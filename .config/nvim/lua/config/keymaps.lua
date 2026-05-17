-- ============================================================
-- core/keymaps.lua
-- ============================================================

local keymap = vim.keymap.set
local opts   = { noremap = true, silent = true }

-- ── MODE SHORTCUTS ──────────────────────────────────────────
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)
keymap("n", ";",  ":",     { noremap = true })

-- ── INSERT MODE — CURSOR MOVEMENT ───────────────────────────
-- Move without leaving insert mode — no arrow keys needed
-- <C-h> removed — conflicts with Ctrl+Backspace in kitty
keymap("i", "<C-l>", "<Right>", opts)   -- move right
keymap("i", "<C-j>", "<Down>",  opts)   -- move down
keymap("i", "<C-e>", "<End>",   opts)   -- jump to end of line
keymap("i", "<C-a>", "<Home>",  opts)   -- jump to start of line
keymap("i", "<M-l>", "<C-Right>", opts) -- Alt+l → jump word forward
keymap("i", "<M-h>", "<C-Left>",  opts) -- Alt+h → jump word backward

-- ── COMMENT TOGGLE Ctrl+/ ───────────────────────────────────
keymap("n", "<C-/>", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("i", "<C-/>", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("v", "<C-/>", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

-- ── NEW LINE — never continues comments ─────────────────────
-- Ctrl+Enter in insert mode → clean empty line below
keymap("i", "<C-CR>", function()
  -- Exit insert, open new line, disable comment continuation, re-enter insert
  vim.cmd("normal! o")
  -- Strip comment prefix that Neovim auto-inserts
  vim.schedule(function()
    local new_line = vim.api.nvim_get_current_line()
    -- If the new line is only whitespace + comment chars, clear it
    if new_line:match("^%s*[/#*%-%-]+%s*$") or new_line:match("^%s*//") or
       new_line:match("^%s*#") or new_line:match("^%s*%*") then
      vim.api.nvim_set_current_line("")
    end
    vim.cmd("startinsert!")
  end)
end, opts)

-- Enter in normal mode → clean empty line below, stay normal
-- Only on modifiable buffers (not dashboard, help, etc.)
keymap("n", "<CR>", function()
  if not vim.bo.modifiable or vim.bo.buftype ~= "" then
    return  -- let Enter work normally in special buffers
  end
  vim.cmd("normal! o")
  vim.schedule(function()
    local new_line = vim.api.nvim_get_current_line()
    if new_line:match("^%s*[/#*]+%s*$") or new_line:match("^%s*//") or
       new_line:match("^%s*#") or new_line:match("^%s*%*") then
      vim.api.nvim_set_current_line("")
    end
    vim.cmd("normal! k")
    vim.cmd("normal! j")
    vim.cmd("stopinsert")
  end)
end, opts)


-- ── FILE OPERATIONS ─────────────────────────────────────────
keymap("n", "<leader>w",  "<cmd>w<CR>",   vim.tbl_extend("force", opts, { desc = "Save"           }))
keymap("n", "<leader>q",  "<cmd>q<CR>",   vim.tbl_extend("force", opts, { desc = "Quit"           }))
keymap("n", "<leader>x",  "<cmd>wq<CR>",  vim.tbl_extend("force", opts, { desc = "Save & Quit"   }))
keymap("n", "<leader>Q",  "<cmd>qa!<CR>", vim.tbl_extend("force", opts, { desc = "Force Quit All" }))

-- ── BETTER MOVEMENT ─────────────────────────────────────────
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n",     "nzzzv",   opts)
keymap("n", "N",     "Nzzzv",   opts)

-- ── SPLIT NAVIGATION ────────────────────────────────────────
-- Move between splits with Ctrl+hjkl
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- ── SPLIT CREATION & CLOSING ────────────────────────────────
keymap("n", "<leader>sv", "<cmd>vsplit<CR>",  vim.tbl_extend("force", opts, { desc = "Split Vertical"   }))
keymap("n", "<leader>sh", "<cmd>split<CR>",   vim.tbl_extend("force", opts, { desc = "Split Horizontal" }))
keymap("n", "<leader>sc", "<cmd>close<CR>",   vim.tbl_extend("force", opts, { desc = "Close Split"      }))
keymap("n", "<leader>so", "<cmd>only<CR>",    vim.tbl_extend("force", opts, { desc = "Close Other Splits (keep this one)" }))

-- ── SPLIT RESIZE ────────────────────────────────────────────
-- Ctrl+Arrow keys to resize the current split
keymap("n", "<C-Up>",    "<cmd>resize +2<CR>",          opts)
keymap("n", "<C-Down>",  "<cmd>resize -2<CR>",          opts)
keymap("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- ── BUFFER MANAGEMENT ───────────────────────────────────────
keymap("n", "<S-l>",      "<cmd>bnext<CR>",     opts)
keymap("n", "<S-h>",      "<cmd>bprevious<CR>", opts)
keymap("n", "<leader>bd", "<cmd>bdelete<CR>",   vim.tbl_extend("force", opts, { desc = "Delete Buffer" }))
keymap("n", "<leader>1",  "<cmd>BufferLineGoToBuffer 1<CR>", opts)
keymap("n", "<leader>2",  "<cmd>BufferLineGoToBuffer 2<CR>", opts)
keymap("n", "<leader>3",  "<cmd>BufferLineGoToBuffer 3<CR>", opts)
keymap("n", "<leader>4",  "<cmd>BufferLineGoToBuffer 4<CR>", opts)
keymap("n", "<leader>5",  "<cmd>BufferLineGoToBuffer 5<CR>", opts)

-- ── NEW BUFFER ─────────────────────────────────────────────
keymap("n", "<leader>bn", "<cmd>enew<CR>",        vim.tbl_extend("force", opts, { desc = "New Buffer"          }))
keymap("n", "<leader>bD", "<cmd>bdelete!<CR>",    vim.tbl_extend("force", opts, { desc = "Force Delete Buffer" }))
keymap("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", vim.tbl_extend("force", opts, { desc = "Close Other Buffers" }))


-- ── VISUAL MODE ─────────────────────────────────────────────
keymap("v", "<",  "<gv",               opts)
keymap("v", ">",  ">gv",               opts)
keymap("v", "J",  ":m '>+1<CR>gv=gv", opts)
keymap("v", "K",  ":m '<-2<CR>gv=gv", opts)

-- ── CLIPBOARD ───────────────────────────────────────────────
keymap("n", "<leader>d", '"_d',  opts)
keymap("v", "<leader>d", '"_d',  opts)
keymap("x", "<leader>p", '"_dP', opts)

-- ── FILE EXPLORER ───────────────────────────────────────────
-- Toggle explorer
keymap("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>", vim.tbl_extend("force", opts, { desc = "Toggle Explorer" }))

-- Track last used root
vim.g.nvim_tree_last_root = vim.fn.expand("~")

local function open_at(root)
  vim.g.nvim_tree_last_root = root
  require("nvim-tree.api").tree.change_root(root)
  require("nvim-tree.api").tree.open()
end

-- Open explorer at specific locations
keymap("n", "<leader>eh", function() open_at(vim.fn.expand("~")) end,
  vim.tbl_extend("force", opts, { desc = "Explorer: Home" }))
keymap("n", "<leader>ed", function() open_at("/mnt/songster") end,
  vim.tbl_extend("force", opts, { desc = "Explorer: Drives" }))
keymap("n", "<leader>er", function() open_at("/") end,
  vim.tbl_extend("force", opts, { desc = "Explorer: Root" }))

-- Toggle explorer at current file location
keymap("n", "<leader>ee", function()
  local api = require("nvim-tree.api")
  if api.tree.is_visible() then
    api.tree.close()
  else
    local dir = vim.fn.expand("%:p:h")
    if dir == "" or dir == "." then dir = vim.fn.getcwd() end
    open_at(dir)
  end
end, vim.tbl_extend("force", opts, { desc = "Explorer: Current Folder" }))


-- ── TELESCOPE ───────────────────────────────────────────────
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>",                vim.tbl_extend("force", opts, { desc = "Find Files"    }))
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",                 vim.tbl_extend("force", opts, { desc = "Live Grep"     }))
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>",                   vim.tbl_extend("force", opts, { desc = "Buffers"       }))
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",                 vim.tbl_extend("force", opts, { desc = "Help"          }))
keymap("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",                   vim.tbl_extend("force", opts, { desc = "Keymaps"       }))

-- ── TERMINAL ────────────────────────────────────────────────
keymap("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", vim.tbl_extend("force", opts, { desc = "Toggle Terminal" }))
keymap("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      vim.tbl_extend("force", opts, { desc = "Float Terminal"  }))

-- ── LIVE SERVER ─────────────────────────────────────────────
local live_server_term = nil
keymap("n", "<leader>lp", function()
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm not loaded", vim.log.levels.ERROR)
    return
  end
  local Terminal = toggleterm.Terminal
  if live_server_term and live_server_term:is_open() then
    live_server_term:close()
    live_server_term:shutdown()
    live_server_term = nil
    vim.notify("  Live Server stopped", vim.log.levels.INFO)
  else
    local dir  = vim.fn.expand("%:p:h")
    local file = vim.fn.expand("%:t")
    if dir == "" then dir = vim.fn.getcwd() end
    local url  = "http://localhost:5500/" .. file
    live_server_term = Terminal:new({
      cmd       = string.format("live-server '%s' --port=5500 --no-browser", dir:gsub("'", "'\''")),
      hidden    = true,
      direction = "float",
      on_open   = function(_)
        vim.defer_fn(function()
          vim.fn.jobstart({ "xdg-open", url }, { detach = true })
          vim.notify("  Live Server → " .. url, vim.log.levels.INFO)
        end, 1500)
      end,
      on_exit = function()
        live_server_term = nil
        vim.notify("  Live Server stopped", vim.log.levels.INFO)
      end,
    })
    live_server_term:open()
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle Live Server" }))

-- ── MARKDOWN PREVIEW ────────────────────────────────────────
keymap("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", vim.tbl_extend("force", opts, { desc = "Markdown Preview" }))


-- ── LSP ─────────────────────────────────────────────────────
keymap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>",  opts)
keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>",  opts)

-- ── ZEN MODE ────────────────────────────────────────────────
keymap("n", "<leader>z",  "<cmd>ZenMode<CR>",  vim.tbl_extend("force", opts, { desc = "Zen Mode" }))
keymap("n", "<leader>tw", "<cmd>Twilight<CR>", vim.tbl_extend("force", opts, { desc = "Twilight" }))

-- ── SEARCH & REPLACE ────────────────────────────────────────
keymap("n", "<leader>sr", '<cmd>lua require("spectre").open()<CR>',                          vim.tbl_extend("force", opts, { desc = "Search & Replace" }))
keymap("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', vim.tbl_extend("force", opts, { desc = "Search Word"       }))

-- ── CLEAR SEARCH HIGHLIGHT ──────────────────────────────────
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- ── CTRL+BACKSPACE — delete whole word ───────────────────────
-- Works in insert mode (like every normal text editor)
keymap("i", "<C-BS>", "<C-w>", opts)
-- Also map the terminal code some systems send for Ctrl+Backspace
keymap("i", "<C-H>",  "<C-w>", opts)

-- ── HOME / END ───────────────────────────────────────────────
-- Make Home/End work naturally in all modes
keymap("n", "<Home>", "^", opts)           -- first non-blank char
keymap("n", "<End>",  "$", opts)           -- end of line
keymap("i", "<Home>", "<C-o>^", opts)
keymap("i", "<End>",  "<C-o>$", opts)

-- ══════════════════════════════════════════════════════════════
-- CODE RUNNER — separate Alacritty window (right side, 30% width)
-- ══════════════════════════════════════════════════════════════

local function get_run_cmd(ft, file)
  local f   = vim.fn.shellescape(file)
  local dir = vim.fn.shellescape(vim.fn.fnamemodify(file, ":h"))
  local t   = vim.fn.shellescape(vim.fn.fnamemodify(file, ":t"))

  local map = {
    python     = "python3 -u " .. f,
    javascript = "node "        .. f,
    typescript = "ts-node "     .. f,
    sh         = "bash "        .. f,
    bash       = "bash "        .. f,
    lua        = "lua "         .. f,
    c          = "cd " .. dir .. " && gcc "  .. t .. " -o /tmp/_nvim_c   && /tmp/_nvim_c",
    cpp        = "cd " .. dir .. " && g++ "  .. t .. " -o /tmp/_nvim_cpp && /tmp/_nvim_cpp",
    html       = nil,  -- handled by live-server (<leader>lp)
  }
  return map[ft]
end

keymap("n", "<leader>rr", function()
  local ft   = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("Save the file first!", vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! write")

  local run_cmd = get_run_cmd(ft, file)
  if not run_cmd then
    if ft == "html" or ft == "css" then
      vim.notify("  Use <leader>lp to start Live Server", vim.log.levels.INFO)
    else
      vim.notify("No runner for: " .. ft, vim.log.levels.WARN)
    end
    return
  end

  local fname   = vim.fn.fnamemodify(file, ":t")
  local script  = vim.fn.expand("~/.config/nvim/runner_launch.sh")

  vim.fn.jobstart({
    "bash", script,
    fname,
    run_cmd,
  }, { detach = true })

end, vim.tbl_extend("force", opts, { desc = "Run File (kitty)" }))

-- ── OBSIDIAN / NOTES ────────────────────────────────────────
-- Toggle checkbox [ ] → [x] → [ ]
keymap("n", "<leader>ct", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("%[%s%]") then
    vim.api.nvim_set_current_line(line:gsub("%[%s%]", "[x]", 1))
  elseif line:match("%[x%]") then
    vim.api.nvim_set_current_line(line:gsub("%[x%]", "[ ]", 1))
  else
    -- No checkbox yet — add one at the start of text
    vim.api.nvim_set_current_line(line:gsub("^(%s*)", "%1- [ ] ", 1))
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle Checkbox" }))

-- ── GO TO DASHBOARD ─────────────────────────────────────────
keymap("n", "<leader>H", function()
  -- Close all buffers except current, then wipe current, then open dashboard
  vim.cmd("silent! %bdelete!")
  vim.cmd("enew")
  vim.cmd("setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile")
  require("alpha").start(false)
end, vim.tbl_extend("force", opts, { desc = "Go to Dashboard" }))

-- ── WORD WRAP TOGGLE ────────────────────────────────────────
vim.keymap.set("n", "<leader>ww", function()
  vim.opt.wrap = not vim.opt.wrap:get()
  vim.notify(vim.opt.wrap:get() and "  Word Wrap ON" or "  Word Wrap OFF", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Toggle Word Wrap" })
