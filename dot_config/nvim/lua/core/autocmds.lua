vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
			vim.cmd("Neotree reveal")
		end
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "CursorHold", "FocusGained" }, {
	pattern = "*",
	callback = function()
		if vim.bo.modified then
			return
		end
		vim.cmd("checktime")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html", "lua" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"python",
		"rust",
		"markdown",
		"cpp",
		"c",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
	end,
})
