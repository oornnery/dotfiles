-- ~/.config/nvim/init.lua
-- Native Neovim base plus lazy.nvim plugin extras.

local function dotfiles_dir()
  if vim.env.DOTFILES_DIR and vim.env.DOTFILES_DIR ~= "" then
    return vim.env.DOTFILES_DIR
  end

  local source = debug.getinfo(1, "S").source:gsub("^@", "")
  local real = vim.uv and vim.uv.fs_realpath(source) or vim.loop.fs_realpath(source)
  local match = real and real:match("^(.*)/nvim%.lazy/%.config/nvim/init%.lua$")
  return match or ((vim.env.HOME or "~") .. "/dotfiles")
end

local root = dotfiles_dir()
local config_dir = root .. "/nvim.lazy/.config/nvim"
vim.opt.runtimepath:prepend(config_dir)

local native_init = root .. "/nvim/.config/nvim/init.lua"
if vim.fn.filereadable(native_init) == 1 then
  dofile(native_init)
else
  vim.notify("native nvim base not found: " .. native_init, vim.log.levels.WARN)
end

require("config.lazy")
