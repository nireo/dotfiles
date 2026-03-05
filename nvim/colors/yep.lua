vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono"

vim.o.background = "dark"

-- Base colors
set_hl(0, "Normal", { fg = "#B0B0B0", bg = "#090909" })
set_hl(0, "BoldKeyword", { fg = "#B0B0B0", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#666666", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#444444", bg = "#090909" })
set_hl(0, "CursorLine", { bg = "#121212" })
set_hl(0, "CursorLineNr", { fg = "#A0A0A0", bg = "#090909", bold = true })
set_hl(0, "ColorColumn", { bg = "#090909" })
set_hl(0, "SignColumn", { bg = "#090909" })
set_hl(0, "VertSplit", { fg = "#1A1A1A", bg = "#090909" })
set_hl(0, "WinSeparator", { fg = "#1A1A1A", bg = "#090909" })
set_hl(0, "StatusLine", { fg = "#909090", bg = "#141414" })
set_hl(0, "StatusLineNC", { fg = "#444444", bg = "#090909" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#262626" })
set_hl(0, "Search", { fg = "#090909", bg = "#B0B0B0", bold = true })
set_hl(0, "IncSearch", { fg = "#090909", bg = "#FFFFFF", bold = true })

-- --- The Colored Accent Groups ---
-- Muted steel blue for comments
set_hl(0, "Comment", { fg = "#788CA0", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#788CA0", bg = "NONE", italic = true })

-- Muted sage green for strings
set_hl(0, "String", { fg = "#8FA18F", bg = "NONE" })

-- Sky Blue for Functions (The 'Actions')
set_hl(0, "Function", { fg = "#61AFEF", bg = "NONE" })

-- Muted Cyan for Types and Classes
set_hl(0, "Type", { fg = "#56B6C2", bg = "NONE", bold = true })

-- Muted Clay/Sand for Keywords (The 'Structure')
set_hl(0, "Keyword", { fg = "#B08A70", bg = "NONE", bold = true })

-- --- Neutralizing Remaining Elements ---
set_hl(0, "Identifier", { link = "Normal" })
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
set_hl(0, "Directory", { link = "Function" })

-- Linking keyword-adjacent groups
set_hl(0, "Conditional", { link = "Keyword" })
set_hl(0, "Repeat", { link = "Keyword" })
set_hl(0, "Statement", { link = "Keyword" })
set_hl(0, "Exception", { link = "Keyword" })
set_hl(0, "Label", { link = "Keyword" })
set_hl(0, "StorageClass", { link = "Type" })
set_hl(0, "Structure", { link = "Type" })
set_hl(0, "Typedef", { link = "Type" })

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

set_hl(0, "@function", { link = "Function" })
set_hl(0, "@function.builtin", { link = "Function" })
set_hl(0, "@function.macro", { link = "Function" })
set_hl(0, "@function.method", { link = "Function" })

set_hl(0, "@type", { link = "Type" })
set_hl(0, "@type.builtin", { link = "Type" })
set_hl(0, "@storageclass", { link = "Type" })
set_hl(0, "@constructor", { link = "Type" })

set_hl(0, "@keyword", { link = "Keyword" })
set_hl(0, "@keyword.function", { link = "Keyword" })
set_hl(0, "@keyword.return", { link = "Keyword" })

set_hl(0, "@string", { link = "String" })
set_hl(0, "@comment", { link = "Comment" })

set_hl(0, "@operator", { link = "Muted" })
set_hl(0, "@punctuation.delimiter", { link = "Muted" })
set_hl(0, "@punctuation.bracket", { link = "Muted" })

-- Pop-up Menu
set_hl(0, "Pmenu", { fg = "#A0A0A0", bg = "#141414" })
set_hl(0, "PmenuSel", { fg = "#FFFFFF", bg = "#262626", bold = true })
set_hl(0, "FloatBorder", { fg = "#303030", bg = "#090909" })
set_hl(0, "NormalFloat", { fg = "#B0B0B0", bg = "#090909" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#805555" })
set_hl(0, "DiagnosticWarn", { fg = "#807055" })
set_hl(0, "DiagnosticInfo", { fg = "#556680" })
set_hl(0, "DiagnosticHint", { fg = "#558070" })
