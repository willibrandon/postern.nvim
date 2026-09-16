if vim.g.loaded_postern or vim.fn.has("nvim-0.11") == 0 then
  return
end
vim.g.loaded_postern = true

vim.lsp.enable("postern")

-- One tree-sitter parser serves the three filetypes.
vim.treesitter.language.register("postgresql_conf", { "postgresql-conf", "pg-hba", "pg-ident" })

-- nvim-treesitter learns where the parser lives, so `:TSInstall postgresql_conf`
-- works. It asks for custom parsers on this event before installing.
vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  group = vim.api.nvim_create_augroup("postern_treesitter", { clear = true }),
  callback = function()
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok then
      parsers.postgresql_conf = {
        install_info = { url = "https://github.com/willibrandon/tree-sitter-postgresql-conf" },
      }
    end
  end,
})
