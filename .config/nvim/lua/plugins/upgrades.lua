-- ============================================================
-- plugins/upgrades.lua
-- NOTE: Trouble rewritten for v3 API (LazyVim ships v3)
-- ============================================================

return {

  -- ── TODO-COMMENTS ──────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("todo-comments").setup({
        signs      = true,
        sign_priority = 8,
        keywords = {
          FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info"   },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = "󰅒 ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = "󰍨 ", color = "hint",    alt = { "INFO" } },
          TEST = { icon = "⏲ ", color = "test",    alt = { "TESTING", "PASSED", "FAILED" } },
        },
        highlight = {
          before        = "",
          keyword       = "wide_bg",
          after         = "fg",
          pattern       = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
        },
        colors = {
          error   = { "DiagnosticError", "ErrorMsg",   "#f38ba8" },
          warning = { "DiagnosticWarn",  "WarningMsg", "#fab387" },
          info    = { "DiagnosticInfo",                "#89b4fa" },
          hint    = { "DiagnosticHint",                "#a6e3a1" },
          default = {                                  "#cba6f7" },
          test    = {                                  "#f5c2e7" },
        },
      })

      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end,
        { desc = "Next TODO", silent = true })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end,
        { desc = "Prev TODO", silent = true })
      vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>",
        { desc = "Find TODOs", silent = true })
    end,
  },

  -- ── TREESITTER-CONTEXT ─────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("treesitter-context").setup({
        enable             = true,
        max_lines          = 3,
        min_window_height  = 20,
        line_numbers       = true,
        multiline_threshold = 1,
        trim_scope         = "outer",
        mode               = "cursor",
        separator          = "─",
        zindex             = 20,
      })

      local function set_hl()
        vim.api.nvim_set_hl(0, "TreesitterContext",           { bg = "#24273a" })
        vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#6c7086", bg = "#24273a" })
        vim.api.nvim_set_hl(0, "TreesitterContextSeparator",  { fg = "#45475a" })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

      vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>",
        { desc = "Toggle Context", silent = true })
    end,
  },

  -- ── TROUBLE v3 ─────────────────────────────────────────────
  -- LazyVim ships Trouble v3 — TroubleToggle is gone
  -- New commands: Trouble diagnostics toggle, Trouble qflist toggle, etc.
  {
    "folke/trouble.nvim",
    cmd  = "Trouble",
    opts = {
      modes = {
        diagnostics = { auto_close = false, auto_open = false },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",               desc = "Toggle Trouble"        },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",  desc = "Document Diagnostics"  },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>",               desc = "Workspace Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                    desc = "Quickfix List"         },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",                   desc = "Location List"         },
    },
  },

}
