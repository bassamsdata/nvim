-- Modified version of @Nvchad's nvterm --thanks a lot
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/term/init.lua
local api = vim.api
local g = vim.g
local M = {}
local set_buf = api.nvim_set_current_buf

g.nvchad_terms = {}

local pos_data = {
  sp = { resize = "height", area = "lines" },
  vsp = { resize = "width", area = "columns" },
}

local function calculate_float_dims(height_percent, width_percent)
  -- Use default values if not provided
  height_percent = height_percent or 0.4 -- keeps your original default
  width_percent = width_percent or 0.6 -- keeps your original default

  local height = math.floor(height_percent * vim.o.lines)
  local width = math.floor(width_percent * vim.o.columns)

  return {
    border = "rounded",
    anchor = "NW",
    height = height,
    width = width,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    relative = "editor",
    zindex = 300,
  }
end

local config = {
  hl = "Normal:term,WinSeparator:WinSeparator",
  sizes = { sp = 0.3, vsp = 0.3 },
  float = calculate_float_dims(),
}

-- used for initially resizing terms
vim.g.nvhterm = false
vim.g.nvvterm = false

-------------------------- util funcs -----------------------------
local function save_term_info(index, val)
  local terms_list = g.nvchad_terms
  terms_list[tostring(index)] = val
  g.nvchad_terms = terms_list
end

local function opts_to_id(id)
  for _, opts in pairs(g.nvchad_terms) do
    if opts.id == id then
      return opts
    end
  end
end

local function create_float(buffer, float_opts)
  local base_opts = calculate_float_dims()
  local opts = vim.tbl_deep_extend("force", base_opts, float_opts or {})
  vim.api.nvim_open_win(buffer, true, opts)
end

local function format_cmd(cmd)
  return type(cmd) == "string" and cmd or cmd()
end

function M.display(opts)
  if opts.pos == "float" then
    create_float(opts.buf, opts.float_opts)
  else
    vim.cmd(opts.pos)
  end

  local win = api.nvim_get_current_win()
  opts.win = win

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  -- vim.wo[win].foldcolumn = "0"
  -- vim.wo[win].signcolumn = "no"
  vim.bo[opts.buf].buflisted = false
  vim.wo[win].winhl = opts.hl or config.hl
  vim.b[opts.buf].miniindentscope_disable = true
  vim.cmd.startinsert()

  -- resize non floating wins initially + or only when they're toggleable
  if
    (opts.pos == "sp" and not vim.g.nvhterm)
    or (opts.pos == "vsp" and not vim.g.nvvterm)
    or (opts.pos ~= "float")
  then
    local pos_type = pos_data[opts.pos]
    local size = opts.size and opts.size or config.sizes[opts.pos]
    local new_size = vim.o[pos_type.area] * size
    api["nvim_win_set_" .. pos_type.resize](0, math.floor(new_size))
  end

  api.nvim_win_set_buf(win, opts.buf)
end

local function create(opts)
  local buf_exists = opts.buf
  opts.buf = opts.buf or vim.api.nvim_create_buf(false, true)

  -- handle cmd opt
  local shell = vim.o.shell
  ---@type string|table
  local cmd = shell

  if opts.cmd and opts.buf then
    cmd = { shell, "-c", format_cmd(opts.cmd) .. "; " .. shell }
  end

  M.display(opts)

  save_term_info(opts.buf, opts)

  if not buf_exists then
    vim.fn.termopen(cmd, {
      on_exit = function(_, _, _)
        if vim.api.nvim_win_is_valid(opts.win) then
          vim.api.nvim_win_close(opts.win, true)
        end
      end,
    })
  end

  vim.g.nvhterm = opts.pos == "sp"
  vim.g.nvvterm = opts.pos == "vsp"
end

--------------------------- user api -------------------------------
function M.open(opts)
  create(opts)
end

function M.toggle(opts)
  local x = opts_to_id(opts.id)
  opts.buf = x and x.buf or nil

  if (x == nil or not api.nvim_buf_is_valid(x.buf)) or vim.fn.bufwinid(x.buf) == -1 then
    create(opts)
  else
    api.nvim_win_close(x.win, true)
  end
end

-- spawns term with *cmd & runs the *cmd if the keybind is run again
function M.run(opts)
  local x = opts_to_id(opts.id)
  local clear_cmd = opts.clear_cmd or "clear; "
  opts.buf = x and x.buf or nil

  -- if buf doesnt exist
  if x == nil then
    create(opts)
  else
    -- window isnt visible
    if vim.fn.bufwinid(x.buf) == -1 then
      M.display(opts)
    end

    local cmd = format_cmd(opts.cmd)

    if x.buf == api.nvim_get_current_buf() then
      set_buf(g.buf_history[#g.buf_history - 1])
      cmd = format_cmd(opts.cmd)
      set_buf(x.buf)
    end

    local job_id = vim.b[x.buf].terminal_job_id
    vim.api.nvim_chan_send(job_id, clear_cmd .. cmd .. " \n")
  end
end

function M.create_tool(cmd, height_percent, width_percent)
  local float_dims = calculate_float_dims(height_percent, width_percent)

  local tool_opts = {
    id = cmd,
    pos = "float",
    cmd = cmd,
    float_opts = float_dims,
  }

  M.toggle(tool_opts)

  -- Set buffer to be wiped when hidden
  vim.bo[tool_opts.buf].bufhidden = "wipe"
  --
  -- -- Add autocmd to close window when terminal process exits
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = tool_opts.buf,
    callback = function()
      vim.schedule(function()
        vim.api.nvim_win_close(0, true)
      end)
    end,
    once = true,
  })
  vim.keymap.set("n", "q", function()
    local job_id = vim.b[tool_opts.buf].terminal_job_id
    if job_id then
      vim.api.nvim_chan_send(job_id, "\x03")
      vim.api.nvim_chan_send(job_id, "exit\n")
    end
  end, { buffer = tool_opts.buf, noremap = true, silent = true })
end

--------------------------- autocmds -------------------------------
api.nvim_create_autocmd("TermClose", {
  callback = function(args)
    save_term_info(args.buf, nil)
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    -- Find and update any visible floating terminals
    for _, opts in pairs(vim.g.nvchad_terms or {}) do
      if opts.pos == "float" then
        local win_id = vim.fn.bufwinid(opts.buf)
        if win_id ~= -1 then
          local new_opts = calculate_float_dims()
          vim.api.nvim_win_set_config(win_id, new_opts)
        end
      end
    end
  end,
})

return M
