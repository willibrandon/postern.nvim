" Vim's conf syntax fits these files: comments, keys and quoted values.
if exists("b:current_syntax")
  finish
endif
runtime! syntax/conf.vim
let b:current_syntax = "pg-ident"
