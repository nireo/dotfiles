vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mute_blue_fog"

vim.o.background = "dark"

-- --- Core Palette (Blue Fog) ---
-- Background:   #101215
-- Foreground:   #B2BAC4 (Cool Gray)
-- Keyword:      #6D8291 (Muted Blue)
-- Type/Label:   #7E8A9A (Fog Slate)
-- Comment:      #57606B (Blue Gray)
-- String:       #D3D9E2 (Soft Ice)
-- Punctuation:  #4A525C (Deep Steel)

-- Base colors
set_hl(0, "Normal", { fg = "#B2BAC4", bg = "#101215" })
set_hl(0, "BoldKeyword", { fg = "#6D8291", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#7E8A9A", bg = "NONE" })
set_hl(0, "Muted", { fg = "#4A525C", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#373F49", bg = "#101215" })
set_hl(0, "CursorLine", { bg = "#171B20" })
set_hl(0, "CursorLineNr", { fg = "#7E8A9A", bg = "#101215", bold = true })
set_hl(0, "ColorColumn", { bg = "#15191E" })
set_hl(0, "SignColumn", { bg = "#101215" })
set_hl(0, "VertSplit", { fg = "#242A32", bg = "#101215" })
set_hl(0, "WinSeparator", { fg = "#242A32", bg = "#101215" })
set_hl(0, "StatusLine", { fg = "#E6ECF5", bg = "#1A2028" })
set_hl(0, "StatusLineNC", { fg = "#56606C", bg = "#101215" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#26313D" })
set_hl(0, "Search", { fg = "#101215", bg = "#6D8291", bold = true })
set_hl(0, "IncSearch", { fg = "#101215", bg = "#D3D9E2", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#57606B", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#57606B", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#D3D9E2", bg = "NONE" })
set_hl(0, "Constant", { fg = "#B2BAC4", bg = "NONE" })
set_hl(0, "Number", { fg = "#B2BAC4", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#B2BAC4", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#A7AFB8", bg = "#171C22" })
set_hl(0, "PmenuSel", { fg = "#F1F7FF", bg = "#26313D", bold = true })
set_hl(0, "FloatBorder", { fg = "#323A45", bg = "#101215" })
set_hl(0, "NormalFloat", { fg = "#B2BAC4", bg = "#101215" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8F6A6E" })
set_hl(0, "DiagnosticWarn", { fg = "#9A845E" })
set_hl(0, "DiagnosticInfo", { fg = "#7C9AB8" })
set_hl(0, "DiagnosticHint", { fg = "#7CA08C" })
