runtime! colors/default.vim
let g:colors_name = 'mono_green'

set background=dark

" Base colors
highlight Normal          guifg=#A9B5A4 guibg=#0E1511
highlight BoldKeyword     guifg=#D6E0D2 guibg=NONE    gui=bold
highlight Muted           guifg=#6C776D guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#4C5A50 guibg=#0E1511
highlight CursorLine      guibg=#141E17
highlight CursorLineNr    guifg=#B0BDB0 guibg=#0E1511 gui=bold
highlight ColorColumn     guibg=#111B14
highlight SignColumn      guibg=#0E1511
highlight VertSplit       guifg=#1F2A22 guibg=#0E1511
highlight WinSeparator    guifg=#1F2A22 guibg=#0E1511
highlight StatusLine      guifg=#9FAA9F guibg=#19231C gui=NONE
highlight StatusLineNC    guifg=#5B665D guibg=#0E1511 gui=NONE

" Selection and Search
highlight Visual          guibg=#243126 gui=NONE
highlight Search          guifg=#0E1511 guibg=#B8C4B3 gui=bold
highlight IncSearch       guifg=#0E1511 guibg=#DCE4D6 gui=bold

" --- The Only Colored Groups ---
" Muted dusty blue for comments
highlight Comment         guifg=#7D8F9C guibg=NONE    gui=italic
highlight SpecialComment  guifg=#7D8F9C guibg=NONE    gui=italic
" Soft sage green for strings
highlight String          guifg=#86A181 guibg=NONE    gui=NONE

" --- Neutralizing Everything Else ---
highlight! link Identifier     Normal
highlight Function       guifg=#87B094 guibg=NONE    gui=NONE
highlight! link Number         Normal
highlight! link Boolean        Normal
highlight! link Constant       Normal
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

" Standard Keywords (Bold but no color)
highlight! link Type           BoldKeyword
highlight! link StorageClass   BoldKeyword
highlight! link Structure       BoldKeyword
highlight! link Typedef        BoldKeyword
highlight! link Keyword        BoldKeyword
highlight! link Conditional    BoldKeyword
highlight! link Repeat         BoldKeyword
highlight! link Statement      BoldKeyword
highlight! link Exception      BoldKeyword
highlight! link Label          BoldKeyword

" Muted Punctuation
highlight! link Delimiter      Muted
highlight! link Operator       Muted

" --- Treesitter Overrides ---
highlight! link @variable          Normal
highlight! link @variable.builtin  Normal
highlight! link @variable.member   Normal
highlight! link @constant          Normal
highlight! link @constant.builtin  Normal
highlight! link @tag               Normal
highlight! link @tag.attribute     Normal
highlight! link @tag.delimiter     Normal
highlight! link @namespace         Normal
highlight! link @module            Normal
highlight! link @function          Function
highlight! link @function.builtin  Function
highlight! link @function.macro    Function
highlight! link @function.method   Function
highlight! link @number            Normal
highlight! link @number.float      Normal
highlight! link @boolean           Normal

highlight! link @type              BoldKeyword
highlight! link @type.builtin      BoldKeyword
highlight! link @storageclass      BoldKeyword
highlight! link @constructor       BoldKeyword
highlight! link @keyword           BoldKeyword
highlight! link @keyword.function  BoldKeyword
highlight! link @keyword.return    BoldKeyword

highlight! link @string            String
highlight! link @comment           Comment

highlight! link @operator               Muted
highlight! link @punctuation.delimiter  Muted
highlight! link @punctuation.bracket    Muted

" Pop-up Menu
highlight Pmenu           guifg=#9FAA9F guibg=#19231C
highlight PmenuSel        guifg=#0E1511 guibg=#B8C4B3 gui=bold
highlight FloatBorder     guifg=#2E3A31 guibg=#0E1511
highlight NormalFloat     guifg=#B8C4B3 guibg=#0E1511

" Diagnostics
highlight DiagnosticError guifg=#9A6A6A
highlight DiagnosticWarn  guifg=#9A8562
highlight DiagnosticInfo  guifg=#6A7F96
highlight DiagnosticHint  guifg=#6A8A78
