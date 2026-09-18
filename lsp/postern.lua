-- Postern language server. Neovim 0.11 reads this file when the server is
-- enabled with vim.lsp.enable("postern"); nvim-lspconfig is not needed. The
-- command is `postern` on the PATH, or the binary `:PosternInstall` fetched.
return {
  cmd = require("postern").cmd(),
  filetypes = { "postgresql-conf", "pg-hba", "pg-ident" },
  root_markers = { "postgresql.conf", "pg_hba.conf", ".git" },
}
