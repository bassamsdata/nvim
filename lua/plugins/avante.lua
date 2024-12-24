if vim.env.NVIM_TESTING then
  return {}
end
local avantWdith = vim.g.neovide and 41 or 41
-- return {}
return {
  {
    "yetone/avante.nvim",
    build = "make",
    -- commit = "054695c",
    -- pin = true,
    dependencies = {
      "echasnovski/mini.icons",
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "MeanderingProgrammer/markdown.nvim",
      -- "stevearc/dressing.nvim",
    },
    keys = {
      -- stylua: ignore start
      { "<leader>aa", function() require("avante.api").ask() end, desc = "avante: ask", mode = { "n", "v" } },
      { "<leader>ar", function() require("avante.api").refresh() end, desc = "avante: refresh" },
      { "<leader>ae", function() require("avante.api").edit() end, desc = "avante: edit", mode = "v" },
      -- stylua: ignore end
    },
    cmd = "AvanteAsk",
    opts = {
      debug = false,
      silent_warning = true,
      windows = {
        wrap_line = true, -- similar to vim.o.wrap
        width = avantWdith, -- default % based on available width
        sidebar_header = {
          align = "center", -- left, center, right for title
          rounded = false,
        },
      },
      provider = "mistral", -- "claude" or "openai" or "azure"
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20240620",
        temperature = 0,
        max_tokens = 4096,
      },
      gemini = {
        endpoint = "",
        type = "gemini",
        model = "gemini-1.5-pro",
        options = {},
      },
      vendors = {
        mistral = {
          endpoint = "https://codestral.mistral.ai/v1/chat/completions",
          model = "codestral-latest",
          api_key_name = "CODESTRAL_API_KEY",
          parse_curl_args = function(opts, code_opts)
            local api_key = os.getenv(opts.api_key_name)
            local Llm = require("avante.providers")

            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. api_key,
              },
              body = {
                model = opts.model,
                messages = Llm.openai.parse_message(code_opts),
                temperature = 0.7,
                max_tokens = 8192,
                stream = true,
                safe_prompt = false,
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            local Llm = require("avante.providers")
            Llm.openai.parse_response(data_stream, event_state, opts)
          end,
        },
        groq = {
          endpoint = "https://api.groq.com/openai/v1/chat/completions",
          model = "llama-3.1-70b-versatile",
          api_key_name = "GROQ_API_KEY",
          parse_curl_args = function(opts, code_opts)
            local api_key = os.getenv(opts.api_key_name)
            local Llm = require("avante.providers")

            return {
              url = opts.endpoint,
              headers = {
                -- ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. api_key,
              },
              body = {
                model = opts.model,
                messages = Llm.openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
                temperature = 0,
                max_tokens = 4096,
                stream = true, -- this will be set by default.
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            local Llm = require("avante.providers")
            Llm.openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    },
  },
}
