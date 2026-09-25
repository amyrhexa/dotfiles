return {
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    -- Everything lives in setup()'s options table below; the neanias/
    -- everforest-nvim Lua port never reads vim.g.everforest_* (that's the
    -- config style of the older sainnhe/everforest VimL plugin it's based
    -- on), so those globals were silently ignored.
    require("everforest").setup({
      background = "hard", -- Replicates VS Code "Dark Vibrant"
      transparent_background_level = 0,
      italics = true,
      disable_italic_comments = false, -- correct field name is plural
      show_eob = false, -- hide the "~" end-of-buffer tildes, VS Code-style
    })

    vim.cmd([[colorscheme everforest]])
  end,
}
