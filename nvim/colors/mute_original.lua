vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mute_original"

vim.o.background = "dark"

-- --- Core Palette (Original Warm) ---
-- Background:   #14100C
-- Foreground:   #B0B0B0 (Gray)
-- Keyword:      #5F8787 (Muted Teal)
-- Type/Label:   #748594 (Dusty Slate)
-- Comment:      #8FBF72 (Bright Sage Green)
-- String:       #D9CFC0 (Warm Off-white)
-- Punctuation:  #4A433A (Muted Brown Gray)

-- Base colors
set_hl(0, "Normal", { fg = "#B0B0B0", bg = "#14100C" })
set_hl(0, "BoldKeyword", { fg = "#5F8787", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#748594", bg = "NONE" })
set_hl(0, "Muted", { fg = "#4A433A", bg = "NONE" })
set_hl(0, "WarmIdentifier", { fg = "#C2AA8D", bg = "NONE" })
set_hl(0, "SoftFunction", { fg = "#B7C08E", bg = "NONE" })
set_hl(0, "SoftSpecial", { fg = "#C49B83", bg = "NONE" })
set_hl(0, "DustyPreProc", { fg = "#86A0B2", bg = "NONE" })
set_hl(0, "WarmTitle", { fg = "#D2C29E", bg = "NONE" })
set_hl(0, "SoftDirectory", { fg = "#96B68A", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#3C342C", bg = "#14100C" })
set_hl(0, "CursorLine", { bg = "#1D1712" })
set_hl(0, "CursorLineNr", { fg = "#748594", bg = "#14100C", bold = true })
set_hl(0, "ColorColumn", { bg = "#1A1511" })
set_hl(0, "SignColumn", { bg = "#14100C" })
set_hl(0, "VertSplit", { fg = "#29231D", bg = "#14100C" })
set_hl(0, "WinSeparator", { fg = "#29231D", bg = "#14100C" })
set_hl(0, "StatusLine", { fg = "#F0E6D8", bg = "#201A15" })
set_hl(0, "StatusLineNC", { fg = "#4A433A", bg = "#14100C" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#2A2119" })
set_hl(0, "Search", { fg = "#14100C", bg = "#5F8787", bold = true })
set_hl(0, "IncSearch", { fg = "#14100C", bg = "#E7DAC7", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#8FBF72", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#8FBF72", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#D9CFC0", bg = "NONE" })
set_hl(0, "Constant", { fg = "#C7A08C", bg = "NONE" })
set_hl(0, "Number", { fg = "#CDAE76", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#9CC681", bg = "NONE" })

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

-- Muted Punctuation
set_hl(0, "Delimiter", { link = "Muted" })
set_hl(0, "Operator", { link = "Muted" })

-- --- Treesitter Overrides ---
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@parameter", { link = "Normal" })
set_hl(0, "@parameter.reference", { link = "Normal" })
set_hl(0, "@variable.parameter", { link = "Normal" })
set_hl(0, "@variable.parameter.builtin", { link = "Normal" })
set_hl(0, "@constant", { link = "Constant" })
set_hl(0, "@constant.builtin", { link = "Constant" })
set_hl(0, "@constant.macro", { link = "DustyPreProc" })
set_hl(0, "@tag", { link = "SoftSpecial" })
set_hl(0, "@tag.attribute", { link = "WarmIdentifier" })
set_hl(0, "@tag.delimiter", { link = "Muted" })
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

set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = "#ADA395", bg = "#1B1612" })
set_hl(0, "PmenuSel", { fg = "#FFF6E8", bg = "#2A2119", bold = true })
set_hl(0, "FloatBorder", { fg = "#35302A", bg = "#14100C" })
set_hl(0, "NormalFloat", { fg = "#B0B0B0", bg = "#14100C" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8D5E5A" })
set_hl(0, "DiagnosticWarn", { fg = "#967E54" })
set_hl(0, "DiagnosticInfo", { fg = "#68819A" })
set_hl(0, "DiagnosticHint", { fg = "#6D9B6A" })
