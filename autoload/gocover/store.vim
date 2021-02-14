scriptencoding utf-8

" store.vim
"
" An implementation for the rolling stored map.
"
" It stores coverage profile for each path.
" Put a profile with #put(path, profile) and get it with #get(path).
" When the number of the paths exceed `g:cover_store_size`, oldest profiles are dropped.
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

let s:store = {}
let s:oldest_path = v:null
let s:newest_path = v:null

""" Get stored profile
function! gocover#store#get(path) abort
  return get(get(s:store, a:path, {}), 'coverage', v:null)
endfunction

""" Truncate stored profile with uplimit `g:gocover_store_size` (default: 10)
function! gocover#store#truncate() abort
  while s:oldest_path isnot# v:null && len(s:store) > get(g:, 'gocover_store_size', 10)
    let l:next = s:store[s:oldest_path].next_path
    call remove(s:store, s:oldest_path)
    let s:oldest_path = l:next
  endwhile
  if s:oldest_path isnot# v:null
    let s:store[s:oldest_path].prev_path = v:null
  endif
endfunction

""" Store profile with the key (a:path)
function! gocover#store#put(path, coverage) abort
  call gocover#store#delete(a:path) " for overwritten

  if s:oldest_path is# v:null || s:newest_path is# v:null
    let s:oldest_path = a:path
    let s:newest_path = a:path
  else
    let s:store[s:newest_path].next_path = a:path
  endif
  let s:store[a:path] = {
    \ 'next_path': v:null,
    \ 'prev_path': s:newest_path,
    \ 'coverage': a:coverage,
    \ }
  let s:newest_path = a:path

  call gocover#store#truncate()
endfunction

""" Clear all stored profile
function! gocover#store#clear() abort
  if len(s:store) is 0
    return v:false
  endif

  let s:store = {}
  let s:oldest_path = v:null
  let s:newest_path = v:null
  return v:true
endfunction

""" Retrieve stored paths (for test)
function! gocover#store#paths() abort
  let l:paths = []
  let l:path = s:oldest_path
  while l:path isnot# v:null
    call add(l:paths, l:path)
    let l:path = s:store[l:path].next_path
  endwhile
  return l:paths
endfunction

""" Delete profile for the key (a:path)
function! gocover#store#delete(path) abort
  if !has_key(s:store, a:path)
    return v:false
  endif

  let l:target = s:store[a:path]
  if s:oldest_path ==# a:path
    let s:oldest_path = l:target.next_path
  endif
  if s:newest_path ==# a:path
    let s:newest_path = l:target.prev_path
  endif
  if l:target.prev_path isnot# v:null
    let s:store[l:target.prev_path].next_path = l:target.next_path
  endif
  if l:target.next_path isnot# v:null
    let s:store[l:target.next_path].prev_path = l:target.prev_path
  endif
  call remove(s:store, a:path)

  return v:true
endfunction

""" Count paths
function! gocover#store#len() abort
  return len(s:store)
endfunction
