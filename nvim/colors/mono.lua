vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono"

vim.o.background = "dark"

-- Base colors
set_hl(0, "Normal", { fg = "#F7EEF2", bg = "#181818" })
set_hl(0, "BoldKeyword", { fg = "#F7EEF2", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#C4B2BC", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#8F6C7D", bg = "#181818" })
set_hl(0, "CursorLine", { bg = "#211C20" })
set_hl(0, "CursorLineNr", { fg = "#F0D1E0", bg = "#181818", bold = true })
set_hl(0, "ColorColumn", { bg = "#181818" })
set_hl(0, "SignColumn", { bg = "#181818" })
set_hl(0, "VertSplit", { fg = "#55414D", bg = "#181818" })
set_hl(0, "WinSeparator", { fg = "#55414D", bg = "#181818" })
set_hl(0, "StatusLine", { fg = "#C6B7C0", bg = "#252025" })
set_hl(0, "StatusLineNC", { fg = "#8F6C7D", bg = "#181818" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#4A3541" })
set_hl(0, "Search", { fg = "#181818", bg = "#F0D1E0", bold = true })
set_hl(0, "IncSearch", { fg = "#181818", bg = "#FFD6E1", bold = true })

-- --- The Only Colored Groups ---
-- Pastel blue for comments
set_hl(0, "Comment", { fg = "#BBD9FF", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#BBD9FF", bg = "NONE", italic = true })
-- Pastel lavender for strings
set_hl(0, "String", { fg = "#D0B9DC", bg = "NONE" })

-- --- Neutralizing Everything Else ---
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Function", { link = "Normal" })
set_hl(0, "Number", { link = "Normal" })
set_hl(0, "Boolean", { link = "Normal" })
set_hl(0, "Constant", { link = "Normal" })
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

-- Standard Keywords (Bold but no color)
set_hl(0, "Type", { link = "BoldKeyword" })
set_hl(0, "StorageClass", { link = "BoldKeyword" })
set_hl(0, "Structure", { link = "BoldKeyword" })
set_hl(0, "Typedef", { link = "BoldKeyword" })
set_hl(0, "Keyword", { link = "BoldKeyword" })
set_hl(0, "Conditional", { link = "BoldKeyword" })
set_hl(0, "Repeat", { link = "BoldKeyword" })
set_hl(0, "Statement", { link = "BoldKeyword" })
set_hl(0, "Exception", { link = "BoldKeyword" })
set_hl(0, "Label", { link = "BoldKeyword" })

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
set_hl(0, "@tag.delimiter", { link = "Normal" })
set_hl(0, "@namespace", { link = "Normal" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@function", { link = "Normal" })
set_hl(0, "@function.builtin", { link = "Normal" })
set_hl(0, "@function.macro", { link = "Normal" })
set_hl(0, "@function.method", { link = "Normal" })
set_hl(0, "@number", { link = "Normal" })
set_hl(0, "@number.float", { link = "Normal" })
set_hl(0, "@boolean", { link = "Normal" })

set_hl(0, "@type", { link = "BoldKeyword" })
set_hl(0, "@type.builtin", { link = "BoldKeyword" })
set_hl(0, "@storageclass", { link = "BoldKeyword" })
set_hl(0, "@constructor", { link = "BoldKeyword" })
set_hl(0, "@keyword", { link = "BoldKeyword" })
set_hl(0, "@keyword.function", { link = "BoldKeyword" })
set_hl(0, "@keyword.return", { link = "BoldKeyword" })

set_hl(0, "@string", { link = "String" })
set_hl(0, "@comment", { link = "Comment" })

set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = "#C6B7C0", bg = "#252025" })
set_hl(0, "PmenuSel", { fg = "#181818", bg = "#C6DDFF", bold = true })
set_hl(0, "FloatBorder", { fg = "#8F6C7D", bg = "#181818" })
set_hl(0, "NormalFloat", { fg = "#F7EEF2", bg = "#181818" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#FFD6E1" })
set_hl(0, "DiagnosticWarn", { fg = "#F7BCCF" })
set_hl(0, "DiagnosticInfo", { fg = "#C6DDFF" })
set_hl(0, "DiagnosticHint", { fg = "#D0B9DC" })
