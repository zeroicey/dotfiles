return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		vim.cmd([[colorscheme tokyonight]])

		-- subtle thin window separators (VS Code-like),
		-- overrides tokyonight's default bold black separator line
		local palette = require("tokyonight.colors").setup({ style = "night" })
		local separator = { fg = palette.bg_highlight, bold = false }
		vim.api.nvim_set_hl(0, "WinSeparator", separator)
		vim.api.nvim_set_hl(0, "VertSplit", separator)
	end,
}
