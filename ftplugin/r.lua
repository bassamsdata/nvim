local map = vim.keymap.set
-- stylua: ignore start 
map( "n", "<localleader>he", "<cmd>lua require('r.run').action('head')<cr>", { desc = "R head" })
map( "n", "<localleader>hb", "<cmd>lua require('r.run').action('tail')<cr>", { desc = "R tail" })
map( "n", "<localleader>hg", "<cmd>lua require('r.run').action('dplyr::glimpse')<cr>", { desc = "R glimpse" })
map( "n", "<localleader>ht", "<cmd>lua require('r.run').action('tibble::tibble')<cr>", { desc = "R tibble" })
map( "n", "<localleader>hc", "<cmd>lua require('r.run').action('class')<cr>", { desc = "R class" })
-- map( "n", "<leader>qk", "<cmd>call g:SendCmdToR('quarto::quarto_preview_stop()')<cr>", { desc = "RQuarto_Stop" })
-- map( "n", "<leader>tr", "<cmd>lua vim.g.R_external_term = 1<cr>", { desc = "R External Activate" })
-- map( "n", "<leader>te", '<cmd>lua vim.g.R_source = ".local/share/nvim/lazy/Nvim-R/R/tmux_split.vim"<cr>', { desc = "R External Activate" })
-- map( "n", "<leader>tt", '<cmd>lua require("config.options").toggle_r_options()<cr>', { desc = "R External Activate" })
-- map( "n", "<leader>ts", '<cmd>lua require("config.options").toggle_shiftwidth()<cr>', { desc = "Change Shiftwidth" })
-- stylua: ignore end

map("n", "<localleader>>", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd("norm A |> ")
  vim.api.nvim_win_set_cursor(0, cursor)
end, { noremap = true, silent = true })
vim.g.molten_virt_lines_off_by_0 = false
