-- Although vim's quickfix list was originally intended to display errors, it's
-- scope has since grown to cover more generic "position list" use cases.
--
-- I want to use it as a non-floating, persistent version of telescope, but
-- quickfix's current design makes that difficult
--
-- Enter the Microscope/µscope ; The quickfix list & telescope had a child
--
-- It has a similar UI to the quickfix list, but each entry represents a generic
-- editor action. Could be "opening a helpfile" or "executing a command". Entries a previwable.
-- So bascially, a non-floating version of Telescope

local core = require("core")
local fzy = require("vendor.fzy")
local libbuf = require("libbuf")
local M = {}

local dispatch = core.dispatch_custom_event
local on = core.on_custom_event

-- We will open three windows in a tab.
-- Communication between windows is done via custom events
local Ev = {
  -- The user typed something
  input_change = "UScopeInputChange",
  -- The user pressed a navigation key (e.g. up, down, <C-u> .. )
  user_movement = "UScopeUserMovement",
  -- A new item was selected
  new_selection = "UScopeNewSelection",
  -- Signals that the user made their final selection (i.e. they pressed Enter)
  final_selection = "UScopeFinalSelection",
}

-- Extracts the values of the given `keys` from each item in `items` and
-- concatenates them.
--
-- To support making the list of entries aligned, this also returns a table
-- listing how wide each column should be
--
-- Given the following arguments
-- ```
-- items:
-- {
--   { filename = "a.txt", info = "someinfo", line = 3 },
--   { filename = "abc.txt", info = "hello", line = 4 },
-- }
-- keys = { "info", "filename" }
-- ```
--
-- This function returns two tables
-- ```
-- First table:
-- {
--   "someinfo       a.txt  "
--   "hello          abc.txt"
-- }
-- Second table:
-- { 15, 7 }
--
-- Note: Any values containing newlines are truncated.
-- ```
local stringify_items = function(items, keys)
  local rows = {}
  local column_widths = {}
  local gap = 4

  for _, item in ipairs(items) do
    local parts = {}
    for i, key in ipairs(keys) do
      local value = string.gsub(item[key], "[\r\n].*", "")
      column_widths[i] = math.max(#value + gap, column_widths[i] or 1)
      table.insert(parts, value)
    end
    table.insert(rows, parts)
  end

  local lines = {}
  for _, parts in ipairs(rows) do
    local line = {}
    for j, val in ipairs(parts) do
      local padding = column_widths[j] - #val
      table.insert(line, val)
      -- Do not insert padding after the last column
      if j ~= #parts then
        table.insert(line, string.rep(" ", padding))
      end
    end
    table.insert(lines, table.concat(line, ""))
  end

  return lines, column_widths
end

-- Returns focus back to the tab the user was in before entering uscope
--
-- In the odd  case that there is not other tab, does nothing and returns
-- `false`
local goto_previous_tab = function()
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd("tabprevious")
    return true
  end

  return false
end

-- Exits the uscope tab without a selection
--
-- If the uscope tab is the last one, exits vim
local exit_uscope_with_no_selection = function(location)
  local done = goto_previous_tab()
  if done then
    vim.cmd(location.tabnr .. "tabclose")
  else
    vim.cmd("quitall")
  end
end

-- Exits the uscope tab with a selection
--
-- If the uscope tab is the last one, create a new  tab before it and execute
-- the selection callback there
local exit_uscope_with_selection = function(location, on_select, item)
  local done = goto_previous_tab()
  if not done then
    vim.cmd("tabnew")
    vim.cmd("tabprevious")
  end
  vim.cmd(location.tabnr .. "tabclose")
  on_select(item)
end

-- Display a centered message in a buffer
local display_message = function(window, buffer, message)
  local height = vim.api.nvim_win_get_height(window)
  local width = vim.api.nvim_win_get_width(window)

  if vim.wo[window].number then
    width = width - vim.wo[window].numberwidth
  end

  local fillchar = " "
  local fillrow = string.rep(fillchar, width)

  local lines = {}
  for _ = 1, height do
    table.insert(lines, fillrow)
  end

  local msg_row = math.floor(height / 2)
  local msg_column = math.max(1, width / 2 - #message)

  lines[msg_row - 1] = ""
  lines[msg_row] = string.rep(" ", msg_column) .. message
  lines[msg_row + 1] = ""

  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
  vim.bo[buffer].modifiable = false
end

-- Writes the contents of a file to a buffer
local write_file_to_buffer = function(buffer, path)
  local lines = {}
  for l in io.lines(path) do
    table.insert(lines, l)
  end

  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
  vim.bo[buffer].modifiable = false
end

-- The supported preview strategies
local Previewers = {
  -- Previewing a help file means opening the file and searching for the tag to
  -- navigate to the right position
  help = function(buffer, window, preview_config)
    write_file_to_buffer(buffer, preview_config.path)
    -- Thank you telescope devs for helping me figure this part out:
    -- https://github.com/nvim-telescope/telescope.nvim/blob/87e92ea31b2b61d45ad044cf7b2d9b66dad2a618/lua/telescope/previewers/buffer_previewer.lua#L289
    vim.api.nvim_buf_call(buffer, function()
      vim.fn.clearmatches()
      -- The `\V` make it such that the query does not treat the tag indicator
      -- (i.e. "*") as a special character
      local query = [[\V]] .. preview_config.search:sub(2)
      -- Go to the top of the file
      vim.cmd("normal! gg")
      -- Search
      vim.fn.search(query, "W")
      -- Reposition the edit window
      vim.cmd("normal! zz")
      -- Highlight the match
      vim.fn.matchadd("Search", query)
    end)

    vim.bo[buffer].syntax = "help"
  end,

  -- Previewing a regular file means opening it, detecting the filetype and
  -- setting the cursor
  file = function(buffer, window, preview_config)
    write_file_to_buffer(buffer, preview_config.path)
    vim.api.nvim_win_set_cursor(window, { preview_config.line or 1, 0 })
    vim.bo[buffer].syntax = vim.filetype.match({
      buf = buffer,
      filename = preview_config.path,
    })
  end,
}

-- Bindings for existing uscope with or without a selection
local basic_binds = function(config)
  return {
    {
      { "n", "i" },
      { "<Esc>" },
      function(buf)
        local location = libbuf.display_info(buf)
        if not location then
          return
        end
        exit_uscope_with_no_selection(location)
      end,
    },
    {
      { "n", "i" },
      "<Enter>",
      function()
        dispatch(Ev.final_selection, { namespace = config.title })
      end,
    },
  }
end

-- Bindings for navigating the result list from the search window
local result_list_navigation = function(config)
  return {
    {
      { "n", "i" },
      { "<Down>", "<C-n>" },
      function()
        dispatch(Ev.user_movement, { namespace = config.title, data = { offset = 1 } })
      end,
    },
    {
      { "n", "i" },
      { "<Up>", "<C-p>" },
      function()
        dispatch(Ev.user_movement, { namespace = config.title, data = { offset = -1 } })
      end,
    },
    {
      { "n", "i" },
      "<C-d>",
      function()
        dispatch(
          Ev.user_movement,
          { namespace = config.title, data = { offset = "down" } }
        )
      end,
    },
    {
      { "n", "i" },
      "<C-u>",
      function()
        dispatch(Ev.user_movement, { namespace = config.title, data = { offset = "up" } })
      end,
    },
  }
end

-- The preview window listens for new selections and previews them
local preview_window = function(config)
  local buffer =
    libbuf.new_buffer({ handle = "uscope-preview" .. config.title, force = true })

  libbuf.set_buffer_options(buffer, {
    buflisted = false,
    buftype = "nofile",
    modifiable = false,
  })

  libbuf.set_window_options(buffer, {
    winbar = "Preview",
    statusline = "%#Normal#",
  })

  on(Ev.new_selection, {
    buffer = buffer,
    namespace = config.title,
    callback = function(cmd_args)
      local selection = cmd_args.data.selection
      if not selection then
        return
      end
      local preview_config = config.get_preview_config(selection)
      if not preview_config then
        return
      end

      local location = libbuf.display_info(buffer)

      if not location then
        return
      end

      local preview_func = Previewers[preview_config.type]

      if not preview_func then
        display_message(location.window, buffer, "Preview not available")
        return
      end

      preview_func(buffer, location.window, preview_config)
    end,
  })

  return buffer
end

-- The results window displays the results of fuzzy searching & handles
-- navigation
local results_window = function(config)
  local buffer =
    libbuf.new_buffer({ handle = "uscope-results" .. config.title, force = true })

  libbuf.set_buffer_options(buffer, {
    buflisted = false,
    buftype = "nofile",
    modifiable = false,
  })
  libbuf.set_window_options(buffer, {
    winbar = config.title,
    cursorline = true,
    cursorlineopt = "line,number",
    statusline = "%#Normal#",
    number = false,
    wrap = false,
  })

  libbuf.set_buffer_keybinds(buffer, basic_binds(config))

  local matching_items = config.items
  local search_column = config.columns[config.search_column]
  local haystack = vim.tbl_map(function(i)
    return i[search_column]
  end, config.items)

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buffer,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local selection = matching_items[cursor[1]]
      dispatch(Ev.new_selection, {
        namespace = config.title,
        data = { selection = selection },
      })
    end,
  })

  on(Ev.user_movement, {
    buffer = buffer,
    namespace = config.title,
    callback = function(cmd_args)
      local location = libbuf.display_info(buffer)

      if not location then
        return
      end

      local offset = cmd_args.data.offset
      if offset == "up" then
        offset = vim.wo[location.window].scroll * -1
      elseif offset == "down" then
        offset = vim.wo[location.window].scroll
      end

      local cursor = vim.api.nvim_win_get_cursor(location.window)
      local num_lines = vim.fn.line("$", location.window)
      local new_pos = { core.clamp(cursor[1] + offset, 1, num_lines), 0 }
      vim.api.nvim_win_set_cursor(location.window, new_pos)
      local selection = matching_items[new_pos[1]]
      dispatch(Ev.new_selection, {
        namespace = config.title,
        data = { selection = selection },
      })
    end,
  })

  on(Ev.input_change, {
    buffer = buffer,
    namespace = config.title,
    callback = function(cmd_args)
      local user_input = cmd_args.data.user_input
      local highlight_positions = {}

      if #user_input > 0 then
        local result = fzy.filter(user_input, haystack)
        -- Sort by score in descending order
        table.sort(result, function(a, b)
          return a[3] > b[3]
        end)
        matching_items = vim.tbl_map(function(i)
          return config.items[i[1]]
        end, result)
        highlight_positions = vim.tbl_map(function(i)
          return i[2]
        end, result)
      else
        matching_items = config.items
      end

      local column_offset = config.column_offsets[config.search_column] - 1
      local lines = vim.tbl_map(function(i)
        return i._buffer_text
      end, matching_items)

      local hlns = vim.api.nvim_create_namespace("uscope")
      vim.api.nvim_buf_clear_namespace(buffer, hlns, 0, -1)

      vim.bo[buffer].modifiable = true
      vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
      vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)

      for line, match_positions in ipairs(highlight_positions) do
        for _, pos in ipairs(match_positions) do
          vim.api.nvim_buf_add_highlight(
            buffer,
            hlns,
            "Special",
            line - 1,
            column_offset + pos - 1,
            column_offset + pos
          )
        end
      end
      vim.bo[buffer].modifiable = false

      local location = libbuf.display_info(buffer)

      if not location then
        return
      end

      -- Clearing the buffer will reset the cursor to the first line
      local selection = matching_items[1]
      dispatch(Ev.new_selection, {
        namespace = config.title,
        data = { selection = selection },
      })
    end,
  })

  on(Ev.final_selection, {
    buffer = buffer,
    namespace = config.title,
    callback = function()
      local location = libbuf.display_info(buffer)
      if not location then
        return
      end
      local cursor = vim.api.nvim_win_get_cursor(location.window)
      local selection = matching_items[cursor[1]]
      if not selection then
        return
      end
      exit_uscope_with_selection(location, config.on_select, selection)
    end,
  })

  return buffer
end

-- The search window mostly accepts user input & dispatches events
local search_window = function(config)
  -- Reuse an existing buffer with the same handle if found. This allows for
  -- persisting the user's search query
  local handle = "uscope-search" .. config.title

  local buffer = libbuf.find_buffer(handle)

  if not buffer then
    buffer = libbuf.new_buffer({ handle = handle })
  end

  libbuf.set_buffer_options(buffer, {
    buflisted = false,
    buftype = "nofile",
    modifiable = true,
  })

  libbuf.set_window_options(buffer, {
    winbar = "Search:",
    statusline = "%#Normal#",
    cursorline = false,
    number = false,
  })

  libbuf.set_buffer_keybinds(buffer, basic_binds(config))
  libbuf.set_buffer_keybinds(buffer, result_list_navigation(config))

  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = buffer,
    callback = function()
      core.startinsert()
      vim.cmd("NoMatchParen")
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buffer,
    callback = function()
      vim.cmd("stopinsert")
      vim.cmd("DoMatchParen")
    end,
  })

  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = buffer,
    callback = function()
      local user_input = vim.api.nvim_buf_get_lines(buffer, 0, 1, true)[1]
      dispatch(
        Ev.input_change,
        { namespace = config.title, data = { user_input = user_input } }
      )
    end,
  })

  vim.api.nvim_exec_autocmds("TextChangedI", {
    buffer = buffer,
  })

  -- Clear the buffer once the user has made a final selection
  on(Ev.final_selection, {
    buffer = buffer,
    callback = function()
      vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
    end,
  })

  return buffer
end

-- Open the µscope
M.open = function(config)
  vim.validate({
    config = { config, "table" },
    -- µscope Title. Note that this acts as an id. Opening µscope twice with
    -- the same title ends up reusing the existing tab
    ["config.title"] = { config.title, "string" },
    -- List of objects: items to display
    ["config.items"] = { config.items, "table" },
    -- List of string: which properties within each item object to display
    ["config.columns"] = { config.columns, "table" },
    -- Disables the search window so results cannot be filtered
    ["config.disable_search"] = { config.disable_search, "boolean", true },
    -- Index to the column that should be used for searching. Defaults to 1
    ["config.search_column"] = { config.search_column, "number", true },
    -- Function invoked whenever an item is to be previewed. Should return an
    -- object specifying the type & configuration of the preview to display for
    -- the item
    ["config.get_preview_config"] = { config.get_preview_config, "function", true },
    -- Function invoked whenever the user selects an item. It is executed in
    -- the context of the window the user was on before opening uscope
    ["config.on_select"] = { config.on_select, "function", true },
  })

  if not config.search_column then
    config.search_column = 1
  end

  if not config.get_preview_config then
    config.get_preview_config = function(_) end
  end

  if not config.on_select then
    config.on_select = function(_) end
  end

  if not config.disable_search then
    config.disable_search = false
  end

  -- For each item in the list, extract the properties we want to display and stringify them
  local buffer_lines, column_widths = stringify_items(config.items, config.columns)

  -- Calculate column offsets for highlighting
  local column_offsets = { 1 }
  for idx, width in ipairs(column_widths) do
    table.insert(column_offsets, width + column_offsets[idx])
  end
  config.column_offsets = column_offsets

  -- Give each item a new property called _buffer_text
  local uscope_items = {}
  for idx, item in ipairs(config.items) do
    table.insert(
      uscope_items,
      vim.tbl_extend("error", item, {
        _buffer_text = buffer_lines[idx],
      })
    )
  end
  config.items = uscope_items

  local preview = preview_window(config)
  local results = results_window(config)
  local search = nil

  if not config.disable_search then
    search = search_window(config)
  end

  -- If the results window is still open somewhere, reuse that tab
  local location = libbuf.display_info(results)
  if location then
    vim.api.nvim_set_current_win(location.window)
    vim.cmd("silent only")
  else
    -- Note: make sure open the new tab with the existing buffer, otherwise,
    -- each time uscope is opened, an orphaned buffer will be created
    vim.cmd("tab sbuffer")
  end

  -- Open the layout

  if config.disable_search then
    local wins = libbuf.layout("row", {
      { buffer = results },
      { buffer = preview },
    })
    vim.api.nvim_set_current_win(wins[1])

    -- Since there is no search window, we need to simulate an initial user input
    -- of `""` to get the results window to display the items unfiltered
    dispatch(Ev.input_change, { namespace = config.title, data = { user_input = "" } })
    return
  end

  local wins = libbuf.layout("column", {
    { buffer = results },
    { buffer = search, size = 1 },
  })

  vim.api.nvim_set_current_win(wins[1])
  libbuf.layout("row", {
    { buffer = results },
    { buffer = preview },
  })
  vim.api.nvim_set_current_win(wins[2])
end

return M
