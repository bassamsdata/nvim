-- vim.opt_local.suffixesadd:prepend(".lua")
-- vim.opt_local.suffixesadd:prepend("init.lua")
-- if vim.uv.cwd() == vim.fn.stdpath("config") then
--   vim.opt_local.path:prepend(vim.fn.stdpath("config") .. "/lua")
-- end
-- Define the ReloadModule user command

-- TODO: delete initif the modeule name is init.lua
local module_naming = function()
  local current_file = vim.fn.expand("%:p")
  local module_name = vim.fn.fnamemodify(current_file, ":.:r:s?lua/??:gs?/?.?")
  if string.find(module_name, ".init") then
    module_name = string.gsub(module_name, ".init", "")
  end
  return module_name
end

local function reload_current_file()
  local module_name = module_naming()
  package.loaded[module_name] = nil
  return require(module_name)
end

vim.api.nvim_create_user_command("ReloadModule", function()
  reload_current_file()
  vim.notify("Module '" .. module_naming() .. "' reloaded", nil, {
    timeout = 500,
  })
end, {
  force = true,
  desc = "Reload the current module",
})

-- Create an autocommand group to ensure no duplication
local group_id = vim.api.nvim_create_augroup("LuaReloadModule", { clear = true })

-- Register the autocommand for *.lua files starting with local M = {}
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group_id,
  pattern = "*.lua",
  callback = function()
    if vim.uv.cwd() ~= vim.fn.stdpath("config") then
      return
    end
    -- Read the first line of the file
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line and first_line:match("^local%s+M%s*=%s*{}") then
      reload_current_file()
      vim.notify("Module '" .. module_naming() .. "' reloaded", nil, {
        timeout = 500,
      })
    end
  end,
  desc = "Reload the current module on save for Lua files starting with local M = {}",
})
