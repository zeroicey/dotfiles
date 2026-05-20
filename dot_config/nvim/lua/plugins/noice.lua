return {
	"folke/noice.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>nh",
			function()
				require("noice").cmd("history")
			end,
			desc = "[N]oice [H]istory",
		},
		{
			"<leader>nl",
			function()
				require("noice").cmd("last")
			end,
			desc = "[N]oice [L]ast",
		},
		{
			"<leader>ne",
			function()
				require("noice").cmd("errors")
			end,
			desc = "[N]oice [E]rrors",
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim",
	},

	opts = {
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	},
}
