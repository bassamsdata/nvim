local M = {}
local log = require("utils.log")

function M.apply_highlight(target_group, attributes)
  local function get_hl_color(name, attr)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    if hl.link then
      hl = vim.api.nvim_get_hl(0, { name = hl.link })
    end
    return hl[attr]
  end
  local props = {}
  for attr, source_group in pairs(attributes) do
    props[attr] = get_hl_color(source_group, attr)
  end
  vim.api.nvim_set_hl(0, target_group, props)
end

function M.highlight(table)
  for group, config in pairs(table) do
    vim.api.nvim_set_hl(0, group, config)
  end
end

function M.is_none(string)
  return string == "NONE" or string == "none"
end

function M.none()
  return "NONE"
end

-- https://github.com/EmmanuelOga/columns/blob/mas", "#fca5a5", 0.5ter/utils/color.lua
--- Converts an HSL color value to RGB. Conversion formula
--- adapted from http://en.wikipedia.org/wiki/HSL_color_space.
--- Assumes h, s, and l are contained in the set [0, 1] and
--- returns r, g, and b in the set [0, 255].
---
---@param table1 table
---@param table2 table
---@return table
function M.merge(table1, table2)
  if table1 == table2 == nil then
    return {}
  end
  if table1 == nil then
    return table2
  elseif table2 == nil then
    return table1
  end
  return vim.tbl_deep_extend("force", table1, table2)
end

function M.hexToRgb(str)
  str = string.lower(str)
  return tonumber(str:sub(2, 3), 16),
    tonumber(str:sub(4, 5), 16),
    tonumber(str:sub(6, 7), 16)
end

function M.rgbToHex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

---@param r number
---@param g number
---@param b number
---@return number, number, number
function M.rgb_to_hsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)

  local h, s, v
  v = max

  local d = max - min
  if max == 0 then
    s = 0
  else
    s = d / max
  end

  if max == min then
    h = 0
  else
    if max == r then
      h = (g - b) / d
      if g < b then
        h = h + 6
      end
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v
end

---@param h number
---@param s number
---@param v number
---@return number, number, number
function M.hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)

  i = i % 6

  if i == 0 then
    r, g, b = v, t, p
  elseif i == 1 then
    r, g, b = q, v, p
  elseif i == 2 then
    r, g, b = p, v, t
  elseif i == 3 then
    r, g, b = p, q, v
  elseif i == 4 then
    r, g, b = t, p, v
  elseif i == 5 then
    r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end

---@param hex string
---@param amount number
---@return string
function M.darken(hex, amount)
  local r, g, b = M.hexToRgb(hex)
  local h, s, v = M.rgb_to_hsv(r, g, b)
  v = v * ((1 - amount) / 1)
  r, g, b = M.hsvToRgb(h, s, v)
  return M.rgbToHex(r, g, b)
end

---@param hex string
---@param amount number
---@return string
function M.lighten(hex, amount)
  local r, g, b = M.hexToRgb(hex)
  local h, s, v = M.rgb_to_hsv(r, g, b)
  v = v * (1 + amount)
  r, g, b = M.hsvToRgb(h, s, v)
  return M.rgbToHex(r, g, b)
end

---Adapted from @folke/tokyonight.nvim.
---@param foreground string
---@param background string
---@param alpha number
---@return string|nil
function M.blend(foreground, background, alpha)
  if M.is_none(foreground) or M.is_none(background) then
    return M.none()
  end

  local fg = { M.hexToRgb(foreground) }
  local bg = { M.hexToRgb(background) }

  -- Add error checking for hexToRgb results
  if #fg ~= 3 or #bg ~= 3 then
    print("Error: Invalid RGB values from hexToRgb")
    print("Foreground:", vim.inspect(fg))
    print("Background:", vim.inspect(bg))
    return nil
  end

  local blend_channel = function(c_fg, c_bg)
    local ret = (alpha * c_fg + ((1 - alpha) * c_bg))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  local r = blend_channel(fg[1], bg[1])
  local g = blend_channel(fg[2], bg[2])
  local b = blend_channel(fg[3], bg[3])
  local blended = M.rgbToHex(r, g, b)

  -- Add error checking for rgbToHex result
  if
    type(blended) ~= "string"
    or #blended ~= 7
    or not blended:match("^#%x%x%x%x%x%x$")
  then
    print("Error: Invalid hex color from rgbToHex")
    print("Blended color:", blended)
    print("RGB values:", r, g, b)
    return nil
  end

  return blended
end

-- new comment to use agaist git

function M.getHexColor(coloGroup, color_type)
  local hl = vim.api.nvim_get_hl(0, { name = coloGroup })
  if hl.link then
    hl = vim.api.nvim_get_hl(0, { name = hl.link })
  end
  if color_type == "fg" then
    local fg = ("#%06x"):format(hl.fg) or "#000000"
    return fg
  end
  if color_type == "bg" then
    local bg = ("#%06x"):format(hl.bg) or "#ffffff"
    return bg
  end
end

---@param groups_to_set string|table
---@param blend_with string
---@param blend_attr "fg"|"bg"
---@param alpha number
function M.blend_highlight_groups(groups_to_set, blend_with, blend_attr, alpha)
  local function get_color(group, attr)
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    if hl[attr] then
      return ("#%06x"):format(hl[attr])
    elseif hl.link then
      return get_color(hl.link, attr)
    end
    return nil
  end

  local blend_color = get_color(blend_with, blend_attr)
  if not blend_color then
    print("Error: Could not get color for blend_with group")
    return
  end

  if type(groups_to_set) == "string" then
    groups_to_set = { groups_to_set }
  end

  for _, group in ipairs(groups_to_set) do
    local original_hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    local original_color = get_color(group, "fg")
    if original_color then
      local blended_color = M.blend(original_color, blend_color, alpha)

      if not blended_color then
        log.info("Error: Failed to blend colors for group " .. group, "print")
        log.info("Original color:" .. original_color, "print")
        log.info("Blend color:" .. blend_color, "print")
        return
      end

      -- Preserve all original attributes except the blended one
      local new_hl = vim.tbl_extend("force", original_hl, {
        fg = blended_color,
      })
      new_hl.link = nil -- Remove the 'link' key if it exists
      vim.api.nvim_set_hl(0, group, new_hl)
    else
      print("Error: Could not get foreground color for group " .. group)
      return
    end
  end
end

return M
