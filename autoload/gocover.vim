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
function! gocover#cover(args, dir) abort
  return gocover#go#__get_profile(a:args, a:dir)
    \.then({ raw -> gocover#profile#__parse(raw) })
    \.then({ prof -> gocover#store#__put(a:dir, prof) })
    \.then({ -> gocover#highlight#update_dir(a:dir) })
    \.then({ -> s:set_autocmd() })
    \.then({ -> execute('redraw', '')})
endfunction

""" Take coverage in path of the current buffer.
function! gocover#cover_current(args) abort
  let l:dir = expand('%:p:h')
  return gocover#cover(a:args, l:dir)
endfunction

function! gocover#_cover_command(...) abort
  let l:args = []
  let l:tags = []
  let l:tags_index = -2
  let l:i = 0
  for l:arg in a:000
    if l:arg ==# '-tags'
      let l:tags_index = l:i
      let l:tags = add(l:tags, l:arg)
    elseif l:i is l:tags_index + 1
      let l:tags = add(l:tags, l:arg)
    else
      let l:args = add(l:args, l:arg)
    endif
    let l:i = l:i + 1
  endfor
  if len(l:args) is 0
    call gocover#cover_current(l:tags)
  else
    for l:dir in a:000
      call gocover#cover(l:tags, fnamemodify(l:dir, ':p'))
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

function! gocover#complete(lead, cmdline, cursor) abort
  " return gopher#compl#filter(a:lead, ['clear', 'toggle', '-run', '-race', '-tags'])
  if a:lead ==# ''
    if a:cmdline =~# '-tags \+$'
      return gocover#tags#find('%')
    end
    let l:dirs = filter(globpath('.', '*', v:true, v:true), {_, v -> isdirectory(v)})
    if a:cmdline =~# ' -tags '
      return l:dirs
    end
    return ['-tags'] + l:dirs
  elseif '-tags' =~# '^' .. a:lead
    return ['-tags']
  elseif split(a:cmdline, ' \+')[-2] ==# '-tags'
    if a:lead =~# ',$'
      let l:used = {}
      for l:u in split(a:lead, ',')
        let l:used[l:u] = v:true
      endfor
      return map(filter(gocover#tags#find('%'), {_, v -> get(l:used, v, v:false) isnot# v:true}), {_, v -> a:lead .. v})
    else
      return filter(gocover#tags#find('%'), {_, v -> v =~# '^' .. a:lead})
    end
  else
    return filter(globpath('.', '*', v:true, v:true), {_, v -> isdirectory(v) && v =~# '^' .. a:lead})
  endif
endfunction
