if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "NvChad/nvterm",
    keys = { { "<M-t>" }, { "<M-v>" }, { "<M-f>" } },
    config = function()
      -- require("core.keymaps").term()
      require("nvterm").setup({
        terminals = {
          type_opts = {
            float = {
              relative = "editor",
              width = 0.8,
              height = 0.6,
              border = "single",
            },
          },
        },
      })
    end,
  },
}
