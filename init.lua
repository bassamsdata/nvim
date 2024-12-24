require("core.options")
require("core.autocommands")
require("core.lazy")
require("core.intro")
require("core.keymaps")
require("core.abbre")
require("core.mystatusline")
require("core.commands")
require("localModules._load")

if vim.g.vscode ~= nil then
  require("core.vscode")
end
