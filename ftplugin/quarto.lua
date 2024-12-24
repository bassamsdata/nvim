vim.b.slime_cell_delimiter = "```"

-- wrap text, but by word no character
-- indent the wrappped line

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

-- vim.wo.wrap = true
-- vim.wo.linebreak = true
-- vim.wo.breakindent = true
-- vim.wo.showbreak = "|"
vim.opt_local.colorcolumn = "200"
-- vim.wo.conceallevel = 0
vim.g.molten_virt_lines_off_by_1 = true
