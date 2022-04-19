" Settings
set t_Co=256
set background=dark
let mapleader = "\<Space>"
set number relativenumber 

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

set lazyredraw

set smarttab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent

set expandtab
set autoindent
set clipboard+=unnamed
set history=500
set autoread

set splitright
set splitbelow

set hidden
set ruler
set linebreak

set ignorecase
set incsearch
set smartcase

set nobackup
set nowb
set noswapfile

set backspace=indent,eol,start

" Mappings
nnoremap j gj
nnoremap k gk
nnoremap ; :

inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>
snoremap <C-j> <Esc>
xnoremap <C-j> <Esc>
cnoremap <C-j> <C-c>
onoremap <C-j> <Esc>
lnoremap <C-j> <Esc>
tnoremap <C-j> <Esc>

nnoremap <C-k> <Esc>
inoremap <C-k> <Esc>
vnoremap <C-k> <Esc>
snoremap <C-k> <Esc>
xnoremap <C-k> <Esc>
cnoremap <C-k> <C-c>
onoremap <C-k> <Esc>
lnoremap <C-k> <Esc>
tnoremap <C-k> <Esc>

nnoremap Q <NOP>

nnoremap <Leader>wj <C-W>j
nnoremap <Leader>wk <C-W>k
nnoremap <Leader>wh <C-W>h
nnoremap <Leader>wl <C-W>l

nmap <leader>w :w!<cr>
nmap <leader>q :wq!<cr>

cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev Q q
cnoreabbrev Qall qall
cnoreabbrev qw wq
cnoreabbrev Qa qa

nnoremap <Leader>w :write<CR>
xnoremap <Leader>w <Esc>:write<CR>
