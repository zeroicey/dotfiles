local map = require("core.keymaps.utils").map
local paste = require("core.paste")

map("n", "J", "5j", { desc = "Move Down 5 Lines" })
map("n", "K", "5k", { desc = "Move Up 5 Lines" })
map("n", "H", "^", { desc = "Go to First Character of Line" })
map("n", "L", "$", { desc = "Go to End of Line" })

map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })
map("v", "J", "5j", { desc = "Extend Selection Down 5 Lines" })
map("v", "K", "5k", { desc = "Extend Selection Up 5 Lines" })
map("v", "H", "^", { desc = "Extend Selection to First Character" })
map("v", "L", "g_", { desc = "Extend Selection to End of Line" })

map("n", "p", function()
	paste.paste_then_fix("p")
end, { desc = "Paste After and Fix Indent" })

map("n", "P", function()
	paste.paste_then_fix("P")
end, { desc = "Paste Before and Fix Indent" })

map("n", "gp", function()
	paste.paste_then_fix("gp")
end, { desc = "Paste After, Leave Cursor After, and Fix Indent" })

map("n", "gP", function()
	paste.paste_then_fix("gP")
end, { desc = "Paste Before, Leave Cursor After, and Fix Indent" })
