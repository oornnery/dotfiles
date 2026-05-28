" Active theme: rose-pine
let g:dotfiles_theme = 'rose-pine'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#e0def4 guibg=#191724
highlight! NormalNC guifg=#e0def4 guibg=#191724
highlight! CursorLine guibg=#26233a
highlight! LineNr guifg=#6e6a86 guibg=#191724
highlight! CursorLineNr guifg=#c4a7e7 guibg=#26233a gui=bold cterm=bold
highlight! SignColumn guifg=#6e6a86 guibg=#191724
highlight! ColorColumn guibg=#26233a
highlight! VertSplit guifg=#403d52 guibg=#191724
highlight! WinSeparator guifg=#403d52 guibg=#191724
highlight! StatusLine guifg=#191724 guibg=#c4a7e7 gui=bold cterm=bold
highlight! StatusLineNC guifg=#6e6a86 guibg=#26233a
highlight! Pmenu guifg=#e0def4 guibg=#26233a
highlight! PmenuSel guifg=#191724 guibg=#c4a7e7 gui=bold cterm=bold
highlight! Visual guibg=#403d52
highlight! Search guifg=#191724 guibg=#f6c177 gui=bold cterm=bold
highlight! IncSearch guifg=#191724 guibg=#c4a7e7 gui=bold cterm=bold
highlight! ErrorMsg guifg=#eb6f92 guibg=#191724
highlight! WarningMsg guifg=#f6c177 guibg=#191724
