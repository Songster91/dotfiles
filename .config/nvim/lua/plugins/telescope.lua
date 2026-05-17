-- ============================================================
-- plugins/telescope.lua — Fuzzy finder for everything
--
-- Telescope is like a supercharged search bar.
-- Find files, search text, browse git commits, find keymaps,
-- search help docs — all with a beautiful live preview.
--
-- Think of it as VS Code's Ctrl+P on steroids.
-- ============================================================

return {

  -- ══════════════════════════════════════════════════════════
  -- TELESCOPE — Main fuzzy finder plugin
  -- ══════════════════════════════════════════════════════════
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",              -- Use stable 0.1.x branch
    dependencies = {
      "nvim-lua/plenary.nvim",     -- Utility functions (required)
      -- FZF native sorter for much faster fuzzy matching
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",  -- File icons in results
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          -- Fix: disable treesitter highlighting in previewer (ft_to_lang error)
          preview = {
            treesitter = false,
          },
          -- The prompt is where you type your search query
          prompt_prefix = "  ",   -- Icon before search input
          selection_caret = " ",  -- Icon next to selected item
          entry_prefix = "  ",

          -- How results are sorted
          -- "smart" = tries to be intelligent about what's most relevant
          sorting_strategy = "ascending",

          -- Layout of the popup window
          layout_config = {
            horizontal = {
              prompt_position = "top",   -- Search bar at top
              preview_width = 0.55,      -- Preview takes 55% of width
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,               -- Telescope takes 87% of screen width
            height = 0.80,              -- And 80% of height
            preview_cutoff = 120,       -- Hide preview if screen < 120 cols
          },

          -- File paths to ignore in searches
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            ".cache",
            "__pycache__",
            "%.lock",
            "dist/",
            "build/",
          },

          -- Default keymaps inside Telescope popup
          mappings = {
            -- Insert mode mappings (when typing in search bar)
            i = {
              ["<C-k>"] = actions.move_selection_previous,  -- Up through results
              ["<C-j>"] = actions.move_selection_next,      -- Down through results
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              -- ^ Send selected results to quickfix list
              ["<Esc>"] = actions.close,   -- Close telescope with Escape
              ["<C-u>"] = false,           -- Don't clear prompt with Ctrl+U
              ["<C-d>"] = false,           -- Don't page down with Ctrl+D
            },
            -- Normal mode mappings (when not typing)
            n = {
              ["q"] = actions.close,       -- Close with q
              ["<Esc>"] = actions.close,   -- Close with Escape
            },
          },
        },

        -- Customize specific pickers (search modes)
        pickers = {
          -- File finder settings
          find_files = {
            hidden = true,   -- Show hidden files (dotfiles)
            -- Use fd if available (faster than find)
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          },
          -- Live grep (text search) settings
          live_grep = {
            additional_args = function()
              return { "--hidden" }  -- Search hidden files too
            end,
          },
          -- Buffer list settings
          buffers = {
            sort_mru = true,         -- Sort by most recently used
            ignore_current_buffer = true,  -- Don't show current buffer
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,  -- Delete buffer from list
              },
            },
          },
        },

        -- Extensions configuration
        extensions = {
          fzf = {
            fuzzy = true,                    -- Enable fuzzy matching
            override_generic_sorter = true,  -- Use fzf for all sorting
            override_file_sorter = true,     -- Use fzf for file sorting
            case_mode = "smart_case",        -- Smart case sensitivity
          },
        },
      })

      -- Load the fzf extension (makes searching WAY faster)
      telescope.load_extension("fzf")

      -- ════════════════════════════════════════════════════
      -- EXTRA TELESCOPE KEYMAPS
      -- (Core ones are in keymaps.lua, extras here)
      -- ════════════════════════════════════════════════════
      local builtin = require("telescope.builtin")

      -- Search recently opened files
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles,
        { desc = "Find Recent Files" })

      -- Search current buffer content (lines)
      vim.keymap.set("n", "<leader>f/", function()
        builtin.current_buffer_fuzzy_find({
          previewer = false,        -- No preview needed for buffer search
        })
      end, { desc = "Search in current buffer" })

      -- Search git commits
      vim.keymap.set("n", "<leader>gc", builtin.git_commits,
        { desc = "Git Commits" })

      -- Search git status (changed files)
      vim.keymap.set("n", "<leader>gs", builtin.git_status,
        { desc = "Git Status" })

      -- Search LSP symbols in current file
      vim.keymap.set("n", "<leader>ls", builtin.lsp_document_symbols,
        { desc = "LSP Document Symbols" })

      -- Search LSP symbols in whole project
      vim.keymap.set("n", "<leader>lS", builtin.lsp_workspace_symbols,
        { desc = "LSP Workspace Symbols" })

      -- Search diagnostics (errors/warnings)
      vim.keymap.set("n", "<leader>ld", builtin.diagnostics,
        { desc = "LSP Diagnostics" })
    end,
  },

}
