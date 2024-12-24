local event_cache = {
  value = "Loading...",
  timestamp = 0,
  refresh_interval = 30,
}

---Function to fetch calendar event or date output
local function fetch_event()
  local now = os.time()
  -- Check if the cache is still valid
  if
    event_cache.value
    and (now - event_cache.timestamp < event_cache.refresh_interval)
  then
    return event_cache.value
  end

  -- Function to handle the command output
  local function on_exit(obj)
    if obj.code == 0 then
      local result = obj.stdout
      if result == nil or result == "" then
        event_cache.value = "No event information available"
      else
        event_cache.value = result:gsub("^%s*(.-)%s*$", "%1")
      end
    else
      event_cache.value = "Nothing's up"
    end
    event_cache.timestamp = now
    return event_cache.value
  end

  -- Execute the system command asynchronously
  vim.system({ "date" }, { text = true }, on_exit)
  return event_cache.value
end

---Create a floating buffer for the calendar event
---@return integer
local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  local event_text = fetch_event() or "No event information available"
  local lines = vim.split(event_text, "\n", { plain = true })
  if #lines > 0 then
    lines[1] = "🌱 " .. lines[1]
  else
    lines = { "🌱 No event" }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

---Create a floating window
---@return integer
local function create_window()
  local height, width, win, buf, padding
  height = 1
  width = 25
  padding = 0
  buf = create_buffer()
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

---Update the buffer with new content
---@param buf integer
---@param content string
local function update_buffer(buf, content)
  local lines = vim.split(content, "\n", { plain = true })
  if #lines > 0 then
    lines[1] = "🌱 " .. lines[1]
  else
    lines = { "🌱 No event" }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

---Main function to create window and update content
local function show_event()
  -- Create buffer and window with loading message
  local buf = create_buffer()
  local win = create_window()

  -- Fetch event asynchronously and update buffer
  vim.system({ "date" }, { text = true }, function(obj)
    local content
    if obj.code == 0 then
      content = obj.stdout
      if content == nil or content == "" then
        content = "No event information available"
      else
        content = content:gsub("^%s*(.-)%s*$", "%1")
      end
    else
      content = "Nothing's up"
    end

    -- Update the buffer with the new content
    vim.schedule(function()
      update_buffer(buf, content)
    end)
  end)
end

-- Example usage: show the event window
show_event()
