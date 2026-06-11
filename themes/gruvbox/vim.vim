" Active theme: gruvbox
let g:dotfiles_theme = 'gruvbox'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#ebdbb2 guibg=#282828
highlight! NormalNC guifg=#ebdbb2 guibg=#282828
highlight! CursorLine guibg=#3c3836
highlight! LineNr guifg=#928374 guibg=#282828
highlight! CursorLineNr guifg=#d79921 guibg=#3c3836 gui=bold cterm=bold
highlight! SignColumn guifg=#928374 guibg=#282828
highlight! ColorColumn guibg=#3c3836
highlight! VertSplit guifg=#504945 guibg=#282828
highlight! WinSeparator guifg=#504945 guibg=#282828
highlight! StatusLine guifg=#282828 guibg=#d79921 gui=bold cterm=bold
highlight! StatusLineNC guifg=#928374 guibg=#3c3836
highlight! DotfilesStatusMode guifg=#282828 guibg=#d79921 gui=bold cterm=bold
highlight! DotfilesStatusFile guifg=#ebdbb2 guibg=#3c3836
highlight! DotfilesStatusInfo guifg=#282828 guibg=#83a598 gui=bold cterm=bold
highlight! DotfilesStatusMuted guifg=#928374 guibg=#3c3836
highlight! DotfilesStatusAccent guifg=#282828 guibg=#fabd2f gui=bold cterm=bold
highlight! Pmenu guifg=#ebdbb2 guibg=#3c3836
highlight! PmenuSel guifg=#282828 guibg=#d79921 gui=bold cterm=bold
highlight! Visual guibg=#504945
highlight! Search guifg=#282828 guibg=#fabd2f gui=bold cterm=bold
highlight! IncSearch guifg=#282828 guibg=#d79921 gui=bold cterm=bold
highlight! ErrorMsg guifg=#fb4934 guibg=#282828
highlight! WarningMsg guifg=#fabd2f guibg=#282828
