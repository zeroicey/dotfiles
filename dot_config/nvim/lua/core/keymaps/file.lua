local map = require("core.keymaps.utils").map

local M = {}

map("n", ",q", ":q<CR>", { desc = "Quit" })
map("n", ",w", ":w<CR>", { desc = "Write (Save)" })
map("n", "<leader>r", ":update<CR> :source<CR>")

function M.close_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	if vim.bo[bufnr].modified then
		vim.notify("Current buffer has unsaved changes. Save it before closing.", vim.log.levels.WARN)
		return false
	end

	local current = vim.api.nvim_get_current_buf()
	if bufnr == current then
		local listed_buffers = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
		end, vim.api.nvim_list_bufs())

		local current_index
		for index, buf in ipairs(listed_buffers) do
			if buf == current then
				current_index = index
				break
			end
		end

		if #listed_buffers > 1 and current_index then
			local next_index = current_index % #listed_buffers + 1
			vim.api.nvim_set_current_buf(listed_buffers[next_index])
		end
	end

	local ok, err = pcall(vim.cmd.bdelete, bufnr)
	if not ok then
		vim.notify(err, vim.log.levels.WARN)
	end

	return ok
end

map("n", "<leader>bd", function()
	M.close_buffer()
end, { desc = "Close Current Buffer" })

map("n", ",f", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end, { desc = "Format File" })

return M
