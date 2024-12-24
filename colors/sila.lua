-- 'Minicyan' color scheme
-- Derived from base16 (https://github.com/chriskempson/base16) and
-- mini_palette palette generator
local use_cterm, palette

-- Dark palette is an output of 'MiniBase16.mini_palette':
-- - Background '#0A2A2A' (LCh(uv) = 15-10-192)
-- - Foreground '#D0D0D0' (Lch(uv) = 83-0-0)
-- - Accent chroma 50
if vim.o.background == "dark" then
  palette = {
    base00 = "#A0CCEF", -- Default Background
    base01 = "#A7836A", -- Lighter Background (Used for status bars, line number and folding marks)
    base02 = "#BDCFE5", -- Selection Background
    base03 = "#8C6754", -- Comments, Invisibles, Line Highlighting
    base04 = "#AABBCB", -- Dark Foreground (Used for status bars)
    base05 = "#574E3F", -- Default Foreground, Caret, Delimiters, Operators
    base06 = "#3B342D", -- Light Foreground (Not often used)
    base07 = "#A4D5F7", -- Light Background (Not often used)
    base08 = "#C49A7F", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = "#B1E1FA", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = "#DAF9FC", -- Classes, Markup Bold, Search Text Background
    base0B = "#1E1A18", -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = "#67665A", -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = "#9BA8B0", -- Functions, Methods, Attribute IDs, Headings
    base0E = "#A0CCEF", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = "#7D837F", -- Deprecated, Opening/Closing Embedded Language Tags
  }
  use_cterm = {
    base00 = 235,
    base01 = 238,
    base02 = 241,
    base03 = 102,
    base04 = 250,
    base05 = 252,
    base06 = 254,
    base07 = 231,
    base08 = 186,
    base09 = 136,
    base0A = 29,
    base0B = 115,
    base0C = 132,
    base0D = 153,
    base0E = 218,
    base0F = 67,
  }
end

-- Light palette is an 'inverted dark', output of 'MiniBase16.mini_palette':
-- - Background '#C0D2D2' (LCh(uv) = 83-10-192)
-- - Foreground '#262626' (Lch(uv) = 15-0-0)
-- - Accent chroma 80
if vim.o.background == "light" then
  palette = {
    base00 = "#fbf7f0", -- Default Background
    base01 = "#efe9dd", -- Lighter Background (Used for status bars, line number and folding marks)
    base02 = "#c9b9b0", -- Selection Background
    base03 = "#595959", -- Comments, Invisibles, Line Highlighting
    base04 = "#193668", -- Dark Foreground (Used for status bars)
    base05 = "#000000", -- Default Foreground, Caret, Delimiters, Operators
    base06 = "#595959", -- Light Foreground (Not often used)
    base07 = "#595959", -- Light Background (Not often used)
    base08 = "#005e8b", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = "#00663f", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = "#005f5f", -- Classes, Markup Bold, Search Text Background
    base0B = "#8f0075", -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = "#005f5f", -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = "#721045", -- Functions, Methods, Attribute IDs, Headings
    base0E = "#7c318f", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = "#972500", -- Deprecated, Opening/Closing Embedded Language Tags
  }
  use_cterm = {
    base00 = 252,
    base01 = 248,
    base02 = 102,
    base03 = 241,
    base04 = 237,
    base05 = 235,
    base06 = 234,
    base07 = 232,
    base08 = 235,
    base09 = 94,
    base0A = 29,
    base0B = 22,
    base0C = 126,
    base0D = 25,
    base0E = 89,
    base0F = 25,
  }
end

if palette then
  vim.cmd("hi clear")
  require("mini.base16").setup({ palette = palette, use_cterm = use_cterm })
  vim.g.colors_name = "sila"
  vim.go.bg = "dark"
end

local hlgroups = {
  -- stylua: ignore start 
	NormalFloat               = { fg   = palette.base05, bg     = palette.base00 },
	LineNr                    = { fg   = palette.base05, bg     = palette.base00 },
	SignColumn                = { fg   = palette.base05, bg     = palette.base00 },
	LineNrAbove               = { fg   = palette.base03, bg     = palette.base00 },
	LineNrBelow               = { fg   = palette.base03, bg     = palette.base00 },
	WhiteSpace                = { fg   = palette.base01 },
	Comment                   = { fg   = palette.base03, italic = true },
	WinSeparator              = { fg   = palette.base01, bg     = palette.base00 },
	NormalMode                = { fg   = palette.base07, bold   = true },
	VisualMode                = { fg   = palette.base0E, bold   = true },
	InsertMode                = { fg   = palette.base0C, bold   = true },
	CommandMode               = { fg   = palette.base0D, bold   = true },
	TermCursor                = { fg   = palette.base00, bg     = palette.base0C },
  MiniDiffSignAdd           = { fg   = palette.base0B, bg     = palette.base00 },
  MiniDiffSignChange        = { fg   = palette.base0E, bg     = palette.base00 },
  MiniDiffSignDelete        = { fg   = palette.base08, bg     = palette.base00 },
  MiniDiffOverAdd           = { link = 'DiffAdd' },
  MiniDiffOverChange        = { link = 'DiffText' },
  MiniDiffOverContext       = { link = 'DiffChange' },
  MiniDiffOverDelete        = { link = 'DiffDelete' },
  MiniPickBorderText        = { fg   = palette.base0D, bg     = palette.base00, bold = true },
  MiniPickPrompt            = { fg   = palette.base0D, bg     = palette.base00, bold = true },
  DiagnosticFloatingError   = { fg   = palette.base08, bg     = palette.base00 },
  DiagnosticFloatingHint    = { fg   = palette.base0D, bg     = palette.base00 },
  DiagnosticFloatingInfo    = { fg   = palette.base0C, bg     = palette.base00 },
  DiagnosticFloatingOk      = { fg   = palette.base0B, bg     = palette.base00 },
  DiagnosticFloatingWarn    = { fg   = palette.base0E, bg     = palette.base00 },
	StatusLineDiagnosticError = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineDiagnosticHint  = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineDiagnosticInfo  = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineDiagnosticWarn  = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineGitAdded        = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineGitChanged      = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineGitRemoved      = { fg   = palette.base04, bg     = palette.base02 },
	StatusLineHeader          = { fg   = palette.base00, bg     = palette.base09 },
	StatusLineHeaderModified  = { fg   = palette.base00, bg     = palette.base0C },
	StatusLineModified        = { fg   = palette.base0C, bg     = palette.base02, bold = true },
	StatusLineArrow           = { fg   = palette.base0F, bg     = palette.base02, bold = true },
  -- stylua: ignore end
}

for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
  vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
end
