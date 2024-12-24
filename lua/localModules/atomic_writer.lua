local M = {}

---Atomically writes data to a file
---@param filepath string The target file path
---@param data string|table The data to write (string or table to be JSON encoded)
---@param opts? table Optional settings {json = boolean, debug = boolean}
---@return boolean success
---@return string? error_message
function M.atomic_write(filepath, data, opts)
  opts = opts or {}
  local temp_file = filepath .. ".tmp"

  -- Convert table to JSON if needed
  local content = data
  if type(data) == "table" and opts.json then
    local ok, encoded = pcall(vim.json.encode, data)
    if not ok then
      return false, "Failed to encode JSON: " .. encoded
    end
    content = encoded
  end

  -- Open temporary file
  local temp_handle = io.open(temp_file, "w")
  if not temp_handle then
    return false, "Failed to open temporary file: " .. temp_file
  end

  -- Write to temporary file
  local write_ok, write_err = temp_handle:write(content)
  temp_handle:flush() -- Ensure all data is written
  temp_handle:close()

  if not write_ok then
    os.remove(temp_file)
    return false, "Failed to write temporary file: " .. tostring(write_err)
  end

  -- Atomically rename temporary file to target file
  local rename_ok, rename_err = os.rename(temp_file, filepath)
  if not rename_ok then
    os.remove(temp_file)
    return false, "Failed to rename temporary file: " .. tostring(rename_err)
  end

  if opts.debug then
    vim.notify("Successfully wrote to " .. filepath, vim.log.levels.DEBUG)
  end

  return true
end

---Reads file content with optional JSON parsing
---@param filepath string The file path to read
---@param opts? table Optional settings {json = boolean, debug = boolean}
---@return any|nil data
---@return string? error_message
function M.read_file(filepath, opts)
  opts = opts or {}

  local file = io.open(filepath, "r")
  if not file then
    return nil, "Failed to open file: " .. filepath
  end

  local content = file:read("*all")
  file:close()

  if opts.json and content and content ~= "" then
    local ok, decoded = pcall(vim.json.decode, content)
    if not ok then
      return nil, "Failed to decode JSON: " .. decoded
    end
    return decoded
  end

  return content
end

return M
