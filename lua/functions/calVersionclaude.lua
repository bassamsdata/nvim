local M = {}

local setValue = vim.api.nvim_set_option_value
-- Create a floating window
local function create_window()
  local buf, win, width, height
  -- stylua: ignore start 
  buf    = vim.api.nvim_create_buf(false, true)
  width  = 25
  height = 1
  win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width    = width,
    height   = height,
    col      = vim.o.columns,
    row      = 0,
    anchor   = "NE",
    style    = "minimal",
    border   = "none",
    -- stylua: ignore end 
  })
  -- stylua: ignore start 
  -- Set buffer options
  setValue("buftype",    "nofile", { buf = buf })
  setValue("swapfile",   false,    { buf = buf })
  setValue("modifiable", true,     { buf = buf })
  -- Set window options
  setValue("wrap",       false,    { win = win })
  setValue("cursorline", false,    { win = win })
  setValue("cursorline", false,    { win = win })
  -- stylua: ignore end

  return buf, win
end

-- Update buffer content
local function update_buffer(buf, content)
  setValue("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
  setValue("modifiable", false, { buf = buf })
end

-- Main function to run system command and display result
function M.run_system_command(cmd, opts)
  local buf, win = create_window()

  -- Show loading message
  update_buffer(buf, "Loading...")

  -- Run the system command asynchronously
  ---@see vim.system
  vim.system(cmd, opts, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        update_buffer(buf, obj.stdout)
      else
        update_buffer(
          buf,
          "Error: " .. (obj.stderr or "Unknown error occurred")
        )
      end
    end)
  end)

  return buf, win
end

-- Example usage
function M.show_current_date()
  M.run_system_command({ "date" }, { text = true })
end

vim.api.nvim_create_user_command("ShowCurrentDate", M.show_current_date, {})

return M
