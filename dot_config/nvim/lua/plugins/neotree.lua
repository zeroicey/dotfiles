return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"antosha417/nvim-lsp-file-operations",
			"s1n7ax/nvim-window-picker",
		},
		keys = {
			{
				"<A-e>",
				function()
					if vim.bo.filetype == "neo-tree" then
						vim.cmd.Neotree("close")
					else
						vim.cmd.Neotree("reveal")
					end
				end,
				desc = "Toggle/Reveal Neo-tree",
			},
			{ "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Explorer" },
			{ "<leader>be", "<cmd>Neotree toggle source=buffers position=right<cr>", desc = "Buffer Explorer" },
			{ "<leader>gs", "<cmd>Neotree toggle source=git_status position=float<cr>", desc = "Git Status Explorer" },
			{
				"<leader>lo",
				"<cmd>Neotree toggle source=document_symbols position=right<cr>",
				desc = "Outline Explorer",
			},
		},
		opts = {
			close_if_last_window = true,
			source_selector = {
				winbar = true,
				sources = {
					{ source = "filesystem", display_name = " Files " },
					{ source = "buffers", display_name = " Buffers " },
					{ source = "git_status", display_name = " Git " },
					{ source = "document_symbols", display_name = " Symbols " },
				},
			},
			filesystem = {
				hijack_netrw_behavior = "disabled",
				window = {
					width = "30%",
					mappings = {
						["l"] = "open",
						["oc"] = "none",
						["od"] = "none",
						["og"] = "none",
						["om"] = "none",
						["on"] = "none",
						["os"] = "none",
						["ot"] = "none",
						["o"] = {
							command = function(state)
								local node = state.tree:get_node()
								if node.type == "file" then
									-- 如果是文件，先调用内置的 open 命令打开
									state.commands.open(state)
									-- 然后立即将焦点切回 Neo-tree
									vim.cmd("Neotree focus")
								else
									-- 如果是目录，则执行默认的切换展开/折叠操作
									state.commands.open(state)
								end
							end,
							desc = "Open file and stay in neo-tree",
							nowait = true,
						},
					},
				},
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
			require("lsp-file-operations").setup()
		end,
	},
	{
		"antosha417/nvim-lsp-file-operations",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		lazy = true,
		config = function()
			require("window-picker").setup({
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
						filetype = { "neo-tree", "neo-tree-popup", "notify", "noice" },
						-- if the buffer type is one of following, the window will be ignored
						buftype = { "terminal", "quickfix" },
					},
				},
			})
		end,
	},
}
