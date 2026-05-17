-- ============================================================
-- config/lazy.lua — LazyVim bootstrap
-- ============================================================

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to continue...", "" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core — catppuccin as colorscheme
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts   = { colorscheme = "catppuccin" },
    },
    -- Use telescope (instead of snacks.picker / fzf-lua)
    { import = "lazyvim.plugins.extras.editor.telescope" },
    -- Use nvim-cmp (instead of blink.cmp)
    { import = "lazyvim.plugins.extras.coding.nvim-cmp" },
    -- Your plugins
    { import = "plugins" },
  },
  defaults         = { lazy = false, version = false },
  install          = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker          = { enabled = true, notify = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "rplugin", "tarPlugin", "toml", "tutor", "zipPlugin",
      },
    },
  },
})
