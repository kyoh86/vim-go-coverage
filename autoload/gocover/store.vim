" store.vim
"
" An implementation for the rolling stored map.
"
" For store coverage profile for each path.
" Put a profile with #put(path, profile) and get it with #get(path).
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

let s:store = {}
let s:oldest = v:null
let s:newest = v:null

function! gocover#store#get(path)
  """ get stored profile
  return get(get(s:store, a:path, {}), 'coverage')
endfunction

function! gocover#store#truncate()
  """ truncate stored profile with uplimit `g:gocover_store_size` (default: 10)
  while s:oldest isnot# v:null && len(s:store) > get(g:, 'gocover_store_size', 10)
    let l:next = s:store[s:oldest].next
    call remove(s:store, s:oldest)
    let s:oldest = l:next
  endwhile
endfunction

function! gocover#store#put(path, coverage)
  """ store profile with the key (a:path)
  if s:oldest is# v:null || s:newest is# v:null
    let s:oldest = a:path
    let s:newest = a:path
  else
    let s:store[s:newest].next = a:path
  endif
  let s:store[a:path] = {'next': v:null, 'coverage': a:coverage}
  let s:newest = a:path

  call gocover#store#truncate()
endfunction

function! gocover#store#clear()
  """ clear all stored profile
  let s:store = {}
  let s:oldest = v:null
  let s:newest = v:null
endfunction
