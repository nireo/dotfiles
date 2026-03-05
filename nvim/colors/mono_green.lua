vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "mono_green"

vim.o.background = "dark"

-- Base colors
set_hl(0, "Normal", { fg = "#A9B5A4", bg = "#0E1511" })
set_hl(0, "BoldKeyword", { fg = "#D6E0D2", bg = "NONE", bold = true })
set_hl(0, "Muted", { fg = "#6C776D", bg = "NONE" })

-- UI Elements
set_hl(0, "LineNr", { fg = "#4C5A50", bg = "#0E1511" })
set_hl(0, "CursorLine", { bg = "#141E17" })
set_hl(0, "CursorLineNr", { fg = "#B0BDB0", bg = "#0E1511", bold = true })
set_hl(0, "ColorColumn", { bg = "#111B14" })
set_hl(0, "SignColumn", { bg = "#0E1511" })
set_hl(0, "VertSplit", { fg = "#1F2A22", bg = "#0E1511" })
set_hl(0, "WinSeparator", { fg = "#1F2A22", bg = "#0E1511" })
set_hl(0, "StatusLine", { fg = "#9FAA9F", bg = "#19231C" })
set_hl(0, "StatusLineNC", { fg = "#5B665D", bg = "#0E1511" })

-- Selection and Search
set_hl(0, "Visual", { bg = "#243126" })
set_hl(0, "Search", { fg = "#0E1511", bg = "#B8C4B3", bold = true })
set_hl(0, "IncSearch", { fg = "#0E1511", bg = "#DCE4D6", bold = true })

-- --- The Only Colored Groups ---
-- Muted dusty blue for comments
set_hl(0, "Comment", { fg = "#7D8F9C", bg = "NONE", italic = true })
set_hl(0, "SpecialComment", { fg = "#7D8F9C", bg = "NONE", italic = true })
-- Soft sage green for strings
set_hl(0, "String", { fg = "#86A181", bg = "NONE" })

-- --- Neutralizing Everything Else ---
set_hl(0, "Identifier", { link = "Normal" })
set_hl(0, "Function", { fg = "#87B094", bg = "NONE" })
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
set_hl(0, "@function", { link = "Function" })
set_hl(0, "@function.builtin", { link = "Function" })
set_hl(0, "@function.macro", { link = "Function" })
set_hl(0, "@function.method", { link = "Function" })
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
set_hl(0, "Pmenu", { fg = "#9FAA9F", bg = "#19231C" })
set_hl(0, "PmenuSel", { fg = "#0E1511", bg = "#B8C4B3", bold = true })
set_hl(0, "FloatBorder", { fg = "#2E3A31", bg = "#0E1511" })
set_hl(0, "NormalFloat", { fg = "#B8C4B3", bg = "#0E1511" })

-- Diagnostics
set_hl(0, "DiagnosticError", { fg = "#9A6A6A" })
set_hl(0, "DiagnosticWarn", { fg = "#9A8562" })
set_hl(0, "DiagnosticInfo", { fg = "#6A7F96" })
set_hl(0, "DiagnosticHint", { fg = "#6A8A78" })
