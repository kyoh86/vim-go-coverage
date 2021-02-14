scriptencoding utf-8

let s:suite = themis#suite('go runtime')
let s:assert = themis#helper('assert')

function! s:suite.test_store_simple()
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/foo_test.go'
  execute 'new ' . l:pkg_dir . '/foo.go'

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equals(l:got, l:want)

  call gocover#clear_current()
  call assert_equal([], getmatches())
endfun
