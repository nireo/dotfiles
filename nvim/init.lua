require("config.options")
require("core.plugins").setup()
require("core.lsp")
require("config.keymaps")
require("config.autocmds")

vim.cmd.colorscheme("kanagawa-dragon")
