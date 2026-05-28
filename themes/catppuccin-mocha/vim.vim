" Active theme: catppuccin-mocha
let g:dotfiles_theme = 'catppuccin-mocha'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#cdd6f4 guibg=#1e1e2e
highlight! NormalNC guifg=#cdd6f4 guibg=#1e1e2e
highlight! CursorLine guibg=#313244
highlight! LineNr guifg=#6c7086 guibg=#1e1e2e
highlight! CursorLineNr guifg=#f5c2e7 guibg=#313244 gui=bold cterm=bold
highlight! SignColumn guifg=#6c7086 guibg=#1e1e2e
highlight! ColorColumn guibg=#313244
highlight! VertSplit guifg=#45475a guibg=#1e1e2e
highlight! WinSeparator guifg=#45475a guibg=#1e1e2e
highlight! StatusLine guifg=#1e1e2e guibg=#f5c2e7 gui=bold cterm=bold
highlight! StatusLineNC guifg=#6c7086 guibg=#313244
highlight! Pmenu guifg=#cdd6f4 guibg=#313244
highlight! PmenuSel guifg=#1e1e2e guibg=#f5c2e7 gui=bold cterm=bold
highlight! Visual guibg=#45475a
highlight! Search guifg=#1e1e2e guibg=#f9e2af gui=bold cterm=bold
highlight! IncSearch guifg=#1e1e2e guibg=#f5c2e7 gui=bold cterm=bold
highlight! ErrorMsg guifg=#f38ba8 guibg=#1e1e2e
highlight! WarningMsg guifg=#f9e2af guibg=#1e1e2e
