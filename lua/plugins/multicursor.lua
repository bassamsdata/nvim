return {
  {
    "jake-stewart/multicursor.nvim",
    lazy = true,
    -- commit = "2656f2d",
    keys = { "<c-n>", "<c-p>", "<up>", "<down>" },
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      -- use MultiCursorCursor and MultiCursorVisual to customize
      -- additional cursors appearance
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "TermCursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

      vim.keymap.set("n", "<esc>", function()
        if mc.cursorsEnabled() then
          mc.firstCursor()
          mc.clearCursors()
          vim.cmd.noh()
          if not vim.g.neovide then
            require("smear_cursor").enabled = true
          end
        else
          vim.cmd.noh()
        end
      end)

      ---@param key string
      ---@param action fun()
      local function checkCursor(key, action)
        return function()
          if mc.cursorsEnabled() then
            action()
          else
            vim.cmd.norm(key)
          end
        end
      end

      if not vim.g.neovide then
        require("smear_cursor").enabled = not mc.cursorsEnabled()
      end
      -- stylua: ignore start 
      local map = vim.keymap.set
      map("v", "S", checkCursor("S", mc.splitCursors))
      map( { "n", "v" }, "<left>", checkCursor("<left>", mc.nextCursor))
      map( { "n", "v" }, "<right>", checkCursor("<right>", mc.prevCursor))
      -- add cursors above/below the main cursor
      map({ "n","v" },  "<up>",   function() mc.addCursor("k") end)
      map({ "n","v" },  "<down>", function() mc.addCursor("j") end)
      -- add a cursor and jump to the next word under cursor
      map({ "n","v" },  "<c-n>",  function() mc.addCursor("*") end)
      -- jump to the next word under cursor but do not add a cursor
      map({ "n","v" },  "<c-s>",  function() mc.skipCursor("*") end)
      -- delete the main cursor
      map({"n", "v"},     "<leader>x", mc.deleteCursor)
      -- add and remove cursors with control + left click
      map("n",  "<c-leftmouse>", mc.handleMouse)
      -- stylua: ignore end
      map("v", "gI", mc.insertVisual)
      map("v", "A", mc.appendVisual)
      -- bring back cursors if you accidentally clear them
      map("n", "<leader>gv", mc.restoreCursors)

      -- Align cursor columns.
      map("v", "<leader>m", mc.alignCursors)
      -- Easy way to add and remove cursors using the main cursor.
      map({ "n", "v" }, "<c-q>", mc.toggleCursor)
    end,
  },
}
