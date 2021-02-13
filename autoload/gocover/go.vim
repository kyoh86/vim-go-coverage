" go.vim
"
" Utilities for working with Go tools.
"
" Author: kyoh86 <me@kyoh86.dev>
" License: MIT

let s:V = vital#gocover#new()
let s:Promise = s:V.import('Async.Promise')
let s:Process = s:V.import('Async.Promise.Process')

function! s:exec(cmd, ...)
  """ Exec command with the option (e.g. {'cwd': <working directory>})
  let l:opt = {
        \   'reject_on_failure': v:true,
        \ }
  if len(a:000) > 0
    call extend(l:opt, a:1)
  endif
  return s:Promise.wait(s:Process.start(a:cmd, l:opt))
endfunction

function! gocover#go#module(dir) abort
  """ Get the Go module name and the path, or empty if error.
  let [l:result, l:err] = s:exec(
        \ ['go', 'list', '-m', '-f', "{{.Path}}\x1F{{.Dir}}"],
        \ {'cwd': a:dir})
  if l:err isnot# v:null
    " TODO: msgerr l:err.stderr
    return []
  endif
  let l:terms = split(l:result.stdout[0], "\x1F")
  if len(l:terms) < 2
    return []
  endif
  return l:terms
endfunction

function! gocover#go#package(dir) abort
  " Get the package path for the dir or empty if error.
  let [l:result, l:err] = s:exec(['go', 'list', './'], {'cwd': a:dir})
  echo l:result
  echo l:err
  if l:err isnot# v:null
    " TODO: msgerr l:err.stderr
    return ''
  endif

  return l:result.stdout[0]
endfunction

function! gocover#go#packagefile(file) abort
  " Get path to file as package/path/file.go
  return gocover#go#package(fnamemodify(a:file, ':h')) . '/' . expand(fnamemodify(a:file, ':t'))
endfunction

"TODO: receive build tags from... caller
function! gocover#go#coverprofile(dir) abort
  " Run a test and collect coverage profile
  let l:tmp = tempname()
  try
    let [l:result, l:err] = s:exec(
          \ ['go', 'test', '-coverprofile', l:tmp],
          \ {'cwd': a:dir})
    if l:err isnot# v:null
      " TODO: msgerr l:err.stderr
      return v:null
    endif

    let l:profile = readfile(l:tmp)
  finally
    call delete(l:tmp)
  endtry
  return l:profile
endfunction

" let s:go_commands = ['go', 'bug', 'build', 'clean', 'doc', 'env', 'fix', 'fmt',
"                    \ 'generate', 'get', 'install', 'list', 'mod', 'run', 'test',
"                    \ 'tool', 'version', 'vet']
" 
" " Add b:go_coverage_build_tags or g:go_coverage_build_tags to the flag_list; will be
" " merged with existing tags (if any).
" function! gocover#go#add_build_tags(flag_list) abort
"   if get(g:, 'go_coverage_build_tags', []) == []
"     return a:flag_list
"   endif
" 
"   if type(a:flag_list) isnot v:t_list
"     call go#coverage#msg#error('add_build_tags: not a list: %s', a:flag_list)
"     return a:flag_list
"   endif
" 
"   let l:tags = go#coverage#bufsetting('go_coverage_build_tags', [])
" 
"   let l:last_flag = 0
"   for l:i in range(len(a:flag_list))
"     if a:flag_list[l:i][0] is# '-' || index(s:go_commands, a:flag_list[l:i]) > -1
"       let l:last_flag = l:i
"     endif
" 
"     if a:flag_list[l:i] is# '-tags'
"       let l:tags = uniq(split(trim(a:flag_list[l:i+1], "\"'"), ',') + l:tags)
"       return a:flag_list[:l:i]
"             \ + ['"' . join(l:tags, ' ') . '"']
"             \ +  a:flag_list[l:i+2:]
"     endif
"   endfor
" 
"   return a:flag_list[:l:last_flag]
"         \ + ['-tags', '"' . join(l:tags, ',') . '"']
"         \ + a:flag_list[l:last_flag+1:]
" endfunction
" 
" " Find the build tags for the current buffer; returns a list (or empty list if
" " there are none).
" function! gocover#go#find_build_tags() abort
"   " https://golang.org/pkg/go/build/#hdr-Build_Constraints
"   for l:i in range(1, line('$'))
"     let l:line = getline(l:i)
"     if l:line =~# '^// +build '
"       return uniq(sort(go#coverage#list#flatten(map(split(l:line[10:], ' '), {_, v -> split(v, ',')}))))
"     endif
" 
"     if l:line =~# '^package \f'
"       return []
"     endif
"   endfor
" 
"   return []
" endfunction
" 
" " Set b:go_coverage_build_package to ./cmd/[module-name] if it exists.
" function! gocover#go#set_build_package() abort
"   if &buftype isnot# '' || &filetype isnot# 'go'
"     return
"   endif
" 
"   if go#coverage#bufsetting('go_coverage_build_package', '') isnot ''
"     return
"   endif
" 
"   " TODO: maybe cache this a bit? Don't need to do it for every buffer in the
"   " same directory.
"   let [l:module, l:modpath] = gocover#go#module()
"   if l:module is# -1
"     return
"   endif
" 
"   let l:name = fnamemodify(l:module, ':t')
"   let l:pkg  = l:module  . '/cmd/' . l:name
"   let l:path = l:modpath . '/cmd/' . l:name
" 
"   " We're already in (possible a different) ./cmd/<name> subpackage: use this
"   " one instead of clobbering ./cmd/other with ./cmd/main
"   if go#coverage#str#has_prefix(bufname(''), 'cmd/')
"     let b:go_coverage_build_package = l:module . '/' . fnamemodify(bufname(''), ':h')
"     compiler go
"     return
"   endif
" 
"   if isdirectory(l:path) && get(b:, 'go_coverage_build_package', '') isnot# l:pkg
"     let b:go_coverage_build_package = l:pkg
"     compiler go
"   endif
" endfunction
" 
" " Set b:go_coverage_build_tags to the build tags in the current buffer.
" function! gocover#go#set_build_tags() abort
"   if &buftype isnot# '' || &filetype isnot# 'go'
"     return
"   endif
" 
"   " TODO: be even smarter about this: merge the g: and b: vars, and allow
"   " setting a special '%BUFFER%' so you can both set tags from vimrc and merge
"   " from file.
"   if len(go#coverage#bufsetting('go_coverage_build_tags', '')) > 0
"     return
"   endif
" 
"   let l:tags = gocover#go#find_build_tags()
"   if l:tags != get(b:, 'go_coverage_build_tags', [])
"     let b:go_coverage_build_tags = l:tags
"     compiler go
"   endif
" endfunction
