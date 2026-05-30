-- ~/.config/hypr/lua/env.lua — variáveis de ambiente expostas a apps.
-- Equivalente a `env = NAME,VALUE` no .conf antigo.

hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- PATH: greetd/GDM inicia Hyprland com PATH minimal (sem ~/.local/bin).
-- Prepend pra que scripts de ~/.local/bin (dots,
-- etc) sejam encontrados nos exec_cmd dos binds.
hl.env("PATH",
  os.getenv("HOME") .. "/.local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
)
