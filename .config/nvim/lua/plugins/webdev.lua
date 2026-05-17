-- ============================================================
-- plugins/webdev.lua — Web development tools
-- Formatting is in conform.lua — NOT here
-- ============================================================

return {

  -- ── AUTO-INSTALL FORMATTERS VIA MASON ──────────────────────
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "black",
          "stylua",
          "shfmt",
          "eslint_d",
          "stylelint",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },

  -- ── LINTING ────────────────────────────────────────────────
  -- Only lints — never formats
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" }, -- NOT BufWritePost
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        -- css = { "stylelint" },  -- disabled, too strict for learning
        -- scss = { "stylelint" },
      }
      -- Lint on read and after leaving insert — NOT on write
      vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── PACKAGE.JSON VERSION HINTS ─────────────────────────────
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "json",
    config = function()
      require("package-info").setup({
        colors = { up_to_date = "#3C4048", outdated = "#d19a66" },
        icons = { enable = true },
        autostart = false,
        package_manager = "npm",
      })
      local o = { silent = true, noremap = true }
      vim.keymap.set(
        "n",
        "<leader>ns",
        require("package-info").show,
        vim.tbl_extend("force", o, { desc = "Show versions" })
      )
      vim.keymap.set(
        "n",
        "<leader>nh",
        require("package-info").hide,
        vim.tbl_extend("force", o, { desc = "Hide versions" })
      )
      vim.keymap.set(
        "n",
        "<leader>nu",
        require("package-info").update,
        vim.tbl_extend("force", o, { desc = "Update package" })
      )
      vim.keymap.set(
        "n",
        "<leader>ni",
        require("package-info").install,
        vim.tbl_extend("force", o, { desc = "Install package" })
      )
      vim.keymap.set(
        "n",
        "<leader>nd",
        require("package-info").delete,
        vim.tbl_extend("force", o, { desc = "Delete package" })
      )
    end,
  },
}
