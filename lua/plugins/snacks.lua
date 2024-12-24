if vim.env.NVIM_TESTING then
  return {}
end
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = false },
    notifier = {
      enabled = false,
      timeout = 3000,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    input = { enabled = true },
  },
  keys = {
    -- stylua: ignore start
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>gb",  function() Snacks.git.blame_line() end,          desc = "Git Blame Line",               },
    { "<leader>gB",  function() Snacks.gitbrowse() end,               desc = "Git Browse",                   },
    { "<leader>glf", function() Snacks.lazygit.log_file() end,        desc = "Lazygit Current File History", },
    { "<leader>gfl", function() Snacks.lazygit.log() end,             desc = "Lazygit Log (cwd)",            },
    { "<leader>cR",  function() Snacks.rename.rename_file() end,      desc = "Rename File",                  },
    { "<c-/>",       function() Snacks.terminal() end,                desc = "Toggle Terminal",              },
    { "]]",          function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",               },
    { "[[",          function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",               },
    { "<leader>.",   function() Snacks.scratch() end,                 desc = "Toggle Scratch Buffer",        },
    { "<leader>S",   function() Snacks.scratch.select() end,          desc = "Select Scratch Buffer",        },
    -- stylua: ignore end
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        if not (vim.g.neovide or vim.g.gui_vimr) then
          Snacks.scroll.enable()
        else
          Snacks.scroll.disable()
        end
        -- Create some toggle mappings
        -- stylua: ignore start
        Snacks.toggle.option("spell",           { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap",            { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }) :map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
        -- stylua: ignore end
        Snacks.toggle
          .option(
            "conceallevel",
            { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }
          )
          :map("<leader>uc")
        Snacks.toggle
          .option("background", { off = "light", on = "dark", name = "Dark Background" })
          :map("<leader>ub")
      end,
    })
  end,
}
