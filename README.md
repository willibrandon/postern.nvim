# Postern for Neovim

Language support for `postgresql.conf`, `postgresql.auto.conf`, `pg_hba.conf` and
`pg_ident.conf` in Neovim 0.11 or newer. It uses Neovim's own language server client, so
nvim-lspconfig is not required.

The plugin gives the four files their own filetypes and enables the `postern` server for them.
It also takes `postgresql.base.conf`, which Patroni keeps the original file as, a `.conf` file
under a `conf.d` directory below a `postgresql` directory, which is how Debian lays out an
`include_dir`, and a `.conf` file whose first line is a `# postern:` comment, wherever it is. For
another layout, add your own pattern with `vim.filetype.add`.
The server has to be on your `PATH`; binaries are on the
[releases page](https://github.com/willibrandon/postern/releases).

Highlighting comes from the
[tree-sitter grammar](https://github.com/willibrandon/tree-sitter-postgresql-conf). A parser is a
compiled library built from the grammar, and nvim-treesitter builds it: `:TSInstall postgresql_conf`
clones the grammar, compiles it with your C compiler and puts `postgresql_conf.so` under
`~/.local/share/nvim/site/parser/`. With LazyVim, `ensure_installed = { "postgresql_conf" }` does the
same on startup. The plugin's part is to tell nvim-treesitter the repository, since the grammar is
not in its list. Until the parser exists the files fall back to Vim's `conf` syntax. The queries in
`queries/postgresql_conf` give the three filetypes highlights and text objects for settings, rules,
maps and options.

## Install

The plugin is developed in `editors/nvim` of the
[postern repository](https://github.com/willibrandon/postern), which takes issues and changes,
and each release publishes it on its own as
[willibrandon/postern.nvim](https://github.com/willibrandon/postern.nvim), which a plugin manager
takes by name; with lazy.nvim:

```lua
{ "willibrandon/postern.nvim" }
```

From a checkout of the main repository, point a spec at this directory instead:

```lua
{ dir = "~/src/postern/editors/nvim" }
```

Without a plugin manager, add the directory to the runtime path in `init.lua`:

```lua
vim.opt.runtimepath:prepend("~/src/postern/editors/nvim")
```

## Files

- `lsp/postern.lua` is the server definition, read by `vim.lsp.enable`, and `lua/postern/init.lua`
  finds the binary and fetches one for `:PosternInstall`.
- `ftdetect/postern.lua` maps the file names, the `conf.d` pattern and the first-line comment to
  their filetypes.
- `syntax/*.vim` loads Vim's `conf` highlighting for each filetype, and `ftplugin/*.lua` sets
  the comment string and starts tree-sitter highlighting when a parser is installed.
- `queries/postgresql_conf/*.scm` are the tree-sitter queries.
- `plugin/postern.lua` enables the server, maps the three filetypes to the one parser and
  registers the grammar with nvim-treesitter.

To use another binary, set `cmd` in your own config: `vim.lsp.config("postern", { cmd = { "/path/to/postern" } })`.

## Tests

The specs in `tests/` run under Neovim with busted, the way lazy.nvim and LazyVim test
themselves. The first run builds Lua, LuaRocks and busted into `.tests/`, which needs a C
compiler, Python 3, `unzip` and the readline headers (`libreadline-dev` on Debian and Ubuntu).
Point `POSTERN_BIN` at a server binary, or have `postern` on the `PATH`, and `POSTERN_PARSER` at a
compiled parser for the tree-sitter specs, which are skipped without one:

```sh
cd editors/nvim
POSTERN_BIN=../../burrito_out/postern_macos_arm64 POSTERN_PARSER=/path/to/postgresql_conf.so nvim -l tests/minit.lua --busted
```
