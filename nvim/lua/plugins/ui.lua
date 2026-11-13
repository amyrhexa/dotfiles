local nord = require("theme.nord")

return {
  -- Nerd Font icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = nord.lualine_theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "\u{e725}" },
          {
            "diff",
            symbols = {
              added = "\u{f457} ",
              modified = "\u{f459} ",
              removed = "\u{f458} ",
            },
          },
          {
            "diagnostics",
            symbols = {
              error = "\u{ea87} ",
              warn = "\u{ea6c} ",
              info = "\u{ea74} ",
              hint = "\u{eb58} ",
            },
          },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Inline diagnostic viewer (replaces ErrorLens)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        show_source = {
          enabled = true,
        },
        use_icons_from_diagnostic = true,
        add_messages = true,
        throttle = 20,
        soft_wrap = true,
      },
    },
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      view = {
        width = 32,
        side = "left",
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = {
          "^\\.git$",
          "^__pycache__$",
          "^\\.pytest_cache$",
          "^\\.mypy_cache$",
          "^\\.ruff_cache$",
          "^\\.venv$",
          "^node_modules$",
          "^\\.ipynb_checkpoints$",
        },
      },
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
    },
  },

  -- Persistent Integrated Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle Terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float Terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical Terminal" },
    },
    opts = {
      size = 15,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = false, -- Prevent overriding normal mode terminal escapes
      persist_size = true,
      persist_mode = true,
      direction = "float",
      float_opts = {
        border = "rounded",
        winblend = 0,
      },
    },
  },

  -- Keymap discovery helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
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
