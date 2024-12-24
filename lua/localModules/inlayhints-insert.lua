-- Thanks to Davidyz for this module, I just modified it a bit to work my lsp
-- servers but the main bones are from his plugin:
-- "https://github.com/Davidyz/inlayhint-filler.nvim",
M = {}

---@class InlayHintFillerOpts
---@field bufnr integer
---@field client_id integer|nil

---@type InlayHintFillerOpts
local DEFAULT_OPTS = { bufnr = 0, client_id = nil }

---@param label string|table[]
---@return string
local function extract_hint_text(label)
  if type(label) == "string" then
    return label
  elseif type(label) == "table" then
    if #label > 1 then
      vim.notify(
        "More than one labels are collected. Defaulting to the first one.",
        vim.log.levels.WARN,
        { title = "InlayHint-Filler" }
      )
    end
    return label[1].value
  end
  return ""
end

---@param hint_item lsp.InlayHint
---@param original_line string
---@return string
local function make_new_line(hint_item, original_line)
  -- Always use label instead of textEdits.newText
  local hint_text = extract_hint_text(hint_item.label)
  local hint_col = hint_item.position.character

  -- Only add padding for parameter hints (kind=2) if paddingRight is true
  if hint_item.kind == 2 and hint_item.paddingRight then
    hint_text = hint_text .. " "
  end

  return original_line:sub(1, hint_col) .. hint_text .. original_line:sub(hint_col + 1)
end

---@param hint_item table
---@param opts InlayHintFillerOpts
---@param row integer
---@param col integer
local function insert_hint_item(hint_item, opts, row, col)
  -- Get the actual inlay hint object
  local inlay_hint = hint_item.inlay_hint

  if opts.client_id == nil or opts.client_id == hint_item.client_id then
    local hint_col = inlay_hint.position.character
    local hint_row = inlay_hint.position.line
    if hint_row == row and math.abs(hint_col - col) <= 1 then
      vim.api.nvim_set_current_line(
        make_new_line(inlay_hint, vim.api.nvim_get_current_line())
      )
    end
  end
end

---@param opts InlayHintFillerOpts
M.fill = function(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, DEFAULT_OPTS)
  local hints = vim.lsp.inlay_hint.get({ bufnr = opts.bufnr })
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  if hints ~= nil and #hints >= 1 then
    for _, hint_item in pairs(hints) do
      insert_hint_item(hint_item, opts, row, col)
    end
  end
end

return M
