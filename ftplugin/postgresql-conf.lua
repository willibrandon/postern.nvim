vim.bo.commentstring = "# %s"

-- Tree-sitter highlighting when the parser is installed; the conf syntax
-- otherwise.
pcall(vim.treesitter.start)
