-- Bootstrap lazy.nvim and load plugin specs from lua/plugins/*.lua.
-- Explicit offline/native mode is useful on rescue hosts and for diagnosis.
if vim.env.DOTFILES_NVIM_PLUGINS == "0" then
  return false
end
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.schedule(function()
      vim.notify("Continuing with native editing; install lazy.nvim when online.", vim.log.levels.WARN)
    end)
    return false
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = not vim.g.dotfiles_basic_terminal, notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip",
        "matchit",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
return true
