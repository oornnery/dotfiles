" Active theme: tokyo-night
let g:dotfiles_theme = 'tokyo-night'
set background=dark
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#c0caf5 guibg=#1a1b26
highlight! NormalNC guifg=#c0caf5 guibg=#1a1b26
highlight! CursorLine guibg=#24283b
highlight! LineNr guifg=#565f89 guibg=#1a1b26
highlight! CursorLineNr guifg=#7aa2f7 guibg=#24283b gui=bold cterm=bold
highlight! SignColumn guifg=#565f89 guibg=#1a1b26
highlight! ColorColumn guibg=#24283b
highlight! VertSplit guifg=#414868 guibg=#1a1b26
highlight! WinSeparator guifg=#414868 guibg=#1a1b26
highlight! StatusLine guifg=#1a1b26 guibg=#7aa2f7 gui=bold cterm=bold
highlight! StatusLineNC guifg=#565f89 guibg=#24283b
highlight! DotfilesStatusMode guifg=#1a1b26 guibg=#7aa2f7 gui=bold cterm=bold
highlight! DotfilesStatusFile guifg=#c0caf5 guibg=#24283b
highlight! DotfilesStatusInfo guifg=#1a1b26 guibg=#7dcfff gui=bold cterm=bold
highlight! DotfilesStatusMuted guifg=#565f89 guibg=#24283b
highlight! DotfilesStatusAccent guifg=#1a1b26 guibg=#e0af68 gui=bold cterm=bold
highlight! Pmenu guifg=#c0caf5 guibg=#24283b
highlight! PmenuSel guifg=#1a1b26 guibg=#7aa2f7 gui=bold cterm=bold
highlight! Visual guibg=#414868
highlight! Search guifg=#1a1b26 guibg=#e0af68 gui=bold cterm=bold
highlight! IncSearch guifg=#1a1b26 guibg=#7aa2f7 gui=bold cterm=bold
highlight! ErrorMsg guifg=#f7768e guibg=#1a1b26
highlight! WarningMsg guifg=#e0af68 guibg=#1a1b26
