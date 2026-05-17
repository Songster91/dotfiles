-- nvim-cmp extra from lazy.lua already enables nvim-cmp.
-- This file provides the full config override.

return {

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip" },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      local kind_icons = {
        Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
        Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "",
        Module = "", Property = "󰜢", Unit = "", Value = "󰎠",
        Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
        File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
        Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕",
        TypeParameter = "󰅲",
      }

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered({
            border       = "rounded",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({ border = "rounded" }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select   = false,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp",                priority = 1000 },
          { name = "luasnip",                 priority = 750  },
          { name = "nvim_lsp_signature_help", priority = 700  },
          { name = "buffer",                  priority = 500  },
          { name = "path",                    priority = 250  },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = "[LSP]", luasnip = "[Snippet]",
              buffer   = "[Buffer]", path   = "[Path]",
            })[entry.source.name]
            if string.len(vim_item.abbr) > 30 then
              vim_item.abbr = string.sub(vim_item.abbr, 1, 30) .. "..."
            end
            return vim_item
          end,
        },
        enabled = function()
          local context = require("cmp.config.context")
          if vim.api.nvim_get_mode().mode == "c" then return true end
          return not context.in_treesitter_capture("comment")
            and not context.in_syntax_group("Comment")
        end,
        experimental = { ghost_text = true },
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version      = "v2.*",
    build        = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({
        history             = true,
        updateevents        = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })
      vim.keymap.set({ "i", "s" }, "<C-f>", function()
        if luasnip.jumpable(1) then luasnip.jump(1) end
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-b>", function()
        if luasnip.jumpable(-1) then luasnip.jump(-1) end
      end, { silent = true })
    end,
  },
}
