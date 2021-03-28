scriptencoding utf-8

" highlight.vim
"
" Highlight with a coverage profile parsed by gocover#profile#__parse.
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

""" Apply stored coverage for all windows
function! gocover#highlight#update_all() abort
  call gocover#view#__each_windows(function('gocover#highlight#update'))
endfunction

""" Apply stored coverage for all windows which in the dir
function! gocover#highlight#update_dir(dirpath) abort
  call gocover#view#__each_windows(function('s:update', [a:dirpath]))
endfunction

""" Collect informations for a window and highlight it as possible by stored coverage.
" Applying on current window, you must get win_id by `win_getid()`.
function! gocover#highlight#update(win_id) abort
  call s:update('', a:win_id)
endfunction

function! s:update(dirpath, win_id) abort
  let l:bufnr = winbufnr(a:win_id)
  if getbufvar(l:bufnr, '&buftype') !=# ''
    " A buffer which is not normal: clear
    call gocover#highlight#clear(a:win_id)
    return
  endif

  let l:bufname = bufname(l:bufnr)
  if l:bufname[-3:] != '.go' || l:bufname[-8:] == '_test.go'
    " Not go file or the go-test file: clear
    call gocover#highlight#clear(a:win_id)
    return
  endif

  let l:bufpath = fnamemodify(l:bufname, ':p')
  let l:bufdirpath = fnamemodify(l:bufpath, ':h:p')
  if a:dirpath !=# '' && a:dirpath !=# l:bufdirpath
    " Not match for the directory path : NOOP
    return
  endif

  call gocover#highlight#clear(a:win_id)

  let l:profile = gocover#store#__get(l:bufdirpath)
  if l:profile is# v:null
    " Not found coverages for the directory
    return
  endif

  return gocover#go#__get_package_file(l:bufpath)
    \.then({ file -> get(l:profile, file, v:null) })
    \.then(function('s:apply', [function('gocover#view#__matchaddpos', [a:win_id])]))
endfunction

""" Clear coverage highlights for all windows.
function! gocover#highlight#clear_all() abort
  call gocover#view#__each_windows(function('gocover#highlight#clear'))
endfunction

""" Clear coverage highlights for the given window.
" Clearing on current window, you must get win_id by `win_getid()`.
function! gocover#highlight#clear(win_id) abort
  for l:m in getmatches(a:win_id)
    if l:m.group is# 'goCoverageCovered' || l:m.group is# 'goCoverageUncovered'
      call matchdelete(l:m.id, a:win_id)
    endif
  endfor
endfun

""" Highlight as described in profile.
" @param matchaddpos A function to highlight with group and the position.
"                    Usualy we should pass `gocover#view#__matchaddpos` bound win_id.
" @param profile The coverage profile for a file which
function! s:apply(matchaddpos, profile) abort
  if a:profile is# v:null
    return
  endif
  for l:entry in a:profile
    let l:group = 'goCoverageCovered'
    if l:entry.cnt is 0
      let l:group = 'goCoverageUncovered'
    endif

    " matchaddpos accepts max 8 positions at once.
    for l:i in range(0, len(l:entry.positions), 8)
      let l:pos = l:entry.positions[l:i : l:i+7]
      if len(l:pos) is 0
        break
      endif
      call a:matchaddpos(l:group, l:pos)
    endfor
  endfor
endfunction
