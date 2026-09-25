#!/usr/bin/env python3
"""Validate AI adapters and cross-file references without loading clients/plugins.

Requires PyYAML. Optional --schema PATH also requires jsonschema.
"""

import argparse
import json
from pathlib import Path
import re
import tomllib

import yaml


ROOT = Path(__file__).resolve().parents[1]
CODEX_MODELS = {"gpt-5.6-luna", "gpt-5.6-terra", "gpt-5.6-sol", "gpt-6-astra"}
OPENCODE_MODELS = {
    "opencode-go/deepseek-v4.1-flash",
    "opencode-go/qwen3.8-flash",
    "opencode-go/glm-5.3",
    "qwen-token-plan/qwen3.8-max",
}
PI_MODELS = {
    "opencode-go": {"deepseek-v4.1-flash", "qwen3.8-flash", "qwen3.8-max", "glm-5.3"},
    # Pi's own provider name for the Alibaba token plan; OpenCode calls it
    # `qwen-token-plan`, so the two adapters are not interchangeable.
    "qwen-token-plan-individual": {"qwen3.8-flash", "qwen3.8-max"},
}
CLAUDE_MODELS = {"opus", "sonnet", "haiku", "fable", "inherit"}
EFFORT = {"low", "medium", "high", "xhigh", "max"}


def frontmatter(path):
    text = path.read_text()
    match = re.match(r"\A---\n(.*?)\n---(?:\n|$)", text, re.S)
    if not match:
        raise ValueError(f"Missing frontmatter: {path}")
    return yaml.safe_load(match[1])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--schema", type=Path)
    args = parser.parse_args()
    opencode = ROOT / "opencode/.config/opencode"
    config = json.loads((opencode / "opencode.jsonc").read_text())
    for name in ("tui.json", "package.json", "dcp.jsonc", "sidebar.json"):
        json.loads((opencode / name).read_text())
    agents = {p.stem: frontmatter(p) for p in (opencode / "agents").glob("*.md")}
    commands = {
        p.stem: {**frontmatter(p), "template": p.read_text().split("---", 2)[2].strip()}
        for p in (opencode / "commands").glob("*.md")
    }
    for name, agent in agents.items():
        assert agent["mode"] in {"primary", "all", "subagent"}, name
        assert agent["model"] in OPENCODE_MODELS, name
        assert agent.get("reasoningEffort", "medium") in {"low", "medium", "high", "xhigh", "max"}, name
        task = agent.get("permission", {}).get("task", {})
        if isinstance(task, dict):
            for target in task:
                assert target == "*" or target in agents, (name, target)
    default = agents[config["default_agent"]]
    assert default["mode"] in {"primary", "all"}
    for name, command in commands.items():
        assert command["agent"] in agents, (name, command["agent"])
        assert isinstance(command.get("subtask"), bool), name
        assert "subagent" not in command, f"v2-only field in v1 command: {name}"
    for plugin in config["plugin"]:
        if plugin.startswith("."):
            assert (opencode / plugin).is_file(), plugin
    token_plan = config["provider"]["qwen-token-plan"]
    assert token_plan["npm"] == "@ai-sdk/openai-compatible"
    assert token_plan["options"]["baseURL"].startswith("https://token-plan.")
    assert token_plan["options"]["apiKey"] == "{env:QWEN_TOKEN_PLAN_API_KEY}"
    for model in ("qwen3.8-max", "qwen3.8-flash", "deepseek-v4.1-flash", "glm-5.3"):
        assert model in token_plan["models"], model

    codex = ROOT / "codex/.codex"
    codex_config = tomllib.loads((codex / "config.toml").read_text())
    assert codex_config["model"] in CODEX_MODELS
    assert codex_config["approval_policy"] == "on-request"
    assert codex_config["sandbox_mode"] == "workspace-write"
    assert config["permission"]["bash"]["*"] == "allow"
    assert "bash" not in agents["verifier"]["permission"], "Verifier must inherit shell policy"
    for name in ("playwright", "chrome_devtools"):
        assert config["permission"][f"{name}_*"] == "allow"
        assert codex_config["mcp_servers"][name]["default_tools_approval_mode"] == "approve"
        for role in ("plan", "explore", "reviewer", "security-reviewer"):
            policy = agents[role]["permission"]
            assert policy[f"{name}_*"] == "allow", role
            assert policy["external_directory"]["*"] == "ask", role
            assert policy["*"] == "deny", role
    for name in ("github", "cloudflare"):
        assert config["permission"][f"{name}_*"] == "ask"
        assert codex_config["mcp_servers"][name]["default_tools_approval_mode"] == "prompt"
    codex_agents = list((codex / "agents").glob("*.toml"))
    skills_root = ROOT / "agents/.agents/skills"
    for path in [*codex_agents, *skills_root.glob("*/agents/*.toml")]:
        agent = tomllib.loads(path.read_text())
        assert agent.get("model", codex_config["model"]) in CODEX_MODELS, path
    skills = list(skills_root.glob("*/SKILL.md"))
    for path in skills:
        meta = frontmatter(path)
        assert meta["name"] == path.parent.name, path
        assert meta["description"], path
    assert set(config["mcp"]) == set(codex_config["mcp_servers"]), "MCP adapter drift"
    for name, server in config["mcp"].items():
        peer = codex_config["mcp_servers"][name]
        assert server["enabled"] == peer.get("enabled", True), name
        if server["type"] == "remote":
            assert server["url"] == peer["url"], name
            headers = dict(server.get("headers", {}))
            if token_var := peer.get("bearer_token_env_var"):
                assert headers.pop("Authorization", None) == f"Bearer {{env:{token_var}}}", name
                assert server.get("oauth") is False, name
            assert headers == peer.get("http_headers", {}), name
        else:
            assert server["command"] == [peer["command"], *peer.get("args", [])], name
            assert server.get("environment", {}) == peer.get("env", {}), name
    claude = ROOT / "claude/.claude"
    claude_settings = json.loads((claude / "settings.json").read_text())
    marketplaces = set(claude_settings.get("extraKnownMarketplaces", {}))
    for plugin in claude_settings.get("enabledPlugins", {}):
        _, _, marketplace = plugin.partition("@")
        assert not marketplace or marketplace in marketplaces, plugin
    claude_hooks = claude_settings.get("hooks", {})
    for event in ("SessionStart", "UserPromptSubmit", "PostToolUse", "Stop", "SessionEnd"):
        hook_commands = [
            hook["command"]
            for group in claude_hooks.get(event, [])
            for hook in group.get("hooks", [])
        ]
        assert any("cavemem hook run" in command for command in hook_commands), event
    claude_agents = list((claude / "agents").glob("*.md"))
    for path in claude_agents:
        meta = frontmatter(path)
        assert meta["name"] == path.stem, path
        assert meta["description"], path
        assert meta.get("model", "inherit") in CLAUDE_MODELS, path
        assert meta.get("effort", "medium") in EFFORT, path
    claude_skills = sorted(p for p in (claude / "skills").iterdir() if p.is_dir())
    agent_names = {p.stem for p in claude_agents} | {"Explore", "Plan", "general-purpose"}
    for directory in claude_skills:
        # Shared skills are symlinks into the agents package; both must resolve.
        meta = frontmatter(directory / "SKILL.md")
        assert meta["description"], directory
        if target := meta.get("agent"):
            assert target in agent_names, directory
            assert meta.get("context") == "fork", directory
    for name, server in json.loads((claude / "mcp/servers.json").read_text()).items():
        assert server["command" if server["type"] == "stdio" else "url"], name

    pi = ROOT / "pi/.pi/agent"
    pi_settings = json.loads((pi / "settings.json").read_text())
    pi_mcp = json.loads((pi / "mcp.json").read_text())["mcpServers"]
    pi_agents = {p.stem: frontmatter(p) for p in (pi / "agents").glob("*.md")}
    pi_prompts = {p.stem: frontmatter(p) for p in (pi / "prompts").glob("*.md")}
    default = f"{pi_settings['defaultProvider']}/{pi_settings['defaultModel']}"
    assert default in OPENCODE_MODELS, default
    assert default in pi_settings["enabledModels"], default
    for package in pi_settings["packages"]:
        # npm pins look like `name@1.2.3`; git pins use a tag (`@v0.1.0`) or a
        # full commit sha. Anything else floats and must not be committed.
        assert re.search(r"@(?:[0-9a-f]{40}|v?\d+\.\d+)", package), f"Unpinned Pi package: {package}"
    assert set(pi_agents) == set(agents), "Pi/OpenCode subagent drift"
    assert set(pi_prompts) == set(commands), "Pi/OpenCode prompt drift"
    for name, agent in pi_agents.items():
        assert agent["name"] == name, name
        assert agent["description"], name
        assert agent["tools"], name
        provider, _, model = agent["model"].partition("/")
        assert model in PI_MODELS.get(provider, set()), name
        assert agent.get("effort", "medium") in EFFORT, name
        if name in {"explore", "plan", "reviewer", "security-reviewer", "verifier"}:
            assert not {"write", "edit"} & set(agent["tools"]), f"Read-only Pi subagent: {name}"
    for name, prompt in pi_prompts.items():
        assert prompt["description"], name
    assert set(pi_mcp) == set(config["mcp"]), "MCP adapter drift (Pi)"
    assert pi_mcp["github"]["headers"]["Authorization"] == "Bearer ${GITHUB_MCP_TOKEN}"
    assert pi_mcp["cavemem"]["command"] == "fnm"

    if args.schema:
        import jsonschema

        schema = json.loads(args.schema.read_text())
        expanded = {**config, "agent": agents, "command": {**config.get("command", {}), **commands}}
        jsonschema.validate(expanded, schema)
    print(f"PASS: {len(agents)} OpenCode agents, {len(commands)} commands, "
          f"{len(codex_agents)} Codex agents, {len(skills)} shared skills; MCP parity; "
          f"{len(claude_agents)} Claude agents, {len(claude_skills)} Claude skills; "
          f"{len(pi_agents)} Pi subagents, {len(pi_prompts)} Pi prompts")


if __name__ == "__main__":
    main()
