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

-- 8. satty (screenshot annotator) — `screenshot region` pops this for
--    drawing arrows/text/blur on the captured region before saving.
hl.window_rule({
  name = "satty-floating",
  match = { class = "^satty$" },
  float = true,
  center = 1,
  size = "1200 800",
})

-- 9. Browser dialogs (Firefox / Vivaldi / Chromium / Brave) — file pickers,
--    print dialogs, sign-in popups, page info, library, picture-in-picture.
--    Match by title patterns that browsers use for their secondary windows.
hl.window_rule({
  name = "browser-dialogs",
  match = {
    class = "^(firefox|firefox-developer-edition|vivaldi-stable|chromium|brave-browser|Google-chrome|google-chrome)$",
    title = "(^Open File|^Save (Page )?As|^Print|^Sign in|^Library|^Page Info|^Downloads|Picture-in-Picture|^Add-ons Manager|^File Upload)",
  },
  float = true,
  center = 1,
  size = "900 650",
})

-- 10. Firefox / Chromium native JS dialogs (alert/confirm/prompt). These
--     usually carry no class match (browser-dialogs catches them) but extra
--     belt-and-braces for the bare "Dialog" / "Prompt" cases some apps use.
hl.window_rule({
  name = "generic-dialogs",
  match = { title = "^(Confirm|Alert|Prompt|.*Dialog)$" },
  float = true,
  center = 1,
})

-- 11. Firefox PWA web apps (ChatGPT / WhatsApp / YouTube / Zoom popups).
--     Class is `FFPWA-<id>`. Sign-in popups + auth windows.
hl.window_rule({
  name = "firefoxpwa-popups",
  match = { class = "^FFPWA-", title = "(^Sign in|Picture-in-Picture|^Notification)" },
  float = true,
  center = 1,
  size = "600 500",
})

-- 12. Portal / system dialogs (xdg-desktop-portal-* gtk/hyprland popups for
--     file/screen sharing prompts, keyring unlock, etc.).
hl.window_rule({
  name = "portal-popups",
  match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-hyprland|Gcr-prompter|polkit-gnome-authentication-agent-1)$" },
  float = true,
  center = 1,
})
