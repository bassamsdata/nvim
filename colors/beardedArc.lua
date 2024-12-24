local palette = {
  base00 = "#1c2433",
  base01 = "#262e3d",
  base02 = "#303847",
  base03 = "#444c5b",
  base04 = "#a1adb7",
  base05 = "#c3cfd9",
  base06 = "#ABB7C1",
  base07 = "#08bdba",
  base08 = "#FF738A",
  base09 = "#FF955C",
  base0A = "#EACD61",
  base0B = "#3CEC85",
  base0C = "#77aed7",
  base0D = "#69C3FF",
  base0E = "#22ECDB",
  base0F = "#B78AFF",
}

local use_cterm = {
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

if palette then
  vim.cmd("hi clear")
  require("mini.base16").setup({ palette = palette, use_cterm = use_cterm })
  vim.g.colors_name = "beardedArc"
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
