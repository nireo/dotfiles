local wezterm = require("wezterm")
local config = {
	font = wezterm.font("Menlo"),
	color_scheme = "Afterglow (Gogh)",
	adjust_window_size_when_changing_font_size = false,
	font_size = 15,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	use_fancy_tab_bar = false,
}

return config
