local map = require("core.keymaps.utils").map

map("n", "<leader>h", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<leader>j", "<C-w>j", { desc = "Go to Down Window" })
map("n", "<leader>k", "<C-w>k", { desc = "Go to Up Window" })
map("n", "<leader>l", "<C-w>l", { desc = "Go to Right Window" })

map("n", "<leader>\\", "<C-w>v", { desc = "Split Window Vertically" })
map("n", "<leader>-", "<C-w>s", { desc = "Split Window Horizontally" })
map("n", "<leader>o", ":only<CR>", { desc = "Keep Only Current Window" })

map("n", "=", "<cmd>vertical resize +5<cr>", { desc = "Increase Window Width" })
map("n", "-", "<cmd>vertical resize -5<cr>", { desc = "Decrease Window Width" })
map("n", "+", "<cmd>horizontal resize +2<cr>", { desc = "Increase Window Height" })
map("n", "_", "<cmd>horizontal resize -2<cr>", { desc = "Decrease Window Height" })
