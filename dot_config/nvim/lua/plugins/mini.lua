return {
	"nvim-mini/mini.nvim",
	version = "*",
	lazy = false,
	config = function()
		local function show_message_history()
			local output = vim.api.nvim_exec2("silent messages", { output = true }).output
			local lines = vim.split(output, "\n", { plain = true, trimempty = false })

			vim.cmd("botright new")
			local buf = vim.api.nvim_get_current_buf()
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].swapfile = false
			vim.bo[buf].modifiable = true
			vim.bo[buf].filetype = "messages"
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].modifiable = false
		end

		require("mini.cursorword").setup()
		require("mini.indentscope").setup({
			draw = {
				animation = require("mini.indentscope").gen_animation.none(),
			},
			symbol = "│",
		})
		require("mini.statusline").setup()

		vim.api.nvim_create_user_command("MessageHistory", show_message_history, {
			desc = "Show :messages in a copyable buffer",
		})
		vim.keymap.set("n", "<leader>mh", show_message_history, { desc = "[M]essage [H]istory" })
	end,
}
