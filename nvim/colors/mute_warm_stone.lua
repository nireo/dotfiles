vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mute_warm_stone"

vim.o.background = "dark"

-- --- Core Palette (Warm Stone) ---
-- Background:   #14110F
-- Foreground:   #BEB5AA (Warm Gray)
-- Keyword:      #8A7966 (Stone Brown)
-- Type/Label:   #7F7A74 (Dusty Slate)
-- Comment:      #665C52 (Soft Brown Gray)
-- String:       #DED5CA (Warm Off-white)
-- Punctuation:  #544A41 (Muted Umber)

-- Base colors
set_hl(0, "Normal", { fg = "#BEB5AA", bg = "#14110F" })
set_hl(0, "BoldKeyword", { fg = "#8A7966", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#7F7A74", bg = "NONE" })
set_hl(0, "Muted", { fg = "#544A41", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#3D352F", bg = "#14110F" })
set_hl(0, "CursorLine", { bg = "#1B1714" })
set_hl(0, "CursorLineNr", { fg = "#7F7A74", bg = "#14110F", bold = true })
set_hl(0, "ColorColumn", { bg = "#191512" })
set_hl(0, "SignColumn", { bg = "#14110F" })
set_hl(0, "VertSplit", { fg = "#2A2420", bg = "#14110F" })
set_hl(0, "WinSeparator", { fg = "#2A2420", bg = "#14110F" })
set_hl(0, "StatusLine", { fg = "#E6DDD2", bg = "#1E1916" })
set_hl(0, "StatusLineNC", { fg = "#544A41", bg = "#14110F" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#322920" })
set_hl(0, "Search", { fg = "#14110F", bg = "#8A7966", bold = true })
set_hl(0, "IncSearch", { fg = "#14110F", bg = "#DED5CA", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#665C52", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#665C52", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#DED5CA", bg = "NONE" })
set_hl(0, "Constant", { fg = "#BEB5AA", bg = "NONE" })
set_hl(0, "Number", { fg = "#BEB5AA", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#BEB5AA", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#B4ACA2", bg = "#1A1613" })
set_hl(0, "PmenuSel", { fg = "#F0E7DC", bg = "#322920", bold = true })
set_hl(0, "FloatBorder", { fg = "#3A332D", bg = "#14110F" })
set_hl(0, "NormalFloat", { fg = "#BEB5AA", bg = "#14110F" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8A5E59" })
set_hl(0, "DiagnosticWarn", { fg = "#8A7459" })
set_hl(0, "DiagnosticInfo", { fg = "#6D7884" })
set_hl(0, "DiagnosticHint", { fg = "#6E7D6A" })
