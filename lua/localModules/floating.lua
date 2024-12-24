local current_height = 1 -- Track the current height
local function open_float_above_selection()
  local start_pos = vim.fn.getpos("v")[2] -- vim.fn.line("v") is the same
  -- Get the current window and buffer
  local win = vim.api.nvim_get_current_win()
  -- local width = vim.api.nvim_win_get_width(win)
  local config = {
    relative = "win",
    win = win,
    bufpos = { start_pos - 5, 6 },
    width = vim.o.columns,
    height = current_height,
    style = "minimal",
    border = { "", "─", "", "", "", "─", "", "" },
    zindex = 1001,
  }

  -- Create the buffer and window for the floating window
  local fBuf = vim.api.nvim_create_buf(false, true)
  local fWin = vim.api.nvim_open_win(fBuf, true, config)
  vim.api.nvim_set_option_value("filetype", "floatCustom", { buf = fBuf })
  vim.cmd("startinsert")

  local function increase_window_height()
    current_height = current_height + 1
    vim.api.nvim_win_set_height(fWin, current_height)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<CR>", true, false, true),
      "n",
      true
    ) -- Simulate Enter key
  end

  -- Map Enter key to increase window height
  vim.keymap.set(
    "i",
    "<CR>",
    increase_window_height,
    { buffer = fBuf, silent = true }
  )

  -- vim.cmd("startinsert")
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(fWin, true)
    -- start_pos = { nil, nil, nil, nil }
  end, { buffer = fBuf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(fWin, true)
    -- start_pos = { nil, nil, nil, nil }
  end, { buffer = fBuf, noremap = true, silent = true })
  -- Set the border color
  -- vim.api.nvim_set_option_value(
  --   "winhl",
  --   "Normal:Normal,FloatBorder:FloatBorder",
  --   { scope = "local", win = fWin }
  -- )
  -- vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#d1eaa0" })
end

-- Set up the keymap for visual mode
vim.keymap.set(
  "v",
  "<leader>f",
  open_float_above_selection,
  { noremap = true, silent = true }
)
