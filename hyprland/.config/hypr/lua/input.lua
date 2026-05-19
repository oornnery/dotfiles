-- ~/.config/hypr/lua/input.lua — input + gestures + per-device.

hl.config({
  input = {
    kb_layout  = "us,br",
    kb_variant = ",abnt2",
    kb_model   = "",
    kb_options = "grp:alt_shift_toggle",
    kb_rules   = "",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
})

-- Gestures: 3-finger horizontal swipe → muda workspace.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device config (exemplo — adapte conforme seus dispositivos).
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})
