if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Gcd",
      "Gclog",
      "Gdiffsplit",
      "Gdrop",
      "Gedit",
      "Ggrep",
      "Git",
      "Glcd",
      "Glgrep",
      "Gllog",
      "Gpedit",
      "Gread",
      "Gsplit",
      "Gtabedit",
      "Gvdiffsplit",
      "Gvsplit",
      "Gwq",
      "Gwrite",
    },
    keys = { { "<Leader>gL", desc = "Open git log" } },
    event = { "BufNew", "BufWritePost", "BufReadPre" },
    dependencies = {
      -- Enable :GBrowse command in GitHub/Gitlab repos
      -- 'tpope/vim-rhubarb',
      -- 'shumphrey/fugitive-gitlab.vim',
    },
    config = function()
      -- Thanks for Bekaboo for this fugitive config:
      -- https://github.com/Bekaboo/dot/blob/master/.config/nvim/lua/configs/vim-fugitive.lua
      -- Override the default fugitive commands to save the previous buffer
      -- before opening the log window.
      vim.cmd([[
  command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete Gclog let g:fugitive_prevbuf=bufnr() | exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "c")
  command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete GcLog let g:fugitive_prevbuf=bufnr() | exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "c")
  command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete Gllog let g:fugitive_prevbuf=bufnr() | exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "l")
  command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete GlLog let g:fugitive_prevbuf=bufnr() | exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "l")
]])

      vim.keymap.set(
        "n",
        "<Leader>gfd",
        "<Cmd>Gdiff<CR>",
        { desc = "Git diff current file" }
      )
      vim.keymap.set(
        "n",
        "<Leader>gfD",
        "<Cmd>Git diff<CR>",
        { desc = "Git diff entire repo" }
      )
      vim.keymap.set(
        "n",
        "<Leader>gfB",
        "<Cmd>Git blame<CR>",
        { desc = "Git blame current file" }
      )
      vim.keymap.set(
        "n",
        "<Leader>gfl",
        "<Cmd>Git log --oneline --follow -- %<CR>",
        { desc = "Git log current file" }
      )
      vim.keymap.set(
        "n",
        "<Leader>gfL",
        "<Cmd>Git log --oneline --graph<CR>",
        { desc = "Git log entire repo" }
      )

      local groupid = vim.api.nvim_create_augroup("FugitiveSettings", {})
      vim.api.nvim_create_autocmd("User", {
        pattern = "FugitiveIndex",
        group = groupid,
        callback = function(info)
          vim.keymap.set(
            { "n", "x" },
            "S",
            "s",
            { buffer = info.buf, remap = true }
          )
          vim.keymap.set(
            { "n", "x" },
            "x",
            "X",
            { buffer = info.buf, remap = true }
          )
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "FugitiveObject",
        group = groupid,
        callback = function()
    -- stylua: ignore start
    local goto_next = [[<Cmd>silent! exe "if get(getloclist(0, {'winid':''}), 'winid', 0) | exe v:count.'lne' | else | exe v:count.'cn' | endif"<CR>]]
    local goto_prev = [[<Cmd>silent! exe "if get(getloclist(0, {'winid':''}), 'winid', 0) | exe v:count.'lpr' | else | exe v:count.'cp' | endif"<CR>]]
          -- stylua: ignore end
          vim.keymap.set("n", "<C-n>", goto_next, { buffer = true })
          vim.keymap.set("n", "<C-p>", goto_prev, { buffer = true })
          vim.keymap.set("n", "<C-j>", goto_next, { buffer = true })
          vim.keymap.set("n", "<C-k>", goto_prev, { buffer = true })
          vim.keymap.set("n", "<C-^>", function()
            if vim.g.fugitive_prevbuf then
              vim.cmd.cclose()
              vim.cmd.lclose()
              vim.cmd.buffer(vim.g.fugitive_prevbuf)
              vim.g.fugitive_prevbuf = nil
              vim.cmd.bw({ "#", bang = true, mods = { emsg_silent = true } })
            end
          end, { buffer = true })
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        desc = "Ensure that fugitive buffers are not listed and are wiped out after hidden.",
        group = groupid,
        pattern = "fugitive://*",
        callback = function(info)
          vim.bo[info.buf].buflisted = false
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Set buffer-local options for fugitive buffers.",
        group = groupid,
        pattern = "fugitive",
        callback = function()
          vim.opt_local.winbar = nil
          vim.opt_local.signcolumn = "no"
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Set buffer-local options for fugitive blame buffers.",
        group = groupid,
        pattern = "fugitiveblame",
        callback = function()
          local win_alt = vim.fn.win_getid(vim.fn.winnr("#"))
          vim.opt_local.winbar = vim.api.nvim_win_is_valid(win_alt)
              and vim.wo[win_alt].winbar ~= ""
              and " "
            or ""

          vim.opt_local.number = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.relativenumber = false
        end,
      })
    end,
  },
  {
    "NeogitOrg/neogit",
    -- branch = "nightly",
    cmd = "Neogit",
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" } },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      disable_signs = false,
      disable_context_highlighting = true,
      disable_commit_confirmation = false,
      kind = "vsplit",
      signs = {
        -- { CLOSED, OPENED }
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
      integrations = { diffview = true },
      commit_editor = {
        kind = "split",
      },
      commit_select_view = {
        kind = "tab",
      },
      commit_view = {
        kind = "split",
      },
      popup = {
        kind = "split",
      },
      status = {
        recent_commit_count = 20,
      },
      mappings = {
        -- modify status buffer mappings
        status = {
          -- Adds a mapping with "B" as key that does the "BranchPopup" command
          -- ["B"] = "BranchPopup",
          -- ["C"] = "CommitPopup",
          -- ["P"] = "PullPopup",
          -- ["S"] = "Stage",
          -- ["D"] = "Discard",
          -- Removes the default mapping of "s"
          -- ["s"] = "",
        },
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    enabled = function()
      return not vim.b.bigfile
    end,
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = {
      view = {
        use_icons = true,
        default = {
          -- layout = "diff2_horizontal",
          winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
        },
      },
    },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview [O]pen" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview [C]lose" },
    },
  },

  {
    "echasnovski/mini.diff",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    keys = {
      {
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("MiniDiffSigns", { clear = true }),
        callback = function()
          require("utils.hi").blend_highlight_groups(
            { "MiniDiffSignAdd", "MiniDiffSignChange", "MiniDiffSignDelete" },
            "Normal",
            "bg",
            0.5
          )
        end,
      })
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = {
            add = "▎",
            change = "▎",
            delete = "",
          },
        },
      })
      require("utils.hi").blend_highlight_groups(
        { "MiniDiffSignAdd", "MiniDiffSignChange", "MiniDiffSignDelete" },
        "Normal",
        "bg",
        0.5
      )
    end,
  },
}
