-- Byte-compile and cache Lua modules for faster subsequent startups
vim.loader.enable()

-- Set leader keys prior to loading any keymaps or plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core system configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin management via lazy.nvim
require("config.lazy")
