-- ~/.config/hypr/lua/bindings.lua — todas as keybindings.
--
-- API Lua do Hyprland 0.55:
--   hl.bind(keys, dispatcher|fn, opts?)
--   hl.dsp.exec_cmd(cmd)                                — roda shell
--   hl.dsp.focus({ direction = "l/r/u/d" })             — move focus
--   hl.dsp.focus({ workspace = N | "e+1" | "e-1" })     — muda workspace
--   hl.dsp.window.close()                               — fecha janela
--   hl.dsp.window.fullscreen()                          — fullscreen
--   hl.dsp.window.float({ action = "toggle" })          — float toggle
--   hl.dsp.window.pseudo()                              — pseudo tile
--   hl.dsp.window.swap({ direction = "l/r/u/d" })       — move window in tile layout
--   hl.dsp.window.move({ workspace = N })               — move window to ws
--   hl.dsp.window.move({ monitor = "+1" })              — move window to monitor
--   hl.dsp.window.drag()                                — mouse drag
--   hl.dsp.window.resize()                              — mouse resize
--   hl.dsp.workspace.toggle_special("magic")            — scratchpad
--   hl.dsp.layout("togglesplit")                        — dwindle layoutmsg

local M   = "SUPER"
local MS  = "SUPER + SHIFT"
local MC  = "SUPER + CTRL"
local MCA = "SUPER + CTRL + ALT"
local MA  = "SUPER + ALT"
local MSA = "SUPER + SHIFT + ALT"

-- Programas
local terminal    = "alacritty"
local fileManager = "nautilus"
-- Launcher: walker é o atual; wofi --show drun continua como fallback.
local menu        = "walker"
local menu_old    = "wofi --show drun"
local browser     = "firefox"
local lock        = "hyprlock"
local logout      = "wlogout"

local function exec(cmd) return hl.dsp.exec_cmd(cmd) end

-- ─── Apps ──────────────────────────────────────────────────────────────────

hl.bind(M  .. " + Q",      exec(terminal))
hl.bind(M  .. " + E",      exec(fileManager))
hl.bind(M  .. " + R",      exec(menu))           -- walker
hl.bind(MS .. " + R",      exec(menu_old))       -- wofi (fallback)
hl.bind(M  .. " + B",      exec(browser))
hl.bind(M  .. " + L",      exec(lock))
hl.bind(MS .. " + E",      exec(logout))
hl.bind(MS .. " + P",      exec("power-menu"))
hl.bind(M  .. " + M",      exec("sh -c 'command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit'"))
hl.bind(M  .. " + grave",  exec("scratch"))

-- ─── Window management ─────────────────────────────────────────────────────

hl.bind(M  .. " + C",      hl.dsp.window.close())
hl.bind(M  .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(M  .. " + P",      hl.dsp.window.pseudo())
hl.bind(M  .. " + J",      hl.dsp.layout("togglesplit"))
hl.bind(M  .. " + F",      hl.dsp.window.fullscreen())

-- Move focus
hl.bind(M  .. " + left",   hl.dsp.focus({ direction = "l" }))
hl.bind(M  .. " + right",  hl.dsp.focus({ direction = "r" }))
hl.bind(M  .. " + up",     hl.dsp.focus({ direction = "u" }))
hl.bind(M  .. " + down",   hl.dsp.focus({ direction = "d" }))

-- Move window in tile layout (swap with neighbor)
hl.bind(MS .. " + left",   hl.dsp.window.swap({ direction = "l" }))
hl.bind(MS .. " + right",  hl.dsp.window.swap({ direction = "r" }))
hl.bind(MS .. " + up",     hl.dsp.window.swap({ direction = "u" }))
hl.bind(MS .. " + down",   hl.dsp.window.swap({ direction = "d" }))

-- Mouse drag
hl.bind(M  .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M  .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Window finder (walker)
hl.bind(MS .. " + Tab",    exec("walker -m windows"))

-- ─── Workspaces ────────────────────────────────────────────────────────────

-- SUPER + 1..9,0 → muda workspace; SHIFT também → move janela
for i = 1, 10 do
  local key = i % 10  -- 10 vira "0"
  hl.bind(M  .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(MS .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(M  .. " + S",   hl.dsp.workspace.toggle_special("magic"))
hl.bind(MS .. " + S",   hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(M  .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M  .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ─── Screenshots ───────────────────────────────────────────────────────────

hl.bind("Print",            exec("screenshot region"))
hl.bind(M  .. " + Print",   exec("screenshot full"))
hl.bind(MS .. " + F",       exec("screenshot region --copy"))
hl.bind(MC .. " + Print",   exec("screenshot window"))
hl.bind(MS .. " + O",       exec("ocr"))

-- ─── Clipboard / color picker / pickers (walker-driven) ───────────────────

hl.bind(M  .. " + V",          exec("walker -m clipboard"))   -- clipboard history
hl.bind(MS .. " + C",          exec("color-picker"))           -- hex color picker
hl.bind(M  .. " + period",     exec("walker -m symbols"))      -- emoji + unicode
hl.bind(MS .. " + period",     exec("walker -m symbols"))      -- (legacy alias)

-- ─── TUIs floating alacritty ───────────────────────────────────────────────

hl.bind(MS  .. " + G",  exec("floating-tui lazygit"))
hl.bind(MS  .. " + D",  exec("floating-tui lazydocker"))
hl.bind(MS  .. " + T",  exec("floating-tui btop"))
hl.bind(MS  .. " + B",  exec("floating-tui bluetui"))
hl.bind(MS  .. " + W",  exec("floating-tui impala"))
hl.bind(MS  .. " + A",  exec("floating-tui pacsea"))
hl.bind(MSA .. " + M",  exec("floating-tui cliamp"))

-- ─── Web apps (firefoxpwa) ─────────────────────────────────────────────────

hl.bind(MC .. " + G",  exec("web-app launch chatgpt"))
hl.bind(MC .. " + W",  exec("web-app launch whatsapp"))
hl.bind(MC .. " + Y",  exec("web-app launch youtube"))
hl.bind(MC .. " + X",  exec("web-app launch x"))
hl.bind(MC .. " + Z",  exec("web-app launch zoom"))

-- ─── Notices (on-demand info → notify-send) ────────────────────────────────

hl.bind(MCA .. " + T",  exec("notice date"))
hl.bind(MCA .. " + W",  exec("notice weather"))
hl.bind(MCA .. " + B",  exec("notice battery"))
hl.bind(MCA .. " + N",  exec("notice network"))
hl.bind(MCA .. " + S",  exec("notice system"))

-- ─── Monitor scale + magnify ───────────────────────────────────────────────

hl.bind(M  .. " + slash",   exec("hypr-scale +0.1"))
hl.bind(MA .. " + slash",   exec("hypr-scale -0.1"))
hl.bind(M  .. " + equal",   exec("magnify in"))
hl.bind(M  .. " + minus",   exec("magnify out"))
hl.bind(MS .. " + m",       exec("magnify toggle"))

-- ─── Themes + power profile + DND + night mode ─────────────────────────────

hl.bind(MCA .. " + Y",  exec("theme cycle"))
hl.bind(MCA .. " + P",  exec("power-profile cycle"))
hl.bind(MCA .. " + D",  exec("dnd"))
hl.bind(MCA .. " + M",  exec("night-mode"))
hl.bind(MCA .. " + R",  exec("record"))

-- ─── Hyprland state toggles (gaps, transparency, layout, mirror) ───────────

hl.bind(MCA .. " + G",  exec("hypr-gaps-toggle"))         -- gaps on/off
hl.bind(MCA .. " + O",  exec("hypr-transparency-toggle")) -- opacity active/inactive
hl.bind(MCA .. " + L",  exec("hypr-layout-toggle"))       -- dwindle ↔ master
hl.bind(MCA .. " + C",  exec("hypr-monitor-mirror toggle")) -- mirror displays

-- Cycle keyboard layout
hl.bind(MA .. " + space", exec("hyprctl switchxkblayout all next"))

-- ─── Helpers: cheatsheet + Obsidian ────────────────────────────────────────

hl.bind(MS .. " + H",  exec("dots-menu-keybindings"))
hl.bind(M  .. " + N",  exec("obsidian-note today"))
hl.bind(MS .. " + N",  exec("obsidian-note find"))
hl.bind(MC .. " + N",  exec("obsidian-note search"))

-- ─── Multimedia keys (sem mod, repeating + locked) ─────────────────────────

hl.bind("XF86AudioRaiseVolume",  exec("volume raise"),           { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  exec("volume lower"),           { repeating = true, locked = true })
hl.bind("XF86AudioMute",         exec("volume mute-toggle"),     { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",      exec("volume mic-mute-toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",   exec("brightness raise"),       { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", exec("brightness lower"),       { repeating = true, locked = true })

-- Playerctl (locked: funciona com sessão travada)
hl.bind("XF86AudioNext",  exec("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  exec("playerctl previous"),   { locked = true })
