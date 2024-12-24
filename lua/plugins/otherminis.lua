if vim.env.NVIM_TESTING then
  return {}
end
local ft = {
  "lua",
  "python",
  "norg",
  "quarto",
  "py",
  "go",
  "markdown",
  "R",
  "v",
  "yaml",
  "toml",
  "codecompanion",
}
return {
  {
    "echasnovski/mini.indentscope",
    -- lazy = true,
    ft = { "lua", "go", "r", "python", "quarto", "v" },
    cond = not vim.g.vscode,
    enabled = function()
      return not vim.b.bigfile or vim.bo.buftype == "markdown"
    end,
    config = function()
      local f = function(args)
        vim.b[args.buf].miniindentscope_disable = true
      end
      -- FIXME: remove this indentscop from terminals
      vim.api.nvim_create_autocmd(
        "Filetype",
        { pattern = { "markdown", "help", "Avante" }, callback = f }
      )
      local indentscope = require("mini.indentscope")
      -- require("utils.hi").blend_highlight_groups(
      --   { "MiniIndentscopeSymbol" },
      --   "Normal",
      --   "bg",
      --   0.7
      -- )
      -- vim.api.nvim_create_autocmd({ "ColorScheme" }, {
      --   group = vim.api.nvim_create_augroup(
      --     "MiniIndentscope",
      --     { clear = true }
      --   ),
      --   callback = function()
      --     require("utils.hi").blend_highlight_groups(
      --       { "MiniIndentscopeSymbol" },
      --       "Normal",
      --       "bg",
      --       0.7
      --     )
      --   end,
      -- })
      indentscope.setup({
        draw = {
          delay = 100,
          animation = indentscope.gen_animation.none(),
        },
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          object_scope = "ii",
          object_scope_with_border = "ai",

          goto_top = "[i",
          goto_bottom = "]i",
        },

        symbol = "│",
        options = { try_as_border = true },
      })
    end,
  },

  {
    "echasnovski/mini.map",
    cond = not vim.g.vscode,
    enabled = function()
      return not vim.b.bigfile
    end,
    ft = ft,
    config = function()
      local map = require("mini.map")
      local gen_integr = map.gen_integration
      if map then
        map.setup({
          integrations = {
            gen_integr.builtin_search(),
            gen_integr.diagnostic(),
            gen_integr.diff(),
          },
          window = {
            show_integration_count = false,
            width = 1,
            winblend = 0,
            zindex = 75,
          },
        })
        for _, key in ipairs({ "n", "N", "*" }) do
          vim.keymap.set(
            "n",
            key,
            key
              .. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
          )
        end

        vim.api.nvim_set_hl(0, "MiniMapNormal", { link = "Normal" })
        require("utils.hi").blend_highlight_groups(
          { "MiniMapSymbolView", "MiniMapSymbolLine" },
          "Normal",
          "bg",
          0.6
        )
        local autocmd = vim.api.nvim_create_autocmd
        local f = function(args)
          vim.schedule(function()
            map.open()
          end)
          if vim.fn.line("$") < 50 then
            vim.b[args.buf].minimap_disable = true
            map.close()
          end
          local excluded_ft = { "lazy", "netrw", "man", "help", "intro", "", "nofile" }
          if vim.tbl_contains(excluded_ft, vim.bo.ft) then
            map.close()
          end
        end

        -- autocmd({ "FileType" }, {
        --   group = vim.api.nvim_create_augroup("MiniMap", { clear = true }),
        --   pattern = "*",
        --   callback = f,
        -- })
        -- isse when resizing with the window manager and terminal is open,
        -- the minimap stays in place in the middle of screen :)
        autocmd({ "VimResized" }, {
          callback = function()
            if map.current then
              map.refresh()
            end
          end,
        })
        autocmd({ "FileType" }, {
          pattern = ft,
          callback = function()
            vim.schedule(function()
              map.open()
            end)
            local excluded_ft = { "lazy", "netrw", "man", "help", "intro", "", "nofile" }
            if vim.tbl_contains(excluded_ft, vim.bo.ft) then
              map.close()
            end
          end,
        })
        --
        autocmd({ "ColorScheme" }, {
          callback = function()
            vim.api.nvim_set_hl(0, "MiniMapNormal", { link = "Normal" })
            require("utils.hi").blend_highlight_groups(
              { "MiniMapSymbolView", "MiniMapSymbolLine" },
              "Normal",
              "bg",
              0.6
            )
          end,
        })
      end
    end,
  },

  {
    "echasnovski/mini.notify",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    keys = {
      {
        "<leader>un",
        function()
          require("mini.notify").clear()
        end,
        desc = "Clear notifications",
      },
    },
    config = function()
      local mini_notify = require("mini.notify")
      vim.notify = mini_notify.make_notify()
      local row = function()
        local has_statusline = vim.o.laststatus > 0
        local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
        return vim.o.lines - bottom_space
      end
      local id = mini_notify.add(
        "position_encoding param is required in vim.lsp.util.make_position_params. Defaulting to position encoding of the first client.",
        "WARN",
        "Comment"
      )
      mini_notify.remove(id)
      mini_notify.setup({
        window = {
          config = function()
            return {
              col = vim.o.columns - 2,
              row = row(),
              anchor = "SE",
              title = "Notification ❰❰",
              title_pos = "right",
              border = "none",
            }
          end,
          max_width_share = 0.6,
        },
      })
    end,
  },

  {
    "echasnovski/mini.misc",
    opts = {},
    keys = {
      {
        "<leader>mm",
        function()
          if not vim.g.neovide then
            require("mini.misc").zoom()
          else
            vim.notify("Not supported in neovide", vim.log.levels.WARN)
          end
        end,
        { desc = "Zoom" },
      },
    },
  },

  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "v", "n" } },
      { "gA", mode = { "v", "n" } },
    },
    opts = {},
  },

  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<localleader>x",
        function() -- credit to LazyVim for this implementation
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(
              ("Save changes to %q?"):format(vim.fn.bufname()),
              "&Yes\n&No\n&Cancel"
            )
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<localleader>X",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
}
