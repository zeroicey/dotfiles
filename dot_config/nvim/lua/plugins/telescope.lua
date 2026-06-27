return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live Grep",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Find Buffers",
		},
		{
			"<leader>fh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Help Tags",
		},
	},
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					prompt_position = "top",
				},
				sorting_strategy = "ascending",
				winblend = 0,
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		})
	end,
}
