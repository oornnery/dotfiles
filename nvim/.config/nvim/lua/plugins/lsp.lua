-- LSP, formatter, treesitter.
return {
  -- nvim-treesitter (branch main, new API). Requires nvim 0.12+.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        "markdown",
        "markdown_inline",
        "bash",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "html",
        "css",
        "rust",
        "go",
        "c",
        "cpp",
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
  },

  -- Mason: install LSP servers / formatters / linters.
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- mason-lspconfig: bridge to vim.lsp.enable (nvim 0.11+ API).
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "mason.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "pyright",
        "ruff",
        "bashls",
        "marksman",
      },
      automatic_installation = true,
    },
  },

  -- nvim-lspconfig: use new vim.lsp.config / vim.lsp.enable API (0.11+).
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
    },
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        },
      })
      vim.lsp.config("rust_analyzer", { capabilities = capabilities })
      vim.lsp.config("ts_ls", { capabilities = capabilities })
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      vim.lsp.config("ruff", {
        capabilities = capabilities,
        init_options = {
          settings = {
            fixAll = true,
            organizeImports = true,
          },
        },
      })
      vim.lsp.config("bashls", { capabilities = capabilities })
      vim.lsp.config("marksman", { capabilities = capabilities })

      vim.lsp.enable({
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "pyright",
        "ruff",
        "bashls",
        "marksman",
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(event)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.documentFormattingProvider = false
          end

          map("n", "gd", vim.lsp.buf.definition, "goto definition")
          map("n", "gr", vim.lsp.buf.references, "references")
          map("n", "gI", vim.lsp.buf.implementation, "goto implementation")
          map("n", "gy", vim.lsp.buf.type_definition, "goto type def")
          map("n", "K", vim.lsp.buf.hover, "hover doc")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "code action")
          map("n", "<leader>crn", vim.lsp.buf.rename, "rename")
          map("n", "<leader>cf", function()
            local ok, conform = pcall(require, "conform")
            if ok then
              conform.format({ async = true, lsp_format = "fallback" })
              return
            end
            vim.lsp.buf.format({ async = true })
          end, "format")
          map("n", "[d", vim.diagnostic.goto_prev, "prev diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "next diagnostic")
          map("n", "<leader>qf", vim.diagnostic.setloclist, "quickfix (diagnostics)")
        end,
      })
    end,
  },

  -- conform.nvim: formatter on save.
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "n",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt", lsp_format = "fallback" },
        go = { "goimports", "gofmt" },
        python = { "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        ["*"] = { "trim_whitespace" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      notify_on_error = true,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
