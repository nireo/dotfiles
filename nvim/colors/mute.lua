vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_muted"

vim.o.background = "dark"

-- --- Core Palette (Warm Stone High Contrast) ---
-- Background:   #110E0C
-- Foreground:   #D2C7BA (Warm Light Gray)
-- Keyword:      #B1967C (Stone Brown)
-- Type/Label:   #A29A90 (Dusty Slate)
-- Comment:      #8A7D71 (Soft Brown Gray)
-- String:       #F0E4D7 (Warm Off-white)
-- Punctuation:  #7A6E62 (Muted Umber)

-- Base colors
set_hl(0, "Normal", { fg = "#D2C7BA", bg = "#110E0C" })
set_hl(0, "BoldKeyword", { fg = "#B1967C", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#A29A90", bg = "NONE" })
set_hl(0, "Muted", { fg = "#7A6E62", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#5E544C", bg = "#110E0C" })
set_hl(0, "CursorLine", { bg = "#1A1512" })
set_hl(0, "CursorLineNr", { fg = "#B1967C", bg = "#110E0C", bold = true })
set_hl(0, "ColorColumn", { bg = "#181310" })
set_hl(0, "SignColumn", { bg = "#110E0C" })
set_hl(0, "VertSplit", { fg = "#2F2823", bg = "#110E0C" })
set_hl(0, "WinSeparator", { fg = "#2F2823", bg = "#110E0C" })
set_hl(0, "StatusLine", { fg = "#F2E7DA", bg = "#231D18" })
set_hl(0, "StatusLineNC", { fg = "#7A6E62", bg = "#110E0C" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#3F3229" })
set_hl(0, "Search", { fg = "#110E0C", bg = "#B1967C", bold = true })
set_hl(0, "IncSearch", { fg = "#110E0C", bg = "#F0E4D7", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#8A7D71", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#8A7D71", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#F0E4D7", bg = "NONE" })
set_hl(0, "Constant", { fg = "#D2C7BA", bg = "NONE" })
set_hl(0, "Number", { fg = "#D2C7BA", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#D2C7BA", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#CFC4B8", bg = "#1E1915" })
set_hl(0, "PmenuSel", { fg = "#FFF3E7", bg = "#3F3229", bold = true })
set_hl(0, "FloatBorder", { fg = "#4A4038", bg = "#110E0C" })
set_hl(0, "NormalFloat", { fg = "#D2C7BA", bg = "#110E0C" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#C7867B" })
set_hl(0, "DiagnosticWarn", { fg = "#C8A06A" })
set_hl(0, "DiagnosticInfo", { fg = "#8FA2B6" })
set_hl(0, "DiagnosticHint", { fg = "#88A28A" })
