return {
  -- Gutter Git Signs & Inline Hunk Staging
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = " " },
        topdelete    = { text = "▔" },
        changedelete = { text = "┊" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation through Git hunks
        map("n", "]h", function()
          if vim.wo.diff then return "]h" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Git Hunk" })

        map("n", "[h", function()
          if vim.wo.diff then return "[h" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous Git Hunk" })

        -- Actions (visual-mode variants stage/reset just the selected lines)
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage Selected Lines" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset Selected Lines" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk Diff" })
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git Line Blame" })
        map("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle Inline Blame" })
      end,
    },
  },

  -- Full Git Workflow Integration (Fugitive)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git Status Overview" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git Diff Split" },
    },
  },
}
