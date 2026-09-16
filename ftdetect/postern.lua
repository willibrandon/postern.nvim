-- PostgreSQL names its configuration files; nothing else does.
vim.filetype.add({
  filename = {
    ["postgresql.conf"] = "postgresql-conf",
    ["postgresql.auto.conf"] = "postgresql-conf",
    ["pg_hba.conf"] = "pg-hba",
    ["pg_ident.conf"] = "pg-ident",
  },
})
