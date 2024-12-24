local MiniDiff = require("mini.diff")

local codecompanion_source = { name = "codecompanion" }

local original_buffer_content = {}

local function is_valid_buffer(buf_id)
  return buf_id and vim.api.nvim_buf_is_valid(buf_id)
end

local function safe_get_lines(buf_id)
  if not is_valid_buffer(buf_id) then
    return {}
  end
  return vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
end

codecompanion_source.attach = function(buf_id)
  if not is_valid_buffer(buf_id) then
    return false
  end

  -- Store the original buffer content when attaching
  original_buffer_content[buf_id] = safe_get_lines(buf_id)

  -- Set up autocmd to track CodeCompanion events
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionInline*",
    callback = function(args)
      if args.match == "CodeCompanionInlineFinished" then
        local event_buf_id = args.buf

        if not is_valid_buffer(event_buf_id) then
          return
        end

        -- Get the current buffer content
        local current_content = safe_get_lines(event_buf_id)

        -- Set the reference text to the original content
        pcall(
          MiniDiff.set_ref_text,
          event_buf_id,
          original_buffer_content[event_buf_id] or {}
        )

        -- Update the original content for future diffs
        original_buffer_content[event_buf_id] = current_content
      end
    end,
  })

  return true
end

codecompanion_source.detach = function(buf_id)
  -- Clean up stored buffer content
  original_buffer_content[buf_id] = nil
end

-- Function to manually trigger diff update
local function update_codecompanion_diff(buf_id)
  if not is_valid_buffer(buf_id) then
    return
  end

  local current_content = safe_get_lines(buf_id)
  pcall(MiniDiff.set_ref_text, buf_id, original_buffer_content[buf_id] or {})
  original_buffer_content[buf_id] = current_content
end

return {
  setup = function()
    require("mini.diff").setup({
      source = codecompanion_source,
    })
  end,
  update_diff = update_codecompanion_diff,
}
