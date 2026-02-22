
-- \~/.config/nvim/lua/plugins/mini.lua
return {
  -- mini.nvim - Módulos essenciais
  {
    "nvim-mini/mini.nvim",
    version = false, -- main branch (últimas features)
    -- version = '*', -- stable (mais conservador)
    config = function()
      -- Módulos essenciais para produtividade
      require("mini.basics").setup() -- gdelete, gwipe, gmove
      require("mini.surround").setup() -- gsaw, gsd, gsr (melhor que vim-surround)
      require("mini.comment").setup() -- gc, gcc com treesitter
      require("mini.pairs").setup() -- autopares ()

      -- Interface visual
      require("mini.indentscope").setup({ symbol = "▎" })
      require("mini.animate").setup() -- Scroll/resize suaves

      -- Statusline customizável
      require("mini.statusline").setup({
        use_icons = vim.g.icons_enabled or false,
      })
    end,
  },
}