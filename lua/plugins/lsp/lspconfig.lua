---@diagnostic disable: undefined-field
if vim.env.NVIM_TESTING then
  return {}
end
return {
  -- {
  --   "Dan7h3x/signup.nvim",
  --   event = "LspAttach",
  --   branch = "main",
  --   opts = {
  --     border = "solid",
  --     winblend = 10,
  --     max_height = 10,
  --     max_width = 60,
  --     floating_window_above_cur_line = true,
  --     preview_parameters = true,
  --     debounce_time = 30,
  --     dock_toggle_key = "<Leader>cp",
  --     toggle_key = "<c-;>",
  --     dock_mode = {
  --       enabled = false,
  --       position = "bottom",
  --       height = 3,
  --       padding = 1,
  --     },
  --     render_style = {
  --       separator = true,
  --       compact = true,
  --       align_icons = true,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("signup").setup(opts)
  --   end,
  -- },

  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "LspAttach",
  --   opts = {
  --     bind = true,
  --     hint_enable = false,
  --     handler_opts = {
  --       border = "rounded",
  --     },
  --   },
  --   config = function(_, opts)
  --     require("lsp_signature").setup(opts)
  --     vim.keymap.set({ "n" }, "<C-S-k>", function()
  --       require("lsp_signature").toggle_float_win()
  --     end, { silent = true, noremap = true, desc = "toggle signature" })
  --   end,
  -- },

  {
    "neovim/nvim-lspconfig",
    enabled = function()
      return not vim.b.bigfile
    end,

    init = function()
      vim.api.nvim_create_autocmd("BufWinEnter", {
        nested = true,
        callback = function(info)
          local path = info.file
          if path == "" then
            return
          end

          local stat = vim.uv.fs_stat(path)
          if stat and stat.type == "file" then
            vim.api.nvim_del_autocmd(info.id)
            require("lspconfig")
            return true
          end
        end,
      })
    end,
    cmd = { "LspInfo", "LspStart" },
    -- event = "VeryLazy",
    event = {
      "BufReadPost",
      -- "BufNewFile"
    },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      cond = function()
        return not vim.g.vscode or not vim.b.bigfile
      end,
    },
    opts = {
      -- provide the code lenses.
      codelens = {
        enabled = true,
      },
      -- Enable lsp cursor word highlighting
      document_highlight = {
        enabled = true,
      },
    },

    config = function()
      -- I took this fn as is from Maria.
      --- Returns the editor's capabilities + some overrides.
      -- require("localModules._load")
      local client_capabilities = function()
        return vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          -- nvim-cmp supports additional completion capabilities, so broadcast that to servers.
          require("cmp_nvim_lsp").default_capabilities(),
          {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = false },
            },
          }
        )
      end
      -- import lspconfig plugin
      local lspconfig = require("lspconfig")
      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = client_capabilities()

      -- local lsp_signature = require("lsp_signature")
      -- if lsp_signature then
      --   lsp_signature.setup({
      --     hint_enable = true,
      --     bind = true,
      --     border = "rounded",
      --     wrap = false,
      --     max_width = 120,
      --   })
      -- end

      local signs = { Error = "✘", Warn = "󱐮", Hint = "◉", Info = "" }
      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = signs.Error,
            [vim.diagnostic.severity.WARN] = signs.Warn,
            [vim.diagnostic.severity.HINT] = signs.Hint,
            [vim.diagnostic.severity.INFO] = signs.Info,
          },
        },
        underline = true,
        update_in_insert = false, -- Don't update diagnostics in insert mode
        severity_sort = true, -- Sort diagnostics by severity
        float = {
          border = "rounded", -- Rounded border for floating window
          source = true, -- Show source of diagnostic in floating window
        },
      })

      local map = vim.keymap.set -- for conciseness
      local opts = { noremap = true, silent = true }
      local hover = vim.lsp.buf.hover
      vim.lsp.buf.hover = function()
        return hover({
          border = "rounded",
          max_height = math.floor(vim.o.lines * 0.5),
          max_width = math.floor(vim.o.columns * 0.4),
        })
      end

      local signature_help = vim.lsp.buf.signature_help
      vim.lsp.buf.signature_help = function()
        return signature_help({
          border = "rounded",
          focusable = false,
          max_height = math.floor(vim.o.lines * 0.5),
          max_width = math.floor(vim.o.columns * 0.4),
        })
      end

      require("lspconfig.ui.windows").default_options.border = "rounded"
      local on_attach = function(client, bufnr)
        opts.buffer = bufnr
        local methods = vim.lsp.protocol.Methods
        -- require("lsp_signature").on_attach({
        --   bind = true,
        --   hint_enable = false,
        --   handler_opts = {
        --     border = "rounded",
        --   },
        -- }, bufnr) -- Note: add in lsp client on-attach

        -- set keybinds
        map("n", "grr", vim.lsp.buf.references, opts)
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "gi", "<cmd>Pick lsp scope='implementation'<CR>", opts) -- show lsp implementations
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
        map("n", "grn", require("utils.lsp_rename").lsp_rename, opts) -- smart rename
        map("n", "<leader>D", "<cmd>Pick diagnostic scope='current'<CR>", opts) -- show  diagnostics for file
        map("n", "<leader>ud", function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end, opts)
        map(
          "n",
          "<leader>d",
          vim.diagnostic.open_float,
          { desc = "open floating diagnostic message" }
        ) -- show diagnostics for line
        map("n", "K", vim.lsp.buf.hover) -- show documentation for what is under cursor
        map("n", "<leader>rs", "<cmd>LspRestart<cr>") -- mapping to restart lsp if necessary
      end

      -- Change the Diagnostic symbols in the sign column (gutter)

      -- configure html server
      lspconfig["html"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure css server
      lspconfig["cssls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
      lspconfig["rust_analyzer"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure python server
      -- lspconfig["pyright"].setup({
      -- 	capabilities = capabilities,
      -- 	on_attach = on_attach,
      -- })

      require("lspconfig").pylance.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              deprecateTypingAliases = true,
              diagnosticSeverityOverrides = {
                reportDeprecated = "warning",
                reportGeneralTypeIssues = "warning",
                reportAttributeAccessIssue = "error",
              },
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = "partial",
                pytestParameters = true,
              },
            },
          },
        },
      })

      -- Find the root of a Python project, starting from file 'main.py'
      -- vim.fs.root(
      -- 	vim.fs.joinpath(vim.env.PWD, "main.py"),
      -- 	{ "pyproject.toml", "setup.py" }
      -- )
      -- lspconfig["basedpyright"].setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      --   settings = {
      --     basedpyright = {
      --       analysis = {
      --         typeCheckingMode = "strict",
      --         deprecateTypingAliases = true,
      --         diagnosticSeverityOverrides = {
      --           reportDeprecated = "warning",
      --         },
      --         inlayHints = {
      --           variableTypes = true,
      --           functionReturnTypes = true,
      --           callArgumentNames = true,
      --           -- pytestParameters = true,
      --         },
      --       },
      --     },
      --   },
      --   --   -- TODO: add this and modify it
      --   --   -- before_init = function(_, config)
      --   --   -- 	local default_venv_path =
      --   --   -- 		path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
      --   --   -- 	config.settings.python.pythonPath = default_venv_path
      --   --   -- end,
      -- })
      --
      -- configure r langauge server
      lspconfig["r_language_server"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
      lspconfig["taplo"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      lspconfig["gopls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            gofumpt = true,
            usePlaceholders = true,
            completeFunctionCalls = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = false,
              rangeVariableTypes = true,
            },
            -- codelens
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
            },
            semanticTokens = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
          },
          gofmt = true,
          --[[ init_options = {
                            usePlaceholders = true,
                            completeFunctionCalls = true,
                        }, ]]
        },
      })

      -- lspconfig["sqlls"].setup({
      -- 	capabilities = capabilities,
      -- 	on_attach = on_attach,
      -- cmd = { "sql-language-server", "up", "--method", "stdio" },
      -- 	filetypes = { "sql"},
      -- 	root_dir = function(_)
      -- 		return vim.loop.cwd()
      -- 	end,
      -- })
      -- configure r langauge server
      -- lspconfig["marksman"].setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      --   -- filetypes = { "markdown", "quarto" },
      -- })
      lspconfig["ruff"].setup({
        on_attach = on_attach,
        on_init = function(client)
          if client.name == "ruff" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
      })
      lspconfig["v_analyzer"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
      -- lspconfig["harper_ls"].setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      -- })

      -- configure lua server (with special settings)
      lspconfig["lua_ls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        ---@param client vim.lsp.Client
        on_init = function(client)
          local path = client.workspace_folders
            and client.workspace_folders[1]
            and client.workspace_folders[1].name
          if
            not path
            or not (
              vim.uv.fs_stat(path .. "/.luarc.json")
              or vim.uv.fs_stat(path .. "/.luarc.jsonc")
            )
          then
            client.config.settings =
              vim.tbl_deep_extend("force", client.config.settings, {
                Lua = {
                  runtime = {
                    version = "LuaJIT",
                  },
                  workspace = {
                    checkThirdParty = false,
                    library = {
                      vim.env.VIMRUNTIME,
                      "${3rd}/luv/library",
                    },
                  },
                },
              })
            client:notify(
              vim.lsp.protocol.Methods.workspace_didChangeConfiguration,
              { settings = client.config.settings }
            )
          end

          return true
        end,
        settings = {
          Lua = {
            -- Using stylua for formatting.
            format = { enable = false },
            hint = {
              enable = true,
              arrayIndex = "Enable",
              paramType = true,
              setType = false,
            },
            completion = { callSnippet = "Replace" },
          },
        },
      })
    end,
  },
}
