-- Project sessions.
return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>ps",
        function()
          require("persistence").load()
        end,
        desc = "Restore session",
      },
      {
        "<leader>pS",
        function()
          require("persistence").select()
        end,
        desc = "Select session",
      },
      {
        "<leader>pl",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>pd",
        function()
          require("persistence").stop()
        end,
        desc = "Do not save session",
      },
    },
    opts = {},
  },
}
