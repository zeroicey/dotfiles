return {
	"saghen/blink.cmp",
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets", "moyiz/blink-emoji.nvim" },

	-- use a release tag to download pre-built binaries
	version = "1.*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = function()
		local function snippet_to_plain_text(snippet)
			local ok, parsed = pcall(vim.lsp._snippet_grammar.parse, snippet)
			if ok then
				return tostring(parsed)
			end

			local plain = snippet

			plain = plain:gsub("%${%d+:([^}]*)}", "%1")
			plain = plain:gsub("%${%d+|([^}]*)|}", function(choices)
				return vim.split(choices, ",", { plain = true })[1] or ""
			end)
			plain = plain:gsub("%${%d+}", "")
			plain = plain:gsub("%$%d+", "")
			plain = plain:gsub("%${[^}:]+:([^}]*)}", "%1")
			plain = plain:gsub("%${[^}]+}", "")
			plain = plain:gsub("\\([$}])", "%1")

			return plain
		end

		local function insert_plain_text_at_cursor(text)
			local row, col = unpack(vim.api.nvim_win_get_cursor(0))
			local lines = vim.split(text, "\n", { plain = true })

			vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)

			local end_row = row - 1 + #lines - 1
			local end_col = (#lines == 1) and (col + #lines[1]) or #lines[#lines]
			vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
		end

		local function safe_expand_snippet(snippet)
			local ok = pcall(vim.snippet.expand, snippet)
			if ok then
				return
			end

			insert_plain_text_at_cursor(snippet_to_plain_text(snippet))
		end

		return {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "enter",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },

				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },

				["<C-p>"] = { "snippet_backward", "fallback" },
				["<C-n>"] = { "snippet_forward", "fallback" },

				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },

				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = {
				documentation = {
					auto_show = true,
					treesitter_highlighting = false,
					window = { border = "rounded" },
				},
				list = { selection = { preselect = true } },
				menu = {
					border = "rounded",
					draw = {
						components = {
							kind_icon = {
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end

									return icon .. ctx.icon_gap
								end,

								-- Optionally, use the highlight groups from nvim-web-devicons
								-- You can also add the same function for `kind.highlight` if you want to
								-- keep the highlight groups in sync with the icons.
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end
									return hl
								end,
							},
						},
					},
				},
			},
			signature = {
				enabled = true,
				window = {
					treesitter_highlighting = false,
				},
			},
			snippets = {
				expand = safe_expand_snippet,
			},
			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "emoji" },
				providers = {
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 15, -- Tune by preference
						opts = {
							insert = true, -- Insert emoji (default) or complete its name
							---@type string|table|fun():table
							trigger = function()
								return { ":" }
							end,
						},
					},
				},
			},

			-- Prefer the Rust fuzzy matcher when available, but silently fall back to Lua
			-- if the prebuilt binary is unavailable.
			fuzzy = { implementation = "prefer_rust" },
		}
	end,
	opts_extend = { "sources.default" },
}
