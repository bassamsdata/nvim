if vim.env.NVIM_TESTING then
  return {}
end
local function get_bufnrs() -- this fn from Nv-macro, thanks
  return vim.b.bigfile and {} or { vim.api.nvim_get_current_buf() }
end

-- Initialize global variable for cmp-nvim toggle
vim.g.cmp_enabled = true
return {
  {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    enabled = function()
      return not vim.b.bigfile
    end,
    event = { "CmdlineEnter", "InsertEnter" },
    dependencies = { "iguanacucumber/magazine.nvim", name = "nvim-cmp" },
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "LspAttach",
  },
  {
    "hrsh7th/cmp-cmdline",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "CmdlineEnter",
    dependencies = { "iguanacucumber/magazine.nvim", name = "nvim-cmp" },
  },
  {
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp", -- Otherwise highlighting gets messed up
    enabled = function()
      return not vim.b.bigfile
    end,
    cond = not vim.g.vscode,
    event = { "LspAttach", "InsertEnter" },
    dependencies = {
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      -- local neocodeium = require("neocodeium")

      cmp.event:on("menu_opened", function()
        if vim.g.codeium_enabled == true then
          return vim.fn["codeium#Clear"]()
        end
      end)

      cmp.setup({
        enabled = function()
          return not vim.b.bigfile
        end,
        preselect = cmp.PreselectMode.None, -- this is espically for gopls lsp
        view = {
          entries = {
            follow_cursor = false,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
          }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-,>"] = cmp.mapping.complete(), -- show completion suggestions
          ["<C-j>"] = cmp.mapping.complete({ -- trigger ai sources only
            config = {
              sources = {
                { name = "codeium" },
                { name = "cody" },
              },
            },
          }),
          ["<C-e>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
              -- return vim.fn["codeium#Complete"]()
            else
              fallback()
            end
          end),
          ["<C-l>"] = cmp.mapping.close(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if neocodeium.visible() then
              neocodeium.accept()
            -- elseif cmp.visible() then
            --   cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              fallback()
            end
          end, { "i", "s", "c" }),
        }),
        -- sources for autocompletion
        sources = cmp.config.sources({
          { name = "supermaven", group_index = 1, priority = 100 },
          { name = "codeium", group_index = 2, priority = 50 },
          { name = "cody", group_index = 3, priority = 25 },
          { name = "otter", max_item_count = 20 },
          { name = "cmp_r" },
          { name = "nvim_lsp", max_item_count = 50 },
          {
            name = "buffer",
            max_item_count = 8,
            option = {
              get_bufnrs = get_bufnrs,
            },
          }, -- text within current buffer
          { name = "path", priority = 150 }, -- file system paths
        }),

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, vim_item)
            local icon, hl = require("mini.icons").get("lsp", vim_item.kind)
            vim_item.kind = icon -- .. " " .. vim_item.kind
            vim_item.kind_hl_group = hl
            -- Thanks to @Bekaboo for the clamp function
            local function clamp(field, min_width, max_width)
              if not vim_item[field] or not type(vim_item) == "string" then
                return
              end
              -- In case that min_width > max_width
              if min_width > max_width then
                min_width, max_width = max_width, min_width
              end
              local field_str = vim_item[field]
              local field_width = vim.fn.strdisplaywidth(field_str)
              if field_width > max_width then
                local former_width = math.floor(max_width * 0.6)
                local latter_width = math.max(0, max_width - former_width - 1)
                vim_item[field] = string.format(
                  "%s…%s",
                  field_str:sub(1, former_width),
                  field_str:sub(-latter_width)
                )
              elseif field_width < min_width then
                vim_item[field] = string.format("%-" .. min_width .. "s", field_str)
              end
            end
            -- stylua: ignore start
            clamp( "abbr", vim.go.pw, math.max(20, math.ceil(vim.o.columns * 0.4)))
            -- clamp( "menu", 0,         math.max(16, math.ceil(vim.o.columns * 0.2)))
            -- stylua: ignore end
            return vim_item
          end,
        },
        window = {
          -- completion = {
          -- 	winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          -- },
          completion = {
            col_offset = -3,
            side_padding = 0,
            border = "rounded",
            winhighlight = "",
          },
          documentation = {
            max_width = 80,
            max_height = 20,
            border = "rounded",
          },
          -- documentation = {
          --   border = "rounded",
          --   winhighlight = "", -- or winhighlight
          --   max_height = math.floor(vim.o.lines * 0.5),
          --   max_width = math.floor(vim.o.columns * 0.4),
          -- },
        },
        -- experimental = {
        -- ghost_text = { hl_group = "LspCodeLens" },
        -- },
      })
      cmp.setup.cmdline({ "/", "?" }, {
        -- view = {
        -- 	entries = { name = "wildmenu", separator = "|" },
        -- },
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(function()
            cmp.select_next_item()
          end, { "c" }),
        }),
        sources = {
          {
            name = "buffer",
          },
        },
      })
      cmp.setup.cmdline(":", {
        -- view = {
        -- 	entries = { name = "wildmenu", separator = "|" },
        -- },
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(function()
            cmp.select_next_item()
          end, { "c" }),
        }),
        sources = {
          { name = "path", group_index = 1 },
          {
            name = "cmdline",
            group_index = 2,
          },
        },
      })
    end,
  },
}
