-- This module to run python code in a scratch buffer (inline as virtual text similar to molten.nvim
-- This whole module was inspired by Snacks.scratch for lua, from Folke https://github.com/folke/snacks.nvim
-- many function taken from that module so credit to Folke.
local api = vim.api
local fn = vim.fn
local uv = vim.uv or vim.loop

---@class python_scratch
local M = {}

-- Add this new function to handle window creation
---@param buf number Buffer handle
---@return number win Window handle
function M.create_scratch_window(buf)
  -- Get filetype icon (if available)
  local icon, icon_hl = "", nil
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    icon, icon_hl = devicons.get_icon("file.py", "python", { default = true })
  end

  -- Add reset functionality - just clear the buffer
  local function reset_buffer()
    api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  end
  -- Prepare window title
  local title = {
    { " " },
    { icon .. " ", icon_hl },
    { M.config.name },
    { vim.v.count1 > 1 and " " .. vim.v.count1 or "" },
    { " " },
  }

  -- Prepare window footer with keymaps
  local keymaps = {
    { key = "<CR>", desc = "Run Code" },
    { key = "R", desc = "Clear" },
    { key = "q", desc = "Close" },
  }

  local footer = { { " " } }
  for _, keymap in ipairs(keymaps) do
    table.insert(
      footer,
      { " " .. fn.keytrans(vim.keycode(keymap.key)) .. " ", "PyScratchKey" }
    )
    table.insert(footer, { " " .. keymap.desc .. " ", "PyScratchDesc" })
    table.insert(footer, { " " })
  end

  -- Create window
  local border_offset = M.config.window.border ~= "none" and 2 or 0
  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = M.config.window.width,
    height = M.config.window.height,
    col = math.floor((vim.o.columns - M.config.window.width - border_offset) / 2),
    row = math.floor((vim.o.lines - M.config.window.height - border_offset) / 2),
    style = M.config.window.style,
    border = M.config.window.border,
    title = title,
    title_pos = M.config.window.title_pos,
    footer = footer,
    footer_pos = M.config.window.footer_pos,
    zindex = M.config.window.zindex,
  })

  -- Set window-local options
  api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = win })

  -- Set up keymaps
  local function set_keymap(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { buffer = buf, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Run code mappings
  set_keymap({ "n", "x" }, "<CR>", function()
    M.run({ buf = buf })
  end, { desc = "Run Python code" })

  -- Buffer management mappings
  set_keymap("n", "q", "<cmd>close<CR>", { desc = "Close scratch buffer" })

  -- Reset mapping
  set_keymap("n", "R", reset_buffer, { desc = "Clear buffer" })
  return win
end
-- Add these utility functions
function M.file_encode(str)
  return str:gsub("([^%w%-_%.\t ])", function(c)
    return string.format("_%%%02X", string.byte(c))
  end)
end

function M.file_decode(str)
  return str:gsub("_%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

-- Add function to list scratch buffers
function M.list()
  local files = {}

  for file, type in vim.fs.dir(M.config.root) do
    if type == "file" and file:match("%.py$") then
      local full_path = vim.fs.normalize(M.config.root .. "/" .. file)

      -- Read the file content
      local lines = fn.readfile(full_path)
      local filekey_line = lines[1] or ""

      -- Get file stats
      local stat = uv.fs_stat(full_path)

      -- Get preview from the first non-filekey line
      local preview = ""
      for _, line in ipairs(lines) do
        if not line:match("^# Filekey:") then
          preview = line
          break
        end
      end

      if #preview > 50 then
        preview = preview:sub(1, 47) .. "..."
      end

      -- Parse the filekey
      local filekey = filekey_line:match("^# Filekey: (.+)$")
      local count, name, cwd, branch

      if filekey then
        -- Print for debugging
        print("Filekey found:", filekey)
        count, name, cwd, branch = filekey:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
        -- Print parsed values for debugging
        print("Parsed values:", count, name, cwd, branch)
      end

      table.insert(files, {
        file = full_path,
        cwd = cwd and fn.fnamemodify(cwd, ":~") or "unknown",
        mtime = stat and stat.mtime.sec or 0,
        preview = preview,
        branch = branch and branch ~= "" and branch or nil,
      })
    end
  end

  -- Sort by modification time
  table.sort(files, function(a, b)
    return a.mtime > b.mtime
  end)
  return files
end

function M.select()
  local items = M.list()

  if #items == 0 then
    vim.notify("No scratch buffers found", vim.log.levels.INFO)
    return
  end

  local widths = { 0, 0 }
  for _, item in ipairs(items) do
    -- Format the middle section
    item.scratch_info = string.format(
      "%s%s",
      item.cwd,
      item.branch and (' - "' .. item.branch .. '"') or ""
    )

    widths[1] = math.max(widths[1], api.nvim_strwidth(item.scratch_info))
    widths[2] = math.max(widths[2], api.nvim_strwidth(item.preview))
  end

  vim.ui.select(items, {
    prompt = "Select Python Scratch Buffer",
    format_item = function(item)
      local parts = {
        item.scratch_info
          .. string.rep(" ", widths[1] - api.nvim_strwidth(item.scratch_info)),
        item.preview,
      }
      return table.concat(parts, " │ ")
    end,
  }, function(selected)
    if selected then
      local buf = fn.bufadd(selected.file)

      -- Check if window with this buffer already exists
      for _, win in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(win) == buf then
          api.nvim_win_close(win, false)
          return
        end
      end

      -- Set buffer options
      api.nvim_set_option_value("filetype", M.config.filetype, { buf = buf })
      api.nvim_set_option_value("buftype", "", { buf = buf })
      api.nvim_set_option_value("swapfile", false, { buf = buf })

      -- Use the common window creation function
      M.create_scratch_window(buf)
    end
  end)
end

-- Create a namespace for our inline virtual text
M.ns = api.nvim_create_namespace("python-scratch")

-- Basic configuration
M.config = {
  name = "Python Scratch",
  filetype = "python",
  root = fn.stdpath("data") .. "/python-scratch",
  autowrite = true,
  window = {
    width = 90,
    height = 25,
    border = "rounded",
    title_pos = "center",
    footer_pos = "center",
    style = "minimal",
    zindex = 20,
  },
}

-- Set up highlights
local function setup_highlights()
  api.nvim_set_hl(0, "PyScratchOutput", { fg = "#89b4fa", italic = true })
  api.nvim_set_hl(0, "PyScratchError", { fg = "#f38ba8", italic = true })
  api.nvim_set_hl(0, "PyScratchKey", { link = "DiagnosticVirtualTextInfo" })
  api.nvim_set_hl(0, "PyScratchDesc", { link = "DiagnosticInfo" })
end

-- Function to run Python code and show inline output
---@param opts? {buf?: number}
function M.run(opts)
  opts = opts or {}
  local buf = opts.buf or api.nvim_get_current_buf()

  -- Clear previous output
  api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)

  -- Get the lines to run based on mode
  local lines ---@type string[]
  local output_line -- Line where output should appear

  if fn.mode():find("[vV]") then
    fn.feedkeys(":", "nx")
    local from = api.nvim_buf_get_mark(buf, "<")
    local to = api.nvim_buf_get_mark(buf, ">")
    lines = api.nvim_buf_get_text(buf, from[1] - 1, from[2], to[1] - 1, to[2] + 1, {})
    output_line = to[1] - 1
    fn.feedkeys("gv", "nx")
  else
    lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    output_line = #lines - 1
  end

  -- Create temporary file
  local tmp_file = fn.tempname() .. ".py"
  fn.writefile(lines, tmp_file)

  -- Collect all output lines first
  local stdout_lines = {}
  local stderr_lines = {}

  -- Run Python asynchronously
  vim.system({ "python3", tmp_file }, {
    text = true,
    stdout = function(err, data)
      if not err and data then
        vim.schedule(function()
          -- Collect stdout lines
          for _, line in ipairs(vim.split(data, "\n")) do
            if line ~= "" then
              table.insert(stdout_lines, line)
            end
          end
          -- Show all collected lines in order
          local virt_lines = {}
          for _, line in ipairs(stdout_lines) do
            table.insert(virt_lines, { { "  │ " .. line, "PyScratchOutput" } })
          end
          api.nvim_buf_set_extmark(buf, M.ns, output_line, 0, {
            virt_lines = virt_lines,
          })
        end)
      end
    end,
    stderr = function(err, data)
      if not err and data then
        vim.schedule(function()
          -- Collect stderr lines
          for _, line in ipairs(vim.split(data, "\n")) do
            if line ~= "" then
              table.insert(stderr_lines, line)
            end
          end
          -- Show all collected error lines in order
          local virt_lines = {}
          for _, line in ipairs(stderr_lines) do
            table.insert(virt_lines, { { "  │ " .. line, "PyScratchError" } })
          end
          -- Place errors after stdout if any
          local error_line = output_line
          if #stdout_lines > 0 then
            error_line = output_line + 1
          end
          api.nvim_buf_set_extmark(buf, M.ns, error_line, 0, {
            virt_lines = virt_lines,
          })
        end)
      end
    end,
  }, function()
    vim.schedule(function()
      fn.delete(tmp_file)
    end)
  end)
end

-- Generate a unique filename for the scratch buffer
local function get_scratch_file()
  local count = vim.v.count1
  local cwd = vim.fs.normalize(fn.getcwd())
  local branch = ""

  -- Try to get git branch
  local git_branch = fn.systemlist("git branch --show-current")[1]
  if vim.v.shell_error == 0 then
    branch = git_branch
  end

  local filekey = table.concat({
    tostring(count),
    M.config.name:gsub("|", " "),
    cwd,
    branch,
  }, "|")

  -- Store both the hashed and original filename
  local hashed_name = fn.sha256(filekey)
  local file = vim.fs.normalize(M.config.root .. "/" .. hashed_name .. ".py")

  if not uv.fs_stat(file) then
    local fd = io.open(file, "w")
    if fd then
      -- Store the original filekey in a comment at the top of the file
      fd:write(string.format("# Filekey: %s\n", filekey))
      fd:close()
    end
  end

  return file
end

-- Add a tracking mechanism for recent scratch buffers
M.recent_buffers = {
  by_cwd = {}, -- Track most recent buffer for each CWD
  list = {}, -- List of recently created buffers
}

function M.open()
  -- Create scratch directory if it doesn't exist
  fn.mkdir(M.config.root, "p")

  -- Get or create scratch file
  local file = get_scratch_file()
  local buf = fn.bufadd(file)
  local cwd = vim.fs.normalize(fn.getcwd())

  -- Update recent buffers tracking
  M.recent_buffers.by_cwd[cwd] = buf
  table.insert(M.recent_buffers.list, buf)

  -- Optionally, limit the number of tracked buffers
  if #M.recent_buffers.list > 10 then
    table.remove(M.recent_buffers.list, 1)
  end

  -- Rest of the existing open() function remains the same...
  api.nvim_set_option_value("filetype", M.config.filetype, { buf = buf })
  api.nvim_set_option_value("buftype", "", { buf = buf })
  api.nvim_set_option_value("swapfile", false, { buf = buf })
  api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
  api.nvim_set_option_value("buflisted", false, { buf = buf })

  local win = M.create_scratch_window(buf)

  if M.config.autowrite then
    api.nvim_create_autocmd("BufHidden", {
      buffer = buf,
      callback = function()
        vim.cmd("silent! write")
      end,
    })
  end

  return buf, win
end

-- New function to open the most recent scratch buffer for current CWD
function M.open_recent()
  local cwd = vim.fs.normalize(fn.getcwd())
  local recent_buf = M.recent_buffers.by_cwd[cwd]

  if recent_buf and api.nvim_buf_is_valid(recent_buf) then
    -- Check if window with this buffer already exists
    for _, win in ipairs(api.nvim_list_wins()) do
      if api.nvim_win_get_buf(win) == recent_buf then
        api.nvim_win_close(win, false)
        return
      end
    end

    -- Set buffer options
    api.nvim_set_option_value("filetype", M.config.filetype, { buf = recent_buf })
    api.nvim_set_option_value("buftype", "", { buf = recent_buf })
    api.nvim_set_option_value("swapfile", false, { buf = recent_buf })
    api.nvim_set_option_value("bufhidden", "hide", { buf = recent_buf })
    api.nvim_set_option_value("buflisted", false, { buf = recent_buf })

    -- Create window for the recent buffer
    M.create_scratch_window(recent_buf)
  else
    -- If no recent buffer, create a new one
    M.open()
  end
end

-- Optional: Function to list recent scratch buffers
function M.list_recent()
  return M.recent_buffers.list
end
-- -- Function to create/open a Python scratch buffer
-- function M.open()
--   -- Create scratch directory if it doesn't exist
--   fn.mkdir(M.config.root, "p")
--
--   -- Get or create scratch file
--   local file = get_scratch_file()
--   local buf = fn.bufadd(file)
--
--   -- Check if window with this buffer already exists
--   for _, win in ipairs(api.nvim_list_wins()) do
--     if api.nvim_win_get_buf(win) == buf then
--       api.nvim_win_close(win, false)
--       return
--     end
--   end
--
--   -- bo = { buftype = "", buflisted = false, bufhidden = "hide", swapfile = false },
--   -- Set buffer options
--   api.nvim_set_option_value("filetype", M.config.filetype, { buf = buf })
--   api.nvim_set_option_value("buftype", "", { buf = buf })
--   api.nvim_set_option_value("swapfile", false, { buf = buf })
--   api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
--   api.nvim_set_option_value("buflisted", false, { buf = buf })
--   -- Use the common window creation function
--   local win = M.create_scratch_window(buf)
--
--   -- Set up autowrite
--   if M.config.autowrite then
--     api.nvim_create_autocmd("BufHidden", {
--       buffer = buf,
--       callback = function()
--         vim.cmd("silent! write")
--       end,
--     })
--   end
--
--   return buf, win
-- end

-- Initialize
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  setup_highlights()
end

return M
