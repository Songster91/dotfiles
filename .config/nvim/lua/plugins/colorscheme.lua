return {
  -- Disable LazyVim's default theme
  { "folke/tokyonight.nvim", enabled = false },

  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour                = "mocha",
      transparent_background = false,
      dim_inactive           = { enabled = true, shade = "dark", percentage = 0.15 },
      styles = {
        comments  = { "italic" },
        keywords  = { "bold" },
        functions = {},
        variables = {},
      },
      integrations = {
        nvimtree         = true,
        telescope        = { enabled = true, style = "nvchad" },
        which_key        = true,
        gitsigns         = true,
        mason            = true,
        cmp              = true,
        treesitter       = true,
        bufferline       = true,
        fidget           = true,
        indent_blankline = { enabled = true, scope_color = "lavender" },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors      = { "italic" },
            hints       = { "italic" },
            warnings    = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors      = { "underline" },
            hints       = { "underline" },
            warnings    = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
  },
}
