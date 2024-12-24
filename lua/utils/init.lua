---@diagnostic disable: deprecated
local M = {}

local swap_pairs = {
  { "true", "false" },
  { "foo", "bar" },
  { "TRUE", "FALSE" },
  { "True", "False" },
  { "fg", "bg" },
  { "open", "close" },
  { "always", "never" },
  { "disable", "enable" },
}

function M.swapBooleanInLine()
  local line = vim.api.nvim_get_current_line()
  for _, pair in ipairs(swap_pairs) do
    local a, b = unpack(pair)
    line = line:find(a) and line:gsub(a, b) or line:find(b) and line:gsub(b, a) or line
  end
  vim.api.nvim_set_current_line(line)
end

--- A simple and clean fold function, thanks https://github.com/tamton-aquib/essentials.nvim
---@return string: foldtext
M.simple_fold = function()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local start_line = vim.fn.getline(fs):gsub("\t", ("\t"):rep(vim.opt.ts:get()))
  local end_line = vim.trim(vim.fn.getline(fe))
  local spaces = (" "):rep(vim.o.columns - start_line:len() - end_line:len() - 7)

  return start_line .. "  " .. end_line .. spaces
end
-- set this: vim.opt.foldtext = 'v:lua.require("essentials").simple_fold()'

M.file_path = vim.fn.stdpath("config") .. "/plugin/colorswitch.lua"

---@param old string
---@param new string
---@return nil
function M.replace_word(old, new)
  local file, err = io.open(M.file_path, "r")
  if not file then
    vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
    return
  end
  local content = file:read("*all")
  file:close()
  -- Escape dashes in both old and new strings
  local escaped_old = string.gsub(old, "([%-])", "%%%1")
  local escaped_new = string.gsub(new, "([%-])", "%%%1")
  -- local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
  local new_content = content:gsub(escaped_old, escaped_new)
  file, err = io.open(M.file_path, "w")
  if not file then
    vim.notify("Failed to open file for writing: " .. err, vim.log.levels.ERROR)
    return
  end
  file:write(new_content)
  file:close()
end

-- idea thanks to MariaSolOs:
-- https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/commands.lua#L36
-- Function to open GitHub links in lua and go
function M.gxhandler()
  local file = vim.fn.expand("<cfile>")
  local ft = vim.bo.filetype
  if ft == "lua" then
    local link = file:match("%w[%w%-]+/[%w%-%._]+")
    if link then
      vim.fn.system("open https://www.github.com/" .. link)
    end
  elseif ft == "go" then
    vim.fn.system("open https://www." .. file)
  else
    vim.notify("Unsupported filetype for gxhandler")
  end
end

-- Function to open dotfyle links for lua plugins
function M.gxdotfyle()
  local file = vim.fn.expand("<cfile>")
  -- Consider anything that looks like string/string a GitHub link.
  local link = file:match("%w[%w%-]+/[%w%-%._]+")
  if link then
    vim.fn.system("open https://www.dotfyle.com/plugins/" .. link)
  else
    vim.notify("Failed to open link: " .. file, vim.log.levels.ERROR)
  end
end

function M.diff_with_clipboard()
  local ftype = vim.api.nvim_get_option_value("filetype", {})
  local cmd = string.format(
    [[
    normal! "xy
    vsplit
    enew
    normal! P
    setlocal buftype=nowrite
    set filetype=%s
    diffthis
    normal! \<C-w>\<C-w>
    enew
    set filetype=%s
    normal! "xP
    diffthis
  ]],
    ftype,
    ftype
  )
  vim.api.nvim_exec2(cmd, {})
end

function M.diff_with_clipboard2()
  local selected_text = vim.fn.getreg('"')
  local _, diff = pcall(require, "mini.diff")
  diff.set_ref_text(0, selected_text)
  diff.toggle_overlay(0)
end

function M.messages_to_quickfix()
  -- Execute :messages command and capture output
  local messages = vim.fn.execute("messages")
  -- Split the output into lines
  local lines = vim.split(messages, "\n")
  -- Create a table of dictionaries for the quickfix list
  local qf_items = {}
  for _, line in ipairs(lines) do
    -- Trim leading and trailing whitespace
    local trimmed_line = line:gsub("^%s*(.-)%s*$", "%1")
    -- Skip if the line is empty
    if trimmed_line ~= "" then
      table.insert(qf_items, { text = trimmed_line })
    end
  end
  -- Set the quickfix list
  vim.fn.setqflist(qf_items, "r")
  vim.cmd.copen()
  vim.cmd("$")
end

---Read file contents
---@param path string
---@return string?
function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content or ""
end

M.last_search = nil
function M.grepandopen()
  vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
    if pattern then
      vim.cmd("silent grep! " .. pattern)
      -- Store pattern in quickfix context
      -- local qf = vim.fn.getqflist()
      -- Set the context for the existing list
      -- vim.fn.setqflist(qf, "r", {
      --   items = qf, -- Keep existing items
      --   context = pattern,
      -- })
      vim.cmd("copen")
      M.last_search = pattern
      -- vim.fn.matchadd("Search", pattern)
      -- local context = vim.fn.getqflist({ context = 0 }).context
      -- print("Context set:", vim.inspect(context))
      -- print("Context set:", M.last_search)
    end
  end)
end

---@return nil
function M.helpgrepnopen()
  vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
    if pattern ~= nil then
      vim.cmd("silent helpgrep " .. pattern)
      vim.cmd("copen")
      vim.fn.matchadd("Search", pattern)
    end
  end)
end

--- Merge one or more tables into the first table.
---@generic T
---@param base T
---@vararg T
---@return T
function M.mergeTables(base, ...)
  for _, additional in ipairs({ ... }) do
    for k, v in pairs(additional) do
      base[k] = v
    end
  end
  return base
end

-- Neovim Utils
--- returns current vim mode name
function M.get_mode_name()
  local mode_names = {
    n = "no",
    no = "n?",
    nov = "n?",
    noV = "n?",
    ["no\22"] = "n?",
    niI = "ni",
    niR = "nr",
    niV = "nv",
    nt = "nt",
    v = "vi",
    vs = "vs",
    V = "v_",
    Vs = "vs",
    ["\22"] = "^V",
    ["\22s"] = "^V",
    s = "se",
    S = "s_",
    ["\19"] = "^S",
    i = "in",
    ic = "ic",
    ix = "ix",
    R = "re",
    Rc = "rc",
    Rx = "rx",
    Rv = "rv",
    Rvc = "rv",
    Rvx = "rv",
    c = "co",
    cv = "ex",
    r = "..",
    rm = "m.",
    ["r?"] = "??",
    ["!"] = "!!",
    t = "te",
  }
  return mode_names[vim.api.nvim_get_mode().mode]
end

--- returns current vim mode highlight
--- @return string
function M.get_mode_hl()
  local mode_hls = {
    -- stylua: ignore start 
    n       = "NormalMode" and "NormalMode" or "CursorLineNr",
    i       = "InsertMode" and "InsertMode" or "TermCursor",
    v       = "VisualMode",
    V       = "VisualMode",
    ["\22"] = "VisualMode",
    c       = "CommandMode",
    s       = "SelectMode",
    S       = "SelectMode",
    ["\19"] = "SelectMode",
    R       = "ControlMode",
    r       = "ControlMode",
    ["!"]   = "NormalMode",
    t       = "TerminalMode",
    -- stylua: ignore end
  }

  return mode_hls[vim.api.nvim_get_mode().mode]
end

--- Closes all buffers except the current one and the alternate one
--- NEXT: make one that closes all abuffers that not in arrow list
---@return nil
function M.close_other_buffers()
  local current = vim.fn.bufnr("%")
  local alternate = vim.fn.bufnr("#")
  local buffers = vim.api.nvim_list_bufs()
  vim.notify("Closing other buffers", vim.log.levels.INFO)

  for _, buf in ipairs(buffers) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_is_valid(buf)
      and buf ~= current
      and buf ~= alternate
    then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

-- TODO: Open all arrow files as well
---@return nil
function M.keepOnlyArrowFiles()
  local cwd = vim.uv.cwd()
  local arrow_filenames = vim.g.arrow_filenames
  local arrow_fullpaths = {}
  if arrow_filenames == nil then
    return
  end

  -- Convert relative paths to full paths
  for _, filename in ipairs(arrow_filenames) do
    table.insert(arrow_fullpaths, cwd .. "/" .. filename)
  end

  -- Iterate over all open buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)

      -- Check if the buffer is not in the arrow_fullpaths list
      if not vim.tbl_contains(arrow_fullpaths, buf_name) and buf_name ~= "" then
        -- If not, close the buffer
        require("mini.bufremove").delete(buf)
      end
    end
  end
end

return M
