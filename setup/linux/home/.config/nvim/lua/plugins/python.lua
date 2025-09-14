return {
  -- LSP: Ruff e Ty como LSPs Python
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.ruff = {}
      opts.servers.ty = {}
    end,
  },

  -- Linting: ruff como linter principal
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = { "ruff" }
    end,
  },

  -- Formatting: ruff também faz formatação e organização de imports
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_format", "ruff_organize_imports" }
    end,
  },

  -- Treesitter para Python (garante python/toml)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "python", "toml" })
    end,
  },

  -- Estrutura de código (outline)
  {
    "stevearc/aerial.nvim",
    opts = {},
    keys = {
      { "<leader>cs", "<cmd>AerialToggle!<cr>", desc = "Aerial (Symbols)" },
    },
  },

  -- Debug: DAP para Python
  {
    "mfussenegger/nvim-dap",
    dependencies = { "mfussenegger/nvim-dap-python" },
    config = function()
      require("dap-python").setup("python3")
    end,
  },

  -- Testes Python com neotest e suporte nvim-nio (obrigatório!)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-python"] = {
        dap = { justMyCode = false },
        args = { "--log-level", "DEBUG" },
        runner = "pytest",
      }
    end,
  },

  -- Seleção de VirtualEnv Python
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {},
    keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" } },
  },

  -- REPL Python integrado (opcional)
  {
    "Vigemus/iron.nvim",
    ft = "python",
    config = function()
      local iron = require("iron.core")
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = { python = { command = { "python3" } } },
          repl_open_cmd = require("iron.view").right("40%"),
        }
      })
    end,
    keys = { { "<leader>i", "<cmd>IronRepl<CR>", desc = "Abrir REPL Python" }, },
  },

  -- Gerador automático de docstrings (opcional)
  {
    "danymat/neogen",
    ft = "python",
    opts = { snippet_engine = "luasnip" },
    keys = {
      { "<leader>nf", function() require("neogen").generate({ type = "func" }) end, desc = "Gerar docstring função" },
      { "<leader>nc", function() require("neogen").generate({ type = "class" }) end, desc = "Gerar docstring classe" },
    },
  },

  -- EXACTOS ESSENCIAIS abaixos --

  -- Diagnostic UI para LSP/lint/testes
  { "folke/trouble.nvim", opts = { use_diagnostic_signs = true } },

  -- Auto-complete inteligente em tudo (com snippets/emoji, etc)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- integração autocompletar com LSP (Ruff, Ty, etc)
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji", -- auto complete emojis (opcional/fun)
      "saadparwaiz1/cmp_luasnip", -- integration with luasnip for snippets
    }
  },

  -- Finder ultra poderoso para tudo
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Grep (Live)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fs", "<cmd>Telescope symbols<cr>",    desc = "Symbols" },
    },
  },

  -- Barra de status moderna
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- Exemplo: adicionando emoji, branch, venv info, etc na barra
      table.insert(opts.sections.lualine_x, {
        function()
          local venv = os.getenv("VIRTUAL_ENV") or ""
          if #venv > 0 then
            return " " .. vim.fn.fnamemodify(venv, ":t")
          end
          return ""
        end,
      })
    end,
  },

  -- Mason: instala LSP/linters/tooling automaticamente
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruff",
        "ty",
        "debugpy",
        -- "pytest",
      })
    end,
  },
}
