return {
	-- Mason: external binary manager
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- Mason Tool Installer: formatters and linters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				"shfmt",
			},
			auto_update = false,
			run_on_start = true,
		},
	},

	-- Mason LSPConfig: bridge installer
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"pyright",
				"ruff",
				"vtsls",
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"bashls",
				"lua_ls",
			},
			automatic_installation = true,
		},
	},

	-- LSP configuration via Neovim 0.11+ native vim.lsp.config
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.offsetEncoding = { "utf-8", "utf-16" }

			-- Set default capabilities across all language servers
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Python: Pyright
			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "standard",
							autoImportCompletions = true,
							indexing = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							diagnosticSeverityOverrides = {
								reportUnusedImport = "none",
								reportUnusedVariable = "none",
								reportDuplicateImport = "none",
							},
						},
					},
				},
			})

			-- Python: Ruff
			vim.lsp.config("ruff", {
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Lua: Lua Language Server
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- Enable all configured servers (active on FileType)
			vim.lsp.enable({
				"pyright",
				"ruff",
				"vtsls",
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"bashls",
				"lua_ls",
			})

			-- Buffer-local keymaps attached to active clients
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
					end

					map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
					map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
					map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
					map("n", "gr", vim.lsp.buf.references, "Go to References")
					map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
					map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
					map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", "Document Symbols")
					map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", "Workspace Symbols")

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client:supports_method("textDocument/inlayHint") then
						map("n", "<leader>ih", function()
							local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
							vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
						end, "Toggle Inlay Hints")
					end
				end,
			})
		end,
	},
}
