runtime! colors/default.vim
let g:colors_name = 'mono_muted'

set background=dark

" --- Core Palette (Warm Stone High Contrast) ---
" Background:   #110E0C
" Foreground:   #D2C7BA (Warm Light Gray)
" Keyword:      #B1967C (Stone Brown)
" Type/Label:   #A29A90 (Dusty Slate)
" Comment:      #8A7D71 (Soft Brown Gray)
" String:       #F0E4D7 (Warm Off-white)
" Punctuation:  #7A6E62 (Muted Umber)

" Base colors
highlight Normal          guifg=#D2C7BA guibg=#110E0C
highlight BoldKeyword    guifg=#B1967C guibg=NONE    gui=bold
highlight SlateKeyword   guifg=#A29A90 guibg=NONE    gui=NONE
highlight Muted          guifg=#7A6E62 guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#5E544C guibg=#110E0C
highlight CursorLine      guibg=#1A1512
highlight CursorLineNr    guifg=#B1967C guibg=#110E0C gui=bold
highlight ColorColumn     guibg=#181310
highlight SignColumn      guibg=#110E0C
highlight VertSplit       guifg=#2F2823 guibg=#110E0C
highlight WinSeparator    guifg=#2F2823 guibg=#110E0C
highlight StatusLine      guifg=#F2E7DA guibg=#231D18 gui=NONE
highlight StatusLineNC    guifg=#7A6E62 guibg=#110E0C gui=NONE

" Selection and Search
highlight Visual          guibg=#3F3229 gui=NONE
highlight Search          guifg=#110E0C guibg=#B1967C gui=bold
highlight IncSearch       guifg=#110E0C guibg=#F0E4D7 gui=bold

" --- Content ---
highlight Comment        guifg=#8A7D71 guibg=NONE    gui=italic
highlight SpecialComment guifg=#8A7D71 guibg=NONE    gui=italic
highlight String         guifg=#F0E4D7 guibg=NONE    gui=NONE
highlight Constant       guifg=#D2C7BA guibg=NONE    gui=NONE
highlight Number         guifg=#D2C7BA guibg=NONE    gui=NONE
highlight Boolean        guifg=#D2C7BA guibg=NONE    gui=NONE

" --- Links ---
highlight! link Identifier    Normal
highlight! link Function      Normal
highlight! link Special       Normal
highlight! link Character     Normal
highlight! link PreProc       Normal
highlight! link Include       Normal
highlight! link Define        Normal
highlight! link Macro         Normal
highlight! link PreCondit     Normal
highlight! link SpecialChar   Normal
highlight! link Tag           Normal
highlight! link Title         Normal
highlight! link Directory     Normal

" Keyword Accents
highlight! link Keyword        BoldKeyword
highlight! link Conditional    BoldKeyword
highlight! link Repeat         BoldKeyword
highlight! link Statement      BoldKeyword
highlight! link Exception      BoldKeyword

" Type/Structure Accents
highlight! link Type           SlateKeyword
highlight! link StorageClass   SlateKeyword
highlight! link Structure      SlateKeyword
highlight! link Typedef        SlateKeyword
highlight! link Label          SlateKeyword

" Muted Punctuation
highlight! link Delimiter      Muted
highlight! link Operator       Muted

" --- Treesitter Overrides ---
highlight! link @variable           Normal
highlight! link @variable.builtin    Normal
highlight! link @variable.member     Normal
highlight! link @constant           Normal
highlight! link @constant.builtin    Normal
highlight! link @tag                Normal
highlight! link @tag.attribute       Normal
highlight! link @tag.delimiter       Muted
highlight! link @namespace           Normal
highlight! link @module              Normal
highlight! link @function            Normal
highlight! link @function.builtin    Normal
highlight! link @function.macro      Normal
highlight! link @function.method     Normal

highlight! link @type                SlateKeyword
highlight! link @type.builtin        SlateKeyword
highlight! link @storageclass        SlateKeyword
highlight! link @constructor         SlateKeyword
highlight! link @keyword             BoldKeyword
highlight! link @keyword.function    BoldKeyword
highlight! link @keyword.return      BoldKeyword

highlight! link @string              String
highlight! link @comment             Comment

highlight! link @operator                Muted
highlight! link @punctuation.delimiter  Muted
highlight! link @punctuation.bracket    Muted

" Pop-up Menu
highlight Pmenu          guifg=#CFC4B8 guibg=#1E1915
highlight PmenuSel       guifg=#FFF3E7 guibg=#3F3229 gui=bold
highlight FloatBorder    guifg=#4A4038 guibg=#110E0C
highlight NormalFloat    guifg=#D2C7BA guibg=#110E0C

" Diagnostics
highlight DiagnosticError guifg=#C7867B
highlight DiagnosticWarn  guifg=#C8A06A
highlight DiagnosticInfo  guifg=#8FA2B6
highlight DiagnosticHint  guifg=#88A28A
