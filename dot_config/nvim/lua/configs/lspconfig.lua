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
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
