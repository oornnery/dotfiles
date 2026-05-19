-- ~/.config/hypr/lua/monitors.lua — layout de monitores.
-- hot-swap: edite e rode `hyprctl reload`.
--
-- Cheat-sheet hl.monitor():
--   output    = "eDP-1" | "HDMI-A-1" | ""              ("" = fallback)
--   mode      = "1920x1080@60" | "preferred" | "highres"
--   position  = "0x0" | "auto" | "1600x0"
--   scale     = 1.0 | 1.2 | "auto"
--   transform = 0..7 (rotação)
--   mirror    = "eDP-1"

-- VAIO display interno.
hl.monitor({
  output   = "eDP-1",
  mode     = "preferred",
  position = "0x0",
  scale    = 1.2,
})

-- HDMI externo à direita do eDP-1, escala 1.
hl.monitor({
  output   = "HDMI-A-1",
  mode     = "preferred",
  position = "1600x0",
  scale    = 1,
})

-- Fallback pra qualquer outro monitor conectado.
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = 1,
})
