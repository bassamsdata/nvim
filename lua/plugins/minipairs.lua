if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "echasnovski/mini.surround",
    keys = { "gsa", "gsr", "gsd", { "gs", mode = "v" } },
    config = function()
      local MiniSurround = require("mini.surround")
      MiniSurround.setup({
        mappings = {
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      })
      -- I don't why but clue picked up long desc, so this is just for aesthtics
      if pcall(require, "mini.surround") then
        require("mini.clue").set_mapping_desc("n", "gsn", "Update n# lines")
      end
    end,
  },
}
