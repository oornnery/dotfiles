-- ~/.config/hypr/lua/events.lua — event hooks reativos (Hyprland 0.55+ Lua API).
--
-- hl.on(event, callback) — the callback runs when the event fires.
-- Limite: 100ms timeout por callback, max recursion depth 5 (anti-loop).
-- Errors do not stop the other handlers.

-- ─── Monitor plug/unplug ───────────────────────────────────────────────────
-- When a monitor is plugged in or out, apply monitors.lua again through a reload.
-- Notify, so a flicker does not look like a broken screen.

hl.on("monitor.added", function(monitor)
  hl.exec_cmd("notify-send -a hyprland 'Monitor conectado' '" .. (monitor.name or "?") .. "' -t 3000")
  -- Re-aplicar monitors.lua (carrega rules pro novo monitor).
  hl.exec_cmd("hyprctl reload")
end)

hl.on("monitor.removed", function(monitor)
  hl.exec_cmd("notify-send -a hyprland 'Monitor removido' '" .. (monitor.name or "?") .. "' -t 3000")
end)

-- ─── Screenshare privacy indicator ────────────────────────────────────────
-- Warn when a screencast starts or stops (paranoid mode).

hl.on("screenshare.state", function(state)
  if state == "started" or state == true then
    hl.exec_cmd("notify-send -a hyprland -u critical 'Screensharing ATIVO' 'Pessoas podem estar vendo sua tela' -t 6000")
  elseif state == "stopped" or state == false then
    hl.exec_cmd("notify-send -a hyprland 'Screensharing parado' '' -t 2000")
  end
end)

-- ─── Config reload feedback ────────────────────────────────────────────────
-- Confirm that `hyprctl reload` worked (visual feedback).

hl.on("config.reloaded", function()
  hl.exec_cmd("notify-send -a hyprland 'Config reloaded' '' -t 1500")
end)

-- ─── Shutdown cleanup ─────────────────────────────────────────────────────
-- Kill daemons that do not stop by themselves when Hyprland exits
-- (avoids orphaned processes on logout).

hl.on("hyprland.shutdown", function()
  hl.exec_cmd("pkill -TERM walker")
  hl.exec_cmd("systemctl --user stop elephant.service")
  hl.exec_cmd("pkill -TERM mako")
  hl.exec_cmd("pkill -TERM hypridle")
end)
