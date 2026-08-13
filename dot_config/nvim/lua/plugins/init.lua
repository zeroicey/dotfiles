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

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- custom nvim-tree: make <l> open like <o>, auto-open on directory
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    opts = function()
      local nvchad_cfg = require("nvchad.configs.nvimtree")
      local api = require("nvim-tree.api")

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
