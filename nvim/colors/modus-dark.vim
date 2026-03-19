" colors/modus_dark.vim
set background=dark
runtime! colors/default.vim
let g:colors_name = 'modus_dark'

" -----------------------------------------------------
" Core UI
" -----------------------------------------------------
highlight Normal guifg=#ffffff guibg=#070707
highlight StatusLine guifg=#a8b5c0 guibg=#232323
highlight StatusLineNC guifg=#a8b5c0 guibg=#303030

highlight! CursorLine guibg=#2f3849 gui=NONE
highlight! CursorColumn guibg=#2f3849

highlight! LineNr guifg=#989898 guibg=#1e1e1e
highlight! CursorLineNr guifg=#ffffff guibg=#535353 gui=NONE

highlight! VertSplit guifg=#646464 guibg=#000000
highlight! SignColumn guifg=#989898 guibg=#000000
highlight! FoldColumn guifg=#989898 guibg=#000000
highlight! Folded guifg=#989898 guibg=#1e1e1e

highlight! TabLineFill guifg=#989898 guibg=#313131
highlight! TabLine guifg=#989898 guibg=#545454
highlight! TabLineSel guifg=#ffffff guibg=#000000

highlight! ColorColumn guibg=#1e1e1e

highlight! Visual guibg=#5a5a5a guifg=NONE
highlight! VisualNOS guibg=#5a5a5a guifg=NONE

" -----------------------------------------------------
" Comments & documentation
" -----------------------------------------------------
highlight! Comment guifg=#989898 gui=italic cterm=italic
highlight! TodoFgTODO guifg=#ff5f59 gui=italic
highlight! TodoBgTODO guifg=#000000 guibg=#7a6100 gui=italic

highlight! docstring guifg=#9ac8e0

highlight! docmarkup guifg=#caa6df

" -----------------------------------------------------
" Syntax (KEEP EVERYTHING AS ORIGINAL — except variables)
" -----------------------------------------------------

" keywords (keep blue-warmer)
highlight! Keyword guifg=#79a8ff gui=NONE
highlight! Statement guifg=#79a8ff gui=NONE

" strings (keep blue)
highlight! String guifg=#2fafff
highlight! Character guifg=#2fafff

" constants (keep magenta-cooler)
highlight! Constant guifg=#b6a0ff
highlight! Number guifg=#ffffff
highlight! Float guifg=#ffffff
highlight! Boolean guifg=#b6a0ff

" builtin (keep magenta)
highlight! Module guifg=#feacd0 gui=italic
highlight! Special guifg=#feacd0

" function names (keep magenta-warmer)
highlight! Function guifg=#f78fe7 gui=NONE

" types (keep green-cooler)
highlight! Type guifg=#6ae4b9                    " type (cyan-cooler)
highlight! Typedef guifg=#11c777 gui=NONE
highlight! StorageClass guifg=#11c777

" operators (white)
highlight! Operator guifg=#ffffff
highlight! Delimiter guifg=#ffffff
highlight! Directory guifg=#c6daff

" ---------------------------
" VARIABLES = WHITE  (your request)
" ---------------------------
highlight! Identifier guifg=#ffffff

" Tree-sitter variable families
highlight! @variable guifg=#ffffff
highlight! @variable.builtin guifg=#ffffff
highlight! @variable.member guifg=#ffffff
highlight! @variable.parameter guifg=#ffffff

" Go-specific TS groups (important for your screenshot)
highlight! @parameter.go guifg=#ffffff
highlight! @variable.go guifg=#ffffff
highlight! @field.go guifg=#ffffff
highlight! @property.go guifg=#ffffff

" generic field/property
highlight! @field guifg=#ffffff
highlight! @property guifg=#ffffff

" attribute / labels
highlight! @attribute guifg=#ffffff

" namespace / module remain colored
highlight! @namespace guifg=#c6daff
highlight! @module guifg=#feacd0
highlight! @module.builtin guifg=#feacd0

" strings
highlight! @string guifg=#2fafff
highlight! @string.special.path guifg=#2fafff

" constructors, functions, methods keep original meaning
highlight! @constructor guifg=#11c777
highlight! @function guifg=#f78fe7
highlight! @function.builtin guifg=#feacd0
highlight! @method guifg=#f78fe7
highlight! @method.call guifg=#f78fe7

" -----------------------------------------------------
" Diagnostics / LSP
" -----------------------------------------------------
highlight! DiagnosticError guifg=#ff5f59
highlight! DiagnosticWarn  guifg=#fec43f
highlight! DiagnosticInfo  guifg=#00d3d0
highlight! DiagnosticHint  guifg=#88ca9f

highlight! DiagnosticUnderlineError gui=underline guisp=#ff5f5f
highlight! DiagnosticUnderlineWarn  gui=underline guisp=#d0bc00
highlight! DiagnosticUnderlineInfo  gui=underline guisp=#00d3d0
highlight! DiagnosticUnderlineHint  gui=underline guisp=#44df44

highlight! LspReferenceText  guibg=#042837
highlight! LspReferenceRead  guibg=#042837
highlight! LspReferenceWrite guibg=#12154a

" -----------------------------------------------------
" Search
" -----------------------------------------------------
highlight! Search guifg=#000000 guibg=#7a6100
highlight! IncSearch guifg=#000000 guibg=#2266ae
highlight! CurSearch guifg=#000000 guibg=#7a6100
highlight! Substitute guifg=#ffffff guibg=#9d1f1f

" Parens
highlight! MatchParen guifg=#ffffff guibg=#4f7f9f gui=bold

" -----------------------------------------------------
" Diff
" -----------------------------------------------------
highlight! DiffAdd guifg=#a0e0a0 guibg=#00381f
highlight! DiffChange guifg=#efef80 guibg=#363300
highlight! DiffDelete guifg=#ffbfbf guibg=#4f1119
highlight! DiffText guifg=#ffffff guibg=#4a4a00 gui=NONE

" -----------------------------------------------------
" Messages
" -----------------------------------------------------
highlight! ErrorMsg guifg=#ffffff guibg=#9d1f1f
highlight! WarningMsg guifg=#000000 guibg=#7a6100
highlight! MoreMsg guifg=#44bc44 guibg=#000000
highlight! Question guifg=#00d3d0 guibg=#000000

" -----------------------------------------------------
" Popup menus
" -----------------------------------------------------
highlight! Pmenu guibg=#16181a ctermbg=0
highlight! PmenuSel guibg=#2a2d30 ctermbg=233 guifg=#a8b5c0 ctermfg=67
highlight! PmenuSbar guibg=#16181a ctermbg=232
highlight! PmenuThumb guibg=#2a2d30 ctermbg=234

" -----------------------------------------------------
" Cursor
" -----------------------------------------------------
highlight! Cursor guifg=#000000 guibg=#ff66ff

" -----------------------------------------------------
" Quickfix
" -----------------------------------------------------
highlight! QuickFixLine guifg=#ffffff guibg=#45605e
highlight! qfLineNr guifg=#c6daff guibg=#45605e

" -----------------------------------------------------
" Terminal cursor
" -----------------------------------------------------
highlight! TermCursor guifg=#000000 guibg=#ffffff
highlight! TermCursorNC guifg=#000000 guibg=#595959

highlight! NormalNC guifg=#ffffff guibg=#000000

highlight! FloatBorder guifg=#2a2d30 guibg=#16181a
highlight! FloatTitle guifg=#a8b5c0 guibg=#16181a gui=NONE
highlight! NormalFloat guifg=NvimLightGrey2 guibg=#16181a
highlight! FloatShadow guibg=#0a0c0e blend=80
highlight! FloatShadowThrough guibg=#0a0c0e blend=100
