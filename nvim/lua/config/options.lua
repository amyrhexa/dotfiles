local opt = vim.opt

-- Disable legacy remote providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- UI & Display
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.termguicolors = true
opt.title = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.showmode = false
opt.pumheight = 10
opt.confirm = true
opt.winborder = "rounded" -- Global Neovim 0.11 rounded border for floating windows

-- Clipboard
-- NOTE: Uses unnamedplus to synchronize deletes, cuts, and yanks directly with
-- the Wayland clipboard via wl-clipboard.
opt.clipboard = "unnamedplus"

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = false

-- Prevent auto-inserting comment leader on newline
opt.formatoptions:remove({ "o", "r" })

-- Search Behavior
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- File Management, Buffers, & Undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 200

-- Timing & Keyboard Handling
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeout = true
opt.ttimeoutlen = 10
opt.backspace = { "indent", "eol", "start" }

-- Whitespace Rendering
opt.list = true
opt.listchars = { tab = "\u{203a} ", trail = "\u{2022}", nbsp = "\u{2423}" }

-- Diff Handling
opt.diffopt:append("linematch:60")
opt.virtualedit = "block"

-- Command line noise suppression
opt.shortmess:append({ s = true, I = true, c = true, C = true, W = true, A = true, F = true })

-- Apply the Nord theme
require("theme.nord").setup()
