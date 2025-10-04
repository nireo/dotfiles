c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

config.load_autoconfig()
c.fonts.default_family = "DejaVuSansM Nerd Font"
c.fonts.default_size = "9pt"

c.auto_save.session = True
c.content.blocking.method = "both"

c.fonts.completion.entry = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.completion.category = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.downloads = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.hints = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.keyhint = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.messages.error = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.messages.info = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.messages.warning = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.prompts = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.statusbar = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.tabs.selected = "bold 9pt DejaVuSansM Nerd Font Mono"
c.fonts.tabs.unselected = "bold 9pt DejaVuSansM Nerd Font Mono"

# c.colors.webpage.darkmode.enabled = True
# c.colors.webpage.darkmode.algorithm = "lightness-cielab"
# c.colors.webpage.darkmode.policy.images = "never"
# config.set("colors.webpage.darkmode.enabled", False, "file://*")
# c.colors.webpage.darkmode.enabled = True

config.set("content.webgl", False, "*")
config.set("content.canvas_reading", False)
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")
config.set("content.cookies.accept", "all")
config.set("content.cookies.store", True)
c.content.blocking.enabled = True

# Completion widget colors
c.colors.completion.fg = "#B0B0B0"
c.colors.completion.odd.bg = "#0A0A0A"
c.colors.completion.even.bg = "#101010"
c.colors.completion.category.fg = "#8AC18A"
c.colors.completion.category.bg = "#121212"
c.colors.completion.category.border.top = "#121212"
c.colors.completion.category.border.bottom = "#2A2A2A"
c.colors.completion.item.selected.fg = "#B0B0B0"
c.colors.completion.item.selected.bg = "#1D1D1D"
c.colors.completion.item.selected.border.top = "#1D1D1D"
c.colors.completion.item.selected.border.bottom = "#2A2A2A"
c.colors.completion.match.fg = "#8AC18A"
c.colors.completion.scrollbar.fg = "#B0B0B0"
c.colors.completion.scrollbar.bg = "#101010"

# Context menu colors
c.colors.contextmenu.disabled.bg = "#121212"
c.colors.contextmenu.disabled.fg = "#6A7A6A"
c.colors.contextmenu.menu.bg = "#101010"
c.colors.contextmenu.menu.fg = "#B0B0B0"
c.colors.contextmenu.selected.bg = "#1D1D1D"
c.colors.contextmenu.selected.fg = "#8AC18A"

# Download colors
c.colors.downloads.bar.bg = "#101010"
c.colors.downloads.start.fg = "#B0B0B0"
c.colors.downloads.start.bg = "#88B588"
c.colors.downloads.stop.fg = "#B0B0B0"
c.colors.downloads.stop.bg = "#8AC18A"
c.colors.downloads.error.fg = "#B0B0B0"
c.colors.downloads.error.bg = "#9BBB94"

# Hints
c.colors.hints.fg = "#101010"
c.colors.hints.bg = "#8AC18A"
c.colors.hints.match.fg = "#88B588"

# Keyhint widget
c.colors.keyhint.fg = "#B0B0B0"
c.colors.keyhint.suffix.fg = "#8AC18A"
c.colors.keyhint.bg = "#101010"

# Messages
c.colors.messages.error.fg = "#B0B0B0"
c.colors.messages.error.bg = "#9BBB94"
c.colors.messages.error.border = "#9BBB94"
c.colors.messages.warning.fg = "#101010"
c.colors.messages.warning.bg = "#88AF7A"
c.colors.messages.warning.border = "#88AF7A"
c.colors.messages.info.fg = "#B0B0B0"
c.colors.messages.info.bg = "#121212"
c.colors.messages.info.border = "#2A2A2A"

# Prompts
c.colors.prompts.fg = "#B0B0B0"
c.colors.prompts.bg = "#101010"
c.colors.prompts.border = "#2A2A2A"
c.colors.prompts.selected.bg = "#1D1D1D"
c.colors.prompts.selected.fg = "#8AC18A"

# Statusbar
c.colors.statusbar.normal.fg = "#B0B0B0"
c.colors.statusbar.normal.bg = "#101010"
c.colors.statusbar.insert.fg = "#101010"
c.colors.statusbar.insert.bg = "#88B588"
c.colors.statusbar.passthrough.fg = "#101010"
c.colors.statusbar.passthrough.bg = "#6B8F8F"
c.colors.statusbar.private.fg = "#B0B0B0"
c.colors.statusbar.private.bg = "#121212"
c.colors.statusbar.command.fg = "#B0B0B0"
c.colors.statusbar.command.bg = "#101010"
c.colors.statusbar.command.private.fg = "#B0B0B0"
c.colors.statusbar.command.private.bg = "#121212"
c.colors.statusbar.caret.fg = "#101010"
c.colors.statusbar.caret.bg = "#88AF7A"
c.colors.statusbar.caret.selection.fg = "#101010"
c.colors.statusbar.caret.selection.bg = "#8AC18A"
c.colors.statusbar.progress.bg = "#8AC18A"
c.colors.statusbar.url.fg = "#B0B0B0"
c.colors.statusbar.url.error.fg = "#9BBB94"
c.colors.statusbar.url.hover.fg = "#88B588"
c.colors.statusbar.url.success.http.fg = "#B0B0B0"
c.colors.statusbar.url.success.https.fg = "#8AC18A"
c.colors.statusbar.url.warn.fg = "#88AF7A"

# Tabs
c.colors.tabs.bar.bg = "#101010"
c.colors.tabs.indicator.start = "#8AC18A"
c.colors.tabs.indicator.stop = "#88B588"
c.colors.tabs.indicator.error = "#9BBB94"
c.colors.tabs.odd.fg = "#6A7A6A"
c.colors.tabs.odd.bg = "#101010"
c.colors.tabs.even.fg = "#6A7A6A"
c.colors.tabs.even.bg = "#0A0A0A"
c.colors.tabs.pinned.even.bg = "#121212"
c.colors.tabs.pinned.even.fg = "#6A7A6A"
c.colors.tabs.pinned.odd.bg = "#121212"
c.colors.tabs.pinned.odd.fg = "#6A7A6A"
c.colors.tabs.pinned.selected.even.bg = "#1D1D1D"
c.colors.tabs.pinned.selected.even.fg = "#8AC18A"
c.colors.tabs.pinned.selected.odd.bg = "#1D1D1D"
c.colors.tabs.pinned.selected.odd.fg = "#8AC18A"
c.colors.tabs.selected.odd.fg = "#B0B0B0"
c.colors.tabs.selected.odd.bg = "#1D1D1D"
c.colors.tabs.selected.even.fg = "#B0B0B0"
c.colors.tabs.selected.even.bg = "#1D1D1D"

# Webpage colors
c.colors.webpage.bg = "#101010"
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True

c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g": "https://www.google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "aw": "https://wiki.archlinux.org/?search={}",
    "w": "https://en.wikipedia.org/wiki/{}",
}

config.bind(",r", "config-source")
config.bind("M", "hint links spawn mpv {hint-url}")
