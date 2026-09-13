vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_blue"
vim.o.background = "dark"

-- The canvas and text match dark-theme.auto.conf in Kitty.
-- Syntax is intentionally limited to a few clearly separated roles.
local c = {
  bg = "#001419",
  fg = "#aeb8b8",
  bright = "#d8dcd8",
  muted = "#718487",
  dim = "#666c6b",
  surface = "#0b252b",
  selection = "#16343b",
  border = "#3f5b61",

  -- More saturated pastels keep each syntax role distinct without becoming neon.
  blue = "#b4c9df",
  blue_muted = "#8999a8",
  cyan = "#a6c9c5",
  green = "#aec9a9",
  comment = "#c0b298",
  magenta = "#b2abc4",
  magenta_bright = "#c3bbd0",
  yellow = "#bbb092",
  red = "#bf979b",
}

-- Base: use the Kitty background instead of a transparent editor canvas.
set_hl(0, "Normal", { fg = c.fg, bg = c.bg })
set_hl(0, "NormalNC", { fg = c.fg, bg = c.bg })
set_hl(0, "Muted", { fg = c.muted, bg = "NONE" })
set_hl(0, "Dim", { fg = c.dim, bg = "NONE" })

-- The small syntax palette: bright functions, blue keywords, lavender literals,
-- sage strings, warm-gold comments, and cyan types.
set_hl(0, "FunctionName", { fg = c.bright, bg = "NONE", bold = true })
set_hl(0, "KeywordColor", { fg = c.blue, bg = "NONE", bold = true })
set_hl(0, "TypeName", { fg = c.cyan, bg = "NONE" })
set_hl(0, "Literal", { fg = c.magenta, bg = "NONE" })

-- Editor chrome
set_hl(0, "LineNr", { fg = c.dim, bg = c.bg })
set_hl(0, "CursorLine", { bg = c.surface })
set_hl(0, "CursorLineNr", { fg = c.bright, bg = c.surface, bold = true })
set_hl(0, "ColorColumn", { bg = c.surface })
set_hl(0, "SignColumn", { bg = c.bg })
set_hl(0, "FoldColumn", { fg = c.dim, bg = c.bg })
set_hl(0, "Folded", { fg = c.muted, bg = c.surface })
set_hl(0, "VertSplit", { fg = c.border, bg = c.bg })
set_hl(0, "WinSeparator", { fg = c.border, bg = c.bg })
set_hl(0, "StatusLine", { fg = c.fg, bg = c.surface })
set_hl(0, "StatusLineNC", { fg = c.muted, bg = c.bg })
set_hl(0, "TabLine", { fg = c.muted, bg = c.surface })
set_hl(0, "TabLineSel", { fg = c.bright, bg = c.selection, bold = true })
set_hl(0, "TabLineFill", { bg = c.surface })
set_hl(0, "WinBar", { fg = c.fg, bg = c.bg })
set_hl(0, "WinBarNC", { fg = c.muted, bg = c.bg })

-- Selection and navigation
set_hl(0, "Visual", { bg = c.selection })
set_hl(0, "Search", { fg = c.bg, bg = c.yellow, bold = true })
set_hl(0, "IncSearch", { fg = c.bg, bg = c.magenta_bright, bold = true })
set_hl(0, "CurSearch", { fg = c.bg, bg = c.magenta_bright, bold = true })
set_hl(0, "MatchParen", { fg = c.bright, bg = c.surface, bold = true })
set_hl(0, "Directory", { fg = c.blue_muted })
set_hl(0, "Title", { fg = c.bright, bold = true })

-- Traditional syntax groups
set_hl(0, "Comment", { fg = c.comment, bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { link = "Comment" })
set_hl(0, "String", { fg = c.green, bg = "NONE" })
set_hl(0, "Character", { link = "Literal" })
set_hl(0, "Number", { link = "Literal" })
set_hl(0, "Float", { link = "Literal" })
set_hl(0, "Boolean", { link = "Literal" })
set_hl(0, "Constant", { link = "Literal" })
set_hl(0, "Function", { link = "FunctionName" })
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Type", { link = "TypeName" })
set_hl(0, "StorageClass", { link = "KeywordColor" })
set_hl(0, "Structure", { link = "KeywordColor" })
set_hl(0, "Typedef", { link = "KeywordColor" })
set_hl(0, "Keyword", { link = "KeywordColor" })
set_hl(0, "Conditional", { link = "KeywordColor" })
set_hl(0, "Repeat", { link = "KeywordColor" })
set_hl(0, "Statement", { link = "KeywordColor" })
set_hl(0, "Exception", { link = "KeywordColor" })
set_hl(0, "Label", { link = "KeywordColor" })
set_hl(0, "PreProc", { link = "Normal" })
set_hl(0, "Include", { link = "Normal" })
set_hl(0, "Define", { link = "Normal" })
set_hl(0, "Macro", { link = "Normal" })
set_hl(0, "Special", { link = "Normal" })
set_hl(0, "Tag", { link = "Normal" })
set_hl(0, "Delimiter", { link = "Dim" })
set_hl(0, "Operator", { link = "Dim" })

-- Treesitter captures for the same small set of roles.
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@constant", { link = "Literal" })
set_hl(0, "@constant.builtin", { link = "Literal" })
set_hl(0, "@constant.macro", { link = "Literal" })
set_hl(0, "@function", { link = "FunctionName" })
set_hl(0, "@function.builtin", { link = "FunctionName" })
set_hl(0, "@function.call", { link = "FunctionName" })
set_hl(0, "@function.method", { link = "FunctionName" })
set_hl(0, "@function.method.call", { link = "FunctionName" })
set_hl(0, "@constructor", { link = "FunctionName" })
set_hl(0, "@type", { link = "TypeName" })
set_hl(0, "@type.builtin", { link = "TypeName" })
set_hl(0, "@type.definition", { link = "TypeName" })
set_hl(0, "@type.qualifier", { link = "KeywordColor" })
set_hl(0, "@keyword", { link = "KeywordColor" })
set_hl(0, "@keyword.function", { link = "KeywordColor" })
set_hl(0, "@keyword.modifier", { link = "KeywordColor" })
set_hl(0, "@keyword.operator", { link = "KeywordColor" })
set_hl(0, "@keyword.return", { link = "KeywordColor" })
set_hl(0, "@string", { link = "String" })
set_hl(0, "@number", { link = "Literal" })
set_hl(0, "@number.float", { link = "Literal" })
set_hl(0, "@boolean", { link = "Literal" })
set_hl(0, "@comment", { link = "Comment" })
set_hl(0, "@operator", { link = "Dim" })
set_hl(0, "@punctuation.delimiter", { link = "Dim" })
set_hl(0, "@punctuation.bracket", { link = "Dim" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@property", { link = "Normal" })
set_hl(0, "@field", { link = "Normal" })
set_hl(0, "@tag", { link = "Normal" })
set_hl(0, "@tag.attribute", { link = "Normal" })
set_hl(0, "@tag.delimiter", { link = "Dim" })

-- Menus and floating windows
set_hl(0, "Pmenu", { fg = c.fg, bg = c.surface })
set_hl(0, "PmenuSel", { fg = c.bright, bg = c.selection, bold = true })
set_hl(0, "PmenuSbar", { bg = c.surface })
set_hl(0, "PmenuThumb", { bg = c.border })
set_hl(0, "NormalFloat", { fg = c.fg, bg = c.surface })
set_hl(0, "FloatBorder", { fg = c.border, bg = c.surface })
set_hl(0, "FloatTitle", { fg = c.blue, bg = c.surface, bold = true })

-- Diagnostics and diffs
set_hl(0, "DiagnosticError", { fg = c.red })
set_hl(0, "DiagnosticWarn", { fg = c.yellow })
set_hl(0, "DiagnosticInfo", { fg = c.blue })
set_hl(0, "DiagnosticHint", { fg = c.cyan })
set_hl(0, "DiagnosticUnderlineError", { sp = c.red, undercurl = true })
set_hl(0, "DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
set_hl(0, "DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
set_hl(0, "DiagnosticUnderlineHint", { sp = c.cyan, undercurl = true })
set_hl(0, "DiffAdd", { fg = c.green, bg = c.surface })
set_hl(0, "DiffChange", { fg = c.blue, bg = c.surface })
set_hl(0, "DiffDelete", { fg = c.red, bg = c.surface })
set_hl(0, "DiffText", { fg = c.bright, bg = c.selection, bold = true })
