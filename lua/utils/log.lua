local M = {}

-- Configuration
M.config = {
  log_file = vim.fn.stdpath("cache") .. "/nvim_custom.log",
  log_level = vim.log.levels.INFO,
  output_methods = { "print", "notify", "file" },
}

local function write_to_file(message)
  local file = io.open(M.config.log_file, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. message .. "")
    file:close()
  end
end

function M.log(message, level, methods)
  level = level or M.config.log_level
  methods = methods or M.config.output_methods

  local formatted_message =
    string.format("[%s] %s", vim.log.levels[level], message)

  for _, method in ipairs(methods) do
    if method == "print" then
      print(formatted_message)
    elseif method == "notify" then
      vim.notify(message, level)
    elseif method == "file" then
      write_to_file(formatted_message)
    end
  end
end

-- Convenience functions for different log levels
function M.debug(message, methods)
  M.log(message, vim.log.levels.DEBUG, methods)
end

function M.info(message, methods)
  M.log(message, vim.log.levels.INFO, methods)
end

function M.warn(message, methods)
  M.log(message, vim.log.levels.WARN, methods)
end

function M.error(message, methods)
  M.log(message, vim.log.levels.ERROR, methods)
end

return M
