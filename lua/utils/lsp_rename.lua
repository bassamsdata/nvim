-- Thanks to venom https://github.com/RaafatTurki/venom
local M = {}
--- returns a table containing the lsp changes counts from an lsp result
local function count_lsp_res_changes(lsp_res)
  local count = { instances = 0, files = 0 }
  if lsp_res.documentChanges then
    for _, changed_file in pairs(lsp_res.documentChanges) do
      count.files = count.files + 1
      count.instances = count.instances + #changed_file.edits
    end
  elseif lsp_res.changes then
    for _, changed_file in pairs(lsp_res.changes) do
      count.instances = count.instances + #changed_file
      count.files = count.files + 1
    end
  end
  return count
end

function M.lsp_rename()
  local curr_name = vim.fn.expand("<cword>")
  local input_opts = {
    prompt = "LSP Rename: ",
    default = curr_name,
  }
  -- ask user input
  vim.ui.input(input_opts, function(new_name)
    -- check new_name is valid
    if not new_name or #new_name == 0 or curr_name == new_name then
      return
    end

    -- request lsp rename
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, vim.lsp.util.offset_encoding)
    params.newName = new_name

    vim.lsp.buf_request(0, "textDocument/rename", params, function(err, res, ctx, _)
      if err then
        if err.message then
          vim.notify(err.message, vim.log.levels.ERROR)
        end
        return
      end
      if not res then
        return
      end

      -- apply renames
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      -- need to check if client is nil, because it can be a string
      if not client then
        return
      end
      vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

      -- display a message
      local changes = count_lsp_res_changes(res)
      local message = string.format(
        "renamed %s instance%s in %s file%s. %s",
        changes.instances,
        changes.instances == 1 and "" or "s",
        changes.files,
        changes.files == 1 and "" or "s",
        changes.files > 1 and "To save them run ':wa'" or ""
      )
      vim.notify(message)
    end)
  end)
end

return M
