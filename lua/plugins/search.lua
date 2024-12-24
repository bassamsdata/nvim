if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    config = function()
      require("grug-far").setup({})
    end,
  },
}
