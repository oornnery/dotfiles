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
      local parsers = {
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
        "c_sharp",
        "java",
        "kotlin",
        "php",
        "ruby",
        "scss",
        "vue",
        "svelte",
        "sql",
        "graphql",
        "dockerfile",
        "make",
        "cmake",
        "terraform",
        "hcl",
        "nix",
        "zig",
        "elixir",
        "diff",
        "gitcommit",
        "gitignore",
        "git_config",
        "ini",
        "xml",
        "kdl",
      }
      -- Needs the tree-sitter CLI. On a new machine Mason installs it first
      -- (plugins/tools.lua), so try again when Mason finishes.
      local function install_parsers()
        if vim.fn.executable("tree-sitter") == 1 then
          require("nvim-treesitter").install(parsers)
        end
      end
      install_parsers()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        once = true,
        callback = install_parsers,
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
      -- Installing is in plugins/tools.lua. vim.lsp.enable() below is the source
      -- of truth; otherwise any server left in Mason attaches as well.
      automatic_enable = false,
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
      "b0o/SchemaStore.nvim",
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
      -- Every server gets the completion capabilities.
      vim.lsp.config("*", { capabilities = capabilities })

      local schemas = function(kind)
        local ok, store = pcall(require, "schemastore")
        return ok and store[kind].schemas() or nil
      end
      vim.lsp.config("jsonls", {
        settings = { json = { schemas = schemas("json"), validate = { enable = true } } },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = { schemaStore = { enable = false, url = "" }, schemas = schemas("yaml") },
        },
      })
      -- ty (Astral) owns Python types, hover, goto and completion; it finds
      -- the project's .venv on its own. Ruff below owns lint + format.
      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            fixAll = true,
            organizeImports = true,
          },
        },
      })

      -- Enable what is on this machine: from Mason or from the system.
      vim.lsp.enable(require("config.servers").available())

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
        python = { "ruff_organize_imports", "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        toml = { "taplo" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        terraform = { "terraform_fmt" },
        zig = { "zigfmt" },
        ["*"] = { "trim_whitespace" },
        ["_"] = { "trim_whitespace" },
      },
      -- Shell keeps its hand alignment: format it with <leader>cf.
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "sh" or ft == "bash" or ft == "zsh" then
          return nil
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      notify_on_error = true,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
