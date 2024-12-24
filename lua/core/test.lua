local M = {}
local num = vim.v.lnum
local winid = vim.g.statusline_winid

print("hello world " .. num)
print("winid " .. tostring(winid))
return M
