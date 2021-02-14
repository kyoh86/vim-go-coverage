scriptencoding utf-8

let s:suite = themis#suite('store')
let s:assert = themis#helper('assert')

function! s:suite.test_store_simple()
  " FIXTURE (empty)
  call gocover#store#clear()

  " TEST (empty)
  let l:got = gocover#store#get('entry-1')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'null should be returned from empty store')

  " DO (put entry-1 -> {entry-1})
  call gocover#store#put('entry-1', 'entry-1-data')

  " TEST (find entry-1)
  let l:got = gocover#store#get('entry-1')
  let l:want = 'entry-1-data'
  call s:assert.equals(l:got, l:want, 'we can get a stored data')

  " TEST (find unknown: NOT FOUND)
  let l:got = gocover#store#get('unknown')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'we can NOT get a stored data with another key')

  " DO (put entry-2 -> {entry-1, entry-2})
  call gocover#store#put('entry-2', 'entry-2-data')

  " TEST (find entry-2)
  let l:got = gocover#store#get('entry-2')
  let l:want = 'entry-2-data'
  call s:assert.equals(l:got, l:want, 'we can get a new stored data')

  " TEST (find entry-1)
  let l:got = gocover#store#get('entry-1')
  let l:want = 'entry-1-data'
  call s:assert.equals(l:got, l:want, 'we can get an old stored data')

  " DO (truncate with size 1 -> {entry-2})
  let g:gocover_store_size = 1
  call gocover#store#truncate()

  " TEST (check paths)
  let l:got = gocover#store#paths()
  let l:want = ['entry-2']
  call s:assert.equals(l:got, l:want, 'truncated data should have newest paths')

  " DO (put entry-3 -> extruded, {entry-3})
  call gocover#store#put('entry-3', 'entry-3-data')

  " TEST (find entry-3: found)
  let l:got = gocover#store#paths()
  let l:want = ['entry-3']
  call s:assert.equals(l:got, l:want, 'extruded data should have newest paths')
endfunction

function! s:suite.test_store_update()
  " FIXTURE (size = 3, filled {entry-1, entry-2, entry-3})
  call gocover#store#clear()
  let g:gocover_store_size = 3
  call gocover#store#put('entry-1', 'entry-1-data')
  call gocover#store#put('entry-2', 'entry-2-data')
  call gocover#store#put('entry-3', 'entry-3-data')

  " CHECK (ordered)
  let l:got = gocover#store#paths()
  let l:want = ['entry-1', 'entry-2', 'entry-3']
  call s:assert.equals(l:got, l:want, 'failed to prepare fixture')

  " DO (update entry-1 -> {entry-2, entry-3, entry-1})
  call gocover#store#put('entry-1', 'entry-1-update')

  " TEST (check paths: order changed)
  let l:got = gocover#store#paths()
  let l:want = ['entry-2', 'entry-3', 'entry-1']
  call s:assert.equals(l:got, l:want, 'updated entry should be newest')

  " TEST (find entry-1: updated)
  let l:got = gocover#store#get('entry-1')
  let l:want = 'entry-1-update'
  call s:assert.equals(l:got, l:want, 'we can get an updated data')

  " TEST (find entry-3: found, not updated)
  let l:got = gocover#store#get('entry-3')
  let l:want = 'entry-3-data'
  call s:assert.equals(l:got, l:want, 'we can get an old data (first)')

  " DO (update entry-2 -> {entry-3, entry-1, entry-2})
  call gocover#store#put('entry-2', 'entry-2-update')

  " TEST (check paths: order changed overrapped)
  let l:got = gocover#store#paths()
  let l:want = ['entry-3', 'entry-1', 'entry-2']
  call s:assert.equals(l:got, l:want, 'more updated entry should be newest')

  " DO (overflow -> {entry-1, entry-2, entry-4})
  call gocover#store#put('entry-4', 'entry-4-data')
  "
  " TEST (find entry-1: updated)
  let l:got = gocover#store#get('entry-1')
  let l:want = 'entry-1-update'
  call s:assert.equals(l:got, l:want, 'we can get an old-updated data (unextruded)')

  " TEST (find entry-2: updated)
  let l:got = gocover#store#get('entry-2')
  let l:want = 'entry-2-update'
  call s:assert.equals(l:got, l:want, 'we can get an new-updated data (unextruded)')

  " TEST (find entry-3: NOT FOUND)
  let l:got = gocover#store#get('entry-3')
  let l:want = v:null
  call s:assert.equals(l:got, l:want, 'we can NOT get an extruded data')

  " TEST (find entry-4: found)
  let l:got = gocover#store#get('entry-4')
  let l:want = 'entry-4-data'
  call s:assert.equals(l:got, l:want, 'we can get a new data')
endfunction
