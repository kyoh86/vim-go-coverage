" view.vim
"
" Manage views (tabs, windows).
"
" Author: kyoh86 <me@kyoh86.dev>
" License: MIT

""" Shorthand for matchaddpos
function! gocover#view#matchadd(win_id, group, pos) abort
  call matchaddpos(a:group, a:pos, 10, -1, {'window': a:win_id})
endfunction

""" Enumerate windows in all of tabpages.
" @param f handle a win_id.
function! gocover#view#each_windows(f) abort
  for l:tabnr in range(1, tabpagenr('$'))
    for l:winnr in range (1, tabpagewinnr(l:tabnr, '$'))
      let l:win_id = win_getid(l:winnr, l:tabnr)
      call a:f(l:win_id)
    endfor
  endfor
endfunction
