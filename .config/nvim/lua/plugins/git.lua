-- ============================================================
-- plugins/git.lua — Git integration
--
-- Two things here:
-- 1. Gitsigns: shows git changes in the gutter (left column)
--    +/~ symbols showing added/modified/deleted lines
-- 2. Diffview: a beautiful diff viewer and merge tool
--
-- Lazygit is handled in editor.lua (it's a terminal app)
-- ============================================================

return {

  -- ══════════════════════════════════════════════════════════
  -- GITSIGNS — Git status in the gutter
  --
  -- That left column shows:
  --   │  = added line (green)
  --   ~  = modified line (yellow)
  --   _  = deleted line (red)
  --
  -- Also adds git blame (who wrote this line) and hunk actions
  -- ══════════════════════════════════════════════════════════
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },  -- Load when opening a file
    config = function()
      require("gitsigns").setup({
        -- Signs shown in the gutter column
        signs = {
          add          = { text = "│" },   -- New line added
          change       = { text = "│" },   -- Line was modified
          delete       = { text = "_" },   -- Line was deleted
          topdelete    = { text = "‾" },   -- First line of a deletion
          changedelete = { text = "~" },   -- Line modified then deleted
          untracked    = { text = "┆" },   -- File not tracked by git
        },

        -- Sign column behavior
        signcolumn = true,       -- Show signs in the sign column
        numhl = false,           -- Don't highlight line numbers
        linehl = false,          -- Don't highlight the whole line
        word_diff = false,       -- Don't show word-level diffs inline

        -- Watch git directory for external changes
        watch_gitdir = {
          interval = 1000,       -- Check every 1 second
          follow_files = true,   -- Follow file renames
        },

        -- Git blame virtual text (shows at end of line)
        current_line_blame = false,   -- Off by default (toggle with keymap)
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",      -- Show at end of line
          delay = 1000,               -- Show after 1 second of no movement
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>",
        -- ^ Format: "Name, YYYY-MM-DD • commit message"

        -- Performance
        update_debounce = 100,   -- Wait 100ms after change before updating
        max_file_length = 40000, -- Don't show signs for very large files

        -- Keymaps for git hunk actions
        -- A "hunk" = a section of changed lines
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr   -- Apply only to current buffer
            vim.keymap.set(mode, l, r, opts)
          end

          -- NAVIGATION between hunks
          map("n", "]h", function()
            if vim.wo.diff then return "]h" end  -- In diff mode, use built-in
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next git hunk" })

          map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Prev git hunk" })

          -- ACTIONS on hunks
          map("n", "<leader>ghs", gs.stage_hunk,        -- Stage (add) this hunk
            { desc = "Stage hunk" })
          map("n", "<leader>ghr", gs.reset_hunk,        -- Undo changes in hunk
            { desc = "Reset hunk" })
          map("n", "<leader>ghS", gs.stage_buffer,      -- Stage whole file
            { desc = "Stage buffer" })
          map("n", "<leader>ghu", gs.undo_stage_hunk,   -- Un-stage this hunk
            { desc = "Undo stage hunk" })
          map("n", "<leader>ghR", gs.reset_buffer,      -- Reset whole file
            { desc = "Reset buffer" })
          map("n", "<leader>ghp", gs.preview_hunk,      -- Preview hunk in popup
            { desc = "Preview hunk" })

          -- Blame
          map("n", "<leader>gb", function()
            gs.blame_line({ full = true })   -- Show full blame for this line
          end, { desc = "Blame line" })

          map("n", "<leader>gB", gs.toggle_current_line_blame,
            { desc = "Toggle line blame" })

          -- Diff views
          map("n", "<leader>gd", gs.diffthis,         -- Diff current file
            { desc = "Diff this file" })
          map("n", "<leader>gD", function()
            gs.diffthis("~")                -- Diff against last commit
          end, { desc = "Diff against last commit" })

          -- Visual mode: stage/reset selected lines only
          map("v", "<leader>ghs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Stage selected lines" })
          map("v", "<leader>ghr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Reset selected lines" })

          -- Text object: ih = inner hunk
          -- Use: "vih" to select changed lines, "dih" to delete them
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>",
            { desc = "Select git hunk" })
        end,
      })
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- DIFFVIEW — Beautiful side-by-side diff viewer
  -- Open with :DiffviewOpen or <leader>gv
  -- Also shows file history: :DiffviewFileHistory
  -- ══════════════════════════════════════════════════════════
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
    },
    config = function()
      require("diffview").setup({
        diff_binaries = false,        -- Don't diff binary files
        enhanced_diff_hl = true,      -- Better diff highlighting
        use_icons = true,             -- Show file type icons

        file_panel = {
          listing_style = "tree",     -- Show files as a tree
          win_config = {
            position = "left",
            width = 35,
          },
        },

        -- Key mappings inside diffview
        keymaps = {
          view = {
            -- Close diffview
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
          },
          file_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
          },
        },
      })

      -- Global keymaps to open diffview
      vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<CR>",
        { desc = "Open Diffview" })
      vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",
        { desc = "File history" })
    end,
  },

}
