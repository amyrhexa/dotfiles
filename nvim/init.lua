-- Byte-compile and cache Lua modules for fast startup
vim.loader.enable()

-- Disable netrw early to prevent directory-open race conditions before nvim-tree loads
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader keys must be set before any plugin or keymap loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core configuration
require("config.options")
require("config.diagnostics")
require("config.keymaps")
require("config.autocmds")

-- Plugin management via lazy.nvim
require("config.lazy")
