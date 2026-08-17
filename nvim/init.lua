require("config.options")
require("core.plugins").setup()
require("core.lsp")
require("config.keymaps")
require("config.autocmds")

require("vim._core.ui2").enable({
	enable = true,
})

vim.g.zenbones_transparent_background = true

local function is_dark_mode()
	if vim.fn.has("macunix") == 1 then
		local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
		return result.code == 0 and vim.trim(result.stdout or ""):lower() == "dark"
	end

	return vim.o.background == "dark"
end

vim.cmd.colorscheme(is_dark_mode() and "mono" or "mono_light")
