scriptencoding utf-8

let s:suite = themis#suite('e2e')
let s:assert = themis#helper('assert')

let s:V = vital#gocover#new()
let s:Promise = s:V.import('Async.Promise')

function! s:suite.test_simple()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/success_test.go'
  execute 'new ' . l:pkg_dir . '/success.go'

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)

  call gocover#clear_current()
  call s:assert.equal(getmatches(), [])
endfunction

function! s:suite.test_samedir_otherwin()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/success.go'
  let l:target_win_id = win_getid()
  execute 'new ' . l:pkg_dir . '/success_test.go'
  let l:test_win_id = win_getid()

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
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
  execute 'new ' . l:pkg_dir . '/success.go'
  let l:target_win_id = win_getid()
  execute 'tabnew ' . l:pkg_dir . '/success_test.go'
  let l:other_win_id = win_getid()

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
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
  execute 'new ' . l:other_pkg_dir . '/success.go'
  let l:other_win_id = win_getid()

  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'new ' . l:pkg_dir . '/success.go'
  let l:target_win_id = win_getid()

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(l:target_win_id), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
  call s:assert.equal(getmatches(l:other_win_id), [], 'uncovered')

  call gocover#clear_current()
  call s:assert.equal(getmatches(l:target_win_id), [])
endfunction

function! s:suite.test_clear_on_edit()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'edit ' . l:pkg_dir . '/success.go'

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)

  execute 'edit ' . l:pkg_dir . '/success_test.go'
  call s:assert.equal(getmatches(), [])
endfunction

function! s:suite.test_cover_on_reopen()
  bufdo! bwipeout!
  let l:pkg_dir = expand('<sfile>:p:h') . '/test/pkg/child2'
  execute 'edit ' . l:pkg_dir . '/success.go'
  execute 'edit ' . l:pkg_dir . '/success_test.go'
  execute 'edit ' . l:pkg_dir . '/success.go'

  let [_, l:err] = s:Promise.wait(gocover#cover_current([]))
  call s:assert.same(l:err, v:null)
  sleep 100m

  let l:want = [
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [5, 10, 20]},
        \ {'group': 'goCoverageUncovered', 'priority': 10, 'pos1': [6, 11, 1]},
        \ {'group': 'goCoverageCovered',   'priority': 10, 'pos1': [7, 10, 1000], 'pos2': [8], 'pos3': [9, 1, 1]}]
  " Remove id as it's not stable.
  let l:got = map(getmatches(), {i, v -> remove(l:v, 'id') is '' ? {} : l:v })

  call s:assert.equal(l:got, l:want)
endfunction
