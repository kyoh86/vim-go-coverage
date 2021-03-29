" Find the build tags for the buffer; returns a list.
function! gocover#tags#find(bufnr) abort
  for l:line in getbufline(a:bufnr, 1, 100)
    if l:line =~# '^// +build '
      return uniq(sort(flatten(map(split(l:line[10:], ' '), {_, v -> split(v, ',')}))))
    endif
    if l:line =~# '^package \f'
      return []
    endif
  endfor
  return []
endfun
