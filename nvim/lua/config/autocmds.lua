local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local utils = require("config.utils")

-- Highlight text on yank using Neovim core API
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Large File Protection Guard
autocmd("BufReadPre", {
  group = augroup("LargeFileGuard", { clear = true }),
  callback = function(ev)
    if utils.is_large_file(ev.buf) then
      vim.b[ev.buf].large_file = true
      vim.bo[ev.buf].undofile = false
      vim.bo[ev.buf].swapfile = false
      vim.bo[ev.buf].syntax = ""
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.opt_local.wrap = false
    end
  end,
})

-- Autosave cleanly on focus loss or leaving buffer using noautocmd write
-- Prevents BufWritePre from triggering blocking formatters in the background
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("AutoSave", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local buf = ev.buf
    local bo = vim.bo[buf]
    if bo.modified and not bo.readonly and bo.buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! noautocmd write")
      end)
    end
  end,
})

-- Resize splits automatically on terminal window resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Restore cursor to last position upon opening file
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

-- Create parent directories on save if missing
autocmd("BufWritePre", {
  group = augroup("MkdirOnSave", { clear = true }),
  callback = function(ev)
    local dir = vim.fn.fnamemodify(ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Close utility buffers quickly with 'q'
autocmd("FileType", {
  group = augroup("QuickClose", { clear = true }),
  pattern = { "help", "qf", "lspinfo", "checkhealth", "man", "notify" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})
