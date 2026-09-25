return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
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
    -- Exclude files matching VS Code settings.json (kept in sync with
    -- plugins/telescope.lua's file_ignore_patterns)
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
}
