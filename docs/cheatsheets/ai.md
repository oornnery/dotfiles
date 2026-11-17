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
(`home/helix/.config/helix/languages.toml`, `lua/plugins/lsp.lua` in nvim). Put
`MISTRAL_API_KEY` and `ANTHROPIC_API_KEY` in `~/.config/ai/env`.

A Claude or ChatGPT subscription does **not** work here: lsp-ai calls the APIs and
needs a key billed per token. (Neovim also has codex-complete, which uses the ChatGPT
subscription; see its README.)

| Backend (`type`) | Fields | Use it for |
| ---------------- | ------ | ---------- |
| `mistral_fim` | `fim_endpoint`, `model` (`codestral-latest`) | Completion: fast, FIM-native, no `fim` block |
| `open_ai` | `chat_endpoint` or `completions_endpoint`, `model` | Any OpenAI-compatible host: OpenAI, Groq, OpenRouter, Fireworks (`starcoder` FIM) |
| `anthropic` | `chat_endpoint`, `model` | Chat and actions; too slow for as-you-type completion |
| `ollama`, `llama_cpp` | `model`; `repository` + `name` or `file_path` | Local only: slow on this machine |

All take `auth_token_env_var_name` (or `auth_token`) and `max_requests_per_second`.

Keys of the config (`config` in Helix, `init_options` in Neovim):

- `memory`: only `file_store`.
- `models`: named models, referenced by name below.
- `completion`: `model` and `parameters`. With `messages` it is an instruction prompt
  (`{CODE}`, `{CONTEXT}`); with `fim` (`start`, `middle`, `end`) a FIM prompt; with
  neither, plain text completion. Omit the key to turn completion off.
- `chat`: code actions with a `trigger` (like `!C`), `model`, and `parameters`
  (`max_context`, `max_tokens`, `system`).
- `actions`: custom code actions; `{SELECTED_TEXT}` and `{CODE}` in `messages`, and
  `post_process.extractor` (a regex) to keep only the answer.
- `post_process`: `remove_duplicate_start` and `remove_duplicate_end`.

Parameters per backend: Anthropic `system`, `max_tokens`, `temperature`, `top_p`;
OpenAI also `presence_penalty`, `frequency_penalty`; Mistral `min_tokens`, `stop`.
API backends send your code to the provider.
