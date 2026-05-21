-- ~/.config/nvim/lua/plugins/cursor-effects.lua
-- Smooth cursor trail effect (sphamba/smear-cursor.nvim).
--
-- Renders a smear/trail behind the cursor as it moves across the buffer.
-- Disabled in TTY (needs a GUI/terminal with good redraw).

return {
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      -- 80% trail length (1.0 = full smear, 0.0 = no smear)
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      -- Smear opacity (lower = subtler)
      trailing_exponent = 0,
      distance_stop_animating = 0.5,
      -- Hide normal cursor while smearing — gives the clean rolling-bubble look
      hide_target_hack = false,
      -- Skip the smear on huge jumps (>2 screens) — looks weird otherwise
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      smear_insert_mode = true,
    },
  },
}
