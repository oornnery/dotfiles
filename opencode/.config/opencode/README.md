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

## Config files

| File                         | What it is                                                      |
| ---------------------------- | --------------------------------------------------------------- |
| `opencode.jsonc`             | Main config (server): LSP + server plugin list                  |
| `micode.jsonc`               | Per-role model overrides for micode agents                      |
| `tui.json`                   | TUI plugins (sidebar, keybinds, panels)                         |
| `sidebar.json`               | opencode-statusline items (branch, diff, current folder)        |
| `dcp.jsonc`                  | DCP config (schema only — defaults)                             |
| `opencode-notifier-state.json` | Notifier internal state (do not edit)                         |
| `package.json`               | Local deps (`@opencode-ai/plugin`) — used by plugins            |
| `instructions/`              | Always-loaded agent contracts: `opencode.md` (RTK) + `engineering.md` |
| `agents/`                    | Custom engineering agents plus Caveman cavecrew agents            |
| `commands/`                  | Custom slash-command workflows plus Caveman commands              |
| `templates/project/`         | Optional project `AGENTS.md`, `.spec/`, and `.mem/` templates     |
| `backups/`                   | Manual snapshots taken before config restructures                 |

## Server plugins (`opencode.jsonc`)

| Plugin | What it does | How to use |
| ------ | ------------ | ---------- |
| `@franlol/opencode-md-table-formatter` | Formats Markdown tables in agent responses (aligned columns) | Automatic |
| `@tarquinen/opencode-dcp` | **Dynamic Context Pruning** — reduces tokens by compressing stale conversation content (smarter than native compaction: only compresses closed sections, with technical summaries; also removes repeated tool calls and failed tool inputs) | `/dcp`, `/dcp context`, `/dcp stats`, `/dcp sweep [n]`, `/dcp compress [focus]`, `/dcp manual [on\|off]`, `/dcp decompress [id]`, `/dcp recompress [id]` |
| `@mohak34/opencode-notifier` | Desktop notification (notify-send) when the agent finishes a response | Automatic |
| `@plannotator/opencode` | Generates Markdown implementation plans before executing complex tasks | Automatic (agent calls it) |
| `opencode-scheduler` | Schedules recurring jobs (cron → systemd) — e.g. run a prompt daily at 9am | `schedule_job`/`list_jobs`/`job_logs` (agent tools) |
| `micode` | micode agent system (commander, brainstormer, planner, executor, reviewer, etc.) + artifacts/ledgers | Automatic (agents available in session) |
| `opencode-worktree-manager` | **Git worktrees**: create/switch/list worktrees via tools (agent does it) | Tools: `worktree_create`, `worktree_list`, `worktree_switch`, `worktree_status`, `worktree_finish` |
| `@bybrawe/opencode-loop` | **Claude Code-style loop/goal**: `/loop` with heartbeat scheduler, idle-safe loops, scheduled commands, compact scheduling; goal mode with checkpoints and verification | `/loop`, `/goal` (plugin commands); `opencode-loopd` daemon |
| `@vheins/opencode-9router` | **9Router provider** (VPS behind Cloudflare Tunnel + Access): model auto-discovery via `GET {baseURL}/v1/models` (3h cache, stale fallback) | `9router` provider registered with baseURL/key via env vars (see section below) |
| `./plugins/caveman/plugin.js` | **Caveman** — terse caveman-style responses (cuts prose: articles, filler, hedging). Local plugin installed via official installer | Automatic (default `full`); `/caveman [lite\|full\|ultra\|off]`, `/caveman-stats`, `/caveman-review` |
| `openrtk` | **RTK proxy for shell commands** — rewrites `git status` → `rtk git status` etc. in `tool.execute.before` (60-90% fewer tokens in dev command output) | Automatic; model instructions in `instructions/opencode.md` (referenced in `instructions` config) |
| `@dietrichgebert/ponytail` | **Ponytail** — "lazy senior dev mode": cuts unnecessary code (YAGNI, reuse, stdlib first). Complements caveman (caveman cuts prose, ponytail cuts code) | Automatic (default `full`); `/ponytail [lite\|full\|ultra\|off]`, `/ponytail-review`, `/ponytail-audit` |
| `opencode-subagent-statusline` | Shows subagent session status in the TUI statusline (useful with micode's multi-agent workflows) | Automatic |

## MCP servers (`opencode.jsonc` → `mcp`)

| Server | What it does | Notes |
| ------ | ------------ | ----- |
| `cavemem` | Persistent cross-session memory (local SQLite) | Runs with node 22 (see stack section) |
| `playwright` | Browser automation: E2E tests, scraping, visual debugging | `npx -y @playwright/mcp` (downloads on first use) |
| `github` | GitHub issues, PRs, code review native in the agent | Remote server; auth via `GITHUB_PAT` env var (auto-filled from `gh auth token` in `.zshrc`) |

## TUI plugins (`tui.json`)

| Plugin | What it does | Keybinds |
| ------ | ------------ | -------- |
| `oc-plugin-gitgud` | **Git in the sidebar**: working tree, stage/unstage, LLM-generated commit messages, push. Replaces the native "Modified Files" card (broken in opencode since v1.16.0) | `<leader>v` status · `<leader>A` stage all · `<leader>U` unstage all · `<leader>C` commit · `<leader>P` push · `F5` refresh |
| `opencode-statusline` | **Status in the sidebar**: current branch, diff (+added ~deleted) and project folder, configurable | Automatic (items defined in `sidebar.json`) |
| `opencode-worktree-manager` | **Worktrees panel** in the sidebar (which is active, dirty files, commits ahead) | Automatic + server tools |
| `opencode-project-panel` | **File manager in the TUI**: browse the folder, preview and edit files straight from the terminal | `F1` file manager · `F2` rename · `F7` create · `Delete` remove · `Ctrl+G` go to path · `Ctrl+R` back to root · `F3` permissions panel (skills/tools/MCP) |
| `@tarquinen/opencode-dcp` | DCP panel in the TUI (context stats, manual controls) | `/dcp` |

## 9Router (remote provider via Cloudflare Tunnel)

9Router runs on the VPS behind Cloudflare Tunnel + Access (Service Token). The
`@vheins/opencode-9router` plugin registers the provider and auto-discovers
models via `GET {baseURL}/v1/models`.

**Required env vars** (export in the shell before starting opencode):

```sh
export NINE_ROUTER_URL=https://YOUR-DOMAIN/v1      # tunnel endpoint
export NINE_ROUTER_API_KEY=sk-...                  # API key from the 9Router dashboard
export CF_ACCESS_CLIENT_ID=...                     # Cloudflare Access Service Token
export CF_ACCESS_CLIENT_SECRET=...
```

**Cloudflare Zero Trust setup:** `/v1/models` needs a bypass in the Access
policy (the plugin's model discovery does not send the Service Token headers —
upstream PR open to fix). `/v1/chat/completions` still requires the Service
Token via `options.headers`.

**Configured provider model:** `9router/auto` routes automatically across tiers.
It is currently optional rather than the global default: model discovery returns
no 9Router models until real environment values and the Access policy are set.
The global default is `openai/gpt-5.6-sol`; specialized agents use strong
OpenAI and OpenCode Go models. Select `9router/auto` after `opencode models`
lists it. OpenCode has no native failure-based model chain; automatic failover
comes from 9Router when that provider is active.

**Verify:** `opencode models | grep 9router` → should list `9router/auto` and
the provider's models.

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
  `~/.cavemem/`), 3 tools (`remember`/`recall`/`forget`-like). Runs with
  **node 22** (`~/.fnm/node-versions/v22.23.2/...`) — **do not** use node 26
  (better-sqlite3 does not compile with the new V8). MCP configured in
  `opencode.jsonc`.
- **Cavekit** — skills installed via `npx skills add JuliusBrussee/cavekit -g
  -a opencode -y` → `~/.agents/skills/` (auto-loaded).

## Agent system (micode / octto)

`micode` embeds the octto system: one orchestrator (`commander`) that
delegates to specialized subagents. Subagents are invisible in the TUI agent
selector (`mode: subagent`) — only `commander` and `brainstormer` are
`primary` and directly selectable.

**Your 2 decisions:**

| You want...                      | Do this                                                   |
| -------------------------------- | --------------------------------------------------------- |
| Normal task (code, bug, research) | Nothing — stay on `commander` (default)                   |
| Vague idea, needs design         | Select `brainstormer` in the TUI (`Ctrl+X+a` → brainstormer) |

**What `commander` decides automatically:**

| Agent                                        | When it's invoked                               | Typical trigger                    |
| -------------------------------------------- | ----------------------------------------------- | ---------------------------------- |
| `planner`                                    | Request is clear enough to plan, but not to code | "build feature X with these 3 parts" |
| `executor` → `implementer` + `reviewer`      | Plan is ready, time to code                     | "implement the plan"               |
| `codebase-locator` / `codebase-analyzer` / `pattern-finder` | Questions about existing code   | "how does auth work here?"         |
| `ledger-creator` / `artifact-searcher`       | Session end/start (continuity)                  | automatic between sessions         |
| `mm-orchestrator`                            | Generate/update `.mindmodel/`                   | on demand, rare                    |
| `octto` / `bootstrapper` / `probe`           | Internally by `brainstormer`, to build questions | automatic inside brainstorm        |

**Workflows:**

1. **Bug**: "login is broken" → `commander` → `codebase-locator` finds file →
   `implementer` fixes → `reviewer` verifies. **You: 1 sentence.**
2. **Medium feature**: "add CSV export" → `commander` → `planner` makes plan →
   `executor` implements. **You: 1 sentence.**
3. **Vague idea**: "I want better performance" → **you switch to
   `brainstormer`** → it asks design questions → design comes out → back to
   `commander` → `planner` → `executor`. **You: answer questions.**

90% of the time you only use `commander`. The only manual switch worth making
is `brainstormer`, and only when the idea is still blurry.

### Model routing

| Role | Model |
| ---- | ----- |
| Global default, `commander`, `executor` | `openai/gpt-5.6-sol` |
| `brainstormer`, `planner` | `openai/gpt-5.6-terra` |
| `implementer`, Python/TypeScript engineers | `opencode-go/kimi-k2.7-code` |
| `reviewer`, security engineer | `opencode-go/deepseek-v4-pro` |
| Codebase analysis | `opencode-go/glm-5.2` |
| Pattern finding, independent verification | `opencode-go/qwen3.7-max` |
| Titles and lightweight work (`small_model`) | `opencode-go/gpt-5.6-luna` |

These are fixed role assignments, not a failure-based fallback chain. OpenCode
Go is authenticated through `/connect`; 9Router owns automatic tier fallback
when `9router/auto` is selected.

## Personal engineering layer

This layer adapts the useful parts of `github.com/oornnery/agents` to native
OpenCode formats without duplicating micode, Cavekit, Caveman, or Ponytail.

### Agents

| Agent | Mode | Purpose |
| ----- | ---- | ------- |
| `python-engineer` | `all` | Python implementation/debugging with project-native tooling |
| `typescript-engineer` | `all` | TypeScript/JavaScript web, API, and Node work |
| `security-engineer` | `subagent` | Read-only adversarial security review |
| `verifier` | `subagent` | Independent evidence-backed PASS/FAIL/BLOCKED |

The two `all` agents appear in the TUI and can also be delegated. Security and
verification remain hidden subagents. Their models are assigned centrally in
`opencode.jsonc`; no Claude-specific alias is embedded in agent files.

### On-demand skills

Installed under `~/.agents/skills/`: `python`, `typescript-web`,
`agent-harness`, `verification`, `security`, `project-state`, and `docs`.
They complement Cavekit and load only when relevant.

### Commands

| Command | Purpose |
| ------- | ------- |
| `/onboard` | Read-only repository map and quality-gate report |
| `/project-plan` | Native `plan` agent + Plannotator approval; no implementation |
| `/project-bootstrap` | Approved project foundation only; no business features |
| `/debug` | Reproduce → isolate → root cause → regression check |
| `/verify` | Independent read-only verdict from `verifier` |
| `/fix-checks` | Repair format/lint/type/test/build failures sequentially |
| `/sync-docs` | Align docs with verified code/config without logic changes |
| `/safe-commit` | Explicit staging, secret check, Conventional Commit; no push |

No custom `/plan`, `/commit`, `/review`, or planner/executor agents were added:
existing native, micode, Caveman, and Ponytail workflows already own those names.

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
- **9Router absent from `opencode models`?** Keep global fallback model active;
  fill real env vars and fix `/v1/models` Access policy before selecting it.
- **`rtk gain` rejects `gain`?** Wrong crates.io package is installed. Reinstall
  with `cargo install --git https://github.com/rtk-ai/rtk --locked --force`.
- **Conversation scroll**: `End` or `Ctrl+Alt+G` = go to end · `Home`/`Ctrl+G` = top · `PageUp`/`PageDown` = page (configurable in `tui.json` → `tui.auto_scroll`/`scroll_speed`).
- **"LSPs are disabled"** in the panel is not an error — it was the default; already enabled.
- **Native "Modified Files" card broken** since v1.16.0 (known regression,
  issue #30877/#32852). That's why gitgud uses `replace_sidebar_files = true`.
- **Changed tracked OpenCode config?** Run
  `stow -R --no-folding -v -t ~ opencode` from `~/dotfiles`.
