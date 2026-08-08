local function close_buffer(bufnr)
	require("core.keymaps.file").close_buffer(bufnr)
end

return {
	"akinsho/bufferline.nvim",
	version = "*",
	lazy = false,
	dependencies = "nvim-tree/nvim-web-devicons",
	keys = {
		{ "9", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "0", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },

		{ "(", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Left" },
		{ ")", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Right" },
	},
	opts = {
		options = {
			close_command = close_buffer,
			right_mouse_command = close_buffer,
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and "󰅚 " or "󰀪 "
				return " " .. icon .. count
			end,
			offsets = {
				{
					filetype = "neo-tree",
					text = "Explorer",
					text_align = "left",
					separator = true,
				},
			},
		},
	},
}
