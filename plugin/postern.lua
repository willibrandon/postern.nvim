if vim.g.loaded_postern or vim.fn.has("nvim-0.11") == 0 then
  return
end
vim.g.loaded_postern = true

vim.lsp.enable("postern")
