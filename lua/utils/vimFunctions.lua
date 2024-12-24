vim.cmd([[
  function TextObjectAll()
    let g:restore_position = winsaveview()
    normal! ggVG

    if index(['c','d'], v:operator) == 1
      " For delete/change ALL, we don't wish to restore cursor position.
    else
      call feedkeys("\<Plug>(RestoreView)")
    end

  endfunction
]])
-- lua version
-- local function textobjectall()
--   vim.g.restore_position = vim.fn.winsaveview()
--   vim.cmd("normal! ggVG")
--
--   if vim.fn.index({ "c", "d" }, vim.v.operator) == 1 then
--     -- For delete/change ALL, we don't wish to restore cursor position.
--   else
--     vim.fn.feedkeys("<Plug>(RestoreView)")
--   end
-- end
