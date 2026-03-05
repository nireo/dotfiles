vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

local set_hl = vim.api.nvim_set_hl

-- modus-operandi-tinted for Vim/Neovim (light)

vim.o.background = "light"
vim.g.colors_name = "modus-light-tinted"

-- Core UI
set_hl(0, "Normal", { fg = "#000000", bg = "#e5dfd3" })
set_hl(0, "StatusLine", { fg = "#000000", bg = "#cab9b2" })
set_hl(0, "StatusLineNC", { fg = "#585858", bg = "#dfd9cf" })

-- Basic syntax
set_hl(0, "Function", { fg = "#602938" })
set_hl(0, "Title", { fg = "#000000" })
set_hl(0, "Identifier", { fg = "#574316" })
set_hl(0, "Delimiter", { fg = "#000000" })
set_hl(0, "Directory", { fg = "#193668" })
set_hl(0, "Module", { fg = "#721045", italic = true })
set_hl(0, "Special", { fg = "#721045" })
set_hl(0, "Namespace", { link = "Module" })
set_hl(0, "Type", { fg = "#306010" })
set_hl(0, "Number", { fg = "#000000" })
set_hl(0, "Float", { link = "Number" })
set_hl(0, "Constructor", { link = "Type" })
set_hl(0, "Character", { link = "String" })
set_hl(0, "Constant", { fg = "#531ab6" })
set_hl(0, "Operator", { fg = "#000000" })
set_hl(0, "ColorColumn", { bg = "#efe9dd" })
set_hl(0, "String", { fg = "#00598b" })
set_hl(0, "Keyword", { fg = "#0031a9" })

-- Treesitter-style links
set_hl(0, "@namespace", { link = "Namespace" })
set_hl(0, "@module", { link = "Module" })
set_hl(0, "@module.builtin", { link = "Module" })
set_hl(0, "@string.special.path", { link = "Underlined" })
set_hl(0, "@constructor", { link = "Constructor" })
set_hl(0, "@identifier", { link = "Identifier" })
set_hl(0, "@type.builtin", { link = "@type" })
set_hl(0, "@variable.builtin", { link = "@variable" })
set_hl(0, "@constant.builtin", { link = "@constant" })
set_hl(0, "@function.builtin", { link = "@function" })
set_hl(0, "@tag.attribute", { link = "@attribute" })
set_hl(0, "@keyword.function", { link = "Keyword" })
set_hl(0, "@keyword.operator", { link = "Keyword" })
set_hl(0, "@keyword.return", { link = "Keyword" })
set_hl(0, "@string", { link = "String" })

-- Comments & TODO
set_hl(0, "Comment", { fg = "#7f0000", italic = true })
set_hl(0, "TodoFgTODO", { fg = "#a60000", italic = true })
set_hl(0, "TodoBgTODO", { fg = "#000000", bg = "#f3d000", italic = true })

-- Popup menu
set_hl(0, "Pmenu", { fg = "#000000", bg = "#f0c1cf" })
set_hl(0, "PmenuSel", { fg = "#000000", bg = "#b2e4dc" })
set_hl(0, "PmenuSbar", { bg = "#efe9dd" })
set_hl(0, "PmenuThumb", { bg = "#c9b9b0" })

-- Nvim Picker
set_hl(0, "NvimPickerNormal", { fg = "#000000", bg = "#efe9dd" })
set_hl(0, "NvimPickerBorder", { fg = "#9f9690", bg = "#efe9dd" })
set_hl(0, "NvimPickerSelected", { fg = "#000000", bg = "#b2e4dc" })
set_hl(0, "NvimPickerHeader", { fg = "#000000", bg = "#efe9dd" })
set_hl(0, "NvimPickerHeaderBorder", { fg = "#9f9690", bg = "#efe9dd" })

-- Floating windows
set_hl(0, "FloatBorder", { fg = "#9f9690", bg = "#efe9dd" })
set_hl(0, "FloatTitle", { fg = "#000000", bg = "#efe9dd" })
set_hl(0, "NormalFloat", { fg = "#000000", bg = "#efe9dd" })
set_hl(0, "FloatShadow", { bg = "#c9b9b0", blend = 80 })
set_hl(0, "FloatShadowThrough", { bg = "#c9b9b0", blend = 100 })

-- Variable and property links
set_hl(0, "@variable.member", { link = "Identifier" })
set_hl(0, "@variable.member.lua", { link = "Identifier" })
set_hl(0, "@property.lua", { link = "Identifier" })
set_hl(0, "@field.lua", { link = "Identifier" })
set_hl(0, "@variable.member.builtin", { fg = "#00603f" })
set_hl(0, "@config", { fg = "#00603f" })
set_hl(0, "@method.call", { link = "Identifier" })
set_hl(0, "@method", { link = "Identifier" })
set_hl(0, "@label.lua", { link = "Identifier" })
set_hl(0, "@variable.builtin", { fg = "#00603f" })
set_hl(0, "@namespace.lua", { fg = "#193668" })
set_hl(0, "@module.builtin", { fg = "#721045" })
set_hl(0, "@variable", { fg = "#00603f" })

-- Diff
set_hl(0, "DiffAdd", { fg = "#005000", bg = "#c3ebc1" })
set_hl(0, "DiffChange", { fg = "#553d00", bg = "#ffdfa9" })
set_hl(0, "DiffDelete", { fg = "#8f1313", bg = "#f4d0cf" })
set_hl(0, "DiffText", { fg = "#000000", bg = "#fac090" })

-- Preprocessor & statements
set_hl(0, "PreProc", { fg = "#894000" })
set_hl(0, "Statement", { fg = "#0031a9" })

-- Line numbers
set_hl(0, "LineNr", { fg = "#595959", bg = "#efe9dd" })
set_hl(0, "CursorLineNr", { fg = "#000000", bg = "#c9b9b0" })

-- Diagnostics (LSP)
set_hl(0, "DiagnosticError", { fg = "#a60000", bg = "NONE" })
set_hl(0, "DiagnosticWarn", { fg = "#6d5000", bg = "NONE" })
set_hl(0, "DiagnosticInfo", { fg = "#006300", bg = "NONE" })
set_hl(0, "DiagnosticHint", { fg = "#2a5045", bg = "NONE" })

set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = "#d00000" })
set_hl(0, "DiagnosticUnderlineWarn", { underline = true, sp = "#808000" })
set_hl(0, "DiagnosticUnderlineInfo", { underline = true, sp = "#008899" })
set_hl(0, "DiagnosticUnderlineHint", { underline = true, sp = "#008900" })

-- LSP references
set_hl(0, "LspReferenceText", { bg = "#e0f2fa", fg = "NONE" })
set_hl(0, "LspReferenceRead", { bg = "#e0f2fa", fg = "NONE" })
set_hl(0, "LspReferenceWrite", { bg = "#ecedff", fg = "NONE" })

-- Visual selection
set_hl(0, "Visual", { bg = "#c2bcb5", fg = "NONE" })
set_hl(0, "VisualNOS", { bg = "#c2bcb5", fg = "NONE" })
