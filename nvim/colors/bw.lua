vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

vim.g.colors_name = "bw-enhanced"

vim.o.background = "dark"

set_hl(0, "Normal", { fg = "#C0C0C0", bg = "#151515" })
set_hl(0, "StatusLine", { fg = "#C0C0C0", bg = "#121212" })
set_hl(0, "StatusLineNC", { fg = "#666666", bg = "#000000" })
set_hl(0, "ColorColumn", { bg = "#141414" })
set_hl(0, "CursorLine", { bg = "#151515" })
set_hl(0, "Visual", { fg = "NONE", bg = "#382642" })
set_hl(0, "String", { fg = "#8FBFB2" })
set_hl(0, "Character", { fg = "#B89AD8" })
set_hl(0, "Type", { fg = "#86B8E0" })
set_hl(0, "StorageClass", { fg = "#86B8E0" })
set_hl(0, "Structure", { fg = "#86B8E0" })
set_hl(0, "Typedef", { fg = "#86B8E0" })
set_hl(0, "Function", { fg = "#FFFFFF" })
set_hl(0, "Constant", { fg = "#98BC99" })
set_hl(0, "Number", { fg = "#98BC99" })
set_hl(0, "Boolean", { fg = "#98BC99" })
set_hl(0, "Float", { fg = "#98BC99" })
set_hl(0, "Statement", { fg = "#B09AE0" })
set_hl(0, "Conditional", { fg = "#B09AE0" })
set_hl(0, "Repeat", { fg = "#B09AE0" })
set_hl(0, "Label", { fg = "#B09AE0" })
set_hl(0, "Keyword", { fg = "#B09AE0" })
set_hl(0, "Exception", { fg = "#B09AE0" })
set_hl(0, "PreProc", { fg = "#70A0A0" })
set_hl(0, "Include", { fg = "#70A0A0" })
set_hl(0, "Define", { fg = "#70A0A0" })
set_hl(0, "Macro", { fg = "#70A0A0" })
set_hl(0, "PreCondit", { fg = "#70A0A0" })

set_hl(0, "Special", { fg = "#70A0A0" })
set_hl(0, "SpecialChar", { fg = "#70A0A0" })
set_hl(0, "Tag", { fg = "#70A0A0" })
set_hl(0, "Delimiter", { fg = "#70A0A0" })
set_hl(0, "Operator", { fg = "#86B8E0" })

set_hl(0, "Directory", { fg = "#B09AE0" })
set_hl(0, "Title", { fg = "#B09AE0", bold = true })

set_hl(0, "Identifier", { link = "Normal" })

set_hl(0, "Comment", { fg = "#9BB6D1", bg = "#1A2430", italic = true })
set_hl(0, "SpecialComment", { fg = "#A7BED6", bg = "#1A2430", italic = true })
set_hl(0, "Debug", { link = "Normal" })

set_hl(0, "@namespace", { link = "Normal" })
set_hl(0, "@module", { link = "Normal" })
set_hl(0, "@module.builtin", { link = "Normal" })
set_hl(0, "@constructor", { link = "Type" })
set_hl(0, "@identifier", { link = "Normal" })

set_hl(0, "@variable", { link = "Normal" })
set_hl(0, "@property.lua", { link = "Normal" })
set_hl(0, "@field.lua", { link = "Normal" })
set_hl(0, "@variable.member.builtin", { link = "Normal" })
set_hl(0, "@config", { link = "Normal" })
set_hl(0, "@label.lua", { link = "Normal" })
set_hl(0, "@namespace.lua", { link = "Normal" })

set_hl(0, "@type", { link = "Type" })
set_hl(0, "@keyword", { link = "Statement" })
set_hl(0, "@string", { link = "String" })
set_hl(0, "@number", { link = "Constant" })
set_hl(0, "@boolean", { link = "Constant" })
set_hl(0, "@operator", { link = "Operator" })
set_hl(0, "@punctuation.delimiter", { link = "Delimiter" })
set_hl(0, "@punctuation.bracket", { link = "Delimiter" })

set_hl(0, "Pmenu", { bg = "#151515", fg = "#C8C8C8" })
set_hl(0, "PmenuSel", { bg = "#2A2A2A", fg = "#F0F0F0", bold = true })
set_hl(0, "PmenuSbar", { bg = "#151515" })
set_hl(0, "PmenuThumb", { bg = "#383838" })

set_hl(0, "NvimPickerNormal", { fg = "#C8C8C8", bg = "#141414" })
set_hl(0, "NvimPickerBorder", { fg = "#3C3C3C", bg = "#141414" })
set_hl(0, "NvimPickerSelected", { fg = "#F0F0F0", bg = "#2A2A2A", bold = true })
set_hl(0, "NvimPickerHeader", { fg = "#D8D8D8", bg = "#141414", bold = true })
set_hl(0, "NvimPickerHeaderBorder", { fg = "#3C3C3C", bg = "#141414" })

set_hl(0, "FloatBorder", { fg = "#474747", bg = "#151515" })
set_hl(0, "FloatTitle", { fg = "#E6E6E6", bg = "#151515", bold = true })
set_hl(0, "NormalFloat", { fg = "#C8C8C8", bg = "#151515" })
set_hl(0, "FloatShadow", { bg = "#000000", blend = 80 })
set_hl(0, "FloatShadowThrough", { bg = "#000000", blend = 100 })

set_hl(0, "LineNr", { fg = "#666666", bg = "#151515" })
set_hl(0, "CursorLineNr", { fg = "#98BC99", bg = "#151515", bold = true })
set_hl(0, "NonText", { fg = "#2A2A2A", bg = "#151515" })
set_hl(0, "VertSplit", { fg = "#1A1A1A", bg = "#151515" })
set_hl(0, "SignColumn", { fg = "#505050", bg = "#151515" })

set_hl(0, "Search", { fg = "#E6E6E6", bg = "#274252" })
set_hl(0, "IncSearch", { fg = "#E6E6E6", bg = "#3A5A6E", bold = true })

set_hl(0, "Todo", { fg = "#E6E6E6", bg = "#504060", bold = true })

set_hl(0, "DiagnosticError", { fg = "#D88A8A" })
set_hl(0, "DiagnosticWarn", { fg = "#D3B07A" })
set_hl(0, "DiagnosticInfo", { fg = "#8FB6D8" })
set_hl(0, "DiagnosticHint", { fg = "#98BC99" })

set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#D88A8A" })
set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#D3B07A" })
set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#8FB6D8" })
set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#98BC99" })
