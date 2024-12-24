if vim.env.NVIM_TESTING then
  return {}
end
return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  -- init = function(plugin)
  --   -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
  --   -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
  --   -- no longer trigger the **nvim-treesitter** module to be loaded in time.
  --   -- Luckily, the only things that those plugins need are the custom queries, which we make available
  --   -- during startup.
  --   require("lazy.core.loader").add_to_rtp(plugin)
  --   require("nvim-treesitter.query_predicates")
  -- end,
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  keys = {
    { "<c-space>", desc = "Increment Selection" },
    { "<bs>", desc = "Decrement Selection", mode = "x" },
  },
  opts_extend = { "ensure_installed" },
  opts = {
    -- Thanks to @bekaboo for the highlight enable function regarding bigfiles, check the README for link to the repo
    highlight = {
      enable = not vim.g.vscode,
      disable = function(ft, buf)
        return ft == "latex"
          or vim.b[buf].bigfile == true
          or vim.fn.win_gettype() == "command"
      end,
      -- Enable additional vim regex highlighting
      -- in markdown files to get vimtex math conceal
      -- additional_vim_regex_highlighting = { "markdown" },
    },
    indent = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "jsdoc",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
      "r",
      "rnoweb",
      "go",
      "v",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    textobjects = {
      move = {
        enable = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
