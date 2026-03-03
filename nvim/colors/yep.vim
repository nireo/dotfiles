runtime! colors/default.vim
let g:colors_name = 'mono'

set background=dark

" Base colors
highlight Normal          guifg=#B0B0B0 guibg=#090909
highlight BoldKeyword     guifg=#B0B0B0 guibg=NONE    gui=bold
highlight Muted           guifg=#666666 guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#444444 guibg=#090909
highlight CursorLine      guibg=#121212
highlight CursorLineNr    guifg=#A0A0A0 guibg=#090909 gui=bold
highlight ColorColumn     guibg=#090909
highlight SignColumn      guibg=#090909
highlight VertSplit       guifg=#1A1A1A guibg=#090909
highlight WinSeparator    guifg=#1A1A1A guibg=#090909
highlight StatusLine      guifg=#909090 guibg=#141414 gui=NONE
highlight StatusLineNC    guifg=#444444 guibg=#090909 gui=NONE

" Selection and Search
highlight Visual          guibg=#262626 gui=NONE
highlight Search          guifg=#090909 guibg=#B0B0B0 gui=bold
highlight IncSearch       guifg=#090909 guibg=#FFFFFF gui=bold

" --- The Colored Accent Groups ---
" Muted steel blue for comments
highlight Comment          guifg=#788CA0 guibg=NONE    gui=italic
highlight SpecialComment   guifg=#788CA0 guibg=NONE    gui=italic

" Muted sage green for strings
highlight String           guifg=#8FA18F guibg=NONE    gui=NONE

" Sky Blue for Functions (The 'Actions')
highlight Function         guifg=#61AFEF guibg=NONE    gui=NONE

" Muted Cyan for Types and Classes
highlight Type             guifg=#56B6C2 guibg=NONE    gui=bold

" Muted Clay/Sand for Keywords (The 'Structure')
highlight Keyword          guifg=#B08A70 guibg=NONE    gui=bold

" --- Neutralizing Remaining Elements ---
highlight! link Identifier    Normal
highlight! link Number        Normal
highlight! link Boolean       Normal
highlight! link Constant      Normal
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
highlight! link Directory     Function

" Linking keyword-adjacent groups
highlight! link Conditional    Keyword
highlight! link Repeat         Keyword
highlight! link Statement      Keyword
highlight! link Exception      Keyword
highlight! link Label          Keyword
highlight! link StorageClass   Type
highlight! link Structure      Type
highlight! link Typedef        Type

" Muted Punctuation
highlight! link Delimiter      Muted
highlight! link Operator       Muted

" --- Treesitter Overrides ---
highlight! link @variable           Normal
highlight! link @variable.builtin   Normal
highlight! link @variable.member    Normal
highlight! link @constant           Normal
highlight! link @constant.builtin   Normal
highlight! link @tag                Normal
highlight! link @tag.attribute      Normal
highlight! link @tag.delimiter      Normal
highlight! link @namespace          Normal
highlight! link @module             Normal

highlight! link @function           Function
highlight! link @function.builtin   Function
highlight! link @function.macro     Function
highlight! link @function.method    Function

highlight! link @type               Type
highlight! link @type.builtin       Type
highlight! link @storageclass       Type
highlight! link @constructor        Type

highlight! link @keyword            Keyword
highlight! link @keyword.function   Keyword
highlight! link @keyword.return     Keyword

highlight! link @string             String
highlight! link @comment            Comment

highlight! link @operator                 Muted
highlight! link @punctuation.delimiter    Muted
highlight! link @punctuation.bracket      Muted

" Pop-up Menu
highlight Pmenu            guifg=#A0A0A0 guibg=#141414
highlight PmenuSel         guifg=#FFFFFF guibg=#262626 gui=bold
highlight FloatBorder      guifg=#303030 guibg=#090909
highlight NormalFloat      guifg=#B0B0B0 guibg=#090909

" Diagnostics
highlight DiagnosticError guifg=#805555
highlight DiagnosticWarn  guifg=#807055
highlight DiagnosticInfo  guifg=#556680
highlight DiagnosticHint  guifg=#558070
