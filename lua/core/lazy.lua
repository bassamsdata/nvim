if vim.env.NVIM_NOTHIRDPARTY then
  return
end
-- install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  print("Initializing lazy.nvim for the first time...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- load plugins from specifications (The leader key must be set before this)
require("lazy").setup({ { import = "plugins" }, { import = "plugins.lsp" } }, {
  install = {
    -- Do not automatically install on startup.
    missing = true,
    colorscheme = {},
  },
  -- I like to play with my configs alot so less clutter please.
  change_detection = { notify = false },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- Stuff I don't use.
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        -- "rplugin", -- this is for remote plugins
        "tarPlugin",
        -- "tohtml",
        "tutor",
        "zipPlugin",
        "health",
        -- "man",
        -- "matchit",
        -- "matchparen",
      },
    },
  },
  dev = {
    -- directory where you store your local plugin projects
    path = "~/repos",
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = { "bassamsdata" },
    fallback = false, -- Fallback to git when local plugin doesn't exist
  },
  ui = {
    border = "rounded",
    -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
    backdrop = 100,
    title = "Lazy", ---@type string only works when border is not "none"
    title_pos = "left", ---@type "center" | "left" | "right"
  },
})
