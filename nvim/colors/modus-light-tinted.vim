" modus-operandi-tinted for Vim/Neovim (light)

set background=light
runtime! colors/default.vim
let g:colors_name = 'modus-light-tinted'

" Core UI
highlight Normal guifg=#000000 guibg=#e5dfd3
highlight StatusLine guifg=#000000 guibg=#cab9b2
highlight StatusLineNC guifg=#585858 guibg=#dfd9cf

" Basic syntax
highlight! Function guifg=#602938 gui=NONE           " fnname (yellow-cooler)
highlight! Title guifg=#000000                       " heading-ish
highlight! Identifier guifg=#574316                  " identifier (yellow-faint)
highlight! Delimiter guifg=#000000
highlight! Directory guifg=#193668 gui=NONE          " fg-alt
highlight! Module guifg=#721045 cterm=italic gui=italic
highlight! Special guifg=#721045                     " builtin/special (magenta)
highlight! link Namespace Module
highlight! Type guifg=#306010                        " type (green-warmer)
highlight! Number guifg=#000000 ctermfg=60           " number
highlight! link Float Number
highlight! link Constructor Type
highlight! link Character String
highlight! Constant guifg=#531ab6                    " constant (magenta-cooler)
highlight! Operator guifg=#000000
highlight! ColorColumn guibg=#efe9dd                 " bg-dim
highlight! String guifg=#00598b                      " string (cyan)
highlight! Keyword guifg=#0031a9 ctermfg=67 gui=NONE " keyword (blue)

" Treesitter-style links
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

" Comments & TODO
highlight! Comment guifg=#7f0000 ctermfg=65 gui=italic cterm=italic " comment (red-faint)
highlight! TodoFgTODO guifg=#a60000 ctermfg=65 gui=italic cterm=italic " prose-todo (red)
highlight! TodoBgTODO guifg=#000000 guibg=#f3d000 ctermfg=65 gui=italic cterm=italic " bg-yellow-intense

" Popup menu
highlight! Pmenu guifg=#000000 guibg=#f0c1cf ctermbg=0               " bg-completion
highlight! PmenuSel guifg=#000000 guibg=#b2e4dc ctermbg=233 ctermfg=67 " bg-hover
highlight! PmenuSbar guibg=#efe9dd ctermbg=232                       " bg-dim
highlight! PmenuThumb guibg=#c9b9b0 ctermbg=234                      " bg-active

" Nvim Picker
highlight! NvimPickerNormal guifg=#000000 guibg=#efe9dd              " fg-main / bg-dim
highlight! NvimPickerBorder guifg=#9f9690 guibg=#efe9dd              " border / bg-dim
highlight! NvimPickerSelected guifg=#000000 guibg=#b2e4dc gui=NONE   " bg-hover
highlight! NvimPickerHeader guifg=#000000 guibg=#efe9dd gui=NONE
highlight! NvimPickerHeaderBorder guifg=#9f9690 guibg=#efe9dd

" Floating windows
highlight! FloatBorder guifg=#9f9690 guibg=#efe9dd
highlight! FloatTitle guifg=#000000 guibg=#efe9dd gui=NONE
highlight! NormalFloat guifg=#000000 guibg=#efe9dd
highlight! FloatShadow guibg=#c9b9b0 blend=80         " bg-active
highlight! FloatShadowThrough guibg=#c9b9b0 blend=100

" Variable and property links
highlight! link @variable.member Identifier
highlight! link @variable.member.lua Identifier
highlight! link @property.lua Identifier
highlight! link @field.lua Identifier
highlight! @variable.member.builtin guifg=#00603f     " variable (green-cooler)
highlight! @config guifg=#00603f
highlight! link @method.call Identifier
highlight! link @method Identifier
highlight! link @label.lua Identifier
highlight! @variable.builtin guifg=#00603f
highlight! @namespace.lua guifg=#193668               " fg-alt
highlight! @module.builtin guifg=#721045              " magenta
highlight! @variable guifg=#00603f                    " variable (green-cooler)

" Diff
highlight! DiffAdd guifg=#005000 guibg=#c3ebc1        " fg-added / bg-added
highlight! DiffChange guifg=#553d00 guibg=#ffdfa9     " fg-changed / bg-changed
highlight! DiffDelete guifg=#8f1313 guibg=#f4d0cf     " fg-removed / bg-removed
highlight! DiffText guifg=#000000 guibg=#fac090 gui=NONE " bg-changed-refine

" Preprocessor & statements
highlight! PreProc guifg=#894000                      " preprocessor (yellow-warmer)
highlight! Statement guifg=#0031a9                    " keyword/statement (blue)

" Line numbers
highlight! LineNr guifg=#595959 guibg=#efe9dd         " fg-dim / bg-dim
highlight! CursorLineNr guifg=#000000 guibg=#c9b9b0 gui=NONE " fg-main / bg-active

" Diagnostics (LSP)
highlight! DiagnosticError guifg=#a60000 guibg=NONE   " err (red)
highlight! DiagnosticWarn  guifg=#6d5000 guibg=NONE   " warning (yellow)
highlight! DiagnosticInfo  guifg=#006300 guibg=NONE   " info (green)
highlight! DiagnosticHint  guifg=#2a5045 guibg=NONE   " green-faint

highlight! DiagnosticUnderlineError gui=underline guisp=#d00000  " underline-err (red-intense)
highlight! DiagnosticUnderlineWarn  gui=underline guisp=#808000  " underline-warning (yellow-intense)
highlight! DiagnosticUnderlineInfo  gui=underline guisp=#008899  " underline-note (cyan-intense)
highlight! DiagnosticUnderlineHint  gui=underline guisp=#008900  " green-intense

" LSP references
highlight! LspReferenceText guibg=#e0f2fa guifg=NONE  " bg-cyan-nuanced
highlight! LspReferenceRead guibg=#e0f2fa guifg=NONE
highlight! LspReferenceWrite guibg=#ecedff guifg=NONE " bg-blue-nuanced

" Visual selection
highlight! Visual guibg=#c2bcb5 guifg=NONE            " bg-region
highlight! VisualNOS guibg=#c2bcb5 guifg=NONE
