-- lua/plugins/js.lua
return {
  -- LSPs principais para web
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Desativar tsserver/ts_ls para evitar duplicidade; usar vtsls
      opts.servers.tsserver = { enabled = false }
      opts.servers.ts_ls = { enabled = false }

      -- TypeScript/JavaScript via vtsls (recomendado)
      opts.servers.vtsls = {
        -- filetypes explícitos para incluir React
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = { enableServerSideFuzzyMatch = true },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
          },
        },
      }

      -- Vue 3 (Volar)
      opts.servers.volar = {
        filetypes = { "vue" },
      }

      -- HTML/CSS/JSON/YAML
      opts.servers.html = {}
      opts.servers.cssls = {}
      opts.servers.jsonls = {}
      opts.servers.yamlls = {}

      -- TailwindCSS
      opts.servers.tailwindcss = {}

      -- Emmet (olrtg/emmet-language-server)
      opts.servers.emmet_language_server = {
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "pug",
          "typescriptreact",
        },
        init_options = {
          includeLanguages = {},
          excludeLanguages = {},
          extensionsPath = {},
          preferences = {},
          showAbbreviationSuggestions = true,
          showExpandedAbbreviation = "always",
          showSuggestionsAsSnippets = false,
          syntaxProfiles = {},
          variables = {},
        },
      }

      -- ESLint LSP (diagnósticos e code actions)
      opts.servers.eslint = {}
    end,
  },

  -- Formatters (Conform)
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Preferir Biome; fallback para Prettier/Prettierd
      local js_fmt = { "biome", "prettierd", "prettier" }
      opts.formatters_by_ft.javascript = js_fmt
      opts.formatters_by_ft.javascriptreact = js_fmt
      opts.formatters_by_ft.typescript = js_fmt
      opts.formatters_by_ft.typescriptreact = js_fmt
      opts.formatters_by_ft.vue = js_fmt
      opts.formatters_by_ft.json = { "biome", "prettierd", "prettier" }
      opts.formatters_by_ft.yaml = { "prettierd", "prettier" }
      opts.formatters_by_ft.html = { "prettierd", "prettier" }
      opts.formatters_by_ft.css = { "prettierd", "prettier" }
      opts.formatters_by_ft.scss = { "prettierd", "prettier" }
    end,
  },

  -- Linters (nvim-lint) - evitar duplicidade com eslint-lsp
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.javascript = { "eslint_d" }
      opts.linters_by_ft.javascriptreact = { "eslint_d" }
      opts.linters_by_ft.typescript = { "eslint_d" }
      opts.linters_by_ft.typescriptreact = { "eslint_d" }
      opts.linters_by_ft.vue = { "eslint_d" }
      opts.linters_by_ft.css = { "stylelint" }
      opts.linters_by_ft.scss = { "stylelint" }
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
        "css",
        "scss",
        "html",
        "json",
        "yaml",
        "vue",
      })
    end,
  },

  -- Autotag (JSX/TSX/Vue/HTML)
  { "windwp/nvim-ts-autotag", opts = {} },

  -- DAP para Node/JS/TS com js-debug
  {
    "mfussenegger/nvim-dap",
    dependencies = { "mxsdev/nvim-dap-vscode-js" },
    config = function()
      local dap = require("dap")
      require("dap-vscode-js").setup({
        -- Usa debugger do Mason
        debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge" },
      })
      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = dap.configurations[lang] or {}
        table.insert(dap.configurations[lang], {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "node",
          sourceMaps = true,
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        })
      end
    end,
  },

  -- Testes: Jest e Vitest via neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/nvim-nio",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-jest"] = {
        jestCommand = "npx jest",
        env = { CI = true },
      }
      opts.adapters["neotest-vitest"] = {}
    end,
  },

  -- Mason: garantir ferramentas
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- LSPs
        "vtsls",
        "eslint-lsp",
        "tailwindcss-language-server",
        "html-lsp",
        "css-lsp",
        "emmet-language-server",
        "vue-language-server",
        "json-lsp",
        "yaml-language-server",
        -- Formatters/Linters
        "biome",
        "prettierd",
        "eslint_d",
        "stylelint-lsp",
        -- Debugger
        "js-debug-adapter",
      })
    end,
  },
}
