# Postern for Neovim

Language support for `postgresql.conf`, `postgresql.auto.conf`, `pg_hba.conf` and
`pg_ident.conf` in Neovim 0.11 or newer. It uses Neovim's own language server client, so
nvim-lspconfig is not required.

The plugin gives the four files their own filetypes with `conf` highlighting, and enables the
`postern` server for them. The server has to be on your `PATH`; binaries are on the
[releases page](https://github.com/willibrandon/postern/releases).

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
  the comment string.
- `plugin/postern.lua` enables the server.

To use another binary, set `cmd` in your own config: `vim.lsp.config("postern", { cmd = { "/path/to/postern" } })`.

## Tests

The specs in `tests/` run under Neovim with busted, the way lazy.nvim and LazyVim test
themselves. The first run builds busted into `.tests/`. Point `POSTERN_BIN` at a server binary,
or have `postern` on the `PATH`:

```sh
cd editors/nvim
POSTERN_BIN=../../burrito_out/postern_macos_arm64 nvim -l tests/minit.lua --busted
```
