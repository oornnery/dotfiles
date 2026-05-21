# AI / LLM Stack Cheatsheet

Setup by `scripts/arch/dev/llms.sh` (toggled via `ENABLE_*` in `arch.conf`).
Launcher: `M+I` opens a walker picker over installed LLM CLIs → floats in alacritty.

## Quick reference

| Tool          | Bin      | Trigger / install                                          |
| ------------- | -------- | ---------------------------------------------------------- |
| Claude Code   | `claude` | `curl claude.ai/install.sh \| bash` · `claude` to launch  |
| Codex         | `codex`  | AUR `openai-codex` or `npm i -g @openai/codex`            |
| Antigravity   | `antigravity` | `curl antigravity.google/cli/install.sh \| bash`     |
| Ollama        | `ollama` | `pacman -S ollama` + `systemctl enable --now ollama`      |
| LM Studio     | (GUI)    | `paru -S lmstudio` (opt-in)                               |
| RTK           | `rtk`    | `curl rtk-ai/rtk/install.sh \| sh` + `rtk init --global`  |
| caveman       | (skill)  | `curl JuliusBrussee/caveman/install.sh \| bash`           |
| cavekit       | (plugin) | `git clone ~/.claude/plugins/cavekit`                     |
| cavemem       | `cavemem`| `npm i -g cavemem` + `cavemem install`                    |

## Claude Code

| Command                  | What                                          |
| ------------------------ | --------------------------------------------- |
| `claude`                 | Launch the CLI                                |
| `claude login`           | First-time auth (browser flow)                |
| `claude logout`          | Clear stored creds                            |
| `claude --resume`        | Continue last session                         |
| `claude /help`           | In-session help                               |
| `claude /init`           | Generate CLAUDE.md from current repo          |
| `claude /memory`         | View/edit persistent memories                 |
| `claude /clear`          | Reset conversation context                    |
| `claude --print "<msg>"` | One-shot non-interactive query                |

Skills + agents in `~/.claude/skills/` (caveman, cavekit lives here too).

## Codex CLI

| Command                  | What                                  |
| ------------------------ | ------------------------------------- |
| `codex`                  | Launch interactive Codex              |
| `codex login`            | Authenticate                          |
| `codex "<prompt>"`       | One-shot                              |
| `codex --model <name>`   | Choose model explicitly               |

## Antigravity (Google CLI)

| Command           | What                                            |
| ----------------- | ----------------------------------------------- |
| `antigravity`     | Launch interactive Antigravity agent            |
| `antigravity --help` | Available subcommands                        |

## Ollama (local LLM runtime)

| Command                          | What                                 |
| -------------------------------- | ------------------------------------ |
| `ollama list`                    | List installed models                |
| `ollama pull <model>`            | Download a model                     |
| `ollama run <model>`             | Interactive REPL                     |
| `ollama run <model> "<prompt>"`  | One-shot                             |
| `ollama rm <model>`              | Remove                               |
| `ollama ps`                      | Running models                       |
| `ollama serve`                   | Run as daemon (systemd handles this) |
| `systemctl status ollama`        | Service health                       |

Default API: `http://localhost:11434/api`. Compatible with OpenAI clients via
`OPENAI_API_BASE=http://localhost:11434/v1`.

Common models for daily use:

| Model              | Best for                           |
| ------------------ | ---------------------------------- |
| `llama3.2:3b`      | Fast Q&A, low RAM (4GB)            |
| `qwen2.5-coder:7b` | Code completion / explanation      |
| `deepseek-r1:7b`   | Reasoning / step-by-step           |
| `nomic-embed-text` | Embeddings (RAG)                   |

## RTK (token killer / prompt optimizer)

CLI proxy that rewrites your prompts before they hit Claude/Codex to
reduce token consumption 60-90% on common dev commands.

| Command                | What                                    |
| ---------------------- | --------------------------------------- |
| `rtk init --global`    | Install hooks for current user          |
| `rtk init`             | Install hooks for current project       |
| `rtk status`           | Show active integrations                |
| `rtk filters list`     | Show active filters                     |
| `rtk filter add <…>`   | Add custom token-reduction filter       |
| `rtk stats`            | Token savings since install             |
| `rtk disable` / `enable` | Toggle filtering                      |

## Caveman ecosystem (JuliusBrussee)

### caveman — output compression

Skill that makes the AGENT respond in caveman-language (terse, ~65% fewer
output tokens). Triggered inside Claude Code / Codex / Gemini CLI.

| Command (inside agent)         | What                                 |
| ------------------------------ | ------------------------------------ |
| `/caveman`                     | Toggle caveman mode                  |
| `/caveman lite`                | Mild compression                     |
| `/caveman full`                | Default level                        |
| `/caveman ultra`               | Maximum (sometimes unreadable)       |
| `/caveman wenyan`              | Classical-Chinese-style compression  |
| `/caveman-commit`              | Generate terse commit message        |
| `/caveman-review`              | One-line PR comment                  |
| `/caveman-stats`               | Session token usage + lifetime saved |
| `/caveman-compress <file>`     | Rewrite a memory file (~46% smaller) |
| say `"normal mode"`            | Exit caveman mode                    |

### cavekit — spec-driven dev

Plugin for Claude Code: writes a `SPEC.md`, generates build plans,
feeds test failures back. Persists across context resets.

| Command (inside Claude)        | What                                      |
| ------------------------------ | ----------------------------------------- |
| `/ck:spec <description>`       | Create / amend `SPEC.md` from natural lang |
| `/ck:build`                    | Generate + execute plan from SPEC.md      |
| `/ck:check`                    | Drift report (code vs spec)               |

Files: `SPEC.md` in repo root (commit it). Plugin: `~/.claude/plugins/cavekit`.

### cavemem — persistent memory

Cross-session memory: captures events, compresses ~75%, stores in SQLite,
exposes via MCP to any compatible agent.

| Command (shell)                | What                                            |
| ------------------------------ | ----------------------------------------------- |
| `cavemem install`              | Register hooks for Claude Code (default)        |
| `cavemem install --ide cursor` | For Cursor                                      |
| `cavemem install --ide gemini-cli` | For Gemini CLI                              |
| `cavemem install --ide opencode`   | For OpenCode                                |
| `cavemem install --ide codex`  | For Codex                                       |
| `cavemem status`               | Service + hook state                            |
| `cavemem search <query>`       | Search memory                                   |
| `cavemem viewer`               | Web UI at `http://localhost:37777`              |
| `cavemem config`               | Edit settings                                   |

| caveman vs cavemem | Compresses                |
| ------------------ | ------------------------- |
| **caveman**        | OUTPUT (what agent says)  |
| **cavemem**        | INPUT (what agent recalls)|

## Custom agents (`~/.agents`)

Cloned from `oornnery/.agents` (`ENABLE_AGENTS=1`, `AGENTS_REPO` overridable).

| Command                | What                                      |
| ---------------------- | ----------------------------------------- |
| `cd ~/.agents`         | Browse skills                              |
| `git -C ~/.agents pull`| Update                                    |

## Bindings (Hyprland)

| Bind     | Action                                                |
| -------- | ----------------------------------------------------- |
| `M + I`  | walker picker → `floating-tui <chosen-LLM>` (alacritty) |

Direct via terminal: `llm claude`, `llm codex`, `llm gemini`, `llm ollama`, etc.

## Workflow recipes

### Start a session with output compression

```bash
claude
> /caveman full
> implement the parser in src/parser.ts
```

### Spec-driven feature

```bash
claude
> /ck:spec  "add OAuth login with Google + persistent sessions"
# ... reviews SPEC.md, you tweak ...
> /ck:build
# ... runs, fails tests, updates spec, iterates ...
> /ck:check
```

### Local-only privacy mode

```bash
ollama run qwen2.5-coder:7b
# or via OpenAI-compatible:
export OPENAI_API_BASE=http://localhost:11434/v1
export OPENAI_API_KEY=ollama
codex "explain this function" --model qwen2.5-coder:7b
```

### See lifetime token savings

```bash
rtk stats           # RTK proxy savings
# inside Claude:
/caveman-stats      # output compression savings
cavemem viewer      # memory store + savings dashboard
```

## Tips

| Tip                                              | Why                                       |
| ------------------------------------------------ | ----------------------------------------- |
| `caveman` + `rtk` stack (input + output)         | Combined 80-90% token reduction           |
| `cavemem` keeps context across `/clear`          | No more re-explaining your codebase       |
| `cavekit` SPEC.md → commit it                    | Onboarding doc + agent build plan in one  |
| `ollama` for sensitive code                      | Nothing leaves the machine                |
| Switch model with `--model` per command          | Cheaper model for trivia, smart for code  |
| `M + I` picker > memorizing 5 different binaries | One muscle memory for all LLMs            |
