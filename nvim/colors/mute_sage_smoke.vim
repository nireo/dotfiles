runtime! colors/default.vim
let g:colors_name = 'mute_sage_smoke'

set background=dark

" --- Core Palette (Sage Smoke) ---
" Background:   #0F1110
" Foreground:   #B7BCB4 (Soft Gray Green)
" Keyword:      #6D8A7A (Muted Sage)
" Type/Label:   #7A8793 (Slate Blue)
" Comment:      #5A615C (Desaturated Green Gray)
" String:       #D2D8CF (Light Sage Gray)
" Punctuation:  #454B47 (Dark Moss Gray)

" Base colors
highlight Normal          guifg=#B7BCB4 guibg=#0F1110
highlight BoldKeyword     guifg=#6D8A7A guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#7A8793 guibg=NONE    gui=NONE
highlight Muted           guifg=#454B47 guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#343A36 guibg=#0F1110
highlight CursorLine      guibg=#171B19
highlight CursorLineNr    guifg=#7A8793 guibg=#0F1110 gui=bold
highlight ColorColumn     guibg=#161A18
highlight SignColumn      guibg=#0F1110
highlight VertSplit       guifg=#232826 guibg=#0F1110
highlight WinSeparator    guifg=#232826 guibg=#0F1110
highlight StatusLine      guifg=#E6ECE3 guibg=#1B201D gui=NONE
highlight StatusLineNC    guifg=#4F5651 guibg=#0F1110 gui=NONE

" Selection and Search
highlight Visual          guibg=#22302A gui=NONE
highlight Search          guifg=#0F1110 guibg=#6D8A7A gui=bold
highlight IncSearch       guifg=#0F1110 guibg=#D2D8CF gui=bold

" --- Content ---
highlight Comment         guifg=#5A615C guibg=NONE    gui=italic
highlight SpecialComment  guifg=#5A615C guibg=NONE    gui=italic
highlight String          guifg=#D2D8CF guibg=NONE    gui=NONE
highlight Constant        guifg=#B7BCB4 guibg=NONE    gui=NONE
highlight Number          guifg=#B7BCB4 guibg=NONE    gui=NONE
highlight Boolean         guifg=#B7BCB4 guibg=NONE    gui=NONE

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
highlight Pmenu           guifg=#AAB0A8 guibg=#171C1A
highlight PmenuSel        guifg=#F2F8EF guibg=#22302A gui=bold
highlight FloatBorder     guifg=#313835 guibg=#0F1110
highlight NormalFloat     guifg=#B7BCB4 guibg=#0F1110

" Diagnostics
highlight DiagnosticError guifg=#8A6663
highlight DiagnosticWarn  guifg=#8D7F62
highlight DiagnosticInfo  guifg=#6C8191
highlight DiagnosticHint  guifg=#6D8C7A
