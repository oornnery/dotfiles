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

  -- LUALINE: statusline moderna, integra diagnostics, branch, venv etc
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = require("lazyvim.config").icons
      return {
        options = {
          theme = "tokyonight",
          globalstatus = true,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter" }
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            require("lazyvim.lualine").root_dir(),
            { "diagnostics", symbols = {
              error = icons.diagnostics.Error,
              warn  = icons.diagnostics.Warn,
              info  = icons.diagnostics.Info,
              hint  = icons.diagnostics.Hint,
            }},
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            require("lazyvim.lualine").pretty_path(),
          },
          lualine_x = {
            -- Mostra se você estiver com ambiente virtual Python ativo
            function()
              local venv = os.getenv("VIRTUAL_ENV") or ""
              if #venv > 0 then
                return " " .. vim.fn.fnamemodify(venv, ":t")
              end
              return ""
            end,
            -- Suporte a atualizações lazy etc
            require("lazy.status").updates,
            { "diff", symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return " " .. os.date("%R") end,
          },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }
    end
  },
}
