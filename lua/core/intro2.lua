local M = {}
local api = vim.api
local fn = vim.fn

local headers = {
  "         .▄▄ · ▪  ▄▄▌   ▄▄▄·    󰲓     Z ",
  " 󰩖     ▐█ ▀. ██ ██•  ▐█ ▀█      Z     ",
  "         ▄▀▀▀█▄▐█·██▪  ▄█▀▀█   z        ",
  "         ▐█▄▪▐█▐█▌▐█▌▐▌▐█ ▪▐ z          ",
  "          ▀▀▀▀ ▀▀▀.▀▀▀  ▀  ▀            ",
  "       As Cutest As The Moon 󰽦          ",
}

local emmptyLine = string.rep(" ", vim.fn.strwidth(headers[1]))

table.insert(headers, 1, emmptyLine)
table.insert(headers, 2, emmptyLine)

headers[#headers + 1] = emmptyLine
headers[#headers + 1] = emmptyLine

api.nvim_create_autocmd("BufLeave", {
  pattern = "sila",
  callback = function()
    vim.cmd("bdelete!")
  end,
})

local silaWidth = #headers[1] + 3

local max_height = #headers + 4 -- 4  = extra spaces i.e top/bottom
local get_win_height = api.nvim_win_get_height

M.set_cleanbuf_opts = function(ft)
  local opt = vim.opt_local

  opt.buflisted = false
  opt.modifiable = false
  opt.buftype = "nofile"
  opt.number = false
  opt.list = false
  opt.wrap = false
  opt.relativenumber = false
  opt.cursorline = false
  opt.colorcolumn = "0"
  opt.foldcolumn = "0"

  vim.opt_local.filetype = ft
  vim.g[ft .. "_displayed"] = true
end

M.open = function()
  vim.g.nv_previous_buf = vim.api.nvim_get_current_buf()

  local buf = vim.api.nvim_create_buf(false, true)
  local win = api.nvim_get_current_win()

  -- switch to larger win if cur win is small
  if silaWidth + 6 > api.nvim_win_get_width(0) then
    vim.api.nvim_set_current_win(api.nvim_list_wins()[2])
    win = api.nvim_get_current_win()
  end

  api.nvim_win_set_buf(win, buf)

  local header = headers

  local function addPadding_toHeader(str)
    local pad = (api.nvim_win_get_width(win) - fn.strwidth(str)) / 2
    return string.rep(" ", math.floor(pad)) .. str .. " "
  end

  local dashboard = {}

  for _, val in ipairs(header) do
    table.insert(dashboard, val .. " ")
  end

  local result = {}

  -- make all lines available
  for i = 1, math.max(get_win_height(win), max_height) do
    result[i] = ""
  end

  local headerStart_Index = math.abs(
    math.floor((get_win_height(win) / 2) - (#dashboard / 2))
  ) + 1 -- 1 = To handle zero case
  local abc = math.abs(math.floor((get_win_height(win) / 2) - (#dashboard / 2)))
    + 1 -- 1 = To handle zero case

  -- set ascii
  for _, val in ipairs(dashboard) do
    result[headerStart_Index] = addPadding_toHeader(val)
    headerStart_Index = headerStart_Index + 1
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, result)

  local sila = api.nvim_create_namespace("sila")
  local horiz_pad_index = math.floor(
    (api.nvim_win_get_width(win) / 2) - (silaWidth / 2)
  ) - 2

  for i = abc, abc + #header do
    api.nvim_buf_add_highlight(buf, sila, "SilaHeader", i, horiz_pad_index, -1)
  end

  for i = abc + #header - 2, abc + #dashboard do
    api.nvim_buf_add_highlight(
      buf,
      sila,
      "NvDashButtons",
      i,
      horiz_pad_index,
      -1
    )
  end

  -- api.nvim_win_set_cursor(
  -- 	win,
  -- 	{ abc + #header, math.floor(vim.o.columns / 2) - 13 }
  -- )

  M.set_cleanbuf_opts("sila")
end

return M
