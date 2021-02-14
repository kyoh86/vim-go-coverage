scriptencoding utf-8

let s:suite = themis#suite('go')
let s:assert = themis#helper('assert')

function! s:suite.test_module_on_root()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg'
  let [l:got_pkg, l:got_dir] = gocover#go#module(l:root_dir)
  call s:assert.equals(l:got_pkg, l:want_pkg)
  call s:assert.equals(l:got_dir, l:root_dir)
endfunction

function! s:suite.test_module_not_in_module()
  let l:root_dir = expand('<sfile>:p:h')
  let l:result = gocover#go#module(l:root_dir)
  call s:assert.length_of(l:result, 0)
endfunction

function! s:suite.test_module_in_subdir()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg'
  let [l:got_pkg, l:got_dir] = gocover#go#module(l:root_dir . '/child1')
  call s:assert.equals(l:got_pkg, l:want_pkg)
  call s:assert.equals(l:got_dir, l:root_dir)
endfunction

function! s:suite.test_package_not_in_package()
  let l:root_dir = expand('<sfile>:p:h')
  let l:result = gocover#go#package(l:root_dir)
  call s:assert.equals(l:result, '')
endfunction

function! s:suite.test_package_in_subdir()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg/child1'
  let l:got_pkg = gocover#go#package(l:root_dir . '/child1')
  call s:assert.equals(l:got_pkg, l:want_pkg)
endfunction

function! s:suite.test_profile_valid()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:got = gocover#go#profile(l:root_dir . '/child1')
  call s:assert.not_same(l:got, v:null)
endfunction

function! s:suite.test_profile_notest()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:got = gocover#go#profile(l:root_dir . '/notest')
  call s:assert.same(l:got, v:null)
endfunction
