runtime! colors/default.vim
let g:colors_name = 'mute_blue_fog'

set background=dark

" --- Core Palette (Blue Fog) ---
" Background:   #101215
" Foreground:   #B2BAC4 (Cool Gray)
" Keyword:      #6D8291 (Muted Blue)
" Type/Label:   #7E8A9A (Fog Slate)
" Comment:      #57606B (Blue Gray)
" String:       #D3D9E2 (Soft Ice)
" Punctuation:  #4A525C (Deep Steel)

" Base colors
highlight Normal          guifg=#B2BAC4 guibg=#101215
highlight BoldKeyword     guifg=#6D8291 guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#7E8A9A guibg=NONE    gui=NONE
highlight Muted           guifg=#4A525C guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#373F49 guibg=#101215
highlight CursorLine      guibg=#171B20
highlight CursorLineNr    guifg=#7E8A9A guibg=#101215 gui=bold
highlight ColorColumn     guibg=#15191E
highlight SignColumn      guibg=#101215
highlight VertSplit       guifg=#242A32 guibg=#101215
highlight WinSeparator    guifg=#242A32 guibg=#101215
highlight StatusLine      guifg=#E6ECF5 guibg=#1A2028 gui=NONE
highlight StatusLineNC    guifg=#56606C guibg=#101215 gui=NONE

" Selection and Search
highlight Visual          guibg=#26313D gui=NONE
highlight Search          guifg=#101215 guibg=#6D8291 gui=bold
highlight IncSearch       guifg=#101215 guibg=#D3D9E2 gui=bold

" --- Content ---
highlight Comment         guifg=#57606B guibg=NONE    gui=italic
highlight SpecialComment  guifg=#57606B guibg=NONE    gui=italic
highlight String          guifg=#D3D9E2 guibg=NONE    gui=NONE
highlight Constant        guifg=#B2BAC4 guibg=NONE    gui=NONE
highlight Number          guifg=#B2BAC4 guibg=NONE    gui=NONE
highlight Boolean         guifg=#B2BAC4 guibg=NONE    gui=NONE

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
highlight Pmenu           guifg=#A7AFB8 guibg=#171C22
highlight PmenuSel        guifg=#F1F7FF guibg=#26313D gui=bold
highlight FloatBorder     guifg=#323A45 guibg=#101215
highlight NormalFloat     guifg=#B2BAC4 guibg=#101215

" Diagnostics
highlight DiagnosticError guifg=#8F6A6E
highlight DiagnosticWarn  guifg=#9A845E
highlight DiagnosticInfo  guifg=#7C9AB8
highlight DiagnosticHint  guifg=#7CA08C
