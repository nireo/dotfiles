vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_pastel"
vim.o.background = "dark"

-- Coordinated with Kitty/Pi Mono Pastel, with editor-specific contrast.
local c = {
  bg = "#17191A",
  surface = "#202324",
  raised = "#2B2F30",
  selection = "#443C41",
  fg = "#DDD9DB",
  bright = "#EBE7E9",
  muted = "#A6A4A6",
  dim = "#797D7D",
  border = "#424748",
  blue = "#A8B8CC",
  comment = "#929FAF",
  lavender = "#B2ABC4",
  mint = "#A5BCB5",
  rose = "#C09BA5",
  warm = "#C0B298",
}

-- Base: inherit the terminal canvas for a quiet, seamless background.
set_hl(0, "Normal", { fg = c.fg, bg = "NONE" })
set_hl(0, "NormalNC", { fg = c.fg, bg = "NONE" })
set_hl(0, "Muted", { fg = c.muted, bg = "NONE" })
set_hl(0, "KeywordColor", { fg = c.blue, bg = "NONE", bold = true })
set_hl(0, "FunctionName", { fg = c.lavender, bg = "NONE" })
set_hl(0, "TypeName", { fg = c.mint, bg = "NONE" })
set_hl(0, "Literal", { fg = c.rose, bg = "NONE" })

-- Editor chrome
set_hl(0, "LineNr", { fg = c.dim, bg = "NONE" })
set_hl(0, "CursorLine", { bg = c.surface })
set_hl(0, "CursorLineNr", { fg = c.bright, bg = "NONE", bold = true })
set_hl(0, "ColorColumn", { bg = c.surface })
set_hl(0, "SignColumn", { bg = "NONE" })
set_hl(0, "FoldColumn", { fg = c.dim, bg = "NONE" })
set_hl(0, "Folded", { fg = c.muted, bg = c.surface })
set_hl(0, "VertSplit", { fg = c.border, bg = "NONE" })
set_hl(0, "WinSeparator", { fg = c.border, bg = "NONE" })
set_hl(0, "StatusLine", { fg = c.fg, bg = c.surface })
set_hl(0, "StatusLineNC", { fg = c.dim, bg = c.surface })
set_hl(0, "TabLine", { fg = c.dim, bg = c.surface })
set_hl(0, "TabLineSel", { fg = c.bright, bg = c.raised, bold = true })
set_hl(0, "TabLineFill", { bg = c.surface })
set_hl(0, "WinBar", { fg = c.fg, bg = "NONE" })
set_hl(0, "WinBarNC", { fg = c.dim, bg = "NONE" })

-- Selection and navigation
set_hl(0, "Visual", { bg = c.selection })
set_hl(0, "Search", { fg = c.bg, bg = c.warm, bold = true })
set_hl(0, "IncSearch", { fg = c.bg, bg = c.bright, bold = true })
set_hl(0, "CurSearch", { fg = c.bg, bg = c.bright, bold = true })
set_hl(0, "MatchParen", { fg = c.bright, bg = c.raised, bold = true })
set_hl(0, "Directory", { fg = c.blue })
set_hl(0, "Title", { fg = c.bright, bold = true })

-- Deliberately restrained syntax accents
set_hl(0, "Comment", { fg = c.comment, italic = true })
set_hl(0, "SpecialComment", { fg = c.comment, italic = true })
set_hl(0, "String", { fg = c.lavender })
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
set_hl(0, "Delimiter", { link = "Muted" })
set_hl(0, "Operator", { link = "Muted" })

-- Treesitter
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@constant", { link = "Literal" })
set_hl(0, "@constant.builtin", { link = "Literal" })
set_hl(0, "@constant.macro", { link = "Literal" })
set_hl(0, "@function", { link = "FunctionName" })
set_hl(0, "@function.builtin", { link = "FunctionName" })
set_hl(0, "@function.call", { link = "FunctionName" })
set_hl(0, "@function.macro", { link = "FunctionName" })
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
set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@tag", { link = "Normal" })
set_hl(0, "@tag.attribute", { link = "Normal" })
set_hl(0, "@tag.delimiter", { link = "Muted" })

-- Menus and floating windows
set_hl(0, "Pmenu", { fg = c.fg, bg = c.surface })
set_hl(0, "PmenuSel", { fg = c.bright, bg = c.selection, bold = true })
set_hl(0, "PmenuSbar", { bg = c.surface })
set_hl(0, "PmenuThumb", { bg = c.border })
set_hl(0, "NormalFloat", { fg = c.fg, bg = c.surface })
set_hl(0, "FloatBorder", { fg = c.border, bg = c.surface })
set_hl(0, "FloatTitle", { fg = c.blue, bg = c.surface, bold = true })

-- Diagnostics and diffs
set_hl(0, "DiagnosticError", { fg = c.rose })
set_hl(0, "DiagnosticWarn", { fg = c.warm })
set_hl(0, "DiagnosticInfo", { fg = c.blue })
set_hl(0, "DiagnosticHint", { fg = c.mint })
set_hl(0, "DiagnosticUnderlineError", { sp = c.rose, undercurl = true })
set_hl(0, "DiagnosticUnderlineWarn", { sp = c.warm, undercurl = true })
set_hl(0, "DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
set_hl(0, "DiagnosticUnderlineHint", { sp = c.mint, undercurl = true })
set_hl(0, "DiffAdd", { fg = c.mint, bg = c.surface })
set_hl(0, "DiffChange", { fg = c.blue, bg = c.surface })
set_hl(0, "DiffDelete", { fg = c.rose, bg = c.surface })
set_hl(0, "DiffText", { fg = c.bright, bg = c.raised, bold = true })
