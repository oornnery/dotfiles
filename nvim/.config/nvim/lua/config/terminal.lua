-- SSH usually forwards TERM, not TERM_PROGRAM: keep an explicit override.
local profile = (vim.env.DOTFILES_TERMINAL or "auto"):lower()
local program = (vim.env.TERM_PROGRAM or ""):lower()
local basic = profile == "basic"
  or (profile == "auto" and (program:find("moba", 1, true) ~= nil or vim.env.TERM == "linux"))

vim.g.dotfiles_basic_terminal = basic
if basic then
  vim.opt.termguicolors = false
  vim.opt.mouse = ""
  vim.opt.guicursor = ""
  vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "+", extends = ">", precedes = "<" }
end
-- Do not force RGB support or change TERM. Let Neovim negotiate capabilities.

-- System clipboard everywhere: over SSH through the terminal (OSC 52), which
-- needs no tool on the server; locally through whatever Neovim detects.
if vim.env.SSH_TTY then
  vim.g.clipboard = "osc52"
end
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

return { basic = basic }
