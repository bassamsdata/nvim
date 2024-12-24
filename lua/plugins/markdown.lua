if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "MeanderingProgrammer/markdown.nvim",
    opts = {
      file_types = { "markdown", "rmd", "quarto", "Avante", "codecompanion" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        -- icons = { "󰼏  ", "󰼐  ", "󰼑  ", "󰼒  ", "󰼓  ", "󰼔  " },
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = true,
        position = "inline",
        unchecked = { icon = "✘ " },
        checked = { icon = "✔ " },
        custom = { todo = { rendered = "◯ " } },
      },
    },
    ft = { "markdown", "rmd", "quarto", "Avante", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.keymap.set("n", "<leader>um", function()
        local enabled = require("render-markdown.state").enabled
        local m = require("render-markdown")
        if enabled then
          m.enable()
        else
          m.disable()
        end
      end, { desc = "Toggle markdown rendering" })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install && cd - && git restore .",
    ft = "markdown",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "light"
    end,
  },
}
