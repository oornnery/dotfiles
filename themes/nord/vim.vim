" Active theme: nord
let g:dotfiles_theme = 'nord'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#d8dee9 guibg=#2e3440
highlight! NormalNC guifg=#d8dee9 guibg=#2e3440
highlight! CursorLine guibg=#3b4252
highlight! LineNr guifg=#4c566a guibg=#2e3440
highlight! CursorLineNr guifg=#88c0d0 guibg=#3b4252 gui=bold cterm=bold
highlight! SignColumn guifg=#4c566a guibg=#2e3440
highlight! ColorColumn guibg=#3b4252
highlight! VertSplit guifg=#434c5e guibg=#2e3440
highlight! WinSeparator guifg=#434c5e guibg=#2e3440
highlight! StatusLine guifg=#2e3440 guibg=#88c0d0 gui=bold cterm=bold
highlight! StatusLineNC guifg=#4c566a guibg=#3b4252
highlight! DotfilesStatusMode guifg=#2e3440 guibg=#88c0d0 gui=bold cterm=bold
highlight! DotfilesStatusFile guifg=#d8dee9 guibg=#3b4252
highlight! DotfilesStatusInfo guifg=#2e3440 guibg=#81a1c1 gui=bold cterm=bold
highlight! DotfilesStatusMuted guifg=#4c566a guibg=#3b4252
highlight! DotfilesStatusAccent guifg=#2e3440 guibg=#ebcb8b gui=bold cterm=bold
highlight! Pmenu guifg=#d8dee9 guibg=#3b4252
highlight! PmenuSel guifg=#2e3440 guibg=#88c0d0 gui=bold cterm=bold
highlight! Visual guibg=#434c5e
highlight! Search guifg=#2e3440 guibg=#ebcb8b gui=bold cterm=bold
highlight! IncSearch guifg=#2e3440 guibg=#88c0d0 gui=bold cterm=bold
highlight! ErrorMsg guifg=#bf616a guibg=#2e3440
highlight! WarningMsg guifg=#ebcb8b guibg=#2e3440
