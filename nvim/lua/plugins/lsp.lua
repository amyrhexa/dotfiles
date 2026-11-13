return {
  -- External language tooling manager
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "\u{f00c}",   -- 
          package_pending = "\u{f061}",     -- 
          package_uninstalled = "\u{f00d}", -- 
        },
      },
    },
  },

  -- Standalone formatters installer
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

  -- Mason LSP bridge (LSP servers only; formatters excluded)
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
        "hyprls",
      },
      automatic_installation = true,
    },
  },

  -- Neovim API support for LuaLS
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Native Neovim 0.11+ LSP configuration (no require('lspconfig') framework calls)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/lazydev.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Buffer-local keymaps bound on LSP attach
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

      -- Default capabilities for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Servers using default configurations
      local servers = {
        "bashls",
        "cssls",
        "html",
        "hyprls",
        "jsonls",
        "vtsls",
      }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {})
      end

      -- YAML: Restrict to standard "yaml" to eliminate unknown sub-filetype warnings
      vim.lsp.config("yamlls", {
        filetypes = { "yaml" },
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
              diagnosticMode = "openFilesOnly",
              diagnosticSeverityOverrides = {
                reportUnusedImport = "none",
                reportUnusedVariable = "none",
                reportDuplicateImport = "none",
              },
            },
          },
        },
      })

      -- Python: Ruff (Linter & diagnostics only)
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.documentFormattingProvider = false
        end,
      })

      -- Lua: LuaLS
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable all configured servers
      vim.lsp.enable({
        "bashls",
        "cssls",
        "html",
        "hyprls",
        "jsonls",
        "lua_ls",
        "pyright",
        "ruff",
        "vtsls",
        "yamlls",
      })
    end,
  },
}
