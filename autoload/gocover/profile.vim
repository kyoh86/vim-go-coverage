scriptencoding utf-8

" profile.vim
"
" Parse go test coverage raw profile.
"
" Author: kyoh86
" License: MIT

""" Parse the coverage profile lines.
function! gocover#profile#parse(raw_profile) abort
  let l:profile = {}
  for l:line in a:raw_profile[1:] " NOTE: 0th line is a modeline i.e. 'mode: xxx'
    let l:cov = s:parse_profile_line(l:line)
    if !has_key(l:profile, l:cov.file)
      let l:profile[l:cov.file] = []
    endif
    call add(l:profile[l:cov.file], l:cov)
  endfor
  return l:profile
endfunction

""" Parses a single line in to a dict.
"
" The format of a line is:
"   <package>/<file>.go:<startline>.<col>,<endline>.<col> <numstmt> <count>
"
" For example:
"   github.com/kyoh86/testpkg/child1/foo.go:3.28,5.2 1 1
function! s:parse_profile_line(line) abort
  let l:m = matchlist(a:line, '\v([^:]+):(\d+)\.(\d+),(\d+)\.(\d+) (\d+) (\d+)')
  return {
    \ 'file':      l:m[1],
    \ 'startline': str2nr(l:m[2]),
    \ 'startcol':  str2nr(l:m[3]),
    \ 'endline':   str2nr(l:m[4]),
    \ 'endcol':    str2nr(l:m[5]),
    \ 'numstmt':   str2nr(l:m[6]),
    \ 'cnt':       str2nr(l:m[7]),
    \ }
endfunction
