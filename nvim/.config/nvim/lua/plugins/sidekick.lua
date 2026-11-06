-- sidekick.nvim: run the official Claude Code and Codex CLIs in a split and
-- send editor context ({this}, {file}, diagnostics) into them. Both CLIs log
-- in with their own subscription, so no API key lives here. NES is off: it
-- needs the Copilot language server.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
    },
    keys = {
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        mode = { "n", "t", "i", "x" },
        desc = "AI CLI focus",
      },
      {
        "<leader>ac",
        function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
        desc = "Claude Code toggle",
      },
      {
        "<leader>ax",
        function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
        desc = "Codex toggle",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "n", "x" },
        desc = "AI CLI send this",
      },
      {
        "<leader>aF",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "AI CLI send file",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "AI CLI detach",
      },
    },
  },
}
