-- ~/.config/hypr/hyprland.lua — entry point.
--
-- Hyprland 0.55+ usa Lua nativo. Este arquivo orquestra os módulos em lua/.
-- Antiga config hyprlang `.conf` ficou como .bak (pra fallback se precisar).
--
-- Para voltar pro .conf:  rm hyprland.lua; mv hyprland.conf.bak hyprland.conf
--                         (Hyprland prefere .lua se ambos existem)

local CFG = os.getenv("HOME") .. "/.config/hypr/lua/"

local function load(mod)
  local path = CFG .. mod .. ".lua"
  local ok, err = pcall(dofile, path)
  if not ok then
    -- Notifica erro sem travar o boot — outros módulos seguem.
    print("[hyprland.lua] ERRO em " .. mod .. ".lua: " .. tostring(err))
  end
end

-- Ordem importa: monitors antes de bindings (pra rules de scale),
-- general antes de animations (curves antes de uso).
load("env")
load("monitors")
load("general")
load("input")
load("autostart")
load("windowrules")
load("bindings")
load("events")  -- vazio por padrão; lugar pra hl.on() futuros
