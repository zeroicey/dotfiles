local map = require("core.keymaps.utils").map

map("n", ",q", ":q<CR>", { desc = "Quit" })
map("n", ",w", ":w<CR>", { desc = "Write (Save)" })
map("n", "<leader>r", ":update<CR> :source<CR>")

map("n", ",f", function()
	require("conform").format()
end, { desc = "Format File" })
