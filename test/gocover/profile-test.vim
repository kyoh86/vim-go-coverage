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
  let l:profile = gocover#profile#__parse(l:raw_profile)
  call s:assert.equals(l:profile, {
    \   'env/parse.go': [{
    \     'file': 'env/parse.go',
    \     'positions': [
    \       [10, 3, 1000], 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    \       22, 23, 24, 25, 26, 27, 28, 29, 30, 31, [32, 1, 29],
    \     ],
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/parse.go',
    \     'positions': [
    \       [38, 2, 1000], 39, [40, 1, 14]
    \     ],
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/parse.go',
    \     'positions': [
    \       [48, 3, 1000], 49, 50, 51, [52, 1, 19],
    \     ],
    \     'cnt': 0,
    \   }],
    \   'env/serialize.go': [{
    \     'file': 'env/serialize.go',
    \     'positions': [
    \       [12, 3, 1000], 13, 14, 15, 16, 17, [18, 1, 17],
    \     ],
    \     'cnt': 1,
    \   }, {
    \     'file': 'env/serialize.go',
    \     'positions': [
    \       [48, 3, 1000], 49, 50, 51, [52, 1, 19],
    \     ],
    \     'cnt': 0,
    \   }],
    \ })
endfunction
