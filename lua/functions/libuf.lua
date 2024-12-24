-- Working with vim buffers

local core = require("core")
local M = {}

-- Returns the first window & tab the buffer is currently displayed in
--
-- Returns `nil` if the buffer is not currently displyed anywhere
M.display_info = function(b)
  local info = vim.fn.getbufinfo(b)[1]

  if not info then
    return nil
  end

  if #info.windows == 0 then
    return nil
  end

  local tab = vim.api.nvim_win_get_tabpage(info.windows[1])
  local tabpagenr = vim.api.nvim_tabpage_get_number(tab)

  return {
    window = info.windows[1],
    tab = tab,
    tabnr = tabpagenr,
  }
end

local option_default = {
  cursorlineopt = "number,line",
}

-- Sets window options that will be active when the buffer is currently
-- displayed in a window
M.set_window_options = function(b, options)
  -- I want to be able to specify window-local options that only apply when
  -- the buffer is visible in a window. These options should be cleared
  -- when the buffer is no longer displayed in that window
  --
  -- Some window-local options are "global-local"; meaning you can
  -- associate them to current buffer within the window with `:setlocal`. Not
  -- all of them work that way. Crucially, when an option is not global-local
  -- and you use `:setlocal`, it sets the global option, meaning the change will
  -- apply to the window regardless of the buffer being displayed. I don't want
  -- that. I'd like this API to be consistent in allowing you to set ANY
  -- window-local option when the underlying buffer is visible
  --
  -- My approach is to set the window-local options in the `BufWinEnter` event. This
  -- triggers whenever a buffer starts being displayed in a new window. I also
  -- record the global versions of the option to restore later.[1]
  --
  -- Then I hook into `BufLeave` event and record which windows contain my buffer
  -- before and after.
  -- If a window that was present before BufLeave is missing after BufLeave, we
  -- know that the buffer is no longer displayed there and we can cleanup the
  -- options.
  --
  -- [1] I restore the global options because setting the `local` version of a
  -- window-local option can sometimes modify the global version ._. .... See
  -- :help `local-options`. Also see these issues for more context:
  -- -> https://github.com/neovim/neovim/issues/11525
  -- -> https://github.com/vim/vim/issues/4945
  vim.validate({ options = { options, "table" } })

  local make_key = function(name)
    return "__libbuf_window_option_global_" .. name
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    buffer = b,
    callback = function()
      local window = vim.api.nvim_get_current_win()
      -- Store the original global option values
      for k in pairs(options) do
        local original =
          vim.api.nvim_get_option_value(k, { scope = "global", win = window })
        vim.w[window][make_key(k)] = original
      end

      -- Then apply our window option values as "local", so they "stick" to
      -- this specific buffer in the window. Note that if this option does not
      -- support the global-local nonsense, it will set the global version
      for k, v in pairs(options) do
        vim.api.nvim_set_option_value(k, v, { scope = "local", win = window })
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = b,
    callback = function()
      local windows_before = core.Set(vim.fn.getbufinfo(b)[1].windows)

      -- This vim.schedule allows us to run code after the BufLeave autocommand
      -- has triggered and the buffer is no longer in focus
      vim.schedule(function()
        -- At this point, the buffer or window may not actually exist (ex: we
        -- closed the window or deleted the buffer)

        -- If the buffer no longer exists, by default neovim closes all the
        -- windows that were displaying it. However, my config has some tweaks
        -- that prevent this behavior (e.g. terminal.lua), so i still need to
        -- reset options in the windows the buffer was displayed in
        local windows_after = core.Set({})
        if vim.api.nvim_buf_is_valid(b) then
          windows_after = core.Set(vim.fn.getbufinfo(b)[1].windows)
        end

        -- The windows that the buffer no longer appears in
        local windows_we_left = {}

        for w in pairs(windows_before) do
          if not windows_after[w] then
            if vim.api.nvim_win_is_valid(w) then
              table.insert(windows_we_left, w)
            end
          end
        end

        -- Restore the options
        for _, w in ipairs(windows_we_left) do
          if vim.api.nvim_win_is_valid(w) then
            for key in pairs(options) do
              local original = vim.w[w][make_key(key)]
              -- HACK: Certain options cannot be set to nil. It is not clear why
              -- Use a default value in such cases
              if not original and option_default[key] then
                original = option_default[key]
              end
              vim.api.nvim_set_option_value(key, original, { scope = "global", win = w })
              vim.w[w][make_key(key)] = nil
            end
          end
        end
      end)
    end,
  })
end

-- Sets buffer options
M.set_buffer_options = function(b, options)
  vim.validate({ options = { options, "table" } })
  for k, v in pairs(options) do
    vim.bo[b][k] = v
  end
end

-- Define buffer-local keybinds
M.set_buffer_keybinds = function(b, binds)
  for _, bind in ipairs(binds) do
    vim.validate({
      -- Mode
      ["config.bind[][1]"] = { bind[1], { "table", "string" } },
      -- Key
      ["config.bind[][2]"] = { bind[2], { "table", "string" } },
      -- Action
      ["config.bind[][3]"] = { bind[3], "function", true },
    })

    local keys_to_map = {}
    if type(bind[2]) == "string" then
      keys_to_map = { bind[2] }
    else
      keys_to_map = bind[2]
    end

    for _, lhs in ipairs(keys_to_map) do
      core.bind(bind[1], lhs, function()
        if bind[3] then
          bind[3](b)
        end
      end, { buffer = b })
    end
  end
end

-- Returns an existing buffer with the given handle
--
-- Returns `nil` if no such buffer exists
--
-- Note: Only buffers created with `libbuf.new_buffer` have a handle.
M.find_buffer = function(handle)
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if vim.b[buf].__libbuf_handle == handle then
      return buf
    end
  end

  return nil
end

--- Returns the handle for buffer `b` if it exists
---
--- @param b number @ The buffer number
---
--- @return string|nil
M.get_handle = function(b)
  if vim.api.nvim_buf_is_valid(b) then
    return vim.b[b].__libbuf_handle
  end
  return nil
end

--- Updates the handle of buffer `b` if it exists
---
--- @param b number @ buffer number
--- @param new_handle string @ new handle
M.update_handle = function(b, new_handle)
  if vim.api.nvim_buf_is_valid(b) then
    vim.b[b].__libbuf_handle = new_handle
  end
end

--- Delete buffer `b`
---
--- If `keep_window` is `true`, the window containing the buffer that is about
--- to be deleted will start displaying the alternate file
---
--- @param b number @ The buffer to delete
--- @param keep_window? boolean @ Whether to close the containing window
M.delete_buf = function(b, keep_window)
  vim.api.nvim_buf_call(b, function()
    if keep_window then
      vim.cmd("buffer #")
    end
    vim.api.nvim_buf_delete(b, { force = true })
  end)
end

-- Create a new buffer with the given handle
--
-- Fails if another buffer exists with the same handle
--
-- If `force` is `true`, any already existing buffer with the same handle is
-- deleted
M.new_buffer = function(config)
  vim.validate({
    config = { config, "table" },
    ["config.handle"] = { config.handle, "string" },
    ["config.force"] = { config.force, "boolean", true },
  })

  if not config.force then
    config.force = false
  end

  local existing = M.find_buffer(config.handle)

  if existing and config.force then
    vim.api.nvim_buf_delete(existing, { force = true })
  end

  if existing and not config.force then
    error("A buffer with handle [" .. config.handle .. "] already exists")
  end

  local new = vim.api.nvim_create_buf(true, false)
  vim.b[new].__libbuf_handle = config.handle

  return new
end

-- Display buffers in windows
--
-- `direction` specifies if the buffers should be laid out in a row or column
--
-- The buffers are laid out in the order they are given
--
-- The cursor will be in the last window when this function ends
--
-- Returns a list of the created windows
M.layout = function(direction, config)
  vim.validate({
    direction = {
      direction,
      function(d)
        return d == "row" or d == "column"
      end,
    },
    config = { config, "table" },
  })

  -- Example: 3 windows means 2 splits
  local num_splits = #config - 1

  -- Make a first pass, creating the splits
  local windows = {}
  for _ = 1, num_splits do
    table.insert(windows, vim.api.nvim_get_current_win())

    if direction == "column" then
      vim.cmd("belowright horizontal split")
    else
      vim.cmd("belowright vertical split")
    end
  end

  table.insert(windows, vim.api.nvim_get_current_win())

  -- A second pass for setting the size & buffers
  for i, c in ipairs(config) do
    vim.validate({
      ["config[].buffer"] = { c.buffer, "number" },
      ["config[].size"] = { c.size, "number", true },
    })
    vim.api.nvim_set_current_win(windows[i])
    if c.size then
      if direction == "column" then
        vim.cmd("resize " .. tostring(c.size))
        vim.opt.winfixheight = true
      else
        vim.cmd("vertical resize " .. tostring(c.size))
        vim.opt.winfixwidth = true
      end
    end
    vim.api.nvim_set_current_buf(c.buffer)
  end

  -- Equalize all windows (except for those whose dimensions has been
  -- explicitely set)
  vim.cmd("wincmd =")

  return windows
end

return M
