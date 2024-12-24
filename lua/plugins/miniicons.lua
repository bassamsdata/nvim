if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "echasnovski/mini.icons",
    config = function()
      require("mini.icons").setup({
        lsp = {
          -- stylua: ignore start 
          ellipsis_char = { glyph = "… ", hl = "MiniIconsRed" },
          copilot       = { glyph = "",  hl = "MiniIconsOrange" },
          supermaven    = { glyph = "",  hl = "MiniIconsYellow" },
          codeium       = { glyph = "",  hl = "MiniIconsGreen" },
          otter         = { glyph = " ", hl = "MiniIconsCyan" },
          cody          = { glyph = "",  hl = "MiniIconsAzure" },
          cmp_r         = { glyph = "󰟔 ", hl = "MiniIconsBlue" },
          ["function"]  = { glyph = "",  hl = "MiniIconsAzure" },
          error         = { glyph = " ", hl = "MiniIconsRed" },
          warn          = { glyph = " ", hl = "MiniIconsOrange" },
          info          = { glyph = "󰙎 ", hl = "MiniIconsYellow" },
          hint          = { glyph = " ", hl = "MiniIconsGreen" },
          anthropic     = { glyph = " ", hl = "MiniIconsOrange" },
          openai        = { glyph = "󰊲 ", hl = "MiniIconsGrey" },
          groq          = { glyph = " ", hl = "MiniIconsRed" },
          gemini        = { glyph = "󰫤 ", hl = "MiniIconsBlue" },
          xai           = { glyph = " ", hl = "MiniIconsAzure" },
          huggingface   = { glyph = " ", hl = "MiniIconsYellow" },
          -- stylua: ignore end
        },
        -- file = {
        --   todo = { glyph = " ", hl = "MiniIconsRed" },
        -- },
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("MiniIconsHi", { clear = true }),
        callback = function()
          require("utils.hi").blend_highlight_groups({
            "MiniIconsAzure",
            "MiniIconsCyan",
            "MiniIconsBlue",
            "MiniIconsGreen",
          }, "StatusLine", "bg", 0.6)
        end,
      })
      require("utils.hi").blend_highlight_groups(
        { "MiniIconsAzure", "MiniIconsCyan", "MiniIconsBlue", "MiniIconsGreen" },
        "StatusLine",
        "bg",
        0.6
      )
    end,
    lazy = true,
    init = function()
      package.preload["nvim-web-devicons"] = function()
        -- needed since it will be false when loading and mini will fail
        -- package.loaded["nvim-web-devicons"] = {}
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
