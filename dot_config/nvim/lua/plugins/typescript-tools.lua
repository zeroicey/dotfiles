return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	config = function()
		require("typescript-tools").setup({
			capabilities = require("blink.cmp").get_lsp_capabilities(),
			settings = {
				separate_diagnostic_server = true,
				publish_diagnostic_on = "insert_leave",
				complete_function_calls = false,
				include_completions_with_insert_text = true,
				tsserver_file_preferences = {
					includeCompletionsWithSnippetText = false,
					includeCompletionsWithClassMemberSnippets = false,
					includeCompletionsWithObjectLiteralMethodSnippets = false,
				},
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
		})
	end,
}
