local M = {}
function M.get_visual_selection()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  -- Normalize the range to start < end
  if
    start_line > end_line or (start_line == end_line and start_col > end_col)
  then
    start_pos, end_pos = end_pos, start_pos
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines =
    vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  -- Handle partial lines
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  print("Selected text:")
  for _, line in ipairs(lines) do
    print(line)
  end

  return lines
end

-- Add a new keymap to test the selection
vim.keymap.set(
  "v",
  "<leader>v",
  M.get_visual_selection,
  { noremap = true, silent = true }
)
return M
