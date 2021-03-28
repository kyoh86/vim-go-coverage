scriptencoding utf-8

" coverage.vim
"
" Implement entrypoints 
" 
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

""" Highlights.
function! s:highlight() abort
  if &background is# 'dark'
    highlight default goCoverageCovered   guibg=#005000 ctermbg=28
    highlight default goCoverageUncovered guibg=#500000 ctermbg=52
  else
    highlight default goCoverageCovered   guibg=#dfffdf ctermbg=120
    highlight default goCoverageUncovered guibg=#ffdfdf ctermbg=223
  endif
endfun
call s:highlight()
augroup gocover-colorscheme
  autocmd!
  autocmd ColorScheme * call s:highlight()
augroup END

""" Highlights added with matchadd() are set on the window, and not the buffer. So
" when switching windows we need to clear and reset this.
function! s:set_autocmd() abort
  augroup gocover-update
    autocmd!
    autocmd BufWinEnter *.go call gocover#highlight#update(win_getid())
    autocmd BufWinLeave *.go call gocover#highlight#clear(win_getid())
  augroup END
endfun

""" Highlights added with matchadd() are set on the window, and not the buffer. So
" when switching windows we need to clear and reset this.
function! s:unset_autocmd() abort
  augroup gocover-update
    autocmd!
  augroup END
endfun

""" Take coverage in the path.
function! gocover#cover(dir) abort
  return gocover#go#__get_profile(a:dir)
    \.then({ raw -> gocover#profile#__parse(raw) })
    \.then({ prof -> gocover#store#__put(a:dir, prof) })
    \.then({ -> gocover#highlight#update_dir(a:dir) })
    \.then({ -> s:set_autocmd() })
    \.then({ -> execute('redraw', '')})
endfunction

""" Take coverage in path of the current buffer.
function! gocover#cover_current() abort
  let l:dir = expand('%:p:h')
  return gocover#cover(l:dir)
endfunction

function! gocover#_cover_command(...) abort
  if a:0 is 0
    call gocover#cover_current()
  else
    for l:dir in a:000
      call gocover#cover(fnamemodify(l:dir, ':p'))
    endfor
  end
endfunction

""" Clear coverage in the path.
function! gocover#clear(dir) abort
  let l:deleted = gocover#store#__delete(a:dir)
  call gocover#highlight#update_dir(a:dir)
  if gocover#store#__len() is 0
    call s:unset_autocmd()
  endif
endfunction

""" Clear coverage in the path of the current buffer.
function! gocover#clear_current() abort
  let l:dir = expand('%:p:h')
  call gocover#clear(l:dir)
endfunction

function! gocover#_clear_command(...) abort
  if a:0 is 0
    call gocover#clear_current()
  else
    for l:dir in a:000
      call gocover#clear(fnamemodify(l:dir, ':p'))
    endfor
  end
endfunction

""" Clear all coverages.
function! gocover#clear_all() abort
  if gocover#store#__clear()
    call gocover#highlight#clear_all()
  endif
  call s:unset_autocmd()
endfunction
