-- Add this to your init.lua or create a new file (e.g., markdown_folding.lua) and require it in init.lua

local api = vim.api

-- Function to create folds
local function markdown_folds()
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local folds = {}
  local in_fold = false
  local fold_start = 0

  for i, line in ipairs(lines) do
    if line:match("^%[!File:") then
      if in_fold then
        table.insert(folds, { fold_start, i - 1 })
      end
      in_fold = true
      fold_start = i
    elseif in_fold and line:match("^```$") then
      table.insert(folds, { fold_start, i })
      in_fold = false
    end
  end

  if in_fold then
    table.insert(folds, { fold_start, #lines })
  end

  return folds
end

-- Function to get fold text
local function fold_text()
  local foldstart = vim.v.foldstart
  local foldend = vim.v.foldend
  local lines = api.nvim_buf_get_lines(0, foldstart - 1, foldend, false)
  local first_line = lines[1]
  return first_line .. " ..."
end

-- Set foldmethod and foldexpr
api.nvim_create_autocmd("FileType", {
  pattern = { "codecompanion", "markdown" },
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.markdown_fold_expr()"
    vim.wo.foldtext = "v:lua.markdown_fold_text()"

    -- Create buffer-local Lua functions for folding
    vim.b.markdown_folds = markdown_folds

    -- Set foldexpr to use our custom folding function
    _G.markdown_fold_expr = function()
      local folds = vim.b.markdown_folds()
      for _, fold in ipairs(folds) do
        if vim.v.lnum >= fold[1] and vim.v.lnum <= fold[2] then
          if vim.v.lnum == fold[1] then
            return ">1"
          else
            return "1"
          end
        end
      end
      return "0"
    end

    -- Set foldtext to use our custom function
    _G.markdown_fold_text = fold_text
  end,
})

-- Keymap to toggle folds
vim.api.nvim_set_keymap(
  "n",
  "<leader>yz",
  "za",
  { noremap = true, silent = true }
)
