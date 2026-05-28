local M = {}

local mode_names = {
  n = "NORMAL",
  no = "OP",
  nov = "OP",
  noV = "OP",
  ["no\22"] = "OP",
  niI = "NORMAL",
  niR = "NORMAL",
  niV = "NORMAL",
  nt = "NORMAL",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  R = "REPLACE",
  Rc = "REPLACE",
  Rx = "REPLACE",
  Rv = "V-REPLACE",
  Rvc = "V-REPLACE",
  Rvx = "V-REPLACE",
  c = "COMMAND",
  cv = "EX",
  ce = "EX",
  r = "PROMPT",
  rm = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  t = "TERMINAL",
}

local function text(value)
  return tostring(value or ""):gsub("%%", "%%%%")
end

local function block(group, value)
  value = text(value)
  if value == "" then
    return ""
  end
  return "%#" .. group .. "# " .. value .. " "
end

local function mode()
  local current = vim.api.nvim_get_mode().mode
  return mode_names[current] or mode_names[current:sub(1, 1)] or current:upper()
end

local function filename()
  local name = vim.fn.expand("%:~:.")
  if name == "" then
    return "[No Name]"
  end
  return name
end

local function flags()
  local items = {}
  if vim.bo.modified then
    items[#items + 1] = "[+]"
  end
  if vim.bo.readonly then
    items[#items + 1] = "[RO]"
  end
  if not vim.bo.modifiable then
    items[#items + 1] = "[-]"
  end
  if vim.bo.buftype == "help" then
    items[#items + 1] = "[H]"
  end
  return table.concat(items, " ")
end

local function filetype()
  if vim.bo.filetype == "" then
    return "noft"
  end
  return vim.bo.filetype
end

local function encoding()
  if vim.bo.fileencoding ~= "" then
    return vim.bo.fileencoding
  end
  return vim.o.encoding
end

local function position()
  return ("%d:%d"):format(vim.fn.line("."), vim.fn.col("."))
end

local function percent()
  local total = math.max(vim.fn.line("$"), 1)
  local current = vim.fn.line(".")
  return ("%d%%"):format(math.floor((current * 100) / total))
end

function M.render()
  return table.concat({
    block("DotfilesStatusMode", mode()),
    block("DotfilesStatusFile", filename()),
    block("DotfilesStatusMuted", flags()),
    "%#DotfilesStatusMiddle#%=",
    block("DotfilesStatusInfo", filetype()),
    block("DotfilesStatusFile", encoding()),
    block("DotfilesStatusMode", position()),
    block("DotfilesStatusAccent", percent()),
  })
end

function M.setup()
  vim.o.laststatus = 3
  vim.o.showmode = false
  vim.o.statusline = "%!v:lua.require'statusline'.render()"
end

return M
