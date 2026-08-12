require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- save and quit
map("n", ",w", "<cmd>w<CR>", { desc = "save file" })
map("n", ",q", "<cmd>q<CR>", { desc = "quit" })

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
		local file = vim.fn.expand("%")
		if file ~= "" and vim.fn.filereadable(file) == 1 then
			tree.find_file()
		else
			tree.toggle()
		end
	end
end, { desc = "toggle/focus file tree" })

-- disable default nvchad file tree keys
vim.keymap.del("n", "<C-n>")
vim.keymap.del("n", "<leader>e")
