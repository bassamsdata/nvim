local M = {}

-- Store the original buffer content
local original_buffer_content = {}

-- Store which buffers are using CodeCompanion source
local codecompanion_buffers = {}

-- Store timers for reverting to Git source
local revert_timers = {}

local function is_valid_buffer(buf_id)
  return buf_id and vim.api.nvim_buf_is_valid(buf_id)
end

local function safe_get_lines(buf_id)
  if not is_valid_buffer(buf_id) then
    return {}
  end
  return vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
end

local function set_diff_source(buf_id, source)
  if is_valid_buffer(buf_id) then
    vim.b[buf_id].diffCompGit = source
  end
end

local codecompanion_source = { name = "codecompanion" }

codecompanion_source.attach = function(buf_id)
  if not is_valid_buffer(buf_id) then
    return false
  end

  original_buffer_content[buf_id] = safe_get_lines(buf_id)
  set_diff_source(buf_id, "llm")
  return true
end

codecompanion_source.detach = function(buf_id)
  original_buffer_content[buf_id] = nil
  set_diff_source(buf_id, "git")
end

local MiniDiff = require("mini.diff")
local git_source = MiniDiff.gen_source.git()

local function switch_to_codecompanion(buf_id)
  if not codecompanion_buffers[buf_id] then
    codecompanion_buffers[buf_id] = true
    MiniDiff.disable(buf_id)
    MiniDiff.enable(buf_id, { source = codecompanion_source })
    M.update_diff(buf_id)
    set_diff_source(buf_id, "llm")
  end
end

local function switch_to_git(buf_id)
  if codecompanion_buffers[buf_id] then
    codecompanion_buffers[buf_id] = nil
    MiniDiff.disable(buf_id)
    MiniDiff.enable(buf_id, { source = git_source })
    set_diff_source(buf_id, "git")
  end
end

local function schedule_revert_to_git(buf_id, delay)
  if revert_timers[buf_id] then
    revert_timers[buf_id]:stop()
  end
  revert_timers[buf_id] = vim.defer_fn(function()
    switch_to_git(buf_id)
    revert_timers[buf_id] = nil
  end, delay)
end

M.setup = function(config)
  config = config or {}
  local revert_delay = config.revert_delay or 5 * 60 * 1000 -- Default: 5 minutes
  -- MiniDiff.setup({ source = git_source })

  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionInline*",
    callback = function(args)
      local buf_id = args.buf
      if not is_valid_buffer(buf_id) then
        return
      end

      if args.match == "CodeCompanionInlineStarted" then
        switch_to_codecompanion(buf_id)
      elseif args.match == "CodeCompanionInlineFinished" then
        local current_content = safe_get_lines(buf_id)
        pcall(
          MiniDiff.set_ref_text,
          buf_id,
          original_buffer_content[buf_id] or {}
        )
        original_buffer_content[buf_id] = current_content
        schedule_revert_to_git(buf_id, revert_delay)
      end
    end,
  })

  -- TODO: Change this to wehn the mini.diff plugin is loaded
  -- Set initial diff source for all buffers
  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
      local buf_id = args.buf
      if is_valid_buffer(buf_id) and vim.b[buf_id].diffCompGit == nil then
        set_diff_source(buf_id, "git")
      end
    end,
  })
end

M.update_diff = function(buf_id)
  if not is_valid_buffer(buf_id) then
    return
  end

  local current_content = safe_get_lines(buf_id)
  pcall(MiniDiff.set_ref_text, buf_id, original_buffer_content[buf_id] or {})
  original_buffer_content[buf_id] = current_content
end

M.force_git = function(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  switch_to_git(buf_id)
end

M.force_codecompanion = function(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  if not is_valid_buffer(buf_id) then
    print("Invalid buffer ID")
    return
  end

  -- Ensure we have original content to diff against
  if not original_buffer_content[buf_id] then
    original_buffer_content[buf_id] = safe_get_lines(buf_id)
  end

  switch_to_codecompanion(buf_id)
  -- Force an update of the diff
  M.update_diff(buf_id)
end

-- TEST: Simulate an LLM modification by adding a comment to the first line
M.simulate_llm_modification = function(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  if not is_valid_buffer(buf_id) then
    print("Invalid buffer ID")
    return
  end

  local lines = safe_get_lines(buf_id)
  if #lines > 0 then
    -- Simulate an LLM modification by adding a comment to the first line
    lines[1] = lines[1] .. " -- LLM modified"
    vim.api.nvim_buf_set_lines(buf_id, 0, 1, false, { lines[1] })
    M.update_diff(buf_id)
    print("Simulated LLM modification and updated diff")
  else
    print("Buffer is empty, cannot simulate modification")
  end
end

M.get_current_source = function(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  return vim.b[buf_id].diffCompGit or "git"
end

return M
