if vim.env.NVIM_TESTING then
  return {}
end
local M = {
  "williamboman/mason-lspconfig.nvim",
  -- event = { "BufReadPost", "BufNewFile" },
  enabled = function()
    return not vim.b.bigfile
  end,
  cmd = { "MasonInstall", "MasonUpdate" },
  dependencies = {
    "williamboman/mason.nvim",
  },
}

function M.config()
  local servers = {
    "r_language_server",
    "basedpyright",
    "lua_ls",
    "html",
    "cssls",
    "marksman",
    "taplo",
    "v_analyzer",
    "gopls",
  }
  require("mason").setup({
    ensure_installed = { "goimports", "gofumpt", "gomodifytags" },
    ui = {
      border = "rounded",
      width = 0.7,
      height = 0.8,
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })

  require("mason-lspconfig").setup({
    ensure_installed = servers,
  })
end

return M
