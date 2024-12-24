if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "epwalsh/obsidian.nvim",
    -- dev = true,
    cmd = {
      "ObsidianSearch",
      "ObsidianNew",
      "ObsidianQuickSwitch",
      "ObsidianTemplate",
    },
    config = function()
      local obsidian = require("obsidian")
      obsidian.setup({
        workspaces = {
          {
            name = "personal",
            path = "~/Sync/MarkdownSync",
          },
          {
            name = "bulk",
            path = "~/Sync/Bulk",
            -- Optional, override certain settings.
            overrides = {
              notes_subdir = "notes",
            },
          },
        },
        notes_subdir = "Notes",
        new_notes_location = "notes_subdir",
        daily_notes = {
          folder = "Notes/dailies",
        },
        use_advanced_uri = true,
        mappings = {},
        completion = {
          nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
          cmp_nvim_lsp = true,
        },
        templates = {
          subdir = "my-templates-folder",
          date_format = "%Y-%m-%d-%a",
          time_format = "%H:%M",
        },
        finder = "mini.pick",
        ui = {
          enable = true, -- set to false to disable all additional syntax features
          update_debounce = 200, -- update delay after a text change (in milliseconds)
          -- Define how various check-boxes are displayed
          checkboxes = {
            -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          },
          external_link_icon = {
            char = "",
            hl_group = "ObsidianExtLinkIcon",
          },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          hl_groups = {
            -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
            ObsidianTodo = { bold = true, fg = "#f78c6c" },
            ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, fg = "#89ddff" },
            ObsidianHighlightText = { bg = "#75662e" },
          },
        },
      })
    end,
  },
}
