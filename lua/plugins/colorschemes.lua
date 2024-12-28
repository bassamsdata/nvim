if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "vague2k/vague.nvim",
    config = function()
      require("vague").setup({
        style = {
          -- "none" is the same thing as default. But "italic" and "bold" are also valid options
          boolean = "none",
          number = "none",
          float = "none",
          error = "none",
          comments = "italic",
          conditionals = "none",
          functions = "none",
          headings = "bold",
          operators = "none",
          strings = "italic",
          variables = "none",
        },
      })
    end,
  },
  {
    "kyazdani42/blue-moon",
    config = function() end,
  },
  {
    "echasnovski/mini.hues",
    lazy = true,
    opts = {
      background = "#0c1014",
      foreground = "#99d1ce",
      n_hues = 8,
      saturation = "medium",
      -- Accent color. One of: 'bg', 'fg', 'red', 'orange', 'yellow', 'green',
      -- 'cyan', 'azure', 'blue', 'purple'
      accent = "bg",
      -- Also can be set per plugin (see |MiniHues.config|).
      plugins = { default = true },
    },
  },
  {
    "ilof2/posterpole.nvim",
    lazy = true,
    -- event = "VeryLazy",
    -- priority = 1000,
    opts = {
      brightness = 4, -- negative numbers - darker, positive - lighter
    },
  },
  {
    "Shatur/neovim-ayu",
    -- FIX: add molten highlights
    name = "ayu",
    -- priority = 1000,
    opts = {
      overrides = {
        RenderMarkdownCode = { link = "Visual" },
        RenderMarkdownCodeInline = { link = "Visual" },
        -- TermCursor = { link = "Substitute" },
      },
    },
  },
  -- {
  --   "olivercederborg/poimandres.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("poimandres").setup({})
  --     vim.schedule(function()
  --       -- stylua: ignore start
  --       vim.api.nvim_set_hl(0,  "NormalFloat",       { link = "Normal" })
  --       vim.api.nvim_set_hl(0,  "Function",          { fg = "#5FB3A1" })
  --       vim.api.nvim_set_hl(0,  "LspReferenceText",  { bg = "#303340" })
  --       vim.api.nvim_set_hl( 0, "LspReferenceRead",  { link = "LspReferenceText" })
  --       vim.api.nvim_set_hl( 0, "LspReferenceWrite", { link = "LspReferenceText" })
  --       -- stylua: ignore end
  --     end)
  --   end,
  -- },
  {
    "fcancelinha/nordern.nvim",
    lazy = true,
    -- event = "VeryLazy",
    config = function()
      vim.cmd.hi("clear")
      require("nordern").setup({
        brighter_comments = false,
        brighter_conditionals = false, -- changes the color of booleans, enums and readonly to aurora yellow from light blue.
        italic_comments = true,
        transparent = false,
      })
      local hl = vim.api.nvim_set_hl
      hl(0, "Cursor", { link = "IncSearch" })
    end,
  },
  {
    "shmerl/neogotham",
    -- lazy = false,
    event = "VeryLazy",
    config = function()
      require("neogotham").setup({})
      vim.schedule(function()
        -- TODO: make neogotham a colorscheme with base16
        if vim.g.colors_name == "neogotham" then
          -- stylua: ignore start 
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#195466", bg = "#0c1014" })
          vim.api.nvim_set_hl(0, "Comment", { fg = "#195466", italic = true })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "#0c1014" })
          vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
          vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#091f2e" })
          -- stylua: ignore end
        end
        -- RenderMarkdownCodeInline = { bg = c.line },
        -- RenderMarkdownCode = { bg = c.line },
      end)
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("neogotham", { clear = true }),
        pattern = "neogotham",
        callback = function()
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#195466", bg = "#0c1014" })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "#0c1014" })
          vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
          vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#091f2e" })
        end,
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    -- lazy = false,
    event = "VeryLazy",
    opts = {
      plugins = {
        -- enable all plugins when not using lazy.nvim
        -- set to false to manually enable/disable plugins
        -- all = package.loaded.lazy == nil,
        -- uses your plugin manager to automatically enable needed plugins
        -- currently only lazy.nvim is supported
        auto = false,
        -- add any plugins here that you want to enable
        -- for all possible plugins, see:
        --   * https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
        -- telescope = true,
        cmp = true,
        treesitter = true,
        indent_blankline = true,
        -- notify = true,
        grugfar = true,
        indentmini = true,
        mini_clue = true,
        mini_diff = true,
        mini_files = true,
        mini_pick = true,
        mini_icons = true,
        mini_map = true,
        mini_surround = true,
        mini_notify = true,
        neogit = true,
      },
    },
  },
  {
    "rose-pine/neovim",
    lazy = false,
    -- event = "VeryLazy",
    name = "rose-pine",
    opts = {
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      enable = {
        terminal = true,
        legacy_highlights = false, -- Improve compatibility for previous versioffs of Neovim
        migrations = true, -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = false,
        transparency = false,
      },

      highlight_groups = {
        -- Normal = { fg = "#e0def4", bg = "black" },
        NormalFloat = { link = "Normal" },
        FloatBorder = { link = "NonText" },
        TermCursor = { link = "CurSearch" },
        StatusLineTerm = { link = "Statusline" },
        -- Comment = { fg = "foam" },
        -- VertSplit = { fg = "muted", bg = "muted" },
        ["@variable"] = { fg = "text", italic = false },
      },
    },
  },
  {
    "AlexvZyl/nordic.nvim",
    event = "VeryLazy",
    -- priority = 1000,
    config = function()
      -- local palette = require("nordic.colors")
      -- require("nordic").load()
      require("nordic").setup({
        on_highlight = function(highlights, palette)
          highlights.MatchParen = {
            fg = palette.yellow.dim,
            italic = false,
            underline = false,
            undercurl = false,
          }
          highlights["@parameter"] = {
            fg = palette.white_alt,
            italic = false,
            underline = false,
            undercurl = false,
          }
          highlights.Search = {
            fg = palette.yellow.dim,
            bg = palette.black0,
            italic = false,
            underline = false,
            undercurl = false,
          }
          highlights.MiniMapNormal = { link = "Normal" }
          highlights.RenderMarkdownCode = { link = "ColorColumn" }
          highlights.RenderMarkdownCodeInline = { link = "ColorColumn" }
          highlights.TermCursor = { link = "Substitute" }
          highlights.MiniIndentscopeSymbol = { link = "Delimiter" }
          highlights.LineNr4 = { fg = "#3B4261" }
          highlights.LineNr3 = { fg = "#4d71a0" }
          highlights.LineNr2 = { fg = "#6fc1cf" }
          highlights.LineNr1 = { fg = "#eeffee" }
          highlights.LineNr0 = { fg = "#FFFFFF", bg = "NONE", bold = true }
          highlights.NormalFloat = { link = "Normal" }
          highlights.FloatBorder = { fg = palette.gray5, bg = "NONE" }
          -- TODO: add Statusline Hoighlights
        end,
      })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    -- event = "VeryLazy",
    -- priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
      -- TODO: need to change the statusline higlights
      -- change minidiff amd minimap colors
      groups = {
        all = {
          NormalFloat = { link = "Normal" },
          RenderMarkdownCode = { link = "Visual" },
          RenderMarkdownCodeInline = { link = "Visual" },
          -- Cursor = { fg = "#fca5a5", bg = "#cecacd" },
        },
        -- orignial colors
        -- hi Normal guifg=#cdcecf guibg=#2e3440
        -- hi NormalFloat guifg=#cdcecf guibg=#232831
      },
    },
  },
  {
    "sam4llis/nvim-tundra",
    lazy = true,
    -- event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local hlgroups = {
        TermCursor = { fg = "#111827", bg = "#fca5a5" },
        MiniIndentscopeSymbol = { link = "Whitespace" },
      }

      for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
        vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
      end
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", opts = {}, lazy = true },
  {
    "sho-87/kanagawa-paper.nvim",
    lazy = false,
    -- event = "VeryLazy",
    -- priority = 500,
    opts = {
      dimInactive = false,
      typeStyle = { italic = false },
      overrides = function() -- override highlight groups
        return {
          NormalFloat = { link = "Normal" },
          RenderMarkdownCode = { bg = "#2a2a37" },
          RenderMarkdownCodeInline = { bg = "#2a2a37" },
          LspReferenceRead = { bg = "#3e4452" },
          LspReferenceWrite = { bold = true, underline = false, fg = "#dcd7ba" },
          WinBar = { link = "NonText" }, -- more visible
          TermCursor = { link = "Substitute" },
          -- LspReferenceText = { bg = "#3e4452" },
          -- LspReferenceWrite = { bg = "#3e4452" },
        }
      end,
    },
  },
}
