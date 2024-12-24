-- great plugin to add noral mode functionalit to the cmdline
return {
  {
    "smilhey/ed-cmd.nvim",
    lazy = true,
    config = function()
      require("ed-cmd").setup({
        -- Those are the default options, you can just call setup({}) if you don't want to change the defaults
        cmdline = {
          keymaps = {
            edit = "<ESC>",
            execute = "<CR>",
            close = { "q", "<esc>" },
          },
        },
        -- You enter normal mode in the cmdline with edit, execute a
        -- command from normal mode with execute and close the cmdline in
        -- normal mode with close
        pumenu = { max_items = 100 },
      })
    end,
  },
}
