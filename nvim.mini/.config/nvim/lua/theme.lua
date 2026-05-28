local M = {}

function M.setup(spec)
  local c = spec.colors or {}

  M.name = spec.name or "dotfiles"
  M.colorscheme = spec.colorscheme or "dotfiles"
  M.lazyvim_colorscheme = spec.lazyvim_colorscheme or M.colorscheme

  local function hl(group, opts)
    pcall(vim.api.nvim_set_hl, 0, group, opts)
  end

  local function set_highlights()
    local bg = c.bg or "#1e1e2e"
    local fg = c.fg or "#cdd6f4"
    local surface = c.surface or bg
    local surface2 = c.surface2 or surface
    local muted = c.muted or fg
    local accent = c.accent or fg
    local accent2 = c.accent2 or accent
    local yellow = c.yellow or accent
    local red = c.red or accent
    local blue = c.blue or accent2
    local green = c.green or accent2
    local cyan = c.cyan or accent2
    local magenta = c.magenta or accent
    local orange = c.orange or yellow

    vim.o.termguicolors = true
    vim.g.colors_name = "dotfiles"

    hl("Normal", { fg = fg, bg = bg })
    hl("NormalNC", { fg = fg, bg = bg })
    hl("EndOfBuffer", { fg = bg, bg = bg })
    hl("NormalFloat", { fg = fg, bg = surface })
    hl("FloatBorder", { fg = accent, bg = surface })
    hl("FloatTitle", { fg = bg, bg = accent, bold = true })
    hl("Cursor", { fg = bg, bg = fg })
    hl("CursorLine", { bg = surface })
    hl("CursorColumn", { bg = surface })
    hl("LineNr", { fg = muted, bg = bg })
    hl("CursorLineNr", { fg = accent, bg = surface, bold = true })
    hl("SignColumn", { fg = muted, bg = bg })
    hl("ColorColumn", { bg = surface })
    hl("WinSeparator", { fg = surface2, bg = bg })
    hl("VertSplit", { fg = surface2, bg = bg })
    hl("StatusLine", { fg = bg, bg = accent, bold = true })
    hl("StatusLineNC", { fg = muted, bg = surface })
    hl("DotfilesStatusMode", { fg = bg, bg = accent, bold = true })
    hl("DotfilesStatusFile", { fg = fg, bg = surface })
    hl("DotfilesStatusInfo", { fg = bg, bg = accent2, bold = true })
    hl("DotfilesStatusMuted", { fg = muted, bg = surface })
    hl("DotfilesStatusAccent", { fg = bg, bg = yellow, bold = true })
    hl("DotfilesStatusMiddle", { fg = muted, bg = bg })
    hl("TabLine", { fg = muted, bg = surface })
    hl("TabLineSel", { fg = bg, bg = accent, bold = true })
    hl("TabLineFill", { fg = muted, bg = bg })
    hl("Pmenu", { fg = fg, bg = surface })
    hl("PmenuSel", { fg = bg, bg = accent, bold = true })
    hl("PmenuSbar", { bg = surface })
    hl("PmenuThumb", { bg = surface2 })
    hl("Visual", { bg = surface2 })
    hl("Search", { fg = bg, bg = yellow, bold = true })
    hl("IncSearch", { fg = bg, bg = accent, bold = true })
    hl("CurSearch", { fg = bg, bg = orange, bold = true })
    hl("MatchParen", { fg = yellow, bg = surface2, bold = true })
    hl("Directory", { fg = blue, bold = true })
    hl("Title", { fg = accent, bold = true })
    hl("MsgArea", { fg = fg, bg = bg })
    hl("ModeMsg", { fg = green, bold = true })
    hl("MoreMsg", { fg = green })
    hl("Question", { fg = accent })
    hl("NonText", { fg = muted })
    hl("SpecialKey", { fg = muted })
    hl("Whitespace", { fg = surface2 })
    hl("Folded", { fg = muted, bg = surface })
    hl("FoldColumn", { fg = muted, bg = bg })
    hl("QuickFixLine", { bg = surface, bold = true })

    hl("Comment", { fg = muted, italic = true })
    hl("Constant", { fg = orange })
    hl("String", { fg = green })
    hl("Character", { fg = green })
    hl("Number", { fg = orange })
    hl("Boolean", { fg = orange })
    hl("Float", { fg = orange })
    hl("Identifier", { fg = fg })
    hl("Function", { fg = blue })
    hl("Statement", { fg = magenta })
    hl("Conditional", { fg = magenta })
    hl("Repeat", { fg = magenta })
    hl("Label", { fg = magenta })
    hl("Operator", { fg = cyan })
    hl("Keyword", { fg = magenta, italic = true })
    hl("Exception", { fg = red })
    hl("PreProc", { fg = yellow })
    hl("Include", { fg = magenta })
    hl("Define", { fg = magenta })
    hl("Macro", { fg = magenta })
    hl("PreCondit", { fg = yellow })
    hl("Type", { fg = yellow })
    hl("StorageClass", { fg = yellow })
    hl("Structure", { fg = yellow })
    hl("Typedef", { fg = yellow })
    hl("Special", { fg = cyan })
    hl("SpecialChar", { fg = cyan })
    hl("Tag", { fg = red })
    hl("Delimiter", { fg = muted })
    hl("SpecialComment", { fg = muted, italic = true })
    hl("Debug", { fg = red })
    hl("Underlined", { fg = blue, underline = true })
    hl("Error", { fg = red, bold = true })
    hl("Todo", { fg = bg, bg = yellow, bold = true })

    hl("@comment", { link = "Comment" })
    hl("@variable", { fg = fg })
    hl("@variable.builtin", { fg = red, italic = true })
    hl("@constant", { link = "Constant" })
    hl("@constant.builtin", { fg = orange, bold = true })
    hl("@module", { fg = yellow })
    hl("@string", { link = "String" })
    hl("@character", { link = "Character" })
    hl("@number", { link = "Number" })
    hl("@boolean", { link = "Boolean" })
    hl("@float", { link = "Float" })
    hl("@function", { link = "Function" })
    hl("@function.builtin", { fg = cyan })
    hl("@function.method", { fg = blue })
    hl("@constructor", { fg = yellow })
    hl("@keyword", { link = "Keyword" })
    hl("@keyword.function", { fg = magenta, italic = true })
    hl("@keyword.operator", { fg = magenta })
    hl("@operator", { link = "Operator" })
    hl("@type", { link = "Type" })
    hl("@type.builtin", { fg = yellow, italic = true })
    hl("@property", { fg = cyan })
    hl("@field", { fg = cyan })
    hl("@parameter", { fg = orange })
    hl("@punctuation.delimiter", { fg = muted })
    hl("@punctuation.bracket", { fg = muted })
    hl("@punctuation.special", { fg = accent })
    hl("@tag", { fg = red })
    hl("@tag.attribute", { fg = yellow })
    hl("@tag.delimiter", { fg = muted })

    hl("DiagnosticError", { fg = red })
    hl("DiagnosticWarn", { fg = yellow })
    hl("DiagnosticInfo", { fg = blue })
    hl("DiagnosticHint", { fg = cyan })
    hl("DiagnosticVirtualTextError", { fg = red, bg = surface })
    hl("DiagnosticVirtualTextWarn", { fg = yellow, bg = surface })
    hl("DiagnosticVirtualTextInfo", { fg = blue, bg = surface })
    hl("DiagnosticVirtualTextHint", { fg = cyan, bg = surface })
    hl("DiagnosticUnderlineError", { sp = red, undercurl = true })
    hl("DiagnosticUnderlineWarn", { sp = yellow, undercurl = true })
    hl("DiagnosticUnderlineInfo", { sp = blue, undercurl = true })
    hl("DiagnosticUnderlineHint", { sp = cyan, undercurl = true })

    hl("DiffAdd", { fg = green, bg = surface })
    hl("DiffChange", { fg = yellow, bg = surface })
    hl("DiffDelete", { fg = red, bg = surface })
    hl("DiffText", { fg = blue, bg = surface2, bold = true })
    hl("MiniTablineCurrent", { fg = bg, bg = accent, bold = true })
    hl("MiniTablineVisible", { fg = fg, bg = surface })
    hl("MiniTablineHidden", { fg = muted, bg = bg })
    hl("MiniStarterHeader", { fg = accent, bold = true })

  end

  function M.apply()
    vim.o.background = spec.background or "dark"
    if M.colorscheme and not M._setting_colorscheme then
      M._setting_colorscheme = true
      pcall(vim.cmd.colorscheme, M.colorscheme)
      M._setting_colorscheme = false
    end
    set_highlights()
  end

  local group = vim.api.nvim_create_augroup("dotfiles_theme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_highlights,
  })

  M.apply()
  return M
end

local home = vim.env.HOME or ""
local data_home = vim.env.XDG_DATA_HOME or (home .. "/.local/share")
local state_file = data_home .. "/dotfiles/active-theme"
local dotfiles_dir = vim.env.DOTFILES_DIR or (home .. "/dotfiles")

local function read_first_line(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local line = file:read("*l")
  file:close()
  return line
end

local name = read_first_line(state_file) or "catppuccin-mocha"
name = vim.trim(name)

if not name:match("^[%w_.-]+$") then
  name = "catppuccin-mocha"
end

local theme_file = dotfiles_dir .. "/themes/" .. name .. "/nvim.lua"
local spec = nil
if vim.fn.filereadable(theme_file) == 1 then
  spec = dofile(theme_file)
end

return M.setup(spec or {
  name = "catppuccin-mocha",
  background = "dark",
  colorscheme = "dotfiles",
  lazyvim_colorscheme = "dotfiles",
  colors = {
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
  },
})
