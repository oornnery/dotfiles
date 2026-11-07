-- ~/.config/hypr/hyprland.lua — entry point.
--
-- Hyprland 0.55+ uses native Lua. This file loads the modules in lua/.
--
--                         (Hyprland prefere .lua se ambos existem)

local CFG = os.getenv("HOME") .. "/.config/hypr/lua/"

local function load(mod)
  local path = CFG .. mod .. ".lua"
  local ok, err = pcall(dofile, path)
  if not ok then
    -- Report the error without blocking startup; the other modules still load.
    print("[hyprland.lua] ERRO em " .. mod .. ".lua: " .. tostring(err))
  end
end

-- Order matters: monitors before bindings (for scale rules),
-- general before animations (curves before they are used).
load("env")
load("monitors")
load("general")
load("input")
load("autostart")
load("windowrules")
load("bindings")
load("events")  -- hl.on() event handlers
