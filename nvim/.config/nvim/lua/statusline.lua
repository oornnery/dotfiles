local M = {}

local fallback_colors = {
  bg = "#1e1e2e",
  fg = "#cdd6f4",
  surface = "#313244",
  surface2 = "#45475a",
  muted = "#6c7086",
  accent = "#f5c2e7",
  accent2 = "#94e2d5",
  yellow = "#f9e2af",
  red = "#f38ba8",
  blue = "#89b4fa",
  green = "#a6e3a1",
  cyan = "#94e2d5",
  magenta = "#f5c2e7",
  orange = "#fab387",
}

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

local mode_groups = {
  n = "DotfilesStatusNormal",
  no = "DotfilesStatusNormal",
  nov = "DotfilesStatusNormal",
  noV = "DotfilesStatusNormal",
  ["no\22"] = "DotfilesStatusNormal",
  niI = "DotfilesStatusNormal",
  niR = "DotfilesStatusNormal",
  niV = "DotfilesStatusNormal",
  nt = "DotfilesStatusNormal",
  v = "DotfilesStatusVisual",
  V = "DotfilesStatusVisual",
  ["\22"] = "DotfilesStatusVisual",
  s = "DotfilesStatusVisual",
  S = "DotfilesStatusVisual",
  ["\19"] = "DotfilesStatusVisual",
  i = "DotfilesStatusInsert",
  ic = "DotfilesStatusInsert",
  ix = "DotfilesStatusInsert",
  R = "DotfilesStatusReplace",
  Rc = "DotfilesStatusReplace",
  Rx = "DotfilesStatusReplace",
  Rv = "DotfilesStatusReplace",
  Rvc = "DotfilesStatusReplace",
  Rvx = "DotfilesStatusReplace",
  c = "DotfilesStatusCommand",
  cv = "DotfilesStatusCommand",
  ce = "DotfilesStatusCommand",
  r = "DotfilesStatusCommand",
  rm = "DotfilesStatusCommand",
  ["r?"] = "DotfilesStatusCommand",
  ["!"] = "DotfilesStatusTerminal",
  t = "DotfilesStatusTerminal",
}

local file_icons = {
  bash = "",
  c = "",
  conf = "",
  cpp = "",
  css = "",
  gitcommit = "",
  go = "",
  html = "",
  javascript = "",
  json = "",
  jsonc = "",
  lua = "",
  make = "",
  markdown = "󰍔",
  python = "",
  rust = "",
  sh = "",
  toml = "",
  typescript = "",
  vim = "",
  yaml = "",
  zsh = "",
}

local function colors()
  local ok, theme = pcall(require, "theme")
  if ok and theme.colors then
    return vim.tbl_extend("force", fallback_colors, theme.colors)
  end
  return fallback_colors
end

local function hl(group, opts)
  pcall(vim.api.nvim_set_hl, 0, group, opts)
end

function M.setup_highlights()
  local c = colors()
  local mode_fg = c.bg

  hl("DotfilesStatusNormal", { fg = mode_fg, bg = c.blue, bold = true })
  hl("DotfilesStatusInsert", { fg = mode_fg, bg = c.green, bold = true })
  hl("DotfilesStatusVisual", { fg = mode_fg, bg = c.magenta, bold = true })
  hl("DotfilesStatusReplace", { fg = mode_fg, bg = c.red, bold = true })
  hl("DotfilesStatusCommand", { fg = mode_fg, bg = c.yellow, bold = true })
  hl("DotfilesStatusTerminal", { fg = mode_fg, bg = c.cyan, bold = true })
  hl("DotfilesStatusFile", { fg = c.fg, bg = c.surface })
  hl("DotfilesStatusGit", { fg = c.yellow, bg = c.surface })
  hl("DotfilesStatusInfo", { fg = c.cyan, bg = c.bg })
  hl("DotfilesStatusMuted", { fg = c.muted, bg = c.bg })
  hl("DotfilesStatusMiddle", { fg = c.muted, bg = c.bg })
  hl("DotfilesStatusError", { fg = c.red, bg = c.bg, bold = true })
  hl("DotfilesStatusWarn", { fg = c.yellow, bg = c.bg, bold = true })
  hl("DotfilesStatusHint", { fg = c.cyan, bg = c.bg })
  hl("DotfilesStatusAccent", { fg = mode_fg, bg = c.accent, bold = true })
end

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

local function current_mode()
  local current = vim.api.nvim_get_mode().mode
  return current, mode_names[current] or mode_names[current:sub(1, 1)] or current:upper()
end

local function mode_block()
  local current, label = current_mode()
  local group = mode_groups[current] or mode_groups[current:sub(1, 1)] or "DotfilesStatusNormal"
  return block(group, label)
end

local function filename()
  local name = vim.fn.expand("%:~:.")
  if name == "" then
    return "[No Name]"
  end
  return name
end

local function file_icon()
  return file_icons[vim.bo.filetype] or ""
end

local function flags()
  local items = {}
  if vim.bo.modified then
    items[#items + 1] = "●"
  end
  if vim.bo.readonly then
    items[#items + 1] = ""
  end
  if not vim.bo.modifiable then
    items[#items + 1] = "󰦝"
  end
  if vim.bo.buftype == "help" then
    items[#items + 1] = "󰋖"
  end
  return table.concat(items, " ")
end

local function branch()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end
  return " " .. head
end

local function diagnostics()
  if not vim.diagnostic or not vim.diagnostic.count then
    return ""
  end
  local count = vim.diagnostic.count(0)
  local items = {}
  local sev = vim.diagnostic.severity
  if (count[sev.ERROR] or 0) > 0 then
    items[#items + 1] = "%#DotfilesStatusError#  " .. count[sev.ERROR] .. " "
  end
  if (count[sev.WARN] or 0) > 0 then
    items[#items + 1] = "%#DotfilesStatusWarn#  " .. count[sev.WARN] .. " "
  end
  if (count[sev.INFO] or 0) > 0 then
    items[#items + 1] = "%#DotfilesStatusInfo#  " .. count[sev.INFO] .. " "
  end
  if (count[sev.HINT] or 0) > 0 then
    items[#items + 1] = "%#DotfilesStatusHint#  " .. count[sev.HINT] .. " "
  end
  return table.concat(items)
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

local function fileformat()
  local formats = { unix = "", dos = "", mac = "" }
  return formats[vim.bo.fileformat] or vim.bo.fileformat
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
    mode_block(),
    block("DotfilesStatusFile", file_icon() .. " " .. filename()),
    block("DotfilesStatusMuted", flags()),
    block("DotfilesStatusGit", branch()),
    diagnostics(),
    "%#DotfilesStatusMiddle#%=",
    block("DotfilesStatusMuted", "󰉿 " .. encoding()),
    block("DotfilesStatusMuted", fileformat()),
    block("DotfilesStatusInfo", ""),
    block("DotfilesStatusFile", (file_icons[vim.bo.filetype] or "") .. " " .. filetype()),
    block("DotfilesStatusMuted", percent()),
    block("DotfilesStatusAccent", position()),
  })
end

function M.setup()
  M.setup_highlights()
  vim.o.laststatus = 3
  vim.o.showmode = false
  vim.o.statusline = "%!v:lua.require'statusline'.render()"

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("dotfiles_statusline", { clear = true }),
    callback = M.setup_highlights,
  })
end

return M
