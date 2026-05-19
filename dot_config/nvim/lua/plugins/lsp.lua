local servers = {
	clangd = {},
	marksman = {},
	tailwindcss = {},
	cssls = {},
	html = {},
	emmet_ls = {},
	gopls = {
		settings = {
			gopls = {
				gofumpt = true,
				usePlaceholders = true,
				completeFunctionCalls = true,
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				analyses = {
					nilness = true,
					shadow = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
				},
			},
		},
	},
	pyright = {
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly",
					reportMissingTypeStubs = "none",
					typeCheckingMode = "standard",
					useLibraryCodeForTypes = true,
				},
			},
		},
	},
	postgres_lsp = {},
	lua_ls = {
		on_init = function(client)
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				local fs_stat = (vim.uv or vim.loop).fs_stat
				if path ~= vim.fn.stdpath("config") and (fs_stat(path .. "/.luarc.json") or fs_stat(path .. "/.luarc.jsonc")) then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
				runtime = {
					version = "LuaJIT",
					path = {
						"lua/?.lua",
						"lua/?/init.lua",
					},
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
					},
				},
			})
		end,
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
			},
		},
	},
}

local mason_lsp_servers = vim.tbl_keys(servers)
local mason_tools = {
	"stylua",
	"prettierd",
	"isort",
	"black",
	"typescript-language-server",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"saghen/blink.cmp",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = mason_lsp_servers,
			automatic_enable = false,
		})
		require("mason-tool-installer").setup({
			ensure_installed = mason_tools,
		})

		local diagnostic_signs = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		}

		local function set_diagnostics_enabled(enable)
			vim.diagnostic.enable(enable)

			local ok, tiny_inline_diagnostic = pcall(require, "tiny-inline-diagnostic")
			if ok then
				if enable then
					tiny_inline_diagnostic.enable()
				else
					tiny_inline_diagnostic.disable()
				end
			end
		end

		local function with_blink_capabilities(config)
			config = vim.deepcopy(config or {})
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			return config
		end

		local function prompt_workspace_symbols()
			vim.ui.input({ prompt = "Workspace symbols > " }, function(query)
				if query and query ~= "" then
					vim.lsp.buf.workspace_symbol(query)
				end
			end)
		end

		for server_name, server_config in pairs(servers) do
			vim.lsp.config(server_name, with_blink_capabilities(server_config))
			vim.lsp.enable(server_name)
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				map("gh", vim.lsp.buf.hover, "Hover Documentation")
				map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
				map("gK", vim.lsp.buf.signature_help, "Signature Help")

				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("grr", vim.lsp.buf.references, "[G]oto [R]eferences")
				map("grt", vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")
				map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
				map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				map("<leader>ls", vim.lsp.buf.document_symbol, "[L]SP Document [S]ymbols")
				map("<leader>lS", prompt_workspace_symbols, "[L]SP Workspace [S]ymbols")

				local function client_supports_method(client, method, bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				if
					client
					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
				then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = {
				text = diagnostic_signs,
			},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		local diagnostic_jump_float = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
				border = "rounded",
				source = "if_many",
			})
		end

		local diagnostic_jump = function(count, severity)
			return function()
				vim.diagnostic.jump({
					count = count,
					severity = severity,
					on_jump = diagnostic_jump_float,
				})
			end
		end

		vim.keymap.set("n", "]d", diagnostic_jump(1), { desc = "Next Diagnostic" })
		vim.keymap.set("n", "[d", diagnostic_jump(-1), { desc = "Previous Diagnostic" })
		vim.keymap.set("n", "]e", diagnostic_jump(1, vim.diagnostic.severity.ERROR), { desc = "Next Error" })
		vim.keymap.set("n", "[e", diagnostic_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Previous Error" })

		vim.keymap.set("n", "<leader>td", function()
			local enable = not vim.diagnostic.is_enabled()
			set_diagnostics_enabled(enable)
			vim.api.nvim_echo(
				{ { enable and "Diagnostics enabled" or "Diagnostics hidden", "ModeMsg" } },
				false,
				{}
			)
		end, { desc = "[T]oggle [D]iagnostics" })

		vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "[D]iagnostic [E]xplain" })
		vim.keymap.set("n", "<leader>dl", function()
			vim.diagnostic.setloclist({ open = true })
		end, { desc = "[D]iagnostic [L]ocation List" })
		vim.keymap.set("n", "<leader>dq", function()
			vim.diagnostic.setqflist({ open = true })
		end, { desc = "[D]iagnostic [Q]uickfix List" })

		set_diagnostics_enabled(false)
	end,
}
