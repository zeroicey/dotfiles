return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = "ToggleTerm",
		keys = {
			{ "<A-o>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle Terminal" },
		},
		opts = {
			open_mapping = "<a-o>",
			direction = "float",
			float_opts = {
				border = "curved",
				winblend = 3,
			},
		},
	},
}
