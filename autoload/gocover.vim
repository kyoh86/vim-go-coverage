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
    autocmd BufWinEnter,BufWinLeave *.go call gocover#highlight#update(win_getid())
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
  let l:raw_profile = gocover#go#__get_profile(a:dir)
  if l:raw_profile is# v:null
    return
  endif
  let l:profile = gocover#profile#__parse(l:raw_profile)
  call gocover#store#__put(a:dir, l:profile)
  call gocover#highlight#update_dir(a:dir)
  call s:set_autocmd()
endfunction

""" Take coverage in path of the current buffer.
function! gocover#cover_current() abort
  let l:dir = expand('%:p:h')
  call gocover#cover(l:dir)
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

""" Clear all coverages.
function! gocover#clear_all() abort
  if gocover#store#__clear()
    call gocover#highlight#update_all()
  endif
  call s:unset_autocmd()
endfunction
