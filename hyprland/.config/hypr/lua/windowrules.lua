-- ~/.config/hypr/lua/windowrules.lua — window rules (regex match).

-- 1. Ignora pedidos de maximizar de todos os apps.
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- 2. Fix de drag issues no XWayland (sem class/title, xwayland, floating).
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- 3. hyprland-run launcher → posiciona embaixo.
hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },
  move = "20 monitor_h-120",
  float = true,
})

-- 4. Astal launcher fallback (caso título seja "Astal Launcher" ou "Launcher").
hl.window_rule({
  name = "astal-launcher-fallback",
  match = { title = "^(Astal Launcher|Launcher)$" },
  float = true,
  center = 1,
  size = "620 430",
  border_size = 0,
  rounding = 0,
  no_shadow = true,
})

-- 5. floating-tui: alacritty spawn with --class floating-tui → centered float.
--    Usado por Super+Shift+{G/D/T/B/W/A,M} pra TUIs (lazygit, btop, etc.).
hl.window_rule({
  name = "floating-tui",
  match = { class = "^floating-tui$" },
  float = true,
  center = 1,
  size = "1000 700",
})

-- 6. Bare `floating` class (cheatsheet usa esse — alacritty --class floating).
hl.window_rule({
  name = "floating-generic",
  match = { class = "^floating$" },
  float = true,
  center = 1,
  size = "900 600",
})

-- 7. floating-md: glow/bat reader pra cheatsheet docs. Reading-friendly
--    proportions (mais alto que largo, padding generoso, ideal pra MD).
hl.window_rule({
  name = "floating-md",
  match = { class = "^floating-md$" },
  float = true,
  center = 1,
  size = "900 800",
  opacity = "0.98 0.95",
})
