-- thaks to https://github.com/NormTurtle/Windots/blob/main/vi/init.lua
-- ************** YANK RING ***************************
-- ─────────────── REGISTER ALLOCATION SCHEME ────────────────────────
-- ╭───┬──────────────────────────┬───┬──────────────────╮
-- │ 1 │ Last delete              │ 0 │ Last yank        │
-- │ 2 │ Second last delete       │ 9 │ Second last yank │
-- │ 3 │ Third last delete        │ 8 │ Third last yank  │
-- │ 4 │ Fourth last delete       │ 7 │ Fourth last yank │
-- │ 5 │ Fifth last delete        │ 6 │ Fifth last yank  │
-- ╰───┴──────────────────────────┴───┴──────────────────╯
local prev0, prev9
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("yank_history", {}),
  desc = "Store previous yanks in latter half of numbered registers (VimEnter hooks)",
  pattern = "*",
  callback = function()
    prev0 = vim.fn.getreginfo("0")
    prev9 = vim.fn.getreginfo("9")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = "yank_history",
  desc = "Store previous yanks in latter half of numbered registers",
  pattern = "*",
  callback = function()
    if vim.v.event.regname ~= "" then
      return
    end
    vim.fn.setreg("6", vim.fn.getreginfo("7"))
    vim.fn.setreg("7", vim.fn.getreginfo("8"))
    vim.fn.setreg("8", vim.fn.getreginfo("9"))
    if vim.v.event.operator == "y" then
      prev0.isunnamed = false
      vim.fn.setreg("9", prev0)
      prev9 = vim.fn.getreginfo("9")
      prev0 = vim.fn.getreginfo("0")
    else
      vim.fn.setreg("9", prev9)
    end
  end,
})

-- *** Everything below implements cycle functionality ***
local last_put_type = nil
local last_cycle_register = nil
vim.api.nvim_create_augroup("yank_cycle", {})
local function register_autocmd()
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = "yank_cycle",
    desc = "Disallow cycling when cursor was moved, or cursorline changed",
    pattern = "*",
    callback = function()
      last_put_type = nil
      last_cycle_register = nil
    end,
  })
end

local function hook_put_actions(mode, key)
  vim.keymap.set(mode, key, function()
    last_put_type = key
    vim.api.nvim_clear_autocmds({ group = "yank_cycle" })
    vim.schedule(register_autocmd)
    return key
  end, { expr = true, desc = "Track put actions" })
end
for _, key in ipairs({ "p", "P", "gp", "gP", "zp", "zP", "[p", "]p" }) do
  hook_put_actions("n", key)
end
local function cycle_put(amount)
  return function()
    if last_put_type ~= nil then
      if last_cycle_register == nil then
        last_cycle_register = tonumber(vim.fn.getreginfo('"').points_to) or 0
      end
      last_cycle_register = (last_cycle_register + amount) % 10
      local meta =
        getmetatable(vim.fn.getreginfo(tostring(last_cycle_register)))
      if meta ~= getmetatable(vim.empty_dict()) then
        vim.cmd.normal(
          string.format('u"%d%s', last_cycle_register, last_put_type)
        )
        vim.api.nvim_echo(
          { { string.format("Paste using [%d/9]", last_cycle_register) } },
          false,
          {}
        )
      else
        vim.api.nvim_echo({
          {
            string.format(
              "Skipping register %d since it's empty",
              last_cycle_register
            ),
            "ErrorMsg",
          },
        }, false, {})
      end
    else
      vim.api.nvim_echo(
        { { "Cannot cycle put. Cursor has moved", "ErrorMsg" } },
        false,
        {}
      )
    end
  end
end

vim.keymap.set(
  "n",
  "<leader>n",
  cycle_put(1),
  { desc = "Swap put with next register" }
)
vim.keymap.set(
  "n",
  "<leader>p",
  cycle_put(-1),
  { desc = "Swap put with previous register" }
)
