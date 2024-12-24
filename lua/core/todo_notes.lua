local M = {}
-- Total rewrite - idea from this post https://www.reddit.com/r/neovim/comments/1bl8wug/comment/kw5og55/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
M.open = function()
  local height, width, buf, win, cwd, buf_options, setupKeymap
  -- relative height and width
  height = math.floor(0.618 * vim.o.lines)
  width = math.floor(0.618 * vim.o.columns)
  buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    -- get the coordinates to ceneter the window
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
    style = "minimal",
    title = " " .. " TODO",
    border = "rounded",
  })
  cwd = vim.uv.cwd()
  vim.cmd.edit(cwd .. "/TODO.md")
  buf_options = {
    number = false,
    relativenumber = false,
    conceallevel = 0,
    signcolumn = "no",
  }
  for option, value in pairs(buf_options) do
    vim.api.nvim_set_option_value(option, value, { scope = "local" })
  end
  -- or vim.cmd(("silent! noautocmd setlocal %s"):format(table.concat(buf_options, " ")))

  setupKeymap = function(key, bufnr)
    vim.keymap.set("n", key, function()
      vim.cmd("silent w")
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end, { buffer = bufnr })
  end

  setupKeymap("<esc>", buf)
  setupKeymap("q", buf)
end

return M
