return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = " ",
        path_display = { "smart" },
        -- Ignore patterns matching VS Code files.exclude & watcherExclude
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.venv/",
          "venv/",
          "__pycache__/",
          "%.pytest_cache/",
          "%.mypy_cache/",
          "%.ruff_cache/",
          "%.ipynb_checkpoints/",
        },
      },
    })

    telescope.load_extension("fzf")
  end,
}
