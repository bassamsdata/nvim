local map = vim.keymap.set
local M = {}
local u = require("utils")
local f = require("functions")

-- ── love section ──────────────────────────────────────────────────────
-- LOVE: I love these mappings. **They are fun**
map("x", "/", "<Esc>/\\%V") --search within visual selection - this is magic
-- Replace all instances of highlighted words
map("v", "<leader>sa", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances" })
map(
  { "n", "v" },
  "<leader>sk",
  ":s/\\(.*\\)/\\1<left><left><left><left><left><left><left><left><left>",
  { desc = "Replace kierby word", silent = false }
)
map(
  "n",
  "<leader>se",
  ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "add to the end of the word", silent = false }
)

map("n", "<leader>sr", ":%s/<C-r><C-w>//g<Left><Left>", { desc = "replace word" })

map("n", "dd", function()
  ---@diagnostic disable-next-line: param-type-mismatch
  if vim.fn.getline(".") == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })

-- Ripgrep go to file by line number - this for search results
map("n", "<leader>rf", 'yiw?^[a-z]<CR>gf:<C-r>"<CR>')
-- open grep directly and then open quickfix with the results
map("n", "<localleader>g", u.grepandopen, { desc = "Grep and open quickfix" })
map("n", "<leader>ug", u.helpgrepnopen, { desc = "Grephelp and open quickfix" })
-- motions -- I really didn't know about such amazing keymaps `:h omap-info`
-- entire buffer (https://vi.stackexchange.com/a/2321)
-- like you can do `daa` to delete entire buffer, `yaa` to yank entire buffer
-- stylua: ignore start
-- map("n", "<BS>", "<C-o>")
map("n", "<Plug>(RestoreView)",        ":call winrestview(g:restore_position)<CR>")

-- TODO: Move this out of here
map("o", "aa", ":<c-u>call TextObjectAll()<CR>")
-- map("o", "aa", ":<c-u>normal! mzggVG<cr>`z")
-- map("o", "aa", ":<c-u>normal! mzggVG<cr>`z")
map("n", "<localleader>'", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<M-y>", u.swapBooleanInLine, { desc = "swap boolean" })
-- map("n", "<up>", "<cmd>lua vim.cmd('norm! 4')<cr>", { desc = "enhance jk" })
-- map("n", "<down>", "<cmd>lua vim.cmd('norm! 4')<cr>", { desc = "enhance jk" })
map("n", "<C-c>", "<cmd>normal! ciw<cr>i")
-- stylua: ignore end
-- map(
--   "n",
--   "<localleader>mm",
--   u.messages_to_quickfix,
--   { desc = ":Messages to quickfix" }
-- )
map(
  "n",
  "<Leader>tr",
  ':execute "!trans :ar " . expand("<cword>")<CR>',
  { desc = "Translate word" }
)
map("n", "<localleader>d", function()
  return ":e " .. vim.fn.expand("%:p:h") .. "/"
end, { expr = true }) -- NOTE: here ths **expr** is so important

-- ── Misc ──────────────────────────────────────────────────────────────
-- stylua: ignore start
map("n", "x", '"_x') -- delete single character without copying into register
map("n", "§§", "<cmd>cclose<cr>") -- close quickfix with §§
-- map("n", "gt", "gg") -- Go top of the page
-- map("n", "gb", "G") -- Go bottom of the page
map("i", "<C-l>", "<C-x><C-l>") -- Complete line -- didn't work
-- map({ "n", "i",     "!", "v" }, "§", "<esc>")
-- stylua: ignore end

-- HACK: this is to insert the fukking bound sign in neovim in conjunction
-- with this keymap in wezterm { key = "1", mods = "OPT", action = act.SendKey({ key = "1", mods = "ALT" }) }
map({ "i", "c" }, "<A-3>", "#")
-- ── Clear search with <esc> ───────────────────────────────────────────
map("n", "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" }) -- Open the package manager lazy

-- Keeping the cursor centered when cycling search results
map("n", "n", "nzzzv", { desc = "Next result" })
map("n", "N", "Nzzzv", { desc = "Previous result" })

-- ── page shift ────────────────────────────────────────────────────────
map("n", "<C-Up>", "<C-y>k", { desc = "Shift page up one line" })
map("n", "<C-Down>", "<C-e>j", { desc = "Shift page down one line" })

-- ── better indenting ──────────────────────────────────────────────────
map("v", "<", "<gv")
map("v", ">", ">gv")

-- -- Create a new highlight group for selected line numbers
-- vim.api.nvim_set_hl(0, "SelectedLineNr", { fg = "#ff875f", bold = true })
--
-- -- Function to highlight line numbers in visual selection
-- local function highlight_selected_numbers()
--   -- Only proceed if in visual mode
--   if vim.fn.mode():find("[vV]") then
--     local start_line = vim.fn.line("v")
--     local end_line = vim.fn.line(".")
--
--     -- Ensure start_line is smaller than end_line
--     if start_line > end_line then
--       start_line, end_line = end_line, start_line
--     end
--
--     -- Clear existing highlights
--     vim.fn.clearmatches()
--
--     -- Add highlight for the line number column in selected range
--     vim.fn.matchaddpos("SelectedLineNr", vim.fn.range(start_line, end_line))
--   end
-- end
--
-- -- Set up autocommands
-- local group =
--   vim.api.nvim_create_augroup("LineNumberHighlight", { clear = true })
-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--   group = group,
--   callback = function()
--     vim.fn.clearmatches()
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   group = group,
--   callback = highlight_selected_numbers,
-- })

-- ── Move to window using the <ctrl> hjkl keys ─────────────────────────
-- stylua: ignore start
map( "n", "<C-h>", "<C-w>h")
map( "n", "<C-j>", "<C-w>j")
map( "n", "<C-k>", "<C-w>k")
map( "n", "<C-l>", "<C-w>l")
-- stylua: ignore end

----------------------- TJ did this, so I need to try
-- So I did all the function above and below did it naturally
map("n", "<C-left>", "<C-w>5<")
map("n", "<C-right>", "<C-w>5>")
map("n", "<A-w>", "<C-w>+")
map("n", "<C-S-s>", "<C-w>-")
map("n", "<leader>xo", "<cmd>.lua<cr>", { desc = "source the current line" })

-- Buffers
map("n", "L", "<cmd>bn<cr>")
map("n", "H", "<cmd>bp<cr>")
map("n", "<leader>,", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  if line:match(",$") then -- Check if line ends with comma
    vim.api.nvim_set_current_line(line:sub(1, -2))
  else
    vim.cmd("norm A,")
  end
  vim.api.nvim_win_set_cursor(0, cursor)
end, { desc = "Add comma at end of line" })
map("n", "<leader>)", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd("norm A)")
  vim.api.nvim_win_set_cursor(0, cursor)
end, { noremap = true, silent = true })
-- Jump backwards
-- vim.keymap.del("n", "<BS>")
map("n", "<C-BS>", function()
  require("whatthejump").show_jumps(false)
  return "<C-o>"
end, { expr = true })
-- Make U opposite to u.
map("n", "U", "<C-r>", { desc = "Redo" })

-- Word navigation in non-normal modes.
map({ "i", "c" }, "<C-h>", "<C-Left>", { desc = "Move word(s) backwards" })
map("c", "<C-l>", "<C-Right>", { desc = "Move word(s) forwards" })

map("x", "y", "ygv<ESC>") -- preserve cursor position on visual yank
map("n", "==", "==_") -- move cursor to the start of the line on format
map("x", "=", "=gv_")
map("n", "J", "J_") -- go to end after a join
map("n", "S", "T hr<CR>k$") -- split (opposite of J)
-- map("i", "<C-a>", "r<CR><esc>k$a") -- split (opposite of J)
-- Add undo break-points
-- map("i", ",", ", <c-g>u") -- caused some problems
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- map("n", "S", function()
-- 	vim.api.nvim_put({ "", "" }, "c", false, false)
-- end, { silent = true, noremap = true })

-- TODO: let it work with visual mode as well
map({ "n", "v" }, "<leader>K", function()
  if vim.fn.mode() == "v" then
    local saved_reg = vim.fn.getreg("v")
    vim.cmd('normal! "vy')
    local selection = vim.fn.getreg("v")
    vim.fn.setreg("v", saved_reg)
    vim.cmd("help " .. selection)
  else
    vim.cmd("help " .. vim.fn.expand("<cword>"))
  end
end, { desc = "help for under cursor or selection" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

map("n", "<leader>:", function()
  vim.cmd("normal! ")
  vim.schedule(function()
    vim.cmd.startinsert()
  end)
end, { desc = "Insert mode" })

map("n", "<leader>gx", u.gxhandler, { desc = "Follow link" })
-- map(
--   "n",
--   "<leader>fd",
--   "<cmd>lua require('utils').gxdotfyle()<cr>",
--   { desc = "Follow dotfyle" }
-- )
-- ┌                                                         ┐
-- │ ── Mini Modules                                         │
-- │ ──────────────────────────────────────────────────────  │
-- └                                                         ┘

-- stylua: ignore start
map( "n", "<leader>ff", "<cmd>Pick frecency<cr>",               { desc = "Find [F]iles" })
map( "n", "<leader>fn", "<cmd>Pick config_frecency<cr>",                 { desc = "Find [N]vim config" })
map( "n", "<leader>fd", "<cmd>Pick nvim_data<cr>",                 { desc = "Find [N]vim plugin data" })
map( "n", "<leader>fp", "<cmd>Pick registry<cr>",               { desc = "Find [P]icker" })
map( "n", "<leader>/",  "<cmd>Pick grep_live<cr>",              { desc = "Find [G]rep_live" })
map( "n", "<leader>fG", "<cmd>Pick grep pattern='<cword>'<cr>", { desc = "Find [C]urrent word" })
map( "n", "<leader>fo", "<cmd>Pick oldfiles<cr>",               { desc = "Find [O]ld files" })
map( "n", "<leader>fr", "<cmd>Pick resume<cr>",                 { desc = "Find [R]esume" })
map( "n", "<leader>fl", "<cmd>Pick help<cr>",                   { desc = "Find he[L]p" })
map( "n", "<leader>fk", "<cmd>Pick keymaps<cr>",                { desc = "Find [K]eymaps" })
-- map( "n", "<leader>b",  "<cmd>Pick buffers<cr>",                { desc = "Find [B]uffers" })
map( "n", "<leader>fk", "<cmd>Pick keymaps<cr>",                { desc = "Find [K]eymaps" })
map( "n", "<leader>fh", "<cmd>Pick hl_groups<cr>",              { desc = "Find [H]ighlights" })
map( "n", "<leader>fc", "<cmd>Pick history scope=':'<cr>",      { desc = "Find [C]ommands" })
map( "n", "<leader>fs", "<cmd>Pick history scope='/'<cr>",      { desc = "Find [S]earch" })
map( "n", "<leader>fv", "<cmd>Pick visit_paths cwd=''<cr>",     { desc = "Visit paths (all)" })
map( "n", "<leader>fV", "<cmd>Pick visit_paths<cr>",            { desc = "Visit paths (cwd)" })
map( "n", "<leader>gk", "<cmd>Pick git_hunks<cr>",              { desc = "Git Hun[k]s" })
map( "n", "<leader><space>", "<cmd>Pick files<cr>",                           { desc = "Find [F]iles" })
map( "n", "<leader>gs",      "<cmd>Pick git_hunks scope='staged'<cr>",        { desc = "Git [S]taged" })
map( "n", "<leader>gK",      "<cmd>Pick git_hunks path='%'<cr>",              { desc = "Git Hun[k]s (current)" })
map( "n", "<leader>cs",      "<cmd>Pick lsp scope='document_symbol'<cr>",     { desc = "Symbols buffer (LSP)" })
map( "n", "<leader>cS",      "<cmd>Pick lsp scope='workspace_symbol'<cr>",    { desc = "Symbols workspace (LSP)" })
map( "n", "<leader>cd",      "<cmd>Pick diagnostic scope='all'<cr>",          { desc = "Diagnostic workspace" })
map( "n", "<leader>cD",      "<cmd>Pick diagnostic scope='current'<cr>",      { desc = "Diagnostic buffer" })
map( "n", "<localleader>mn", "<cmd>15sp | lua MiniNotify.show_history()<cr>", { desc = "Diagnostic buffer" })
-- stylus: ignore end
map("n", "<leader>q", function()
  require("quicker").toggle({ height = 100, focus = true, min_height = 10})
end, {
  desc = "Toggle quickfix",
})
-- I got this from reedit - wow, look how simple it is
M.mini_files_key = {
  {
    "<leader>e",
    function()
      -- added this just to open the mini.files at the current file location
      local bufname = vim.api.nvim_buf_get_name(1)
      local _ = require("mini.files").close()
        or require("mini.files").open(bufname, false)
    end,
    { desc = "File explorer" },
  },
}


-- ── Spell ─────────────────────────────────────────────────────────────
-- Thanks to Bugaboo, Correct misspelled word / mark as correct
map("i", "<C-g>=", "<C-g>u<Esc>[s1z=`]a<C-G>u") --first suggestions
-- credit to @Maria Solos
-- Use dressing (or mini.pick) for spelling suggestions.
map("n", "z=", function()
  vim.ui.select(
    vim.fn.spellsuggest(vim.fn.expand("<cword>")),
    {},
    vim.schedule_wrap(function(selected)
      if selected then
        vim.cmd("normal! ciw" .. selected)
      end
    end)
  )
end, { desc = "Spelling suggestions" })
local function spellToggle()
  if vim.opt.spell:get() then
    vim.opt_local.spell = false
    vim.opt_local.spelllang = "en"
  else
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end
end
map("n", "<leader>5", spellToggle, { desc = "Toggle spell" })

map("n", "<leader>td", function()
  require("core.todo_notes").open()
end, {})
-- ── Terminal ──────────────────────────────────────────────────────────
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-k>", "<C-\\><C-n><C-w><C-k>", { desc = "out of terminal to top" })
map("t", "<C-h>", "<C-\\><C-n><C-w><C-h>", { desc = "Out of terminal to left" })

-- Toggling terminals
map({ "n", "t" }, "<M-s>", function()
  require("localModules.nvterminal").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle Floating term" })

map("n","<S-tab>","<cmd>tabNext<cr>",{desc = "Next tab"})
map("n","<C-S-tab>","<cmd>tabprevious<cr>",{desc = "Previous tab"})

map({ "n", "t" }, "<M-v>", function()
  require("localModules.nvterminal").toggle({ pos = "vsp", id = "verticalTerm", width = 0.8 })
end, { desc = "Terminal Toggle Vertical term" })

map({ "n", "t" }, "<C-S-h>", function()
  require("localModules.nvterminal").toggle({ pos = "sp", id = "horizontalTerm" })
end, { desc = "Terminal Toggle Horizontal term" })

-- Creating new terminals
map(
  "n",
  "<leader>cnv",
  [[<cmd>lua require("nvterminal").new({ pos = "vsp", size = 0.3 })<CR>]],
  { noremap = true, silent = true, desc = "Create New Vertical Terminal" }
)
map(
  "n",
  "<leader>cnh",
  [[<cmd>lua require("nvterminal").new({ pos = "sp", size = 0.5 })<CR>]],
  { noremap = true, silent = true, desc = "Create New Horizontal Terminal" }
)

map(
  "n",
  "<leader>wx",
  [[<cmd>lua require("nvterminal").runner{ cmd = function() local file = vim.fn.expand("%"); local ext = vim.fn.fnamemodify(file, ":e"); if ext == "go" then return "go run ".. file else return "python3 ".. file end end }<CR>]],
  { noremap = true, silent = true, desc = "Execute Current File (Go/Python)" }
)
-- ── clean registers ───────────────────────────────────────────────────
local function clear_registers()
  local registers =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
  for register in registers:gmatch(".") do
    vim.fn.setreg(register, {})
  end
end
map("n", "<leader>rg", clear_registers, { desc = "Clear registers" })
map(
  "n",
  "ghy",
  require("utils.git").copy_hunk_ref_text,
  { desc = "Copy hunk's reference lines" }
)
map("x", "<Space>dc", u.diff_with_clipboard, { desc = "Diff with clipboard" })
map("x", "<Space>dC", u.diff_with_clipboard2, { desc = "Diff with clipboard" })
  -- ── Abbreviations ─────────────────────────────────────────────────────
-- ── run Stuff ─────────────────────────────────────────────────────
map("n", "<leader>cg", f.run_file, { desc = "[C]ode [G]o mode" })
map("n", "<leader>cr", f.run_file_term, { desc = "[C]ode [R]un in Term" })
map("n", "<leader>cl", "<cmd>w | so %<cr>", { desc = "[C]ode [R]un in Term" })

-- ── Ai ───────────────────────────────────────────────────────────
-- map("n", "<leader>ac", "<cmd>CodyChat<cr>", { desc = "[A]i [C]hat - cody" })
map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "[A]i [C]codeCompanion" })
map({ "n", "v"  }, "<leader>as", "<cmd>CodeCompanionActions<cr>", { desc = "[A]i Ation[S]" })
map({ "n", "v"  }, "<leader>ai", ":CodeCompanion<space>", { desc = "[A]i [I]nline" })
-- map("v", "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", { desc = "[A]i [A]dd" })
vim.keymap.set("v", "<leader>ad", function()
    require("codecompanion").add({})
end, { desc = "[A]i [A]dd" })

-- ── Arrow ───────────────────────────────────────────────────────────
map("n", "<C-s>", function() -- Select first file
  local _ = pcall(require, "arrow")
  local arrow_files = vim.g.arrow_filenames

  if #arrow_files > 0 then
    vim.cmd("edit " .. arrow_files[1])
  end
end, { desc = "Select first file", silent = true })

map("n", "<C-;>", function() -- Select second file
  local _ = pcall(require, "arrow")
  local arrow_files = vim.g.arrow_filenames

  if #arrow_files > 1 then
    vim.cmd("edit " .. arrow_files[2])
  end
end, { desc = "Select second file", silent = true })

map("n", "<localleader>\\", function() -- Select third file
  local _, arrow = pcall(require, "arrow.commands")
  return arrow.commands.toggle_current_line_for_buffer()
end, { desc = "set buffer bookmark", silent = true })

map("n", "]m", "<cmd>Arrow next_buffer_bookmark<cr>", { desc = "next buffer bookmark", silent = true })
map("n", "[m", "<cmd>Arrow prev_buffer_bookmark<cr>", { desc = "set buffer bookmark", silent = true })

-- map("n", "<C-'>", function() -- Select third file
--   local _ = pcall(require, "arrow")
-- local arrow_table = require("arrow.buffer_persist").get_bookmarks_by()
--   if #arrow_table > 0 then
--     -- vim.cmd(tostring(arrow_table[1].line))
--     return vim.api.nvim_win_set_cursor(0, { arrow_table[1].line, arrow_table[1].col })
--   end
-- end, { desc = "Select first file", silent = true })

-- map("n", "<C-'>", function() -- Select third file
--   local _ = pcall(require, "arrow")
-- local arrow_table = require("arrow.buffer_persist").get_bookmarks_by()
--   if #arrow_table > 1 then
--     -- vim.cmd(tostring(arrow_table[1].line))
--     return vim.api.nvim_win_set_cursor(0, { arrow_table[2].line, arrow_table[2].col })
--   end
-- end, { desc = "Select first file", silent = true })

-- ── Marks ───────────────────────────────────────────────────────────
local function deleteMarks()
  local char = vim.fn.nr2char(vim.fn.getchar())
  vim.cmd("delmarks " .. char)
end
map("n", "dm", deleteMarks, { noremap = true, silent = true })

-- ── Neovide ───────────────────────────────────────────────────────────
if vim.g.neovide then
  -- stylua: ignore start 
  map({ "n", "v" }, "<C-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>")
  map({ "n", "v" }, "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>")
  map({ "n", "v" }, "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")
  map("c", "<D-v>", "<C-R>+") -- Paste command mode
  map("i", "<D-v>", "<ESC>pli") -- Paste insert mode
  map("n", "<D-n>", "<cmd>silent exec 'neovide &'<cr>")
  map("n", "<D-t>", "<cmd>!cd ~ &&neovide &<cr>")
  -- stylua: ignore end
end


map("n", "R", Gat("v:lua.Substitute"), { desc = "Substitute", silent = true })
-- map("v", "T", Gat("v:lua.Substitute2"), { silent = true })
-- map( "n", "R", "m'<cmd>set opfunc=v:lua.Substitute<CR>g@", { desc = "Substitute", silent = true })


map(
  "n",
  "<leader>sd",
  require("functions").change_directory,
  { desc = "Change directory", silent = true }
)

map(
  "n",
  "dM",
  f.delmarks_motion,
  { desc = "Delete marks in motion", silent = true }
)

map("n", "<localleader>j", function()
  vim.cmd("normal! \\e")
  return vim.fn.feedkeys(vim.api.nvim_replace_termcodes("ip", true, true, true))
end, { desc = "Substitute word under cursor" }) -- Usage:
--   <key>ipfoo<CR>         Substituteee every occurrence of the word under
--                          the cursor with 'foo' in the current paragraph
--   <key>Gfoo<CR>          Same, from here to the end of the buffer
--   <key>?bar<CR>foo<CR>   Same, from previous occurrence of 'bar'
--                          to current line



local function select_codecompanion_adapter()
  local adapters = {'gemini', 'openai', 'anthropic', 'groq', 'xai', 'huggingface', "copilot"}
  vim.ui.select(adapters, { prompt = "Select CodeCompanion Adapter:" }, function(choice)
    if choice then
      vim.g.codecompanion_adapter = choice
      vim.notify("CodeCompanion adapter set to: " .. choice, vim.log.levels.INFO)
    end
  end)
end

vim.keymap.set('n', '<Leader>cc', select_codecompanion_adapter)

local function toggle_messages()
  local version = vim.version()
  if version.minor < 11 then
    vim.notify("Wait mode is only supported in Neovim 0.11+", vim.log.levels.WARN)
    return
  end
  local current = vim.opt.messagesopt:get()
  if vim.tbl_contains(current, "hit-enter") then
    vim.opt.messagesopt = "wait:1000,history:500"
    vim.notify("Messages: wait mode", vim.log.levels.INFO)
  else
    vim.opt.messagesopt = "hit-enter,history:500"
    vim.notify("Messages: hit-enter mode", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>ue", toggle_messages, { desc = "Toggle message display mode" })

return M
