-- ~/.config/nvim/init.lua
-- Neovim native-only setup: no plugin manager, no external plugins.
-- Goal: modern baseline using built-in editor features only.

-- Leader ---------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Disable optional host providers if you do not use them. This avoids startup
-- warnings and keeps the config self-contained.
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- netrw: built-in file explorer ---------------------------------------------
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 28
vim.g.netrw_altv = 1
vim.g.netrw_keepdir = 0

local opt = vim.opt

-- UI -------------------------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.termguicolors = true
opt.laststatus = 3
opt.showmode = false
opt.ruler = true
opt.cmdheight = 1
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.pumheight = 12
opt.winminwidth = 5
opt.list = true
opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
  extends = '›',
  precedes = '‹',
}
opt.fillchars = {
  eob = ' ',
  fold = ' ',
  foldopen = '-',
  foldsep = ' ',
  foldclose = '+',
}
opt.colorcolumn = '100'
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Editing --------------------------------------------------------------------
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.virtualedit = 'block'
opt.backspace = { 'indent', 'eol', 'start' }
opt.iskeyword:append('-')

-- Search ---------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = 'split'

-- Completion / command line --------------------------------------------------
opt.completeopt = { 'menuone', 'noselect', 'preview' }
opt.wildmenu = true
opt.wildmode = { 'longest:full', 'full' }
opt.path:append('**')
opt.wildignore:append({
  '*/.git/*',
  '*/node_modules/*',
  '*/.venv/*',
  '*/venv/*',
  '*/target/*',
  '*/dist/*',
  '*/build/*',
  '*.pyc',
  '*.o',
  '*.a',
  '*.so',
})

-- Files / persistence --------------------------------------------------------
-- 'hidden' exists in Vim and older Neovim; newer Neovim behaves as hidden by default.
pcall(function() opt.hidden = true end)
opt.autoread = true
opt.confirm = true
opt.undofile = true
opt.swapfile = true
opt.backup = true
opt.writebackup = true

local state = vim.fn.stdpath('state')
local data = vim.fn.stdpath('data')
opt.undodir = state .. '/undo//'
opt.backupdir = state .. '/backup//'
opt.directory = data .. '/swap//'
vim.fn.mkdir(vim.o.undodir, 'p')
vim.fn.mkdir(vim.o.backupdir, 'p')
vim.fn.mkdir(vim.o.directory, 'p')

-- Performance / behavior -----------------------------------------------------
opt.updatetime = 250
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.lazyredraw = false

-- Spelling: enable per filetype below, not globally.
opt.spelllang = { 'en_us', 'pt_br' }

-- Colors ---------------------------------------------------------------------
pcall(vim.cmd.colorscheme, 'habamax')

-- Active theme drop-in written by the `theme` command.
pcall(require, 'theme')
pcall(function() require('statusline').setup() end)
pcall(function() require('cheatsheet').setup() end)

-- Helpers --------------------------------------------------------------------
local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup('native_config', { clear = true })

local function trim_trailing_whitespace()
  local ft = vim.bo.filetype
  if ft == 'markdown' or ft == 'text' or ft == 'gitcommit' then
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end

local function project_root()
  local markers = { '.git', 'pyproject.toml', 'package.json', 'Cargo.toml', 'go.mod', 'Makefile' }
  local start = vim.fn.expand('%:p:h')

  if vim.fs and vim.fs.root then
    return vim.fs.root(start, markers) or vim.fn.getcwd()
  end

  local dir = start
  while dir and dir ~= '/' do
    for _, marker in ipairs(markers) do
      if vim.fn.isdirectory(dir .. '/' .. marker) == 1 or vim.fn.filereadable(dir .. '/' .. marker) == 1 then
        return dir
      end
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end
  return vim.fn.getcwd()
end

local function pesc(str)
  return (str:gsub('([^%w])', '%%%1'))
end

local comment_fallback = {
  lua = '-- %s',
  vim = '" %s',
  python = '# %s',
  sh = '# %s',
  bash = '# %s',
  zsh = '# %s',
  conf = '# %s',
  dosini = '# %s',
  yaml = '# %s',
  toml = '# %s',
  rust = '// %s',
  go = '// %s',
  javascript = '// %s',
  typescript = '// %s',
  jsonc = '// %s',
  c = '// %s',
  cpp = '// %s',
  css = '/* %s */',
  html = '<!-- %s -->',
  markdown = '<!-- %s -->',
}

local function comment_parts()
  local cs = vim.bo.commentstring
  if not cs or cs == '' or not cs:find('%%s') then
    cs = comment_fallback[vim.bo.filetype] or '# %s'
  end
  local left, right = cs:match('^(.-)%%s(.*)$')
  return left or '# ', right or ''
end

local function is_commented(line, left, right)
  if left == '' then
    return false
  end
  local body = line:gsub('^%s*', '')
  if not body:find('^' .. pesc(left)) then
    return false
  end
  if right ~= '' and not body:find(pesc(right) .. '%s*$') then
    return false
  end
  return true
end

local function toggle_comment(first, last)
  local left, right = comment_parts()
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)

  local all_commented = true
  for _, line in ipairs(lines) do
    if not line:match('^%s*$') and not is_commented(line, left, right) then
      all_commented = false
      break
    end
  end

  local new_lines = {}
  for _, line in ipairs(lines) do
    if line:match('^%s*$') then
      table.insert(new_lines, line)
    else
      local indent, body = line:match('^(%s*)(.*)$')
      if all_commented then
        body = body:gsub('^' .. pesc(left), '', 1)
        if right ~= '' then
          body = body:gsub('%s*' .. pesc(right) .. '%s*$', '', 1)
        end
        table.insert(new_lines, indent .. body)
      else
        if right ~= '' then
          table.insert(new_lines, indent .. left .. body .. right)
        else
          table.insert(new_lines, indent .. left .. body)
        end
      end
    end
  end

  vim.api.nvim_buf_set_lines(0, first - 1, last, false, new_lines)
end

-- Commands -------------------------------------------------------------------
vim.api.nvim_create_user_command('Root', function()
  vim.cmd.cd(vim.fn.fnameescape(project_root()))
  print('cwd: ' .. vim.fn.getcwd())
end, {})

vim.api.nvim_create_user_command('Search', function(opts)
  local pattern = vim.fn.escape(opts.args, [[/\]])
  vim.cmd('silent! vimgrep /' .. pattern .. '/gj **/*')
  vim.cmd('copen')
end, { nargs = 1 })

vim.api.nvim_create_user_command('TrimWhitespace', trim_trailing_whitespace, {})
vim.api.nvim_create_user_command('Term', 'botright split | resize 14 | terminal', {})
vim.api.nvim_create_user_command('MkSession', 'mksession! .session.vim', {})
vim.api.nvim_create_user_command('LoadSession', 'source .session.vim', {})

-- Keymaps --------------------------------------------------------------------
map({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })

-- Files / write / quit
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Write file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit window' })
map('n', '<leader>x', '<cmd>x<cr>', { desc = 'Write and quit' })
map('n', '<leader>e', '<cmd>Lexplore<cr>', { desc = 'Toggle netrw explorer' })
map('n', '<leader>E', '<cmd>Explore<cr>', { desc = 'Open netrw explorer' })
map('n', '<leader>ff', ':find ', { desc = 'Find file using native :find' })
map('n', '<leader>sg', ':Search ', { desc = 'Search project using native :vimgrep' })
map('n', '<leader>rr', '<cmd>Root<cr>', { desc = 'cd to project root' })

-- Buffers / quickfix
map('n', '<leader>bb', '<cmd>ls<cr>:buffer ', { desc = 'Switch buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '[q', '<cmd>cprevious<cr>', { desc = 'Previous quickfix item' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix item' })
map('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open quickfix' })
map('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close quickfix' })

-- Windows
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })
map('n', '<leader>sv', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
map('n', '<leader>sh', '<cmd>split<cr>', { desc = 'Horizontal split' })
map('n', '<leader>=', '<C-w>=', { desc = 'Equalize windows' })

-- Editing
map('n', '<Esc><Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', 'gcc', function() toggle_comment(vim.fn.line('.'), vim.fn.line('.')) end, { desc = 'Toggle comment line' })
map('x', 'gc', function() toggle_comment(vim.fn.line("'<"), vim.fn.line("'>")) end, { desc = 'Toggle comment selection' })
map('x', '<', '<gv', { desc = 'Indent left and reselect' })
map('x', '>', '>gv', { desc = 'Indent right and reselect' })
map('n', '<leader>f', 'gg=G``', { desc = 'Reindent whole file' })
map('x', '<leader>f', '=', { desc = 'Reindent selection' })
map('n', '<leader>tw', '<cmd>setlocal wrap!<cr>', { desc = 'Toggle wrap' })
map('n', '<leader>ts', '<cmd>setlocal spell!<cr>', { desc = 'Toggle spell' })

-- Terminal
map('n', '<leader>tt', '<cmd>Term<cr>', { desc = 'Open terminal split' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Terminal normal mode' })

-- Autocommands ---------------------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  callback = trim_trailing_whitespace,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 100
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'python' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'go', 'make' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})
