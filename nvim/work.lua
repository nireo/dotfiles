local source = debug.getinfo(1, "S").source:sub(2)
local config_root = vim.fn.fnamemodify(source, ":p:h")

vim.opt.rtp:prepend(config_root)

require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
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
		},
	},
}, {
	install = {
		missing = true,
		colorscheme = { "habamax" },
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"tarPlugin",
				"tutor",
			},
		},
	},
})

require("core.lsp")

local yank = require("custom.yank")
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "<leader>o", "<cmd>Explore<CR>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "<leader>cw", ":set textwidth=80 | normal! gggqG<CR>", { desc = "Format to 80 width" })
map("i", "<C-j>", "<Esc>")
map("i", "<C-f>", "<Esc>")
map("n", "<leader>q", ":q!<CR>")
map("n", "<C-s>", ":w!<CR>")
map("n", "<leader>wl", "<C-w>l<CR>")
map("n", "<leader>wh", "<C-w>h<CR>")
map("n", "<leader>wj", "<C-w>j<CR>")
map("n", "<leader>wk", "<C-w>k<CR>")
map("n", "<leader>|", "<C-w>v")
map("n", "<leader>-", "<C-w>s")
map("n", "<CR>", ":write!<CR>")
map({ "n", "v" }, "go", "%")
map({ "n", "v" }, "gh", "^")
map({ "n", "v" }, "gl", "$")
map("n", "<Tab>", "<C-W>w")
map("n", "<S-Tab>", "<C-W>W")
map("v", "<", "<gv")
map("v", ">", ">gv")
map({ "v", "x" }, "J", ":move '>+1<cr>gv-gv")
map({ "v", "x" }, "K", ":move '<-2<cr>gv-gv")
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>yb", function()
	local cur = vim.api.nvim_win_get_cursor(0)
	vim.cmd("normal! ggVGy")
	vim.api.nvim_win_set_cursor(0, cur)
	print("yanked whole file to system clipboard")
end)
map("n", "<leader>cg", "<cmd>Neogit<CR>")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "dd", function()
	if vim.fn.getline("."):match("^%s*$") then
		return '"_dd'
	end
	return "dd"
end, { expr = true })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
map("n", "<leader>t", function()
	local term_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
			term_buf = buf
			break
		end
	end

	if term_buf then
		vim.api.nvim_set_current_buf(term_buf)
	else
		vim.cmd("terminal")
	end

	vim.cmd("startinsert")
end, { desc = "Toggle terminal buffer" })
map("n", "<C-a>", "<C-^>", { desc = "Alternate file" })
map("n", "<leader>T", function()
	local term_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
			term_buf = buf
			break
		end
	end

	local width = vim.api.nvim_win_get_width(0)
	local height = vim.api.nvim_win_get_height(0)
	local split_cmd = (width > height * 2) and "vsplit" or "split"

	vim.cmd(split_cmd)
	if term_buf then
		vim.api.nvim_set_current_buf(term_buf)
	else
		vim.cmd("terminal")
	end

	vim.cmd("startinsert")
end, { desc = "Split terminal buffer" })
map("n", "<leader>rn", function()
	local number = vim.wo.number
	local relativenumber = vim.wo.relativenumber
	if number or relativenumber then
		vim.wo.number = false
		vim.wo.relativenumber = false
	else
		vim.wo.number = true
		vim.wo.relativenumber = true
	end
end, { desc = "Toggle line numbers" })
map("n", "<C-Left>", ":vertical resize -6<CR>")
map("n", "<C-Right>", ":vertical resize +6<CR>")
map("n", "<C-Up>", ":resize +6<CR>")
map("n", "<C-Down>", ":resize -6<CR>")
map("n", "gv", "<C-w>]", opts)
map("n", "<leader>lo", ":copen<CR>", opts)
map("n", "]q", ":cnext<CR>", opts)
map("n", "[q", ":cprev<CR>", opts)
map("n", "]Q", ":clast<CR>", opts)
map("n", "[Q", ":cfirst<CR>", opts)
map("n", "<leader>ln", ":cnext<CR>zz", opts)
map("n", "<leader>lp", ":cprev<CR>zz", opts)

local function quickfix_is_open()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			return true
		end
	end
	return false
end

local function toggle_quickfix()
	if quickfix_is_open() then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end

map("n", "<leader>lc", function()
	vim.fn.setqflist({})
	vim.cmd("cclose")
end, opts)
map("n", "<leader>lr", ":copen<CR>", opts)
map("n", "<leader>lq", toggle_quickfix, { desc = "Toggle quickfix" })
map("n", "<leader>ll", toggle_quickfix, { desc = "Toggle quickfix" })
map("n", "<leader>ya", function()
	yank.yank_path(yank.get_buffer_absolute(), "absolute")
end, { desc = "[Y]ank [A]bsolute path to clipboard" })
map("n", "<leader>yr", function()
	yank.yank_path(yank.get_buffer_cwd_relative(), "relative")
end, { desc = "[Y]ank [R]elative path to clipboard" })
map("v", "<leader>ya", function()
	yank.yank_visual_with_path(yank.get_buffer_absolute(), "absolute")
end, { desc = "[Y]ank selection with [A]bsolute path" })
map("v", "<leader>yr", function()
	yank.yank_visual_with_path(yank.get_buffer_cwd_relative(), "relative")
end, { desc = "[Y]ank selection with [R]elative path" })

map("n", "ff", function()
	Snacks.picker.files()
end, { desc = "Find files" })
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
map("n", "gw", function()
	Snacks.picker.grep_word()
end, { desc = "Grep word" })
map("n", "<S-h>", function()
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
			list = {
				keys = {
					["d"] = "bufdelete",
				},
			},
		},
	})
end, { desc = "Buffers" })
map("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto definition" })
map("n", "gr", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })
map("n", "gI", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto implementation" })
map("n", "gy", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Goto type definition" })
map("n", "gai", function()
	Snacks.picker.lsp_incoming_calls()
end, { desc = "Incoming calls" })
map("n", "gao", function()
	Snacks.picker.lsp_outgoing_calls()
end, { desc = "Outgoing calls" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP symbols" })
map("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Workspace symbols" })
map("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, { desc = "Rename file" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("work-safe-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

local winbar_branch_cache = {}
local uv = vim.uv or vim.loop

local function winbar_git_branch(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return ""
	end

	local git_dir = vim.fs.find(".git", { path = vim.fs.dirname(name), upward = true, limit = 1 })[1]
	if not git_dir then
		return ""
	end

	local git_root = vim.fs.dirname(git_dir)
	local now = uv.now()
	local cached = winbar_branch_cache[git_root]
	if cached and now - cached.at < 5000 then
		return cached.branch
	end

	local result = vim.system({ "git", "-C", git_root, "branch", "--show-current" }, { text = true }):wait()
	local branch = result.code == 0 and vim.trim(result.stdout or "") or ""
	winbar_branch_cache[git_root] = { branch = branch, at = now }

	return branch
end

function _G.MyWinBar()
	local bufnr = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(bufnr)
	local path = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
	local diagnostics = {}
	local severities = vim.diagnostic.severity
	local errors = #vim.diagnostic.get(bufnr, { severity = severities.ERROR })
	local warnings = #vim.diagnostic.get(bufnr, { severity = severities.WARN })
	local info = #vim.diagnostic.get(bufnr, { severity = severities.INFO })
	local branch = winbar_git_branch(bufnr)

	if branch ~= "" then
		table.insert(diagnostics, "git:" .. branch)
	end
	if errors > 0 then
		table.insert(diagnostics, "E:" .. errors)
	end
	if warnings > 0 then
		table.insert(diagnostics, "W:" .. warnings)
	end
	if info > 0 then
		table.insert(diagnostics, "I:" .. info)
	end

	local left = " " .. path .. " %m%r"
	local right = table.concat(diagnostics, "  ")
	if right == "" then
		return left
	end

	return left .. "%=" .. right .. " "
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "WinEnter" }, {
	group = vim.api.nvim_create_augroup("work-safe-filename-winbar", { clear = true }),
	callback = function(args)
		local win_config = vim.api.nvim_win_get_config(0)
		if win_config.relative ~= "" or vim.bo[args.buf].buftype ~= "" then
			vim.opt_local.winbar = ""
			return
		end

		vim.opt_local.winbar = "%!v:lua.MyWinBar()"
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("work-safe-lsp-attach", { clear = true }),
	callback = function(event)
		local function lsp_map(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		lsp_map("gl", vim.diagnostic.open_float, "Open Diagnostic Float")
		lsp_map("K", vim.lsp.buf.hover, "Hover Documentation")
		lsp_map("gs", vim.lsp.buf.signature_help, "Signature Documentation")
		lsp_map("<leader>la", vim.lsp.buf.code_action, "Code Action")
		lsp_map("<leader>lr", vim.lsp.buf.rename, "Rename all references")
		lsp_map("<leader>lf", vim.lsp.buf.format, "Format")
		lsp_map("<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", "Goto Definition in Vertical Split")

		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			end
			return client.supports_method(method, { bufnr = bufnr })
		end

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
			local highlight_group = vim.api.nvim_create_augroup("work-safe-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_group,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("work-safe-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event2.buf })
				end,
			})
		end
	end,
})

vim.o.background = "dark"
vim.cmd.colorscheme("mute_original")
