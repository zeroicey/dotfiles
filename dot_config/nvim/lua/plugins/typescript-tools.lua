return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
	opts = function()
		return {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
			settings = {
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
		}
	end,
}
