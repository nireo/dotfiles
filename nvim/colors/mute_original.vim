runtime! colors/default.vim
let g:colors_name = 'mute_original'

set background=dark

" --- Core Palette (Original Warm) ---
" Background:   #14100C
" Foreground:   #B0B0B0 (Gray)
" Keyword:      #5F8787 (Muted Teal)
" Type/Label:   #748594 (Dusty Slate)
" Comment:      #8FBF72 (Bright Sage Green)
" String:       #D9CFC0 (Warm Off-white)
" Punctuation:  #4A433A (Muted Brown Gray)

" Base colors
highlight Normal          guifg=#B0B0B0 guibg=#14100C
highlight BoldKeyword     guifg=#5F8787 guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#748594 guibg=NONE    gui=NONE
highlight Muted           guifg=#4A433A guibg=NONE    gui=NONE
highlight WarmIdentifier  guifg=#C2AA8D guibg=NONE    gui=NONE
highlight SoftFunction    guifg=#B7C08E guibg=NONE    gui=NONE
highlight SoftSpecial     guifg=#C49B83 guibg=NONE    gui=NONE
highlight DustyPreProc    guifg=#86A0B2 guibg=NONE    gui=NONE
highlight WarmTitle       guifg=#D2C29E guibg=NONE    gui=NONE
highlight SoftDirectory   guifg=#96B68A guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#3C342C guibg=#14100C
highlight CursorLine      guibg=#1D1712
highlight CursorLineNr    guifg=#748594 guibg=#14100C gui=bold
highlight ColorColumn     guibg=#1A1511
highlight SignColumn      guibg=#14100C
highlight VertSplit       guifg=#29231D guibg=#14100C
highlight WinSeparator    guifg=#29231D guibg=#14100C
highlight StatusLine      guifg=#F0E6D8 guibg=#201A15 gui=NONE
highlight StatusLineNC    guifg=#4A433A guibg=#14100C gui=NONE

" Selection and Search
highlight Visual          guibg=#2A2119 gui=NONE
highlight Search          guifg=#14100C guibg=#5F8787 gui=bold
highlight IncSearch       guifg=#14100C guibg=#E7DAC7 gui=bold

" --- Content ---
highlight Comment         guifg=#8FBF72 guibg=NONE    gui=italic
highlight SpecialComment  guifg=#8FBF72 guibg=NONE    gui=italic
highlight String          guifg=#D9CFC0 guibg=NONE    gui=NONE
highlight Constant        guifg=#C7A08C guibg=NONE    gui=NONE
highlight Number          guifg=#CDAE76 guibg=NONE    gui=NONE
highlight Boolean         guifg=#9CC681 guibg=NONE    gui=NONE

" --- Links ---
highlight! link Identifier     Normal
highlight! link Function       SoftFunction
highlight! link Special        SoftSpecial
highlight! link Character      String
highlight! link PreProc        DustyPreProc
highlight! link Include        DustyPreProc
highlight! link Define         DustyPreProc
highlight! link Macro          DustyPreProc
highlight! link PreCondit      DustyPreProc
highlight! link SpecialChar    SoftSpecial
highlight! link Tag            SoftSpecial
highlight! link Title          WarmTitle
highlight! link Directory      SoftDirectory

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
highlight! link @parameter               Normal
highlight! link @parameter.reference     Normal
highlight! link @variable.parameter      Normal
highlight! link @variable.parameter.builtin Normal
highlight! link @constant                Constant
highlight! link @constant.builtin        Constant
highlight! link @constant.macro          DustyPreProc
highlight! link @tag                     SoftSpecial
highlight! link @tag.attribute           WarmIdentifier
highlight! link @tag.delimiter           Muted
highlight! link @namespace               DustyPreProc
highlight! link @module                  DustyPreProc
highlight! link @function                SoftFunction
highlight! link @function.builtin        SoftFunction
highlight! link @function.macro          DustyPreProc
highlight! link @function.method         SoftFunction
highlight! link @property                Normal
highlight! link @field                   Normal

highlight! link @type                    SlateKeyword
highlight! link @type.builtin            SlateKeyword
highlight! link @storageclass            SlateKeyword
highlight! link @constructor             SlateKeyword
highlight! link @keyword                 BoldKeyword
highlight! link @keyword.function        BoldKeyword
highlight! link @keyword.return          BoldKeyword

highlight! link @string                  String
highlight! link @character               String
highlight! link @comment                 Comment
highlight! link @number                  Number
highlight! link @boolean                 Boolean

highlight! link @operator                Muted
highlight! link @punctuation.delimiter   Muted
highlight! link @punctuation.bracket     Muted

" Pop-up Menu
highlight Pmenu           guifg=#ADA395 guibg=#1B1612
highlight PmenuSel        guifg=#FFF6E8 guibg=#2A2119 gui=bold
highlight FloatBorder     guifg=#35302A guibg=#14100C
highlight NormalFloat     guifg=#B0B0B0 guibg=#14100C

" Diagnostics
highlight DiagnosticError guifg=#8D5E5A
highlight DiagnosticWarn  guifg=#967E54
highlight DiagnosticInfo  guifg=#68819A
highlight DiagnosticHint  guifg=#6D9B6A
