-- Get Git branch Name ---------------------------------------------
local M = {}
-- Utility function to perform checks --------------------------------
---@param buf_id number
---@return boolean
local function is_valid_git_repo(buf_id)
  local path = vim.api.nvim_buf_get_name(buf_id)
  if path == "" or not vim.fn.filereadable(path) then
    return false
  end
  return vim.fs.root(path, ".git") ~= 0
end

local branch_cache = {}

-- Function to clear the Git branch cache -----------------------------
---@return nil
M.clear_git_branch_cache = function()
  -- Clear by doing an empty table :)
  branch_cache = {}
end

---@param data table
---@param cwd string
M.update_git_branch = function(data, cwd)
  if not is_valid_git_repo(data.buf) then
    return
  end

  -- Check if branch is already cached
  ---@type string
  local cached_branch = branch_cache[data.buf]
  if cached_branch then
    vim.b.git_branch = cached_branch
    return
  end

  ---@param content table
  ---@see vim.system
  local function on_exit(content)
    if content.code == 0 then
      local new_branch = content.stdout:gsub("\n", "")
      if new_branch ~= branch_cache[data.buf] then
        vim.b.git_branch = new_branch
        branch_cache[data.buf] = new_branch
      end
    end
  end
  vim.system(
    { "git", "-C", vim.fs.root(0, ".git"), "branch", "--show-current" },
    { text = true, cwd = cwd },
    on_exit
  )
end

---@return string?
M.copy_hunk_ref_text = function()
  local _, MiniDiff = pcall(require, "mini.diff")
  local buf_data = MiniDiff.get_buf_data()
  if buf_data == nil then
    return
  end

  -- Get hunk under cursor
  local cur_line, cur_hunk = vim.fn.line("."), nil
  for _, h in ipairs(buf_data.hunks) do
    local count = math.max(h.buf_count, 1)
    if h.buf_start <= cur_line and cur_line <= h.buf_start + count then
      cur_hunk = h
    end
  end
  if cur_hunk == nil then
    return
  end

  -- Get hunk's reference lines
  local ref_lines = vim.split(buf_data.ref_text, "\n")
  local from, to =
    cur_hunk.ref_start, cur_hunk.ref_start + cur_hunk.ref_count - 1
  local hunk_ref_lines = vim.list_slice(ref_lines, from, to)

  -- Populate register '"' (to be usable with plain `p`) with target lines
  vim.fn.setreg('"', hunk_ref_lines, "l")
end

return M
------------------------------------------------------------------------
