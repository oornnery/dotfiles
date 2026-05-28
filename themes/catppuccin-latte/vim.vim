" Active theme: catppuccin-latte
let g:dotfiles_theme = 'catppuccin-latte'
set background=light
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

highlight! Normal guifg=#4c4f69 guibg=#eff1f5
highlight! NormalNC guifg=#4c4f69 guibg=#eff1f5
highlight! CursorLine guibg=#e6e9ef
highlight! LineNr guifg=#8c8fa1 guibg=#eff1f5
highlight! CursorLineNr guifg=#8839ef guibg=#e6e9ef gui=bold cterm=bold
highlight! SignColumn guifg=#8c8fa1 guibg=#eff1f5
highlight! ColorColumn guibg=#e6e9ef
highlight! VertSplit guifg=#ccd0da guibg=#eff1f5
highlight! WinSeparator guifg=#ccd0da guibg=#eff1f5
highlight! StatusLine guifg=#eff1f5 guibg=#8839ef gui=bold cterm=bold
highlight! StatusLineNC guifg=#8c8fa1 guibg=#e6e9ef
highlight! Pmenu guifg=#4c4f69 guibg=#e6e9ef
highlight! PmenuSel guifg=#eff1f5 guibg=#8839ef gui=bold cterm=bold
highlight! Visual guibg=#ccd0da
highlight! Search guifg=#eff1f5 guibg=#df8e1d gui=bold cterm=bold
highlight! IncSearch guifg=#eff1f5 guibg=#8839ef gui=bold cterm=bold
highlight! ErrorMsg guifg=#d20f39 guibg=#eff1f5
highlight! WarningMsg guifg=#df8e1d guibg=#eff1f5
