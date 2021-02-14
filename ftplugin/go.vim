" Commands
" command! -cov-nargs=* -complete=customlist,go#coverage#complete GoCoverage call go#coverage#do(<f-args>)

" | Command          | Description                                   |
" | -                | -                                             |
" | :GoCover         | Take coverage in path of the current window.  |
" | :GoCoverClear    | Clear coverage in path of the current window. |
" | :GoCoverClearAll | Clear all coverages.                          |
"
command! -buffer GoCover         call gocover#cover_current()
command! -buffer GoCoverClear    call gocover#clear_current()
command! -buffer GoCoverClearAll call gocover#clear_all()
