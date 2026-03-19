vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl
local palette = {
	bg = "#050505",
	bg_alt = "#121212",
	bg_popup = "#0F0F0F",
	fg = "#D4CDC2",
	fg_bright = "#F5ECDE",
	string = "#C78F88",
	accent = "#95A5AE",
	accent_keyword = "#B7BF92",
	accent_soft = "#B4A999",
	number = "#E4CCAC",
	boolean = "#D2DBAD",
	builtin = "#C2CFDB",
	visual = "#241B15",
	comment = "#908B86",
	muted = "#60574C",
	muted_dark = "#222222",
	error = "#E7DAC7",
	warn = "#9E9484",
	info = "#7D8F99",
	hint = "#87907A",
}

vim.g.colors_name = "mute_original"

vim.o.background = "dark"

set_hl(0, "Normal", { fg = palette.fg, bg = palette.bg })
set_hl(0, "BoldKeyword", { fg = palette.accent_keyword, bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = palette.accent, bg = "NONE" })
set_hl(0, "Muted", { fg = palette.accent_soft, bg = "NONE" })
set_hl(0, "WarmIdentifier", { fg = palette.fg, bg = "NONE" })
set_hl(0, "SoftFunction", { fg = palette.accent, bg = "NONE" })
set_hl(0, "SoftSpecial", { fg = palette.accent, bg = "NONE" })
set_hl(0, "DustyPreProc", { fg = palette.accent, bg = "NONE" })
set_hl(0, "WarmTitle", { fg = palette.fg_bright, bg = "NONE" })
set_hl(0, "SoftDirectory", { fg = palette.accent, bg = "NONE" })

set_hl(0, "LineNr", { fg = palette.muted, bg = palette.bg })
set_hl(0, "CursorLine", { bg = palette.bg_alt })
set_hl(0, "CursorLineNr", { fg = palette.accent, bg = palette.bg_alt, bold = true })
set_hl(0, "ColorColumn", { bg = palette.bg_alt })
set_hl(0, "SignColumn", { bg = palette.bg })
set_hl(0, "VertSplit", { fg = palette.muted_dark, bg = palette.bg })
set_hl(0, "WinSeparator", { fg = palette.muted_dark, bg = palette.bg })
set_hl(0, "StatusLine", { fg = palette.fg_bright, bg = palette.bg_popup })
set_hl(0, "StatusLineNC", { fg = palette.muted, bg = palette.bg })

set_hl(0, "Visual", { fg = palette.fg_bright, bg = palette.visual, bold = true })
set_hl(0, "VisualNOS", { fg = palette.fg_bright, bg = palette.visual, bold = true })
set_hl(0, "Search", { fg = palette.bg, bg = palette.accent, bold = true })
set_hl(0, "IncSearch", { fg = palette.bg, bg = palette.fg_bright, bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = palette.comment, bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = palette.comment, bg = "NONE", italic = true })
set_hl(0, "String", { fg = palette.string, bg = "NONE" })
set_hl(0, "Constant", { fg = palette.fg_bright, bg = "NONE" })
set_hl(0, "BuiltinConstant", { fg = palette.builtin, bg = "NONE" })
set_hl(0, "Number", { fg = palette.number, bg = "NONE" })
set_hl(0, "Boolean", { fg = palette.boolean, bg = "NONE" })
set_hl(0, "goPredefinedIdentifiers", { link = "BuiltinConstant" })
set_hl(0, "goBoolean", { link = "Boolean" })

-- --- Links ---
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Function", { link = "SoftFunction" })
set_hl(0, "Special", { link = "SoftSpecial" })
set_hl(0, "Character", { link = "String" })
set_hl(0, "PreProc", { link = "DustyPreProc" })
set_hl(0, "Include", { link = "DustyPreProc" })
set_hl(0, "Define", { link = "DustyPreProc" })
set_hl(0, "Macro", { link = "DustyPreProc" })
set_hl(0, "PreCondit", { link = "DustyPreProc" })
set_hl(0, "SpecialChar", { link = "SoftSpecial" })
set_hl(0, "Tag", { link = "SoftSpecial" })
set_hl(0, "Title", { link = "WarmTitle" })
set_hl(0, "Directory", { link = "SoftDirectory" })

-- Keyword Accents
set_hl(0, "Keyword", { link = "BoldKeyword" })
set_hl(0, "Conditional", { link = "BoldKeyword" })
set_hl(0, "Repeat", { link = "BoldKeyword" })
set_hl(0, "Statement", { link = "BoldKeyword" })
set_hl(0, "Exception", { link = "BoldKeyword" })

-- Type/Structure Accents
set_hl(0, "Type", { link = "SlateKeyword" })
set_hl(0, "StorageClass", { link = "SlateKeyword" })
set_hl(0, "Structure", { link = "SlateKeyword" })
set_hl(0, "Typedef", { link = "SlateKeyword" })
set_hl(0, "Label", { link = "SlateKeyword" })

-- Softer punctuation, clearer operators
set_hl(0, "Delimiter", { fg = palette.accent_soft, bg = "NONE" })
set_hl(0, "Operator", { fg = palette.fg, bg = "NONE" })

-- --- Treesitter Overrides ---
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@parameter", { link = "Normal" })
set_hl(0, "@parameter.reference", { link = "Normal" })
set_hl(0, "@variable.parameter", { link = "Normal" })
set_hl(0, "@variable.parameter.builtin", { link = "Normal" })
set_hl(0, "@constant", { link = "Constant" })
set_hl(0, "@constant.builtin", { link = "BuiltinConstant" })
set_hl(0, "@constant.builtin.go", { link = "BuiltinConstant" })
set_hl(0, "@constant.macro", { link = "DustyPreProc" })
set_hl(0, "@tag", { link = "SoftSpecial" })
set_hl(0, "@tag.attribute", { link = "WarmIdentifier" })
set_hl(0, "@tag.delimiter", { link = "Delimiter" })
set_hl(0, "@namespace", { link = "DustyPreProc" })
set_hl(0, "@module", { link = "DustyPreProc" })
set_hl(0, "@function", { link = "SoftFunction" })
set_hl(0, "@function.builtin", { link = "SoftFunction" })
set_hl(0, "@function.macro", { link = "DustyPreProc" })
set_hl(0, "@function.method", { link = "SoftFunction" })
set_hl(0, "@property", { link = "Normal" })
set_hl(0, "@field", { link = "Normal" })

set_hl(0, "@type", { link = "SlateKeyword" })
set_hl(0, "@type.builtin", { link = "SlateKeyword" })
set_hl(0, "@storageclass", { link = "SlateKeyword" })
set_hl(0, "@constructor", { link = "SlateKeyword" })
set_hl(0, "@keyword", { link = "BoldKeyword" })
set_hl(0, "@keyword.function", { link = "BoldKeyword" })
set_hl(0, "@keyword.return", { link = "BoldKeyword" })

set_hl(0, "@string", { link = "String" })
set_hl(0, "@character", { link = "String" })
set_hl(0, "@comment", { link = "Comment" })
set_hl(0, "@number", { link = "Number" })
set_hl(0, "@boolean", { link = "Boolean" })
set_hl(0, "@number.go", { link = "Number" })
set_hl(0, "@boolean.go", { link = "Boolean" })

set_hl(0, "@operator", { link = "Operator" })
set_hl(0, "@punctuation.delimiter", { link = "Delimiter" })
set_hl(0, "@punctuation.bracket", { link = "Delimiter" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = palette.fg, bg = palette.bg_popup })
set_hl(0, "PmenuSel", { fg = palette.fg_bright, bg = palette.bg_alt, bold = true })
set_hl(0, "FloatBorder", { fg = palette.muted_dark, bg = palette.bg_popup })
set_hl(0, "NormalFloat", { fg = palette.fg, bg = palette.bg_popup })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = palette.error })
set_hl(0, "DiagnosticWarn", { fg = palette.warn })
set_hl(0, "DiagnosticInfo", { fg = palette.info })
set_hl(0, "DiagnosticHint", { fg = palette.hint })
