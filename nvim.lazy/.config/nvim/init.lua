-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

pcall(function()
  require("statusline").setup()
end)

pcall(function()
  require("cheatsheet").setup()
end)
