-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Active theme drop-in written by the `theme` command.
local ok, theme = pcall(require, "theme")
if ok and type(theme.apply) == "function" then
  theme.apply()
end
