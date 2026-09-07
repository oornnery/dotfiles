" Native workflow regression checks, shared by Vim and Neovim.
call assert_equal('', v:errmsg, 'startup error')
call assert_equal(' ', g:mapleader)
call assert_equal($DOTFILES_EDITOR_EXPECT_BASIC ==# '1', g:dotfiles_basic_terminal ? 1 : 0)
call assert_equal(100, &ttimeoutlen)
for s:key in ['w', 'q', 'ff', 'fg', 'cf', 'rr', 'tt', 'e']
  call assert_notequal('', maparg(' ' . s:key, 'n'), 'missing leader ' . s:key)
endfor
if g:dotfiles_basic_terminal
  call assert_false(&termguicolors)
  call assert_equal('', &mouse)
  call assert_equal('> ', &listchars->split(',')->filter('v:val =~# "^tab:"')[0][4:])
endif

set noundofile nobackup nowritebackup noswapfile
execute 'edit ' . fnameescape($DOTFILES_EDITOR_FIXTURE . '/sub/sample.py')
setfiletype python
call assert_equal(4, &shiftwidth)
call setline(1, 'print("hello")')
normal gcc
call assert_match('^#', getline(1))
normal gcc
call assert_equal('print("hello")', getline(1))
Root
call assert_equal($DOTFILES_EDITOR_FIXTURE, getcwd())
Lexplore
call assert_equal('netrw', &filetype, 'native directory explorer')
" netrw's silent unmaps can leave E31 in v:errmsg without a command failure.
if !empty(v:errors)
  call writefile(v:errors, $DOTFILES_EDITOR_RESULT)
  cquit
endif
call writefile(['PASS'], $DOTFILES_EDITOR_RESULT)
qa!
