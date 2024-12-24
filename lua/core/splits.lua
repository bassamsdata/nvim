local vsplit_list = vim.api.nvim_tabpage_list_wins(0)

vsplit_list = vim.tbl_filter(function(win)
  return vim.list_contains(
    { "left", "right" },
    vim.api.nvim_win_get_config(win).split
  )
end, vsplit_list)

table.sort(vsplit_list, function(win1, win2)
  return vim.api.nvim_win_get_position(win1)[2]
    < vim.api.nvim_win_get_position(win2)[2]
end)

-- go to the first split
vim.api.nvim_set_current_win(vsplit_list[1])
-- go to the last split
local last = #vsplit_list
-- vim.api.nvim_set_current_win(vsplit_list[last])

vim.print(vsplit_list)

vim.print(vim.api.nvim_win_get_config(1355))
