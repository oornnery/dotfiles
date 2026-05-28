" ~/.vimrc — vim (not neovim) config.
"
" Use case: emergency editor (sudoedit, recovery TTY, SSH to boxes without
" neovim). Neovim is the daily driver — see ~/.config/nvim/.

" ─── Auto-install vim-plug ─────────────────────────────────────────────────

let s:plug = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug))
    silent execute '!curl -fLo ' . s:plug . ' --create-dirs '
        \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ─── Plugins ───────────────────────────────────────────────────────────────

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'            " baseline modern defaults
Plug 'tpope/vim-commentary'          " gcc / gc{motion} toggle comment
Plug 'tpope/vim-surround'            " cs"' ds" ys{motion}{char}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'              " :Files :Buffers :Rg
call plug#end()

" ─── Options ───────────────────────────────────────────────────────────────

set nocompatible
set encoding=utf-8

" UI
set number relativenumber
set ruler showcmd
set cursorline
set scrolloff=4
set sidescrolloff=8
set wildmenu wildmode=longest:full,full

" Search
set incsearch hlsearch
set ignorecase smartcase

" Indent
filetype plugin indent on
set expandtab smarttab autoindent
set tabstop=4 softtabstop=4 shiftwidth=4

" Mouse + clipboard (system clipboard if compiled with +clipboard)
set mouse=a
if has('clipboard')
    set clipboard^=unnamed,unnamedplus
endif

" Buffers / files
set hidden                           " allow switching with unsaved changes
set autoread                         " reload externally-modified files
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undofile
set undodir=~/.vim/undo//
silent! call mkdir(expand('~/.vim/backup'), 'p')
silent! call mkdir(expand('~/.vim/swap'),   'p')
silent! call mkdir(expand('~/.vim/undo'),   'p')

" Performance
set lazyredraw
set ttyfast
set updatetime=300
set timeoutlen=500

" Splits
set splitright splitbelow

" Colors
syntax on
set background=dark
silent! colorscheme habamax            " ships with vim 9.x; falls back silently

" ─── Keymaps ───────────────────────────────────────────────────────────────

let mapleader = ','

" Save / quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Clear search highlight
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" Move between windows with Ctrl-h/j/k/l (matches tmux/vim-tmux-navigator).
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Visual indent keeps selection.
vnoremap < <gv
vnoremap > >gv

" fzf.vim bindings
nnoremap <leader><space> :Files<CR>
nnoremap <leader>b       :Buffers<CR>
nnoremap <leader>r       :Rg<CR>

" ─── Statusline (minimal) ──────────────────────────────────────────────────

set laststatus=2
set statusline=
set statusline+=%#PmenuSel#
set statusline+=\ %f                    " filename
set statusline+=\ %m%r%h%w              " modified/readonly flags
set statusline+=%=                      " right-align
set statusline+=\ %y                    " filetype
set statusline+=\ %l:%c                 " line:column
set statusline+=\ %p%%\                 " percent through file

" Active theme drop-in written by the `theme` command.
" It is loaded after the statusline so it can override status colors.
if filereadable(expand('~/.vim/theme.vim'))
    source ~/.vim/theme.vim
endif
