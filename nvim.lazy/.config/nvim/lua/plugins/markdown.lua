-- ~/.config/nvim/lua/plugins/markdown.lua
-- render-markdown.nvim: pretty inline rendering of headings, tables, code blocks,
-- lists, checkboxes, etc. — directly in the buffer while editing.
--
-- Pairs well with the user's heavy MD usage (docs/cheatsheets, obsidian-note).

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "Avante" },
    opts = {
      -- Anti-conceal: show raw markup on the line where the cursor is.
      -- Trade-off: minor "flicker" while moving cursor through MD.
      anti_conceal = { enabled = true },
      heading = {
        sign = true,
        position = "overlay",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = true,
        style = "language",
        position = "left",
        width = "block",
        right_pad = 2,
      },
      bullet = { icons = { "●", "○", "◆", "◇" } },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      table = { style = "full", cell = "padded" },
      link = { hyperlink = "󰌹 " },
    },
  },
}
