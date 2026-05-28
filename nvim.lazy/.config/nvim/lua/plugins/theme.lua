local ok, theme = pcall(require, "theme")

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = ok and (theme.lazyvim_colorscheme or theme.colorscheme) or "habamax",
    },
  },
}
