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

  -- 补 Rust treesitter 解析器（NvChad 默认只装 lua/vim 等）
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "rust" })
    end,
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
