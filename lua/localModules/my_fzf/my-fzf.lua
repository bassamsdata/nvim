local M = {}

local api = vim.api

function M.open_fzf(items, opts)
  opts = opts or {}
  local prompt = opts.prompt or "> "

  -- Create a buffer for fzf
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "filetype", "fzf")

  -- Create a window for fzf
  local win_opts = {
    width = opts.width or 80,
    height = opts.height or 10,
    style = "minimal",
    border = "rounded", -- You can customize the border
    relative = "editor",
    -- You can customize the position
    row = math.floor((vim.o.lines - (opts.height or 10)) / 2),
    col = math.floor((vim.o.columns - (opts.width or 80)) / 2),
  }
  local win = api.nvim_open_win(buf, true, win_opts)

  -- Set keymaps inside the fzf window
  local function set_keymap(key, func)
    vim.keymap.set("n", key, func, { buffer = buf })
  end

  set_keymap("<CR>", function()
    local line = vim.fn.getline(".")
    api.nvim_win_close(win, true)
    if opts.on_choose then
      opts.on_choose(line)
    end
  end)

  set_keymap("<Esc>", function()
    api.nvim_win_close(win, true)
    if opts.on_close then
      opts.on_close()
    end
  end)

  -- Display the prompt and items in the buffer
  local lines = { prompt }
  for _, item in ipairs(items) do
    table.insert(lines, item)
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Position the cursor after the prompt
  api.nvim_win_set_cursor(win, { 1, #prompt + 1 })
end

return M
