require("nvchad.configs.lspconfig").defaults()

-- Web 开发语言服务器（二进制由 mason ensure_installed 自动安装，见 plugins/init.lua）
local servers = {
  "html",       -- HTML
  "cssls",      -- CSS / SCSS / LESS
  "jsonls",     -- JSON / JSONC
  "vtsls",      -- TypeScript / JavaScript / TSX / JSX
  "volar",      -- Vue 3 (.vue)
  "tailwindcss", -- Tailwind CSS（需项目含 tailwind.config.*）
  "emmet_ls",   -- HTML/CSS Emmet 缩写补全
  "gopls",      -- Go
  "basedpyright", -- Python：类型检查 / 补全 / 自动识别项目 .venv（uv 项目同理）
  "ruff",       -- Python：lint + import 排序（格式化交给 conform 的 ruff_format）
}
vim.lsp.enable(servers)

-- Python 两件套分工：basedpyright 管类型与补全，ruff 只管 lint/imports（格式化不重复写）
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard", -- 比 off/basic 严，比 strict 温和
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})
vim.lsp.config("ruff", {
  init_options = { settings = { logLevel = "error" } },
  on_attach = function(client)
    -- 格式化统一走 conform（ruff_format），不让 ruff LSP 再包一份，避免双写/抢写
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers 
