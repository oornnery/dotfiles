" Active theme: kanagawa
let g:dotfiles_theme = 'kanagawa'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#dcd7ba guibg=#1f1f28
highlight! NormalNC guifg=#dcd7ba guibg=#1f1f28
highlight! CursorLine guibg=#2a2a37
highlight! LineNr guifg=#727169 guibg=#1f1f28
highlight! CursorLineNr guifg=#7e9cd8 guibg=#2a2a37 gui=bold cterm=bold
highlight! SignColumn guifg=#727169 guibg=#1f1f28
highlight! ColorColumn guibg=#2a2a37
highlight! VertSplit guifg=#54546d guibg=#1f1f28
highlight! WinSeparator guifg=#54546d guibg=#1f1f28
highlight! StatusLine guifg=#1f1f28 guibg=#7e9cd8 gui=bold cterm=bold
highlight! StatusLineNC guifg=#727169 guibg=#2a2a37
highlight! DotfilesStatusMode guifg=#1f1f28 guibg=#7e9cd8 gui=bold cterm=bold
highlight! DotfilesStatusFile guifg=#dcd7ba guibg=#2a2a37
highlight! DotfilesStatusInfo guifg=#1f1f28 guibg=#98bb6c gui=bold cterm=bold
highlight! DotfilesStatusMuted guifg=#727169 guibg=#2a2a37
highlight! DotfilesStatusAccent guifg=#1f1f28 guibg=#e6c384 gui=bold cterm=bold
highlight! Pmenu guifg=#dcd7ba guibg=#2a2a37
highlight! PmenuSel guifg=#1f1f28 guibg=#7e9cd8 gui=bold cterm=bold
highlight! Visual guibg=#54546d
highlight! Search guifg=#1f1f28 guibg=#e6c384 gui=bold cterm=bold
highlight! IncSearch guifg=#1f1f28 guibg=#7e9cd8 gui=bold cterm=bold
highlight! ErrorMsg guifg=#c34043 guibg=#1f1f28
highlight! WarningMsg guifg=#e6c384 guibg=#1f1f28
