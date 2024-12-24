if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "dnlhc/glance.nvim",
    -- lazy = true,
    event = "LspAttach",
    config = function()
      local glance = require("glance")

      glance.setup({
        height = 16,
        detached = function(win)
          return vim.api.nvim_win_get_width(win) < 80
        end,
        indent_lines = {
          enable = true,
          icon = " ",
        },
        theme = {
          enable = true,
        },
        folds = {
          folded = false,
        },
        border = {
          enable = true,
          top_char = vim.opt.fillchars:get().horiz,
          bottom_char = vim.opt.fillchars:get().horiz,
        },
        hooks = { -- if theere is 1 result, and in the same buffer, jump to it, else open glance win
          before_open = function(results, open, jump, method)
            local uri = vim.uri_from_bufnr(0)
            if #results == 1 then
              local target_uri = results[1].uri or results[1].targetUri

              if target_uri == uri then
                jump(results[1])
              else
                open(results)
              end
            else
              open(results)
            end
          end,
        },
      })
      ---@diagnostic disable: duplicate-set-field
      -- Override LSP handler functions
      -- stylua: ignore start
      vim.lsp.buf.references = function() glance.open('references') end
      vim.lsp.buf.definition = function() glance.open('definitions') end
      vim.lsp.buf.type_definition = function() glance.open('type_definitions') end
      vim.lsp.buf.implementations = function() glance.open('implementations') end

      -- stylua: ignore end
      ---@diagnostic enable: duplicate-set-field
    end,
  },
}
