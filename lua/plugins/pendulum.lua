if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "ptdewey/pendulum-nvim",
    event = "VeryLazy",
    dev = false,
    opts = {
      gen_reports = true,
    },
    config = function(_, opts)
      require("pendulum").setup(opts)
    end,
  },
}
