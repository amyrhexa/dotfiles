local map = vim.keymap.set

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus Right Window" })

-- Resize Windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Buffer Navigation
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer Tab" })
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer Tab" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Current Buffer" })

-- Move Selected Lines Up/Down in Visual Mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Keep Selection After Indenting
map("v", "<", "<gv", { desc = "Indent Left (Keep Selection)" })
map("v", ">", ">gv", { desc = "Indent Right (Keep Selection)" })

-- Keep Cursor Centered While Scrolling/Searching
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down (Centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up (Centered)" })
map("n", "n", "nzzzv", { desc = "Next Search Result (Centered)" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result (Centered)" })

-- Quick Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save File" })

-- File Explorer Toggle
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

-- Telescope Quick Open & Search
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Quick Open File" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Global Search (Live Grep)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find Open Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Find Recent Files" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find Diagnostics (Workspace)" })

-- Diagnostics (buffer-independent; LSP-attach keymaps in lsp.lua cover the rest)
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous Diagnostic" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to Loclist" })

-- Formatting
map("n", "<leader>mp", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format Document" })

-- Terminal Toggle
map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle Integrated Terminal" })

-- Run current Python file in a toggleterm horizontal split or floating window
map("n", "<S-CR>", function()
	local python_path = vim.env.CONDA_PREFIX and (vim.env.CONDA_PREFIX .. "/bin/python") or "python"
	vim.cmd("w")
	vim.cmd(string.format("TermExec cmd='%s %%' direction=float", python_path))
end, { desc = "Run Python File" })
