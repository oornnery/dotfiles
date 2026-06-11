-- ~/.config/hypr/lua/autostart.lua — daemons & serviços ao iniciar o Hyprland.
--
-- Padrão correto da API Lua: hl.dsp.exec_cmd é um DISPATCHER (retorna obj),
-- não executa nada. Pra realmente rodar comandos no startup, usar hl.exec_cmd
-- (top-level) dentro do callback do evento hyprland.start.

hl.on("hyprland.start", function()
  -- Sessão: dbus + systemd user env.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GNOME_KEYRING_CONTROL SSH_AUTH_SOCK")

  -- Wallpaper + status bar (AGS) + notifications.
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("ags run")
  hl.exec_cmd("mako")

  -- Clipboard history (Mod+V → cliphist).
  hl.exec_cmd("wl-paste --type text  --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Idle / lock daemon.
  hl.exec_cmd("hypridle")

  -- USB / removable media.
  hl.exec_cmd("udiskie --automount --notify --tray")

  -- Polkit auth dialogs.
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

  -- Network applet.
  hl.exec_cmd("nm-applet --indicator")

  -- (Monitor plug/unplug is handled natively in events.lua via hl.on.)

  -- Walker daemon (launcher) — Super+R triggers via D-Bus if already running.
  -- Garantir que elephant (provider backend) inicia explícito; o systemd
  -- graphical-session.target pode não ser alcançado em todas as sessions.
  hl.exec_cmd("systemctl --user start elephant.service")
  hl.exec_cmd("walker --gapplication-service")

  -- Custom Fabric shell (opcional).
  -- hl.exec_cmd("bash -lc 'cd ~/.config/fabric-shell 2>/dev/null || cd ~/dotfiles/fabric/.config/fabric-shell 2>/dev/null && uv run src/main.py'")
end)
