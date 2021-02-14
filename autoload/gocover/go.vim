scriptencoding utf-8

" go.vim
"
" Utilities for working with Go tools.
"
" Author: kyoh86<me@kyoh86.dev>
" License: MIT

let s:V = vital#gocover#new()
let s:Promise = s:V.import('Async.Promise')
let s:Process = s:V.import('Async.Promise.Process')

""" Exec command with the option (e.g. {'cwd': <working directory>})
function! s:exec(cmd, ...) abort
  let l:opt = {
        \   'reject_on_failure': v:true,
        \ }
  if len(a:000) > 0
    call extend(l:opt, a:1)
  endif
  return s:Promise.wait(s:Process.start(a:cmd, l:opt))
endfunction

""" Get the Go module name and the path, or empty if error.
function! gocover#go#module(dir) abort
  let [l:result, l:err] = s:exec(
        \ ['go', 'list', '-m', '-f', "{{.Path}}\x1F{{.Dir}}"],
        \ {'cwd': a:dir})
  if l:err isnot# v:null
    call gocover#view#error(join(l:err.stderr, '\n'))
    return []
  endif
  let l:terms = split(l:result.stdout[0], "\x1F")
  if len(l:terms) < 2
    return []
  endif
  return l:terms
endfunction

""" Get the package path for the dir or empty if error.
function! gocover#go#package(dir) abort
  let [l:result, l:err] = s:exec(['go', 'list', './'], {'cwd': a:dir})
  if l:err isnot# v:null
    call gocover#view#error(join(l:err.stderr, '\n'))
    return ''
  endif

  return l:result.stdout[0]
endfunction

""" Get path to file as package/path/file.go
function! gocover#go#packagefile(file) abort
  return gocover#go#package(fnamemodify(a:file, ':h')) . '/' . expand(fnamemodify(a:file, ':t'))
endfunction

""" Run a test and get raw coverage profile
function! gocover#go#profile(dir) abort
  let l:tmp = tempname()
  try
    let [l:result, l:err] = s:exec(
          \ ['go', 'test', '-coverprofile', l:tmp],
          \ {'cwd': a:dir})
    if l:err isnot# v:null
      call gocover#view#error(join(l:err.stderr, '\n'))
      return v:null
    endif

    let l:profile = readfile(l:tmp)
  finally
    call delete(l:tmp)
  endtry
  return l:profile
endfunction
