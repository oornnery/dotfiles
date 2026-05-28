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
set noshowmode
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
nnoremap <leader>?       :Cheatsheet vim<CR>

command! -nargs=? Helpme call <SID>OpenHelpme(<q-args> ==# '' ? 'vim' : <q-args>)
command! -nargs=? Cheatsheet call <SID>OpenHelpme(<q-args> ==# '' ? 'vim' : <q-args>)

function! s:OpenHelpme(topic) abort
    let l:helper = expand('~/.local/bin/helpme')
    if !executable(l:helper)
        let l:helper = 'helpme'
    endif

    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted filetype=markdown
    silent execute 'read !' . shellescape(l:helper) . ' --no-pager ' . shellescape(a:topic)
    silent! 1delete _
    setlocal nomodifiable
    nnoremap <silent> <buffer> q :close<CR>
    normal! gg
endfunction

" ─── Statusline (native, no plugin) ────────────────────────────────────────

function! DotfilesStatusMode() abort
    let l:modes = {
        \ 'n': 'NORMAL',
        \ 'no': 'OP',
        \ 'v': 'VISUAL',
        \ 'V': 'V-LINE',
        \ "\<C-v>": 'V-BLOCK',
        \ 's': 'SELECT',
        \ 'S': 'S-LINE',
        \ "\<C-s>": 'S-BLOCK',
        \ 'i': 'INSERT',
        \ 'R': 'REPLACE',
        \ 'c': 'COMMAND',
        \ }
    return get(l:modes, mode(), toupper(mode()))
endfunction

function! DotfilesStatusText(text) abort
    return substitute(printf('%s', a:text), '%', '%%', 'g')
endfunction

function! DotfilesStatusFile() abort
    let l:file = expand('%:~:.')
    return empty(l:file) ? '[No Name]' : l:file
endfunction

function! DotfilesStatusFlags() abort
    let l:flags = ''
    let l:flags .= &modified ? '[+]' : ''
    let l:flags .= &readonly ? '[RO]' : ''
    let l:flags .= &buftype ==# 'help' ? '[help]' : ''
    let l:flags .= exists('&previewwindow') && &previewwindow ? '[preview]' : ''
    return empty(l:flags) ? '' : ' ' . DotfilesStatusText(l:flags) . ' '
endfunction

function! DotfilesStatusFiletype() abort
    return empty(&filetype) ? 'noft' : &filetype
endfunction

function! DotfilesStatusEncoding() abort
    return empty(&fileencoding) ? &encoding : &fileencoding
endfunction

function! DotfilesStatusPosition() abort
    return line('.') . ':' . col('.')
endfunction

function! DotfilesStatusPercent() abort
    return printf('%d%%', line('.') * 100 / line('$'))
endfunction

highlight default link DotfilesStatusMode StatusLine
highlight default link DotfilesStatusFile StatusLine
highlight default link DotfilesStatusInfo StatusLine
highlight default link DotfilesStatusMuted StatusLineNC
highlight default link DotfilesStatusAccent StatusLine

set laststatus=2
let &statusline = join([
        \ '%#DotfilesStatusMode# %{DotfilesStatusText(DotfilesStatusMode())} ',
        \ '%#DotfilesStatusFile# %{DotfilesStatusText(DotfilesStatusFile())} ',
        \ '%#DotfilesStatusMuted#%{DotfilesStatusFlags()}',
        \ '%=',
        \ '%#DotfilesStatusInfo# %{DotfilesStatusText(DotfilesStatusFiletype())} ',
        \ '%#DotfilesStatusFile# %{DotfilesStatusText(DotfilesStatusEncoding())} ',
        \ '%#DotfilesStatusMode# %{DotfilesStatusText(DotfilesStatusPosition())} ',
        \ '%#DotfilesStatusAccent# %{DotfilesStatusText(DotfilesStatusPercent())} ',
        \ ], '')

" Active theme drop-in written by the `theme` command.
" It is loaded after the statusline so it can override status colors.
if filereadable(expand('~/.vim/theme.vim'))
    source ~/.vim/theme.vim
endif
