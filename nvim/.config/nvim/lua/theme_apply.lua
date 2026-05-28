local M = {}

function M.setup(spec)
  local c = spec.colors or {}

  M.name = spec.name
  M.colorscheme = spec.colorscheme or "habamax"
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

    hl("Normal", { fg = fg, bg = bg })
    hl("NormalNC", { fg = fg, bg = bg })
    hl("NormalFloat", { fg = fg, bg = surface })
    hl("FloatBorder", { fg = accent, bg = surface })
    hl("CursorLine", { bg = surface })
    hl("LineNr", { fg = muted, bg = bg })
    hl("CursorLineNr", { fg = accent, bg = surface, bold = true })
    hl("SignColumn", { fg = muted, bg = bg })
    hl("ColorColumn", { bg = surface })
    hl("WinSeparator", { fg = surface2, bg = bg })
    hl("VertSplit", { fg = surface2, bg = bg })
    hl("StatusLine", { fg = bg, bg = accent, bold = true })
    hl("StatusLineNC", { fg = muted, bg = surface })
    hl("Pmenu", { fg = fg, bg = surface })
    hl("PmenuSel", { fg = bg, bg = accent, bold = true })
    hl("Visual", { bg = surface2 })
    hl("Search", { fg = bg, bg = yellow, bold = true })
    hl("IncSearch", { fg = bg, bg = accent, bold = true })
    hl("DiagnosticError", { fg = red })
    hl("DiagnosticWarn", { fg = yellow })
    hl("DiagnosticInfo", { fg = blue })
    hl("DiagnosticHint", { fg = accent2 })

    hl("MiniStatuslineModeNormal", { fg = bg, bg = accent, bold = true })
    hl("MiniStatuslineModeInsert", { fg = bg, bg = accent2, bold = true })
    hl("MiniStatuslineModeVisual", { fg = bg, bg = yellow, bold = true })
    hl("MiniStatuslineModeReplace", { fg = bg, bg = red, bold = true })
    hl("MiniStatuslineModeCommand", { fg = bg, bg = blue, bold = true })
    hl("MiniStatuslineDevinfo", { fg = fg, bg = surface })
    hl("MiniStatuslineFilename", { fg = muted, bg = surface })
    hl("MiniStatuslineFileinfo", { fg = fg, bg = surface })
    hl("MiniStatuslineInactive", { fg = muted, bg = surface })
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

return M
