local function get_buffer_functions(callback)
  if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.document_symbol({
    on_list = function(response)
      if not response or not response.items then
        vim.notify("No items in LSP response", vim.log.levels.WARN)
        return
      end

      local functions = {}
      for _, item in ipairs(response.items) do
        -- Check the actual kind string instead of number
        if item.kind == "Function" or item.kind == "Method" then
          table.insert(functions, {
            name = item.text,
            range = {
              start = {
                line = item.lnum - 1,
                character = item.col - 1,
              },
            },
            detail = item.text,
          })
        end
      end

      if #functions == 0 then
        vim.notify("No functions found in current buffer", vim.log.levels.INFO)
        return
      end

      if callback then
        callback(functions)
      end
    end,
  })
end

-- Handler for floating window
local function show_in_float(functions)
  local lines = {}
  for _, func in ipairs(functions) do
    table.insert(lines, func.name)
  end

  -- Guard against empty results
  if #lines == 0 then
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 40,
    height = math.min(#lines, 20), -- Limit height and ensure it's at least 1
    row = 1,
    col = 1,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Handler for quickfix list
local function show_in_quickfix(functions)
  local qf_items = {}
  for _, func in ipairs(functions) do
    if func.range then
      table.insert(qf_items, {
        bufnr = vim.api.nvim_get_current_buf(),
        lnum = func.range.start.line + 1,
        col = func.range.start.character + 1,
        text = func.name,
      })
    end
  end

  -- Guard against empty results
  if #qf_items == 0 then
    vim.notify("No function locations found", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist(qf_items)
  vim.cmd("copen")
end

-- Set up keymaps
vim.keymap.set("n", "<leader>cf", function()
  get_buffer_functions(show_in_float)
end, { desc = "Show functions in float" })
vim.keymap.set("n", "<leader>cq", function()
  get_buffer_functions(show_in_quickfix)
end, { desc = "Show functions in quickfix" })

local function get_buffer_functions_alt(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }

  vim.lsp.buf_request(
    bufnr,
    "textDocument/documentSymbol",
    params,
    function(err, result, ctx, config)
      if err then
        vim.notify("LSP Error: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end

      if not result or vim.tbl_isempty(result) then
        vim.notify("No symbols found", vim.log.levels.INFO)
        return
      end

      local functions = {}
      local function extract_functions(symbols)
        for _, symbol in ipairs(symbols) do
          if
            symbol.kind == vim.lsp.protocol.SymbolKind.Function
            or symbol.kind == vim.lsp.protocol.SymbolKind.Method
          then
            table.insert(functions, {
              name = symbol.name,
              range = symbol.range,
              detail = symbol.detail,
            })
          end
          -- Check for nested functions
          if symbol.children then
            extract_functions(symbol.children)
          end
        end
      end

      extract_functions(result)

      if #functions > 0 and callback then
        callback(functions)
      else
        vim.notify("No functions found", vim.log.levels.INFO)
      end
    end
  )
end

-- Try both approaches with these keymaps
vim.keymap.set("n", "<leader>cF", function()
  get_buffer_functions_alt(show_in_float)
end, { desc = "Show functions in float (method 2)" })
