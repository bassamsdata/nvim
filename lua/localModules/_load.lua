---@diagnostic disable: missing-parameter
require("localModules.nvterminal")
require("localModules.floating")
require("localModules.runner").setup()
require("localModules.trying")
require("localModules.symbols_easy")
vim.keymap.set("n", "<leader>sa", function()
  require("localModules.magnet").jump()
end, { desc = "Magnet", noremap = true, silent = true })
require("localModules.scratch").setup()
require("localModules.csv_freeze_row").setup()
-- Create a keymap to open it
vim.keymap.set("n", "<leader>L", function()
  require("localModules.scratch").open()
end, { desc = "Open Python Scratch" })

vim.api.nvim_create_autocmd("LspAttach", {
  once = true,
  callback = function()
    vim.keymap.set("n", "<Leader>ci", function()
      require("localModules.inlayhints-insert").fill()
    end, { desc = "Insert the inlay-hint under cursor into the buffer." })
  end,
})

local selecta = require("localModules.selecta.selecta")

-- Test data with different types of items
local test_items = {
  -- Items with icons
  {
    text = "file1.lua",
    value = "path/to/file1.lua",
    icon = "󰈙",
    kind = "File",
  },
  {
    text = "MyClass",
    value = "class_definition",
    icon = "󰌗",
    kind = "Class",
  },
  {
    text = "setup_function",
    value = "func_definition",
    icon = "󰊕",
    kind = "Function",
  },
  {
    text = "CONSTANT_VALUE",
    value = "constant",
    icon = "󰏿",
    kind = "Constant",
  },
  -- More items to test scrolling and matching
  {
    text = "initialize_module",
    value = "init",
    icon = "󰆧",
    kind = "Method",
  },
  {
    text = "config_options",
    value = "options",
    icon = "󰒓",
    kind = "Variable",
  },
}

-- Test with icon mode
local function test_icon_mode()
  print("Testing icon mode...")
  -- Verify debug setting

  selecta.pick(test_items, {
    title = "Icon Mode Test",
    display = {
      mode = "icon",
      padding = 1,
    },
    window = {
      border = "rounded",
      title_prefix = "󰍉 ",
      auto_size = true,
      min_width = 40,
    },
    on_select = function(item)
      print("Selected:", item.text, "Value:", item.value)
    end,
    on_cancel = function()
      print("Selection cancelled")
    end,
    on_move = function(item)
      print("Moved to:", item.text)
    end,
  })
end

-- Test with text mode
local function test_text_mode()
  print("Testing text mode...")
  selecta.pick(test_items, {
    title = "Text Mode Test",
    display = {
      mode = "text",
      padding = 2,
      prefix_width = nil, -- This will be calculated automatically
    },
    window = {
      border = "rounded",
      title_prefix = "Select > ",
      auto_size = true,
      min_width = 40,
    },
    on_select = function(item)
      print("Selected:", item.text, "Value:", item.value)
    end,
    on_cancel = function()
      print("Selection cancelled")
    end,
    on_move = function(item)
      print("Moved to:", item.text)
    end,
  })
end

-- Optional: Add keymaps for testing
vim.keymap.set("n", "<leader>si", test_icon_mode, { desc = "Test Selecta Icon Mode" })
vim.keymap.set("n", "<leader>st", test_text_mode, { desc = "Test Selecta Text Mode" })

-- First, set up selecta with your preferred defaults
require("localModules.selecta.selecta").setup({
  window = {
    border = "rounded",
    auto_size = true,
    title_prefix = "󰍉 ",
  },
})

-- Then set up magnet with your preferences
require("localModules.selecta.magnet_enhanced").setup({
  -- Optional: Override default included symbol kinds per filetype
  includeKinds = {
    -- Default for all filetypes
    default = { "Function", "Method", "Class", "Module" },
    -- Filetype specific
    python = { "Function", "Class", "Method" },
    lua = { "Function", "Table", "Module" },
  },

  -- Optional: Patterns to exclude from results
  excludeResults = {
    default = { "^_" }, -- ignore private symbols
    lua = {
      "^vim%.", -- ignore vim.* functions
      "%.%.%. :", -- ignore vim.iter functions
      ":gsub", -- ignore string.gsub
      "^callback$", -- ignore nvim autocmds
      "^filter$",
    },
  },

  -- Window configuration
  window = {
    auto_size = true,
    border = "rounded",
  },

  -- Optional: Enable debug logging
  debug = false,
})

-- Optional: Set up default keymaps
-- This will create <leader>ss mapping
require("localModules.selecta.magnet_enhanced").setup_keymaps()

-- Or set your own custom keymaps
vim.keymap.set("n", "<leader>ss", require("localModules.selecta.magnet_enhanced").jump, {
  desc = "Jump to symbol",
  silent = true,
})
local my_fzf = require("localModules.my_fzf.my-fzf")

local items = {
  "Item 1",
  "Item 2",
  "Item 3",
  "Another item",
  "Yet another item",
}

vim.keymap.set("n", "<leader>sf", function()
  my_fzf.open_fzf(items, {
    prompt = "Select an item: ",
    width = 50,
    height = 12,
    on_choose = function(chosen_item)
      print("You chose:", chosen_item)
    end,
    on_close = function()
      print("FZF closed")
    end,
  })
end, { desc = "Open fzf" })

vim.keymap.set("n", "<leader>sl", function()
  my_fzf.open_fzf({ "one", "two", "three" }, { prompt = "numbers: " })
end, { desc = "Open fzf with numbers" })
-- -- You can also create more specific mappings
-- local magnet = require('localModules.selecta.magnet_enhanced')
-- vim.keymap.set('n', '<leader>sf', magnet.jump, { desc = "Jump to symbol" })
-- Require and setup the module
-- local frecency_switcher = require("localModules.frecency_switcher")
-- frecency_switcher.setup({
--
--   -- Optional: customize the keys
--   keys =s { "a", "s", "d", "f", "g" },
--   -- Optional: window customization
--   window = {
--     width = 60,
--     height = 10,
--     border = "rounded",
--     highlight = "FloatBorder",
--   },
-- })
--
-- -- Set up your preferred keymap to trigger the switcher
-- vim.keymap.set(
--   "n",
--   "<Leader>b",
--   frecency_switcher.show_switcher,
--   { noremap = true, silent = true }
-- )
