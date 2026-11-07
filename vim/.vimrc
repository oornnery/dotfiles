" ~/.vimrc
" Kept for machines with only vim; not linked by default (dots stow vim).
" No plugins. Same behaviour and Space keys as the Helix config.
set nocompatible
filetype plugin indent on
syntax enable
silent! colorscheme habamax
let mapleader = " "

" Look
set number relativenumber cursorline laststatus=2 showcmd
set scrolloff=8 splitright splitbelow nowrap
set list listchars=tab:»\ ,trail:·,nbsp:␣
if has('termguicolors') | set termguicolors | endif

" Editing
set expandtab tabstop=2 softtabstop=2 shiftwidth=2 autoindent smartindent
set backspace=indent,eol,start hidden autoread confirm mouse=a
set ignorecase smartcase incsearch hlsearch
set wildmenu wildmode=longest:full,full path+=**
set wildignore+=*/.git/*,*/node_modules/*,*/.venv/*,*/target/*
set updatetime=300 ttimeout ttimeoutlen=100

" Undo and swap outside the project
set undofile undodir=~/.vim/undo// directory=~/.vim/swap//
silent! call mkdir(expand('~/.vim/undo'), 'p')
silent! call mkdir(expand('~/.vim/swap'), 'p')
if has('clipboard') | set clipboard^=unnamedplus | endif

" Built-ins: file explorer (Space e) and gc to comment (vim 9.1+)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
silent! packadd comment

" Same keys as Helix
nnoremap <leader><leader> :find<Space>
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>e :Explore<CR>
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
xnoremap < <gv
xnoremap > >gv

" Back to the last position when opening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute "normal! g`\"" | endif

" Written by dots theme.
silent! source ~/.vim/theme.vim
