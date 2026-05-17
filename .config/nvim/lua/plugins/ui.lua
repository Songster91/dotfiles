return {

  -- ── DISABLE CONFLICTING LAZYVIM DEFAULTS ───────────────────
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false }, -- replaced by alpha
      notifier = { enabled = false }, -- replaced by nvim-notify
      terminal = { enabled = false }, -- replaced by toggleterm
      indent = { enabled = false }, -- replaced by indent-blankline
      lazygit = { enabled = false }, -- replaced by toggleterm lazygit
      picker = { enabled = false }, -- replaced by telescope
    },
  },

  -- ── LUALINE ─────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      -- Suppress tbl_flatten deprecation from lualine internals
      local _orig_notify = vim.notify
      vim.notify = function(msg, ...)
        if type(msg) == "string" and msg:find("tbl_flatten") then
          return
        end
        _orig_notify(msg, ...)
      end

      require("lualine").setup({
        options = {
          theme = "catppuccin",
          globalstatus = true,
          always_divide_middle = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "alpha", "NvimTree" } },
        },
        sections = {
          lualine_a = {
            { "mode", separator = { left = "" }, padding = { left = 1, right = 1 } },
          },
          lualine_b = {
            { "branch", icon = "" },
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = "  ", readonly = "  " } },
          },
          lualine_x = {
            { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
            { "filetype", icon_only = false },
          },
          lualine_y = { { "progress", padding = { left = 1, right = 1 } } },
          lualine_z = {
            { "location", separator = { right = "" }, padding = { left = 1, right = 1 } },
          },
        },
        inactive_sections = {
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
        },
      })
    end,
  },

  -- ── BUFFERLINE ──────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          always_show_bufferline = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "  Files",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },

  -- ── ALPHA — Dashboard ───────────────────────────────────────
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "  ███████╗ ██████╗ ███╗   ██╗ ██████╗ ███████╗████████╗███████╗██████╗  ",
        "  ██╔════╝██╔═══██╗████╗  ██║██╔════╝ ██╔════╝╚══██╔══╝██╔════╝██╔══██╗ ",
        "  ███████╗██║   ██║██╔██╗ ██║██║  ███╗███████╗   ██║   █████╗  ██████╔╝ ",
        "  ╚════██║██║   ██║██║╚██╗██║██║   ██║╚════██║   ██║   ██╔══╝  ██╔══██╗ ",
        "  ███████║╚██████╔╝██║ ╚████║╚██████╔╝███████║   ██║   ███████╗██║  ██║ ",
        "  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ",
        "                     Welcome back, Songster 🎵                      ",
      }
      dashboard.section.header.opts.hl = "AlphaHeader"

      dashboard.section.buttons.val = {
        dashboard.button("f", "󰱼  Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "  New File", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "󰺮  Search Text", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("e", "  Explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("s", "  Sessions", "<cmd>Telescope session-lens<CR>"),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      for _, btn in ipairs(dashboard.section.buttons.val) do
        btn.opts.hl = "AlphaButtons"
        btn.opts.hl_shortcut = "AlphaShortcut"
      end

      -- dashboard.section.footer.val = "  Keep building. Keep learning."
      dashboard.section.footer.val = ""
      dashboard.section.footer.opts.hl = "AlphaFooter"

      vim.defer_fn(function()
        local stats = require("lazy").stats()
        local ms    = math.floor(stats.startuptime * 100) / 100
        dashboard.section.footer.val = "⚡ Neovim loaded "
          .. stats.loaded .. "/" .. stats.count
          .. " plugins in " .. ms .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end, 100)

      local function set_hl()
        vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#cba6f7", bold = true })
        vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#89b4fa" })
        vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#f38ba8", bold = true })
        vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#6c7086", italic = true })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

      dashboard.opts.layout = {
        { type = "padding", val = 1 },
        dashboard.section.header,
        { type = "padding", val = 1 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }
      alpha.setup(dashboard.opts)
    end,
  },


  -- ── NOICE FILTERS ──────────────────────────────────────────
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            find  = "issues with your",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find  = "lualine",
          },
          opts = { skip = true },
        },
      },
    },
  },

  -- ── INDENT-BLANKLINE ────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        highlight = { "Function", "Label" },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "NvimTree",
          "lazy",
          "mason",
          "toggleterm",
          "notify",
        },
      },
    },
  },

  -- ── NVIM-COLORIZER ──────────────────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        css = true,
        tailwind = true,
        mode = "background",
        suppress_deprecation = true,
      },
    },
  },

  -- ── SMEAR CURSOR ────────────────────────────────────────────
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      hide_target_hack = true,
    },
  },

  -- ── NVIM-NOTIFY ─────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        render = "minimal",
        stages = "fade",
        timeout = 2000,
        max_width = 40,
        max_height = 3,
        top_down = true,
        background_colour = "#1e1e2e",
        icons = { ERROR = "", WARN = "", INFO = "" },
        level = vim.log.levels.WARN,
      })
      local banned = {
        "warning: multiple different client offset_encodings",
        "No information available",
        "written",
        "fewer lines",
        "more lines",
        "tbl_flatten",
      }
      vim.notify = function(msg, level, gopts)
        if not msg then
          return
        end
        for _, b in ipairs(banned) do
          if msg:find(b, 1, true) then
            return
          end
        end
        notify(msg, level, gopts)
      end
    end,
  },

  -- ── WHICH-KEY ───────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(vim.tbl_deep_extend("force", opts or {}, {
        win = { border = "rounded", padding = { 1, 2 } },
        layout = { align = "center" },
        notify = false,
      }))
      wk.add({
        { "<leader>l", group = "  LSP" },
        { "<leader>t", group = "  Terminal" },
        { "<leader>r", group = "  Run" },
        { "<leader>h", group = "  Harpoon" },
        { "<leader>o", group = "  Notes" },
        { "<leader>n", group = "  NPM" },
      })
    end,
  },

  -- ── WEB DEVICONS ────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
