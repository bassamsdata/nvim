if vim.env.NVIM_TESTING then
  return {}
end
local filenames_to_exclude = { "foo.sh" }
local filetypes_to_exclude = { "sh", "env" }

local function shouldExclude()
  local filename = vim.fn.expand("%:t")
  local filetype = vim.bo.filetype

  for _, fname in ipairs(filenames_to_exclude) do
    if string.match(filename, fname) then
      return true
    end
  end

  for _, ftype in ipairs(filetypes_to_exclude) do
    if filetype == ftype then
      return true
    end
  end

  return false
end
return {
  {
    "Exafunction/codeium.nvim",
    commit = "aa06fa2",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = { "InsertEnter" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- cmd = "Codeium",
    build = ":Codeium Auth",
    opts = {
      enable_chat = false,
      enable_local_search = true,
      enable_index_service = true,
    },
  },

  -- {
  --   "sourcegraph/sg.nvim",
  --   enabled = function()
  --     return not vim.b.bigfile
  --   end,
  --   event = { "InsertEnter" },
  --   cmd = "CodyToggle",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   opts = { enable_cody = true },
  -- },
  --
  -- add this to the file where you setup your other plugins:
  {
    "monkoose/neocodeium",
    lazy = true,
    cond = not vim.g.vscode,
    -- event = "BufReadPost",
    config = function()
      local neocodeium = require("neocodeium")
      local map = vim.keymap.set
      neocodeium.setup({
        silent = true,
        filetypes = {
          sh = false,
          env = false,
          DressingInput = false,
          floatCustom = false,
        },
      })

      -- map("i", "<C-y>", neocodeium.accept)
      map("i", "<C-e>", neocodeium.accept)
      map("i", "<M-l>", neocodeium.accept_line) -- TODO: M-l M-h are for left and right
      map("i", "<M-w>", neocodeium.accept_word)
      map("i", "<M-c>", neocodeium.clear)
      map("i", "<M-]>", neocodeium.cycle_or_complete)
      map("i", "<M-[>", function()
        neocodeium.cycle_or_complete(-1)
      end)
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    cond = not vim.g.vscode,
    cmd = { "SupermavenToggle", "SupermavenStart", "SupermavenStatus" },
    config = function()
      require("supermaven-nvim").setup({
        condition = function()
          return shouldExclude()
        end,
        -- keymaps = {
        --   accept_suggestion = "<C-y>",
        --   clear_suggestion = "<C-]>",
        --   accept_word = "<C-i>",
        -- },
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      })
    end,
  },
}
