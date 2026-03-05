vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mute_dusty_mauve"

vim.o.background = "dark"

-- --- Core Palette (Dusty Mauve) ---
-- Background:   #131014
-- Foreground:   #B9B1BC (Soft Violet Gray)
-- Keyword:      #85718B (Muted Mauve)
-- Type/Label:   #7D8598 (Slate Violet)
-- Comment:      #655D68 (Dusty Gray)
-- String:       #D8CFDA (Pale Lilac)
-- Punctuation:  #524C55 (Dark Plum Gray)

-- Base colors
set_hl(0, "Normal", { fg = "#B9B1BC", bg = "#131014" })
set_hl(0, "BoldKeyword", { fg = "#85718B", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#7D8598", bg = "NONE" })
set_hl(0, "Muted", { fg = "#524C55", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#3A343D", bg = "#131014" })
set_hl(0, "CursorLine", { bg = "#1A151C" })
set_hl(0, "CursorLineNr", { fg = "#85718B", bg = "#131014", bold = true })
set_hl(0, "ColorColumn", { bg = "#181319" })
set_hl(0, "SignColumn", { bg = "#131014" })
set_hl(0, "VertSplit", { fg = "#29222D", bg = "#131014" })
set_hl(0, "WinSeparator", { fg = "#29222D", bg = "#131014" })
set_hl(0, "StatusLine", { fg = "#ECE3EE", bg = "#1E1821" })
set_hl(0, "StatusLineNC", { fg = "#524C55", bg = "#131014" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#2D2532" })
set_hl(0, "Search", { fg = "#131014", bg = "#85718B", bold = true })
set_hl(0, "IncSearch", { fg = "#131014", bg = "#D8CFDA", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#655D68", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#655D68", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#D8CFDA", bg = "NONE" })
set_hl(0, "Constant", { fg = "#B9B1BC", bg = "NONE" })
set_hl(0, "Number", { fg = "#B9B1BC", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#B9B1BC", bg = "NONE" })

-- --- Links ---
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Function", { link = "Normal" })
set_hl(0, "Special", { link = "Normal" })
set_hl(0, "Character", { link = "Normal" })
set_hl(0, "PreProc", { link = "Normal" })
set_hl(0, "Include", { link = "Normal" })
set_hl(0, "Define", { link = "Normal" })
set_hl(0, "Macro", { link = "Normal" })
set_hl(0, "PreCondit", { link = "Normal" })
set_hl(0, "SpecialChar", { link = "Normal" })
set_hl(0, "Tag", { link = "Normal" })
set_hl(0, "Title", { link = "Normal" })
set_hl(0, "Directory", { link = "Normal" })

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

-- Muted Punctuation
set_hl(0, "Delimiter", { link = "Muted" })
set_hl(0, "Operator", { link = "Muted" })

-- --- Treesitter Overrides ---
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@constant", { link = "Normal" })
set_hl(0, "@constant.builtin", { link = "Normal" })
set_hl(0, "@tag", { link = "Normal" })
set_hl(0, "@tag.attribute", { link = "Normal" })
set_hl(0, "@tag.delimiter", { link = "Muted" })
set_hl(0, "@namespace", { link = "Normal" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@function", { link = "Normal" })
set_hl(0, "@function.builtin", { link = "Normal" })
set_hl(0, "@function.macro", { link = "Normal" })
set_hl(0, "@function.method", { link = "Normal" })

set_hl(0, "@type", { link = "SlateKeyword" })
set_hl(0, "@type.builtin", { link = "SlateKeyword" })
set_hl(0, "@storageclass", { link = "SlateKeyword" })
set_hl(0, "@constructor", { link = "SlateKeyword" })
set_hl(0, "@keyword", { link = "BoldKeyword" })
set_hl(0, "@keyword.function", { link = "BoldKeyword" })
set_hl(0, "@keyword.return", { link = "BoldKeyword" })

set_hl(0, "@string", { link = "String" })
set_hl(0, "@comment", { link = "Comment" })

set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = "#B2AAB5", bg = "#1A151C" })
set_hl(0, "PmenuSel", { fg = "#FAF0FC", bg = "#2D2532", bold = true })
set_hl(0, "FloatBorder", { fg = "#3A3240", bg = "#131014" })
set_hl(0, "NormalFloat", { fg = "#B9B1BC", bg = "#131014" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#A06D73" })
set_hl(0, "DiagnosticWarn", { fg = "#A58A69" })
set_hl(0, "DiagnosticInfo", { fg = "#8491A9" })
set_hl(0, "DiagnosticHint", { fg = "#819A88" })
