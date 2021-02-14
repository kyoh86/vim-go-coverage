scriptencoding utf-8

let s:suite = themis#suite('e2e')
let s:assert = themis#helper('assert')

function! s:suite.test_simple()
  bufdo! bwipeout!
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

  call s:assert.equal(l:got, l:want)

  call gocover#clear_current()
  call s:assert.equal(getmatches(), [])
endfunction

function! s:suite.test_samedir_otherwin()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/foo.go'
  let l:target_win_id = win_getid()
  execute 'new ' . l:pkg_dir . '/foo_test.go'
  let l:test_win_id = win_getid()

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(l:target_win_id), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
  call s:assert.equal(getmatches(l:test_win_id), [])

  call gocover#clear_current()
  call s:assert.equal(getmatches(l:target_win_id), [])
endfunction

function! s:suite.test_samedir_othertab()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/foo.go'
  let l:target_win_id = win_getid()
  execute 'tabnew ' . l:pkg_dir . '/foo_test.go'
  let l:other_win_id = win_getid()

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(l:target_win_id), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
  call s:assert.equal(getmatches(l:other_win_id), [])

  call gocover#clear_current()
  call s:assert.equal(getmatches(l:target_win_id), [])
endfunction

function! s:suite.test_otherdir()
  bufdo! bwipeout!
  let l:other_pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child1'
  execute 'new ' . l:other_pkg_dir . '/foo.go'
  let l:other_win_id = win_getid()

  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/foo.go'
  let l:target_win_id = win_getid()

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(l:target_win_id), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
  call s:assert.equal(getmatches(l:other_win_id), [], 'uncovered')

  call gocover#clear_current()
  call s:assert.equal(getmatches(l:target_win_id), [])
endfunction

function! s:suite.test_buffer_shortage()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'edit ' . l:pkg_dir . '/foo.go'
  7,9delete

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)

  call gocover#clear_current()
  call s:assert.equal(getmatches(), [])
endfunction

function! s:suite.test_clear_on_edit()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'edit ' . l:pkg_dir . '/foo.go'

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)

  execute 'edit ' . l:pkg_dir . '/foo_test.go'
  call s:assert.equal(getmatches(), [])
endfunction

function! s:suite.test_cover_on_reopen()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'edit ' . l:pkg_dir . '/foo.go'
  execute 'edit ' . l:pkg_dir . '/foo_test.go'
  execute 'edit ' . l:pkg_dir . '/foo.go'

  call gocover#cover_current()

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 0]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [8]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
endfunction
