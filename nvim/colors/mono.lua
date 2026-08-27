vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono"

vim.o.background = "dark"

-- Base colors
-- Leave the editor canvas to the terminal so its background is inherited.
set_hl(0, "Normal", { fg = "#F7EEF2", bg = "NONE" })
set_hl(0, "NormalNC", { fg = "#F7EEF2", bg = "NONE" })
set_hl(0, "BoldKeyword", { fg = "#F7EEF2", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#C4B2BC", bg = "NONE" })

-- Syntax accents
-- Cool blue keywords, lavender functions, mint types, and soft rose literals.
set_hl(0, "KeywordColor", { fg = "#C0D6FD", bg = "NONE", bold = true })
set_hl(0, "FunctionName", { fg = "#C1BEEE", bg = "NONE" })
set_hl(0, "TypeName", { fg = "#BFD8D2", bg = "NONE" })
set_hl(0, "Literal", { fg = "#F0D1E0", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#8A8A8A", bg = "NONE" })
set_hl(0, "CursorLine", { bg = "NONE" })
set_hl(0, "CursorLineNr", { fg = "#F0D1E0", bg = "NONE", bold = true })
set_hl(0, "ColorColumn", { bg = "NONE" })
set_hl(0, "SignColumn", { bg = "NONE" })
set_hl(0, "VertSplit", { fg = "#55414D", bg = "NONE" })
set_hl(0, "WinSeparator", { fg = "#55414D", bg = "NONE" })
set_hl(0, "StatusLine", { fg = "#C6B7C0", bg = "NONE" })
set_hl(0, "StatusLineNC", { fg = "#8F6C7D", bg = "NONE" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#4A3541" })
set_hl(0, "Search", { fg = "#181818", bg = "#F0D1E0", bold = true })
set_hl(0, "IncSearch", { fg = "#181818", bg = "#FFD6E1", bold = true })

-- --- Colored Syntax Groups ---
-- Pastel blue for comments
set_hl(0, "Comment", { fg = "#BBD9FF", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#BBD9FF", bg = "NONE", italic = true })
-- Pastel lavender for strings
set_hl(0, "String", { fg = "#D0B9DC", bg = "NONE" })

-- --- Neutralizing Everything Else ---
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Function", { link = "FunctionName" })
set_hl(0, "Number", { link = "Literal" })
set_hl(0, "Boolean", { link = "Literal" })
set_hl(0, "Constant", { link = "Literal" })
set_hl(0, "Special", { link = "Normal" })
set_hl(0, "Character", { link = "Literal" })
set_hl(0, "PreProc", { link = "Normal" })
set_hl(0, "Include", { link = "Normal" })
set_hl(0, "Define", { link = "Normal" })
set_hl(0, "Macro", { link = "Normal" })
set_hl(0, "PreCondit", { link = "Normal" })
set_hl(0, "SpecialChar", { link = "Normal" })
set_hl(0, "Tag", { link = "Normal" })
set_hl(0, "Title", { link = "Normal" })
set_hl(0, "Directory", { link = "Normal" })

-- Standard Keywords (blue and bold)
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

-- Muted Punctuation
set_hl(0, "Delimiter", { link = "Muted" })
set_hl(0, "Operator", { link = "Muted" })

-- --- Treesitter Overrides ---
set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@variable.builtin", { link = "Normal" })
set_hl(0, "@variable.member", { link = "Normal" })
set_hl(0, "@constant", { link = "Literal" })
set_hl(0, "@constant.builtin", { link = "Literal" })
set_hl(0, "@constant.macro", { link = "Literal" })
set_hl(0, "@tag", { link = "Normal" })
set_hl(0, "@tag.attribute", { link = "Normal" })
set_hl(0, "@tag.delimiter", { link = "Normal" })
set_hl(0, "@namespace", { link = "Normal" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@function", { link = "FunctionName" })
set_hl(0, "@function.builtin", { link = "FunctionName" })
set_hl(0, "@function.call", { link = "FunctionName" })
set_hl(0, "@function.macro", { link = "FunctionName" })
set_hl(0, "@function.method", { link = "FunctionName" })
set_hl(0, "@function.method.call", { link = "FunctionName" })
set_hl(0, "@method", { link = "FunctionName" })
set_hl(0, "@method.call", { link = "FunctionName" })
set_hl(0, "@number", { link = "Literal" })
set_hl(0, "@number.float", { link = "Literal" })
set_hl(0, "@boolean", { link = "Literal" })

set_hl(0, "@type", { link = "TypeName" })
set_hl(0, "@type.builtin", { link = "TypeName" })
set_hl(0, "@type.definition", { link = "TypeName" })
set_hl(0, "@type.parameter", { link = "TypeName" })
set_hl(0, "@storageclass", { link = "KeywordColor" })
set_hl(0, "@constructor", { link = "FunctionName" })
set_hl(0, "@keyword", { link = "KeywordColor" })
set_hl(0, "@keyword.function", { link = "KeywordColor" })
set_hl(0, "@keyword.modifier", { link = "KeywordColor" })
set_hl(0, "@keyword.operator", { link = "KeywordColor" })
set_hl(0, "@keyword.return", { link = "KeywordColor" })
set_hl(0, "@type.qualifier", { link = "KeywordColor" })

set_hl(0, "@string", { link = "String" })
set_hl(0, "@comment", { link = "Comment" })

set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = "#C6B7C0", bg = "NONE" })
set_hl(0, "PmenuSel", { fg = "#181818", bg = "#C6DDFF", bold = true })
set_hl(0, "FloatBorder", { fg = "#8F6C7D", bg = "NONE" })
set_hl(0, "NormalFloat", { fg = "#F7EEF2", bg = "NONE" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#FFD6E1" })
set_hl(0, "DiagnosticWarn", { fg = "#F7BCCF" })
set_hl(0, "DiagnosticInfo", { fg = "#C6DDFF" })
set_hl(0, "DiagnosticHint", { fg = "#D0B9DC" })
