---@diagnostic disable: undefined-field
-- `assert` is luassert while the specs run, which the Lua language server cannot see.

-- The server under test is `postern` on the PATH, or POSTERN_BIN.
local bin = vim.env.POSTERN_BIN or "postern"

local function tempfile(name, text)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/" .. name
  vim.fn.writefile(vim.split(text, "\n", { trimempty = false }), path)
  return path
end

local function open(name, text)
  vim.cmd.edit(tempfile(name, text))
  return vim.api.nvim_get_current_buf()
end

local function diagnostics_for(bufnr, timeout)
  vim.wait(timeout or 15000, function()
    return #vim.diagnostic.get(bufnr) > 0
  end)
  return vim.diagnostic.get(bufnr)
end

local function client_for(bufnr, timeout)
  vim.wait(timeout or 15000, function()
    return #vim.lsp.get_clients({ bufnr = bufnr }) > 0
  end)
  return vim.lsp.get_clients({ bufnr = bufnr })[1]
end

describe("filetypes", function()
  it("are assigned by PostgreSQL's file names", function()
    assert.equals("postgresql-conf", vim.filetype.match({ filename = "postgresql.conf" }))
    assert.equals("postgresql-conf", vim.filetype.match({ filename = "postgresql.auto.conf" }))
    assert.equals("pg-hba", vim.filetype.match({ filename = "pg_hba.conf" }))
    assert.equals("pg-ident", vim.filetype.match({ filename = "pg_ident.conf" }))
  end)

  it("take postgresql.base.conf and an include_dir under a postgresql directory", function()
    assert.equals("postgresql-conf", vim.filetype.match({ filename = "postgresql.base.conf" }))
    assert.equals(
      "postgresql-conf",
      vim.filetype.match({ filename = "/etc/postgresql/16/main/conf.d/10-memory.conf" })
    )
  end)

  it("take a .conf file that starts with a postern comment", function()
    local bufnr = open("10-memory.conf", "# postern: pg=16\nshared_buffers = 128MB\n")
    assert.equals("postgresql-conf", vim.bo[bufnr].filetype)
  end)

  it("leave other .conf files alone", function()
    assert.is_true(vim.filetype.match({ filename = "other.conf" }) ~= "postgresql-conf")
    assert.is_true(vim.filetype.match({ filename = "pg_hba_backup.conf" }) ~= "pg-hba")
    assert.is_true(vim.filetype.match({ filename = "/etc/nginx/conf.d/default.conf" }) ~= "postgresql-conf")
  end)

  it("get conf highlighting and a comment string", function()
    local bufnr = open("pg_hba.conf", "# a comment\nlocal all all peer\n")
    assert.equals("pg-hba", vim.bo[bufnr].filetype)
    assert.equals("pg-hba", vim.b[bufnr].current_syntax)
    assert.equals("confComment", vim.fn.synIDattr(vim.fn.synID(1, 1, 1), "name"))
    assert.equals("# %s", vim.bo[bufnr].commentstring)
  end)
end)

describe("language server", function()
  before_each(function()
    vim.lsp.config("postern", { cmd = { bin } })
  end)

  it("reports a misspelled setting in postgresql.conf", function()
    local bufnr = open("postgresql.conf", "listen_addreses = 'localhost'\n")
    local client = client_for(bufnr)
    assert.is_truthy(client, "no client attached")
    assert.equals("postern", client.name)
    local found = diagnostics_for(bufnr)
    assert.is_true(#found > 0, "no diagnostics")
    assert.is_truthy(found[1].message:find("listen_addresses", 1, true), found[1].message)
  end)

  it("warns about a shadowed pg_hba.conf rule", function()
    local bufnr = open("pg_hba.conf", "host all all 0.0.0.0/0 trust\nhost all all 10.0.0.0/8 scram-sha-256\n")
    assert.is_truthy(client_for(bufnr), "no client attached")
    local found = diagnostics_for(bufnr)
    local shadowed
    for _, d in ipairs(found) do
      if d.message:find("shadows it", 1, true) then
        shadowed = d
      end
    end
    assert.is_truthy(shadowed, vim.inspect(found))
    assert.equals(1, shadowed.lnum)
    assert.equals(vim.diagnostic.severity.WARN, shadowed.severity)
  end)

  it("does not attach to other .conf files", function()
    local bufnr = open("other.conf", "key = value\n")
    vim.wait(3000, function()
      return #vim.lsp.get_clients({ bufnr = bufnr }) > 0
    end)
    assert.equals(0, #vim.lsp.get_clients({ bufnr = bufnr }))
  end)
end)

describe("the checksum", function()
  local dir = vim.fn.tempname()
  before_each(function()
    vim.fn.mkdir(dir, "p")
  end)
  after_each(function()
    vim.fn.delete(dir, "rf")
  end)

  it("is the SHA-256 of the file's bytes", function()
    local path = vim.fs.joinpath(dir, "hello")
    vim.fn.writefile({ "hello" }, path)
    assert.equals("5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03", require("postern").sha256(path))
  end)

  it("reads past a NUL byte, which Vim's sha256() stops at", function()
    local path = vim.fs.joinpath(dir, "binary")
    local f = assert(io.open(path, "wb"))
    f:write("a\0b")
    f:close()
    assert.equals("59b271ae1bbcb1d31d41929817f4b16fb439eb4f31520b5ad1d5ce98920a7138", require("postern").sha256(path))
  end)
end)

describe("the server binary", function()
  it("is postern on the PATH, or the one :PosternInstall fetched, or postern for the client to report", function()
    local postern = require("postern")
    assert.equals("table", type(postern.cmd()))
    assert.equals(1, #postern.cmd())
    local dir = postern.dir()
    vim.fn.mkdir(dir, "p")
    local path = postern.installed()
    vim.fn.writefile({ "#!/bin/sh", "exit 0" }, path)
    vim.uv.fs_chmod(path, 493)
    if vim.fn.executable("postern") == 1 then
      assert.same({ "postern" }, postern.cmd())
    else
      assert.same({ path }, postern.cmd())
    end
    os.remove(path)
    assert.is_true(vim.fn.exists(":PosternInstall") == 2)
  end)
end)
