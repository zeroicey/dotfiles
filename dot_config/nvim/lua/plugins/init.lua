return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- === Rust ===
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- 立即加载：rust-analyzer 由本插件接管（无需 mason/lspconfig 配 rust_analyzer）
  },

  {
    "Saecki/crates.nvim",
    version = "v0.7.1",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },

  -- 补 treesitter 解析器（NvChad 默认只装 lua/vim 等）：rust + web 全栈
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "rust",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "scss",
        "vue",
        "json",
        "go",
        "markdown",
        "markdown_inline",
      })
    end,
  },

  -- ============ Web 开发 ============

  -- 跨机器自动安装 LSP / 格式化器（mason-tool-installer 在启动时补齐 ensure_installed 缺失包）
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- Web 语言服务器
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "vtsls",
        "vue-language-server",
        "tailwindcss-language-server",
        "emmet-ls",
        -- 格式化器
        "prettierd",
        -- 基础
        "stylua",
        "lua-language-server",
        "gopls",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- 自动闭合 / 同步重命名 HTML / JSX / Vue 标签
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },

  -- 上下文感知注释切换（gc/gcc，支持 JSX/TSX/Vue 的 {/* */} 与 <!-- -->）
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- custom nvim-tree: make <l> open like <o>, auto-open on directory
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    opts = function()
      local nvchad_cfg = require("nvchad.configs.nvimtree")
      local api = require("nvim-tree.api")

      nvchad_cfg.filters = vim.tbl_deep_extend("force", nvchad_cfg.filters or {}, {
        git_ignored = false,
      })

      nvchad_cfg.on_attach = function(bufnr)
        api.map.on_attach.default(bufnr)
        local function mopts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "l", api.node.open.edit, mopts("Open"))
      end

      return nvchad_cfg
    end,
  },
}
