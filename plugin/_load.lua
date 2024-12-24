-- readline
local nvim_config_path = vim.fn.stdpath("config")
package.path = package.path
  .. ";"
  .. nvim_config_path
  .. "/?.lua;"
  .. nvim_config_path
  .. "/?/init.lua"

vim.api.nvim_create_autocmd({ "CmdlineEnter", "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("ReadlineSetup", {}),
  once = true,
  callback = function()
    require("plugin.readline").setup()
    return true
  end,
})
