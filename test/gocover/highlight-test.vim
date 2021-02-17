let s:suite = themis#suite('highlight')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:funcs = s:scope.funcs('autoload/gocover/highlight.vim')

function! s:suite.test_highlight_apply_2_positions()
  let l:profile = [{
  \  'file': 'foo/bar.go',
  \  'positions': [1, 2],
  \  'cnt': 1,
  \}]
  let l:got = []
  call s:funcs.apply({group, pos -> add(l:got, pos)}, l:profile)
  call s:assert.equal(l:got, [[1, 2]])
endfunction

function! s:suite.test_highlight_apply_8_positions()
  let l:profile = [{
  \  'file': 'foo/bar.go',
  \  'positions': range(1, 8),
  \  'cnt': 1,
  \}]
  let l:got = []
  call s:funcs.apply({group, pos -> add(l:got, pos)}, l:profile)
  call s:assert.equal(l:got, [range(1, 8)])
endfunction

function! s:suite.test_highlight_apply_9_positions()
  let l:profile = [{
  \  'file': 'foo/bar.go',
  \  'positions': range(1, 9),
  \  'cnt': 1,
  \}]
  let l:got = []
  call s:funcs.apply({group, pos -> add(l:got, pos)}, l:profile)
  call s:assert.equal(l:got, [range(1, 8), [9]])
endfunction

function! s:suite.test_highlight_apply_16_positions()
  let l:profile = [{
  \  'file': 'foo/bar.go',
  \  'positions': range(1, 16),
  \  'cnt': 1,
  \}]
  let l:got = []
  call s:funcs.apply({group, pos -> add(l:got, pos)}, l:profile)
  call s:assert.equal(l:got, [range(1, 8), range(9, 16)])
endfunction

function! s:suite.test_highlight_apply_17_positions()
  let l:profile = [{
  \  'file': 'foo/bar.go',
  \  'positions': range(1, 17),
  \  'cnt': 1,
  \}]
  let l:got = []
  call s:funcs.apply({group, pos -> add(l:got, pos)}, l:profile)
  call s:assert.equal(l:got, [range(1, 8), range(9, 16), [17]])
endfunction
