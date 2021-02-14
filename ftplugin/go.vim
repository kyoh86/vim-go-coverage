scriptencoding utf-8

" go.vim
"
" Prepare commands for go-coverage

" Take coverage in path of the current window.
"TODO: -complete
"TODO: -tags
"TODO: -run
command! -buffer GoCover         call gocover#cover_current()

" Clear coverage in path of the current window.
command! -buffer GoCoverClear    call gocover#clear_current()

" Clear all coverages.
command! -buffer GoCoverClearAll call gocover#clear_all()
