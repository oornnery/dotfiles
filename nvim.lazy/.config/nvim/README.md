# Neovim + lazy.nvim

This distro sources the native config from `../../../../nvim/.config/nvim`
first, then adds plugin extras with lazy.nvim.

The base behavior stays shared with native Neovim:

- options and keymaps
- theme loader
- statusline
- cheatsheet commands

Run `:Lazy sync` after switching to this distro. lazy.nvim will create a fresh
`lazy-lock.json` for the active plugin set.
