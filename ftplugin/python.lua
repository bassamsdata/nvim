local api = vim.api
-- Thanks to @codecompanion.nvim plugin

local codeblock = {
  desc = "Insert a codeblock",
  callback = function()
    local bufnr = api.nvim_get_current_buf()
    local cursor_pos = api.nvim_win_get_cursor(0)
    local line = cursor_pos[1]

    -- I can customize this based on the filetype
    local codeblock = {
      "# %%",
      "",
      "# %%",
    }

    api.nvim_buf_set_lines(bufnr, line - 1, line, false, codeblock)
    api.nvim_win_set_cursor(0, { line + 1, vim.fn.indent(line) })
  end,
}

vim.keymap.set(
  "n",
  "<leader>gi",
  codeblock.callback,
  { buffer = true, desc = codeblock.desc }
)

local function add_code_block_markers()
  local bufnr = vim.api.nvim_get_current_buf()

  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".") -- usually end poistion

  if start_pos[2] > end_pos[2] then
    start_pos, end_pos = end_pos, start_pos
  end

  vim.api.nvim_buf_set_lines(bufnr, start_pos[2] - 1, start_pos[2] - 1, false, { "# %%" })
  vim.api.nvim_buf_set_lines(bufnr, end_pos[2] + 1, end_pos[2] + 1, false, { "", "# %%" })

  -- move the cursor to the end of the added block
  vim.api.nvim_win_set_cursor(0, { end_pos[2] + 3, 0 })

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
    "n",
    false
  )
end

-- Set the keymap for visual mode
vim.keymap.set(
  "v",
  "<leader>gi",
  add_code_block_markers,
  { buffer = true, desc = "Add code block markers" }
)

-- vim.g.no_python_maps = 1 -- Disable built-in python mappings
