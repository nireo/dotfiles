vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<leader>o", ":Oil<CR>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<leader>cw", ":set textwidth=80 | normal! gggqG<CR>", { desc = "Format to 80 width" })
vim.keymap.set("i", "<C-j>", "<ESC>")
vim.keymap.set("i", "<C-f>", "<ESC>")
vim.keymap.set("n", "<leader>q", ":q!<CR>")
vim.keymap.set("n", "<C-s>", ":w!<CR>")

vim.keymap.set("n", "<leader>wl", "<C-w>l<CR>")
vim.keymap.set("n", "<leader>wh", "<C-w>h<CR>")
vim.keymap.set("n", "<leader>wj", "<C-w>j<CR>")
vim.keymap.set("n", "<leader>wk", "<C-w>k<CR>")

vim.keymap.set("n", "<leader>|", "<C-w>v")
vim.keymap.set("n", "<leader>-", "<C-w>s")
vim.keymap.set("n", "<CR>", ":write!<CR>")
vim.keymap.set({ "n", "v" }, "go", "%")
vim.keymap.set({ "n", "v" }, "gh", "^")
vim.keymap.set({ "n", "v" }, "gl", "$")
vim.keymap.set("n", "<Tab>", "<C-W>w")
vim.keymap.set("n", "<S-Tab>", "<C-W>W")

vim.keymap.set("n", "<leader>ie", ":GoIfErr<CR>")
vim.keymap.set("n", "<leader>gotf", ":GoTestFile<CR>")
vim.keymap.set("n", "<leader>gofn", ":GoTestFunc<CR>")
vim.keymap.set("n", "<leader>gofs", ":GoFillStruct<CR>")
vim.keymap.set("n", "<leader>goj", ":GoAddTag json<CR>")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set({ "v", "x" }, "J", ":move '>+1<cr>gv-gv")
vim.keymap.set({ "v", "x" }, "K", ":move '<-2<cr>gv-gv")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>yb", function()
	local cur = vim.api.nvim_win_get_cursor(0)
	vim.cmd("normal! ggVGy")
	vim.api.nvim_win_set_cursor(0, cur)

	print("yanked whole file to system clipboard")
end)

-- open neogit
vim.keymap.set("n", "<leader>cg", ":Neogit<CR>")

-- center search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- do not copy empty lines when deleting them
vim.keymap.set("n", "dd", function()
	if vim.fn.getline("."):match("^%s*$") then
		return '"_dd'
	end
	return "dd"
end, { expr = true })

-- diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open float window to properly read diagnostic" })

-- open full screen terminal
vim.keymap.set("n", "<leader>t", function()
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

vim.keymap.set("n", "<C-a>", "<C-^>", { desc = "Go to back from terminal" })

-- open a terminal via a smart split, i.e. checks the size of the screen and based on that does
-- vertical or horizontal split.
vim.keymap.set("n", "<leader>T", function()
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

	if term_buf then
		vim.cmd(split_cmd)
		vim.api.nvim_set_current_buf(term_buf)
	else
		vim.cmd(split_cmd)
		vim.cmd("terminal")
	end

	vim.cmd("startinsert")
end, { desc = "Split terminal buffer" })

vim.keymap.set("n", "<leader>rn", function()
	local number = vim.wo.number
	local relativenumber = vim.wo.relativenumber
	if number or relativenumber then
		vim.wo.number = false
		vim.wo.relativenumber = false
	else
		vim.wo.number = true
		vim.wo.relativenumber = true
	end
end, { desc = "Toggle line numbers (absolute + relative)" })

vim.keymap.set("n", "<C-Left>", ":vertical resize -6<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +6<CR>")
vim.keymap.set("n", "<C-Up>", ":resize +6<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -6<CR>")
vim.keymap.set("n", "gv", "<C-w>]", { noremap = true, silent = true }) -- jump to def in another window

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>lo", ":copen<CR>", opts)
vim.keymap.set("n", "<leader>lc", ":cclose<CR>", opts)

vim.keymap.set("n", "]q", ":cnext<CR>", opts)
vim.keymap.set("n", "[q", ":cprev<CR>", opts)
vim.keymap.set("n", "]Q", ":clast<CR>", opts)
vim.keymap.set("n", "[Q", ":cfirst<CR>", opts)

vim.keymap.set("n", "<leader>ln", ":cnext<CR>zz", opts)
vim.keymap.set("n", "<leader>lp", ":cprev<CR>zz", opts)

vim.keymap.set("n", "<leader>lc", function()
	vim.fn.setqflist({})
end, opts)

vim.keymap.set("n", "<leader>lr", ":copen<CR>", opts)
vim.keymap.set("n", "<leader>lq", function()
	require("quicker").toggle()
end, {
	desc = "Toggle quickfix",
})

vim.keymap.set("n", "<leader>ll", function()
	require("quicker").toggle()
end, {
	desc = "Toggle quickfix",
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
