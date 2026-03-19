require("config.options")
require("core.lazy")
require("core.lsp")
require("config.keymaps")
require("config.autocmds")

vim.o.background = "dark"
vim.g.adwaita_darker = true -- for darker version
vim.cmd.colorscheme("mute_original")
