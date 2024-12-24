if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "TodoTrouble", "TodoQuickFix" },
    opts = {
      keywords = {
        -- stylua: ignore start 
        FIX  = { icon = " ", color = "error",   alt = { "FIXME",     "BUG",    "FIXIT",    "ISSUE" }, },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING",     "XXX" } },
        PERF = { icon = "󰓅 ", alt   = { "OPTIM", "PERFORMANCE",         "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
        TEST = { icon = "󰙨",  color = "test",   alt  = { "TESTING",  "PASSED", "FAILED" }, },
        DEL  = { icon = " ", color = "error",   alt = { "DELETE" } },
        SUG  = { icon = "󰭙 ", color = "info",    alt = { "SUGGEST" } },
        SCHE = { icon = "󱫌 ", color = "sche",    alt = { "SCHEDULE", "SCHED" } },
        NEXT = { icon = " ", color = "sche",    alt = { "NEXT",     "NXT" } },
        PREV = { icon = " ", color = "hint" },
        -- stylua: ignore end
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
        sche = { "DiagnosticWarn", "WarningMsg", "#fca5a5" },
      },
    },
  },
}
