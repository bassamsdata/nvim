if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = {
      { "<leader>ut", "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },
}
