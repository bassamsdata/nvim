-- Name:         default
-- Description:  Improves default colorscheme
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Wed 03 Jan 2024 01:53:29 AM CST

vim.cmd.hi("clear")
vim.g.colors_name = "default"
local hl = vim.api.nvim_set_hl

if vim.go.background == "dark" then
  -- stylua: ignore start 
  hl(0, "Comment",     { fg = "NvimDarkGrey4", ctermfg = 8 })
  hl(0, "StatusLine",  { bg = "NvimDarkGrey2", fg = "NvimLightGrey4", ctermbg = 7, ctermfg = 0 })
  hl(0, "LineNr",      { fg = "NvimDarkGrey4", ctermfg = 8 })
  hl(0, "NonText",     { fg = "NvimDarkGrey4", ctermfg = 8 })
  hl(0, "SpellBad",    { underdashed = true,   cterm = {} })
  hl(0, "NormalFloat", { bg = "NvimDarkGrey1", ctermbg = 7,           ctermfg = 0 })
  -- stylua: ignore end
end

-- stylua: ignore start
hl(0, 'GitSignsAdd',           { fg = 'NvimLightGreen', ctermfg = 10 })
hl(0, 'GitSignsChange',        { fg = 'NvimLightBlue',  ctermfg = 12 })
hl(0, 'GitSignsDelete',        { fg = 'NvimDarkRed',    ctermfg = 9 })
hl(0, 'GitSignsDeletePreview', { bg = 'NvimDarkRed',    ctermbg = 9 })
-- stylua: ignore end

-- vim:ts=2:sw=2:sts=2:fdm=marker:fdl=0
