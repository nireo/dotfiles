runtime! colors/default.vim
let g:colors_name = 'mute_dusty_mauve'

set background=dark

" --- Core Palette (Dusty Mauve) ---
" Background:   #131014
" Foreground:   #B9B1BC (Soft Violet Gray)
" Keyword:      #85718B (Muted Mauve)
" Type/Label:   #7D8598 (Slate Violet)
" Comment:      #655D68 (Dusty Gray)
" String:       #D8CFDA (Pale Lilac)
" Punctuation:  #524C55 (Dark Plum Gray)

" Base colors
highlight Normal          guifg=#B9B1BC guibg=#131014
highlight BoldKeyword     guifg=#85718B guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#7D8598 guibg=NONE    gui=NONE
highlight Muted           guifg=#524C55 guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#3A343D guibg=#131014
highlight CursorLine      guibg=#1A151C
highlight CursorLineNr    guifg=#85718B guibg=#131014 gui=bold
highlight ColorColumn     guibg=#181319
highlight SignColumn      guibg=#131014
highlight VertSplit       guifg=#29222D guibg=#131014
highlight WinSeparator    guifg=#29222D guibg=#131014
highlight StatusLine      guifg=#ECE3EE guibg=#1E1821 gui=NONE
highlight StatusLineNC    guifg=#524C55 guibg=#131014 gui=NONE

" Selection and Search
highlight Visual          guibg=#2D2532 gui=NONE
highlight Search          guifg=#131014 guibg=#85718B gui=bold
highlight IncSearch       guifg=#131014 guibg=#D8CFDA gui=bold

" --- Content ---
highlight Comment         guifg=#655D68 guibg=NONE    gui=italic
highlight SpecialComment  guifg=#655D68 guibg=NONE    gui=italic
highlight String          guifg=#D8CFDA guibg=NONE    gui=NONE
highlight Constant        guifg=#B9B1BC guibg=NONE    gui=NONE
highlight Number          guifg=#B9B1BC guibg=NONE    gui=NONE
highlight Boolean         guifg=#B9B1BC guibg=NONE    gui=NONE

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
highlight Pmenu           guifg=#B2AAB5 guibg=#1A151C
highlight PmenuSel        guifg=#FAF0FC guibg=#2D2532 gui=bold
highlight FloatBorder     guifg=#3A3240 guibg=#131014
highlight NormalFloat     guifg=#B9B1BC guibg=#131014

" Diagnostics
highlight DiagnosticError guifg=#A06D73
highlight DiagnosticWarn  guifg=#A58A69
highlight DiagnosticInfo  guifg=#8491A9
highlight DiagnosticHint  guifg=#819A88
