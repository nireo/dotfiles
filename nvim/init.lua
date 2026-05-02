require("config.options")
require("config.tabline")
require("core.plugins").setup()
require("core.lsp")
require("config.keymaps")
require("config.autocmds")

require("vim._core.ui2").enable({
	enable = true,
})

-- vim.cmd.colorscheme("")
