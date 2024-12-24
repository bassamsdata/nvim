local M = {}
local api = vim.api
local fn = vim.fn

local config = {
  keys = { "a", "s", "d", "f", "g" },
  use_numbers = false,
  show_scores = true, -- Whether to show frecency scores
  score_format = "%.1f", -- How to format the score
  select_key = "<CR>", -- Key to select current line
  modified_icon = "", -- Default modified icon
  delete_key = "D", -- Key to delete buffer
  use_icons = true, -- Whether to use icons if available
  scoring = {
    -- Weights should add up to 1.0
    frequency_weight = 0.4, -- Default weight for frequency (how often)
    recency_weight = 0.6, -- Default weight for recency (how recent)
    -- Controls how quickly recency score decays
    -- Higher values = slower decay = longer-lasting recency impact
    recency_decay = 1.0,
  },
  window = {
    width = 60,
    height = 10,
    border = "rounded",
    highlight = "FloatBorder",
    left_padding = "    ", -- Configure padding here
  },
  split_commands = {
    vertical = "v", -- prefix for vertical split
    horizontal = "-", -- prefix for horizontal split
  },
  -- Add project detection configuration
  project = {
    markers = {
      ".git",
      "go.mod",
      "package.json",
      "Cargo.toml",
      "pyproject.toml",
      "pyproject.json",
      "Makefile",
      "README.md",
    },
    -- NEW: Maximum number of project histories to keep
    max_histories = 50,
  },
}

-- Store for buffer access history

---@type table<string, {count: number, last_access: number, total_score: number}>
local buffer_history = {}
local current_project_root = nil
local history_file_path = ""
local current_buffer = nil
M.current_switcher = { win = nil, buf = nil }

-- Add function to check if switcher is open
local function is_switcher_open()
  return M.current_switcher.win ~= nil
    and M.current_switcher.buf ~= nil
    and api.nvim_win_is_valid(M.current_switcher.win)
    and api.nvim_buf_is_valid(M.current_switcher.buf)
end

-- Setup plugin directory structure
local function ensure_directories()
  local base_dir = fn.stdpath("data") .. "/frecency"
  local projects_dir = base_dir .. "/projects"

  -- Create directories if they don't exist
  for _, dir in ipairs({ base_dir, projects_dir }) do
    if fn.isdirectory(dir) == 0 then
      fn.mkdir(dir, "p")
    end
  end
  return base_dir, projects_dir
end

-- Generate consistent hash for project path
local function hash_path(path)
  return fn.sha256(path):sub(1, 16)
end

local function reset_buffer_score(file_path)
  if buffer_history[file_path] then
    buffer_history[file_path] = {
      count = 0,
      last_access = 0,
      total_score = 0,
    }
    M.save_history()
    return true
  end
  return false
end

-- Get project root and history file path
local function setup_project_paths()
  local base_dir, projects_dir = ensure_directories()
  current_project_root = vim.fs.root(0, config.project.markers)

  if current_project_root then
    local project_hash = hash_path(current_project_root)
    history_file_path = string.format("%s/%s.json", projects_dir, project_hash)
  else
    history_file_path = base_dir .. "/global.json"
  end
end

-- FIXME: doesn't really work
-- Cleanup old project histories
local function cleanup_old_histories()
  local _, projects_dir = ensure_directories()
  local files = fn.glob(projects_dir .. "/*.json", 0, 1)

  if #files > config.project.max_histories then
    -- Sort files by access time
    table.sort(files, function(a, b)
      return fn.getftime(a) > fn.getftime(b)
    end)

    -- Remove oldest files
    for i = config.project.max_histories + 1, #files do
      fn.delete(files[i])
    end
  end
end

-- Load history from file
local function load_history()
  if not history_file_path then
    return
  end

  local file = io.open(history_file_path, "r")
  if not file then
    return
  end

  local content = file:read("*all")
  file:close()

  if content and content ~= "" then
    local ok, data = pcall(vim.json.decode, content)
    if ok then
      buffer_history = {}
      for k, v in pairs(data) do
        buffer_history[k] = v
      end
    end
  end
end

-- Save history to file
function M.save_history()
  if not history_file_path then
    return
  end

  -- Create a temporary file path
  local temp_file = history_file_path .. ".tmp"

  -- Debug: Check buffer_history content
  if vim.g.frecency_debug then
    vim.notify(
      "Saving buffer history: " .. vim.inspect(buffer_history),
      vim.log.levels.DEBUG
    )
  end

  -- First write to temporary file
  local temp_handle = io.open(temp_file, "w")
  if not temp_handle then
    return
  end

  local ok, encoded = pcall(vim.json.encode, buffer_history)
  if not ok then
    temp_handle:close()
    os.remove(temp_file)
    return
  end

  local write_ok, write_err = temp_handle:write(encoded)
  temp_handle:flush() -- Ensure all data is written
  temp_handle:close()

  if not write_ok then
    vim.notify(
      "Failed to write temporary file: " .. tostring(write_err),
      vim.log.levels.ERROR
    )
    os.remove(temp_file)
    return
  end

  -- Atomically rename temporary file to target file
  local rename_ok, rename_err = os.rename(temp_file, history_file_path)
  if not rename_ok then
    vim.notify(
      "Failed to rename temporary file: " .. tostring(rename_err),
      vim.log.levels.ERROR
    )
    os.remove(temp_file)
    return
  end

  if vim.g.frecency_debug then
    vim.notify(
      "Successfully saved history to " .. history_file_path,
      vim.log.levels.DEBUG
    )
  end
end

-- Calculate frecency score
-- Combines frequency (how often) and recency (how recent) of buffer access
local function calculate_frecency(file_path)
  if type(file_path) ~= "string" or file_path == "" then
    return 0
  end

  local history = buffer_history[file_path]
    or {
      count = 0,
      last_access = os.time(),
      total_score = 0,
    }
  local current_time = os.time()
  local time_diff = math.max(current_time - history.last_access, 1)

  -- Recency score with configurable decay
  local recency_score = 1
    / (1 + math.log(time_diff) * config.scoring.recency_decay)
  -- Frequency score (capped at 100 visits)
  local frequency_score = math.min(history.count, 100)

  -- Apply weights
  return (frequency_score * config.scoring.frequency_weight)
    + (recency_score * config.scoring.recency_weight)
end

--- TODO: show icons in sign column

--- Add icon support function
--- @param file_path string
--- @return string, string|nil
local function get_file_icon(file_path)
  if not config.use_icons then
    return "", nil
  end

  -- Try mini.icons first
  local ok_mini, MiniIcons = pcall(require, "mini.icons")
  if ok_mini then
    local icon, hl = MiniIcons.get("file", file_path)
    return icon .. " ", hl
  end

  -- Try nvim-web-devicons as fallback
  local ok_web, devicons = pcall(require, "nvim-web-devicons")
  if ok_web then
    local icon, hl = devicons.get_icon(
      file_path,
      file_path:match("^.+%.(%w+)$"), -- Get file extension
      { default = true }
    )
    return icon and (icon .. " ") or "", hl
  end

  return "", nil
end

-- Update buffer access history
local function update_history(buf_id)
  local file_path = api.nvim_buf_get_name(buf_id)
  if file_path == "" then -- Skip unnamed buffers
    return
  end

  if not buffer_history[file_path] then
    buffer_history[file_path] = {
      count = 0,
      last_access = 0,
      total_score = 0,
    }
  end

  -- Update access data and calculate new score
  buffer_history[file_path].count = buffer_history[file_path].count + 1
  buffer_history[file_path].last_access = os.time()
  -- Calculate and cache the score
  buffer_history[file_path].total_score = calculate_frecency(file_path)

  if vim.g.frecency_debug then
    vim.notify(
      string.format(
        "Updated history for %s:\n" .. "  Count: %d\n" .. "  Score: %.4f",
        file_path,
        buffer_history[file_path].count,
        buffer_history[file_path].total_score
      ),
      vim.log.levels.DEBUG
    )
  end
end

local function is_valid_buffer(buf)
  -- Check if buffer is valid and listed
  if
    not api.nvim_buf_is_valid(buf)
    or not api.nvim_get_option_value("buflisted", { buf = buf })
  then
    return false
  end

  local file_path = api.nvim_buf_get_name(buf)
  if file_path == "" then
    return false
  end

  -- Check if it's a real file (not a terminal, help, etc)
  local buftype = api.nvim_get_option_value("buftype", { buf = buf })
  if buftype ~= "" then
    return false
  end

  return true
end
-- Get sorted list of buffers based on frecency
local function get_sorted_buffers()
  local buffers = {}

  -- TODO: might change this to list tabpage buffers
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if is_valid_buffer(buf) then
      local file_path = api.nvim_buf_get_name(buf)
      -- Use cached score or 0 for new buffers
      local score = buffer_history[file_path]
          and buffer_history[file_path].total_score
        or 0
      table.insert(buffers, {
        id = buf,
        path = file_path,
        score = score,
        name = fn.fnamemodify(file_path, ":~:."),
        modified = api.nvim_get_option_value("modified", { buf = buf }),
      })
    end
  end

  -- Sort by cached frecency score
  table.sort(buffers, function(a, b)
    return a.score > b.score
  end)

  if vim.g.frecency_debug then
    vim.notify("Sorted buffers scores:", vim.log.levels.DEBUG)
    for _, buf in ipairs(buffers) do
      vim.notify(
        string.format("  %s: %.4f", buf.name, buf.score),
        vim.log.levels.DEBUG
      )
    end
  end

  return buffers
end

-- Create and show the floating window
local function create_float_win()
  local width = config.window.width
  local height = config.window.height

  -- Calculate position
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer for the window
  local buf = api.nvim_create_buf(false, true)

  -- Window options
  local win_opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = config.window.border,
  }

  -- Create window
  local win = api.nvim_open_win(buf, true, win_opts)

  -- Add padding at the top
  api.nvim_buf_set_lines(buf, 0, 1, false, { "" })
  -- Set window options
  api.nvim_set_option_value("winblend", 0, { win = win })
  -- api.nvim_set_option_value("cursorline", true, { win = win })

  return buf, win
end

-- Display buffer list with key hints
local function display_buffers(buf, buffers, current_buf)
  local lines = {}
  local key_map = {}
  local highlights = {}
  local current_line = nil

  -- Clear existing highlights
  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

  -- Add initial empty line for top padding
  table.insert(lines, "")

  for i, buffer in ipairs(buffers) do
    local key = i <= #config.keys and config.keys[i] or tostring(i)
    local modified = buffer.modified and config.modified_icon or ""
    local is_current = buffer.id == current_buf
    -- local prefix = is_current and "→ " or "  "
    local icon, icon_hl = get_file_icon(buffer.path)

    -- Split the path into filename and directory
    local filename = vim.fn.fnamemodify(buffer.path, ":t")
    local dir_path = vim.fn.fnamemodify(buffer.path, ":~:.:h")
    -- Handle root directory case
    dir_path = dir_path == "." and " . ./" or " . " .. dir_path .. "/"
    local score_display = config.show_scores
        and string.format(" [" .. config.score_format .. "]", buffer.score)
      or ""

    local display_line = string.format(
      "%s%s %s%s%s%s%s %s",
      config.window.left_padding,
      key,
      icon,
      filename,
      dir_path,
      score_display,
      modified ~= "" and " " or "", -- Add space only if modified
      modified
    )

    table.insert(lines, display_line)
    key_map[key] = buffer.id

    -- Store current buffer line number (1-based index for cursor positioning)
    if is_current then
      current_line = i + 1 -- +1 for the padding line
    end

    -- Calculate positions for highlights with left padding
    local base_col = #config.window.left_padding
    local key_end = base_col + #key
    local icon_start = key_end + 1
    local filename_start = icon_start + #icon
    local dir_start = filename_start + #filename
    local score_start = dir_start + #dir_path
    local modified_start = score_start
      + #score_display
      + (#modified > 0 and 1 or 0)

    -- Store highlights for this line
    local line_idx = i + 1 -- +1 for the padding line

    -- Key number highlight
    table.insert(highlights, {
      line = line_idx - 1,
      hl_group = "CursorLineNr",
      start_col = base_col,
      end_col = key_end,
    })
    -- Icon highlight
    if icon_hl then
      table.insert(highlights, {
        line = line_idx - 1,
        hl_group = icon_hl,
        start_col = icon_start,
        end_col = icon_start + #icon - 1,
      })
    end

    -- Directory path highlight (including the dot and slash)
    table.insert(highlights, {
      line = line_idx - 1,
      hl_group = "Comment",
      start_col = dir_start,
      end_col = score_start,
    })

    -- Score highlight
    if #score_display > 0 then
      table.insert(highlights, {
        line = line_idx - 1,
        hl_group = "Special",
        start_col = score_start,
        end_col = score_start + #score_display,
      })
    end
    -- Modified icon highlight
    if #modified > 0 then
      table.insert(highlights, {
        line = line_idx - 1,
        hl_group = "Special",
        start_col = modified_start,
        end_col = modified_start + #modified,
      })
    end

    -- Current buffer highlight
    if is_current then
      table.insert(highlights, {
        line = line_idx - 1,
        hl_group = "Title",
        start_col = filename_start,
        end_col = dir_start,
      })
    end
  end

  -- Set the lines
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    api.nvim_buf_add_highlight(
      buf,
      -1,
      hl.hl_group,
      hl.line,
      hl.start_col,
      hl.end_col
    )
  end

  return key_map, buffers, current_line
end

-- Add buffer deletion function
local function delete_buffer(buf_id, win_id)
  -- Try to delete the buffer
  local success = pcall(api.nvim_buf_delete, buf_id, { force = false })
  if not success then
    vim.notify("Cannot delete buffer: Buffer is modified", vim.log.levels.WARN)
    return false
  end
  return true
end

-- Add refresh function
local function refresh_switcher()
  if not is_switcher_open() then
    return
  end

  local buffers = get_sorted_buffers()
  local _, _, current_line =
    display_buffers(M.current_switcher.buf, buffers, current_buffer)

  -- Adjust cursor position
  local cursor = api.nvim_win_get_cursor(M.current_switcher.win)
  if cursor[1] > #buffers then
    api.nvim_win_set_cursor(M.current_switcher.win, { #buffers, 1 })
  elseif current_line then
    api.nvim_win_set_cursor(M.current_switcher.win, { current_line, 7 }) -- Set to 1st letter of file path
  end
end

-- Add this function for help menu
local function show_help_window()
  local help_text = {
    "Keymaps:",
    "a-g      - Quick select buffers",
    "<CR>     - Select buffer",
    "v        - Toggle vertical split mode",
    "-        - Toggle horizontal split mode",
    "D        - Delete buffer",
    "R        - Reset buffer frecency score",
    "q/Esc    - Close switcher",
    "g?       - Show this help",
  }

  -- Create a small floating window
  local width = 40
  local height = #help_text
  local main_win = M.current_switcher.win
  local main_config = api.nvim_win_get_config(main_win)

  local row = main_config.row + api.nvim_win_get_height(main_win) + 1 -- Add 1 for slight gap
  local col = main_config.col

  local buf = api.nvim_create_buf(false, true)
  local win_opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  }

  local win = api.nvim_open_win(buf, false, win_opts)
  api.nvim_buf_set_lines(buf, 0, -1, false, help_text)

  -- Add highlighting
  for i = 0, #help_text - 1 do
    if i == 0 then
      api.nvim_buf_add_highlight(buf, -1, "Title", i, 0, -1)
    else
      -- Highlight the keybinding part
      local dash_pos = help_text[i + 1]:find("-")
      if dash_pos then
        api.nvim_buf_add_highlight(buf, -1, "Special", i, 0, dash_pos - 1)
      end
    end
  end

  -- Auto-close help window when main window closes
  api.nvim_create_autocmd("WinClosed", {
    buffer = M.current_switcher.buf,
    callback = function()
      if api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
      end
    end,
    once = true,
  })

  return buf, win
end

-- Add this helper function at module level
local function set_fixed_cursor_column(win, line)
  local lines =
    api.nvim_buf_get_lines(M.current_switcher.buf, line - 1, line, false)
  if #lines > 0 then
    -- Position after key and icon (adjust the number based on your preferred position)
    local fixed_col = #config.window.left_padding + 7 -- This will position after "a  󰢱 "
    api.nvim_win_set_cursor(win, { line, fixed_col })
  end
end
-- Main function to show buffer switcher
function M.show_switcher()
  current_buffer = api.nvim_get_current_buf() -- Save the current buffer ID
  -- Close existing switcher if open
  if is_switcher_open() then
    api.nvim_win_close(M.current_switcher.win, true)
    M.current_switcher = { buf = nil, win = nil }
  end

  local buffers = get_sorted_buffers()
  local buf, win = create_float_win()
  local mode = {
    vertical = false,
    horizontal = false,
  }
  api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      local cursor = api.nvim_win_get_cursor(win)
      local fixed_col = #config.window.left_padding + 7 -- This will position after "a  󰢱 "
      api.nvim_win_set_cursor(win, { cursor[1], fixed_col })
    end,
  })

  -- Store current switcher
  M.current_switcher = { buf = buf, win = win }
  local key_map, _, current_line = display_buffers(buf, buffers, current_buffer) -- Pass the original buffer ID

  -- Calculate correct cursor position (after key and icon)
  local function get_filename_col(line_text)
    local _, icon_end = line_text:find("^%s*[a-z]%s+[^ ]+ ")
    return icon_end or 6 -- fallback to 6 if pattern not found
  end
  if current_line then
    vim.schedule(function()
      if api.nvim_win_is_valid(win) then
        local lines =
          api.nvim_buf_get_lines(buf, current_line - 1, current_line, false)
        if #lines > 0 then
          local col = get_filename_col(lines[1])
          local fixed_col = #config.window.left_padding + 7 -- This will position after "a  󰢱 "
          api.nvim_win_set_cursor(win, { current_line, fixed_col })
        end
      end
    end)
  end

  local function clear_echo()
    vim.api.nvim_echo({ { "" } }, false, {})
  end

  local function reset_mode()
    mode.vertical = false
    mode.horizontal = false
    clear_echo()
  end

  -- Add escape key to reset mode
  api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = reset_mode,
    noremap = true,
    silent = true,
  })
  -- Set up key mappings for selection
  for key, buffer_id in pairs(key_map) do
    local key_handler = function()
      clear_echo() -- Clear echo before closing
      api.nvim_win_close(win, true)
      if mode.vertical then
        vim.cmd("vsplit")
      elseif mode.horizontal then
        vim.cmd("split")
      end
      api.nvim_set_current_buf(buffer_id)
    end

    api.nvim_buf_set_keymap(buf, "n", key, "", {
      callback = key_handler,
      noremap = true,
      silent = true,
    })
  end

  -- Modified split mappings
  api.nvim_buf_set_keymap(buf, "n", config.split_commands.vertical, "", {
    callback = function()
      mode.vertical = not mode.vertical
      mode.horizontal = false
      if mode.vertical then
        vim.api.nvim_echo({ { " VERTICAL ", "IncSearch" } }, false, {})
      else
        clear_echo()
      end
    end,
    noremap = true,
    silent = true,
  })

  -- Modify horizontal split mapping
  api.nvim_buf_set_keymap(buf, "n", config.split_commands.horizontal, "", {
    callback = function()
      mode.horizontal = not mode.horizontal
      mode.vertical = false
      if mode.horizontal then
        vim.api.nvim_echo({ { " HORIZONTAL ", "IncSearch" } }, false, {})
      else
        clear_echo()
      end
    end,
    noremap = true,
    silent = true,
  })
  -- delete buffer mapping
  api.nvim_buf_set_keymap(buf, "n", config.delete_key, "", {
    callback = function()
      local cursor = api.nvim_win_get_cursor(win)
      local line_num = cursor[1] - 1
      buffers = get_sorted_buffers()
      if line_num <= #buffers then
        local buffer_to_delete = buffers[line_num].id
        if delete_buffer(buffer_to_delete, win) then
          refresh_switcher()
        end
      end
    end,
    noremap = true,
    silent = true,
  })

  -- Modify the select_key handler
  api.nvim_buf_set_keymap(buf, "n", config.select_key, "", {
    callback = function()
      local cursor = api.nvim_win_get_cursor(win)
      local line_num = cursor[1] - 1
      if line_num <= #buffers then
        local buffer_id = buffers[line_num].id
        api.nvim_win_close(win, true)
        if mode.vertical then
          vim.cmd("vsplit")
        elseif mode.horizontal then
          vim.cmd("split")
        end
        api.nvim_set_current_buf(buffer_id)
      end
    end,
    noremap = true,
    silent = true,
  })

  api.nvim_buf_set_keymap(buf, "n", "R", "", {
    callback = function()
      local cursor = api.nvim_win_get_cursor(win)
      local line_num = cursor[1] - 1
      buffers = get_sorted_buffers()
      if line_num <= #buffers then
        local buffer_path = buffers[line_num].path
        if reset_buffer_score(buffer_path) then
          vim.notify("Reset frecency score for " .. buffer_path)
          refresh_switcher()
        end
      end
    end,
    noremap = true,
    silent = true,
  })
  -- Add g? mapping for help
  api.nvim_buf_set_keymap(buf, "n", "g?", "", {
    callback = function()
      show_help_window()
    end,
    noremap = true,
    silent = true,
  })
  -- Clean up switcher reference when closing
  api.nvim_buf_set_keymap(buf, "n", "q", "", {
    callback = function()
      clear_echo() -- Clear echo before closing
      api.nvim_win_close(M.current_switcher.win, true)
      M.current_switcher = { buf = nil, win = nil }
    end,
    noremap = true,
    silent = true,
  })
end

-- setup function
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.g.frecency_debug = opts.debug or false
  setup_project_paths()
  load_history()

  local group = api.nvim_create_augroup("FrecencySwitcher", { clear = true })

  -- Track buffer switches - this is where scores are calculated
  api.nvim_create_autocmd("BufEnter", {
    callback = function()
      local current_buf = api.nvim_get_current_buf()
      if is_valid_buffer(current_buf) then
        update_history(current_buf)
      end
    end,
    group = group,
  })

  -- Save on focus lost and exit
  api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
    callback = function()
      M.save_history()
      cleanup_old_histories()
    end,
    group = group,
  })

  -- Handle project changes
  api.nvim_create_autocmd("DirChanged", {
    callback = function()
      M.save_history()
      setup_project_paths()
      load_history()
    end,
    group = group,
  })
end

return M
