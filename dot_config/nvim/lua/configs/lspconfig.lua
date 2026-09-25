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
  "clangd",     -- C / C++：补全、诊断、定义/声明/引用/实现跳转
  "texlab",     -- LaTeX：补全 / 诊断 / 悬停 / 格式化
}

-- C / C++：优先消费 CMake 生成的 compile_commands.json（放在 build/ 时也显式告诉 clangd）
local clangd_util = require "lspconfig.util"
-- NixOS 的 Mason clangd 是 generic ELF，运行时会被 nix-ld 拦截；优先使用系统 clangd。
-- macOS/Windows 没有这个路径时仍回退到 Mason/系统 PATH 中的 clangd。
local nix_clangd = "/run/current-system/sw/bin/clangd"
local clangd_bin = vim.fn.filereadable(nix_clangd) == 1 and nix_clangd or "clangd"
vim.lsp.config("clangd", {
  cmd = { clangd_bin },
  root_dir = clangd_util.root_pattern("CMakeLists.txt", "compile_commands.json", ".git"),
  before_init = function(config, ctx)
    -- lspconfig v2 传给 before_init 的 ctx.root_dir 可能仍是函数；统一从当前文件重新解析。
    local filename = vim.api.nvim_buf_get_name(ctx.bufnr or 0)
    local root = clangd_util.root_pattern("CMakeLists.txt", "compile_commands.json", ".git")(filename)
      or vim.uv.cwd()
    local build_db = root .. "/build/compile_commands.json"
    if vim.fn.filereadable(build_db) == 1 then
      config.cmd = { clangd_bin, "--compile-commands-dir=" .. root .. "/build" }
    end
  end,
})

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

-- LaTeX：texlab 只做语言服务，构建交给 vimtex 的 latexmk（避免双份构建）
vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = { onSave = false },
      chktex = { onOpenAndSave = true },
    },
  },
})

-- 必须在所有 config 定义完成后再 enable；否则 clangd 会被记录为 enabled，
-- 但当前文件不会因后续注册 config 而自动 attach。
vim.lsp.enable(servers)

-- Neovim 0.12 + lazy.nvim 的启动顺序下，文件可能早于 LSP config 注册；
-- 显式兜底启动 C/C++ client，并避免重复启动。
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function(args)
    if #vim.lsp.get_clients({ name = "clangd", bufnr = args.buf }) == 0 then
      vim.lsp.start(vim.lsp.config["clangd"], { bufnr = args.buf })
    end
  end,
})
