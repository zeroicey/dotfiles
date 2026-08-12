require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- hover: K(default) -> gh
map("n", "gh", vim.lsp.buf.hover, { desc = "hover documentation" })

-- J/K: 5-line movement (normal + visual)
map("n", "J", "5j", { desc = "move down 5 lines" })
map("n", "K", "5k", { desc = "move up 5 lines" })
map("v", "J", "5j", { desc = "extend selection down 5 lines" })
map("v", "K", "5k", { desc = "extend selection up 5 lines" })

-- H/L: line start/end (normal + visual)
map("n", "H", "^", { desc = "go to first char of line" })
map("n", "L", "$", { desc = "go to end of line" })
map("v", "H", "^", { desc = "extend selection to first char" })
map("v", "L", "g_", { desc = "extend selection to end of line" })

-- save and quit
map("n", ",w", "<cmd>w<CR>", { desc = "save file" })

-- smart quit: if closing this window leaves only helper windows (e.g. file tree), exit nvim entirely
map("n", ",q", function()
	local current = vim.api.nvim_get_current_win()
	local other_real = false
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= current then
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype == "" then
				other_real = true
				break
			end
		end
	end

	if other_real then
		vim.cmd("q")
	else
		vim.cmd("qa")
	end
end, { desc = "quit (with file tree)" })

-- file tree: <A-e>
-- 1. tree not open: open and focus it
-- 2. inside tree: close it
-- 3. tree open but not focused: focus it
map("n", "<A-e>", function()
	local tree = require("nvim-tree.api").tree
	if tree.is_tree_buf() then
		tree.close()
	elseif tree.is_visible() then
		tree.focus()
	else
		tree.toggle()
	end
end, { desc = "toggle/focus file tree" })

-- disable default nvchad file tree keys
vim.keymap.del("n", "<C-n>")
vim.keymap.del("n", "<leader>e")
