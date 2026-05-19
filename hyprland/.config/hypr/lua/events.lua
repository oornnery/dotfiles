-- ~/.config/hypr/lua/events.lua — event hooks reativos (Hyprland 0.55+ Lua API).
--
-- hl.on(event, callback) — callback roda quando o evento dispara.
-- Limite: 100ms timeout por callback, max recursion depth 5 (anti-loop).
-- Erros não interrompem outros handlers.

-- ─── Monitor plug/unplug (substituí hypr-monitor-watch shell script) ───────
-- Quando monitor é conectado/desconectado, re-aplica monitors.lua via reload.
-- Notifica o usuário pra não pensar que tela bugou.

hl.on("monitor.added", function(monitor)
  hl.exec_cmd("notify-send -a hyprland 'Monitor conectado' '" .. (monitor.name or "?") .. "' -t 3000")
  -- Re-aplicar monitors.lua (carrega rules pro novo monitor).
  hl.exec_cmd("hyprctl reload")
end)

hl.on("monitor.removed", function(monitor)
  hl.exec_cmd("notify-send -a hyprland 'Monitor removido' '" .. (monitor.name or "?") .. "' -t 3000")
end)

-- ─── Screenshare privacy indicator ────────────────────────────────────────
-- Avisa quando você começa/termina screencast (paranoid mode).

hl.on("screenshare.state", function(state)
  if state == "started" or state == true then
    hl.exec_cmd("notify-send -a hyprland -u critical 'Screensharing ATIVO' 'Pessoas podem estar vendo sua tela' -t 6000")
  elseif state == "stopped" or state == false then
    hl.exec_cmd("notify-send -a hyprland 'Screensharing parado' '' -t 2000")
  end
end)

-- ─── Config reload feedback ────────────────────────────────────────────────
-- Confirma que `hyprctl reload` funcionou (visual feedback).

hl.on("config.reloaded", function()
  hl.exec_cmd("notify-send -a hyprland 'Config reloaded' '' -t 1500")
end)

-- ─── Shutdown cleanup ─────────────────────────────────────────────────────
-- Mata daemons que não terminam sozinhos quando Hyprland sai
-- (evita processes órfãos em logout).

hl.on("hyprland.shutdown", function()
  hl.exec_cmd("pkill -TERM walker")
  hl.exec_cmd("systemctl --user stop elephant.service")
  hl.exec_cmd("pkill -TERM mako")
  hl.exec_cmd("pkill -TERM hypridle")
end)
