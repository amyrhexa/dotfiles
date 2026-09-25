return {
  -- File Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "everforest",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        -- Same glyphs as the diagnostic signs in plugins/diagnostics.lua, so
        -- the statusline count and the gutter icon always agree.
        lualine_b = {
          "branch",
          "diff",
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Open Buffer Tabs Bar (Bufferline)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
        },
      },
    },
  },

  -- Keybinding Helper Overlay (Which-Key)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      -- Names the leader groups that the keymaps in config/keymaps.lua and
      -- plugins/git.lua already create, so the popup shows "Find"/"Git"/etc.
      -- instead of a bare "+prefix".
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>m", group = "Format" },
        { "<leader>t", group = "Terminal" },
      },
    },
  },
}
