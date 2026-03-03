runtime! colors/default.vim
let g:colors_name = 'mute_warm_stone'

set background=dark

" --- Core Palette (Warm Stone) ---
" Background:   #14110F
" Foreground:   #BEB5AA (Warm Gray)
" Keyword:      #8A7966 (Stone Brown)
" Type/Label:   #7F7A74 (Dusty Slate)
" Comment:      #665C52 (Soft Brown Gray)
" String:       #DED5CA (Warm Off-white)
" Punctuation:  #544A41 (Muted Umber)

" Base colors
highlight Normal          guifg=#BEB5AA guibg=#14110F
highlight BoldKeyword     guifg=#8A7966 guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#7F7A74 guibg=NONE    gui=NONE
highlight Muted           guifg=#544A41 guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#3D352F guibg=#14110F
highlight CursorLine      guibg=#1B1714
highlight CursorLineNr    guifg=#7F7A74 guibg=#14110F gui=bold
highlight ColorColumn     guibg=#191512
highlight SignColumn      guibg=#14110F
highlight VertSplit       guifg=#2A2420 guibg=#14110F
highlight WinSeparator    guifg=#2A2420 guibg=#14110F
highlight StatusLine      guifg=#E6DDD2 guibg=#1E1916 gui=NONE
highlight StatusLineNC    guifg=#544A41 guibg=#14110F gui=NONE

" Selection and Search
highlight Visual          guibg=#322920 gui=NONE
highlight Search          guifg=#14110F guibg=#8A7966 gui=bold
highlight IncSearch       guifg=#14110F guibg=#DED5CA gui=bold

" --- Content ---
highlight Comment         guifg=#665C52 guibg=NONE    gui=italic
highlight SpecialComment  guifg=#665C52 guibg=NONE    gui=italic
highlight String          guifg=#DED5CA guibg=NONE    gui=NONE
highlight Constant        guifg=#BEB5AA guibg=NONE    gui=NONE
highlight Number          guifg=#BEB5AA guibg=NONE    gui=NONE
highlight Boolean         guifg=#BEB5AA guibg=NONE    gui=NONE

" --- Links ---
highlight! link Identifier     Normal
highlight! link Function       Normal
highlight! link Special        Normal
highlight! link Character      Normal
highlight! link PreProc        Normal
highlight! link Include        Normal
highlight! link Define         Normal
highlight! link Macro          Normal
highlight! link PreCondit      Normal
highlight! link SpecialChar    Normal
highlight! link Tag            Normal
highlight! link Title          Normal
highlight! link Directory      Normal

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
highlight! link @variable                Normal
highlight! link @variable.builtin        Normal
highlight! link @variable.member         Normal
highlight! link @constant                Normal
highlight! link @constant.builtin        Normal
highlight! link @tag                     Normal
highlight! link @tag.attribute           Normal
highlight! link @tag.delimiter           Muted
highlight! link @namespace               Normal
highlight! link @module                  Normal
highlight! link @function                Normal
highlight! link @function.builtin        Normal
highlight! link @function.macro          Normal
highlight! link @function.method         Normal

highlight! link @type                    SlateKeyword
highlight! link @type.builtin            SlateKeyword
highlight! link @storageclass            SlateKeyword
highlight! link @constructor             SlateKeyword
highlight! link @keyword                 BoldKeyword
highlight! link @keyword.function        BoldKeyword
highlight! link @keyword.return          BoldKeyword

highlight! link @string                  String
highlight! link @comment                 Comment

highlight! link @operator                Muted
highlight! link @punctuation.delimiter   Muted
highlight! link @punctuation.bracket     Muted

" Pop-up Menu
highlight Pmenu           guifg=#B4ACA2 guibg=#1A1613
highlight PmenuSel        guifg=#F0E7DC guibg=#322920 gui=bold
highlight FloatBorder     guifg=#3A332D guibg=#14110F
highlight NormalFloat     guifg=#BEB5AA guibg=#14110F

" Diagnostics
highlight DiagnosticError guifg=#8A5E59
highlight DiagnosticWarn  guifg=#8A7459
highlight DiagnosticInfo  guifg=#6D7884
highlight DiagnosticHint  guifg=#6E7D6A
