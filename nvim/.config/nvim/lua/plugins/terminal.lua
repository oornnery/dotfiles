-- Terminal workflow and external TUI tools.
local opencode_terms = {}

local function opencode_terminal(direction)
  return function()
    if vim.fn.executable("opencode") ~= 1 then
      vim.notify("opencode not found in PATH", vim.log.levels.WARN)
      return
    end

    local Terminal = require("toggleterm.terminal").Terminal
    opencode_terms[direction] = opencode_terms[direction] or Terminal:new({
      cmd = "opencode",
      direction = direction,
      hidden = true,
      close_on_exit = false,
      float_opts = { border = "rounded" },
    })
    opencode_terms[direction]:toggle()
  end
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Terminal vertical" },
      { "<leader>th", "<cmd>ToggleTerm size=14 direction=horizontal<cr>", desc = "Terminal horizontal" },
      { "<leader>ao", opencode_terminal("float"), desc = "OpenCode float" },
      { "<leader>aO", opencode_terminal("vertical"), desc = "OpenCode vertical" },
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
