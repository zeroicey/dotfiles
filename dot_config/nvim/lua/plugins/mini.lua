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

		local function statusline_filename()
			if vim.bo.buftype == "terminal" then
				return "%t"
			end

			if vim.fn.expand("%:t") == "" then
				return "[No Name]"
			end

			return "%t%m%r"
		end

		local function statusline_filetype()
			if MiniStatusline.is_truncated(70) then
				return ""
			end

			return vim.bo.filetype
		end

		local function active_statusline()
			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 9999 })
			local search = MiniStatusline.section_searchcount({
				trunc_width = 90,
				options = { recompute = false },
			})

			return MiniStatusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { statusline_filename() } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { search, statusline_filetype() } },
				{ hl = mode_hl, strings = { "%l:%2v" } },
			})
		end

		local function inactive_statusline()
			return "%#MiniStatuslineInactive# %t%m%r%="
		end

		require("mini.cursorword").setup()
		require("mini.indentscope").setup({
			draw = {
				animation = require("mini.indentscope").gen_animation.none(),
			},
			symbol = "│",
		})
		require("mini.statusline").setup({
			content = {
				active = active_statusline,
				inactive = inactive_statusline,
			},
			use_icons = false,
		})

		vim.api.nvim_create_user_command("MessageHistory", show_message_history, {
			desc = "Show :messages in a copyable buffer",
		})
		vim.keymap.set("n", "<leader>mh", show_message_history, { desc = "[M]essage [H]istory" })
	end,
}
