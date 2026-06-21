-- Base keymaps. Plugin-specific mappings live in their specs (fzf, oil, gitsigns, lsp).
local map = vim.keymap.set

-- Reset <Space> (leader) in normal/visual.
map({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Files / write / quit
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>x", "<cmd>x<cr>", { desc = "Write and quit" })

-- Buffers / quickfix
map("n", "<leader>bb", "<cmd>ls<cr>:buffer ", { desc = "Switch buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })

-- Editing
map("n", "<Esc><Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })
map("n", "<leader>tw", "<cmd>setlocal wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>ts", "<cmd>setlocal spell!<cr>", { desc = "Toggle spell" })

-- Terminal (toggleterm owns <leader>tt/<leader>tv/<leader>th).
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })

-- Project root
map("n", "<leader>rr", "<cmd>Root<cr>", { desc = "cd to project root" })
