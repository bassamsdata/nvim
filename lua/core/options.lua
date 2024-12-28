local opt = vim.opt
if vim.fn.has("nvim-0.10.3") then -- it has an issue with :Inspect command
vim.hl = vim.highlight
end
-- stylua: ignore start 
vim.g.mapleader      = " " -- set leader key to space
vim.g.maplocalleader = "\\" -- we need to escabe \ with another \
-- Appearance
if vim.fn.has("nvim-0.11") == 1 then
    opt.messagesopt = "wait:1000,history:500"
end

opt.termguicolors    = true
opt.background       = "dark"
opt.signcolumn       = "yes"
opt.relativenumber   = true
opt.number           = true
opt.mouse            = "a" -- Enable mouse mode.
-- tabs & indentation
opt.expandtab        = true
opt.tabstop          = 2
opt.shiftwidth       = 2
opt.smarttab         = true
opt.statuscolumn     = [[%!v:lua.require'core.statuscolumn'.statuscolumn()]]
opt.shiftround       = true -- Round indent
vim.opt.listchars:append({
  trail              = "·",
})

-- Save undo history.
opt.undofile         = true
opt.undolevels       = 10000
-- Cursor settings
opt.cursorline       = true
opt.guicursor        = {
  "n-v:block-Cursor/lCursor",
  "i-c-ci-ve:blinkoff500-blinkon1000-block-TermCursor",
}
-- view and session options
opt.viewoptions      = "cursor,folds"
opt.sessionoptions   = "buffers,curdir,folds,help,tabpages,winsize"
opt.clipboard:append("unnamedplus") -- clipoboard
opt.showbreak        = "↪ "

-- UI characters.
opt.fillchars:append({
  diff               = "╱",
  eob                = " ",
})

opt.laststatus       = 3
opt.pumheight        = 10 -- Maximum number of entries in a popup
--spli windows
opt.splitright       = true
opt.splitbelow       = true
-- search settings
opt.ignorecase       = true
opt.smartcase        = true

if vim.env.VSCODE then
  vim.g.vscode       = true
end
if not vim.g.neovide then
  -- it has a bug with
  opt.inccommand     = "split" -- split window for substitute - nice to have
end

opt.confirm          = true -- Confirm to save changes
opt.wrap             = false --line wrapping
-- yank to Capital case register with reserving lines
opt.cpoptions:append(">")
vim.opt.wildignore:append({ ".DS_Store" }) -- completion
-- opt.conceallevel  = 2 -- Hide * markup for bold and italic
opt.foldcolumn       = "0"
opt.foldenable       = false
opt.foldlevel        = 999
-- opt.foldmethod       = "indent"
-- opt.foldtext      = "v:lua.require'utils'.foldtext()"
opt.smoothscroll     = true
-- opt.foldtext         = 'v:lua.require("utils").foldtext()'
opt.formatoptions    = "jcqlnt" -- tcqj
-- this drove me crzy - it controll how vertical movement behave when tab is used
-- stylua: ignore end
if not vim.g.vscode then
  opt.scrolloff = 4
  opt.showmode = false
end
vim.g.no_plugin_maps = 1 -- this one for python dwfault craze keymaps from ftplugin/python.vim

-- Disable health checks for these providers.
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

if vim.g.neovide then
  -- stylua: ignore start 
  -- vim.o.guifont                               = "Iosevka Comfy:h15:w1"
  vim.g.neovide_transparency                     = 1
  -- vim.g.neovide_window_blurred                = true
  vim.g.neovide_input_macos_option_key_is_meta   = "both"
  vim.g.neovide_cursor_animation_length          = 0.1
  -- vim.g.neovide_scroll_animation_far_lines = 5
  vim.g.neovide_cursor_trail_size                = 0.3
  -- vim.g.neovide_scroll_animation_length       = 0.3 -- 0.3 is default
  vim.g.neovide_cursor_antialiasing              = false
  -- vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.opt.linespace                              = 22
  vim.g.neovide_hide_mouse_when_typing           = true
  vim.g.neovide_floating_shadow                  = true
  vim.g.neovide_floating_z_height                = 10
  vim.g.neovide_light_angle_degrees              = 45
  vim.g.neovide_light_radius                     = 5
  vim.g.neovide_floating_blur_amount_x           = 0
  vim.g.neovide_floating_blur_amount_y           = 0
  vim.g.neovide_floating_z_height                = 0
  vim.g.neovide_light_angle_degrees              = 0
  vim.g.neovide_light_radius                     = 0
  vim.g.neovide_padding_right                    = 0
  vim.g.neovide_padding_left                     = 0
  vim.g.neovide_padding_top                      = 0
  vim.g.neovide_padding_bottom                   = 0
  vim.g.neovide_padding_right                    = 0
  vim.g.neovide_padding_left                     = 0
  -- stylua: ignore end
end

-- Thanks to Bekaboo for this https://github.com/Bekaboo/nvim
---Lazy-load runtime files
local g = vim.g
---@param runtime string
---@param flag string
---@param event string|string[]
local function _load(runtime, flag, event)
  if not g[flag] then
    g[flag] = 0
    vim.api.nvim_create_autocmd(event, {
      once = true,
      callback = function()
        g[flag] = nil
        vim.cmd.runtime(runtime)
        return true
      end,
    })
  end
end

-- stylua: ignore start 
_load("plugin/rplugin.vim",    "loaded_remote_plugins",   "FileType")
_load("provider/python3.vim",  "loaded_python3_provider", "FileType")
_load("plugin/matchit.vim",    "loaded_matchit",          "FileType")
_load("plugin/matchparen.vim", "loaded_matchparen",       "FileType")
_load("plugin/tohtml.lua",     "loaded_tohtml",           "FileType")
_load("plugin/tutor.lua",      "loaded_tutor_mode",       "FileType")
-- _load("plugin/man.lua",        "loaded_man",              "FileType")
_load("plugin/spellfile.vim",  "loaded_spellfile",        "FileType")
-- stylua: ignore end
