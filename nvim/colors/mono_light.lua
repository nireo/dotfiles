vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_light"

vim.o.background = "light"

-- Base colors
set_hl(0, "Normal", { fg = "#3F444A", bg = "#DDDCD8" })
set_hl(0, "BoldKeyword", { fg = "#3F444A", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#757B83", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#999EA5", bg = "#DDDCD8" })
set_hl(0, "CursorLine", { bg = "#D6D5D1" })
set_hl(0, "CursorLineNr", { fg = "#50565D", bg = "#DDDCD8", bold = true })
set_hl(0, "ColorColumn", { bg = "#D8D7D3" })
set_hl(0, "SignColumn", { bg = "#DDDCD8" })
set_hl(0, "VertSplit", { fg = "#C3C4C0", bg = "#DDDCD8" })
set_hl(0, "WinSeparator", { fg = "#C3C4C0", bg = "#DDDCD8" })
set_hl(0, "StatusLine", { fg = "#50565D", bg = "#D0CFCC" })
set_hl(0, "StatusLineNC", { fg = "#82878D", bg = "#DDDCD8" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#CACED3" })
set_hl(0, "Search", { fg = "#383E45", bg = "#BCC2CA", bold = true })
set_hl(0, "IncSearch", { fg = "#383E45", bg = "#AFB6C0", bold = true })

-- Diff
set_hl(0, "DiffAdd", { fg = "#3F444A", bg = "#D4DDD5" })
set_hl(0, "DiffChange", { fg = "#3F444A", bg = "#D5D8DD" })
set_hl(0, "DiffDelete", { fg = "#6D5B60", bg = "#DACCD0" })
set_hl(0, "DiffText", { fg = "#3F444A", bg = "#C1C8D1", bold = true })

-- Neogit diff (override plugin palette)
set_hl(0, "NeogitDiffDelete", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeleteHighlight", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeleteCursor", { link = "DiffDelete" })
set_hl(0, "NeogitDiffDeletions", { fg = "#6D5B60", bg = "NONE" })

-- --- The Only Colored Groups ---
-- Muted dusty blue for comments
set_hl(0, "Comment", { fg = "#687682", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#687682", bg = "NONE", italic = true })
-- Soft sage green for strings
set_hl(0, "String", { fg = "#617063", bg = "NONE" })

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
set_hl(0, "Pmenu", { fg = "#50565D", bg = "#D0CFCC" })
set_hl(0, "PmenuSel", { fg = "#383E45", bg = "#BCC2CA", bold = true })
set_hl(0, "FloatBorder", { fg = "#B7B8B4", bg = "#DDDCD8" })
set_hl(0, "NormalFloat", { fg = "#3F444A", bg = "#DDDCD8" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#8B6D74" })
set_hl(0, "DiagnosticWarn", { fg = "#8A7F6D" })
set_hl(0, "DiagnosticInfo", { fg = "#667688" })
set_hl(0, "DiagnosticHint", { fg = "#66776B" })
