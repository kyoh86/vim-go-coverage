let s:suite = themis#suite('profile')
let s:assert = themis#helper('assert')

function! s:suite.test_profile_parse()
  let l:raw_profile = [
    \ 'mode: set',
    \ 'env/parse.go:10.3,32.30 1 1',
    \ 'env/parse.go:38.2,40.15 1 1',
    \ 'env/parse.go:48.3,52.20 0 0',
    \ 'env/serialize.go:12.3,18.18 1 1',
    \ 'env/serialize.go:48.3,52.20 0 0',
    \ ]
  let l:profile = gocover#profile#parse(l:raw_profile)
  call s:assert.equals(l:profile, {
    \   'env/parse.go': [{
    \     'file': 'env/parse.go',
    \     'startline': 10,
    \     'startcol': 3,
    \     'endline': 32,
    \     'endcol': 30,
    \     'numstmt': 1,
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/parse.go',
    \     'startline': 38,
    \     'startcol': 2,
    \     'endline': 40,
    \     'endcol': 15,
    \     'numstmt': 1,
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/parse.go',
    \     'startline': 48,
    \     'startcol': 3,
    \     'endline': 52,
    \     'endcol': 20,
    \     'numstmt': 0,
    \     'cnt': 0,
    \   }],
    \   'env/serialize.go': [{
    \     'file': 'env/serialize.go',
    \     'startline': 12,
    \     'startcol': 3,
    \     'endline': 18,
    \     'endcol': 18,
    \     'numstmt': 1,
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/serialize.go',
    \     'startline': 48,
    \     'startcol': 3,
    \     'endline': 52,
    \     'endcol': 20,
    \     'numstmt': 0,
    \     'cnt': 0,
    \   }],
    \ })
endfunction
