local M = {}

local treesitter_parsers = {
	"vimdoc",
	"ocaml",
	"c",
	"cpp",
	"go",
	"lua",
	"rust",
	"javascript",
	"typescript",
	"hcl",
	"toml",
	"zig",
	"python",
	"scala",
}

local function gh(repo)
	return "https://github.com/" .. repo
end

local function ensure_site_in_packpath()
	local site = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
	local packpath = vim.opt.packpath:get()

	if not vim.tbl_contains(packpath, site) then
		vim.opt.packpath:append(site)
	end
end

local function prepare_pack()
	if not vim.pack then
		error("vim.pack is not available in this Neovim build")
	end

	ensure_site_in_packpath()
	vim.g.copilot_enabled = false
end

local function add(specs)
	prepare_pack()
	vim.pack.add(specs, { load = true, confirm = false })
end

local function setup_treesitter()
	require("nvim-treesitter").install(treesitter_parsers)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("core-treesitter-start", { clear = true }),
		callback = function(args)
			local language = vim.treesitter.language.get_lang(args.match)
			if not language then
				return
			end

			if not vim.treesitter.language.add(language) then
				return
			end

			vim.treesitter.start(args.buf, language)
		end,
	})
end

local function setup_main_plugins()
	local map = vim.keymap.set
	local conform = require("conform")
	local snacks = require("snacks")
	local which_key = require("which-key")
	local flash = require("flash")
	local opencode = require("opencode")

	require("Comment").setup({})
	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			rust = { "rustfmt", lsp_format = "fallback" },
			go = { "goimports", "gofumpt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			json = { "prettier" },
			css = { "prettier" },
			ocaml = { "ocamlformat" },
		},
		formatters = {
			["clang-format"] = {
				prepend_args = { "--style=webkit" },
			},
			ocamlformat = {
				prepend_args = {
					"--if-then-else",
					"vertical",
					"--break-cases",
					"fit-or-vertical",
					"--type-decl",
					"sparse",
				},
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
		format_after_save = {
			lsp_format = "fallback",
		},
	})

	require("blink.cmp").setup({
		keymap = {
			preset = "enter",
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				markdown = { "lsp", "path" },
			},
		},
		signature = { enabled = true },
		cmdline = {
			enabled = false,
		},
		completion = {
			menu = {
				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind" } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
		},
	})

	require("mason").setup({})
	require("nvim-autopairs").setup({})
	require("go").setup({
		go = "go",
		gofmt = "gofumpt",
		staticcheck = true,
		max_line_len = 100,
	})
	require("quicker").setup({
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		},
	})
	setup_treesitter()
	require("neogit").setup({})
	require("oil").setup({})
	which_key.setup({})
	flash.setup({})

	snacks.setup({
		zen = {
			enabled = true,
		},
		gh = {
			enabled = true,
		},
		lazygit = {
			enabled = true,
		},
		picker = {
			enabled = true,
			layout = {
				preview = false,
				preset = "ivy",
				position = "bottom",
				height = 0.2,
			},
			win = {
				border = "none",
				style = "minimal",
				input = {
					keys = {
						["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
					},
				},
			},
			formatters = {
				file = {
					truncate = 120,
				},
			},
			actions = {
				opencode_send = function(...)
					return opencode.snacks_picker_send(...)
				end,
			},
		},
		input = {},
	})

	vim.g.opencode_opts = {}
	vim.o.autoread = true

	map("n", "<leader>o", ":Oil<CR>")
	map("n", "<leader>ie", ":GoIfErr<CR>")
	map("n", "<leader>gotf", ":GoTestFile<CR>")
	map("n", "<leader>gofn", ":GoTestFunc<CR>")
	map("n", "<leader>gofs", ":GoFillStruct<CR>")
	map("n", "<leader>goj", ":GoAddTag json<CR>")
	map("n", "<leader>cg", ":Neogit<CR>")
	map("n", "<leader>lq", function()
		require("quicker").toggle()
	end, { desc = "Toggle quickfix" })
	map("n", "<leader>ll", function()
		require("quicker").toggle()
	end, { desc = "Toggle quickfix" })

	map("n", "<leader>ii", "<cmd>AnyJump<CR>", { desc = "Any Jump" })
	map("x", "<leader>ii", "<cmd>AnyJumpVisual<CR>", { desc = "Any Jump" })
	map("n", "<leader>ib", "<cmd>AnyJumpBack<CR>", { desc = "Any Jump Back" })
	map("n", "<leader>il", "<cmd>AnyJumpLastResults<CR>", { desc = "Any Jump Resume" })

	map("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Toggle Copilot" })
	map("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Toggle Copilot" })

	map("n", "<leader>?", function()
		which_key.show({ global = false })
	end, { desc = "Buffer Local Keymaps (which-key)" })

	map({ "n", "x" }, "<C-a>", function()
		opencode.ask("@this: ", { submit = true })
	end, { desc = "Ask opencode..." })
	map({ "n", "x" }, "<C-x>", function()
		opencode.select()
	end, { desc = "Execute opencode action..." })
	map({ "n", "t" }, "<C-.>", function()
		opencode.toggle()
	end, { desc = "Toggle opencode" })
	map({ "n", "x" }, "go", function()
		return opencode.operator("@this ")
	end, { desc = "Add range to opencode", expr = true })
	map("n", "goo", function()
		return opencode.operator("@this ") .. "_"
	end, { desc = "Add line to opencode", expr = true })
	map("n", "<S-C-u>", function()
		opencode.command("session.half.page.up")
	end, { desc = "Scroll opencode up" })
	map("n", "<S-C-d>", function()
		opencode.command("session.half.page.down")
	end, { desc = "Scroll opencode down" })
	map("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
	map("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

	map("n", "<leader>gi", function()
		snacks.picker.gh_issue()
	end, { desc = "GitHub Issues (open)" })
	map("n", "<leader>gI", function()
		snacks.picker.gh_issue({ state = "all" })
	end, { desc = "GitHub Issues (all)" })
	map("n", "<leader>gp", function()
		snacks.picker.gh_pr()
	end, { desc = "GitHub Pull Requests (open)" })
	map("n", "<leader>gg", function()
		snacks.lazygit()
	end, { desc = "Lazygit" })
	map("n", "<leader>gP", function()
		snacks.picker.gh_pr({ state = "all" })
	end, { desc = "GitHub Pull Requests (all)" })
	map("n", "gr", function()
		snacks.picker.grep()
	end, { desc = "Grep" })
	map("n", "ff", function()
		snacks.picker.files()
	end, { desc = "Find files" })
	map("n", "gw", function()
		snacks.picker.grep_word()
	end, { desc = "Grep" })
	map("n", "<leader>cR", function()
		snacks.rename.rename_file()
	end, { desc = "Rename File" })
	map("n", "<S-h>", function()
		snacks.picker.buffers({
			on_show = function()
				vim.cmd.stopinsert()
			end,
			finder = "buffers",
			format = "buffer",
			hidden = false,
			unloaded = true,
			current = true,
			sort_lastused = true,
			win = {
				input = {
					keys = {
						["d"] = "bufdelete",
					},
				},
				list = {
					keys = {
						["d"] = "bufdelete",
					},
				},
			},
		})
	end, { desc = "[P]Snacks picker buffers" })
	map("n", "gd", function()
		snacks.picker.lsp_definitions()
	end, { desc = "Goto Definition" })
	map("n", "<leader>sd", function()
		snacks.picker.diagnostics()
	end, { desc = "Diagnostics" })
	map("n", "<leader>z", function()
		snacks.zen()
	end, { desc = "Toggle Zen Mode" })
	map("n", "gR", function()
		snacks.picker.lsp_references()
	end, { desc = "References", nowait = true })
	map("n", "gI", function()
		snacks.picker.lsp_implementations()
	end, { desc = "Goto Implementation" })
	map("n", "gy", function()
		snacks.picker.lsp_type_definitions()
	end, { desc = "Goto T[y]pe Definition" })
	map("n", "gai", function()
		snacks.picker.lsp_incoming_calls()
	end, { desc = "C[a]lls Incoming" })
	map("n", "gao", function()
		snacks.picker.lsp_outgoing_calls()
	end, { desc = "C[a]lls Outgoing" })
	map("n", "<leader>ss", function()
		snacks.picker.lsp_symbols()
	end, { desc = "LSP Symbols" })
	map("n", "<leader>sS", function()
		snacks.picker.lsp_workspace_symbols()
	end, { desc = "LSP Workspace Symbols" })

	map({ "n", "x", "o" }, "s", function()
		flash.jump()
	end, { desc = "Flash" })
	map({ "n", "x", "o" }, "S", function()
		flash.treesitter()
	end, { desc = "Flash Treesitter" })
end

local main_specs = {
	gh("tpope/vim-sleuth"),
	gh("pechorin/any-jump.vim"),
	gh("stevearc/conform.nvim"),
	gh("rafamadriz/friendly-snippets"),
	gh("numToStr/Comment.nvim"),
	gh("williamboman/mason.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("ray-x/guihua.lua"),
	gh("ray-x/go.nvim"),
	gh("stevearc/quicker.nvim"),
	gh("rebelot/kanagawa.nvim"),
	gh("Mofiqul/adwaita.nvim"),
	gh("folke/snacks.nvim"),
	gh("nvim-lua/plenary.nvim"),
	gh("MunifTanjim/nui.nvim"),
	gh("folke/which-key.nvim"),
	gh("stevearc/oil.nvim"),
	gh("folke/flash.nvim"),
	gh("NeogitOrg/neogit"),
	gh("esmuellert/codediff.nvim"),
	{ src = gh("github/copilot.vim"), version = "release" },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("nickjvandyke/opencode.nvim"), version = vim.version.range("0") },
}

function M.setup()
	add(main_specs)
	setup_main_plugins()
end

function M.setup_work()
	add({
		gh("nvim-lua/plenary.nvim"),
		gh("NeogitOrg/neogit"),
		gh("folke/snacks.nvim"),
	})

	require("neogit").setup({})
	require("snacks").setup({
		picker = {
			enabled = true,
			layout = {
				preview = false,
				preset = "ivy",
				position = "bottom",
				height = 0.25,
			},
			win = {
				border = "none",
				style = "minimal",
			},
		},
		notifier = {
			enabled = true,
			timeout = 2500,
		},
		rename = {
			enabled = true,
		},
	})
end

return M
