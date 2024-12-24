if vim.env.NVIM_TESTING then
  return {}
end
return {
  -- {
  --   "cdmill/focus.nvim",
  --   cmd = { "Focus", "Zen", "Narrow" },
  --   opts = {
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  {
    --   "folke/zen-mode.nvim",
    --   cond = not vim.g.vscode,
    --   keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "ZenMode" } },
    --   opts = {
    --     window = {
    --       width = 0.79,
    --       options = {
    --         number = false,
    --         relativenumber = false,
    --         list = false,
    --         scrolloff = 99,
    --       },
    --     },
    --     plugins = {
    --       twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
    --       gitsigns = { enabled = false },
    --       wezterm = {
    --         enabled = false,
    --         font = "+4", -- (10% increase per step)
    --       },
    --       options = {
    --         enabled = true,
    --         ruler = false, -- disables the ruler text in the cmd line area
    --         showcmd = false, -- disables the command in the last line of the screen
    --         laststatus = 0,
    --       },
    --     },
    --     on_open = function()
    --       -- vim.cmd("IBLDisable")
    --
    --       vim.opt.listchars:append({
    --         trail = "·",
    --         -- tab = "│ ",
    --       })
    --       vim.opt.cmdheight = 0
    --       vim.opt.sidescrolloff = 0
    --     end,
    --     on_close = function()
    --       -- vim.cmd("IBLEnable")
    --       vim.opt.listchars:append({
    --         trail = "·",
    --         -- leadmultispace = "│ ", -- this caused problems
    --         -- multispace  = "│ ",
    --         tab = "│ ",
    --         -- space = "⋅",
    --       })
    --       vim.opt.sidescrolloff = 4
    --       vim.opt.cmdheight = 1
    --     end,
    --   },
  },
}
