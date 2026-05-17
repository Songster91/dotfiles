-- ============================================================
-- config/options.lua
-- ============================================================

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

local opt = vim.opt

-- ── LINE NUMBERS ────────────────────────────────────────────
opt.number = true
opt.relativenumber = true

-- ── TABS & INDENTATION ──────────────────────────────────────
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- ── APPEARANCE ──────────────────────────────────────────────
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cmdheight = 0
opt.pumheight = 10
opt.showmode = false
opt.laststatus = 3
opt.cursorline = true
opt.fillchars = {
  eob = " ",
  fold = " ",
  vert = "│",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
opt.listchars = { tab = "→ ", trail = "·" }

-- ── COLORCOLUMN ─────────────────────────────────────────────
opt.colorcolumn = "93"

-- ── SEARCH ──────────────────────────────────────────────────
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- ── SPLITS ──────────────────────────────────────────────────
opt.splitbelow = true
opt.splitright = true

-- ── PERFORMANCE ─────────────────────────────────────────────
opt.lazyredraw = false
opt.updatetime = 200
opt.timeoutlen = 400
opt.ttimeoutlen = 0
opt.redrawtime = 1500
opt.synmaxcol = 240
opt.regexpengine = 0  -- auto-select (safer)

-- ── FILES ───────────────────────────────────────────────────
opt.undofile = true
opt.undolevels = 1000
opt.backup = false
opt.swapfile = false
opt.fileencoding = "utf-8"
opt.autoread = true

-- ── SCROLLING ───────────────────────────────────────────────
opt.scrolloff = 8
opt.sidescrolloff = 8

-- ── COMPLETION ──────────────────────────────────────────────
opt.completeopt = "menuone,noselect"
opt.shortmess:append("c")

-- ── CLIPBOARD ───────────────────────────────────────────────
opt.clipboard = "unnamedplus"

-- ── WRAP ────────────────────────────────────────────────────
opt.wrap = false
opt.linebreak = true

-- ── FOLDS ───────────────────────────────────────────────────
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- ── MISC ────────────────────────────────────────────────────
opt.mouse = "a"
opt.mousemoveevent = true
opt.iskeyword:append("-")
-- NOTE: formatoptions are stripped per-buffer in autocmds.lua via BufEnter.
-- That autocmd is the correct place — filetype plugins re-add these flags,
-- so a one-time set here would be overwritten anyway.
opt.whichwrap:append("<,>,[,],h,l")
opt.confirm = true

-- ── COLORCOLUMN HIGHLIGHT ───────────────────────────────────
local function set_colorcolumn_hl()
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#3b3052" })
end
set_colorcolumn_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_colorcolumn_hl })

-- Disable LazyVim auto-format on save
vim.g.autoformat = false

-- ── PATH — ensure nvim inherits full shell PATH ─────────────
vim.env.PATH = vim.env.HOME .. "/.npm-global/bin:" .. vim.env.PATH
