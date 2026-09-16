#!/usr/bin/env -S nvim -l

-- Runs the specs in tests/ under Neovim with busted, the way lazy.nvim and
-- LazyVim test themselves:  nvim -l tests/minit.lua --busted

vim.env.LAZY_STDPATH = ".tests"

-- A local clone of lazy.nvim is used when there is one; otherwise it is fetched.
local clone = vim.fs.normalize(vim.env.LAZY_PATH or "~/src/lazy.nvim")
if vim.fn.isdirectory(clone) == 1 then
  vim.env.LAZY_PATH = clone
  loadfile(clone .. "/bootstrap.lua")()
else
  load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"), "bootstrap.lua")()
end

vim.opt.rtp:prepend(".")

-- What a normal Neovim has on by default, but a bare `nvim -l` does not.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

require("lazy.minit").setup({
  spec = {
    { dir = vim.uv.cwd() },
  },
})
