local M = {}

-- thanks to tamton-aquib https://github.com/tamton-aquib/essentials.nvim/blob/b082e194dcd65656431411a4dd11c7f8b636616f/lua/essentials/init.lua#L93-L108

local fts = {
  python = "ipython %",
  lua = "so %",
  r = "R %",
  sh = "chmod +x %", -- make script executable
  go = "go run %",
  sql = "duckdb -f %",
  quarto = "quarto render %",
  rmd = "R -e 'rmarkdown::render(\"%\")'",
  markdown = "pandoc % -o %:r.html",
}
function M.run_file_term(option, term_height)
  local cmd = fts[vim.bo.ft]
  local height = term_height or 15

  if not cmd then
    vim.notify("No command for this filetype", vim.log.levels.WARN)
    return
  end

  vim.cmd("w")
  vim.cmd(string.format("%s%ssp | terminal", option or "", height))

  vim.defer_fn(function()
    local job_id = vim.b.terminal_job_id
    vim.fn.chansend(job_id, cmd .. "\n")
    vim.cmd("startinsert")
  end, 100)
end

-- This is what you need
M.run_file = function(option)
  local cmd = fts[vim.bo.ft]
  vim.cmd(
    cmd and ("silent! w | " .. (option or "") .. "!" .. cmd)
      or "echo 'No command for this filetype'"
  )
end

------------------------------------------
-- delete all marks on current line
-- modified version - thanks to https://vi.stackexchange.com/questions/13984/how-do-i-delete-a-mark-in-current-line
M.delmarks = function()
  local marks = {}
  for i = string.byte("a"), string.byte("z") do
    local mark = string.char(i)
    local mark_line = vim.fn.getpos("'" .. mark .. "'")[2]
    if mark_line == vim.fn.line(".") then
      table.insert(marks, mark)
    end
  end
  local m = table.concat(marks)
  if m ~= "" then
    vim.cmd("delmarks " .. m)
  end
end

function M.delmarks_motion()
  -- Backup the previous operatorfunc
  local old_func = vim.go.operatorfunc

  -- Define a new function that will be called by the motion command
  _G.op_func_delmarks = function()
    -- Get the start and end positions of the motion
    local start = vim.api.nvim_buf_get_mark(0, "[")
    local finish = vim.api.nvim_buf_get_mark(0, "]")

    -- Iterate through the marks in the range and delete them
    for i = string.byte("a"), string.byte("z") do
      local mark = string.char(i)
      local mark_line = vim.fn.getpos("'" .. mark .. "'")[2]
      if mark_line >= start[1] and mark_line <= finish[1] then
        vim.cmd("delmarks " .. mark)
      end
    end

    -- Restore the previous operatorfunc and remove the temporary function
    vim.go.operatorfunc = old_func
    _G.op_func_delmarks = nil
  end

  -- Set the operatorfunc to the new function
  vim.go.operatorfunc = "v:lua.op_func_delmarks"

  -- Trigger the motion command
  vim.api.nvim_feedkeys("g@", "n", false)
end

------------------------------------------
-- Substitution function
-- lua version of the original post, thanks to https://gist.github.com/romainl/b00ccf58d40f522186528012fd8cd13d
-- TODO: make it print the old name as well like lsp rename using vim.ui.input
-- this doesn't work after mini.surround, we need to do it like delete marks
_G.Substitute = function()
  -- I tried this way but it didn't work,vim.api.nvim_win_get_cursor(0)
  local cur = vim.fn.getpos("''")
  vim.fn.cursor(cur[2], cur[3])
  local cword = vim.fn.expand("<cword>")
  local input = vim.fn.input(cword .. "/")
  local cmd = "'[,']s/" .. cword .. "/" .. input .. "/g"
  vim.fn.execute(cmd)
  vim.fn.cursor(cur[2], cur[3])
  vim.notify(cword .. " -> " .. input, vim.log.levels.INFO)
end

_G.Gat = function(method)
  vim.api.nvim_set_option_value("operatorfunc", method, {})
  return "m' g@"
end

_G.Substitute2 = function()
  local cmd, cword = "", ""
  local start_col, end_col, line, input

  start_col = vim.fn.col("'<") - 1
  end_col = vim.fn.col("'>") - 1
  line = vim.fn.getline(".")
  cword = string.sub(line, start_col + 1, end_col + 1) -- Corrected string slicing
  input = vim.fn.input(cword .. "/")
  cmd = "'<,'>s/" .. cword .. "/" .. input .. "/g"

  vim.fn.execute(cmd)
  vim.notify(cword .. " -> " .. input, vim.log.levels.INFO)
end

------------------------------------------

---@return nil
function M.change_directory()
  local buf = vim.api.nvim_get_current_buf()
  local root =
    vim.fs.root(buf, { ".git", "main.R", "data/", "main.py", "main.qmd", "README.md" })
  if root then
    vim.uv.chdir(root)
    vim.notify("CWD is now " .. root, vim.log.levels.INFO)
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to change directory to " .. root, vim.log.levels.ERROR)
    end
  else
    vim.notify("No suitable root directory found", vim.log.levels.WARN)
  end
end

return M
