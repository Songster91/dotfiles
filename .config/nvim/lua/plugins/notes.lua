-- ============================================================
-- plugins/notes.lua — Note-taking and writing setup
--
-- Obsidian-style note linking, Markdown preview in browser,
-- focus/zen writing mode, and task checkboxes.
-- Perfect for studying, project notes, or daily journaling.
-- ============================================================

return {

  -- ══════════════════════════════════════════════════════════
  -- OBSIDIAN.NVIM — Obsidian-style notes in Neovim
  --
  -- Your notes are stored as plain markdown files.
  -- You can link between them with [[note name]] syntax.
  -- Works with your existing Obsidian vault too!
  -- ══════════════════════════════════════════════════════════
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- Required utility library
      "hrsh7th/nvim-cmp",              -- For [[link]] autocomplete
      "nvim-telescope/telescope.nvim", -- For searching notes
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("obsidian").setup({
        -- Where your notes vault lives
        -- Create this folder: mkdir -p ~/notes
        workspaces = {
          {
            name = "second-brain",
            path = "/mnt/songster/Local Disk E/Learning/Notes/Obsidian/Second Brain",
          },
        },

        -- How new notes are named
        -- This uses a timestamp to make unique names
        note_id_func = function(title)
          local suffix = ""
          if title ~= nil then
            -- Clean the title for use as a filename
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If no title, use random characters
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. "-" .. suffix
        end,

        -- Note frontmatter (the YAML at the top of notes)
        note_frontmatter_func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          -- Add creation date
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,

        -- How links look when created
        wiki_link_func = function(opts)
          if opts.id == nil then
            return string.format("[[%s]]", opts.label)
          elseif opts.label ~= opts.id then
            return string.format("[[%s|%s]]", opts.id, opts.label)
          else
            return string.format("[[%s]]", opts.id)
          end
        end,

        -- Completion settings
        completion = {
          nvim_cmp = true,        -- Integrate with nvim-cmp
          min_chars = 2,          -- Start completing after 2 chars
        },

        -- Keymaps inside obsidian notes
        mappings = {
          -- Follow a [[link]] under cursor
          ["gf"] = {
            action = function()
              return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- Toggle checkbox on current line
          ["<leader>ch"] = {
            action = function()
              return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true, desc = "Toggle Checkbox" },
          },
        },

        -- Where to put attachments (images etc.)
        attachments = {
          img_folder = "assets/imgs",  -- Relative to vault root
        },

        -- Disable obsidian's built-in UI (we use markdown.nvim instead)
        ui = {
          enable = true,
          update_debounce = 200,
          checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          },
          bullets = { char = "•", hl_group = "ObsidianBullet" },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
        },
      })

      -- Obsidian keymaps
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>on", function()
        local vault = "/mnt/songster/Local Disk E/Learning/Notes/Obsidian/Second Brain"
        local dirs  = {
          "00. Inbox",
          "01. Daily Notes",
          "02. Area",
          "Important",
        }
        vim.ui.select(dirs, { prompt = "  Save note in:" }, function(choice)
          if not choice then return end
          vim.ui.input({ prompt = "  Note title: " }, function(title)
            if not title or title == "" then return end
            local path = vault .. "/" .. choice .. "/" .. title .. ".md"
            vim.cmd("edit " .. vim.fn.fnameescape(path))
          end)
        end)
      end, vim.tbl_extend("force", opts, { desc = "New Note" }))
      vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>",
        vim.tbl_extend("force", opts, { desc = "Search Notes" }))
      vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>",
        vim.tbl_extend("force", opts, { desc = "Quick Switch Note" }))
      vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>",
        vim.tbl_extend("force", opts, { desc = "Note Backlinks" }))
      vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTags<CR>",
        vim.tbl_extend("force", opts, { desc = "Search by Tag" }))
      vim.keymap.set("n", "<leader>od", function()
        local vault = "/mnt/songster/Local Disk E/Learning/Notes/Obsidian/Second Brain"
        local date  = os.date("%Y-%m-%d")
        local dirs  = {
          "01. Daily Notes",
          "00. Inbox",
          "02. Area",
          "Important",
        }
        vim.ui.select(dirs, { prompt = "  Save daily note in:" }, function(choice)
          if not choice then return end
          local path = vault .. "/" .. choice .. "/" .. date .. ".md"
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          -- Add daily template if file is new
          vim.schedule(function()
            if vim.api.nvim_buf_line_count(0) <= 1 then
              local lines = {
                "---",
                'id: "' .. date .. '"',
                "aliases: []",
                "tags:",
                "  - daily",
                "---",
                "",
                "# 📅 " .. date,
                "",
                "## Tasks",
                "- [ ] ",
                "",
                "## Notes",
                "",
              }
              vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            end
          end)
        end)
      end, vim.tbl_extend("force", opts, { desc = "Daily Note" }))
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- MARKDOWN-PREVIEW.NVIM — Preview markdown in browser
  -- Opens a real-time rendered preview in your browser
  -- Syncs scrolling between Neovim and browser!
  -- ══════════════════════════════════════════════════════════
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },   -- Only for markdown files
    build = "cd app && npm install",

    config = function()
      -- Auto-close preview when leaving markdown file
      vim.g.mkdp_auto_close = 1

      -- Don't auto-open on BufEnter (use keymap instead)
      vim.g.mkdp_auto_start = 0

      -- Open in default browser
      vim.g.mkdp_browser = ""

      -- Preview server port
      vim.g.mkdp_port = "8080"

      -- Custom preview page title
      vim.g.mkdp_page_title = "${name} — Preview"

      -- Theme: dark or light (matches your terminal theme)
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- ZEN-MODE.NVIM — Distraction-free writing mode
  -- Hides everything except your text
  -- Great for writing, studying notes, focused coding
  -- ══════════════════════════════════════════════════════════
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup({
        window = {
          backdrop = 0.95,       -- Dim background slightly
          width = 80,            -- Center column width (80 chars = good writing width)
          height = 1,            -- Full height
          options = {
            signcolumn = "no",       -- Hide sign column
            number = false,          -- Hide line numbers
            relativenumber = false,  -- Hide relative numbers
            cursorline = false,      -- Hide cursor line highlight
            foldcolumn = "0",        -- Hide fold column
          },
        },
        plugins = {
          options = {
            enabled = true,
            ruler = false,       -- Hide ruler
            showcmd = false,     -- Hide command display
            laststatus = 0,      -- Hide statusline
          },
          gitsigns = { enabled = false },    -- Hide git signs
          tmux = { enabled = false },
          -- twilight highlights only the current paragraph (see below)
          twilight = { enabled = true },
        },
      })

      -- Keymap to toggle zen mode
      vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>",
        { desc = "Toggle Zen Mode" })
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- TWILIGHT.NVIM — Dims inactive parts of the file
  -- Only the current paragraph/function is fully bright
  -- Everything else is dimmed to 60% opacity
  -- Works great with zen-mode
  -- ══════════════════════════════════════════════════════════
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    config = function()
      require("twilight").setup({
        dimming = {
          alpha = 0.25,        -- 25% brightness for inactive text
          color = { "Normal", "#ffffff" },
          term_bg = "#000000",
          inactive = false,    -- Don't dim inactive windows
        },
        context = 10,          -- How many lines around cursor to keep bright
        treesitter = true,     -- Use treesitter for smarter dimming
        expand = {             -- Expand context to these node types
          "function",
          "method",
          "table",
          "if_statement",
        },
      })

      vim.keymap.set("n", "<leader>tw", "<cmd>Twilight<CR>",
        { desc = "Toggle Twilight" })
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- HEADLINES.NVIM — Beautiful markdown headings
  -- Adds colored background highlights to # headings
  -- Makes your markdown notes look like a real document
  -- ══════════════════════════════════════════════════════════
  {
    "lukas-reineke/headlines.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        markdown = {
          query = vim.treesitter.query.parse(
            "markdown",
            [[
              (atx_heading [
                  (atx_h1_marker)
                  (atx_h2_marker)
                  (atx_h3_marker)
                  (atx_h4_marker)
                  (atx_h5_marker)
                  (atx_h6_marker)
              ] @headline)
              (thematic_break) @dash
              (fenced_code_block) @codeblock
              (block_quote_marker) @quote
              (block_quote (paragraph (inline (block_continuation) @quote)))
            ]]
          ),
          headline_highlights = {
            "Headline1",   -- # heading color
            "Headline2",   -- ## heading color
            "Headline3",   -- ### heading color
            "Headline4",
            "Headline5",
            "Headline6",
          },
          codeblock_highlight = "CodeBlock",
          dash_highlight = "Dash",
          dash_string = "-",
          quote_highlight = "Quote",
          quote_string = "┃",
          fat_headlines = true,      -- Full-width heading backgrounds
          fat_headline_upper_string = "▃",
          fat_headline_lower_string = "▀",
        },
      })
    end,
  },

}
