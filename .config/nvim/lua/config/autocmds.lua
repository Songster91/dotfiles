-- ============================================================
-- core/autocmds.lua
-- ============================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ── HIGHLIGHT ON YANK ──────────────────────────────────────
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── DISABLE COMMENT CONTINUATION — ROOT FIX ────────────────
-- Neovim by default continues comments when you press Enter or o/O
-- This kills that behavior for every single filetype, every buffer
-- So Enter always creates a CLEAN empty line, never a comment line
augroup("NoCommentContinuation", { clear = true })
autocmd("BufEnter", {
  group    = "NoCommentContinuation",
  pattern  = "*",
  callback = function()
    -- Remove these formatoptions flags:
    -- r = auto-insert comment leader on Enter (in insert mode)
    -- o = auto-insert comment leader on o/O (in normal mode)
    -- c = auto-wrap comments
    vim.opt_local.formatoptions:remove({ "r", "o", "c" })
  end,
})

-- ── REMOVE TRAILING WHITESPACE ON SAVE ─────────────────────
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group   = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local skip = { diff=1, gitcommit=1, gitrebase=1, TelescopePrompt=1 }
    if skip[vim.bo.filetype] or not vim.bo.modifiable then return end
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- ── RESTORE CURSOR POSITION ────────────────────────────────
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark   = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── AUTO-RESIZE SPLITS ─────────────────────────────────────
augroup("AutoResize", { clear = true })
autocmd("VimResized", {
  group   = "AutoResize",
  command = "tabdo wincmd =",
})

-- ── FILETYPE-SPECIFIC INDENT ───────────────────────────────
augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
  group   = "FileTypeIndent",
  pattern = { "html","css","javascript","typescript",
              "javascriptreact","typescriptreact","json","yaml" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})
autocmd("FileType", {
  group   = "FileTypeIndent",
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
  end,
})

-- ── CLOSE CERTAIN WINDOWS WITH Q ───────────────────────────
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group   = "CloseWithQ",
  pattern = { "help","qf","notify","lspinfo","startuptime","checkhealth" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer=true, silent=true })
  end,
})

-- ── DISABLE LINE NUMBERS IN TERMINAL ───────────────────────
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  callback = function()
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- ── COMMENTSTRING FOR ALL COMMON FILETYPES ──────────────────
augroup("CommentString", { clear = true })
autocmd("FileType", {
  group = "CommentString",
  pattern = {
    "css", "scss", "sass", "less",
  },
  callback = function() vim.bo.commentstring = "/* %s */" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = {
    "python", "bash", "sh", "zsh", "fish",
    "conf", "config", "ini", "hyprlang", "toml",
    "yaml", "dockerfile", "gitconfig", "gitignore",
    "r", "ruby", "perl", "cmake",
  },
  callback = function() vim.bo.commentstring = "# %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "lua" },
  callback = function() vim.bo.commentstring = "-- %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = {
    "javascript", "typescript", "javascriptreact", "typescriptreact",
    "java", "c", "cpp", "cs", "go", "rust", "swift", "kotlin",
    "dart", "scala", "groovy", "jsonc",
  },
  callback = function() vim.bo.commentstring = "// %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "vim" },
  callback = function() vim.bo.commentstring = '" %s' end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "sql" },
  callback = function() vim.bo.commentstring = "-- %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "html", "xml", "svg" },
  callback = function() vim.bo.commentstring = "<!-- %s -->" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "txt", "text", "markdown", "md" },
  callback = function() vim.bo.commentstring = "# %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "haskell", "elm" },
  callback = function() vim.bo.commentstring = "-- %s" end,
})
autocmd("FileType", {
  group = "CommentString",
  pattern = { "matlab", "octave" },
  callback = function() vim.bo.commentstring = "%% %s" end,
})
