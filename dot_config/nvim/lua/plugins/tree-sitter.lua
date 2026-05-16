return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	main = "nvim-treesitter.config",
	opts = {},
	config = function(_, opts)
		require("nvim-treesitter.config").setup(opts)
		vim.treesitter.start()
	end,
}
