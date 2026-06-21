-- render-markdown: inline markdown preview in the editing buffer.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    cmd = { "RenderMarkdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown inline preview" },
    },
    opts = {
      enabled = true,
      render_modes = { "n", "c", "t" },
      completions = { blink = { enabled = true } },
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        signs = { "󰫎 " },
        width = "block",
        right_pad = 1,
      },
      code = {
        sign = false,
        style = "normal",
        border = "none",
        disable_background = true,
        left_pad = 0,
        right_pad = 0,
        language_pad = 1,
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },
      quote = { icon = "▋" },
      pipe_table = {
        preset = "round",
        cell = "trimmed",
        padding = 1,
      },
      link = {
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
      },
      overrides = {
        buftype = {
          nofile = {
            padding = { highlight = "Normal" },
            sign = { enabled = false },
            pipe_table = {
              preset = "round",
              cell = "trimmed",
              padding = 1,
              style = "full",
            },
          },
        },
      },
    },
  },
}
