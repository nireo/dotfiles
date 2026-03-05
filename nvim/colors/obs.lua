vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "obs"

vim.o.background = "dark"

-- Base palette
set_hl(0, "Normal", { fg = "#e7e7e7", bg = "#181818" })
set_hl(0, "BoldKeyword", { fg = "#b59487", bg = "NONE", bold = true })
set_hl(0, "SlateKeyword", { fg = "#9fbfe7", bg = "NONE" })
set_hl(0, "Muted", { fg = "#727272", bg = "NONE" })
set_hl(0, "WarmIdentifier", { fg = "#bcbcbc", bg = "NONE" })
set_hl(0, "SoftFunction", { fg = "#a0c0d0", bg = "NONE" })
set_hl(0, "SoftSpecial", { fg = "#e9acbf", bg = "NONE" })
set_hl(0, "DustyPreProc", { fg = "#a0c0d0", bg = "NONE" })
set_hl(0, "WarmTitle", { fg = "#c0b080", bg = "NONE" })
set_hl(0, "SoftDirectory", { fg = "#b9d0aa", bg = "NONE" })

-- UI
set_hl(0, "Cursor", { fg = "#181818", bg = "#eeddbb" })
set_hl(0, "lCursor", { fg = "#181818", bg = "#eeddbb" })
set_hl(0, "LineNr", { fg = "#505050", bg = "#181818" })
set_hl(0, "CursorLine", { bg = "#2f2f2f" })
set_hl(0, "CursorColumn", { bg = "#2f2f2f" })
set_hl(0, "CursorLineNr", { fg = "#b59487", bg = "#181818", bold = true })
set_hl(0, "ColorColumn", { bg = "#2f2f2f" })
set_hl(0, "SignColumn", { bg = "#181818" })
set_hl(0, "FoldColumn", { fg = "#505050", bg = "#181818" })
set_hl(0, "Folded", { fg = "#969696", bg = "#2f2f2f" })
set_hl(0, "EndOfBuffer", { fg = "#2f2f2f", bg = "#181818" })
set_hl(0, "NonText", { fg = "#505050", bg = "NONE" })
set_hl(0, "VertSplit", { fg = "#727272", bg = "#181818" })
set_hl(0, "WinSeparator", { fg = "#727272", bg = "#181818" })
set_hl(0, "StatusLine", { fg = "#e7e7e7", bg = "#3a3a3a" })
set_hl(0, "StatusLineNC", { fg = "#969696", bg = "#181818" })

-- Selection and search
set_hl(0, "Visual", { bg = "#432f2a" })
set_hl(0, "VisualNOS", { bg = "#432f2a" })
set_hl(0, "Search", { fg = "#181818", bg = "#c0b080", bold = true })
set_hl(0, "IncSearch", { fg = "#181818", bg = "#eeddbb", bold = true })
set_hl(0, "CurSearch", { fg = "#181818", bg = "#eeddbb", bold = true })
set_hl(0, "MatchParen", { fg = "#e7e7e7", bg = "#505050", bold = true })

-- Content
set_hl(0, "Comment", { fg = "#969696", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#969696", bg = "NONE", italic = true })
set_hl(0, "String", { fg = "#b9d0aa", bg = "NONE" })
set_hl(0, "Constant", { fg = "#b59487", bg = "NONE" })
set_hl(0, "Number", { fg = "#c0b080", bg = "NONE" })
set_hl(0, "Boolean", { fg = "#e9acbf", bg = "NONE" })

-- Links
set_hl(0, "Identifier", { link = "WarmIdentifier" })
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

-- Keywords and structure
set_hl(0, "Keyword", { link = "BoldKeyword" })
set_hl(0, "Conditional", { link = "BoldKeyword" })
set_hl(0, "Repeat", { link = "BoldKeyword" })
set_hl(0, "Statement", { link = "BoldKeyword" })
set_hl(0, "Exception", { link = "BoldKeyword" })

set_hl(0, "Type", { link = "SlateKeyword" })
set_hl(0, "StorageClass", { link = "SlateKeyword" })
set_hl(0, "Structure", { link = "SlateKeyword" })
set_hl(0, "Typedef", { link = "SlateKeyword" })
set_hl(0, "Label", { link = "SlateKeyword" })

set_hl(0, "Delimiter", { link = "Muted" })
set_hl(0, "Operator", { link = "Muted" })

-- Treesitter
set_hl(0, "@variable", { link = "WarmIdentifier" })
set_hl(0, "@variable.builtin", { link = "WarmIdentifier" })
set_hl(0, "@variable.member", { link = "WarmIdentifier" })
set_hl(0, "@parameter", { link = "WarmIdentifier" })
set_hl(0, "@parameter.reference", { link = "WarmIdentifier" })
set_hl(0, "@variable.parameter", { link = "WarmIdentifier" })
set_hl(0, "@variable.parameter.builtin", { link = "WarmIdentifier" })
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
set_hl(0, "@property", { link = "WarmIdentifier" })
set_hl(0, "@field", { link = "WarmIdentifier" })

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

-- Pop-up menu and floating windows
set_hl(0, "Pmenu", { fg = "#bcbcbc", bg = "#2f2f2f" })
set_hl(0, "PmenuSel", { fg = "#e7e7e7", bg = "#3a3a3a", bold = true })
set_hl(0, "PmenuSbar", { bg = "#2f2f2f" })
set_hl(0, "PmenuThumb", { bg = "#505050" })
set_hl(0, "FloatBorder", { fg = "#727272", bg = "#181818" })
set_hl(0, "FloatTitle", { fg = "#b59487", bg = "#181818", bold = true })
set_hl(0, "NormalFloat", { fg = "#e7e7e7", bg = "#181818" })

-- Diff
set_hl(0, "DiffAdd", { fg = "#b9d0aa", bg = "#1f402e" })
set_hl(0, "DiffChange", { fg = "#a0c0d0", bg = "#2f4f54" })
set_hl(0, "DiffDelete", { fg = "#eca28f", bg = "#4d1f20" })
set_hl(0, "DiffText", { fg = "#9fbfe7", bg = "#223567", bold = true })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#eca28f" })
set_hl(0, "DiagnosticWarn", { fg = "#c0b080" })
set_hl(0, "DiagnosticInfo", { fg = "#9fbfe7" })
set_hl(0, "DiagnosticHint", { fg = "#a0c0d0" })
set_hl(0, "DiagnosticOk", { fg = "#b9d0aa" })

set_hl(0, "DiagnosticVirtualTextError", { fg = "#eca28f", bg = "#4d1f20" })
set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#c0b080", bg = "#504432" })
set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#9fbfe7", bg = "#223567" })
set_hl(0, "DiagnosticVirtualTextHint", { fg = "#a0c0d0", bg = "#2f4f54" })
