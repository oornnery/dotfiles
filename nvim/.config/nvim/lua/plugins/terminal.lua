-- Terminal workflow and external TUI tools.

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Terminal vertical" },
      { "<leader>th", "<cmd>ToggleTerm size=14 direction=horizontal<cr>", desc = "Terminal horizontal" },
    },
    opts = {
      size = 14,
      open_mapping = [[<C-\>]],
      shade_terminals = true,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },
}
