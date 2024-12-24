vim.opt.shortmess:append("I")
local intro = {}

---@param dict table
---@return table
intro.center = function(dict)
  local new_dict = {}
  for _, v in pairs(dict) do
    local padding = vim.fn.max(vim.fn.map(dict, "strwidth(v:val)"))
    local spacing = (" "):rep(math.floor((vim.o.columns - padding) / 2)) .. v
    table.insert(new_dict, spacing)
  end
  return new_dict
end

--> Simple dashboard
intro.splash_screen = vim.schedule_wrap(function()
  local xdg = vim.fn.fnamemodify(
    vim.fn.stdpath("config") --[[@as string]],
    ":h"
  ) .. "/"
  -- stylua: ignore start 
	local header = {
		"", "", "", "", "", "","", "", "", "", "", "",

		[[    ██████  ██▓ ██▓     ▄▄▄      󰩖   ]],
		[[  ▒██    ▒ ▓██▒▓██▒    ▒████▄          ]],
		[[  ░ ▓██▄   ▒██▒▒██░    ▒██  ▀█▄        ]],
		[[    ▒   ██▒░██░▒██░    ░██▄▄▄▄██       ]],
		[[  ▒██████▒▒░██░░██████▒ ▓█   ▓██▒      ]],
		[[  ▒ ▒▓▒ ▒ ░░▓  ░ ▒░▓  ░ ▒▒   ▓▒█░      ]],
		[[  ░ ░▒  ░ ░ ▒ ░░ ░ ▒  ░  ▒   ▒▒ ░      ]],
		[[  ░  ░  ░   ▒ ░  ░ ░     ░   ▒         ]],
		[[        ░   ░      ░  ░      ░  ░      ]],
	}
  -- stylua: ignore end
  local arg = vim.fn.argv(0)
  local excluded_ft = { "lazy", "netrw", "man" }
  if not vim.tbl_contains(excluded_ft, vim.bo.ft) and (arg == "") then
    vim.fn.matchadd("Error", "[░▒]")
    vim.fn.matchadd("Function", "[▓█▄▀▐▌]")
    local map = function(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { silent = true, buffer = 0 })
    end
    local keys = {
      N = "neovide/config.toml",
      K = "kitty/kitty.conf",
      W = "wezterm/wezterm.lua",
      I = "nvim/init.lua",
      A = "alacritty/alacritty.toml",
      G = "ghostty/config",
    }
    vim.api.nvim_put(intro.center(header), "l", true, true)
    vim.cmd( -- set local: nonumber norelativenumber nosign-column ocursorcolumn
      [[silent! setl nonu nornu nobl nolist nocul ft=intro bh=wipe bt=nofile]]
    ) -- buffer-history, backtrace

    vim.api.nvim_win_set_cursor(0, { 1, 1 })

    for k, f in pairs(keys) do
      map(k, "<cmd>e " .. xdg .. f .. " | setl noacd<CR>")
    end
    map("P", "<cmd>Pick oldfiles<CR>")
    map("q", "<cmd>q<CR>")
    map("o", "<cmd>e #<1<CR>") -- edit the last edited file
  end
end)

vim.api.nvim_create_autocmd(
  "UIEnter",
  { pattern = "*", callback = intro.splash_screen }
)

return intro
