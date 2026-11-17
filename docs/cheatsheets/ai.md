# AI tools

The old Claude, Codex, OpenCode and Pi setup is in `ai/`, mapped in
`ai/README.md`. Nothing there is linked yet.

| Task | Command |
| ---- | ------- |
| Claude Code | `claude` |
| Codex | `codex` |
| OpenCode | `opencode` |
| Link one setup after reviewing it | `stow --no-folding -d ~/dotfiles/ai -t ~ claude` |

API keys go in `~/.config/ai/env` (see `ai/env.example`). It is sourced by
`env.sh` and never tracked.

## lsp-ai: models in Helix and Neovim

`dots install lsp-ai` installs the server; both editors already have its config
(`home/helix/.config/helix/languages.toml`, `lua/plugins/lsp.lua` in nvim). It goes
through OpenRouter: one key, `OPENROUTER_API_KEY` in `~/.config/ai/env`, billed per token.
A Claude or ChatGPT subscription does not work here (Neovim's codex-complete does use
the ChatGPT one).

OpenRouter has no FIM endpoint, so completion is a small chat model asked for the text
at `<CURSOR>`. Chat: type `!C` and the question, then the code action.

Prices per million tokens, input / output, from the OpenRouter model list (2026-11):

| Model (slug) | Price | Use |
| ------------ | ----- | --- |
| `deepseek/deepseek-v4-flash` | 0.09 / 0.18 | Completion: cheapest, fast |
| `anthropic/claude-haiku-5.5` | 0.10 / 0.50 | Chat and actions: best quality of the cheap ones |
| `openai/gpt-6-luna` | 0.10 / 0.50 | The same price as Haiku; try it for completion |
| `qwen/qwen3-coder-next` | 0.12 / 0.80 | Code-tuned alternative |
| `mistralai/codestral-2508` | 0.30 / 0.90 | Made for FIM, but FIM needs Mistral's own API (`mistral_fim`) |
| `z-ai/glm-4.7-flash` | 0.06 / 0.40 | Cheap; no sign it is better than the above |

To switch, change `model` in `[language-server.lsp-ai.config.models.*]` (Helix) or
`models` (nvim). Browse slugs at openrouter.ai/models.

Config keys (`config` in Helix, `init_options` in Neovim):

- `memory`: only `file_store`.
- `models`: named models. `type = "open_ai"` with `chat_endpoint`, `model`,
  `auth_token_env_var_name`; also `anthropic`, `mistral_fim`, `ollama`, `llama_cpp`.
- `completion`: `model` and `parameters`: `messages` (`{CODE}`), or `fim`, or none for
  plain text completion; `max_context`, `max_tokens`. Omit the key to turn it off.
- `chat`: code actions with a `trigger`, `model` and `parameters`.
- `actions`: custom code actions; `{SELECTED_TEXT}` in `messages`, and
  `post_process.extractor` (a regex) to keep only the answer.
- `post_process`: `remove_duplicate_start` and `remove_duplicate_end`.

API backends send your code to the provider.
