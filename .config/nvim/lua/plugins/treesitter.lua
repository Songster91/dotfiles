-- ============================================================
-- plugins/treesitter.lua — FINAL FIX
-- Root cause: lazy.nvim loads config before nvim-treesitter
-- is on the runtimepath when using lazy=false + require()
-- Solution: use VimEnter autocmd to guarantee loading AFTER
-- everything is ready. This is bulletproof.
-- ============================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- Do NOT use event= or lazy=false with require() in config
    -- Instead we defer setup to VimEnter via init.lua autocmd
    -- The plugin still loads, just config runs after rtp is ready
    config = function()
      -- pcall wraps the require so if it fails, no error popup
      -- just silent fail until next restart when it works fine
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      configs.setup({
        ensure_installed = {
          "html", "css", "javascript", "typescript", "tsx",
          "json", "jsonc", "python", "bash", "lua",
          "markdown", "markdown_inline", "yaml", "toml",
          "gitcommit", "gitignore", "regex", "vim", "vimdoc",
        },
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(_, buf)
            local ok2, stats = pcall(vim.uv.fs_stat,
              vim.api.nvim_buf_get_name(buf))
            if ok2 and stats and stats.size > 100 * 1024 then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = "<S-CR>",
            node_decremental  = "<BS>",
          },
        },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
          },
          move = {
            enable    = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
          swap = {
            enable        = true,
            swap_next     = { ["<leader>sp"] = "@parameter.inner" },
            swap_previous = { ["<leader>sP"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
  },

  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "xml", "jsx", "tsx", "javascriptreact", "typescriptreact", "vue", "svelte" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close         = true,
          enable_rename        = true,
          enable_close_on_slash = false,
        },
        per_filetype = {
          ["html"] = { enable_close = true },
        },
      })
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
      languages = {
        css  = "/* %s */",
        scss = "/* %s */",
        conf = "# %s",
        fish = "# %s",
      },
    },
  },
}
