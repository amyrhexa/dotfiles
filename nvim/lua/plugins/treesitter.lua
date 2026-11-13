return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      ts.install({
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "diff",
        "regex",
        "vim",
        "vimdoc",
        "query",
        "luadoc",
        "hyprlang",
        "rasi",
        "gitcommit",
        "ini",
        "dockerfile",
      })

      vim.treesitter.language.register("json", "jsonc")

      -- Neovim 0.11 Treesitter starter and indentation binding
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreeSitter", { clear = true }),
        callback = function(args)
          if vim.b[args.buf].large_file then
            return
          end

          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
