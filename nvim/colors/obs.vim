runtime! colors/default.vim
let g:colors_name = 'obs'

set background=dark

" Base palette
highlight Normal          guifg=#e7e7e7 guibg=#181818
highlight BoldKeyword     guifg=#b59487 guibg=NONE    gui=bold
highlight SlateKeyword    guifg=#9fbfe7 guibg=NONE    gui=NONE
highlight Muted           guifg=#727272 guibg=NONE    gui=NONE
highlight WarmIdentifier  guifg=#bcbcbc guibg=NONE    gui=NONE
highlight SoftFunction    guifg=#a0c0d0 guibg=NONE    gui=NONE
highlight SoftSpecial     guifg=#e9acbf guibg=NONE    gui=NONE
highlight DustyPreProc    guifg=#a0c0d0 guibg=NONE    gui=NONE
highlight WarmTitle       guifg=#c0b080 guibg=NONE    gui=NONE
highlight SoftDirectory   guifg=#b9d0aa guibg=NONE    gui=NONE

" UI
highlight Cursor          guifg=#181818 guibg=#eeddbb
highlight lCursor         guifg=#181818 guibg=#eeddbb
highlight LineNr          guifg=#505050 guibg=#181818
highlight CursorLine      guibg=#2f2f2f
highlight CursorColumn    guibg=#2f2f2f
highlight CursorLineNr    guifg=#b59487 guibg=#181818 gui=bold
highlight ColorColumn     guibg=#2f2f2f
highlight SignColumn      guibg=#181818
highlight FoldColumn      guifg=#505050 guibg=#181818
highlight Folded          guifg=#969696 guibg=#2f2f2f
highlight EndOfBuffer     guifg=#2f2f2f guibg=#181818
highlight NonText         guifg=#505050 guibg=NONE
highlight VertSplit       guifg=#727272 guibg=#181818
highlight WinSeparator    guifg=#727272 guibg=#181818
highlight StatusLine      guifg=#e7e7e7 guibg=#3a3a3a gui=NONE
highlight StatusLineNC    guifg=#969696 guibg=#181818 gui=NONE

" Selection and search
highlight Visual          guibg=#432f2a gui=NONE
highlight VisualNOS       guibg=#432f2a gui=NONE
highlight Search          guifg=#181818 guibg=#c0b080 gui=bold
highlight IncSearch       guifg=#181818 guibg=#eeddbb gui=bold
highlight CurSearch       guifg=#181818 guibg=#eeddbb gui=bold
highlight MatchParen      guifg=#e7e7e7 guibg=#505050 gui=bold

" Content
highlight Comment         guifg=#969696 guibg=NONE    gui=italic
highlight SpecialComment  guifg=#969696 guibg=NONE    gui=italic
highlight String          guifg=#b9d0aa guibg=NONE    gui=NONE
highlight Constant        guifg=#b59487 guibg=NONE    gui=NONE
highlight Number          guifg=#c0b080 guibg=NONE    gui=NONE
highlight Boolean         guifg=#e9acbf guibg=NONE    gui=NONE

" Links
highlight! link Identifier     WarmIdentifier
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

" Keywords and structure
highlight! link Keyword        BoldKeyword
highlight! link Conditional    BoldKeyword
highlight! link Repeat         BoldKeyword
highlight! link Statement      BoldKeyword
highlight! link Exception      BoldKeyword

highlight! link Type           SlateKeyword
highlight! link StorageClass   SlateKeyword
highlight! link Structure      SlateKeyword
highlight! link Typedef        SlateKeyword
highlight! link Label          SlateKeyword

highlight! link Delimiter      Muted
highlight! link Operator       Muted

" Treesitter
highlight! link @variable                      WarmIdentifier
highlight! link @variable.builtin              WarmIdentifier
highlight! link @variable.member               WarmIdentifier
highlight! link @parameter                     WarmIdentifier
highlight! link @parameter.reference           WarmIdentifier
highlight! link @variable.parameter            WarmIdentifier
highlight! link @variable.parameter.builtin    WarmIdentifier
highlight! link @constant                      Constant
highlight! link @constant.builtin              Constant
highlight! link @constant.macro                DustyPreProc
highlight! link @tag                           SoftSpecial
highlight! link @tag.attribute                 WarmIdentifier
highlight! link @tag.delimiter                 Muted
highlight! link @namespace                     DustyPreProc
highlight! link @module                        DustyPreProc
highlight! link @function                      SoftFunction
highlight! link @function.builtin              SoftFunction
highlight! link @function.macro                DustyPreProc
highlight! link @function.method               SoftFunction
highlight! link @property                      WarmIdentifier
highlight! link @field                         WarmIdentifier

highlight! link @type                          SlateKeyword
highlight! link @type.builtin                  SlateKeyword
highlight! link @storageclass                  SlateKeyword
highlight! link @constructor                   SlateKeyword
highlight! link @keyword                       BoldKeyword
highlight! link @keyword.function              BoldKeyword
highlight! link @keyword.return                BoldKeyword

highlight! link @string                        String
highlight! link @character                     String
highlight! link @comment                       Comment
highlight! link @number                        Number
highlight! link @boolean                       Boolean

highlight! link @operator                      Muted
highlight! link @punctuation.delimiter         Muted
highlight! link @punctuation.bracket           Muted

" Pop-up menu and floating windows
highlight Pmenu           guifg=#bcbcbc guibg=#2f2f2f
highlight PmenuSel        guifg=#e7e7e7 guibg=#3a3a3a gui=bold
highlight PmenuSbar       guibg=#2f2f2f
highlight PmenuThumb      guibg=#505050
highlight FloatBorder     guifg=#727272 guibg=#181818
highlight FloatTitle      guifg=#b59487 guibg=#181818 gui=bold
highlight NormalFloat     guifg=#e7e7e7 guibg=#181818

" Diff
highlight DiffAdd         guifg=#b9d0aa guibg=#1f402e
highlight DiffChange      guifg=#a0c0d0 guibg=#2f4f54
highlight DiffDelete      guifg=#eca28f guibg=#4d1f20
highlight DiffText        guifg=#9fbfe7 guibg=#223567 gui=bold

" Diagnostics
highlight DiagnosticError guifg=#eca28f
highlight DiagnosticWarn  guifg=#c0b080
highlight DiagnosticInfo  guifg=#9fbfe7
highlight DiagnosticHint  guifg=#a0c0d0
highlight DiagnosticOk    guifg=#b9d0aa

highlight DiagnosticVirtualTextError guifg=#eca28f guibg=#4d1f20
highlight DiagnosticVirtualTextWarn  guifg=#c0b080 guibg=#504432
highlight DiagnosticVirtualTextInfo  guifg=#9fbfe7 guibg=#223567
highlight DiagnosticVirtualTextHint  guifg=#a0c0d0 guibg=#2f4f54
