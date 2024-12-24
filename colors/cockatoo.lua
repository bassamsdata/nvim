-- Name:         cockatoo
-- Description:  Soft but colorful colorscheme with light and dark variants
-- Author:       Bekaboo <kankefengjing@gmail.com>
-- Maintainer:   Bekaboo <kankefengjing@gmail.com>
-- License:      GPL-3.0
-- Last Updated: Mon 12 Feb 2024 02:17:12 am EST

-- Clear hlgroups and set colors_name {{{
vim.cmd.hi("clear")
vim.g.colors_name = "cockatoo"
-- }}}

-- Palette {{{
-- stylua: ignore start

local c = {
  "yellow", "earth", "orange", "pink", "ochre", "scarlet", "wine", "tea",
  "aqua", "turquoise", "flashlight", "skyblue", "cerulean", "lavender", "purple",
  "magenta", "pigeon", "cumulonimbus", "thunder", "white", "smoke", "beige", "steel",
  "iron", "deepsea", "ocean", "jeans", "space", "black", "shadow", "tea_blend", "aqua_blend",
  "purple_blend", "lavender_blend", "scarlet_blend", "wine_blend", "earth_blend", "smoke_blend", "white2",
}

if vim.go.bg == 'dark' then
  c.yellow         = '#e6bb86'
  c.earth          = '#c1a575'
  c.orange         = '#f0a16c'
  c.pink           = '#f49ba7'
  c.ochre          = '#e87c69'
  c.scarlet        = '#d85959'
  c.wine           = '#a52929'
  c.tea            = '#a4bd84'
  c.aqua           = '#79ada7'
  c.turquoise      = '#7fa0af'
  c.flashlight     = '#add0ef'
  c.skyblue        = '#a5d5ff'
  c.cerulean       = '#86aadc'
  c.lavender       = '#caafeb'
  c.purple         = '#a48fd1'
  c.magenta        = '#dc8ed3'
  c.pigeon         = '#8f9fbc'
  c.cumulonimbus   = '#557396'
  c.thunder        = '#425974'
  c.white          = '#e5e5eb'
  c.smoke          = '#bebec3'
  c.beige          = '#b1aca7'
  c.white2         = '#1b1e30'
  c.steel          = '#606d86'
  c.iron           = '#313742'
  c.deepsea        = '#334154'
  c.ocean          = '#303846'
  c.jeans          = '#0F111A'
  c.space          = '#13161f'
  c.black          = '#09080b'
  c.shadow         = '#09080b'
  c.tea_blend      = '#425858'
  c.aqua_blend     = '#2f3f48'
  c.purple_blend   = '#33374b'
  c.lavender_blend = '#4b4b6e'
  c.scarlet_blend  = '#4b323c'
  c.wine_blend     = '#35262d'
  c.earth_blend    = '#303032'
  c.smoke_blend    = '#272d3a'
else
  c.yellow         = '#c88500'
  c.earth          = '#b48327'
  c.orange         = '#a84a24'
  c.pink           = '#df6d73'
  c.ochre          = '#c84b2b'
  c.scarlet        = '#d85959'
  c.wine           = '#a52929'
  c.tea            = '#5f8c3f'
  c.aqua           = '#3b8f84'
  c.turquoise      = '#29647a'
  c.flashlight     = '#97c0dc'
  c.skyblue        = '#4c99d4'
  c.cerulean       = '#3c70b4'
  c.lavender       = '#9d7bca'
  c.purple         = '#8b71c7'
  c.magenta        = '#ac4ea1'
  c.pigeon         = '#6666a8'
  c.cumulonimbus   = '#486a91'
  c.thunder        = '#dfd6ce'
  c.white          = '#385372'
  c.smoke          = '#404553'
  c.beige          = '#385372'
  c.steel          = '#9a978a'
  c.white2         = '#e7e4d1'
  c.iron           = '#b8b7b3'
  c.deepsea        = '#e6ded6'
  c.ocean          = '#f0e8e2'
  c.jeans          = '#faf4ed'
  c.space          = '#faf7ee'
  c.black          = '#efefef'
  c.shadow         = '#3c3935'
  c.tea_blend      = '#bdc8ad'
  c.aqua_blend     = '#c4cdc2'
  c.purple_blend   = '#e1dbe2'
  c.lavender_blend = '#bcb0cd'
  c.scarlet_blend  = '#e6b8b3'
  c.wine_blend     = '#e6c9c3'
  c.earth_blend    = '#ebe0ce'
  c.smoke_blend    = '#e4e4e2'
end
-- stylua: ignore end
-- }}}

-- Set terminal colors {{{
-- stylua: ignore start
if vim.go.bg == 'dark' then
  vim.g.terminal_color_0  = c.ocean
  vim.g.terminal_color_1  = c.ochre
  vim.g.terminal_color_2  = c.tea
  vim.g.terminal_color_3  = c.yellow
  vim.g.terminal_color_4  = c.cumulonimbus
  vim.g.terminal_color_5  = c.lavender
  vim.g.terminal_color_6  = c.aqua
  vim.g.terminal_color_7  = c.white
  vim.g.terminal_color_8  = c.white
  vim.g.terminal_color_9  = c.ochre
  vim.g.terminal_color_10 = c.tea
  vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_12 = c.cumulonimbus
  vim.g.terminal_color_13 = c.lavender
  vim.g.terminal_color_14 = c.aqua
  vim.g.terminal_color_15 = c.pigeon
else
  vim.g.terminal_color_0  = c.ocean
  vim.g.terminal_color_1  = c.ochre
  vim.g.terminal_color_2  = c.tea
  vim.g.terminal_color_3  = c.yellow
  vim.g.terminal_color_4  = c.flashlight
  vim.g.terminal_color_5  = c.pigeon
  vim.g.terminal_color_6  = c.aqua
  vim.g.terminal_color_7  = c.white
  vim.g.terminal_color_8  = c.white
  vim.g.terminal_color_9  = c.ochre
  vim.g.terminal_color_10 = c.tea
  vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_12 = c.cumulonimbus
  vim.g.terminal_color_13 = c.pigeon
  vim.g.terminal_color_14 = c.aqua
  vim.g.terminal_color_15 = c.pigeon
end
-- }}}

-- Highlight groups {{{1
local hlgroups = {
  -- Common {{{2
  Normal =             { fg = c.smoke, bg = c.jeans },
  NormalFloat =        { fg = c.smoke, bg = c.jeans },
  NormalNC =           { link = 'Normal' },
  ColorColumn =        { bg = c.deepsea },
  Conceal =            { fg = c.smoke },
  Cursor =             { fg = c.space, bg = c.white },
  CursorColumn =       { bg = c.ocean },
  CursorIM =           { fg = c.space, bg = c.flashlight },
  CursorLine =         { bg = c.ocean },
  CursorLineNr=        { fg = c.orange, bold = true },
  DebugPC =            { bg = c.purple_blend },
  lCursor =            { link = 'Cursor' },
  TermCursor =         { fg = c.space, bg = c.orange },
  TermCursorNC =       { fg = c.orange, bg = c.ocean },
  DiffAdd =            { bg = c.aqua_blend },
  DiffAdded =          { fg = c.tea, bg = c.aqua_blend },
  DiffChange =         { bg = c.purple_blend },
  DiffDelete =         { fg = c.wine, bg = c.wine_blend },
  DiffRemoved =        { fg = c.scarlet, bg = c.wine_blend },
  DiffText =           { bg = c.lavender_blend },
  Directory =          { fg = c.pigeon },
  EndOfBuffer =        { fg = c.iron },
  ErrorMsg =           { fg = c.scarlet },
  FoldColumn =         { fg = c.steel },
  Folded =             { fg = c.steel, bg = c.ocean },
  FloatBorder =        { fg = c.smoke, bg = c.jeans },
  FloatShadow =        { bg = c.shadow, blend = 70 },
  FloatShadowThrough = { link = 'None' },
  HealthSuccess =      { fg = c.tea },
  Search =             { bg = c.thunder },
  IncSearch =          { fg = c.black, bg = c.orange, bold = true },
  CurSearch =          { link = 'IncSearch' },
  LineNr =             { fg = c.steel },
  ModeMsg =            { fg = c.smoke },
  MoreMsg =            { fg = c.aqua },
  MsgArea =            { link = 'Normal' },
  MsgSeparator =       { link = 'StatusLine' },
  MatchParen =         { bg = c.thunder, bold = true },
  NonText =            { fg = c.steel },
  Pmenu =              { fg = c.smoke, bg = c.ocean },
  PmenuSbar =          { bg = c.deepsea },
  PmenuSel =           { fg = c.white, bg = c.thunder },
  PmenuThumb =         { bg = c.orange },
  Question =           { fg = c.smoke },
  QuickFixLine =       { link = 'Visual' },
  SignColumn =         { fg = c.smoke },
  SpecialKey =         { fg = c.orange },
  SpellBad =           { underdashed = true },
  SpellCap =           { link = 'SpellBad' },
  SpellLocal =         { link = 'SpellBad' },
  SpellRare =          { link = 'SpellBad' },
  StatusLine =         { fg = c.smoke, bg = nil }, -- c_deepsea
  StatusLineNC =       { fg = c.steel, bg = c.ocean },
  Substitute =         { link = 'Search' },
  TabLine =            { link = 'StatusLine' },
  TabLineFill =        { fg = c.pigeon, bg = c.ocean },
  Title =              { fg = c.pigeon, bold = true },
  VertSplit =          { fg = c.ocean },
  Visual =             { bg = c.deepsea },
  VisualNOS =          { link = 'Visual' },
  WarningMsg =         { fg = c.yellow },
  Whitespace =         {fg = c.white2},
  WildMenu =           { link = 'PmenuSel' },
  WinSeparator =       { link = 'VertSplit' },
  WinBar =             { fg = c.smoke },
 WinBarNC =            { fg = c.pigeon },
  -- }}}2

  -- Syntax {{{2
  Comment =         { fg = c.steel, italic = true },
  Constant =        { fg = c.ochre },
  String =          { fg = c.turquoise },
  DocumentKeyword = { fg = c.tea },
  Character =       { fg = c.orange },
  Number =          { fg = c.purple },
  Boolean =         { fg = c.ochre },
  Array =           { fg = c.orange },
  Float =           { link = 'Number' },
  Identifier =      { fg = c.smoke },
  Builtin =         { fg = c.pink },
  Field =           { fg = c.pigeon },
  Enum =            { fg = c.ochre },
  Namespace =       { fg = c.ochre },
  Function =        { fg = c.yellow },
  Statement =       { fg = c.lavender },
  Specifier =       { fg = c.lavender },
  Object =          { fg = c.lavender },
  Conditional =     { fg = c.magenta },
  Repeat =          { fg = c.magenta },
  Label =           { fg = c.magenta },
  Operator =        { fg = c.orange },
  Keyword =         { fg = c.cerulean },
  Exception =       { fg = c.magenta },
  PreProc =         { fg = c.turquoise },
  PreCondit =       { link = 'PreProc' },
  Include =         { link = 'PreProc' },
  Define =          { link = 'PreProc' },
  Macro =           { fg = c.ochre },
  Type =            { fg = c.lavender },
  StorageClass =    { link = 'Keyword' },
  Structure =       { link = 'Type' },
  Typedef =         { fg = c.beige },
  Special =         { fg = c.orange },
  SpecialChar =     { link = 'Special' },
  Tag =             { fg = c.flashlight},
  Delimiter =       { fg = c.orange },
  Bracket =         { fg = c.cumulonimbus },
  SpecialComment =  { link = 'SpecialChar' },
  Debug =           { link = 'Special' },
  Underlined =      { underline = true },
  Ignore =          { fg = c.iron },
  Error =           { fg = c.scarlet },
  Todo =            { fg = c.black, bg = c.beige, bold = true },
  -- : Organize this - these are used in ModeChanged event for CursorLineNr
  NormalMode = { fg = c.magenta},
  VisualMode = { fg = "#cb4251" },
  InsertMode = { fg = c.aqua },
  CommandMode = { fg = "#ffc73d" },
  -- }}}2

  -- Treesitter syntax {{{2
  ['@field'] = { link = 'Field' },
  ['@property'] = { link = 'Field' },
  ['@annotation'] = { link = 'Operator' },
  ['@comment'] = { link = 'Comment' },
  ['@none'] = { link = 'None' },
  ['@preproc'] = { link = 'PreProc' },
  ['@define'] = { link = 'Define' },
  ['@operator'] = { link = 'Operator' },
  ['@punctuation.delimiter'] = { link = 'Delimiter' },
  ['@punctuation.bracket'] = { link = 'Bracket' },
  ['@punctuation.special'] = { link = 'Delimiter' },
  ['@string'] = { link = 'String' },
  ['@string.regex'] = { link = 'String' },
  ['@string.escape'] = { link = 'SpecialChar' },
  ['@string.special'] = { link = 'SpecialChar' },
  ['@character'] = { link = 'Character' },
  ['@character.special'] = { link = 'SpecialChar' },
  ['@boolean'] = { link = 'Boolean' },
  ['@number'] = { link = 'Number' },
  ['@float'] = { link = 'Float' },
  ['@function'] = { link = 'Function' },
  ['@function.call'] = { link = 'Function' },
  ['@function.builtin'] = { link = 'Special' },
  ['@function.macro'] = { link = 'Macro' },
  ['@method'] = { link = 'Function' },
  ['@method.call'] = { link = 'Function' },
  ['@constructor'] = { link = 'Function' },
  ['@parameter'] = { link = 'Parameter' },
  ['@keyword'] = { link = 'Keyword' },
  ['@keyword.function'] = { link = 'Keyword' },
  ['@keyword.return'] = { link = 'Keyword' },
  ['@conditional'] = { link = 'Conditional' },
  ['@repeat'] = { link = 'Repeat' },
  ['@debug'] = { link = 'Debug' },
  ['@label'] = { link = 'Keyword' },
  ['@include'] = { link = 'Include' },
  ['@exception'] = { link = 'Exception' },
  ['@type'] = { link = 'Type' },
  ['@type.Builtin'] = { link = 'Type' },
  ['@type.qualifier'] = { link = 'Type' },
  ['@type.definition'] = { link = 'Typedef' },
  ['@storageclass'] = { link = 'StorageClass' },
  ['@attribute'] = { link = 'Label' },
  ['@variable'] = { link = 'Identifier' },
  ['@variable.Builtin'] = { link = 'Builtin' },
  ['@constant'] = { link = 'Constant' },
  ['@constant.Builtin'] = { link = 'Constant' },
  ['@constant.macro'] = { link = 'Macro' },
  ['@namespace'] = { link = 'Namespace' },
  ['@symbol'] = { link = 'Identifier' },
  ['@text'] = { link = 'String' },
  ['@text.title'] = { link = 'Title' },
  ['@text.literal'] = { link = 'String' },
  ['@text.uri'] = { link = 'htmlLink' },
  ['@text.math'] = { link = 'Special' },
  ['@text.environment'] = { link = 'Macro' },
  ['@text.environment.name'] = { link = 'Type' },
  ['@text.reference'] = { link = 'Constant' },
  ['@text.title.1.markdown'] = { link = 'markdownH1' },
  ['@text.title.2.markdown'] = { link = 'markdownH2' },
  ['@text.title.3.markdown'] = { link = 'markdownH3' },
  ['@text.title.4.markdown'] = { link = 'markdownH4' },
  ['@text.title.5.markdown'] = { link = 'markdownH5' },
  ['@text.title.6.markdown'] = { link = 'markdownH6' },
  ['@text.title.1.marker.markdown'] = { link = 'markdownH1Delimiter' },
  ['@text.title.2.marker.markdown'] = { link = 'markdownH2Delimiter' },
  ['@text.title.3.marker.markdown'] = { link = 'markdownH3Delimiter' },
  ['@text.title.4.marker.markdown'] = { link = 'markdownH4Delimiter' },
  ['@text.title.5.marker.markdown'] = { link = 'markdownH5Delimiter' },
  ['@text.title.6.marker.markdown'] = { link = 'markdownH6Delimiter' },
  ['@text.todo'] = { link = 'Todo' },
  ['@text.todo.unchecked'] = { link = 'Todo' },
  ['@text.todo.checked'] = { link = 'Done' },
  ['@text.note'] = { link = 'SpecialComment' },
  ['@text.warning'] = { link = 'WarningMsg' },
  ['@text.danger'] = { link = 'ErrorMsg' },
  ['@text.diff.add'] = { link = 'DiffAdded' },
  ['@text.diff.delete'] = { link = 'DiffRemoved' },
  ['@tag'] = { link = 'Tag' },
  ['@tag.attribute'] = { link = 'Identifier' },
  ['@tag.delimiter'] = { link = 'Delimiter' },
  ['@text.strong'] = { bold = true },
  ['@text.strike'] = { strikethrough = true },
  ['@text.emphasis'] = { fg = c.beige, bold = true, italic = true, },
  ['@text.underline'] = { underline = true },
  ['@keyword.operator'] = { link = 'Operator' },
  -- }}}2

  -- LSP semantic {{{2
  ['@lsp.type.enum'] = { link = 'Type' },
  ['@lsp.type.type'] = { link = 'Type' },
  ['@lsp.type.class'] = { link = 'Structure' },
  ['@lsp.type.struct'] = { link = 'Structure' },
  ['@lsp.type.macro'] = { link = 'Macro' },
  ['@lsp.type.method'] = { link = 'Function' },
  ['@lsp.type.comment'] = { link = 'Comment' },
  ['@lsp.type.function'] = { link = 'Function' },
  ['@lsp.type.property'] = { link = 'Field' },
  ['@lsp.type.variable'] = { link = 'Variable' },
  ['@lsp.type.decorator'] = { link = 'Label' },
  ['@lsp.type.interface'] = { link = 'Structure' },
  ['@lsp.type.namespace'] = { link = 'Namespace' },
  ['@lsp.type.parameter'] = { link = 'Parameter' },
  ['@lsp.type.enumMember'] = { link = 'Enum' },
  ['@lsp.type.typeParameter'] = { link = 'Parameter' },
  ['@lsp.typemod.keyword.documentation'] = { link = 'DocumentKeyword' },
  ['@lsp.typemod.function.defaultLibrary'] = { link = 'Special' },
  ['@lsp.typemod.variable.defaultLibrary'] = { link = 'Builtin' },
  ['@lsp.typemod.variable.global'] = { link = 'Identifier' },
  -- }}}2

  -- LSP {{{2
  LspReferenceText = { link = 'Search' },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceWrite = { link = 'LspReferenceText' },
  LspSignatureActiveParameter = { link = 'IncSearch' },
  LspInfoBorder = { link = 'FloatBorder' },
  LspInlayHint = { link = 'DiagnosticVirtualTextHint' },
  LspCodeLens = {  fg= c.magenta, italic = true },
  -- }}}2

  -- Diagnostic {{{2
  DiagnosticOk = { fg = c.tea },
  DiagnosticError = { fg = c.wine },
  DiagnosticWarn = { fg = c.earth },
  DiagnosticInfo = { fg = c.smoke },
  DiagnosticHint = { fg = c.pigeon },
  DiagnosticVirtualTextOk = { fg = c.tea, bg = c.tea_blend },
  DiagnosticVirtualTextError = { fg = c.wine, bg = c.wine_blend },
  DiagnosticVirtualTextWarn = { fg = c.earth, bg = c.earth_blend },
  DiagnosticVirtualTextInfo = { fg = c.smoke, bg = c.smoke_blend },
  DiagnosticVirtualTextHint = { fg = c.pigeon, bg = c.deepsea },
  DiagnosticUnderlineOk = { underline = true, sp = c.tea },
  DiagnosticUnderlineError = { undercurl = true, sp = c.wine },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c.earth },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c.flashlight },
  DiagnosticUnderlineHint = { undercurl = true, sp = c.pigeon },
  DiagnosticFloatingOk = { link = 'DiagnosticOk' },
  DiagnosticFloatingError = { link = 'DiagnosticError' },
  DiagnosticFloatingWarn = { link = 'DiagnosticWarn' },
  DiagnosticFloatingInfo = { link = 'DiagnosticInfo' },
  DiagnosticFloatingHint = { link = 'DiagnosticHint' },
  DiagnosticSignOk = { link = 'DiagnosticOk' },
  DiagnosticSignError = { link = 'DiagnosticError' },
  DiagnosticSignWarn = { link = 'DiagnosticWarn' },
  DiagnosticSignInfo = { link = 'DiagnosticInfo' },
  DiagnosticSignHint = { link = 'DiagnosticHint' },
  -- }}}2

  -- Filetype {{{2
  -- HTML
  htmlArg = { fg = c.pigeon },
  htmlBold = { bold = true },
  htmlBoldItalic = { bold = true, italic = true },
  htmlTag = { fg = c.smoke },
  htmlTagName = { link = 'Tag' },
  htmlSpecialTagName = { fg = c.yellow },
  htmlEndTag = { fg = c.yellow },
  htmlH1 = { fg = c.yellow, bold = true },
  htmlH2 = { fg = c.ochre, bold = true },
  htmlH3 = { fg = c.pink, bold = true },
  htmlH4 = { fg = c.lavender, bold = true },
  htmlH5 = { fg = c.cerulean, bold = true },
  htmlH6 = { fg = c.aqua, bold = true },
  htmlItalic = { italic = true },
  htmlLink = { fg = c.flashlight, underline = true },
  htmlSpecialChar = { fg = c.beige },
  htmlTitle = { fg = c.pigeon },

  -- Json
  jsonKeyword = { link = 'Keyword' },
  jsonBraces = { fg = c.smoke },

  -- Markdown
  markdownBold = { fg = c.aqua, bold = true },
  markdownBoldItalic = { fg = c.skyblue, bold = true, italic = true },
  markdownCode = { fg = c.pigeon },
  markdownError = { link = 'None' },
  markdownEscape = { link = 'None' },
  markdownListMarker = { fg = c.orange },
  markdownH1 = { link = 'htmlH1' },
  markdownH2 = { link = 'htmlH2' },
  markdownH3 = { link = 'htmlH3' },
  markdownH4 = { link = 'htmlH4' },
  markdownH5 = { link = 'htmlH5' },
  markdownH6 = { link = 'htmlH6' },

  -- Shell
  shDeref = { link = 'Macro' },
  shDerefVar = { link = 'Macro' },

  -- Git
  gitHash = { fg = c.pigeon },

  -- Checkhealth
  helpHeader = { fg = c.pigeon, bold = true },
  helpSectionDelim = { fg = c.ochre, bold = true },
  helpCommand = { fg = c.turquoise },
  helpBacktick = { fg = c.turquoise },

  -- Man
  manBold = { fg = c.ochre, bold = true },
  manItalic = { fg = c.turquoise, italic = true },
  manOptionDesc = { fg = c.ochre },
  manReference = { link = 'htmlLink' },
  manSectionHeading = { link = 'manBold' },
  manUnderline = { fg = c.cerulean },
  -- }}}2

  -- Plugins {{{2
  -- netrw
  netrwClassify = { link = 'Directory' },

  -- nvim-cmp
  CmpItemAbbr = { fg = c.smoke },
  CmpItemAbbrDeprecated = { strikethrough = true },
  CmpItemAbbrMatch = { fg = c.white, bold = true },
  CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },
  CmpItemKindText = { link = 'String' },
  CmpItemKindMethod = { link = 'Function' },
  CmpItemKindFunction = { link = 'Function' },
  CmpItemKindConstructor = { link = 'Function' },
  CmpItemKindField = { fg = c.purple },
  CmpItemKindProperty = { link = 'CmpItemKindField' },
  CmpItemKindVariable = { fg = c.aqua },
  CmpItemKindReference = { link = 'CmpItemKindVariable' },
  CmpItemKindModule = { fg = c.magenta },
  CmpItemKindEnum = { fg = c.ochre },
  CmpItemKindEnumMember = { link = 'CmpItemKindEnum' },
  CmpItemKindKeyword = { link = 'Keyword' },
  CmpItemKindOperator = { link = 'Operator' },
  CmpItemKindSnippet = { fg = c.tea },
  CmpItemKindColor = { fg = c.pink },
  CmpItemKindConstant = { link = 'Constant' },
  CmpItemKindCopilot = { fg = c.magenta },
  CmpItemKindValue = { link = 'Number' },
  CmpItemKindClass = { link = 'Type' },
  CmpItemKindStruct = { link = 'Type' },
  CmpItemKindEvent = { fg = c.flashlight },
  CmpItemKindInterface = { fg = c.flashlight },
  CmpItemKindFile = { link = 'DevIconDefault' },
  CmpItemKindFolder = { link = 'Directory' },
  CmpItemKindUnit = { fg = c.cerulean },
  CmpItemKind = { fg = c.smoke },
  CmpItemMenu = { link = 'Pmenu' },
  CmpVirtualText = { fg = c.steel, italic = true },

  -- gitsigns
  GitSignsAdd = { fg = c.tea_blend },
  GitSignsAddInline = { fg = c.tea, bg = c.tea_blend },
  GitSignsAddLnInline = { fg = c.tea, bg = c.tea_blend },
  GitSignsAddPreview = { link = 'DiffAdded' },
  GitSignsChange = { fg = c.lavender_blend },
  GitSignsChangeInline = { fg = c.lavender, bg = c.lavender_blend },
  GitSignsChangeLnInline = { fg = c.lavender, bg = c.lavender_blend, },
  GitSignsCurrentLineBlame = { fg = c.smoke, bg = c.smoke_blend },
  GitSignsDelete = { fg = c.wine },
  GitSignsDeleteInline = { fg = c.scarlet, bg = c.scarlet_blend },
  GitSignsDeleteLnInline = { fg = c.scarlet, bg = c.scarlet_blend },
  GitSignsDeletePreview = { fg = c.scarlet, bg = c.wine_blend },
  GitSignsDeleteVirtLnInLine = { fg = c.scarlet, bg = c.scarlet_blend, },
  GitSignsUntracked = { fg = c.scarlet_blend },
  GitSignsUntrackedLn = { bg = c.scarlet_blend },
  GitSignsUntrackedNr = { fg = c.pink },

  -- fugitive
  fugitiveHash = { link = 'gitHash' },
  fugitiveHeader = { link = 'Title' },
  fugitiveHeading = { fg = c.orange, bold = true },
  fugitiveHelpTag = { fg = c.orange },
  fugitiveSymbolicRef = { fg = c.yellow },
  fugitiveStagedModifier = { fg = c.tea, bold = true },
  fugitiveUnstagedModifier = { fg = c.scarlet, bold = true },
  fugitiveUntrackedModifier = { fg = c.pigeon, bold = true },
  fugitiveStagedHeading = { fg = c.aqua, bold = true },
  fugitiveUnstagedHeading = { fg = c.ochre, bold = true },
  fugitiveUntrackedHeading = { fg = c.lavender, bold = true },

  -- telescope
  TelescopeNormal = { link = 'NormalFloat' },
  TelescopePromptNormal = { bg = c.deepsea },
  TelescopeTitle = { fg = c.space, bg = c.turquoise, bold = true },
  TelescopePromptTitle = { fg = c.space, bg = c.yellow, bold = true, },
  TelescopeBorder = { fg = c.smoke, bg = c.ocean },
  TelescopePromptBorder = { fg = c.smoke, bg = c.deepsea },
  TelescopeSelection = { fg = c.smoke, bg = c.thunder },
  TelescopeMultiIcon = { fg = c.pigeon, bold = true },
  TelescopeMultiSelection = { bg = c.thunder, bold = true },
  TelescopePreviewLine = { bg = c.thunder },
  TelescopeMatching = { link = 'Search' },
  TelescopePromptCounter = { link = 'Comment' },
  TelescopePromptPrefix = { fg = c.orange },
  TelescopeSelectionCaret = { fg = c.orange, bg = c.thunder },

  -- nvim-dap-ui
  DapUIBreakpointsCurrentLine = { link = 'CursorLineNr' },
  DapUIBreakpointsInfo = { fg = c.tea },
  DapUIBreakpointsPath = { link = 'Directory' },
  DapUICurrentFrameName = { fg = c.tea, bold = true },
  DapUIDecoration = { fg = c.yellow },
  DapUIFloatBorder = { link = 'FloatBorder' },
  DapUINormalFloat = { link = 'NormalFloat' },
  DapUILineNumber = { link = 'LineNr' },
  DapUIModifiedValue = { fg = c.skyblue, bold = true },
  DapUIPlayPause = { fg = c.tea },
  DapUIPlayPauseNC = { fg = c.tea },
  DapUIRestart = { fg = c.tea },
  DapUIRestartNC = { fg = c.tea },
  DapUIScope = { fg = c.orange },
  DapUISource = { link = 'Directory' },
  DapUIStepBack = { fg = c.lavender },
  DapUIStepBackRC = { fg = c.lavender },
  DapUIStepInto = { fg = c.lavender },
  DapUIStepIntoRC = { fg = c.lavender },
  DapUIStepOut = { fg = c.lavender },
  DapUIStepOutRC = { fg = c.lavender },
  DapUIStepOver = { fg = c.lavender },
  DapUIStepOverRC = { fg = c.lavender },
  DapUIStop = { fg = c.scarlet },
  DapUIStopNC = { fg = c.scarlet },
  DapUIStoppedThread = { fg = c.tea },
  DapUIThread = { fg = c.aqua },
  DapUIType = { link = 'Type' },
  DapUIVariable = { link = 'Identifier' },
  DapUIWatchesEmpty = { link = 'Comment' },
  DapUIWatchesError = { link = 'Error' },
  DapUIWatchesValue = { fg = c.orange },

  -- vimtex
  texArg = { fg = c.pigeon },
  texArgNew = { fg = c.skyblue },
  texCmd = { fg = c.yellow },
  texCmdBib = { link = 'texCmd' },
  texCmdClass = { link = 'texCmd' },
  texCmdDef = { link = 'texCmd' },
  texCmdE3 = { link = 'texCmd' },
  texCmdEnv = { link = 'texCmd' },
  texCmdEnvM = { link = 'texCmd' },
  texCmdError = { link = 'ErrorMsg' },
  texCmdFatal = { link = 'ErrorMsg' },
  texCmdGreek = { link = 'texCmd' },
  texCmdInput = { link = 'texCmd' },
  texCmdItem = { link = 'texCmd' },
  texCmdLet = { link = 'texCmd' },
  texCmdMath = { link = 'texCmd' },
  texCmdNew = { link = 'texCmd' },
  texCmdPart = { link = 'texCmd' },
  texCmdRef = { link = 'texCmd' },
  texCmdSize = { link = 'texCmd' },
  texCmdStyle = { link = 'texCmd' },
  texCmdTitle = { link = 'texCmd' },
  texCmdTodo = { link = 'texCmd' },
  texCmdType = { link = 'texCmd' },
  texCmdVerb = { link = 'texCmd' },
  texComment = { link = 'Comment' },
  texDefParm = { link = 'Keyword' },
  texDelim = { fg = c.pigeon },
  texE3Cmd = { link = 'texCmd' },
  texE3Delim = { link = 'texDelim' },
  texE3Opt = { link = 'texOpt' },
  texE3Parm = { link = 'texParm' },
  texE3Type = { link = 'texCmd' },
  texEnvOpt = { link = 'texOpt' },
  texError = { link = 'ErrorMsg' },
  texFileArg = { link = 'Directory' },
  texFileOpt = { link = 'texOpt' },
  texFilesArg = { link = 'texFileArg' },
  texFilesOpt = { link = 'texFileOpt' },
  texLength = { fg = c.lavender },
  texLigature = { fg = c.pigeon },
  texOpt = { fg = c.smoke },
  texOptEqual = { fg = c.orange },
  texOptSep = { fg = c.orange },
  texParm = { fg = c.pigeon },
  texRefArg = { fg = c.lavender },
  texRefOpt = { link = 'texOpt' },
  texSymbol = { fg = c.orange },
  texTitleArg = { link = 'Title' },
  texVerbZone = { fg = c.pigeon },
  texZone = { fg = c.pigeon },
  texMathArg = { fg = c.pigeon },
  texMathCmd = { link = 'texCmd' },
  texMathSub = { fg = c.pigeon },
  texMathOper = { fg = c.orange },
  texMathZone = { fg = c.yellow },
  texMathDelim = { fg = c.smoke },
  texMathError = { link = 'Error' },
  texMathGroup = { fg = c.pigeon },
  texMathSuper = { fg = c.pigeon },
  texMathSymbol = { fg = c.yellow },
  texMathZoneLD = { fg = c.pigeon },
  texMathZoneLI = { fg = c.pigeon },
  texMathZoneTD = { fg = c.pigeon },
  texMathZoneTI = { fg = c.pigeon },
  texMathCmdText = { link = 'texCmd' },
  texMathZoneEnv = { fg = c.pigeon },
  texMathArrayArg = { fg = c.yellow },
  texMathCmdStyle = { link = 'texCmd' },
  texMathDelimMod = { fg = c.smoke },
  texMathSuperSub = { fg = c.smoke },
  texMathDelimZone = { fg = c.pigeon },
  texMathStyleBold = { fg = c.smoke, bold = true },
  texMathStyleItal = { fg = c.smoke, italic = true },
  texMathEnvArgName = { fg = c.lavender },
  texMathErrorDelim = { link = 'Error' },
  texMathDelimZoneLD = { fg = c.steel },
  texMathDelimZoneLI = { fg = c.steel },
  texMathDelimZoneTD = { fg = c.steel },
  texMathDelimZoneTI = { fg = c.steel },
  texMathZoneEnsured = { fg = c.pigeon },
  texMathCmdStyleBold = { fg = c.yellow, bold = true },
  texMathCmdStyleItal = { fg = c.yellow, italic = true },
  texMathStyleConcArg = { fg = c.pigeon },
  texMathZoneEnvStarred = { fg = c.pigeon },

  -- lazy.nvim
  LazyDir = { link = 'Directory' },
  LazyUrl = { link = 'htmlLink' },
  LazySpecial = { fg = c.orange },
  LazyCommit = { fg = c.tea },
  LazyReasonFt = { fg = c.pigeon },
  LazyReasonCmd = { fg = c.yellow },
  LazyReasonPlugin = { fg = c.turquoise },
  LazyReasonSource = { fg = c.orange },
  LazyReasonRuntime = { fg = c.lavender },
  LazyReasonEvent = { fg = c.flashlight },
  LazyReasonKeys = { fg = c.pink },
  LazyButton = { bg = c.ocean },
  LazyButtonActive = { bg = c.thunder, bold = true },
  LazyH1 = { fg = c.space, bg = c.yellow, bold = true },

  -- copilot.lua
  CopilotSuggestion = { fg = c.steel, italic = true },
  CopilotAnnotation = { fg = c.steel, italic = true },

  -- statusline plugin
  StatusLineDiagnosticError = { fg = c.wine, bg = c.jeans},
  StatusLineDiagnosticHint = { fg = c.pigeon, bg = c.jeans},
  StatusLineDiagnosticInfo = { fg = c.smoke, bg = c.jeans},
  StatusLineDiagnosticWarn = { fg = c.earth, bg = c.jeans},
  StatusLineGitAdded = { fg = c.tea, bg = c.jeans },
  StatusLineGitChanged = { fg = c.lavender, bg = c.jeans },
  StatusLineGitRemoved = { fg = c.scarlet, bg = c.jeans },
  StatusLineHeader = { fg = c.jeans, bg = c.pigeon },
  StatusLineHeaderModified = { fg = c.jeans, bg = c.ochre },
  StatusLineNormal = { fg = c.jeans, bg = c.cerulean },
  StatusLineInsert = { fg = c.jeans, bg = c.tea },
  StatusLineVisual = { fg = c.jeans, bg = c.orange },
  StatusLineArrow = {fg = c.ochre, bg = c.jeans, bold = true},

  -- glance.nvim
  GlanceBorderTop = { link = 'WinSeparator' },
  GlancePreviewBorderBottom = { link = 'GlanceBorderTop' },
  GlanceListBorderBottom = { link = 'GlanceBorderTop' },
  GlanceFoldIcon = { link = 'Comment' },
  GlanceListCount = { fg = c.jeans, bg = c.pigeon },
  GlanceListCursorLine = { bg = c.deepsea },
  GlanceListNormal = { bg = c.deepsea },
  GlanceListMatch = { bg = c.thunder, bold = true },
  GlancePreviewNormal = { link = 'Pmenu' },
  GlanceWinBarFilename = { fg = c.pigeon, bg = c.deepsea, bold = true },
  GlanceWinBarFilepath = { fg = c.pigeon, bg = c.deepsea },
  GlanceWinBarTitle = { fg = c.pigeon, bg = c.deepsea, bold = true },

  -- mini.nvim highlights
  MiniMapSymbolView = {link = 'VertSplit'},
  MiniNotifyBorder = {fg = c.jeans},

  -- Treesitter Context Menu
  -- TreesitterContextBottom = { underline = true, sp = c_tea},
  -- }}}2


  -- Extra {{{2
  Yellow = { fg = c.yellow },
  Earth = { fg = c.earth },
  Orange = { fg = c.orange },
  Scarlet = { fg = c.scarlet },
  Scarlet_bg = { bg = c.scarlet },
  Ochre = { fg = c.ochre },
  Ochre_bg = {fg = c.jeans, bg = c.ochre },
  Wine = { fg = c.wine },
  Pink = { fg = c.pink },
  Tea = { fg = c.tea },
  Flashlight = { fg = c.flashlight },
  Aqua = { fg = c.aqua },
  Aqua_bg = { fg = c.jeans, bg = c.aqua },
  Cerulean = { fg = c.cerulean },
  SkyBlue = { fg = c.skyblue },
  SkyBlue_bg = { fg = c.jeans, bg = c.skyblue },
  Turquoise = { fg = c.turquoise },
  Lavender = { fg = c.lavender },
  Magenta = { fg = c.magenta },
  Purple = { fg = c.purple },
  Thunder = { fg = c.thunder },
  White = { fg = c.white },
  Beige = { fg = c.beige },
  Pigeon = { fg = c.pigeon },
  Steel = { fg = c.steel },
  Smoke = { fg = c.smoke },
  Iron = { fg = c.iron },
  Deepsea = { fg = c.deepsea },
  Ocean = { fg = c.ocean },
  Space = { fg = c.space },
  Black = { fg = c.black },
  -- }}}2

  HiPatternsNOTE = {link = "Aqua"},
  HiPatternsTODO = {link = "SkyBlue"},
  HiPatternsERROR = {link = "Error"},
  HiPatternsLOVE = {link = "Tea"},
  HiPatternsFIX = {link = "Yellow"},
}
-- }}}1

-- Set highlight groups {{{1
for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
  vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
end
-- }}}1

-- vim:ts=2:sw=2:sts=2:fdm=marker:fdl=0
