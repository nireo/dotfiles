return {
	{
		"github/copilot.vim",
		cmd = "Copilot",
		keys = {
			vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Toggle Copilot" }),
			vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Toggle Copilot" }),
		},
		config = function()
			vim.g.copilot_enabled = false
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = "CodeDiff",
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"stevearc/oil.nvim",
		opts = {},
		lazy = false,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
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
				},
				formatters = {
					file = {
						truncate = 120,
					},
				},
			},
			notifier = {
				enabled = true,
				timeout = 3000,
			},
		},
		keys = {
			{
				"<leader>gi",
				function()
					Snacks.picker.gh_issue()
				end,
				desc = "GitHub Issues (open)",
			},
			{
				"<leader>gI",
				function()
					Snacks.picker.gh_issue({ state = "all" })
				end,
				desc = "GitHub Issues (all)",
			},
			{
				"<leader>gp",
				function()
					Snacks.picker.gh_pr()
				end,
				desc = "GitHub Pull Requests (open)",
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>gP",
				function()
					Snacks.picker.gh_pr({ state = "all" })
				end,
				desc = "GitHub Pull Requests (all)",
			},
			{
				"gr",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find files",
			},
			{
				"gw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Grep",
			},
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<S-h>",
				function()
					Snacks.picker.buffers({
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
							list = { keys = { ["d"] = "bufdelete" } },
						},
					})
				end,
				desc = "[P]Snacks picker buffers",
			},
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle Zen Mode",
			},

		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"gai",
			function()
				Snacks.picker.lsp_incoming_calls()
			end,
			desc = "C[a]lls Incoming",
		},
		{
			"gao",
			function()
				Snacks.picker.lsp_outgoing_calls()
			end,
			desc = "C[a]lls Outgoing",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>sS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},
}
