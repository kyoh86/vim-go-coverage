" highlight.vim
"
" Highlight with a coverage profile parsed by gocover#profile#parse.
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

" Highlight the window ID as described in entry.
function! go#coverage#highlight(winid, entry) abort
  let l:winid = {'window': a:winid is 0 ? win_getid() : a:winid}

  let l:group = 'goCoverageCovered'
  if a:entry.cnt is 0
    let l:group = 'goCoverageUncovered'
  endif

  " Highlight entire lines, instead of starting at the first non-space
  " character.
  let l:startcol = a:entry.startcol
  if getline(a:entry.startline)[:l:startcol - 2] =~# '^\s*$'
    let l:startcol = 0
  endif

  " Single line.
  if a:entry.startline is# a:entry.endline
    call matchaddpos(l:group, [[a:entry.startline,
          \ l:startcol,
          \ a:entry.endcol - a:entry.startcol]],
          \ 10, -1, l:winid)
    return
  endif

  " First line.
  call matchaddpos(l:group, [[a:entry.startline, l:startcol,
        \ len(getline(a:entry.startline)) - l:startcol]],
        \ 10, -1, l:winid)

  " Fill lines in between.
  let l:l = a:entry.startline
  while l:l < a:entry.endline
    let l:l += 1
    call matchaddpos(l:group, [l:l], 10, -1, l:winid)
  endwhile

  " Last line.
  call matchaddpos(l:group, [[a:entry.endline, a:entry.endcol - 1]], 10, -1, l:winid)
endfunction
