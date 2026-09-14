#!/usr/bin/env python3
"""Apply the repository's user-scope MCP servers to Claude Code.

Claude Code keeps user-scope MCP servers in ~/.claude.json, a file it writes for
itself, so the canonical list lives in claude/.claude/mcp/servers.json here and is
merged in by this script. The `claude` CLI is used when it is on PATH; otherwise the
file is merged directly after a backup.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
SERVERS = ROOT / "claude/.claude/mcp/servers.json"


def load_servers() -> dict:
    servers = json.loads(SERVERS.read_text())
    if not isinstance(servers, dict) or not servers:
        raise SystemExit(f"{SERVERS} must be a non-empty object")
    return servers


def apply_with_cli(servers: dict) -> None:
    # add-json refuses an existing name and has no --force, so skip what is there.
    existing = subprocess.run(
        ["claude", "mcp", "list"], capture_output=True, text=True
    ).stdout
    for name, config in servers.items():
        if f"{name}:" in existing:
            print(f"{name}: already configured")
            continue
        subprocess.run(
            ["claude", "mcp", "add-json", name, json.dumps(config), "--scope", "user"],
            check=True,
        )
        print(f"claude mcp add-json {name} --scope user")


def apply_with_merge(servers: dict, config_path: Path) -> None:
    data = {}
    if config_path.exists():
        backup = config_path.with_suffix(f".json.bak.{time.strftime('%Y%m%d%H%M%S')}")
        shutil.copy2(config_path, backup)
        print(f"Backed up {config_path} to {backup}")
        data = json.loads(config_path.read_text())
    existing = data.get("mcpServers") or {}
    for name, config in servers.items():
        if existing.get(name) == config:
            continue
        existing[name] = config
        print(f"merged mcpServers.{name}")
    data["mcpServers"] = existing
    tmp = config_path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(data, indent=2) + "\n")
    os.replace(tmp, config_path)
    config_path.chmod(0o600)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="write the changes")
    parser.add_argument(
        "--config",
        type=Path,
        default=Path(os.environ.get("DOTFILES_AI_TARGET", Path.home())) / ".claude.json",
    )
    args = parser.parse_args()

    servers = load_servers()
    if not args.apply:
        print(f"Would configure {len(servers)} user-scope MCP servers:")
        for name in servers:
            print(f"  - {name}")
        print(f"Target: {args.config}")
        return

    if shutil.which("claude"):
        apply_with_cli(servers)
    else:
        print("claude CLI not on PATH; merging into the config file directly.")
        apply_with_merge(servers, args.config)

    needs_env = [n for n, c in servers.items() if "GITHUB_MCP_TOKEN" in json.dumps(c)]
    if needs_env and not os.environ.get("GITHUB_MCP_TOKEN"):
        print("GITHUB_MCP_TOKEN is unset; " + ", ".join(needs_env) + " will not connect.")
    print("Cloudflare needs an interactive login: /mcp inside Claude Code.")


if __name__ == "__main__":
    main()
