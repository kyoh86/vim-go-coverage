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

function! s:normalize_path(path)
  let l:path = fnamemodify(simplify(a:path), ':p')
  if has("win16") || has("win32") || has("win64")
    let l:path = substitute(l:path, '/\\\+$', '', '')
  elseif l:path ==# '/'
    return l:path
  else
    let l:path = substitute(l:path, '/\+$', '', '')
  endif
  return l:path
endfunction

""" Get stored profile
function! gocover#store#__get(path) abort
  return get(get(s:store, s:normalize_path(a:path), {}), 'coverage', v:null)
endfunction

""" Truncate stored profile with uplimit `g:gocover_store_size` (default: 10)
function! gocover#store#__truncate() abort
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
function! gocover#store#__put(path, coverage) abort
  let l:path = s:normalize_path(a:path)
  call gocover#store#__delete(l:path) " for overwritten

  if s:oldest_path is# v:null || s:newest_path is# v:null
    let s:oldest_path = l:path
    let s:newest_path = l:path
  else
    let s:store[s:newest_path].next_path = l:path
  endif
  let s:store[l:path] = {
    \ 'next_path': v:null,
    \ 'prev_path': s:newest_path,
    \ 'coverage': a:coverage,
    \ }
  let s:newest_path = l:path

  call gocover#store#__truncate()
endfunction

""" Clear all stored profile
function! gocover#store#__clear() abort
  if len(s:store) is 0
    return v:false
  endif

  let s:store = {}
  let s:oldest_path = v:null
  let s:newest_path = v:null
  return v:true
endfunction

""" Retrieve stored paths (for test)
function! gocover#store#__paths() abort
  let l:paths = []
  let l:path = s:oldest_path
  while l:path isnot# v:null
    call add(l:paths, l:path)
    let l:path = s:store[l:path].next_path
  endwhile
  return l:paths
endfunction

""" Delete profile for the key (a:path)
function! gocover#store#__delete(path) abort
  let l:path = s:normalize_path(a:path)
  if !has_key(s:store, l:path)
    return v:false
  endif

  let l:target = s:store[l:path]
  if s:oldest_path ==# l:path
    let s:oldest_path = l:target.next_path
  endif
  if s:newest_path ==# l:path
    let s:newest_path = l:target.prev_path
  endif
  if l:target.prev_path isnot# v:null
    let s:store[l:target.prev_path].next_path = l:target.next_path
  endif
  if l:target.next_path isnot# v:null
    let s:store[l:target.next_path].prev_path = l:target.prev_path
  endif
  call remove(s:store, l:path)

  return v:true
endfunction

""" Count paths
function! gocover#store#__len() abort
  return len(s:store)
endfunction
