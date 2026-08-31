# AI credentials

Private API keys live in `~/.config/ai/env`. The file uses normal shell
`export NAME="value"` syntax and is loaded by `~/.zshenv`, so terminal tools and
Neovim inherit the same variables.

## Setup

```sh
mkdir -p ~/.config/ai
cp ~/dotfiles/zsh/.config/ai/env.example ~/.config/ai/env
chmod 600 ~/.config/ai/env
nvim ~/.config/ai/env
exec zsh
```

Uncomment only the providers you use. Never add the real `env` file to Git.
The dotfiles repository ignores `zsh/.config/ai/env`; `env.example` contains
names only and is safe to track.

OpenCode logins already stored in `~/.local/share/opencode/auth.json` are read
directly by the Minuet configuration, so duplicating those keys here is
optional. Environment variables take priority and are useful on a fresh
machine or for overriding a login.

## Minuet variables

| Variable              | Purpose                                             |
| --------------------- | --------------------------------------------------- |
| `OPENCODE_GO_API_KEY` | OpenCode Go subscription; default DeepSeek provider |
| `OPENCODE_API_KEY`    | OpenCode Zen, including free models                 |
| `ZAI_API_KEY`         | Z.AI/GLM Coding Plan fallback                       |
| `MINUET_PROVIDER`     | Force a Minuet provider                             |
| `MINUET_MODEL`        | Force a model ID                                    |
| `MINUET_ENDPOINT`     | Force the full completion endpoint                  |

The Minuet presets are `opencode_go`, `deepseek_free`, and `glm`. Use
`<leader>aP` inside Neovim to switch among credentials available at startup.
This is a manual fallback: Minuet does not automatically retry a failed request
against a different provider.

OpenCode may temporarily mark a free model unavailable. If Go reaches its quota
or `deepseek_free` is unavailable, select `glm`; changing a preset does not
require restarting Neovim.
