# Postern for Neovim

Language support for `postgresql.conf`, `postgresql.auto.conf`, `pg_hba.conf` and
`pg_ident.conf` in Neovim 0.11 or newer. It uses Neovim's own language server client, so
nvim-lspconfig is not required.

The plugin gives the four files their own filetypes and enables the `postern` server for them.
The server has to be on your `PATH`; binaries are on the
[releases page](https://github.com/willibrandon/postern/releases).

Highlighting comes from the
[tree-sitter grammar](https://github.com/willibrandon/tree-sitter-postgresql-conf) once its parser
is installed, and from Vim's `conf` syntax until then. The plugin tells nvim-treesitter where the
grammar lives, so `:TSInstall postgresql_conf` installs the parser, or add `postgresql_conf` to
`ensure_installed`. The queries in `queries/postgresql_conf` give the three filetypes highlights
and text objects for settings, rules, maps and options.

## Install

With lazy.nvim, point a spec at this directory in a checkout of the repository:

```lua
{ dir = "~/src/postern/editors/nvim" }
```

Without a plugin manager, add the directory to the runtime path in `init.lua`:

```lua
vim.opt.runtimepath:prepend("~/src/postern/editors/nvim")
```

## Files

- `lsp/postern.lua` is the server definition, read by `vim.lsp.enable`.
- `ftdetect/postern.lua` maps the four file names to their filetypes.
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
