if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "stevearc/quicker.nvim",
    ft = { "qf" },
    opts = {
      borders = {
        -- Thinner separator.
        vert = "│",
      },
    },
    keys = {
      {
        "<leader>xd",
        function()
          local quicker = require("quicker")

          if quicker.is_open() then
            quicker.close()
          else
            vim.diagnostic.setqflist()
          end
        end,
        desc = "Toggle diagnostics",
      },
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse context",
      },
    },
  },
}
