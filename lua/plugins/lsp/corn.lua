if vim.env.NVIM_TESTING then
  return {}
end
return {
  "RaafatTurki/corn.nvim",
  dev = false,
  event = "LspAttach",
  config = function()
    -- vim.diagnostic.config({ virtual_text = false })

    require("corn").setup({
      -- auto_cmds = false,
      sort_method = "column",
      -- scope = 'file',
      border_style = "none",
      blacklisted_modes = { "i", "v", "V" },
      icons = {
        error = "󰃤",
        warn = "",
        hint = "󰠠",
        info = "", -- 󰋼
      },

      ---@param item table
      ---@return table
      item_preprocess_func = function(item)
        local trunc_tail = "..."
        local max_width = vim.api.nvim_win_get_width(0) / 2

        if #item.message > max_width then
          item.message = item.message:sub(1, max_width - #trunc_tail) .. trunc_tail
          -- item.source = trunc_tail
        end

        return item
      end,

      -- on_toggle = function()
      --   vim.g.corn_hide = 1
      -- end,
    })
  end,
}
