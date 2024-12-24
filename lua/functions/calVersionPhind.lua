local event_cache = {
  value = "",
  timestamp = 0,
  refresh_interval = 30,
}

local function current_cal_event(callback)
  local now = os.time()
  -- Check if the cache is still valid
  if
    event_cache.value
    and (now - event_cache.timestamp < event_cache.refresh_interval)
  then
    callback(event_cache.value)
    return
  end

  vim.system({ "date" }, { text = true }, function(obj)
    if obj.code == 0 then
      local result = obj.stdout
      -- Update the cache
      if result == nil or result == "" then
        event_cache.value = "No event information available"
      else
        event_cache.value = result:gsub("^%s*(.-)%s*$", "%1")
      end
    else
      event_cache.value = "Nothing's up"
    end
    event_cache.timestamp = now
    callback(event_cache.value)
  end)
end

local function create_buffer(callback)
  local buf = vim.api.nvim_create_buf(false, true)
  -- Initially show a loading message
  local lines = { "Loading..." }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Fetch the calendar event asynchronously
  current_cal_event(function(event_text)
    -- Update the buffer content with the fetched event text
    lines = vim.split(event_text, "\n", { plain = true })
    if #lines > 0 then
      lines[1] = "🌱 " .. lines[1]
    else
      lines = { "🌱 No event" }
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    -- Call the callback to signal that the buffer content has been updated
    callback(buf)
  end)
end

---@return integer
local function create_window(buf)
  local height, width, win, padding
  height = 1
  width = 25
  padding = 0
  win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "NE",
    width = width,
    height = height,
    focusable = false,
    row = padding,
    col = vim.o.columns - padding,
    style = "minimal",
    border = "none",
  })
  local buf_options = {
    buftype = "nofile",
    modifiable = false,
  }
  local win_options = {
    winblend = 0,
    winhighlight = "Normal:TabLineFile",
  }
  for option, value in pairs(buf_options) do
    vim.api.nvim_set_option_value(option, value, { buf = buf })
  end
  for option, value in pairs(win_options) do
    vim.api.nvim_set_option_value(option, value, { win = win })
  end
  return win
end

-- Asynchronously create the buffer and window
create_buffer(function(buf)
  local win = create_window(buf)
  -- Additional logic here if needed
end)
