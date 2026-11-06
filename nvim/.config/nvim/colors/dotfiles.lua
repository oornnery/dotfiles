local ok, theme = pcall(require, "theme")

if ok and type(theme) == "table" and type(theme.apply) == "function" then
  theme.apply()
end
