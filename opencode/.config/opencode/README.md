# OpenCode — setup & plugin guide

Documentation of this machine's OpenCode setup: what's installed, what each
plugin does, and how to use it. Tracked config lives in
`~/dotfiles/opencode/.config/opencode/` and is linked into
`~/.config/opencode/` with GNU Stow.

## Overview

- **OpenCode CLI** (v1.18.x) + TUI in the terminal.
- **LSP enabled** via `"lsp": true` (opencode ships with LSP off by default —
  `opencode debug lsp diagnostics --print-logs` confirms).
- **2 plugin layers**:
  - `opencode.jsonc` → **server** plugins (tools the agent uses).
  - `tui.json` → **TUI** plugins (panels/sidebar/keybinds in the interface).

## Runtime prerequisites

The Arch bootstrap installs these through `scripts/arch/dev/languages.sh` and
`scripts/arch/core/base-utils.sh`. For another Linux setup, provide them before
starting OpenCode:

| Requirement | Why it is needed | Verify |
| ----------- | ---------------- | ------ |
| Bun (`bun`, `bunx`) | OpenCode's npm-plugin tooling resolves pinned packages into `~/.cache/opencode/packages/`; first use of a new version may download it | `bun --version && bunx --version` |
| fnm + Node 22 | Cavemem runs under a Node 22 selected at launch; no username, fnm storage path, or patch version is hardcoded | `fnm exec --using=22 -- node --version` |
| Cavemem | Provides the local `cavemem` MCP executable | `fnm exec --using=22 -- cavemem --version` |
| `xdg-utils` | Supplies `xdg-open`, used by Linux commands/plugins that hand a URL to the default browser | `command -v xdg-open` |

Arch setup commands:

```sh
sudo pacman -S --needed fnm bun xdg-utils
fnm install 22
fnm default 22
fnm exec --using=22 -- npm install --global cavemem
```

The MCP command is `fnm exec --using=22 -- cavemem mcp`. Upgrading to another
Node 22 patch needs no config edit. Keep Node 26 out of this path until
Cavemem's native `better-sqlite3` dependency supports its V8 ABI.

## Config files

| File                         | What it is                                                      |
| ---------------------------- | --------------------------------------------------------------- |
| `opencode.jsonc`             | Main config (server): LSP + server plugin list                  |
| `tui.json`                   | TUI plugins (sidebar, keybinds, panels)                         |
| `sidebar.json`               | opencode-statusline items (branch, diff, current folder)        |
| `dcp.jsonc`                  | DCP config (schema only — defaults)                             |
| `opencode-notifier-state.json` | Notifier internal state (do not edit)                         |
| `package.json`               | Local deps for plugin types and the Ponytail wrapper             |
| `instructions/`              | Always-loaded agent contracts: `opencode.md` (RTK) + `engineering.md` |
| `agents/`                    | Read-only reviewer/verifier plus Caveman cavecrew agents           |
| `commands/`                  | Custom slash-command workflows plus Caveman commands              |
| `templates/project/`         | Optional project `AGENTS.md`, `.spec/`, and `.mem/` templates     |
| `backups/`                   | Manual snapshots taken before config restructures                 |

## Shell permissions

Normal development commands run without confirmation: RTK, Git/GitHub CLI;
navigation, search, text, comparison, checksum, archive-inspection, temporary
directory, and safe creation commands; shell syntax checks; network/query and
system diagnostics; fnm, uv/Python, npm/Node, pnpm, Yarn, Bun, Rust, Go,
Make/CMake/Ninja, ShellCheck, shfmt, OpenCode, and Stow. This includes bare and
argument forms of common commands such as `wc`, plus `mkdir`, `mktemp`, `touch`,
`ln -s`, and `chmod +x`. Unknown commands still ask first. Credential-printing
and arbitrary network-transfer commands also ask.
Destructive local Git commands keep confirmation enabled; pushes and package
publishing inherit their normal command allow rules.

Creating/switching/finishing worktrees, changing scheduled jobs, global cleanup,
and skill installation require confirmation. Safety Net independently blocks
semantically destructive shell commands, including wrapped variants.

The read-only `planner` denies shell. `reviewer` permits only Git
`status`/`diff`/`log` (direct or through RTK) so it can inspect current changes;
all other shell commands and unlisted tools stay denied. Both deny `.env*`.

## Server plugins (`opencode.jsonc`)

| Plugin | What it does | How to use |
| ------ | ------------ | ---------- |
| `@franlol/opencode-md-table-formatter` | Formats Markdown tables in agent responses (aligned columns) | Automatic |
| `@tarquinen/opencode-dcp` | **Dynamic Context Pruning** — reduces tokens by compressing stale conversation content and removing redundant tool noise | `/dcp`, `/dcp-compress` |
| `@mohak34/opencode-notifier` | Desktop notification (notify-send) when the agent finishes a response | Automatic |
| `opencode-scheduler` | Schedules recurring jobs (cron → systemd) — e.g. run a prompt daily at 9am | `schedule_job`/`list_jobs`/`job_logs` (agent tools) |
| `opencode-worktree-manager` | **Git worktrees**: create/switch/list worktrees via tools (agent does it) | Tools: `worktree_create`, `worktree_list`, `worktree_switch`, `worktree_status`, `worktree_finish` |
| `@bybrawe/opencode-loop` | **Claude Code-style loop/goal**: `/loop` with heartbeat scheduler, idle-safe loops, scheduled commands, compact scheduling; goal mode with checkpoints and verification | `/loop`, `/goal` (plugin commands); `opencode-loopd` daemon |
| `./plugins/caveman/plugin.js` | **Caveman** — terse caveman-style responses (cuts prose: articles, filler, hedging). Local plugin installed via official installer | Automatic (default `full`); `/caveman [lite\|full\|ultra\|off]`, `/caveman-stats`, `/caveman-review` |
| `cc-safety-net` | Semantically blocks destructive Git and filesystem commands, including shell wrappers and interpreter one-liners | Automatic; `npx cc-safety-net doctor` for diagnostics |
| `openrtk` | **RTK proxy for shell commands** — rewrites `git status` → `rtk git status` etc. in `tool.execute.before` (60-90% fewer tokens in dev command output) | Automatic; model instructions in `instructions/opencode.md` (referenced in `instructions` config) |
| `./plugins/ponytail.js` | **Ponytail** — local default-export wrapper around pinned `@dietrichgebert/ponytail`; cuts unnecessary code without triggering OpenCode's named-export loader bug | Automatic (default `full`); `/ponytail [lite\|full\|ultra\|off]`, `/ponytail-review`, `/ponytail-audit` |
| `opencode-update-notifier` | Checks pinned plugins every 6 hours and shows one TUI toast when updates exist; never auto-updates | Automatic |

All npm plugins use exact versions. The update notifier reports newer releases;
upgrades remain explicit config diffs and require an OpenCode restart.

## MCP servers (`opencode.jsonc` → `mcp`)

| Server | What it does | Notes |
| ------ | ------------ | ----- |
| `cavemem` | Persistent cross-session memory (local SQLite) | `fnm exec --using=22 -- cavemem mcp` (see prerequisites) |
| `context7` | Current, version-specific library documentation | Remote `https://mcp.context7.com/mcp`; anonymous rate limits apply |
| `playwright` | Browser automation: E2E tests, scraping, visual debugging | Pinned `npx -y @playwright/mcp@0.0.78` |

## TUI plugins (`tui.json`)

| Plugin | What it does | Keybinds |
| ------ | ------------ | -------- |
| `oc-plugin-gitgud` | **Git in the sidebar**: working tree, stage/unstage, LLM-generated commit messages, push. Replaces the native "Modified Files" card (broken in opencode since v1.16.0) | `<leader>v` status · `<leader>A` stage all · `<leader>U` unstage all · `<leader>C` commit · `<leader>P` push · `F5` refresh |
| `opencode-statusline` | **Status in the sidebar**: current branch, diff (+added ~deleted) and project folder, configurable | Automatic (items defined in `sidebar.json`) |
| `opencode-worktree-manager` | **Worktrees panel** in the sidebar (which is active, dirty files, commits ahead) | Automatic + server tools |
| `opencode-project-panel` | **File manager in the TUI**: browse the folder, preview and edit files straight from the terminal | `F1` file manager · `F2` rename · `F7` create · `Delete` remove · `Ctrl+G` go to path · `Ctrl+R` back to root · `F3` permissions panel (skills/tools/MCP) |
| `@tarquinen/opencode-dcp` | DCP panel in the TUI (context stats, manual controls) | `/dcp` |
| `opencode-subagent-statusline` | Shows native and custom delegated-session status in the TUI statusline | Automatic |

## Efficiency stack (caveman + rtk + cavemem)

- **Caveman** — local plugin (`plugins/caveman/`) that makes responses terse.
  Modes: `/caveman lite|full|ultra|off`, `/caveman-stats` (estimated savings),
  `/caveman-review`. Auto-activates at default `full`. Rules block in
  `AGENTS.md`. **Important:** the installer created a separate `opencode.json`
  — the entry was consolidated into `opencode.jsonc`
  (`"./plugins/caveman/plugin.js"`).
- **RTK + openrtk** — `rtk` (Rust CLI in `~/.cargo/bin`) compresses dev command
  output; `openrtk` (npm plugin) rewrites shell commands automatically. Model
  instructions in `instructions/opencode.md`. Meta:
  `rtk gain`, `rtk discover`. Install from `rtk-ai/rtk` GitHub, not crates.io:
  crates.io has an unrelated Rust Type Kit using the same binary name.
- **Ponytail** — npm plugin that cuts unnecessary code (YAGNI/reuse).
  Complements caveman. `/ponytail [lite|full|ultra|off]`.
- **Cavemem** — persistent cross-session memory via MCP (local SQLite,
  `~/.cavemem/`). Search with `cavemem_search`, expand hits with
  `cavemem_get_observations`, and navigate sessions with
  `cavemem_list_sessions`/`cavemem_timeline`. Runs with
  **Node 22** selected by `fnm exec --using=22`; the command contains no
  machine-specific Node path. **Do not** use Node 26 until the native
  `better-sqlite3` dependency supports its V8 ABI. MCP configured in
  `opencode.jsonc`; installation and checks are in Runtime prerequisites.
- **Cavekit** — skills installed via `npx skills add JuliusBrussee/cavekit -g
  -a opencode -y` → `~/.agents/skills/` (auto-loaded).

## Native agent system

This setup uses OpenCode's native agents and `task` delegation. `micode` and
its `micode.jsonc` role map are not installed. Its embedded octto WebSocket and
browser question flow are therefore absent.

| Native agent | Use |
| ------------ | --- |
| `build` | Default implementation, debugging, and repository work |
| `plan` | Built-in planning mode; may write Markdown plans |
| `planner` | Permission-enforced read-only planning for `/project-plan` |
| `general` | Complex delegated work, including independent parallel units |
| `explore` | Fast read-only codebase search and mapping |

Native `task` calls can launch independent subagents in parallel; use that for
research, locating code, or separate checks. Keep edits to the same files
sequential. For genuinely independent edit streams, create separate worktrees
with `opencode-worktree-manager` first.

OpenCode confirmations, prompts, and selects render as native TUI dialogs.
The plugin API exposes dialog primitives directly, so no modal package is
required. `/project-plan` returns its plan directly in the current TUI.

### Model routing

Built-in agents inherit global `openai/gpt-5.6-sol`. Titles and lightweight
internal work use `small_model` (`opencode-go/gpt-5.6-luna`). Review commands
run through the permission-enforced read-only `reviewer`, select their models
explicitly, and `verifier` keeps its own
`opencode-go/qwen3.7-max` override. These are fixed assignments, not a
failure-based fallback chain. OpenCode Go is authenticated through `/connect`.

## Personal engineering layer

This layer adapts the useful parts of `github.com/oornnery/agents` to native
OpenCode formats without duplicating built-in agents, Cavekit, Caveman, or
Ponytail.

### Agents

| Agent | Mode | Purpose |
| ----- | ---- | ------- |
| `planner` | `subagent` | Permission-enforced read-only planning for `/project-plan` |
| `reviewer` | `subagent` | Generic permission-enforced read-only code review |
| `verifier` | `subagent` | Independent evidence-backed PASS/FAIL/BLOCKED |

Implementation stays on native `build`; specialized behavior comes from
on-demand skills instead of duplicate language agents. `reviewer` receives its
model from each invoking command; `verifier` keeps its model assigned centrally
in `opencode.jsonc`. Both remain hidden subagents.

### On-demand skills

Installed under `~/.agents/skills/`: `python`, `typescript-web`,
`agent-harness`, `verification`, `security`, `project-state`, and `docs`.
They complement Cavekit and load only when relevant. The engineering contract
automatically routes Python work to `python`, TypeScript/JavaScript work to
`typescript-web`, and trust-boundary work to `security`; no `/python` or `/ts`
command is required.

### Commands

| Command | Purpose |
| ------- | ------- |
| `/onboard` | Read-only repository map and quality-gate report |
| `/project-plan` | Read-only `planner` agent in the current TUI; no implementation |
| `/project-bootstrap` | Approved project foundation only; no business features |
| `/debug` | Reproduce → isolate → root cause → regression check |
| `/verify` | Independent read-only verdict from `verifier` |
| `/python-review` | Read-only Python review using `opencode-go/kimi-k2.7-code` |
| `/typescript-review` | Read-only TypeScript/JavaScript review using `opencode-go/kimi-k2.7-code` |
| `/security-review` | Adversarial read-only review using `opencode-go/deepseek-v4-pro` |
| `/fix-checks` | Repair format/lint/type/test/build failures sequentially |
| `/sync-docs` | Align docs with verified code/config without logic changes |
| `/safe-commit` | Explicit staging, secret check, Conventional Commit; no push |

No custom `/plan`, `/commit`, `/review`, or executor agent was added: built-in
OpenCode, Caveman, and Ponytail workflows already own those names.

### Project templates

`templates/project/` contains opt-in files; copy and trim them per repository.
`.spec/` tracks auditable milestone checks/handoffs. `.mem/` is optional durable
project memory; Cavemem remains responsible for session continuity. Voice/LLM
projects should also apply `AGENTS.harness.md` and keep product, architecture,
security, eval, and roadmap details inside that project—not global config.

## Useful CLI commands

```sh
opencode plugin <name> -g        # install plugin globally (server → opencode.jsonc, TUI → tui.json)
opencode plugin <name> -f        # reinstall/update
opencode debug lsp diagnostics --print-logs   # show active LSPs
opencode agent list             # list primary, all-mode, and subagents
opencode debug agent verifier   # inspect merged custom agent definition
opencode debug skill security   # inspect loaded external skill
opencode db path                 # session database location
opencode upgrade                 # update the CLI
```

## Notes / troubleshooting

- **Installed a new plugin?** Restart the TUI (some only load at start).
- **Changed agents, commands, skills, or instructions?** Restart the TUI; config
  is loaded once per process.
- **`rtk gain` rejects `gain`?** Wrong crates.io package is installed. Reinstall
  with `cargo install --git https://github.com/rtk-ai/rtk --locked --force`.
- **Conversation scroll**: `End` or `Ctrl+Alt+G` = go to end · `Home`/`Ctrl+G` = top · `PageUp`/`PageDown` = page (configurable in `tui.json` → `tui.auto_scroll`/`scroll_speed`).
- **"LSPs are disabled"** in the panel is not an error — it was the default; already enabled.
- **Native "Modified Files" card broken** since v1.16.0 (known regression,
  issue #30877/#32852). That's why gitgud uses `replace_sidebar_files = true`.
- **Worktrees says `No worktrees`?** Normal when no auxiliary worktree exists;
  this panel is not a changed-files list. Open GitGud status with `<leader>v`
  and use `F5` to refresh working-tree changes.
- **Plugin asks to install on every start?** npm plugin specs are resolved via
  Bun into `~/.cache/opencode/packages/`. Check cache ownership/write access and
  network availability; this is separate from Cavemem's fnm/Node process.
- **Cavemem reports `posix_spawn`/`ENOENT`?** Run both fnm/Cavemem checks from
  Runtime prerequisites. The config intentionally contains no absolute Node or
  npm-global path.
- **Changed tracked OpenCode config?** Run
  `stow -R --no-folding -v -t ~ opencode` from `~/dotfiles`.
