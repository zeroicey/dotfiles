return {
	"hat0uma/csvview.nvim",
	ft = { "csv", "tsv" },
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
	---@module "csvview"
	---@type CsvView.Options
	opts = {
		view = {
			display_mode = "border",
			sticky_header = {
				enabled = true,
			},
		},
	},
	config = function(_, opts)
		require("csvview").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("zeroicey-csvview-auto-enable", { clear = true }),
			pattern = { "csv", "tsv" },
			callback = function(args)
				if vim.b[args.buf].csvview_auto_enabled then
					return
				end

				vim.b[args.buf].csvview_auto_enabled = true
				vim.cmd("CsvViewEnable")
			end,
		})
	end,
}
