-- Autocommands extracted from the old init.lua. Code-dead bits removed
-- (project_root manual fallback, custom comment toggle, pcall hidden).
local augroup = vim.api.nvim_create_augroup("native_config", { clear = true })

local function trim_trailing_whitespace()
  local ft = vim.bo.filetype
  if ft == "markdown" or ft == "text" or ft == "gitcommit" then
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    -- vim.highlight deprecated in 0.11+, use vim.hl.
    local hl = vim.hl or vim.highlight
    if hl and hl.on_yank then
      hl.on_yank({ timeout = 150 })
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = trim_trailing_whitespace,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 100
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "go", "make" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- User commands --------------------------------------------------------------
local function project_root()
  local markers = {
    ".git",
    "pyproject.toml",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "Makefile",
  }
  local start = vim.fn.expand("%:p:h")
  if vim.fs and vim.fs.root then
    return vim.fs.root(start, markers) or vim.fn.getcwd()
  end
  return vim.fn.getcwd()
end

vim.api.nvim_create_user_command("Root", function()
  vim.cmd.cd(vim.fn.fnameescape(project_root()))
  print("cwd: " .. vim.fn.getcwd())
end, {})

vim.api.nvim_create_user_command("TrimWhitespace", trim_trailing_whitespace, {})
vim.api.nvim_create_user_command("Term", "botright split | resize 14 | terminal", {})
vim.api.nvim_create_user_command("MkSession", "mksession! .session.vim", {})
vim.api.nvim_create_user_command("LoadSession", "source .session.vim", {})