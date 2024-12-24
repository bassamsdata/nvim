local M = {
  colorscheme = nil,
  opts = {},
  globals = { vim = vim },
  cache = {},
  is_initialized = false,
}

local function initialize()
  if M.is_initialized then
    return
  end

  local current_colorscheme = vim.g.colors_name
  if current_colorscheme then
    M.colorscheme = current_colorscheme
    M.reset()
  end

  M.is_initialized = true
end

function M.reset()
  if M.colorscheme then
    -- Clear the package.loaded for the colorscheme
    package.loaded[M.colorscheme] = nil

    -- Reload the colorscheme module
    local ok, colorscheme_module = pcall(require, M.colorscheme)
    if not ok then
      print("Failed to load colorscheme module: " .. M.colorscheme)
      return
    end

    -- Recreate the colors if the module has the necessary functions
    if type(colorscheme_module) == "table" then
      if
        colorscheme_module.bases
        and type(colorscheme_module.gen_shades) == "function"
      then
        colorscheme_module.shades = {}
        for color, value in pairs(colorscheme_module.bases) do
          colorscheme_module.shades[color] =
            colorscheme_module.gen_shades(value)
        end
      end

      -- Update globals
      M.globals.colors = colorscheme_module
      M.globals.c = colorscheme_module.c or colorscheme_module
      M.globals.M = colorscheme_module
    else
      print("Colorscheme module is not a table: " .. M.colorscheme)
    end
  end
end

---@param name string
---@param buf number
function M.hl_group(name, buf)
  return vim.api.nvim_buf_get_name(buf):find("kinds") and "LspKind" .. name
    or name
end

local function reload()
  initialize()
  if M.colorscheme then
    M.cache = {}
    M.reset()

    -- Reapply the colorscheme
    local _, colorscheme_module = pcall(require, M.colorscheme)
    if colorscheme_module.setup then
      colorscheme_module.setup(colorscheme_module.highlights or {})
    end

    vim.cmd.colorscheme(M.colorscheme)

    local hi = require("mini.hipatterns")
    for _, buf in ipairs(hi.get_enabled_buffers()) do
      hi.update(buf)
    end
  end
end

reload = vim.schedule_wrap(reload)

local function setup_autocmds()
  local augroup =
    vim.api.nvim_create_augroup("colorscheme_dev", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    pattern = "*/colors/" .. "venom.lua",
    callback = function(args)
      local file = args.file
      local colorscheme = vim.fn.fnamemodify(file, ":t:r")
      M.colorscheme = colorscheme
      reload()
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*/colors/" .. "venom.lua",
    callback = function(args)
      local file = args.file
      local colorscheme = vim.fn.fnamemodify(file, ":t:r")
      M.colorscheme = colorscheme
      reload()
    end,
  })
end

local function setup_mini_hipatterns()
  return {
    {
      "echasnovski/mini.hipatterns",
      event = "BufReadPost */colors/venom.lua",
      opts = function(_, opts)
        local hi = require("mini.hipatterns")
        opts.highlighters = opts.highlighters or {}
        opts.highlighters = vim.tbl_extend("keep", opts.highlighters or {}, {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          hl_group = {
            pattern = function(buf)
              return vim.api
                .nvim_buf_get_name(buf)
                :find("colors/" .. M.colorscheme) and '^%s*%[?"?()[%w%.@]+()"?%]?%s*='
            end,
            group = function(buf, match)
              local group = M.hl_group(match, buf)
              if group then
                if M.cache[group] == nil then
                  M.cache[group] = false
                  local hl = vim.api.nvim_get_hl(
                    0,
                    { name = group, link = false, create = false }
                  )
                  if not vim.tbl_isempty(hl) then
                    hl.fg = hl.fg
                      or vim.api.nvim_get_hl(
                        0,
                        { name = "Normal", link = false }
                      ).fg
                    M.cache[group] = true
                    vim.api.nvim_set_hl(0, group .. "Dev", hl)
                  end
                end
                return M.cache[group] and group .. "Dev" or nil
              end
            end,
            extmark_opts = { priority = 2000 },
          },
          hl_color = {
            pattern = {
              "%f[%w]()c%.[%w_%.]+()%f[%W]",
              "%f[%w]()colors%.[%w_%.]+()%f[%W]",
              "%f[%w]()M%.bases%.[%w_%.]+()%f[%W]",
              "%f[%w]()M%.shades%.[%w_%.]+%[?%-?%d*%]?()%f[%W]",
              "%f[%w]()vim%.g%.terminal_color_%d+()%f[%W]",
            },
            group = function(_, match)
              local parts = vim.split(match, ".", { plain = true })
              local color = vim.tbl_get(M.globals, unpack(parts))
              if type(color) == "table" then
                color = color[tonumber(parts[#parts]) or 0] or color
              end
              return type(color) == "string"
                and hi.compute_hex_color_group(color, "fg")
            end,
            extmark_opts = function(_, _, data)
              return {
                virt_text = { { "⬤ ", data.hl_group } },
                virt_text_pos = "inline",
                priority = 2000,
              }
            end,
          },
        })
      end,
    },
  }
end

setup_autocmds()
return setup_mini_hipatterns()
