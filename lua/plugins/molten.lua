if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "benlubas/molten-nvim",
    ft = { "python", "r", "quarto" },
    event = "BufEnter *.ipynb",
    build = ":UpdateRemotePlugins",
    init = function()
      -- vim.g.molten_show_mimetype_debug = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_show_more = true
      -- vim.g.molten_image_provider = "wezterm"
      -- vim.g.molten_output_win_border = { "", "━", "", "" }
      -- vim.g.molten_output_win_max_height = 14
      -- vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_text_output = true
      -- vim.g.molten_use_border_highlights = true
      -- vim.g.molten_virt_lines_off_by_0 = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_width = 120
      -- vim.g.molten_tick_rate = 175
      vim.g.molten_auto_image_popup = true
      vim.g.molten_virt_text_max_lines = 16
      local autocmd = vim.api.nvim_create_autocmd
      local map = vim.keymap.set
      -- stylua: ignore start 
      map( "n", "<localleader>im", ":MoltenInit<CR>", { desc = "Initialize Molten", silent = true })
      map( "n", "<localleader>iir", function() vim.cmd("MoltenInit ir") end, { desc = "Initialize Molten", silent = true })
      map("n",  "<localleader>ir", function() vim.cmd("MoltenInit rust") end,
        { desc = "Initialize Molten for Rust", silent = true })
      -- stylua: ignore end
      map("n", "<localleader>ip", function()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv ~= nil then
          -- Check if venv is in .virtualenvs directory
          if string.match(venv, "/%.virtualenvs/") then
            venv = vim.fn.fnamemodify(venv, ":t")
          else
            -- Get parent directory of .venv
            venv = vim.fn.fnamemodify(venv, ":h:t")
          end
          vim.cmd(("MoltenInit %s"):format(venv))
        else
          vim.cmd("MoltenInit python3")
        end
      end, {
        desc = "Initialize Molten for python3",
        silent = true,
        noremap = true,
      })

      autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          -- quarto code runner mappings
          local r = require("quarto.runner")
          -- stylua: ignore start 
          map( "n", "<localleader>rc", r.run_cell,  { desc = "run cell",           silent = true })
          map( "n", "<localleader>ra", r.run_above, { desc = "run cell and above", silent = true })
          map( "n", "<localleader>rb", r.run_below, { desc = "run cell and below", silent = true })
          map( "n", "<localleader>ml", r.run_line,  { desc = "run line",           silent = true })
          map( "n", "<localleader>rA", r.run_all,   { desc = "run all cells",      silent = true })
          map("n",  "<localleader>RA", function() r.run_all(true) end,     { desc = "run all cells & languages", silent = true })
          -- setup some molten specific keybindings
          map( "n", "<localleader>ml", ":MoltenEvaluateLine<CR>",          { desc = "evalute line",              silent = true })
          map( "n", "<localleader>e",  ":MoltenEvaluateOperator<CR>",      { desc = "evaluate operator",         silent = true })
          map( "n", "<localleader>rr", ":MoltenReevaluateCell<CR>",        { desc = "re-eval cell",              silent = true })
          map( "v", "<localleader>mv",  ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection",  silent = true })
          map( "n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window",        silent = true })
          map( "n", "<localleader>oh", ":MoltenHideOutput<CR>",            { desc = "close output window",       silent = true })
          map( "n", "<localleader>md", ":MoltenDelete<CR>",                { desc = "delete Molten cell",        silent = true })
          local open = false
          map("n", "<localleader>ot", function() open = not open vim.fn.MoltenUpdateOption("auto_open_output", open) end) -- stylua: ignore end
          -- if we're in a python file, change the configuration a little
          if vim.bo.filetype == "python" then
            vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
          end
          -- Map <CR> to MoltenEvaluateOperator with motion support
          map('n', '<CR>', function()
            -- Start the MoltenEvaluateOperator command and simulate the 'ip' motion
            vim.cmd('MoltenEvaluateOperator')
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("ik", true, true, true))
          end, { noremap = true, silent = true })
        end,
      })
    end,
  },
}
