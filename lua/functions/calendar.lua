-- source: https://www.reddit.com/r/neovim/comments/1egdcql/show_upcoming_notion_calendar_event_in_neovim/
-- plugin/tabline.lua

---@return string|osdate
local function current_time()
  return os.date("%H:%M")
end

---@return string|osdate
local function current_day()
  return os.date("%A")
end

---@return string|osdate
local function current_file()
  local filename = vim.fn.expand("%:t")
  return filename == "" and current_day() or filename
end

---@class EventCache
---@field value string
---@field timestamp number
---@field refresh_interval number
---@type EventCache
local event_cache = {
  value = "",
  timestamp = 0,
  refresh_interval = 30,
}

local function current_cal_event()
  local now = os.time()
  -- Check if the cache is still valid
  if
    event_cache.value
    and (now - event_cache.timestamp < event_cache.refresh_interval)
  then
    return event_cache.value
  end

  local function on_exit(obj)
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
    return event_cache.value
  end

  -- Execute the AppleScript using vim.system()
  -- vim.system({ "osascript", "-e", script }, { text = true }, on_exit)
  vim.system({ "date" }, { text = true }, on_exit)
end

---create a floating buffer for the calendar event
---@return integer
local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  local event_text = current_cal_event() or "No event information available"
  local lines = vim.split(event_text, "\n", { plain = true })
  if #lines > 0 then
    -- Add the 🌱 icon to the first line
    lines[1] = "🌱 " .. lines[1]
  else
    -- If there are no lines, add a default line with the icon
    lines = { "🌱 No event" }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

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

---@type integer?
local current_window = nil

---@return nil
local function close_window()
  if current_window and vim.api.nvim_win_is_valid(current_window) then
    vim.api.nvim_win_close(current_window, true)
    current_window = nil
  end
end

---@return nil
local function toggle_window()
  if current_window and vim.api.nvim_win_is_valid(current_window) then
    close_window()
  else
    current_window = create_window()
  end
end

vim.keymap.set("n", "gC", toggle_window, { noremap = true, silent = true })

-- vim.opt.showtabline = 2
-- vim.cmd("highlight! link TabLineFile @field")
-- vim.cmd("highlight! link TabLineTime @diff.minus")
-- vim.cmd("highlight! link TabLineEvent @diff.plus")
-- vim.cmd("highlight! TabLineEventBg guifg=#333c48")
-- vim.cmd("highlight! TabLineTimeBg guifg=#43293a")
-- -- vim.o.tabline = " 🌱 %#TabLineFile# %{v:lua.current_file()} %h%m%r %= %#TabLineTime# %{v:lua.current_time()} " -- " ♥ "
-- vim.o.tabline =
-- " 🌱 %#TabLineFile# %{v:lua.current_file()} %h%m%r %= %#TabLineEventBg#%#TabLineEvent#%{v:lua.current_cal_event()}%#TabLineEventBg#%#Normal# %#TabLineTimeBg#%#TabLineTime#%{v:lua.current_time()}%#TabLineTimeBg#" -- " ♥ "
--
_G.current_time = current_time
_G.current_file = current_file
_G.current_cal_event = current_cal_event
