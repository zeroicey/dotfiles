return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		spec = {
			{ "<leader>b", group = "Buffers" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>m", group = "Messages" },
			{ "<leader>n", group = "Noice" },
			{ "<leader>t", group = "Toggles" },
			{ "<leader>w", proxy = "<C-w>", group = "Windows" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
