scriptencoding utf-8

" go.vim
"
" Prepare commands for go-coverage

" Take coverage in path of the current window.
"TODO: -tags
command! -buffer -nargs=* GoCover       call gocover#_cover_command(<f-args>)

" Clear coverage in path of the current window.
command! -buffer -nargs=* GoCoverClear call gocover#_clear_command(<f-args>)

" Clear all coverages.
command! -buffer GoCoverClearAll       call gocover#clear_all()
