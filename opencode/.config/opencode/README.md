# OpenCode

The maintained setup guide is [docs/configuration/ai-agents.md](../../../docs/configuration/ai-agents.md)
in the dotfiles repository.

Select modes with Tab or leader+a. The default is build/Terra; fast uses Luna,
plan/reviewer use Sol, and deep/debugger/frontend/security-reviewer use Astra.
Frontend work uses the shared impeccable skill. Commands are shortcuts to these
modes, not separate agent implementations.

Configuration: opencode.jsonc, agents/, commands/, tui.json.
Runtime data and authentication are not distributed by Stow.
