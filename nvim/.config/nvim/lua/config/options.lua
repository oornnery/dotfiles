-- vim.opt settings extracted from the old init.lua.
local opt = vim.opt

-- UI -------------------------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
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
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "-",
  foldsep = " ",
  foldclose = "+",
}
opt.colorcolumn = "100"
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Mouse -----------------------------------------------------------------------
opt.mouse = "a"
opt.mousemodel = "extend"

-- Editing --------------------------------------------------------------------
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.virtualedit = "block"
opt.backspace = { "indent", "eol", "start" }
opt.iskeyword:append("-")

-- Search ---------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"

-- Completion / command line --------------------------------------------------
-- blink.cmp manages completion; keep menuone+noselect, drop preview (annoying).
opt.completeopt = { "menuone", "noselect" }
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }
opt.path:append("**")
opt.wildignore:append({
  "*/.git/*",
  "*/node_modules/*",
  "*/.venv/*",
  "*/venv/*",
  "*/target/*",
  "*/dist/*",
  "*/build/*",
  "*.pyc",
  "*.o",
  "*.a",
  "*.so",
})

-- Files / persistence ---------------------------------------------------------
opt.autoread = true
opt.confirm = true
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = true

local state = vim.fn.stdpath("state")
local data = vim.fn.stdpath("data")
opt.undodir = state .. "/undo//"
opt.backupdir = state .. "/backup//"
opt.directory = data .. "/swap//"
vim.fn.mkdir(vim.o.undodir, "p")
vim.fn.mkdir(vim.o.backupdir, "p")
vim.fn.mkdir(vim.o.directory, "p")

-- Performance / behavior -----------------------------------------------------
opt.updatetime = 250
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.lazyredraw = false

-- Spelling: enabled per filetype in autocmds, not globally.
opt.spelllang = { "en_us", "pt_br" }
