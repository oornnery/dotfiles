-- ~/.config/hypr/lua/monitors.lua — monitor layout.
-- hot-swap: edite e rode `hyprctl reload`.
--
-- Cheat-sheet hl.monitor():
--   output    = "eDP-1" | "HDMI-A-1" | ""              ("" = fallback)
--   mode      = "1920x1080@60" | "preferred" | "highres"
--   position  = "0x0" | "auto" | "1600x0"
--   scale     = 1.0 | 1.2 | "auto"
--   transform = 0..7 (rotation)
--   mirror    = "eDP-1"

-- VAIO display interno.
hl.monitor({
  output   = "eDP-1",
  mode     = "preferred",
  position = "0x0",
  scale    = 1.2,
})

-- External HDMI. `position = "auto"` lets Hyprland work out the position
-- from the current eDP-1 scale (avoids a fixed "1600x0", which
-- breaks when the internal scale changes).
hl.monitor({
  output   = "HDMI-A-1",
  mode     = "preferred",
  position = "auto",
  scale    = 1,
})

-- Fallback for any other connected monitor.
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = 1,
})
