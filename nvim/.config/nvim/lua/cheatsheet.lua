local M = {}

local function config_root()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then
    return vim.fn.fnamemodify(source:sub(2), ":p:h:h")
  end
  return vim.fn.stdpath("config")
end

local function cheatsheet_path()
  return config_root() .. "/docs/cheatsheet.md"
end

local function open_buffer(lines)
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()

  -- Make the cheatsheet read like a doc page, not an editable buffer.
  vim.wo.colorcolumn = ""
  vim.wo.cursorline = false
  vim.wo.foldcolumn = "0"
  vim.wo.list = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.spell = false
  vim.wo.wrap = true

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"

  -- FileType autocmds may reset window-local markdown defaults.
  vim.wo.colorcolumn = ""
  vim.wo.cursorline = false
  vim.wo.list = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.spell = false

  pcall(vim.api.nvim_buf_set_name, buf, "nvim-cheatsheet.md")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close cheatsheet" })
end

function M.open()
  open_buffer(vim.fn.readfile(cheatsheet_path()))
end

function M.setup()
  vim.api.nvim_create_user_command("Helpme", M.open, {})
  vim.api.nvim_create_user_command("Cheatsheet", M.open, {})

  vim.keymap.set("n", "<leader>?", function()
    M.open()
  end, { desc = "Open keybinding cheatsheet" })
end

return M
