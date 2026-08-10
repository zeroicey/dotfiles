local map = require("core.keymaps.utils").map

-- Set <Space> as the leader key.
map("n", "<Space>", "", {})

map("i", "jj", "<Esc>")

map("n", ";", ":", { desc = "Open the command" })
