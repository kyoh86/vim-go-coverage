scriptencoding utf-8

" view.vim
"
" Manage views (tabs, windows, messages).
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

""" Shorthand for matchaddpos
function! gocover#view#__matchaddpos(win_id, group, pos) abort
  call matchaddpos(a:group, a:pos, 10, -1, {'window': a:win_id})
endfunction

""" Enumerate windows in all of tabpages.
" @param f handle a win_id.
function! gocover#view#__each_windows(f) abort
  for l:tabnr in range(1, tabpagenr('$'))
    for l:winnr in range (1, tabpagewinnr(l:tabnr, '$'))
      let l:win_id = win_getid(l:winnr, l:tabnr)
      call a:f(l:win_id)
    endfor
  endfor
endfunction

""" Echo messages as debug level.
function! gocover#view#__debug(s) abort
  if &verbose is 0
    return
  endif
  echohl None | echomsg a:s
endfunction

""" Echo messages as info level.
function! gocover#view#__info(s) abort
  echohl None | echomsg a:s
endfunction

""" Echo messages as warning level.
function! gocover#view#__warning(s) abort
  echohl WarningMsg | echomsg a:s | echohl None
endfunction

""" Echo messages as error level.
function! gocover#view#__error(s) abort
  echohl ErrorMsg | echomsg a:s | echohl None
endfunction
