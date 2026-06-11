require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  -- "pyright", -- Static Type Checker for Python
  "ruff_lsp", -- An extremely fast Python type checker and language server, written in Rust.
  "ruff",
  "ty",       -- An extremely fast Python type checker and language server, written in Rust.
  "tombi",    -- Language server for Tombi, a TOML toolkit.
  "lua_ls",
  "sqruff",   -- sqruff is a SQL linter and formatter written in Rust.
  "ts_ls",    -- TypeScript Language Server
  "ttags",    -- ttags generates ctags using Tree-sitter.
}

vim.lsp.enable(servers)
-- vim.lsp.enable(vim.tbl_keys(servers))

-- read :h vim.lsp.config for changing options of lsp servers

-- Restore cursor position

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
        line > 1
        and line <= vim.fn.line "$"
        and vim.bo.filetype ~= "commit"
        and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})


-- Clipboard in WSL without xclip

vim.g.clipboard = {
  name = 'WslClipboard',
  copy = {
    ['+'] = 'clip.exe',
    ['*'] = 'clip.exe',
  },
  paste = {
    ['+'] = 'pwsh.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ['*'] = 'pwsh.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}


-- Show Nvdash when all buffers are closed

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})
