scriptencoding utf-8

" highlight.vim
"
" Highlight with a coverage profile parsed by gocover#profile#parse.
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

""" Apply stored coverage for all windows
function! gocover#highlight#apply_all_windows() abort
  call gocover#view#each_windows(function('gocover#highlight#apply_win_id'))
endfunction

""" Collect informations for a window or the current window if 0,
"  and highlight it as possible by stored coverage.
function! gocover#highlight#apply_win_id(win_id) abort
  let l:win_id = a:win_id is 0 ? win_getid() : a:win_id

  call gocover#highlight#clear_win_id(l:win_id)

  let l:bufnr = winbufnr(l:win_id)
  let l:buftype = getbufvar(l:bufnr, '&buftype')
  if l:buftype !=# ''
    " A buffer which is not normal
    return
  endif

  let l:bufname = bufname(l:bufnr)
  if l:bufname[-3:] != '.go' || l:bufname[-8:] == '_test.go'
    " Not go file or the go-test file
    return
  endif

  let l:bufpath = fnamemodify(l:bufname, ':p')
  let l:bufdirpath = fnamemodify(l:bufpath, ':h')
  let l:profile = gocover#store#get(l:bufdirpath)
  if l:profile is# v:null
    " Not found coverages for the directory
    return
  endif

  let l:bufpackagefile = gocover#go#packagefile(l:bufpath)
  let l:bufprofile = get(l:profile, l:bufpackagefile, v:null)
  if l:bufprofile is# v:null
    " Not found coverages for the file
    return
  endif

  for l:entry in l:bufprofile
    let l:entry = s:fit_entry(l:bufnr, l:entry)
    if l:entry is# v:null
      continue
    endif
    call gocover#highlight#apply_entry(l:entry, function('gocover#view#matchadd', [l:win_id]))
  endfor
endfunction

""" Apply stored coverage for all windows
function! gocover#highlight#clear_all_windows() abort
  call gocover#view#each_windows(function('gocover#highlight#clear_win_id'))
endfunction

""" Clear coverage highlights for the given window, or the current window if 0.
function! gocover#highlight#clear_win_id(win_id) abort
  let l:win_id = a:win_id is 0 ? win_getid() : a:win_id

  for l:m in getmatches(l:win_id)
    if l:m.group is# 'goCoverageCovered' || l:m.group is# 'goCoverageUncovered'
      call matchdelete(l:m.id, l:win_id)
    endif
  endfor
endfun

""" Fix coverage profile positions to fit for a content of the buffer.
function! s:fit_entry(bufnr, entry) abort
  " Highlight entire lines, instead of starting at the first non-space
  " character.
  let l:lines = getbufline(a:bufnr, a:entry.startline)
  if len(l:lines) is 0
    return v:null
  endif
  let l:firstline = l:lines[0]
  if l:firstline[:a:entry.startcol - 2] =~# '^\s+$'
    let a:entry.startcol = 1
  endif

  " Highlight first-line to tail if the entry covers multiline.
  let a:entry.firsttail = a:entry.endcol
  if a:entry.endline > a:entry.startline
    let a:entry.firsttail = len(l:firstline)
  endif
  return a:entry
endfunction

""" Highlight as described in entry.
" @param entry The coverage entry for a file which
" @param matchadd A function to highlight with group and the position.
function! gocover#highlight#apply_entry(entry, matchadd) abort
  let l:group = 'goCoverageCovered'
  if a:entry.cnt is 0
    let l:group = 'goCoverageUncovered'
  endif

  " Highlight first-line.
  call a:matchadd(l:group, [[a:entry.startline, a:entry.startcol, a:entry.firsttail - a:entry.startcol]])

  if a:entry.startline is a:entry.endline
    return
  endif

  " Highlight lines in between.
  if a:entry.endline > a:entry.startline + 1
    let l:lines = []
    let l:l = a:entry.startline
    while l:l < a:entry.endline - 1
      let l:l += 1
      call add(l:lines, l:l)
    endwhile
    call a:matchadd(l:group, l:lines)
  endif

  " Highlight last line.
  call a:matchadd(l:group, [[a:entry.endline, 1, a:entry.endcol - 1]])
endfunction
