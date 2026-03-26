vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
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
	group = vim.api.nvim_create_augroup("filename-winbar", { clear = true }),
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
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("gl", vim.diagnostic.open_float, "Open Diagnostic Float")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gs", vim.lsp.buf.signature_help, "Signature Documentation")
		map("<leader>la", vim.lsp.buf.code_action, "Code Action")
		map("<leader>lr", vim.lsp.buf.rename, "Rename all references")
		map("<leader>lf", vim.lsp.buf.format, "Format")
		map("<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Goto Definition in Vertical Split")

		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			else
				return client.supports_method(method, { bufnr = bufnr })
			end
		end

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
				end,
			})
		end
	end,
})
