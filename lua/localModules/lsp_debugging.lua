local M = {}
function M.inspect_lsp_client()
  vim.ui.input({ prompt = "Enter LSP Client name: " }, function(client_name)
    if client_name then
      local client = vim.lsp.get_clients({ name = client_name })

      if #client == 0 then
        vim.notify(
          "No active LSP clients found with this name: " .. client_name,
          vim.log.levels.WARN
        )
        return
      end

      -- Create a temporary buffer to show the configuration
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.75),
        height = math.floor(vim.o.lines * 0.90),
        col = math.floor(vim.o.columns * 0.125),
        row = math.floor(vim.o.lines * 0.05),
        style = "minimal",
        border = "rounded",
        title = " "
          .. (client_name:gsub("^%l", string.upper))
          .. ": LSP Configuration ",
        title_pos = "center",
        zindex = 300,
      })

      local lines = {}
      for i, this_client in ipairs(client) do
        if i > 1 then
          table.insert(lines, string.rep("-", 80))
        end
        table.insert(lines, "Client: " .. this_client.name)
        table.insert(lines, "ID: " .. this_client.id)
        table.insert(lines, "")
        table.insert(lines, "Configuration:")

        local config_lines = vim.split(vim.inspect(this_client.config), "\n")
        vim.list_extend(lines, config_lines)
      end

      -- Set the lines in the buffer
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Set buffer options
      vim.bo[buf].modifiable = false
      vim.bo[buf].filetype = "lua"
      vim.bo[buf].bh = "delete"

      -- Define resizing function
      local function resize_window()
        local width = math.floor(vim.o.columns * 0.75)
        local height = math.floor(vim.o.lines * 0.90)
        local col = math.floor(vim.o.columns * 0.125)
        local row = math.floor(vim.o.lines * 0.05)
        vim.api.nvim_win_set_config(win, {
          width = width,
          height = height,
          col = col,
          row = row,
        })
      end

      -- Create an autocommand group for resizing
      vim.api.nvim_create_augroup("LspClientWindowResize", { clear = true })
      vim.api.nvim_create_autocmd("VimResized", {
        group = "LspClientWindowResize",
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            resize_window()
          end
        end,
      })

      vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "q",
        ":q<CR>",
        { noremap = true, silent = true }
      )
    end
  end)
end
return M
