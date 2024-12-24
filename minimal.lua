-- 󰈙 file1.lua

local ns_id = vim.api.nvim_create_namespace("selecta_highlights")
local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
print("line: " .. line .. " " .. #line)
local extmark_id = vim.api.nvim_buf_set_extmark(0, ns_id, 0, 5, {
  end_col = #line,
  hl_group = "Tag",
  priority = 200,
  hl_mode = "combine",
})

-- NOTE: this is greate for highlighting similar to magnet
local start_line = 27 -- zero-indexed
local end_line = 33 -- inclusive, so this highlights up to and including line 30
local hl_group = "Visual" -- Replace with the desired highlight group

-- Define the highlight group (if it doesn't exist)

for line = start_line, end_line do
  vim.api.nvim_buf_set_extmark(0, ns_id, line, 0, {
    end_line = line,
    end_col = 0,
    line_hl_group = hl_group,
  })
end
vim.api.nvim_buf_set_extmark(0, ns_id, start_line, 0, {
  end_line = end_line,
  end_col = 0,
  hl_eol = true,
  hl_group = hl_group,
  -- line_hl_group = hl_group,
})

local timer = vim.uv.new_timer()
timer:start(
  5000, -- wait time in milliseconds
  0, -- interval time in milliseconds; 0 means it won't repeat
  vim.schedule_wrap(function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    print("Highlight removed")
    timer:stop() -- stop the timer
    timer:close() -- close the timer
  end)
)
