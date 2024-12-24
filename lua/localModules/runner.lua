local M = {}

-- Function to create a floating window
local function create_floating_window()
  local width = 60
  local height = 10
  local buf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1]

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = ui.width - width - 1,
    row = ui.height - height - 1,
    anchor = "SW",
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, false, opts)
  return buf, win
end

-- Function to run Go file and display output
function M.run_go_file()
  local file_path = vim.fn.expand("%:p")

  -- Create floating window
  local buf, win = create_floating_window()

  -- Set initial content of the buffer
  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    { "Running Go file...", "Please wait..." }
  )

  -- Make the window visible
  vim.api.nvim_set_current_win(win)

  -- Run the Go file asynchronously
  vim.system(
    { "go", "run", file_path },
    {
      stdout = vim.schedule_wrap(function(err, data)
        if err then
          vim.api.nvim_buf_set_lines(
            buf,
            0,
            -1,
            false,
            vim.split("Error: " .. err, "\n")
          )
        elseif data then
          local lines = vim.split(data, "\n")
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        end
      end),
      stderr = vim.schedule_wrap(function(err, data)
        if data then
          local lines = vim.split(data, "\n")
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        end
      end),
    },
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        vim.api.nvim_buf_set_lines(
          buf,
          0,
          -1,
          false,
          { "Go file execution completed with errors." }
        )
      else
        vim.api.nvim_buf_set_lines(
          buf,
          0,
          -1,
          false,
          { "Go file execution completed successfully." }
        )
      end

      -- Close the window after 10 seconds
      vim.defer_fn(function()
        pcall(vim.api.nvim_win_close, win, true)
      end, 10000)
    end)
  )
end

-- Set up keybinding
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
      vim.keymap.set(
        "n",
        "<leader>co",
        M.run_go_file,
        { buffer = true, desc = "Run Go file" }
      )
    end,
  })
end

return M
