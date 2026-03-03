runtime! colors/default.vim
let g:colors_name = 'mono_light'

set background=light

" Base colors
highlight Normal          guifg=#3A3A3A guibg=#F5F3ED
highlight BoldKeyword     guifg=#3A3A3A guibg=NONE    gui=bold
highlight Muted           guifg=#8A8A8A guibg=NONE    gui=NONE

" UI Elements
highlight LineNr          guifg=#B0AAA1 guibg=#F5F3ED
highlight CursorLine      guibg=#EEE9E0
highlight CursorLineNr    guifg=#5A5A5A guibg=#F5F3ED gui=bold
highlight ColorColumn     guibg=#F0EBE2
highlight SignColumn      guibg=#F5F3ED
highlight VertSplit       guifg=#DDD7CE guibg=#F5F3ED
highlight WinSeparator    guifg=#DDD7CE guibg=#F5F3ED
highlight StatusLine      guifg=#5C5C5C guibg=#EDE7DD gui=NONE
highlight StatusLineNC    guifg=#9C9C9C guibg=#F5F3ED gui=NONE

" Selection and Search
highlight Visual          guibg=#E2DED4 gui=NONE
highlight Search          guifg=#F5F3ED guibg=#6E6E6E gui=bold
highlight IncSearch       guifg=#F5F3ED guibg=#4F4F4F gui=bold

" Diff
highlight DiffAdd         guifg=#3A3A3A guibg=#E3EEE3
highlight DiffChange      guifg=#3A3A3A guibg=#EFE5D6
highlight DiffDelete      guifg=#3E2A2A guibg=#F2D2D2
highlight DiffText        guifg=#3A3A3A guibg=#DCCFB8 gui=bold

" Neogit diff (override plugin palette)
highlight! link NeogitDiffDelete          DiffDelete
highlight! link NeogitDiffDeleteHighlight DiffDelete
highlight! link NeogitDiffDeleteCursor    DiffDelete
highlight NeogitDiffDeletions guifg=#3E2A2A guibg=NONE

" --- The Only Colored Groups ---
" Muted dusty blue for comments
highlight Comment         guifg=#6E8798 guibg=NONE    gui=italic
highlight SpecialComment  guifg=#6E8798 guibg=NONE    gui=italic
" Soft sage green for strings
highlight String          guifg=#6F8A6F guibg=NONE    gui=NONE

" --- Neutralizing Everything Else ---
highlight! link Identifier     Normal
highlight! link Function       Normal
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
highlight! link @function          Normal
highlight! link @function.builtin  Normal
highlight! link @function.macro    Normal
highlight! link @function.method   Normal
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
highlight Pmenu           guifg=#5C5C5C guibg=#EDE7DD
highlight PmenuSel        guifg=#F5F3ED guibg=#6E6E6E gui=bold
highlight FloatBorder     guifg=#CFC8BE guibg=#F5F3ED
highlight NormalFloat     guifg=#3A3A3A guibg=#F5F3ED

" Diagnostics
highlight DiagnosticError guifg=#8E6060
highlight DiagnosticWarn  guifg=#8A7A5A
highlight DiagnosticInfo  guifg=#5E6F86
highlight DiagnosticHint  guifg=#5C7A6A
