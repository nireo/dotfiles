local o = vim.opt
local a = vim.api

-- Set highlight on search
o.hlsearch = false

-- Backspace
o.backspace = "indent,eol,start"

-- Enable mouse mode
o.mouse = "a"
o.guicursor = ""
o.cursorline = true

-- Indentation changes
o.shiftwidth = 4
o.tabstop = 4
o.expandtab = true
o.autoindent = true

-- Enable break indent
o.breakindent = true

-- Save undo history
o.undofile = true

o.completeopt = "menu,menuone,noselect"

-- Case insensitive searching UNLESS /C or capital in search
o.ignorecase = true
o.smartcase = true
o.smartindent = true

-- Enable usage of system clipboard.
o.clipboard = "unnamedplus"

o.cursorline = true
o.cursorcolumn = false

-- Decrease update time
o.updatetime = 100
o.timeoutlen = 300
vim.wo.signcolumn = "no"
o.synmaxcol = 120

o.termguicolors = true

-- Window splits
o.splitright = true
o.splitbelow = true

-- Set completeopt to have a better completion experience
o.completeopt = "menuone,noselect"

-- Set leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g["surround_no_mapping"] = 1

o.backup = false
o.scrolloff = 5
o.swapfile = false
o.fileencoding = "utf-8"
o.showmode = false
o.lazyredraw = true
vim.wo.wrap = true
vim.wo.linebreak = true

vim.g.netrw_winsize = 20
vim.g.netrw_banner = 0
vim.g.netrw_list_style = 1

o.relativenumber = true
o.number = true

o.autoread = true

a.nvim_create_autocmd(
	{ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
	{ pattern = "*", command = "if &nu && mode() != 'i' | set rnu | endif" }
)

a.nvim_create_autocmd(
	{ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
	{ pattern = "*", command = "if &nu | set nornu | endif" }
)

vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
