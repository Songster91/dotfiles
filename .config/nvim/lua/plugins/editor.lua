return {

  -- ── DISABLE CONFLICTING LAZYVIM DEFAULTS ───────────────────
  -- neo-tree replaced by nvim-tree
  -- mini.surround replaced by nvim-surround
  -- mini.comment + ts-comments replaced by Comment.nvim
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  { "mini.surround",               enabled = false },
  { "mini.comment",                enabled = false },
  { "folke/ts-comments.nvim",      enabled = false },

  -- ── NVIM-TREE ───────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view     = { width = 32, side = "left" },
        renderer = {
          group_empty       = true,
          root_folder_label = false,
          indent_markers    = { enable = true },
          icons = {
            show  = { file = true, folder = true, folder_arrow = true, git = true },
            glyphs = {
              folder = { arrow_closed = "", arrow_open = "" },
            },
          },
        },
        filters  = {
          dotfiles = false,
          custom   = { "node_modules", ".git", "__pycache__", ".cache" },
        },
        git      = { enable = true, ignore = false },
        actions  = { open_file = { quit_on_open = false } },
        sync_root_with_cwd = true,
        respect_buf_cwd    = true,
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local o   = function(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true }
          end
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "h", api.node.navigate.parent_close, o("Close Dir"))
          vim.keymap.set("n", "l", api.node.open.edit,             o("Open"))
          vim.keymap.set("n", "e", api.tree.close,                 o("Close Explorer"))
          vim.keymap.set("n", "r", api.fs.rename,                  o("Rename"))
        end,
      })
    end,
  },

  -- ── AUTOPAIRS ───────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },
  },

  -- ── NVIM-SURROUND ───────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- ── COMMENT.NVIM ────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event  = "BufReadPost",
    config = function()
      require("Comment").setup({
        pre_hook = function(ctx)
          -- Use ts-context-commentstring if available
          local ok, ts_cs = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
          if ok then
            local hook = ts_cs.create_pre_hook()
            local result = hook(ctx)
            -- If treesitter returns nil, fall back to vim commentstring
            if result ~= nil then return result end
          end
          -- Fallback to vim.bo.commentstring
          return vim.bo.commentstring
        end,
      })
    end,
  },

  -- ── AUTO-SAVE ───────────────────────────────────────────────
  {
    "pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup({
        enabled        = true,
        trigger_events = { "InsertLeave", "FocusLost" },
        debounce_delay = 1000,
        condition = function(buf)
          local fn    = vim.fn
          local utils = require("auto-save.utils.data")
          return fn.getbufvar(buf, "&modifiable") == 1
            and utils.not_in(fn.getbufvar(buf, "&filetype"), {
              "oil", "alpha", "NvimTree", "toggleterm", "lazy", "mason",
            })
        end,
      })
    end,
  },

  -- ── TOGGLETERM ──────────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config  = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return vim.o.columns * 0.4
          end
        end,
        open_mapping    = [[<C-\>]],
        direction       = "horizontal",
        shade_terminals = true,
        shading_factor  = 2,
        close_on_exit   = true,
        shell           = vim.o.shell,
        float_opts      = { border = "curved", winblend = 0 },
      })

      function _G.set_terminal_keymaps()
        local o = { buffer = 0 }
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],        o)
        vim.keymap.set("t", "jk",    [[<C-\><C-n>]],        o)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
      end
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit  = Terminal:new({
        cmd        = "lazygit",
        hidden     = true,
        direction  = "float",
        float_opts = { border = "double" },
        on_open    = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>",
            { noremap = true, silent = true })
        end,
      })
      function _G.lazygit_toggle() lazygit:toggle() end
      vim.keymap.set("n", "<leader>gg", "<cmd>lua lazygit_toggle()<CR>",
        { noremap = true, silent = true, desc = "Open Lazygit" })
    end,
  },

  -- ── HARPOON ─────────────────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end,                      { desc = "Harpoon Add"  })
      vim.keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
      vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,                     { desc = "Harpoon 1"   })
      vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,                     { desc = "Harpoon 2"   })
      vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,                     { desc = "Harpoon 3"   })
      vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,                     { desc = "Harpoon 4"   })
    end,
  },

  -- ── AUTO-SESSION ────────────────────────────────────────────
  {
    "rmagatti/auto-session",
    config = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      require("auto-session").setup({
        auto_save           = true,
        auto_restore        = true,
        git_use_branch_name = true,
        log_level           = "error",
        suppressed_dirs     = { "~/", "~/Downloads", "/tmp" },
      })
    end,
  },

  -- ── VIM-VISUAL-MULTI ────────────────────────────────────────
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_maps  = { ["Find Under"] = "<C-n>", ["Exit"] = "<Esc>" }
      vim.g.VM_theme = "codedark"
    end,
  },

  -- ── SPECTRE ─────────────────────────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup()
    end,
  },
}
