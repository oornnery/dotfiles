-- Linters, the non-LSP tools from Mason, git diffs, and JSON/YAML schemas.
return {
  -- nvim-lint: only for what language servers do not cover. A linter that is
  -- not installed here is skipped.
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        make = { "checkmake" },
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("dotfiles_lint", { clear = true }),
        callback = function()
          local names = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            local cmd = type(linter) == "table" and linter.cmd or name
            return type(cmd) == "string" and vim.fn.executable(cmd) == 1
          end, lint.linters_by_ft[vim.bo.filetype] or {})
          if #names > 0 then
            lint.try_lint(names)
          end
        end,
      })
    end,
  },

  -- Language servers, formatters, linters and tree-sitter from Mason, gated by what they need to run.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    event = "VeryLazy",
    config = function()
      local has = function(cmd)
        return vim.fn.executable(cmd) == 1
      end
      -- Language servers and tools, all in one place.
      local tools = require("config.servers").installable()
      vim.list_extend(tools, { "tree-sitter-cli", "stylua", "shfmt", "shellcheck", "hadolint" })
      if has("node") then
        vim.list_extend(tools, { "prettierd", "markdownlint" })
      end
      if has("python3") then
        table.insert(tools, "yamllint")
      end
      if has("go") then
        vim.list_extend(tools, { "goimports", "checkmake" })
      end
      if has("gcc") or has("clang") then
        table.insert(tools, "clang-format")
      end
      require("mason-tool-installer").setup({ ensure_installed = tools, run_on_start = true })
      require("mason-tool-installer").check_install(false, false)
    end,
  },

  -- Side-by-side git diffs and file history.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff" },
    },
  },

  -- Schemas for JSON and YAML; read by the language servers in lsp.lua.
  { "b0o/SchemaStore.nvim", lazy = true },
}
