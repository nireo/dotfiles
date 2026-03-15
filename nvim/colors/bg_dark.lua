vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd.syntax("reset")
end

vim.g.colors_name = "bg_dark"
vim.o.background = "dark"

local palette = {
	fg = "#E7DAC7",
	bg = "#14100C",

	-- square colors harmony
	square1 = "#648467",
	square2 = "#94715D",
	square3 = "#8A657B",
	square4 = "#6A849A",

	cursor = "#6D90E6",
	cursorprimary = "#7AA2FF",
	cursormatch = "#9F9433",

	selection = "#62452A",
	selectionprimary = "#8A5E2D",

	panel = "#1D1712",
	paneldim = "#B3A793",

	diffplus = "#537356",
	diffminus = "#8A4A45",
	diffdelta = "#8F6E35",

	modenormal = "#C98A36",
	modeinsert = "#5DA4D6",
	modeselect = "#6E67D6",
}

local hl = function(name, val)
	val.force = true
	val.cterm = {}
	vim.api.nvim_set_hl(0, name, val)
end

-- editor
hl("Normal", { bg = palette.bg, fg = palette.fg })
hl("NormalFloat", { bg = palette.bg, fg = palette.fg })
hl("NonText", { bg = palette.bg })
hl("Ignore", { bg = palette.bg })
hl("Cursor", { bg = palette.cursorprimary, fg = palette.bg })
hl("lCursor", { link = "Cursor" })
hl("TermCursor", { link = "Cursor" })
hl("CursorLine", { bg = palette.bg })
hl("Visual", { bg = palette.selectionprimary })
hl("IncSearch", { bg = palette.selectionprimary })
hl("Search", { bg = palette.selection })
hl("CurSearch", { bg = palette.selectionprimary })
hl("StatusLine", { bg = palette.panel })
hl("StatusLineNC", { bg = palette.panel })
hl("ColorColumn", { link = "StatusLine" })
hl("Pmenu", { bg = palette.panel })
hl("MatchParen", { bg = palette.cursormatch })
hl("LineNr", { bg = palette.bg })
hl("CursorLineNr", { fg = palette.selectionprimary, bg = palette.bg, bold = true })

hl("Added", { link = "@diff.plus" })
hl("DiffAdd", { link = "@diff.plus" })
hl("Removed", { link = "@diff.minus" })
hl("DiffDelete", { link = "@diff.minus" })
hl("Changed", { link = "@diff.delta" })
hl("DiffChange", { link = "@diff.delta" })
hl("DiffText", { link = "DiffDelete" })

-- language
hl("@variable", { bg = palette.bg })
hl("@variable.builtin", { bg = palette.bg, bold = true })
hl("@variable.parameter", { bg = palette.bg })
hl("@variable.parameter.builtin", { link = "@variable.parameter" })
hl("@variable.member", { link = "@variable.parameter" })

hl("@property", { bg = palette.bg })
hl("@label", { bg = palette.square3, italic = true })

hl("@string", { bg = palette.square4 })
hl("@string.documentation", { bg = palette.square4, italic = true })
hl("@string.special", { bg = palette.square4, bold = true })
hl("@string.pe", { link = "@string.special" })
hl("@string.special.symbol", { link = "@string.special" })
hl("@string.special.url", { link = "@string.special" })

hl("@constant", { bg = palette.bg, underline = true, italic = true })
hl("@constant.builtin", { link = "@constant" })
hl("@constant.macro", { link = "@constant" })
hl("@character", { bg = palette.square4 })
hl("@character.special", { bg = palette.square4 })
hl("@boolean", { bg = palette.bg, underline = true, italic = true })
hl("@number", { bg = palette.bg, italic = true })
hl("@number.float", { bg = palette.bg, italic = true })

hl("@type", { bg = palette.square2 })
hl("@type.builtin", { link = "@type" })
hl("@type.definition", { link = "@type" })

hl("@attribute", { bg = palette.bg, italic = true })
hl("@attribute.builtin", { link = "@attribute" })

hl("@function", { bg = palette.square1 })
hl("@function.call", { link = "@function" })
hl("@function.method", { link = "@function" })
hl("@function.method.call", { link = "@function" })
hl("@function.builtin", { bg = palette.square1, italic = true })
hl("@function.macro", { bg = palette.square1, underline = true })
hl("@constructor", { bg = palette.square1, bold = true })

hl("@operator", { fg = palette.paneldim, bg = palette.bg })

hl("@keyword", { bg = palette.bg, bold = true })
hl("@keyword.coroutine", { link = "@keyword" })
hl("@keyword.function", { link = "@keyword" })
hl("@keyword.import", { link = "@keyword" })
hl("@keyword.type", { link = "@keyword" })
hl("@keyword.modifer", { link = "@keyword" })
hl("@keyword.repeat", { link = "@keyword" })
hl("@keyword.return", { link = "@keyword" })
hl("@keyword.debug", { link = "@keyword" })
hl("@keyword.exception", { link = "@keyword" })
hl("@keyword.conditional", { link = "@keyword" })
hl("@keyword.conditional.ternary", { link = "@keyword" })
hl("@keyword.directive", { link = "@keyword" })
hl("@keyword.directive.define", { link = "@keyword" })
hl("@keyword.operator", { bg = palette.bg, italic = true })

hl("@punctuation.delimiter", { bg = palette.bg })
hl("@punctuation.bracket", { fg = palette.paneldim, bg = palette.bg })
hl("@punctuation.special", { fg = palette.paneldim, bg = palette.bg, bold = true })

hl("@comment", { bg = palette.square3 })
hl("@comment.error", { link = "@diff.minus" })
hl("@comment.warning", { link = "@diff.delta" })
hl("@comment.note", { link = "@diff.plus" })
hl("@comment.todo", { bg = palette.square3, bold = true })

hl("@tag", { bg = palette.bg })
hl("@tag.builtin", { link = "@tag" })

hl("@module", { bg = palette.bg })
hl("@module.builtin", { link = "@module" })

hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.strikethrough", { strikethrough = true })
hl("@markup.underline", { underline = true })
hl("@markup.heading", { bg = palette.square1 })
hl("@markup.heading.1", { link = "@markup.heading" })
hl("@markup.heading.2", { link = "@markup.heading" })
hl("@markup.heading.3", { link = "@markup.heading" })
hl("@markup.heading.4", { link = "@markup.heading" })
hl("@markup.heading.5", { link = "@markup.heading" })
hl("@markup.heading.6", { link = "@markup.heading" })
hl("@markup.quote", { link = "@string" })
hl("@markup.math", { italic = true })
hl("@markup.link", { link = "@string.special" })
hl("@markup.link.url", { link = "@string.special.url" })
hl("@markup.raw", { link = "@type" })
hl("@markup.raw.block", { link = "@type" })
hl("@markup.list", { bold = true })
hl("@markup.list.checked", { fg = palette.paneldim })
hl("@markup.list.unchecked", { link = "@markup.list" })

hl("@diff.plus", { fg = palette.fg, bg = palette.diffplus })
hl("@diff.minus", { fg = palette.fg, bg = palette.diffminus })
hl("@diff.delta", { fg = palette.fg, bg = palette.diffdelta })
