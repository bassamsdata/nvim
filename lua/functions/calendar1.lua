-- public/tabline.lua
-- orginal version actually used tabline, this version uses a floating window
-- @bassamsdata added the window logic https://gist.github.com/bassamsdata/80d59a68e5560da37c4ff9161897c691
-- this gist contains adds styling as it the original, version 1, of the gist

local function current_time()
  return os.date("%H:%M")
end

local function current_day()
  return os.date("%A")
end

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

  -- AppleScript code as a single string
  local script = [[
        set processExists to false
        tell application "System Events"
            set processList to name of every process
            if processList contains "Notion Calendar" then
                set processExists to true
            end if
        end tell

        if processExists then
          tell application "System Events"
            tell process "Notion Calendar"
              -- Get the second menu bar
              set theSecondMenuBar to menu bar 2

              -- Get all menu bar items in the second menu bar
              set menuBarItems to menu bar items of theSecondMenuBar

              -- Collect the titles or values of each menu bar item
              set menuBarItemTitles to {}
              repeat with itemIndex from 1 to count of menuBarItems
                set menuBarItemTitle to value of attribute "AXTitle" of item itemIndex of menuBarItems
                set end of menuBarItemTitles to menuBarItemTitle
              end repeat
            end tell
          end tell
          return menuBarItemTitles as string
        else
          return "Open Notion Calendar to see upcoming events"
        end if
    ]]

  -- Execute the AppleScript using osascript
  local handle, error = io.popen("date")

  if handle == nil then
    event_cache.value = error or "Error querying Notion Calendar"
    event_cache.timestamp = now
    return event_cache.value
  end

  local result = handle:read("*a")
  handle:close()

  -- Update the cache
  if result == nil or result == "" then
    event_cache.value = "No event information available"
  else
    event_cache.value = result:gsub("^%s*(.-)%s*$", "%1")
  end
  event_cache.timestamp = now

  return result
end

local start_symbol = ""
local end_symbol = ""

---@class DecoratedEvent
---@field decorated string
---@field plain string

---get decorated and plain event text
---@return DecoratedEvent
local function get_decorated_event()
  local event_text = current_cal_event()
  local lines = vim.split(event_text, "\n", { plain = true })
  local text = "🌱 " .. (lines[1] or "No event")

  local decorated_text = start_symbol .. text .. end_symbol

  return {
    decorated = decorated_text,
    plain = text,
  }
end

---create a floating buffer for the calendar event
---@param event DecoratedEvent
---@return integer
local function create_buffer(event)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = { event.decorated }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  return buf
end

---@param event DecoratedEvent
---@return integer
local function create_window(event)
  local height, width, buf, win, padding

  -- width needs to in columns needed to render string
  width = vim.fn.strwidth(event.decorated)
  height = 1
  padding = 0
  buf = create_buffer(event)

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

  -- theme
  local ns = vim.api.nvim_create_namespace("notioncalendar")
  vim.api.nvim_set_hl(
    0,
    "NotionCalendarNormal",
    { bg = "#333c48", fg = "#ffffff" }
  )
  vim.api.nvim_set_hl(0, "NotionCalendarOrnament", { fg = "#333c48", bg = nil })

  local buf_options = {
    buftype = "nofile",
    modifiable = false,
    filetype = "notioncalendar",
  }

  local win_options = {
    winblend = 0,
  }

  for option, value in pairs(buf_options) do
    vim.api.nvim_set_option_value(option, value, { buf = buf })
  end

  for option, value in pairs(win_options) do
    vim.api.nvim_set_option_value(option, value, { win = win })
  end

  -- extmark end_col needs to be in byte
  local end_col = #event.decorated - #end_symbol
  local ornament_regexp = "\\(" .. start_symbol .. "\\|" .. end_symbol .. "\\)"

  vim.api.nvim_buf_set_extmark(
    buf,
    ns,
    0,
    2,
    { end_row = 0, end_col = end_col, hl_group = "NotionCalendarNormal" }
  )
  vim.fn.matchadd(
    "NotionCalendarOrnament",
    ornament_regexp,
    999,
    -1,
    { window = win }
  )

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
    local event = get_decorated_event()
    current_window = create_window(event)
  end
end

vim.keymap.set("n", "gC", toggle_window, { noremap = true, silent = true })
