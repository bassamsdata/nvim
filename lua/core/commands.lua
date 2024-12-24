local command = vim.api.nvim_create_user_command

command("Mess", function()
  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch_buffer].filetype = "vim"
  local messages = vim.split(vim.fn.execute("messages", "silent"), "\n")
  vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, messages)
  vim.cmd.sbuffer(scratch_buffer)
  vim.cmd("normal! G")
  vim.api.nvim_set_option_value("modifiable", false, { buf = scratch_buffer })
  vim.api.nvim_set_option_value("wrap", true, { win = 0 })
  vim.api.nvim_win_set_height(0, 10)
end, {})

command("CloseOtherBuffers", function()
  require("utils").close_other_buffers()
end, {})

command("KeepOnlyArrowFiles", function()
  require("utils").keepOnlyArrowFiles()
end, {})

command("Lg", function()
  require("localModules.nvterminal").create_tool("lazygit", 0.9, 0.9)
end, {})

command("LspDebug", function()
  require("localModules.lsp_debugging").inspect_lsp_client()
end, {})
