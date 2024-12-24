local u = require("utils")
local git = require("utils.git")
local autocmd = vim.api.nvim_create_autocmd

-- Create automatic naming for groups
local function augroup(name)
  return vim.api.nvim_create_augroup("sila_" .. name, { clear = true })
end

-- local excluded_ft = { "lazy", "netrw", "man", "intro", "help" }
-- if not vim.tbl_contains(excluded_ft, vim.bo.ft) then
-- autocmd("FileType", {
--   pattern = "lua",
--   group = augroup("help"),
--   callback = function()
--     local separator = vim.g.neovide and " │ " or " ┃ "
-- -- stylua: ignore start
--   vim.opt.statuscolumn =
--       '%s%=%#LineNr4#%{(v:relnum >= 4)?v:relnum.\"' .. separator .. '\":\"\"}' ..
--       '%#LineNr3#%{    (v:relnum == 3)?v:relnum.\"' .. separator .. '\":\"\"}' ..
--       '%#LineNr2#%{    (v:relnum == 2)?v:relnum.\"' .. separator .. '\":\"\"}' ..
--       '%#LineNr1#%{    (v:relnum == 1)?v:relnum.\"' .. separator .. '\":\"\"}' ..
--       '%#LineNr0#%{    (v:relnum == 0)?v:lnum.\"  ' .. separator .. '\":\"\"}'
--     -- stylua: ignore end
--   end,
-- })

-- Thanks to this post https://www.reddit.com/r/neovim/comments/15c7rk3/quickfix_editing_tips_worth_resharing/
autocmd("BufWinEnter", {
  group = augroup("quickfix"),
  desc = "allow updating quickfix window",
  pattern = "quickfix",
  callback = function(ctx)
    vim.bo.modifiable = true
    -- :vimgrep's quickfix window display format now includes start and end column (in vim and nvim) so adding 2nd format to match that
    vim.bo.errorformat = "%f|%l col %c| %m,%f|%l col %c-%k| %m"
    vim.keymap.set(
      "n",
      "<C-s>",
      '<Cmd>cgetbuffer|set nomodified|echo "quickfix/location list updated"<CR>',
      {
        buffer = true,
        desc = "Update quickfix/location list with changes made in quickfix window",
      }
    )
  end,
})

-- The next 2 autocommands are for setting the background color of the terminal to match neovim
-- source: https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
autocmd({ "UIEnter", "ColorScheme" }, {
  callback = function()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    if not normal.bg then
      return
    end
    io.write(string.format("\027]11;#%06x\027\\", normal.bg))
  end,
})
autocmd("UILeave", {
  callback = function()
    io.write("\027]111\027\\")
  end,
})

-- Thanks to bekaboo for the initial autocmd
autocmd({ "BufLeave", "WinLeave", "FocusLost" }, {
  group = augroup("autosave"),
  nested = true,
  desc = "Autosave on focus change.",
  callback = function(info)
    -- python black formatting is slow and will affect moving around
    local excluded_ft = { "qf", "python", "", "quarto" }
    if vim.tbl_contains(excluded_ft, vim.bo[info.buf].ft) then
      return
    end
    local diagnostics = vim.diagnostic.count(info.buf)
    -- Check if there are no errors or warnings
    if diagnostics[2] == nil and diagnostics[3] == nil then
      vim.cmd.update({
        mods = { emsg_silent = true },
      })
    end
  end,
})

-- function to save file based on update instead of w if the cmdline == w
-- local function saveFile()
--   if vim.fn.getcmdtype() == "w" then
--     vim.cmd.update({
--       mods = { emsg_silent = true },
--     })
--   else
--     vim.cmd.w()
--   end
-- end
--
-- vim.keymap.set("c", "w", saveFile)

vim.api.nvim_create_user_command("W", function()
  vim.cmd.update({
    mods = { emsg_silent = true },
  })
end, {})

autocmd("BufReadPre", {
  group = augroup("largefilesettings"),
  desc = "Set settings for large files.",
  callback = function(info)
    vim.b.bigfile = false
    ---@diagnostic disable-next-line: undefined-field
    local stat = vim.uv.fs_stat(info.match)
    if stat and stat.size > 524200 then
      vim.b.bigfile = true
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.breakindent = false
      vim.opt_local.colorcolumn = ""
      vim.opt_local.statuscolumn = ""
      vim.opt_local.signcolumn = "no"
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.winbar = ""
      vim.opt_local.syntax = ""
      vim.cmd.syntax("off")
      autocmd("BufReadPost", {
        once = true,
        buffer = info.buf,
        callback = function()
          vim.opt_local.syntax = ""
          return true
        end,
      })
    end
  end,
})

local mygroup = vim.api.nvim_create_augroup("MyCommentSettings", { clear = true })

autocmd({ "FileType" }, {
  group = mygroup,
  pattern = { "v", "vsh", "vv", "json" },
  callback = function()
    vim.bo.commentstring = "// %s"
  end,
})
autocmd({ "FileType" }, {
  group = mygroup,
  pattern = { "sql", "plpgsql", "plsql", "psql", "postgresql", "prql" },
  callback = function()
    vim.bo.commentstring = "-- %s"
  end,
})

-- vim.api.nvim_create_autocmd("CmdlineLeave", {
--   desc = "Handling annoying hit-return prompt",
--   callback = function()
--     local cmdtype = vim.fn.getcmdtype()
--     if cmdtype == "/" or cmdtype == "?" then
--       local pattern = vim.fn.getcmdline()
--       local result = vim.fn.search(pattern, "nc")
--       if result == 0 then
--         vim.api.nvim_input("<cr>")
--         vim.notify("E486: Pattern not found: " .. pattern, vim.log.levels.ERROR)
--       end
--     end
--   end,
-- })

-- autocmd("QuickFixCmdPost", {
--   group = augroup("qf"),
--   pattern = { "[^l]*" },
--   command = "cwindow",
-- })

autocmd({ "TermOpen", "BufEnter" }, {
  group = augroup("terminal"),
  pattern = { "*" },
  callback = function()
    if vim.opt.buftype:get() == "terminal" then
      vim.cmd.startinsert()
    end
  end,
})

-- TODO: make it like keep ratio instead of equal resizing
autocmd("VimResized", {
  desc = "auto resize splited windows",
  pattern = "*",
  command = "tabdo wincmd =",
})

-- Autocommand to clear the Git branch cache when the directory changes
autocmd({ "DirChanged", "FileChangedShellPost" }, {
  callback = git.clear_git_branch_cache,
})
-- Call this function when the buffer is opened in a window
autocmd({ "BufWinEnter", "FileChangedShellPost" }, {
  callback = function(data)
    git.update_git_branch(data, vim.fn.getcwd())
  end,
})

autocmd({ "BufWinLeave", "BufWritePost" }, {
  group = augroup("save_view"),
  callback = function()
    vim.cmd("silent! mkview")
  end,
})

autocmd({ "BufWinEnter" }, {
  group = augroup("load_view"),
  callback = function()
    vim.cmd("silent! loadview")
  end,
})

-- autocmd("FileType", {
--   group = augroup("yanking"),
--   pattern = "qf",
--   desc = "Yank in quickfix with no ||",
--   callback = function()
--     vim.keymap.set(
--       "n",
--       "<leader>y",
--       "<cmd>normal! wy$<cr>",
--       { noremap = true, silent = true }
--     )
--   end,
-- })

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local function save_cursorline_colors()
  _G.cursorline_bg_orig_gui =
    vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("CursorLine")), "bg", "gui")
  _G.cursorline_bg_orig_cterm =
    vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("CursorLine")), "bg", "cterm")
  if _G.cursorline_bg_orig_cterm == "" then
    _G.cursorline_bg_orig_cterm = "NONE"
  end
  if _G.cursorline_bg_orig_gui == "" then
    _G.cursorline_bg_orig_gui = "NONE"
  end
end

-- TODO: change this
local function update_cursorline_colors(is_recording)
  local gui = vim.o.background == "dark" and "#223322" or "#aaffaa"
  local cterm = vim.o.background == "dark" and "2" or "10"
  if not is_recording then
    gui = _G.cursorline_bg_orig_gui
    cterm = _G.cursorline_bg_orig_cterm
  end
  vim.cmd(string.format("hi CursorLine guibg=%s ctermbg=%s", gui, cterm))
end

vim.api.nvim_create_augroup("macro_visual_indication", {})
autocmd({ "RecordingEnter", "ColorScheme" }, {
  group = "macro_visual_indication",
  callback = function()
    save_cursorline_colors()
    update_cursorline_colors(vim.fn.reg_recording() ~= "")
  end,
})

autocmd("RecordingLeave", {
  group = "macro_visual_indication",
  callback = function()
    update_cursorline_colors(false)
  end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.api.nvim_command("normal! zz")
    end
  end,
})

-- similar to modicator.nvim plugin
autocmd({ "ModeChanged" }, {
  group = augroup("modechange"),
  callback = function()
    -- make it work on statuscolumn custom numbering (with ranges over visual selection)
    local hl = vim.api.nvim_get_hl(0, { name = u.get_mode_hl() })
    -- local curline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CursorLineNr", {
        fg = hl.fg,
      })
    end)
  end,
})

-- Redir output -> new buffer
vim.api.nvim_create_user_command("Redir", function(ctx)
  local result = vim.api.nvim_exec2(ctx.args, { output = true })
  if result.error then
    vim.notify(result.error, vim.log.levels.ERROR)
    return
  end
  local lines = vim.split(result.output, "\n", { plain = true })
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.opt_local.modified = false
  vim.opt_local.filetype = "redir"
end, { nargs = "+", complete = "command" })

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "checkhealth",
    "mininotify-history",
    "git",
    "grug-far",
    "vim",
    "molten_output",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    ---@diagnostic disable-next-line: undefined-field
    local file = (vim.uv or vim.loop).fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- autocmd("BufReadPost", {
--   once = true,
--   group = augroup("Globalfunction"),
--   callback = function()
--     require("utils.vimFunctions")
--   end,
-- })

-- Tahnks to @MariaSolOs https://github.com/MariaSolOs/dotfiles
-- local line_numbers_group =
--   vim.api.nvim_create_augroup("toggle_line_numbers", {})
-- autocmd({ "InsertLeave", "CmdlineLeave" }, {
--   group = line_numbers_group,
--   desc = "Toggle relative line numbers on",
--   callback = function()
--     if
--       vim.wo.nu
--       and vim.wo.relativenumber == false
--       and not vim.startswith(vim.api.nvim_get_mode().mode, "i")
--     then
--       vim.wo.relativenumber = true
--     end
--   end,
-- })
-- autocmd({ "InsertEnter", "CmdlineEnter" }, {
--   group = line_numbers_group,
--   desc = "Toggle relative line numbers off",
--   callback = function(args)
--     if vim.wo.nu and vim.wo.relativenumber then
--       vim.wo.relativenumber = false
--       if args.event == "CmdlineEnter" then
--         vim.cmd.redraw()
--       end
--     end
--   end,
-- })
