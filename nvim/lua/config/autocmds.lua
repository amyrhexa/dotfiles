local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight text on yank
autocmd("TextYankPost", {
	group = augroup("YankHighlight", { clear = true }),
	pattern = "*",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

-- Auto-Save cleanly on focus loss or leaving the buffer (avoids timer race conditions)
autocmd({ "FocusLost", "BufLeave" }, {
	group = augroup("AutoSave", { clear = true }),
	pattern = "*",
	callback = function(ev)
		local buf = ev.buf
		local bo = vim.bo[buf]

		if bo.modified and not bo.readonly and bo.buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("silent! write")
			end)
		end
	end,
})

-- Auto-resize splits when window is resized
autocmd("VimResized", {
	group = augroup("ResizeSplits", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Restore cursor to last edit position when reopening a file
autocmd("BufReadPost", {
	group = augroup("RestoreCursor", { clear = true }),
	callback = function(ev)
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Create parent directories on save if they don't exist yet (e.g. new nested file)
autocmd("BufWritePre", {
	group = augroup("MkdirOnSave", { clear = true }),
	callback = function(ev)
		local dir = vim.fn.fnamemodify(ev.match, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Close utility windows (help, quickfix, lsp info) with a single 'q'
autocmd("FileType", {
	group = augroup("QuickClose", { clear = true }),
	pattern = { "help", "qf", "lspinfo", "checkhealth", "man", "notify" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
	end,
})
