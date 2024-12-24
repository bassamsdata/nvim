local map = vim.keymap.set

map("!a", "sis", "-- stylua: ignore start") -- Check :h nvim_set_keymap
map("!a", "sie", "-- stylua: ignore end")
map("!a", "sia", "-- stylua: ignore all")
vim.cmd([[cab ll Lazy]])
vim.cmd([[cab cc CodeCompanion]])
vim.cmd([[cab ch CodeCompanionChat]])

local static_abbrevs = {
  ["br,"] = "Best regards,",
  ["ty,"] = "Thank you for your time,",
  ["fn,"] = "function",
  ["ret,"] = "return",
  ["con,"] = "const",
  ["code,"] = "Code output only, please.", -- with special chars
  ["unders,"] = "Do you understand?",
}

local dynamic_abbrevs = {
  ["dts,"] = function()
    return os.date("%Y-%m-%d")
  end,
  ["tdy,"] = function()
    return os.date("%A")
  end,
}
-- Set dynamic abbreviations with expr=true
for lhs, rhs in pairs(dynamic_abbrevs) do
  vim.keymap.set("ia", lhs, rhs, { expr = true })
end
-- Set static abbreviations
for lhs, rhs in pairs(static_abbrevs) do
  vim.keymap.set("ia", lhs, rhs)
end
