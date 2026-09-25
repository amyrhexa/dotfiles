return {
  -- Replicates VS Code ErrorLens with inline color blocks
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
          add_messages = true,
          throttle = 20,
          soft_wrap = true,
        },
      })

      -- Native Neovim 0.10+ diagnostic configuration with inline signs
      vim.diagnostic.config({
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        severity_sort = true,
        -- Rounded to match Mason/Lazy/Toggleterm float borders elsewhere in the config
        float = { border = "rounded", source = true },
      })
    end,
  },
}
