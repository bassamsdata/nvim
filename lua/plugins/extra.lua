if vim.env.NVIM_TESTING then
  return {}
end

return {
  {
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
    config = function()
      require("dropbar").setup({
        bar = {
          enable = function(buf, win, _)
            return not vim.w[win].winbar_no_attach
              and vim.api.nvim_buf_is_valid(buf)
              and vim.api.nvim_win_is_valid(win)
              and vim.wo[win].winbar == ""
              and vim.fn.win_gettype(win) == ""
              and vim.bo[buf].ft ~= "help"
              and ((pcall(vim.treesitter.get_parser, buf)) and true or false)
          end,
        },
      })
      local dropbar_api = require("dropbar.api")
      -- stylua: ignore start 
      vim.keymap.set( "n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set( "n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set( "n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
      -- stylua: ignore end

      local function toggle_dropbar()
        local win = vim.api.nvim_get_current_win()
        if vim.w[win].winbar_no_attach then
          -- Re-enable dropbar
          vim.w[win].winbar_no_attach = false
          vim.wo[win].winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
          vim.notify("Dropbar enabled", vim.log.levels.INFO)
        else
          -- Disable dropbar
          vim.wo[win].winbar = ""
          vim.w[win].winbar_no_attach = true
          vim.notify("Dropbar disabled", vim.log.levels.INFO)
        end
      end

      -- Add the keymap (you can change the keybinding as needed)
      vim.keymap.set("n", "<leader>ur", toggle_dropbar, { desc = "Toggle dropbar" })
    end,
  },
  {
    "Vallen217/eidolon.nvim",
    -- lazy = false,
    config = function() end,
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = true, -- disable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = false },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {
          lotusWhite5 = "#eae4b8",
          lotusWhite0 = "#ddd5ac",
        },
        theme = {
          wave = {},
          lotus = {},
          dragon = {},
          all = {
            ui = {
              float = { bg = "none", bg_border = "none" },
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors) -- add/modify highlights
        return {}
      end,
      theme = "wave", -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        light = "lotus",
      },
    },
  },
  {
    "hat0uma/csvview.nvim",
    ft = "csv",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "csv",
        callback = function()
          require("csvview").enable()
        end,
      })
      require("csvview").setup({
        view = {
          display_mode = "border",
        },
      })
    end,
  },
  {
    "marcussimonsen/let-it-snow.nvim",
    cmd = "LetItSnow", -- Wait with loading until command is run
    opts = {},
  },
  {
    "mcauley-penney/visual-whitespace.nvim",
    enabled = function()
      return vim.fn.has("nvim-0.11") == 1
    end,
    branch = "incremental-hl",
    event = "BufReadPost",
    opts = {},
  },
  -- {
  --   "atiladefreitas/dooing",
  --   keys = { "<leader>to" },
  --   cmd = "Dooing",
  --   config = function()
  --     require("dooing").setup({
  --       save_path = vim.fn.stdpath("data") .. "/dooing_todos.json",
  --       keymaps = {
  --         toggle_window = "<leader>to",
  --       },
  --       prioritization = true,
  --     })
  --   end,
  -- },
  {
    "sphamba/smear-cursor.nvim",
    cond = not (vim.g.neovide or vim.g.gui_vimr),
    event = "BufReadPost",
    opts = {

      -- Cursor color. Defaults to Normal gui foreground color
      -- cursor_color = "#d3cdc3",
      -- Background color. Defaults to Normal gui background color
      -- normal_bg = "#282828",
      -- Smear cursor when switching buffers
      smear_between_buffers = false,
      -- Smear cursor when moving within line or to neighbor lines
      smear_between_neighbor_lines = true,
      -- Use floating windows to display smears outside buffers.
      -- May have performance issues with other plugins.
      use_floating_windows = false,
      -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
      -- Smears will blend better on all backgrounds.
      legacy_computing_symbols_support = false,
      -- Attempt to hide the real cursor when smearing.
      hide_target_hack = true,
      -- How fast the smear's head moves towards the target.
      -- 0: no movement, 1: instantaneous
      stiffness = 0.7,
      -- How fast the smear's tail moves towards the target.
      -- 0: no movement, 1: instantaneous
      -- trailing_stiffness = 0.3, -- default =0.3
      -- Controls if middle points are closer to the head or the tail.
      -- < 1: closer to the tail, > 1: closer to the head
      trailing_exponent = 0, -- default =1
      gamma = 3, -- color blending -- default = 2.2
    },
  },
  {
    "leath-dub/snipe.nvim",
    keys = {
      {
        "gl",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    opts = {},
  },
  { "meznaric/key-analyzer.nvim", cmd = "KeyAnalyzer", opts = {} },
  {
    "nvchad/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      timeout = 3,
      maxkeys = 5,
      position = "bottom-center",
    },
  },
  {
    "frankroeder/parrot.nvim",
    cmd = { "PrtChatToggle", "PrtRewrite", "PrtAsk", "PrtAsk" },
    -- tag = "v0.3.9",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          pplx = {
            api_key = os.getenv("PERPLEXITY_API_KEY"),
            -- OPTIONAL
            -- gpg command
            -- api_key = { "gpg", "--decrypt", vim.fn.expand("$HOME") .. "/pplx_api_key.txt.gpg"  },
            -- macOS security tool
            -- api_key = { "/usr/bin/security", "find-generic-password", "-s pplx-api-key", "-w" },
          },
          openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
          },
          anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },
          mistral = {
            api_key = os.getenv("MISTRAL_API_KEY"),
          },
          gemini = {
            api_key = os.getenv("GEMINI_API_KEY"),
          },
          ollama = {}, -- provide an empty list to make provider available
        },
      })
    end,
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      default_mappings = false,
      mappings = {
        i = {
          j = {
            -- These can all also be functions
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        c = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        t = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        s = {
          j = {
            k = "<Esc>",
          },
        },
      },
    },
  },

  {
    "2kabhishek/nerdy.nvim",
    dependencies = { "echasnovski/mini.pick" },
    cmd = "Nerdy",
  },

  {
    "lewis6991/hover.nvim",
    event = "BufReadPost",
    config = function()
      require("hover").setup({
        init = function()
          -- Require providers
          require("hover.providers.lsp")
          -- require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          -- require('hover.providers.dap')
          require("hover.providers.man")
          require("hover.providers.dictionary")
        end,
        preview_opts = {
          border = "rounded",
          max_width = 80,
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
        mouse_providers = {
          "LSP",
        },
        mouse_delay = 1000,
      })

      -- stylua: ignore start
      vim.keymap.set("n",  "K",  require("hover").hover,        { desc = "hover.nvim" })
      vim.keymap.set( "n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
      -- vim.keymap.set("n",  "<C-p>", function() require("hover").hover_switch("previous") end, { desc = "hover.nvim (previous source)" })
      -- vim.keymap.set("n",  "<C-n>", function() require("hover").hover_switch("next") end,     { desc = "hover.nvim (next source)" })
      -- stylua: ignore end

      -- Mouse support
      vim.keymap.set(
        "n",
        "<MouseMove>",
        require("hover").hover_mouse,
        { desc = "hover.nvim (mouse)" }
      )
      vim.o.mousemoveevent = true
    end,
  },

  { "lewis6991/whatthejump.nvim", keys = { "<C-o>", "<C-i>", "<Backspace>" } },

  {
    "wildfunctions/myeyeshurt",
    event = "VeryLazy",
    opts = {
      initialFlakes = 10,
      flakeOdds = 20,
      maxFlakes = 750,
      nextFrameDelay = 175,
      useDefaultKeymaps = false,
      flake = { "󰼪 ", "󰜗 ", "" },
      minutesUntilRest = 20,
    },
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  {
    "kawre/neotab.nvim",
    cond = not vim.g.vscode or not vim.b.bigfile,
    event = "InsertEnter",
    opts = {},
  },

  { "laytan/cloak.nvim", cmd = "CloakToggle", ft = "sh", opts = {} },
}
