local M = {}

-- Module state variables
M.split_opened = false
M.frozen_line = 0
M.frozen_line_top = 0
M.frozen_line_bottom = 0
M.is_frozen_active = false
M.csv_augroup = nil

-- Toggle split view for freezing rows
function M.toggle_split()
  -- Ensure we're in a CSV file
  if vim.bo.filetype ~= "csv" then
    return
  end

  -- If split is already opened
  if M.split_opened then
    -- If there's only one window, do nothing
    if vim.fn.winnr("$") == 1 then
      return
    end

    -- Close other windows and reset state
    vim.cmd("wincmd o")
    M.split_opened = false
    M.frozen_line_top = 0
    M.frozen_line_bottom = 0
    M.is_frozen_active = false
    return
  end

  -- Activate frozen state if not already active
  if not M.is_frozen_active then
    M.is_frozen_active = true
  end

  -- Get current line
  local target_line = vim.fn.line(".")
  M.frozen_line = target_line

  -- Set top and bottom frozen lines
  M.frozen_line_top = target_line - 2
  M.frozen_line_bottom = target_line + 18

  -- Save current cursor position
  vim.cmd("normal! mz")

  -- Split window and set scroll binding
  vim.cmd("split")
  vim.wo.scrollbind = true

  -- Go to target line in split window
  vim.cmd(string.format("normal! %dG", target_line))

  -- Resize window (1/5 of current height)
  local winheight = vim.fn.winheight(0)
  local resize_count = math.floor(winheight / 5)
  vim.cmd(string.format("normal! %d", resize_count) .. "<C-w>-")

  -- Return to original window and set cursor
  vim.cmd("wincmd p")
  vim.cmd(string.format("normal! %dG", M.frozen_line))

  M.split_opened = true
end

-- Auto toggle split based on cursor movement
function M.auto_toggle_split()
  -- Ensure we're in a CSV file and frozen state is active
  if vim.bo.filetype ~= "csv" or not M.is_frozen_active then
    return
  end

  local current_line = vim.fn.line(".")

  -- Close split if scrolled above frozen top line
  if M.split_opened and current_line < M.frozen_line_top then
    if vim.fn.winnr("$") == 1 then
      return
    end
    vim.cmd("wincmd o")
    M.split_opened = false
    return
  end

  -- Open split if scrolled below frozen bottom line
  if
    not M.split_opened
    and current_line >= M.frozen_line_bottom
    and current_line <= vim.fn.line("$") - 14
    and M.frozen_line ~= 0
  then
    local target_line = current_line - M.frozen_line_bottom + M.frozen_line

    -- Save current cursor position
    vim.cmd("normal! mz")

    -- Split window and set scroll binding
    vim.cmd("split")
    vim.wo.scrollbind = true

    -- Go to target line in split window
    vim.cmd(string.format("normal! %dG", target_line))

    -- Resize window (1/5 of current height)
    local winheight = vim.fn.winheight(0)
    local resize_count = math.floor(winheight / 5)
    vim.cmd(string.format("normal! %d", resize_count) .. "<C-w>-")

    -- Return to original window and set cursor
    vim.cmd("wincmd p")
    vim.cmd(string.format("normal! %dG", M.frozen_line))

    M.split_opened = true
  end
end

-- Setup function to create autocommands and key mapping
function M.setup()
  -- Create a function to attach CSV-specific autocommands
  local function attach_csv_autocmds()
    -- Create autogroup for this buffer's CSV freeze
    local augroup =
      vim.api.nvim_create_augroup("CSVFreeze_" .. vim.fn.bufnr(), { clear = true })

    -- Store the augroup for potential later cleanup
    M.csv_augroup = augroup

    -- Autocommands to trigger auto toggle
    vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled", "CursorHold" }, {
      group = augroup,
      buffer = 0, -- Current buffer only
      callback = M.auto_toggle_split,
    })
  end

  -- Create an autocmd to attach CSV-specific autocommands when entering a CSV file
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "csv",
    callback = function()
      -- Set up key mapping only in CSV files
      vim.keymap.set("n", "<leader>fz", M.toggle_split, {
        noremap = true,
        silent = true,
        buffer = true, -- Buffer-local mapping
      })

      -- Attach CSV-specific autocommands
      attach_csv_autocmds()
    end,
  })
end

return M
