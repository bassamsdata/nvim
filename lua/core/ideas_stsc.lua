-- @thanks to https://www.reddit.com/r/neovim/comments/1ggwaho/multiline_showbreaklike_wrapping_symbols_in/
-- Get the number of wrapped lines in the current buffer
local function get_num_wraps()
  -- Calculate the actual buffer width, accounting for splits, number columns, and other padding
  local wrapped_lines = vim.api.nvim_win_call(0, function()
    local winid = vim.api.nvim_get_current_win()

    -- get the width of the buffer
    local winwidth = vim.api.nvim_win_get_width(winid)
    local numberwidth = vim.wo.number and vim.wo.numberwidth or 0
    local signwidth = vim.fn.exists("*sign_define") == 1
        and vim.fn.sign_getdefined()
        and 2
      or 0
    local foldwidth = vim.wo.foldcolumn or 0

    -- subtract the number of empty spaces in your statuscol. I have
    -- four extra spaces in mine, to enhance readability for me
    local bufferwidth = winwidth - numberwidth - signwidth - foldwidth - 4

    -- fetch the line and calculate its display width
    local line = vim.fn.getline(vim.v.lnum)
    local line_length = vim.fn.strdisplaywidth(line)

    return math.floor(line_length / bufferwidth)
  end)

  return wrapped_lines
end
text = {
  ' ',
  "%=",
  function(args)
    if vim.v.virtnum < 0 then
      return '-'
    elseif vim.v.virtnum > 0 and (vim.wo.number or vim.wo.relativenumber) then
      local num_wraps = get_num_wraps()

      if vim.v.virtnum == num_wraps then
        return '└'
      else
        return '├'
      end
    end

    return require("statuscol.builtin").lnumfunc(args)
  end,
  ' ',
 }
},
