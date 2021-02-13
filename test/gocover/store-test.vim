let s:suite = themis#suite('go runtime')
let s:assert = themis#helper('assert')

function! s:suite.test_store()
  call gocover#store#clear()

  " TEST
  let l:got = gocover#store#get('foo')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'null should be returned from empty store')

  " DO
  call gocover#store#put('foo', 'foo-data')

  " TEST
  let l:got = gocover#store#get('foo')
  let l:want = 'foo-data'
  call s:assert.equals(l:got, l:want, 'we can get a stored data')

  " TEST
  let l:got = gocover#store#get('bar')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'we can NOT get a stored data with another key')

  " DO
  call gocover#store#put('bar', 'bar-data')

  " TEST
  let l:got = gocover#store#get('bar')
  let l:want = 'bar-data'
  call s:assert.equals(l:got, l:want, 'we can get a new stored data')

  " TEST
  let l:got = gocover#store#get('foo')
  let l:want = 'foo-data'
  call s:assert.equals(l:got, l:want, 'we can get an old stored data')

  " DO
  let g:gocover_store_size = 1
  call gocover#store#truncate()

  " TEST
  let l:got = gocover#store#get('foo')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'we can NOT get a truncated data')

  " TEST
  let l:got = gocover#store#get('bar')
  let l:want = 'bar-data'
  call s:assert.equals(l:got, l:want, 'we can get a not-truncated data')

  " DO
  call gocover#store#put('baz', 'baz-data')

  " TEST
  let l:got = gocover#store#get('baz')
  let l:want = 'baz-data'
  call s:assert.equals(l:got, l:want, 'we can get a new stored data')

  " TEST
  let l:got = gocover#store#get('bar')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'we can NOT get an extruded data')
endfunction
