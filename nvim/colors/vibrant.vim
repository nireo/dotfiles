set background=dark
runtime! colors/default.vim
let g:colors_name = 'vibrant'

"highlight Normal guifg=#D6CFC4 guibg=#101010
highlight Normal guifg=#D6CFC4 guibg=#0e1415
highlight StatusLine guifg=#D6CFC4 guibg=#101010
highlight StatusLineNC guifg=#D6CFC4 guibg=#202020
highlight! Function guifg=#7DADA8
highlight! Title guifg=#A8D89E
highlight! Identifier guifg=#D6CFC4
highlight! Delimiter guifg=#D6CFC4
highlight! Directory guifg=#98C98A
highlight! Module cterm=italic gui=italic
highlight! Special guifg=#98C98A
highlight! link Namespace Module
highlight! Type guifg=#90C0D0
highlight! Number guifg=#8EAAC5 ctermfg=60
highlight! link Float Number
highlight! link Constructor Type
highlight! link Character String
highlight! Constant guifg=#8EAAC5
highlight! Operator guifg=#A8D89E
highlight! ColorColumn guibg=#0A0A0A
highlight! String guifg=#95D095
highlight! Keyword guifg=#9CD99C ctermfg=67
highlight! link @namespace Namespace
highlight! link @module Module
highlight! link @module.builtin Module
highlight! link @string.special.path Underlined
highlight! link @constructor Constructor
highlight! link @identifier Identifier
highlight! link @type.builtin @type
highlight! link @variable.builtin @variable
highlight! link @constant.builtin @constant
highlight! link @function.builtin @function
highlight! link @tag.attribute @attribute
highlight! link @keyword.function Keyword
highlight! link @keyword.operator Keyword
highlight! link @keyword.return Keyword
highlight! link @string String
highlight! Comment guifg=#9B9B7A ctermfg=65 gui=italic cterm=italic
highlight! TodoFgTODO guifg=#BED1A8 ctermfg=65 gui=italic cterm=italic
highlight! TodoBgTODO guifg=#0e1415 guibg=#BED1A8 ctermfg=65 gui=italic cterm=italic
highlight! Pmenu guibg=#0e1415 ctermbg=0
highlight! PmenuSel guibg=#1D1D1D ctermbg=233 guifg=#9CD99C ctermfg=67
highlight! PmenuSbar guibg=#121212 ctermbg=232
highlight! PmenuThumb guibg=#2A2A2A ctermbg=234
highlight! NvimPickerNormal guifg=NvimLightGrey2 guibg=#121212
highlight! NvimPickerBorder guifg=#2A2A2A guibg=#121212
highlight! NvimPickerSelected guifg=#9CD99C guibg=#1D1D1D gui=bold
highlight! NvimPickerHeader guifg=#8AA070 guibg=#121212 gui=bold
highlight! NvimPickerHeaderBorder guifg=#2A2A2A guibg=#121212

" Floating windows
highlight! FloatBorder guifg=#2A2A2A guibg=#0e1415
highlight! FloatTitle guifg=#8AA070 guibg=#0e1415 gui=bold
highlight! NormalFloat guifg=NvimLightGrey2 guibg=#0e1415
highlight! FloatShadow guibg=#050505 blend=80
highlight! FloatShadowThrough guibg=#050505 blend=100

" Variable and property links
highlight! link @variable.member Identifier
highlight! link @variable.member.lua Identifier
highlight! link @property.lua Identifier
highlight! link @field.lua Identifier
highlight! @variable.member.builtin guifg=#D6CFC4
highlight! @config guifg=#D6CFC4
highlight! link @method.call Identifier
highlight! link @method Identifier
highlight! link @label.lua Identifier
highlight! @variable.builtin guifg=#D6CFC4
highlight! @namespace.lua guifg=#D6CFC4
highlight! @module.builtin guifg=#D6CFC4
highlight! @variable guifg=#D6CFC4

highlight! DiffAdd guifg=#6B8B6B guibg=#1A2B1A
highlight! DiffChange guifg=#7B7B6B guibg=#252520
highlight! DiffDelete guifg=#8B6B6B guibg=#2B1A1A
highlight! DiffText guifg=#8B8B7B guibg=#2B2B20 gui=bold
