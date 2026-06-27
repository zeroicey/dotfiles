return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-mini/mini.nvim",
	},
	---@module "render-markdown"
	---@type render.md.UserConfig
	opts = {
		render_modes = true,
		restart_highlighter = false,
		anti_conceal = {
			enabled = true,
		},
		heading = {
			position = "inline",
			width = "block",
		},
		code = {
			sign = false,
			width = "block",
			right_pad = 1,
			disable_background = { "diff" },
		},
	},
}
