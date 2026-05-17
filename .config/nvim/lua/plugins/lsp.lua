-- ============================================================
-- plugins/lsp.lua — hooks into LazyVim's lspconfig mechanism
-- Uses opts.servers (LazyVim's way) — no vim.lsp.config calls
-- ============================================================

return {

  -- ── MASON ───────────────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  -- ── MASON-LSPCONFIG ─────────────────────────────────────────
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "html",
        "cssls",
        "ts_ls",
        "tailwindcss",
        "emmet_ls",
        "jsonls",
        "pyright",
        "bashls",
        "marksman",
      },
      automatic_installation = true,
    },
  },

  -- ── SCHEMASTORE ─────────────────────────────────────────────
  { "b0o/schemastore.nvim", lazy = true },

  -- ── NVIM-LSPCONFIG — server configuration ───────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim" },
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "●",
          spacing = 4,
          severity = { min = vim.diagnostic.severity.WARN },
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always", max_width = 80 },
      },
      inlay_hints = { enabled = false },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.fn.expand("$VIMRUNTIME/lua"),
                  vim.fn.stdpath("config") .. "/lua",
                },
              },
              diagnostics = { globals = { "vim" } },
              telemetry = { enable = false },
              hint = { enable = true },
            },
          },
        },
        ts_ls = {
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
              },
            },
          },
        },
        pyright = {
          single_file_support = false,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = { "tw`([^`]*)", "tw\\('([^']*)'\\)" },
              },
            },
          },
        },
        html = {},
        cssls = {},
        bashls = {},
        marksman = {},
        emmet_ls = {},
      },
      -- jsonls needs schemastore — evaluated lazily via setup handler
      setup = {
        jsonls = function(_, server_opts)
          server_opts.settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          }
        end,
      },
    },
  },

  -- ── CUSTOM LSPATTACH KEYMAPS ─────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local map = function(k, f, desc)
            vim.keymap.set("n", k, f, { buffer = ev.buf, noremap = true, silent = true, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("gr", vim.lsp.buf.references, "Find References")
          map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>la", vim.lsp.buf.code_action, "Code Action")

        end,
      })
    end,
  },

  -- ── FIDGET ──────────────────────────────────────────────────
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        notification = { window = { winblend = 0, border = "none", align = "bottom", avoid = { "NvimTree" } } },
        progress = { display = { done_ttl = 1, progress_icon = { pattern = "dots" } } },
      })
    end,
  },
}
