-- PostgreSQL names its configuration files; nothing else does. A .conf file
-- under a conf.d directory below a postgresql directory is an include_dir
-- entry as Debian lays it out, /etc/postgresql/16/main/conf.d/*.conf, and a
-- .conf file that starts with the comment Postern reads for the target
-- version is one of ours wherever it is. That check runs ahead of the conf
-- extension, which would otherwise take the file first.
local function starts_with_postern_comment(_, bufnr)
  if not bufnr then
    return nil
  end
  local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
  if first:find("^#%s*postern:") then
    return "postgresql-conf"
  end
end

vim.filetype.add({
  filename = {
    ["postgresql.conf"] = "postgresql-conf",
    ["postgresql.auto.conf"] = "postgresql-conf",
    ["postgresql.base.conf"] = "postgresql-conf",
    ["pg_hba.conf"] = "pg-hba",
    ["pg_ident.conf"] = "pg-ident",
  },
  pattern = {
    [".*/postgresql/.*/conf%.d/[^/]+%.conf"] = "postgresql-conf",
    [".*%.conf"] = { starts_with_postern_comment, { priority = 1 } },
  },
})
