return {
  -- Gutter Git Signs & Inline Hunk Controls
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "\u{258e}" },          -- ▎
        change = { text = "\u{258e}" },       -- ▎
        delete = { text = "\u{2581}" },       --
        topdelete = { text = "\u{2594}" },    -- ▔
        changedelete = { text = "\u{254e}" }, -- ┊
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]h", function()
          if vim.wo.diff then
            return "]h"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Git Hunk" })

        map("n", "[h", function()
          if vim.wo.diff then
            return "[h"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous Git Hunk" })

        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage Selected Lines" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset Selected Lines" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk Diff" })
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, { desc = "Git Line Blame" })
        map("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle Inline Blame" })
      end,
    },
  },

  -- Git Workflow Integration (Fugitive)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git Status" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git Diff Split" },
    },
  },
}
