-- opencode.nvim: pair with OpenCode from inside nvim — ask, prompts and
-- commands via the OpenCode server API. Needs the `opencode` CLI on PATH.
-- No config is required: on first use it connects to a running server
-- (`opencode --port`) or starts one in a vertical split terminal.
return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      {
        "<leader>aa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = { "n", "x" },
        desc = "Ask OpenCode about this",
      },
      {
        "<leader>ap",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "Select OpenCode prompt/command",
      },
    },
    config = function()
      -- Defaults are good: @this/@buffer/@diagnostics contexts, built-in
      -- prompts, and diffpatch review for edits. Set vim.g.opencode_opts
      -- here to override (see :h opencode-config).
      vim.g.opencode_opts = vim.g.opencode_opts or {}
    end,
  },
}
