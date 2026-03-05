vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_light"

vim.o.background = "light"

-- Base colors
set_hl(0, "Normal", { fg = "#3A3A3A", bg = "#F5F3ED" })
set_hl(0, "BoldKeyword", { fg = "#3A3A3A", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#8A8A8A", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#B0AAA1", bg = "#F5F3ED" })
set_hl(0, "CursorLine", { bg = "#EEE9E0" })
set_hl(0, "CursorLineNr", { fg = "#5A5A5A", bg = "#F5F3ED", bold = true })
set_hl(0, "ColorColumn", { bg = "#F0EBE2" })
set_hl(0, "SignColumn", { bg = "#F5F3ED" })
set_hl(0, "VertSplit", { fg = "#DDD7CE", bg = "#F5F3ED" })
set_hl(0, "WinSeparator", { fg = "#DDD7CE", bg = "#F5F3ED" })
set_hl(0, "StatusLine", { fg = "#5C5C5C", bg = "#EDE7DD" })
set_hl(0, "StatusLineNC", { fg = "#9C9C9C", bg = "#F5F3ED" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#E2DED4" })
set_hl(0, "Search", { fg = "#F5F3ED", bg = "#6E6E6E", bold = true })
set_hl(0, "IncSearch", { fg = "#F5F3ED", bg = "#4F4F4F", bold = true })

-- Diff
set_hl(0, "DiffAdd", { fg = "#3A3A3A", bg = "#E3EEE3" })
set_hl(0, "DiffChange", { fg = "#3A3A3A", bg = "#EFE5D6" })
set_hl(0, "DiffDelete", { fg = "#3E2A2A", bg = "#F2D2D2" })
set_hl(0, "DiffText", { fg = "#3A3A3A", bg = "#DCCFB8", bold = true })

-- Neogit diff (override plugin palette)
set_hl(0, "NeogitDiffDelete", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeleteHighlight", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeleteCursor", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeletions", { fg = "#3E2A2A", bg = "NONE" })

-- --- The Only Colored Groups ---
-- Muted dusty blue for comments
set_hl(0, "Comment", { fg = "#6E8798", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#6E8798", bg = "NONE", italic = true })
-- Soft sage green for strings
set_hl(0, "String", { fg = "#6F8A6F", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#5C5C5C", bg = "#EDE7DD" })
set_hl(0, "PmenuSel", { fg = "#F5F3ED", bg = "#6E6E6E", bold = true })
set_hl(0, "FloatBorder", { fg = "#CFC8BE", bg = "#F5F3ED" })
set_hl(0, "NormalFloat", { fg = "#3A3A3A", bg = "#F5F3ED" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8E6060" })
set_hl(0, "DiagnosticWarn", { fg = "#8A7A5A" })
set_hl(0, "DiagnosticInfo", { fg = "#5E6F86" })
set_hl(0, "DiagnosticHint", { fg = "#5C7A6A" })
