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
--   hl.dsp.window.move({ direction = "l/r/u/d" })       — move window in tile layout
--   hl.dsp.window.swap({ direction = "l/r/u/d" })       — swap window with neighbor
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
local menu        = "walker"  -- launcher (apps, clipboard, symbols, windows, …)
local browser     = "firefox"
local lock        = "hyprlock"

local function exec(cmd) return hl.dsp.exec_cmd(cmd) end

-- Helper: bind com `description` legível em hyprctl binds (em vez de __lua).
local function kb(keys, dispatcher, desc)
  return hl.bind(keys, dispatcher, { description = desc })
end

-- ─── Apps ──────────────────────────────────────────────────────────────────

kb(M  .. " + Return", exec(terminal),                       "terminal")
kb(M  .. " + E",      exec(fileManager),                    "file manager")
kb(M  .. " + R",      exec(menu),                           "launcher (walker default search)")
kb(M  .. " + space",  exec("walker -m providerlist"),       "launcher (walker provider picker)")
kb(M  .. " + I",      exec("llm"),                          "LLM picker (claude/codex/…)")
kb(M  .. " + B",      exec(browser),                        "browser")
kb(M  .. " + L",      exec(lock),                           "lock screen")
kb(MS .. " + P",      exec("power-menu"),                   "power menu (lock/suspend/logout/reboot/shutdown)")
kb(M  .. " + M",      exec("hypr-exit"),                    "exit Hyprland (graceful)")
kb(M  .. " + grave",  exec("scratch"),                      "scratchpad terminal")

-- ─── Window management ─────────────────────────────────────────────────────

kb(MS .. " + Q",      hl.dsp.window.close(),                "close window")
kb(M  .. " + T",      hl.dsp.window.float({ action = "toggle" }), "toggle floating (T = tile/float)")
kb(M  .. " + P",      hl.dsp.window.pseudo(),               "pseudo tile")
kb(M  .. " + J",      hl.dsp.layout("togglesplit"),         "toggle split (dwindle)")
kb(M  .. " + F",      hl.dsp.window.fullscreen(),           "fullscreen")

-- Move focus
kb(M  .. " + left",   hl.dsp.focus({ direction = "l" }),    "focus left")
kb(M  .. " + right",  hl.dsp.focus({ direction = "r" }),    "focus right")
kb(M  .. " + up",     hl.dsp.focus({ direction = "u" }),    "focus up")
kb(M  .. " + down",   hl.dsp.focus({ direction = "d" }),    "focus down")

-- Move window in tile layout (rearranges position, doesn't swap with neighbor)
kb(MS .. " + left",   hl.dsp.window.move({ direction = "l" }), "move window left")
kb(MS .. " + right",  hl.dsp.window.move({ direction = "r" }), "move window right")
kb(MS .. " + up",     hl.dsp.window.move({ direction = "u" }), "move window up")
kb(MS .. " + down",   hl.dsp.window.move({ direction = "d" }), "move window down")

-- Mouse drag
hl.bind(M  .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M  .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Tab: cycle monitor focus / Alt+Tab opens window picker (Windows-style)
kb(M  .. " + Tab", hl.dsp.focus({ monitor = "+1" }), "cycle monitor focus")
kb("ALT + Tab",    exec("walker -m windows"),        "window picker (alt-tab)")
kb(MS .. " + Tab", exec("walker -m windows"),        "window picker (MS+Tab fallback)")

-- ─── Workspaces ────────────────────────────────────────────────────────────

-- SUPER + 1..9,0 → muda workspace; SHIFT também → move janela
for i = 1, 10 do
  local key = i % 10  -- 10 vira "0"
  kb(M  .. " + " .. key, hl.dsp.focus({ workspace = i }),         "workspace " .. i)
  kb(MS .. " + " .. key, hl.dsp.window.move({ workspace = i }),   "move to ws " .. i)
end

-- Special workspace (scratchpad)
kb(M  .. " + S",   hl.dsp.workspace.toggle_special("magic"),                   "toggle scratchpad")
kb(MS .. " + S",   hl.dsp.window.move({ workspace = "special:magic" }),        "move to scratchpad")

-- Scroll workspaces
kb(M  .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }),                 "next workspace (scroll)")
kb(M  .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }),                 "prev workspace (scroll)")

-- ─── Screenshots ───────────────────────────────────────────────────────────

kb("Print",            exec("screenshot region"),         "screenshot region")
kb(M  .. " + Print",   exec("screenshot full"),           "screenshot full")
kb(MS .. " + F",       exec("screenshot region --copy"),  "screenshot region (clipboard)")
kb(MC .. " + Print",   exec("screenshot window"),         "screenshot window")
kb(MS .. " + O",       exec("ocr"),                       "OCR region → clipboard")

-- ─── Clipboard / color picker / pickers (walker-driven) ───────────────────

kb(M  .. " + V",          exec("walker -m clipboard"),    "clipboard history")
kb(MS .. " + C",          exec("color-picker"),           "color picker (hex)")
kb(M  .. " + period",     exec("walker -m symbols"),      "emoji / symbols")
kb(MS .. " + period",     exec("walker -m symbols"),      "emoji / symbols (alias)")

-- ─── TUIs floating alacritty ───────────────────────────────────────────────

kb(MS  .. " + G",  exec("floating-tui lazygit"),     "lazygit (TUI)")
kb(MS  .. " + D",  exec("floating-tui lazydocker"),  "lazydocker (TUI)")
kb(MS  .. " + T",  exec("floating-tui btop"),        "btop (TUI)")
kb(MS  .. " + B",  exec("floating-tui bluetui"),     "bluetui (Bluetooth TUI)")
kb(MS  .. " + W",  exec("floating-tui impala"),      "impala (Wi-Fi TUI)")
kb(MS  .. " + A",  exec("floating-tui pacsea"),      "pacsea (Arch pkg TUI)")
kb(MSA .. " + M",  exec("floating-tui cliamp"),      "cliamp (music TUI)")

-- ─── Web apps (firefoxpwa) ─────────────────────────────────────────────────

kb(MC .. " + G",  exec("web-app launch chatgpt"),    "web-app: ChatGPT")
kb(MC .. " + W",  exec("web-app launch whatsapp"),   "web-app: WhatsApp")
kb(MC .. " + Y",  exec("web-app launch youtube"),    "web-app: YouTube")
kb(MC .. " + X",  exec("web-app launch x"),          "web-app: X (Twitter)")
kb(MC .. " + Z",  exec("web-app launch zoom"),       "web-app: Zoom")

-- ─── Notices (on-demand info → notify-send) ────────────────────────────────

kb(MCA .. " + T",  exec("notice date"),              "notice: date")
kb(MCA .. " + W",  exec("notice weather"),           "notice: weather")
kb(MCA .. " + B",  exec("notice battery"),           "notice: battery")
kb(MCA .. " + N",  exec("notice network"),           "notice: network")
kb(MCA .. " + S",  exec("notice system"),            "notice: system info")

-- ─── Monitor scale + magnify ───────────────────────────────────────────────

kb(M  .. " + slash",   exec("hypr-scale +0.1"),      "monitor scale +0.1")
kb(MA .. " + slash",   exec("hypr-scale -0.1"),      "monitor scale -0.1")
kb(M  .. " + equal",   exec("magnify in"),           "magnify in")
kb(M  .. " + minus",   exec("magnify out"),          "magnify out")
kb(MS .. " + m",       exec("magnify toggle"),       "magnify toggle")

-- ─── Themes + power profile + DND + night mode ─────────────────────────────

kb(MCA .. " + Y",  exec("theme cycle"),              "cycle theme")
kb(MCA .. " + P",  exec("power-profile cycle"),      "cycle power profile")
kb(MCA .. " + D",  exec("dnd"),                      "toggle DND")
kb(MCA .. " + M",  exec("night-mode"),               "toggle night mode")
kb(MCA .. " + R",  exec("record"),                   "screen record")

-- ─── Hyprland state toggles (gaps, transparency, layout, mirror) ───────────

kb(MCA .. " + G",  exec("hypr-gaps-toggle"),         "toggle gaps")
kb(MCA .. " + O",  exec("hypr-transparency-toggle"), "toggle transparency")
kb(MCA .. " + L",  exec("hypr-layout-toggle"),       "cycle layout (dwindle/master)")
kb(MCA .. " + C",  exec("hypr-monitor-mirror toggle"), "toggle monitor mirror")

-- Cycle keyboard layout
kb(MA .. " + space", exec("hyprctl switchxkblayout all next"), "cycle keyboard layout")

-- ─── Helpers: cheatsheet + Obsidian ────────────────────────────────────────

kb(MS .. " + H",  exec("dots-cheatsheet"),            "cheatsheet (all sources)")
kb(M  .. " + N",  exec("obsidian-note today"),       "obsidian: today's note")
kb(MS .. " + N",  exec("obsidian-note find"),        "obsidian: find note")
kb(MC .. " + N",  exec("obsidian-note search"),      "obsidian: search content")

-- ─── Notifications (mako) ──────────────────────────────────────────────────

kb(M  .. " + Backspace",  exec("dots-notifications clear"),   "notifications: dismiss all")
kb(MS .. " + Backspace",  exec("dots-notifications restore"), "notifications: restore last")
kb(MC .. " + Backspace",  exec("dots-notifications pick"),    "notifications: pick (walker)")

-- ─── AGS sidebar (control panel) ───────────────────────────────────────────

kb(M  .. " + backslash",  exec("ags toggle sidebar"),         "toggle sidebar (control panel)")

-- ─── Multimedia keys (sem mod, repeating + locked) ─────────────────────────

hl.bind("XF86AudioRaiseVolume",  exec("volume raise"),
    { repeating = true, locked = true, description = "volume up" })
hl.bind("XF86AudioLowerVolume",  exec("volume lower"),
    { repeating = true, locked = true, description = "volume down" })
hl.bind("XF86AudioMute",         exec("volume mute-toggle"),
    { repeating = true, locked = true, description = "mute toggle" })
hl.bind("XF86AudioMicMute",      exec("volume mic-mute-toggle"),
    { repeating = true, locked = true, description = "mic mute toggle" })
hl.bind("XF86MonBrightnessUp",   exec("brightness raise"),
    { repeating = true, locked = true, description = "brightness up" })
hl.bind("XF86MonBrightnessDown", exec("brightness lower"),
    { repeating = true, locked = true, description = "brightness down" })

-- Playerctl (locked: funciona com sessão travada)
hl.bind("XF86AudioNext",  exec("playerctl next"),       { locked = true, description = "media: next" })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true, description = "media: pause/play" })
hl.bind("XF86AudioPlay",  exec("playerctl play-pause"), { locked = true, description = "media: pause/play" })
hl.bind("XF86AudioPrev",  exec("playerctl previous"),   { locked = true, description = "media: previous" })
