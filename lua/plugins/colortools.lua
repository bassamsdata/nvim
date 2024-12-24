-- if vim.env.NVIM_TESTING then
--   return {}
-- end
return {
  { "rktjmp/lush.nvim", cmd = { "LushRunTutorial", "LushImport" } },
  { "echasnovski/mini.base16", event = "ColorScheme" },
  { "nvchad/volt", lazy = true },
  { "nvchad/minty", lazy = true, cmd = { "Shades", "Huefy" } },
  {
    "brenoprata10/nvim-highlight-colors",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "BufReadPost",
    opts = {
      render = "virtual",
      virtual_symbol = "",
    },
  },
}
