if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "mrvaita/sqlrun.nvim",
    cmd = { "SQLRun" },
    ft = { "sql" },
    opts = {},
  },
}
