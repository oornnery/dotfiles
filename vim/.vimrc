" ~/.vimrc
" Vim native-only setup: no vim-plug, no external plugins.
" Goal: solid emergency/daily Vim using only built-in features.

set nocompatible
scriptencoding utf-8

" Leader ----------------------------------------------------------------------
let mapleader = " "
let maplocalleader = "\\"

" Built-in runtime plugins ----------------------------------------------------
filetype plugin indent on
syntax enable
silent! packadd matchit

" netrw: built-in file explorer ----------------------------------------------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 28
let g:netrw_altv = 1
let g:netrw_keepdir = 0

" UI --------------------------------------------------------------------------
set encoding=utf-8
set number relativenumber
set cursorline
set ruler showcmd
set noshowmode
set laststatus=2
set scrolloff=8
set sidescrolloff=8
set splitright splitbelow
set pumheight=12
set wildmenu
set wildmode=longest:full,full
set list
set listchars=tab:»\ ,trail:·,nbsp:␣,extends:›,precedes:‹
set colorcolumn=100
set nowrap
set linebreak
set breakindent
if exists('+signcolumn')
  set signcolumn=yes
endif
if has('termguicolors')
  set termguicolors
endif
silent! colorscheme habamax

" Editing ---------------------------------------------------------------------
set expandtab smarttab autoindent smartindent
set tabstop=2 softtabstop=2 shiftwidth=2 shiftround
set backspace=indent,eol,start
set formatoptions-=o
set formatoptions+=j

" Search ----------------------------------------------------------------------
set ignorecase smartcase
set incsearch hlsearch

" Completion / command line ---------------------------------------------------
set completeopt=menuone,noselect
set path+=**
set wildignore+=*/.git/*,*/node_modules/*,*/.venv/*,*/venv/*,*/target/*,*/dist/*,*/build/*,*.pyc,*.o,*.a,*.so

" Files / persistence ---------------------------------------------------------
set hidden
set autoread
set confirm
set undofile
set backup
set writebackup
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set undodir=~/.vim/undo//
silent! call mkdir(expand('~/.vim/swap'), 'p')
silent! call mkdir(expand('~/.vim/backup'), 'p')
silent! call mkdir(expand('~/.vim/undo'), 'p')

" Clipboard: only when Vim was compiled with support.
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

" Performance / behavior ------------------------------------------------------
set updatetime=300
set timeoutlen=500
set ttyfast

" Spelling: enable per filetype below.
set spelllang=en_us,pt_br

" Statusline: native, no plugin ----------------------------------------------
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
        \ 't': 'TERMINAL',
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

" Commands --------------------------------------------------------------------
command! TrimWhitespace call <SID>TrimTrailingWhitespace()
command! -nargs=1 Search execute 'silent! vimgrep /' . escape(<q-args>, '/\') . '/gj **/*' | copen
command! Term botright split | resize 14 | terminal
command! MkSession mksession! .session.vim
command! LoadSession source .session.vim
command! -nargs=? Helpme call <SID>OpenHelpme(<q-args> ==# '' ? 'vim' : <q-args>)
command! -nargs=? Cheatsheet call <SID>OpenHelpme(<q-args> ==# '' ? 'vim' : <q-args>)

" Keymaps ---------------------------------------------------------------------
" Files / write / quit
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>e :Lexplore<CR>
nnoremap <leader>E :Explore<CR>
nnoremap <leader>ff :find<Space>
nnoremap <leader>sg :Search<Space>

" Buffers / quickfix
nnoremap <leader>bb :ls<CR>:buffer<Space>
nnoremap <leader>bd :bdelete<CR>
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>

" Windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <leader>= <C-w>=

" Editing
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap <silent> gcc :<C-u>call <SID>ToggleComment(line('.'), line('.'))<CR>
xnoremap <silent> gc :<C-u>call <SID>ToggleComment(line("'<"), line("'>"))<CR>
xnoremap < <gv
xnoremap > >gv
nnoremap <leader>f gg=G``
xnoremap <leader>f =
nnoremap <leader>tw :setlocal wrap!<CR>
nnoremap <leader>ts :setlocal spell!<CR>
nnoremap <leader>? :Cheatsheet vim<CR>

" Terminal
nnoremap <leader>tt :Term<CR>
tnoremap <Esc><Esc> <C-\><C-n>

" Functions -------------------------------------------------------------------
function! s:TrimTrailingWhitespace() abort
  if index(['markdown', 'text', 'gitcommit'], &filetype) >= 0
    return
  endif
  let l:view = winsaveview()
  silent! keeppatterns %s/\s\+$//e
  call winrestview(l:view)
endfunction

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

function! s:CommentParts() abort
  let l:cs = &commentstring
  if empty(l:cs) || l:cs !~# '%s'
    let l:fallback = {
          \ 'vim': '" %s',
          \ 'lua': '-- %s',
          \ 'python': '# %s',
          \ 'sh': '# %s',
          \ 'bash': '# %s',
          \ 'zsh': '# %s',
          \ 'conf': '# %s',
          \ 'dosini': '# %s',
          \ 'yaml': '# %s',
          \ 'toml': '# %s',
          \ 'rust': '// %s',
          \ 'go': '// %s',
          \ 'javascript': '// %s',
          \ 'typescript': '// %s',
          \ 'jsonc': '// %s',
          \ 'c': '// %s',
          \ 'cpp': '// %s',
          \ 'css': '/* %s */',
          \ 'html': '<!-- %s -->',
          \ 'markdown': '<!-- %s -->',
          \ }
    let l:cs = get(l:fallback, &filetype, '# %s')
  endif
  let l:parts = split(l:cs, '\V%s', 1)
  return [get(l:parts, 0, '# '), get(l:parts, 1, '')]
endfunction

function! s:EscPattern(text) abort
  return escape(a:text, '\.^$*[]~')
endfunction

function! s:IsCommented(line, left, right) abort
  if empty(a:left)
    return 0
  endif
  let l:body = substitute(a:line, '^\s*', '', '')
  if l:body !~# '^' . s:EscPattern(a:left)
    return 0
  endif
  if !empty(a:right) && l:body !~# s:EscPattern(a:right) . '\s*$'
    return 0
  endif
  return 1
endfunction

function! s:ToggleComment(first, last) abort
  let [l:left, l:right] = s:CommentParts()
  let l:all_commented = 1

  for lnum in range(a:first, a:last)
    let l:line = getline(lnum)
    if l:line =~# '^\s*$'
      continue
    endif
    if !s:IsCommented(l:line, l:left, l:right)
      let l:all_commented = 0
      break
    endif
  endfor

  for lnum in range(a:first, a:last)
    let l:line = getline(lnum)
    if l:line =~# '^\s*$'
      continue
    endif

    let l:indent = matchstr(l:line, '^\s*')
    let l:body = substitute(l:line, '^\s*', '', '')

    if l:all_commented
      let l:body = substitute(l:body, '^' . s:EscPattern(l:left), '', '')
      if !empty(l:right)
        let l:body = substitute(l:body, '\s*' . s:EscPattern(l:right) . '\s*$', '', '')
      endif
      call setline(lnum, l:indent . l:body)
    else
      if !empty(l:right)
        call setline(lnum, l:indent . l:left . l:body . l:right)
      else
        call setline(lnum, l:indent . l:left . l:body)
      endif
    endif
  endfor
endfunction

" Autocommands ----------------------------------------------------------------
augroup native_config
  autocmd!

  autocmd BufWritePre * call <SID>TrimTrailingWhitespace()

  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"' | endif

  autocmd FileType markdown,text,gitcommit setlocal wrap linebreak spell textwidth=100
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType go,make setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

  if exists('##TerminalOpen')
    autocmd TerminalOpen * setlocal nonumber norelativenumber signcolumn=no
  endif
augroup END
