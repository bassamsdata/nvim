-- thanks to Bekaboo for this https://github.com/Bekaboo/nvim

-- If is quickfix list, always open it at the bottom of screen
if vim.fn.win_gettype() == "quickfix" then
  vim.cmd.wincmd("J")
end

vim.bo.buflisted = false
vim.opt_local.spell = false
vim.opt_local.rnu = false
vim.opt_local.signcolumn = "no"
vim.opt_local.statuscolumn = ""

-- stylua: ignore start
vim.keymap.set('n', '<Tab>', '<CR>zz<C-w>p',  { buffer = true })
vim.keymap.set('n', '<C-n>', 'j<CR>zz<C-w>p', { buffer = true })
vim.keymap.set('n', '<C-p>', 'k<CR>zz<C-w>p', { buffer = true })
-- stylua: ignore end

-- Provides `:Cfilter` and `:Lfilter` commands
vim.cmd.packadd({
  args = { "cfilter" },
  mods = { emsg_silent = true },
})

vim.keymap.set("n", ">", function()
  require("quicker").expand({
    before = 2,
    after = 2,
    add_to_existing = true,
  })
end, { desc = "Expand quickfix context" })

vim.keymap.set("n", "<", function()
  require("quicker").collapse()
end, { desc = "Collapse quickfix context" })
