vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mute_sage_smoke"

vim.o.background = "dark"

-- --- Core Palette (Sage Smoke) ---
-- Background:   #0F1110
-- Foreground:   #B7BCB4 (Soft Gray Green)
-- Keyword:      #6D8A7A (Muted Sage)
-- Type/Label:   #7A8793 (Slate Blue)
-- Comment:      #5A615C (Desaturated Green Gray)
-- String:       #D2D8CF (Light Sage Gray)
-- Punctuation:  #454B47 (Dark Moss Gray)

-- Base colors
set_hl(0, "Normal", { fg = "#B7BCB4", bg = "#0F1110" })
set_hl(0, "BoldKeyword", { fg = "#6D8A7A", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#7A8793", bg = "NONE" })
set_hl(0, "Muted", { fg = "#454B47", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#343A36", bg = "#0F1110" })
set_hl(0, "CursorLine", { bg = "#171B19" })
set_hl(0, "CursorLineNr", { fg = "#7A8793", bg = "#0F1110", bold = true })
set_hl(0, "ColorColumn", { bg = "#161A18" })
set_hl(0, "SignColumn", { bg = "#0F1110" })
set_hl(0, "VertSplit", { fg = "#232826", bg = "#0F1110" })
set_hl(0, "WinSeparator", { fg = "#232826", bg = "#0F1110" })
set_hl(0, "StatusLine", { fg = "#E6ECE3", bg = "#1B201D" })
set_hl(0, "StatusLineNC", { fg = "#4F5651", bg = "#0F1110" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#22302A" })
set_hl(0, "Search", { fg = "#0F1110", bg = "#6D8A7A", bold = true })
set_hl(0, "IncSearch", { fg = "#0F1110", bg = "#D2D8CF", bold = true })

-- --- Content ---
set_hl(0, "Comment", { fg = "#5A615C", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#5A615C", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#D2D8CF", bg = "NONE" })
set_hl(0, "Constant", { fg = "#B7BCB4", bg = "NONE" })
set_hl(0, "Number", { fg = "#B7BCB4", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#B7BCB4", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#AAB0A8", bg = "#171C1A" })
set_hl(0, "PmenuSel", { fg = "#F2F8EF", bg = "#22302A", bold = true })
set_hl(0, "FloatBorder", { fg = "#313835", bg = "#0F1110" })
set_hl(0, "NormalFloat", { fg = "#B7BCB4", bg = "#0F1110" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8A6663" })
set_hl(0, "DiagnosticWarn", { fg = "#8D7F62" })
set_hl(0, "DiagnosticInfo", { fg = "#6C8191" })
set_hl(0, "DiagnosticHint", { fg = "#6D8C7A" })
