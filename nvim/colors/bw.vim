runtime! colors/default.vim
let g:colors_name = 'bw-enhanced'

set background=dark

highlight Normal     guifg=#C0C0C0 guibg=#151515
highlight StatusLine   guifg=#C0C0C0 guibg=#121212
highlight StatusLineNC guifg=#666666 guibg=#000000
highlight ColorColumn  guibg=#141414
highlight CursorLine   guibg=#151515
highlight Visual       guifg=NONE    guibg=#382642      " muted purple tint
highlight String          guifg=#8FBFB2
highlight Character    guifg=#B89AD8
highlight Type         guifg=#86B8E0
highlight StorageClass guifg=#86B8E0
highlight Structure    guifg=#86B8E0
highlight Typedef      guifg=#86B8E0
highlight Function     guifg=#FFFFFF
highlight Constant     guifg=#98BC99
highlight Number       guifg=#98BC99
highlight Boolean      guifg=#98BC99
highlight Float        guifg=#98BC99
highlight Statement    guifg=#B09AE0
highlight Conditional  guifg=#B09AE0
highlight Repeat       guifg=#B09AE0
highlight Label        guifg=#B09AE0
highlight Keyword      guifg=#B09AE0
highlight Exception    guifg=#B09AE0
highlight PreProc      guifg=#70A0A0
highlight Include      guifg=#70A0A0
highlight Define       guifg=#70A0A0
highlight Macro        guifg=#70A0A0
highlight PreCondit    guifg=#70A0A0

highlight Special      guifg=#70A0A0
highlight SpecialChar  guifg=#70A0A0
highlight Tag          guifg=#70A0A0
highlight Delimiter    guifg=#70A0A0
highlight Operator     guifg=#86B8E0 " Linked to Blue (or use #70A0A0 for teal)

highlight Directory    guifg=#B09AE0
highlight Title        guifg=#B09AE0 gui=bold

highlight! link Identifier Normal

highlight Comment         guifg=#9BB6D1 guibg=#1A2430 gui=italic
highlight SpecialComment  guifg=#A7BED6 guibg=#1A2430 gui=italic
highlight! link Debug Normal

highlight! link @namespace Normal
highlight! link @module Normal
highlight! link @module.builtin Normal
highlight! link @constructor Type
highlight! link @identifier Normal

highlight! link @variable Normal
highlight! link @property.lua Normal
highlight! link @field.lua Normal
highlight! link @variable.member.builtin Normal
highlight! link @config Normal
highlight! link @label.lua Normal
highlight! link @namespace.lua Normal

highlight! link @type Type
highlight! link @keyword Statement
highlight! link @string String
highlight! link @number Constant
highlight! link @boolean Constant
highlight! link @operator Operator
highlight! link @punctuation.delimiter Delimiter
highlight! link @punctuation.bracket Delimiter

highlight! Pmenu       guibg=#151515 guifg=#C8C8C8
highlight! PmenuSel    guibg=#2A2A2A guifg=#F0F0F0 gui=bold
highlight! PmenuSbar   guibg=#151515
highlight! PmenuThumb  guibg=#383838

highlight! NvimPickerNormal        guifg=#C8C8C8 guibg=#141414
highlight! NvimPickerBorder        guifg=#3C3C3C guibg=#141414
highlight! NvimPickerSelected      guifg=#F0F0F0 guibg=#2A2A2A gui=bold
highlight! NvimPickerHeader        guifg=#D8D8D8 guibg=#141414 gui=bold
highlight! NvimPickerHeaderBorder  guifg=#3C3C3C guibg=#141414

highlight! FloatBorder   guifg=#474747 guibg=#151515
highlight! FloatTitle    guifg=#E6E6E6 guibg=#151515 gui=bold
highlight! NormalFloat   guifg=#C8C8C8 guibg=#151515
highlight! FloatShadow           guibg=#000000 blend=80
highlight! FloatShadowThrough    guibg=#000000 blend=100

highlight LineNr        guifg=#666666 guibg=#151515
highlight CursorLineNr  guifg=#98BC99 guibg=#151515 gui=bold
highlight NonText       guifg=#2A2A2A guibg=#151515
highlight VertSplit     guifg=#1A1A1A guibg=#151515
highlight SignColumn    guifg=#505050 guibg=#151515

highlight Search        guifg=#E6E6E6 guibg=#274252
highlight IncSearch     guifg=#E6E6E6 guibg=#3A5A6E gui=bold

highlight Todo          guifg=#E6E6E6 guibg=#504060 gui=bold

highlight DiagnosticError guifg=#D88A8A 
highlight DiagnosticWarn  guifg=#D3B07A 
highlight DiagnosticInfo  guifg=#8FB6D8
highlight DiagnosticHint  guifg=#98BC99

highlight DiagnosticUnderlineError gui=undercurl guisp=#D88A8A
highlight DiagnosticUnderlineWarn  gui=undercurl guisp=#D3B07A
highlight DiagnosticUnderlineInfo  gui=undercurl guisp=#8FB6D8
highlight DiagnosticUnderlineHint  gui=undercurl guisp=#98BC99
