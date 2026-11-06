-- Diagnostics and TODO navigation.
return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>dD", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>ds", "<cmd>Trouble symbols toggle<cr>", desc = "Document symbols" },
      { "<leader>dl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs/defs" },
      { "<leader>dq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
      { "<leader>dc", "<cmd>Trouble close<cr>", desc = "Close Trouble" },
    },
    opts = {
      focus = true,
      auto_close = false,
      use_diagnostic_signs = true,
    },
  },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous TODO",
      },
      { "<leader>dt", "<cmd>TodoTrouble<cr>", desc = "TODOs (Trouble)" },
      { "<leader>dT", "<cmd>TodoQuickFix<cr>", desc = "TODOs (quickfix)" },
    },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },
}
