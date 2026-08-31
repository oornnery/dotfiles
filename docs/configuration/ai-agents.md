# OpenCode and Codex setup

GNU Stow keeps one versioned source of truth while respecting each client's native
configuration format.

## Layout

```text
agents/.agents/skills/        shared workflow and domain skills
opencode/.config/opencode/    OpenCode agents, commands, routing, MCPs, permissions
codex/.codex/                 Codex agents, guidance, MCPs, and config
```

Skills are genuinely shared: both clients discover `~/.agents/skills/<name>/SKILL.md`.
Agent manifests and MCP configuration are adapters because OpenCode uses Markdown and
JSONC while Codex uses TOML. Do not symlink one client's config file over the other.

## Shared skills

The shared package includes architecture, agent design, CI/CD, debugging, system and
API design, documentation, frontend design, Git, project state, Python, Python CLI and
library work, Python web, quality, security, TypeScript/web, and verification.

Package-specific skills from the imported overlay are intentionally omitted:
`httpx`, `polars`, `textual`, and `voip-sip`. `skill-builder` is also omitted because
each client already provides a native skill-authoring workflow.

## Role mapping

| Intent               | OpenCode                    | Codex               |
| -------------------- | --------------------------- | ------------------- |
| architecture         | `architect`                 | `architect`         |
| implementation plan  | `planner`                   | `planner`           |
| code discovery       | `explore`                   | `explorer`          |
| root-cause debugging | `debugger`                  | `debugger`          |
| frontend work        | `frontend`, `frontend-fast` | `frontend`          |
| code review          | `reviewer`                  | `reviewer`          |
| security audit       | `security-reviewer`         | `security-reviewer` |
| acceptance evidence  | `verifier`                  | `verifier`          |

OpenCode keeps additional specialized implementation roles, but all role models use
the authenticated OpenAI family: Sol for Qwen/DeepSeek-class reasoning, Terra for
GLM-class implementation, and Luna for fast exploration or tiny changes. A role
describes how to work; shared skills provide stack or domain knowledge.

## MCP parity

Both clients configure the same three servers:

| Server       | Transport   | Purpose                           |
| ------------ | ----------- | --------------------------------- |
| `cavemem`    | local stdio | durable project/session memory    |
| `context7`   | remote HTTP | current library documentation     |
| `playwright` | local stdio | browser inspection and automation |

Credentials are never stored in this repository. OAuth state and API keys remain in
each client's private runtime storage or environment. MCP syntax is intentionally
duplicated because the clients use different schemas.

## Apply

From the dotfiles repository:

```bash
stow -R --no-folding -v -t ~ agents
stow -R --no-folding -v -t ~ opencode
stow -R --no-folding -v -t ~ codex
```

Restart both clients after changing global instructions, agent manifests, skills, or
MCP configuration.

## Validate

```bash
opencode agent list
opencode debug agent architect
opencode debug skill python
codex mcp list
```

In Codex, start a new session and ask it to list available custom agents and shared
skills. In OpenCode, use the role commands under `~/.config/opencode/commands/`.
