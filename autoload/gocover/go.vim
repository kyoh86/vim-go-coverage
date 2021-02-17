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
  return s:Process.start(a:cmd, l:opt)
endfunction

""" Report error when the exec failed.
" You can use it with `Promise.catch`.
function! s:report_error(alt, err) abort
  call gocover#view#__error(join(a:err.stderr, '\n'))
  return a:alt
endfunction

""" Get the Go module name and the path, or empty if error.
function! gocover#go#__get_module(dir) abort
  return s:exec(
    \ ['go', 'list', '-m', '-f', "{{.Path}}\x1F{{.Dir}}"],
    \ {'cwd': a:dir})
    \.then(function('s:parse_module'))
    \.catch(function('s:report_error', [[]]))
endfunction

function! s:parse_module(res)
  let l:terms = split(a:res.stdout[0], "\x1F")
  if len(l:terms) < 2
    return []
  endif
  return l:terms
endfunction

""" Get the package path for the dir or empty if error.
function! gocover#go#__get_package(dir) abort
  return s:exec(['go', 'list', './'], {'cwd': a:dir})
    \.then({res -> res.stdout[0]})
    \.catch(function('s:report_error', ['']))
endfunction

""" Get path to file as package/path/file.go
function! gocover#go#__get_package_file(file) abort
  return gocover#go#__get_package(fnamemodify(a:file, ':h'))
    \.then({pkg -> pkg . '/' . expand(fnamemodify(a:file, ':t'))})
endfunction

""" Run a test and get raw coverage profile
function! gocover#go#__get_profile(dir) abort
  let l:tmp = tempname()
  return s:exec(
        \ ['go', 'test', '-coverprofile', l:tmp],
        \ {'cwd': a:dir})
        \.then({ -> readfile(l:tmp) }, function('s:report_error', [v:null]))
        \.finally({ -> delete(l:tmp) })
endfunction
