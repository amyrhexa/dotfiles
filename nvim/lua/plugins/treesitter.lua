return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- Install parsers
			ts.install({
				"python",
				"javascript",
				"typescript",
				"html",
				"css",
				"json",
				"yaml",
				"toml", -- pyproject.toml / ruff & mypy config
				"bash",
				"lua",
				"markdown",
				"markdown_inline",
				"diff", -- git diffs in fugitive/gitsigns previews
				"regex",
				"vim",
				"vimdoc",
				"query", -- treesitter query files, for editing this very config
				"luadoc", -- LuaLS annotations
			})

			-- Register filetypes
			vim.treesitter.language.register("json", "jsonc")

			-- Enable Treesitter highlighting and indent via Neovim core API
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("UserTreeSitter", { clear = true }),
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
					vim.bo[args.buf].indentexpr = "v:lua.vim.treesitter.indent()"
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			enable = true,
			max_lines = 3,
			trim_scope = "outer",
			mode = "topline",
			separator = nil,
		},
	},
}
