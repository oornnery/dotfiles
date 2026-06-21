-- blink.cmp: completion engine (Rust-backed fuzzy). Requires nvim 0.12+.
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "saghen/blink.lib",
      "rafamadriz/friendly-snippets",
      "milanglacier/minuet-ai.nvim",
    },
    -- Build fuzzy matcher (Rust). Pre-built binary on tagged releases.
    -- `build()` is only needed when building from source / main branch.
    build = "cargo build --release",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = function()
      return {
        keymap = {
          preset = "super-tab",
          ["<A-y>"] = require("minuet").make_blink_map(),
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "minuet" },
          providers = {
            minuet = {
              name = "minuet",
              module = "minuet.blink",
              async = true,
              timeout_ms = 3000,
              score_offset = 50,
            },
          },
        },
        completion = {
          trigger = { prefetch_on_insert = false },
          documentation = { auto_show = true, auto_show_delay_ms = 300 },
          menu = { auto_show = true },
          ghost_text = { enabled = true },
          accept = { auto_brackets = { enabled = true } },
        },
        signature = { enabled = true },
        fuzzy = { implementation = "rust" },
        appearance = { nerd_font_variant = "mono" },
      }
    end,
  },
}
