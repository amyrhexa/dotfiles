local opt = vim.opt

-- Disable unused remote providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- Register sub-filetypes recognized by yamlls
vim.filetype.add({
	pattern = {
		[".*docker%-compose%.ya?ml"] = "yaml.docker-compose",
		[".*compose%.ya?ml"] = "yaml.docker-compose",
		["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		[".*values%.ya?ml"] = "yaml.helm-values",
	},
})

-- Editor Display & Clipboard
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.title = true -- sets the terminal/tab title to the current file (kitty picks this up)

-- Tabs & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = false

-- Don't auto-continue comment leaders ('o'/'O' or line-wrap) into the next line
opt.formatoptions:remove({ "o", "r" })

-- Search Behavior
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split" -- live preview for :s/:smagic substitutions

-- UI & Viewport
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.showmode = false -- lualine already shows the mode; avoid the duplicate -- INSERT -- in cmdline
opt.pumheight = 10 -- cap completion/wildmenu popup height
opt.confirm = true -- ask to save instead of erroring on :q with unsaved changes
opt.diffopt:append("linematch:60") -- much finer-grained diff highlighting (gitsigns/fugitive/diffs)
opt.virtualedit = "block" -- allow visual-block selection past end of line

-- Silence non-critical command-line clutter
opt.shortmess:append({ s = true, I = true, c = true, C = true, W = true, A = true, F = true })

-- File Management & Undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 200

-- Terminal Escape Timing & Backspace Control
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeout = true
opt.ttimeoutlen = 10
opt.backspace = { "indent", "eol", "start" }

-- Whitespace Rendering
opt.list = true
opt.listchars = { tab = "› ", trail = "•", nbsp = "␣" }
