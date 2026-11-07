-- ~/.config/hypr/lua/env.lua — environment variables for apps.
-- Equivalente a `env = NAME,VALUE` no .conf antigo.

hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- PATH: greetd and GDM start Hyprland with a minimal PATH (no ~/.local/bin).
-- Prepend it so scripts in ~/.local/bin (dots,
-- etc) are found by the exec_cmd in binds.
hl.env("PATH",
  os.getenv("HOME") .. "/.local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
)
