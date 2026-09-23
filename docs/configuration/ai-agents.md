# Claude Code, Codex, OpenCode and Pi

One maintained setup, five GNU Stow packages:

- `agents/.agents/skills/`: shared domain skills and pinned Impeccable.
- `claude/.claude/`: Claude Code contract, subagents, skills, output styles, MCP list.
- `codex/.codex/`: Codex configuration and small role adapters.
- `opencode/.config/opencode/`: OpenCode modes, command shortcuts and configuration.
- `pi/.pi/agent/`: Pi contract, settings, subagents, prompt templates and MCP servers.

Claude Code is the daily driver on the primary machine; OpenCode and Pi are the
alternates and back Neovim's `opencode` integration; Codex stays maintained too.

User requests and project instructions override personal defaults. Ordinary work
does not require SPEC.md, planning approval, automatic commits or a fixed test ladder.

## Claude Code

`claude/.claude/` carries `CLAUDE.md` (the personal contract), `settings.json`
(permissions, the RTK hook, plugin marketplaces), `agents/`, `skills/`,
`output-styles/`, `RTK.md`, and `mcp/servers.json`. The eight shared skills are
symlinks into `agents/.agents/skills/`, so every client reads one copy.

| Agent               | Model  | Effort | Purpose                                    |
| ------------------- | ------ | ------ | ------------------------------------------ |
| `deep`              | opus   | high   | Difficult implementation and migrations    |
| `debugger`          | opus   | high   | Root cause; fixes when requested           |
| `reviewer`          | opus   | high   | Read-only code review                      |
| `security-reviewer` | opus   | high   | Read-only security audit                   |
| `verifier`          | sonnet | high   | PASS / FAIL / BLOCKED with evidence        |
| `frontend`          | opus   | medium | Impeccable UI design and implementation    |
| `shape`             | opus   | medium | Product definition and requested documents |
| `fast`              | haiku  | low    | Small edits, quick answers, docs           |

`Explore` and `Plan` are built in and not duplicated. Skills mirror the OpenCode
commands: `/implement`, `/deep`, `/debug`, `/fast`, `/plan`, `/shape`, `/frontend`,
`/docs`, `/tests`, `/verify`, `/safe-commit`, `/project-bootstrap`, plus the caveman
family. The **Caveman** output style makes compressed prose the default; `/caveman`
applies to one session only.

MCP servers come from `claude/.claude/mcp/servers.json` and are applied at user scope
by `scripts/claude-mcp.py`, which uses `claude mcp add-json --scope user` when the CLI
is present and otherwise merges into `~/.claude.json` after a timestamped backup.

Cavemem memory is written by hooks in `settings.json` for `SessionStart`,
`UserPromptSubmit`, `PostToolUse`, `Stop` and `SessionEnd`, each running
`fnm exec --using=22 -- cavemem hook run <event> --ide claude-code`. Session start
injects compressed summaries of up to three prior sessions, and the MCP tools expose
search, timeline and observation reads. Verify with `cavemem status`, `cavemem doctor`
or `cavemem search "<term>"`. Do not run `cavemem install --ide claude-code`: it
replaces these hooks with a version-pinned node path and adds a duplicate `mcpServers`
block to `settings.json`, while user-scope servers stay in `~/.claude.json`.

Context is bounded by `autoCompactWindow: 300000` in `settings.json`, so auto-compact
runs well before the 1M window fills. Change it per session with `/autocompact`, and
keep tool search enabled (the default) so MCP tool definitions are deferred.

Five plugins are declared in `settings.json` and their marketplaces clone at startup,
but declaring a plugin enabled does not install it:

```bash
claude plugin install ck@cavekit-marketplace --scope user --yes
claude plugin install ponytail@ponytail --scope user --yes
claude plugin install pyright-lsp@claude-plugins-official --scope user --yes
claude plugin install codex@openai-codex --scope user --yes
claude plugin install frontend-design@claude-plugins-official --scope user --yes
```

- **ck** ([cavekit](https://github.com/JuliusBrussee/cavekit)) — spec-driven loop over
  one `SPEC.md`, plus bug-to-spec backprop and the caveman spec encoding.
- **ponytail** ([ponytail](https://github.com/DietrichGebert/ponytail)) — cuts
  unnecessary *code*: YAGNI, stdlib first. Its hooks need `node` on the PATH.
- **pyright-lsp** (official) — Pyright language-server diagnostics for Python.
- **codex** ([openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc)) —
  delegate tasks and reviews from Claude Code to the Codex CLI.
- **frontend-design** (official) — Anthropic's visual-direction skill for distinctive
  UI. It overlaps the `impeccable` playbooks; the `frontend` agent still routes to
  Impeccable.

RTK rewrites shell commands through a `PreToolUse` hook declared as
`"$HOME/.cargo/bin/rtk" hook claude`; it stays inert if the binary is missing.

The desktop app ships no Linux CLI — under WSL it drives shells from the Windows side,
so `claude` is absent and the `/plugin`, `/hooks` and `/config` dialogs never open in
its Code tab. `scripts/llms.sh` installs the CLI into `~/.local`.

## OpenCode modes

Press **Tab / Shift+Tab** to cycle modes, or **leader+a** to open the agent picker.
`build` is the default. Modes marked `all` are both selectable and available as
subagents; `explore` stays a discovery subagent.

| Mode              | Model                             | Effort | Purpose                                            |
| ----------------- | --------------------------------- | ------ | -------------------------------------------------- |
| build             | opencode-go/deepseek-v4.1-flash   | medium | Daily implementation                               |
| fast              | opencode-go/qwen3.8-flash         | low    | Small edits, quick answers, docs                   |
| plan              | opencode-go/glm-5.3               | high   | Read-only technical planning and architecture      |
| shape             | opencode-go/glm-5.3               | medium | Product definition and requested project documents |
| deep              | qwen-token-plan/qwen3.8-max       | high   | Difficult implementation and migrations            |
| debugger          | qwen-token-plan/qwen3.8-max       | high   | Root cause; fixes when requested                   |
| frontend          | qwen-token-plan/qwen3.8-max       | medium | Impeccable UI design and implementation            |
| reviewer          | opencode-go/glm-5.3               | high   | Read-only code review                              |
| security-reviewer | qwen-token-plan/qwen3.8-max       | high   | Read-only security audit                           |
| verifier          | opencode-go/deepseek-v4.1-flash   | high   | Acceptance checks and evidence                     |
| explore           | opencode-go/qwen3.8-flash         | low    | Read-only local discovery; subagent only           |

Default and small models come from OpenCode Go (`opencode-go/*`), authenticated with
`/connect`, and heavy roles use the custom `qwen-token-plan` provider: Alibaba's Qwen
Token Plan on the international endpoint
`https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1`, reading
`QWEN_TOKEN_PLAN_API_KEY`. Swap the base URL to
`https://token-plan.cn-beijing.maas.aliyuncs.com/compatible-mode/v1` for the China
plan. The OpenCode Go catalog was checked for every `opencode-go/*` ID; the Alibaba
provider exposes the models listed in `opencode.jsonc`, which is a superset of the
ones used in the table. Role assignments are a starting policy, not a claim that one
model always wins. Escalate an unexpectedly difficult task through the mode picker.

The 15 command files are shortcuts with `subtask: false`, so work remains in the
current session: `/implement`, `/fast`, `/plan`, `/shape`, `/deep`, `/debug`,
`/frontend`, `/review`, `/security-review`, `/verify`, `/tests`, `/docs`,
`/project-bootstrap`, `/safe-commit`, and `/impeccable`.
Selecting a read-only mode does not authorize implementing its findings.
`/safe-commit` explicitly requests a commit; it never pushes.

Use `opencode web --hostname 127.0.0.1 --port 4096` from a terminal for the web UI.
Set `OPENCODE_SERVER_PASSWORD` in your private environment when authentication is needed.

## Pi

`pi/.pi/agent/` carries `AGENTS.md` (the personal contract), `settings.json`,
`mcp.json`, `agents/` and `prompts/`. Pi reads `AGENTS.md` plus ancestor files as
context, and auto-discovers `~/.agents/skills/`, so the shared skills need no
settings entry. `settings.json` sets the `opencode-go/deepseek-v4.1-flash` default
with `qwen3.8-flash`, `qwen3.8-max` and `glm-5.3` in the Ctrl+P list, plus three
pinned packages:

- [pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) v2.36.0 — lazy `mcp`
  proxy tool; `~/.pi/agent/mcp.json` holds the same six servers as Codex and OpenCode.
- [pi-subagents-j0k3r](https://github.com/j0k3r-dev-rgl/pi-subagents-j0k3r) v1.6.1 —
  the `agents/*.md` subagents, reachable through `subagent_run` and `/subagents`.
- [pi-plan-task](https://www.npmjs.com/package/pi-plan-task) v5.0.5 — the `/pt`
  Plan → Review → Approve → Build → Verify workflow.

Pi subagents mirror the OpenCode modes; read-only roles keep read-only tool lists.

| Subagents                         | Model                           | Effort        |
| --------------------------------- | ------------------------------- | ------------- |
| build, verifier                   | opencode-go/deepseek-v4.1-flash | medium / high |
| fast, explore                     | opencode-go/qwen3.8-flash       | low           |
| plan, reviewer                    | opencode-go/glm-5.3             | high          |
| shape                             | opencode-go/glm-5.3             | medium        |
| deep, debugger, security-reviewer | qwen-token-plan/qwen3.8-max     | high          |
| frontend                          | qwen-token-plan/qwen3.8-max     | medium        |

`prompts/` ports the 15 command shortcuts as prompt templates, so `/implement`,
`/review`, `/safe-commit` and the rest behave like their OpenCode counterparts. Pi
has no built-in permission prompts, MCP tool subsetting or plan mode: those come
from the packages above and from the agent tool lists. Treat that as the boundary;
there is no interactive approval gate to fall back on.

## Codex roles

Codex keeps the existing OpenAI subscription tiers; it is not part of the OpenCode
Go/Alibaba migration. The main session keeps Astra/medium. Explorer and fast use
Luna/low; worker uses Terra/medium; verifier uses Terra/high; planner and reviewer
use Sol/high; architect, debugger and security-reviewer use Astra/high; frontend
uses Astra/medium.

Roles express scope and permissions, not a second development methodology.
Models are pinned in the small client-native agent files so costs are explicit.
The independent review roles retain read-only boundaries.

## Skills and Impeccable

Versioned personal skills: `python`, `python-cli`, `python-library`, `python-web`,
`typescript-web`, `security`, `project-state`, and `impeccable`.
The Python web preference remains FastAPI/Jinja with restrained progressive enhancement.
Existing repository choices take precedence.

Impeccable is vendored from [pbakaus/impeccable](https://github.com/pbakaus/impeccable),
revision `dbdc470e70dbbda69f9b78ee38bc38ea1d3560b9`, skill version **4.2.2**.
Its Apache-2.0 license is included alongside the skill. Trailing whitespace in three
upstream reference files is normalized for Git checks. Upstream references, scripts
and nested Codex agents are retained. The launcher pins its engine version separately
in `scripts/VERSION`; its first use may download the platform binary into the user's
Impeccable cache. No global edit hooks were installed.

Examples:

- Codex: `$impeccable polish src/` or `$impeccable critique src/`.
- OpenCode: select `frontend`, or run `/impeccable polish src/`.
- Pi: select the `frontend` subagent, or run `/impeccable polish src/`.
- Use `/shape` for product definition; use `/impeccable shape` for UX/UI planning.

The shared global directory can also contain independently installed skills, such as
Cloudflare and writing tools. They are preserved; they are not all owned by this repo.
Do not reinstall a wildcard collection of generic workflow skills through bootstrap.

Codex disables seven duplicate Cloudflare plugin skills through
[`skills.config`](https://learn.chatgpt.com/docs/build-skills), keeping the newer
shared copies available to both clients: `agents-sdk`, `cloudflare`,
`durable-objects`, `sandbox-sdk`, `web-perf`, `workers-best-practices`, and `wrangler`.
The plugin's unique `building-ai-agent-on-cloudflare` and
`building-mcp-server-on-cloudflare` skills are retained. No vendor files are deleted.
The overrides target the installed plugin version `0.1.2` and this account's
absolute cache paths; recheck them after plugin upgrades or on another machine.
The CLI accepted the strict configuration and an isolated discovery of the cached
plugin skills confirmed the seven disabled/two enabled flags. This does not test
the current app session's already-injected skill list; start a new session to
refresh it.

## Plugins and MCP

OpenCode server plugins retained: table formatter, DCP, notifier, safety net and
update notifier. TUI plugins retained: DCP, GitGud, statusline, project panel and
subagent statusline. Their versions remain pinned. Caveman, Ponytail, automatic
loops, scheduler, worktree-manager and automatic RTK rewriting were removed.
Git worktrees remain available through Git itself; RTK can still be used explicitly.

Codex, OpenCode and Pi declare the same six MCP servers:

| Server          | Purpose                                           |
| --------------- | ------------------------------------------------- |
| context7        | Current library documentation                     |
| playwright      | Browser interaction and UI verification           |
| cavemem         | Durable cross-session memory                      |
| chrome_devtools | Performance traces, network and console diagnosis |
| github          | Repositories, issues, pull requests and Actions   |
| cloudflare      | Cloudflare API search and approved execution      |

Cavemem retains the existing Node 22/fnm launch adapter. Ensure `fnm`, Node 22 and
`cavemem` are on PATH. Only Claude Code registers write hooks; Codex, OpenCode and Pi
read the same database through the MCP tools. Hooks persist truncated tool
inputs/outputs in the local database and only strip `<private>` blocks, so the deny
rules remain the protection for secrets. Memory databases and client authentication
stay outside Git.

[Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) is pinned
to `1.8.0`. It starts headless Chrome with a temporary isolated profile; it does not
attach to your personal browser. MCP usage statistics, CrUX URL uploads and automatic
update checks are disabled. Chrome stable, Node LTS and npm are required. The initial
`npx` download can require network access. Use Playwright for interaction tests and
DevTools for performance/network diagnosis; neither shares the other's login state.

[GitHub MCP](https://github.com/github/github-mcp-server) uses the official hosted
endpoint, limited to `repos,issues,pull_requests,actions` toolsets. Hosted server
updates are controlled by GitHub rather than pinned locally. Codex and OpenCode keep
approval enabled for GitHub and Cloudflare; Pi expands `${GITHUB_MCP_TOKEN}` in its
lazy MCP config and relies on the task boundary instead of an approval prompt.

### Routine command and browser permissions

OpenCode's implementation modes and verifier inherit the global shell policy:
routine commands, including uv, npm and Python, run without a per-command prompt.
The verifier still forbids edits and must not use shell commands to implement fixes.
Existing sensitive Git/token patterns and the safety-net plugin remain in place;
command-name permissions are not a sandbox and cannot prove a script is harmless.

Plan, explore and review modes retain their limited shell allowlist and deny edits.
Their `external_directory` guard asks instead of denying, so an approved read outside
the project can proceed. `~/proj/**` remains allowed. Protected environment files
remain denied. Project configuration can override personal defaults.

Playwright and Chrome DevTools tools are pre-approved in Codex and OpenCode,
including OpenCode's read-only modes. This includes browser interactions and script
evaluation, not only screenshots; use them only for the authorized task. A read-only
role must not use the browser to mutate external services. In Pi the same servers
arrive through the lazy `mcp` tool, so they are used on demand rather than pre-loaded.

Codex uses `approval_policy = "on-request"`, `sandbox_mode = "workspace-write"`
and the existing automatic reviewer. Routine commands inside the sandbox need no
blanket interpreter allowlist; network access, writes outside the sandbox and managed
policies can still require approval. Browser MCP servers use
`default_tools_approval_mode = "approve"`. These settings follow the
[Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
and [OpenCode permissions](https://opencode.ai/docs/permissions/).
Restart clients after changing permissions; an existing session may retain old rules.

### Cloudflare authentication

The official [Cloudflare API MCP](https://developers.cloudflare.com/agents/model-context-protocol/cloudflare/servers-for-cloudflare/)
uses `https://mcp.cloudflare.com/mcp` with OAuth. Its Code Mode exposes `search` and
`execute` instead of a large per-endpoint tool catalog. Execution can modify the
account, so both clients require tool approval. Grant only the account permissions
you actually need during login; no account changes or deployments are part of setup.

```bash
codex mcp login cloudflare
opencode mcp auth cloudflare
```

Authentication is per client. Run the commands above for Codex and OpenCode, and
use Pi's `/mcp` command to inspect or authenticate its servers. Credentials stay in
each client's private credential storage, not Git; configuration alone does not
authorize the account.

### GitHub authentication

Provide a least-privilege GitHub personal access token as `GITHUB_MCP_TOKEN` in the
environment that launches each client. Prefer a fine-grained token restricted to
the repositories and permissions actually needed. Keep it in your secret manager
or private environment, never in these files or a pasted chat message. No token is
provisioned or copied from `gh` by this setup. Restart clients after setting it.

Codex reads the variable through `bearer_token_env_var`; OpenCode and Pi expand it
in the Authorization header, with OAuth disabled for this PAT configuration. Until a
valid token is provided, GitHub is configured but will not connect. Check Codex
`/mcp`, `opencode mcp list` or Pi `/mcp` after authentication. See the
[official Codex installation guide](https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-codex.md).

Other candidate, not enabled: [Sentry MCP](https://mcp.sentry.dev/) for production
errors and traces if a project uses Sentry.
Add integrations for actual project workflows; keep credentials out of adapters.

## Install, migrate, recover

Prerequisites: GNU Stow and the desired clients. For user-side CLI installation:

```bash
bash scripts/llms.sh
```

`ENABLE_CLAUDE`, `ENABLE_CODEX`, `ENABLE_OPENCODE`, `ENABLE_PI` and
`ENABLE_CAVEMEM` switch the individual installers on or off; each CLI is skipped when
already present. `scripts/arch/dev/llms.sh` does the same during the Arch bootstrap.

To preview or apply the dotfiles:

```bash
bash scripts/ai-setup.sh --dry-run
bash scripts/ai-setup.sh --apply
```

For the one-time cleanup of the previous setup:

```bash
bash scripts/ai-setup.sh --migrate
```

Migration archives the retired global Cavekit/generic skills, old Impeccable install,
Claude configuration, old OpenCode variants and stale links. `--apply` also moves any
pre-existing real Pi config (`settings.json`, `AGENTS.md`, `mcp.json`, `agents/`,
`prompts/`) aside before linking the repository copy; Pi's runtime state (`auth.json`,
sessions, `npm/`) is left untouched. Independent domain skills, credentials/history
inside the archive and installed CLI binaries are preserved. It does not uninstall
system packages. Archives live under `~/.local/state/dotfiles-ai/backup.*/`;
`moves.tsv` maps original to archived paths. Recover selectively: remove a replacement
symlink if necessary, then move the corresponding archived file/directory back. Do
not overwrite newer work.

Removed versioned files remain recoverable from Git history. Restart the clients
after applying. The old shell's background-subagent variable disappears in a fresh shell.

## Validate

```bash
python3 scripts/validate-ai.py
bash -n scripts/ai-setup.sh scripts/llms.sh scripts/arch/dev/llms.sh
opencode --pure models opencode-go
opencode --pure debug agent frontend
pi --list-models
pi list
```

The Python validator requires PyYAML. Optionally pass `--schema <downloaded-config.json>`
with jsonschema installed for full OpenCode schema validation. It checks adapter
syntax, command targets, model IDs, skill metadata, MCP parity and the Pi settings,
subagents, prompts and pinned packages without starting plugins or making model
requests. `--pure` skips external OpenCode plugins.

## Future OmniRoute migration

Keep this layout until the router becomes the source of truth. Shared skills are
client-independent, while agent/MCP schemas remain client-native adapters. The routing
table above captures the intended workloads without coupling prompts to a gateway.

Later: move provider routing and credentials to OmniRoute, verify its MCP/skills/agent
capabilities, then migrate each adapter separately. Preserve task permissions and cost
tiers; a gateway is not a substitute for client-side review boundaries.
Do not introduce a second generated configuration system before that migration.

## Sources

- [OpenAI model guidance](https://developers.openai.com/api/docs/guides/latest-model)
- [OpenCode 1.x agents](https://opencode.ai/docs/agents/)
- [OpenCode 1.x commands](https://opencode.ai/docs/commands/)
- [OpenCode schema](https://opencode.ai/config.json)
- [Pi install and docs](https://pi.dev/docs)

The OpenCode v2 documentation uses different command/permission fields; do not copy
those into this 1.x setup.
