-- ~/.config/nvim/init.lua
-- Entry: bootstrap lazy.nvim, load config modules, apply theme.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable unused provider hosts (avoid startup warnings).
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Disable netrw: oil.nvim replaces it.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")

-- Active theme drop-in written by the `dots theme` command.
-- Falls back to habamax if the theme module is absent.
pcall(vim.cmd.colorscheme, "habamax")
pcall(require, "theme")
pcall(function() require("statusline").setup() end)
pcall(function() require("cheatsheet").setup() end)
