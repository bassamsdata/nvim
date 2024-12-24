if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "echasnovski/mini.clue",
    event = "BufReadPost",
    config = function()
      local miniclue = require("mini.clue")
      -- mark and macro clues taken from Maria configs - please see the readme for a link to Maria's config
      -- BS: Changed this function and used 'for loop' instead of 'iter' module
      -- Add a-z/A-Z marks.
      local function mark_clues()
        local marks = {}
        vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
        vim.list_extend(marks, vim.fn.getmarklist())

        local result = {}
        for _, mark in ipairs(marks) do
          local key = mark.mark:sub(2, 2)

          -- Just look at letter marks.
          if not string.match(key, "^%a") then
            goto continue
          end
          -- For global marks, use the file as a description.
          -- For local marks, use the line number and content.
          local desc
          if mark.file then
            desc = vim.fn.fnamemodify(mark.file, ":p:~:.")
          elseif mark.pos[1] and mark.pos[1] ~= 0 then
            local line_num = mark.pos[2]
            local lines = vim.fn.getbufline(mark.pos[1], line_num)
            if lines and lines[1] then
              desc = string.format("%d: %s", line_num, lines[1]:gsub("^%s*", ""))
            end
          end

          if desc then
            table.insert(
              result,
              { mode = "n", keys = string.format("'%s", key), desc = desc }
            )
            table.insert(
              result,
              { mode = "n", keys = string.format("`%s", key), desc = desc }
            )
          end

          ::continue::
        end

        return result
      end

      -- Clues for recorded macros.
      local function macro_clues()
        local res = {}
        local registers = "123456789abcdefghijklmnopqrstuvwxyz" -- when adding , wierd behavior will occur
        for register in registers:gmatch(".") do
          local keys = string.format('"%s', register)
          -- vim.fn.getreg() is really bad and inconsistent
          --- @diagnostic disable-next-line: param-type-mismatch
          local desc = vim.fn.getreg(register):gsub("[\n\r]", "⏎") -- this is the only way it worked
          if desc ~= "" then
            table.insert(res, { mode = "n", keys = keys, desc = desc })
            table.insert(res, { mode = "v", keys = keys, desc = desc })
          end
        end
        return res
      end

      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },
          -- Built-in completion
          { mode = "i", keys = "<C-x>" },
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },
          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },
          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },
          -- Window commands
          { mode = "n", keys = "<C-w>" },
          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
          -- Moving between stuff.
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
          -- R and Python
          { mode = "n", keys = "\\" },
          { mode = "v", keys = "\\" },
        },
        window = {
          -- Delay before showing clue window
          delay = 300,
          config = function(bufnr)
            local max_width = 0
            for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
              max_width = math.max(max_width, vim.fn.strchars(line))
            end

            -- Keep some right padding.
            max_width = max_width + 2

            return {
              border = "rounded",
              -- Dynamic width capped at 45.
              width = math.min(45, max_width),
            }
          end,
        },
        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          { mode = "n", keys = "<Leader>m", desc = "+Misc/Maximaize" },
          -- { mode = "n", keys = "<leader>h", desc = "+Harpoon/R" },
          { mode = "n", keys = "<leader>a", desc = "+Ai" },
          { mode = "n", keys = "<leader>e", desc = "File Explorer" },
          { mode = "n", keys = "<leader>C", desc = "+Environment" },
          { mode = "n", keys = "<leader>e", desc = "File Explorer" },
          -- { mode = "n", keys = "<leader>d", desc = "+database" },
          { mode = "n", keys = "<leader>r", desc = "+R/R-console" },
          { mode = "n", keys = "<leader>s", desc = "+session" },
          { mode = "n", keys = "<leader>t", desc = "+Toggle & Term" },
          { mode = "n", keys = "<leader>x", desc = "+loclist/quickfix" },
          { mode = "n", keys = "<leader><tab>", desc = "+tabs" },
          { mode = "n", keys = "<leader>b", desc = "+buffers" },
          { mode = "n", keys = "<leader>c", desc = "+code" },
          { mode = "n", keys = "<leader>f", desc = "+find" },
          { mode = "n", keys = "<leader>g", desc = "+git" },
          { mode = "n", keys = "<leader>gh", desc = "+gitsigns" },
          { mode = "n", keys = "<leader>gd", desc = "+DiffView" },
          -- { mode = "n", keys = "<leader>s", desc = "+search" },
          { mode = "n", keys = "<leader>u", desc = "+ui" },
          -- { mode = "n", keys = "<leader>w", desc = "+window" },
          { mode = "n", keys = "<leader>x", desc = "+diagnostics/quickfix" },
          { mode = "n", keys = "<leader>q", desc = "+quit/session" },
          -- { mode = "n", keys = "[", desc = "+prev" },
          -- { mode = "n", keys = "]", desc = "+next" },
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          mark_clues,
          macro_clues,
        },
      })
    end,
  },
}
