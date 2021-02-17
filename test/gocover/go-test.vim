scriptencoding utf-8

let s:suite = themis#suite('go')
let s:assert = themis#helper('assert')

let s:V = vital#gocover#new()
let s:Promise = s:V.import('Async.Promise')

function! s:suite.test_module_on_root()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg'
  let [l:result, l:err] = s:Promise.wait(gocover#go#__get_module(l:root_dir))
  call s:assert.equals(l:err, v:null)
  let [l:got_pkg, l:got_dir] = l:result
  call s:assert.equals(l:got_pkg, l:want_pkg)
  call s:assert.equals(l:got_dir, l:root_dir)
endfunction

function! s:suite.test_module_not_in_module()
  let l:root_dir = expand('<sfile>:p:h')
  let [l:result, l:err] = s:Promise.wait(gocover#go#__get_module(l:root_dir))
  call s:assert.equals(l:err, v:null)
  call s:assert.length_of(l:result, 0)
endfunction

function! s:suite.test_module_in_subdir()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg'

  let [l:result, l:err] = s:Promise.wait(gocover#go#__get_module(l:root_dir . '/child1'))
  call s:assert.equals(l:err, v:null)
  let [l:got_pkg, l:got_dir] = l:result
  call s:assert.equals(l:got_pkg, l:want_pkg)
  call s:assert.equals(l:got_dir, l:root_dir)
endfunction

function! s:suite.test_package_not_in_package()
  let l:root_dir = expand('<sfile>:p:h')
  let [l:got_pkg, l:err] = s:Promise.wait(gocover#go#__get_package(l:root_dir))
  call s:assert.equals(l:err, v:null)
  call s:assert.equals(l:got_pkg, '')
endfunction

function! s:suite.test_package_in_subdir()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let l:want_pkg = 'github.com/kyoh86/testpkg/child1'
  let [l:got_pkg, l:err] = s:Promise.wait(gocover#go#__get_package(l:root_dir . '/child1'))
  call s:assert.equals(l:err, v:null)
  call s:assert.equals(l:got_pkg, l:want_pkg)
endfunction

function! s:suite.test_package_notest()
  let l:root_dir = expand('<sfile>:p:h') . '/test/pkg'
  let [l:got_pkg, l:err] = s:Promise.wait(gocover#go#__get_package(l:root_dir . '/notest'))
  call s:assert.equals(l:err, v:null)
  call s:assert.same(l:got_pkg, '')
endfunction

function! s:suite.test_profile_simple()
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  let [l:result, l:err] = s:Promise.wait(gocover#go#__get_profile(l:pkg_dir))
  call s:assert.same(l:err, v:null, 'not error')
  call s:assert.not_empty(l:result, 'filled any')
endfunction

