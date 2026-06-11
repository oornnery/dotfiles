return {
  -- TOKYO NIGHT THEME
  {
    "folke/tokyonight.nvim",
    lazy = false, -- carrega ao iniciar!
    priority = 1000,
    opts = {},
  },

  -- Aplica Tokyo Night como colorscheme padrão
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- -- LUALINE: statusline moderna, integra diagnostics, branch, venv etc
}
