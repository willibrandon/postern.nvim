---@diagnostic disable: undefined-field
-- POSTERN_PARSER points at a compiled postgresql_conf parser; CI builds one
-- from the grammar. Without it, or an nvim-treesitter install, the specs that
-- need a parser are skipped.

local function tempfile(name, text)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/" .. name
  vim.fn.writefile(vim.split(text, "\n", { trimempty = false }), path)
  return path
end

describe("tree-sitter", function()
  local have_parser = vim.env.POSTERN_PARSER
      and vim.treesitter.language.add("postgresql_conf", { path = vim.env.POSTERN_PARSER }) == true
    or vim.treesitter.language.add("postgresql_conf") == true

  it("maps the three filetypes to one language", function()
    for _, ft in ipairs({ "postgresql-conf", "pg-hba", "pg-ident" }) do
      assert.equals("postgresql_conf", vim.treesitter.language.get_lang(ft))
    end
  end)

  it("parses a rule and starts highlighting", function()
    if not have_parser then
      pending("no postgresql_conf parser on the runtime path")
    end
    vim.cmd.edit(tempfile("pg_hba.conf", "host all all 10.0.0.0/8 trust\n"))
    local bufnr = vim.api.nvim_get_current_buf()
    assert.is_not_nil(vim.treesitter.highlighter.active[bufnr])
    local root = vim.treesitter.get_parser(bufnr):parse()[1]:root()
    assert.equals("hba_rule", root:named_child(0):type())
    assert.equals("connection_type", root:named_child(0):field("type")[1]:type())
  end)

  it("ships highlight and textobject queries", function()
    if not have_parser then
      pending("no postgresql_conf parser on the runtime path")
    end
    assert.is_not_nil(vim.treesitter.query.get("postgresql_conf", "highlights"))
    assert.is_not_nil(vim.treesitter.query.get("postgresql_conf", "textobjects"))
  end)
end)
