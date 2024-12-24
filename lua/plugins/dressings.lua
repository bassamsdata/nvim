if vim.env.NVIM_TESTING then
  return {}
end
return {
  -- "stevearc/dressing.nvim",
  -- lazy = true,
  -- init = function()
  --   ---@diagnostic disable-next-line: duplicate-set-field
  --   -- vim.ui.select = function(...)
  --   --   require("lazy").load({ plugins = { "dressing.nvim" } })
  --   --   return vim.ui.select(...)
  --   -- end
  --   ---@diagnostic disable-next-line: duplicate-set-field
  --   vim.ui.input = function(...)
  --     require("lazy").load({ plugins = { "dressing.nvim" } })
  --     return vim.ui.input(...)
  --   end
  -- end,
  -- opts = {
  --   select = { backend = { "builtin" } },
  --   input = {
  --     -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
  --     prefer_width = vim.o.columns,
  --     width = nil,
  --     border = "rounded",
  --     -- min_width and max_width can be a list of mixed types.
  --     -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
  --     max_width = { 140, 0.9 },
  --     min_width = { 20, 0.2 },
  --   },
  -- },
}
