-- ============================================================
-- plugins/runner.lua — interactive REPL via iron.nvim
-- Code running is handled in keymaps.lua via <leader>rr
-- ============================================================

return {

  -- ── IRON.NVIM — interactive REPL ───────────────────────────
  {
    "Vigemus/iron.nvim",
    ft   = { "python", "javascript", "lua" },
    keys = {
      { "<leader>ri", "<cmd>IronRepl<CR>",    desc = "Open REPL"    },
      { "<leader>rR", "<cmd>IronRestart<CR>", desc = "Restart REPL" },
      { "<leader>rh", "<cmd>IronHide<CR>",    desc = "Hide REPL"    },
    },
    config = function()
      require("iron.core").setup({
        config = {
          repl_open_cmd = require("iron.view").bottom(30),
          repl_definition = {
            python = {
              command = function()
                if vim.fn.executable("ipython") == 1 then
                  return { "ipython", "--no-autoindent" }
                end
                return { "python3" }
              end,
            },
            javascript = { command = { "node" } },
            lua        = { command = { "lua"  } },
          },
        },
        keymaps = {
          send_motion       = "<leader>rm",
          visual_send       = "<leader>rv",
          send_file         = "<leader>ra",
          send_line         = "<leader>rl",
          send_until_cursor = "<leader>ru",
          interrupt         = "<leader>r<Space>",
          exit              = "<leader>rq",
          clear             = "<leader>rx",
        },
        highlight          = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

}
