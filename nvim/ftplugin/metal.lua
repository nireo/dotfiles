-- Metal Shading Language is a C++-based dialect.
vim.cmd.runtime("ftplugin/cpp.vim")

vim.bo.commentstring = "// %s"
vim.bo.syntax = "metal"
vim.opt_local.suffixesadd:append({ ".metal", ".h" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setlocal commentstring< syntax< suffixesadd<"
