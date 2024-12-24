return {
  "bassamsdata/vite.nvim",
  -- lazy = true,
  event = "VeryLazy",
  dev = true,
  config = function()
    require("vite").setup({
      keys = { "a", "s", "d", "f", "g" },
      select_key = "<CR>",
      delete_key = "D",
    })
    -- Set up your preferred keymap to trigger the switcher
  end,
  keys = {
    {
      "<leader>b",
      function()
        require("vite").show()
      end,
      desc = "Show buffer switcher",
    },
  },
}
