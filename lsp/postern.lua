-- Postern language server. Neovim 0.11 reads this file when the server is
-- enabled with vim.lsp.enable("postern"); nvim-lspconfig is not needed.
return {
  cmd = { "postern" },
  filetypes = { "postgresql-conf", "pg-hba", "pg-ident" },
  root_markers = { "postgresql.conf", "pg_hba.conf", ".git" },
}
