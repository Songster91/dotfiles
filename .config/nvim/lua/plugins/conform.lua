-- ============================================================
-- plugins/conform.lua — Manual formatting ONLY
-- NO auto-format. NO BufWritePre. NO format_on_save.
-- Format only when you press <leader>lf
-- ============================================================

return {
  {
    "stevearc/conform.nvim",
    -- Load only when the keymap is triggered — not on file events
    cmd  = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({
            lsp_fallback = true,
            async        = false,
            timeout_ms   = 2000,
          })
        end,
        mode = { "n", "v" },
        desc = "Format Document",
      },
    },
    config = function()
      require("conform").setup({
        -- Explicitly NO format_on_save
        format_on_save  = false,
        format_after_save = false,

        formatters_by_ft = {
          javascript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescript      = { "prettier" },
          typescriptreact = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          scss            = { "prettier" },
          json            = { "prettier" },
          jsonc           = { "prettier" },
          markdown        = { "prettier" },
          python          = { "black" },
          lua             = { "stylua" },
          sh              = { "shfmt" },
          bash            = { "shfmt" },
        },
      })
    end,
  },
}
