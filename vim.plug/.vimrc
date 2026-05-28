" ~/.vimrc
" Vim native base plus vim-plug plugin extras.

let s:dotfiles_dir = exists('$DOTFILES_DIR') && !empty($DOTFILES_DIR)
      \ ? $DOTFILES_DIR
      \ : expand('~/dotfiles')
let s:native_vimrc = s:dotfiles_dir . '/vim/.vimrc'

if filereadable(s:native_vimrc)
  execute 'source' fnameescape(s:native_vimrc)
else
  echohl WarningMsg
  echom 'native vim base not found: ' . s:native_vimrc
  echohl None
endif

" Auto-install vim-plug.
let s:plug = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug))
  silent execute '!curl -fLo ' . shellescape(s:plug) . ' --create-dirs '
        \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if filereadable(s:plug)
  call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-surround'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  call plug#end()
endif

" Extra plugin keymaps. Core mappings stay inherited from vim/.vimrc.
nnoremap <leader><space> :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :Rg<CR>
