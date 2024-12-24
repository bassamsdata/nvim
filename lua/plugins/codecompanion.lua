-- if vim.env.NVIM_TESTING then
--   return {}
-- end
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    -- event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    -- "bassamsdata/codecompanion.nvim",
    -- branch = "huggingface",
    -- dev = true,
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCmd",
    },
    dependencies = {
      "codecompanion-save",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "hrsh7th/nvim-cmp" },
      -- "stevearc/dressing.nvim",
      "echasnovski/mini.pick",
    },
    config = function()
      local api_keys = {}
      local _, _ = pcall(require, "localModules.codecompanion_save")

      local get_api_key = function(name)
        if not api_keys[name] then
          api_keys[name] = vim.fn.inputsecret(
            string.format(
              "Please perform KeepassXC autotype for %s API key:",
              name:upper()
            )
          )
        end
        return api_keys[name]
      end

      -- stylua: ignore start 
      local openai_api_key = function() return get_api_key("openai") end
      local xai_api_key    = function() return get_api_key("xai") end
      local claude_api_key = function() return get_api_key("claude") end
      local groq_api_key   = function() return get_api_key("groq") end
      local huggingface_api_key = function() return get_api_key("huggingface") end
      local gemini_api_key = function() return get_api_key("gemini") end
      -- stylua: ignore end

      local hi = vim.api.nvim_set_hl
      hi(0, "CodeCompanionChatVariable", { link = "TermCursor" })
      hi(0, "CodeCompanionChatTool", { link = "IncSearch" })
      require("codecompanion").setup({
        -- debug = true,
        -- log_level = "DEBUG",
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.5-sonnet",
                },
              },
            })
          end,
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = openai_api_key,
              },
              schema = {
                model = {
                  default = "gpt-4o-2024-08-06",
                  choices = {
                    "gpt-4o-2024-08-06",
                    "gpt-4o-mini",
                    "o1-preview",
                    "o1-mini",
                  },
                },
              },
            })
          end,
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = claude_api_key,
              },
              schema = {
                model = {
                  default = "claude-3-5-sonnet-20241022",
                  choices = {
                    "claude-3-5-sonnet-20241022",
                    "claude-3-5-haiku-20241022",
                    "claude-3-haiku-20240307",
                  },
                },
              },
            })
          end,
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = gemini_api_key,
              },
              schema = {
                model = {
                  default = "gemini-2.0-flash-exp",
                  choices = {
                    "gemini-2.0-flash-exp",
                    "gemini-1.5-flash",
                    "gemini-1.5-pro",
                    "gemini-1.0-pro",
                  },
                },
              },
            })
          end,
          xai = function()
            return require("codecompanion.adapters").extend("xai", {
              env = {
                api_key = xai_api_key,
              },
              schema = {
                model = {
                  default = "grok-beta",
                  choices = {
                    "grok-beta",
                    "trigger the event for my statusline :)",
                  },
                },
              },
            })
          end,
          huggingface = function()
            return require("codecompanion.adapters").extend("huggingface", {
              env = {
                api_key = huggingface_api_key,
              },
              -- opts = { stream = false },
              schema = {
                model = {
                  default = "Qwen/Qwen2.5-Coder-32B-Instruct",
                  choices = {
                    "meta-llama/Meta-Llama-3.1-8B-Instruct",
                    "Qwen/Qwen2.5-72B-Instruct",
                    "Qwen/Qwen2.5-Coder-32B-Instruct",
                    "meta-llama/Llama-3.2-1B-Instruct",
                    "mistralai/Mistral-Nemo-Instruct-2407",
                    "microsoft/Phi-3-mini-4k-instruct",
                    "black-forest-labs/FLUX.1-dev",
                    "stabilityai/stable-diffusion-3-medium-diffusers:",
                  },
                },
              },
              ["X-Use-Cache"] = false,
            })
          end,
          groq = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = groq_api_key,
              },
              name = "groq",
              url = "https://api.groq.com/openai/v1/chat/completions",
              schema = {
                model = {
                  default = "llama-3.2-90b-vision-preview",
                  choices = {
                    "llama-3.2-90b-vision-preview",
                    "llama-3.1-70b-specdec",
                    "mixtral-8x7b-32768", -- 32K token context
                    "distil-whisper-large-v3-en", -- 25MB speech input
                    "gemma2-9b-it", -- 8K context
                    "llama-3.2-11b-vision-preview", -- 128K limited to 8K
                    "llama-3.2-90b-vision-preview", -- 128K limited to 8K
                    "whisper-\alarge-v3", -- 132K context
                  },
                },
              },
              max_tokens = {
                default = 8192,
              },
              temperature = {
                default = 1,
              },
              handlers = {
                form_messages = function(self, messages)
                  for i, msg in ipairs(messages) do
                    -- Remove 'id' and 'opts' properties from all messages
                    msg.id = nil
                    msg.opts = nil

                    -- Ensure 'name' is a string if present, otherwise remove it
                    if msg.name then
                      msg.name = tostring(msg.name)
                    else
                      msg.name = nil
                    end

                    -- Ensure only supported properties are present
                    local supported_props = { role = true, content = true, name = true }
                    for prop in pairs(msg) do
                      if not supported_props[prop] then
                        msg[prop] = nil
                      end
                    end
                  end
                  return { messages = messages }
                end,
              },
            })
          end,
        },
        strategies = {
          cmd = {
            adapter = "openai",
          },
          chat = {
            roles = {
              llm = "CodeComanion",
              user = "Me", -- The markdown header for your questions
            },
            adapter = "anthropic",
            slash_commands = {
              ["buffer"] = {
                opts = {
                  contains_code = true,
                  provider = "mini_pick",
                },
              },
              ["file"] = {
                opts = {
                  contains_code = true,
                  max_lines = 1000,
                  provider = "mini_pick",
                },
              },
              ["help"] = {
                opts = {
                  contains_code = false,
                  provider = "mini_pick",
                },
              },
            },
            keymaps = {
              codeblock = {
                modes = {
                  n = "gi",
                },
                index = 6,
                callback = "keymaps.codeblock",
                description = "Insert Codeblock",
              },
              regenerate = {
                modes = {
                  n = "grR",
                },
                description = "Regenerate Code",
              },
            },
          },
          inline = {
            adapter = "anthropic",
          },
          agent = {
            adapter = "anthropic",
          },
        },
        display = {
          chat = {
            show_settings = false,
            show_token_count = true, -- Show the token count for each response?

            ---@param tokens number
            token_count = function(tokens, adapter) -- The function to display the token count
              return " (" .. tokens .. " tokens)"
            end,
            window = {
              opts = {
                number = false,
                relativenumber = false,
              },
            },
          },
          inline = {
            -- If the inline prompt creates a new buffer, how should we display this?
            -- layout = "buffer", -- vertical|horizontal|buffer
          },
          diff = {
            -- enabled = true,
            provider = "mini_diff", -- default|mini_diff
          },
          action_palette = {
            -- provider = "mini_pick",
          },
        },

        prompt_library = {
          ["Your_New_Prompt"] = {
            strategy = "chat",
            description = "Your Special New Prompt",
            opts = {
              ignore_system_prompt = true,
            },
            -- Your prompts here
          },
          ["Docstring"] = {
            strategy = "inline",
            description = "Generate docstring for this function",
            opts = {
              modes = { "v" },
              short_name = "docstring",
              auto_submit = true,
              stop_context_insertion = true,
              user_prompt = false,
            },
            prompts = {
              {
                role = "system",
                content = function(context)
                  return "I want you to act as a senior "
                    .. context.filetype
                    .. " developer. I will send you a function and I want you to generate the docstrings for the function using the numpy format. Generate only the docstrings and nothing more. Put the generated docstring at the correct position in the code. Use tabs instead of spaces"
                end,
              },
              {
                role = "user",
                content = function(context)
                  local text = require("codecompanion.helpers.actions").get_code(
                    context.start_line,
                    context.end_line
                  )

                  return text
                end,
                opts = {
                  placement = "add",
                  contains_code = true,
                },
              },
            },
          },
          ["Code Expert"] = {
            strategy = "chat",
            description = "Get some special advice from an LLM",
            opts = {
              mapping = "<LocalLeader>ce",
              modes = { "v" },
              short_name = "expert",
              auto_submit = true,
              stop_context_insertion = true,
              user_prompt = true,
            },
            prompts = {
              {
                role = "system",
                content = function(context)
                  return "I want you to act as a senior "
                    .. context.filetype
                    .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
                end,
              },
              {
                role = "user",
                content = function(context)
                  local text = require("codecompanion.helpers.actions").get_code(
                    context.start_line,
                    context.end_line
                  )

                  return "I have the following code:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. text
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
        },

        opts = {
          log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
        },
      })
    end,
  },
}
