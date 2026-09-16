-- treesitter 语言清单（parser + highlights query 一起装）。
-- main 分支的安装器会把它们落到 stdpath("data")/site/（默认 install_dir，已在 runtimepath 内）。
local ts_langs = {
  -- NvChad 默认带这套
  "lua",
  "luadoc",
  "printf",
  "vim",
  "vimdoc",
  "query",
  -- 配置 / 文档 / 通用
  "markdown",
  "markdown_inline",
  "latex",
  "bibtex",
  "bash",
  "toml",
  "yaml",
  "json",
  "dockerfile",
  "gitcommit",
  "diff",
  "sql",
  "ini",
  "regex",
  "make",
  "cmake",
  -- Python（uv 虚拟环境主力语言）
  "python",
  -- 前端全栈
  "html",
  "css",
  "scss",
  "javascript",
  "typescript",
  "tsx",
  "vue",
  -- 后端
  "go",
  "rust",
}

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

  -- === Python（uv 虚拟环境） ===
  -- venv-selector：LSP 侧由 basedpyright 自动识别项目 .venv；这里补一个手动切换入口
  -- （支持 uv / .venv / poetry / conda 与 PEP-723 元数据；激活后同时设置 VIRTUAL_ENV）
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = "python",
    keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Python: select venv" } },
    opts = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
  },

  -- === LaTeX（论文） ===
  -- 分工：vimtex 管编译/预览/导航（mature，6361★，2026-09 仍活跃）；
  --       texlab（mason 装）管补全/诊断/悬停。零服务器端配置，PDF 用外部查看器。
  -- 查看器：macOS=Skim、Windows=SumatraPDF（都支持 SyncTeX 正反搜索）；Linux 只装基础，不作预览。
  {
    "lervag/vimtex",
    lazy = false, -- 官方 README 明确：VimTeX 不要 lazy-load
    init = function()
      if vim.fn.has "mac" == 1 then
        vim.g.vimtex_view_method = "skim"
        -- 用户态 TeX Live（~/.texlive/2026）不在默认 PATH；从 Finder 启动 nvim 时也要能找到 latexmk
        local tlbin = vim.fn.glob(vim.fn.expand "~/.texlive/*/bin/*-darwin", true)[1]
        if tlbin then
          vim.env.PATH = tlbin .. ":" .. vim.env.PATH
        end
      elseif vim.fn.has "win32" == 1 then
        vim.g.vimtex_view_method = "sumatrapdf"
      else
        vim.g.vimtex_view_method = "general"
      end
      vim.g.vimtex_compiler_method = "latexmk" -- 连续编译：\ll 后保存即刷新 PDF
      vim.g.vimtex_view_automatic = 1 -- 首次编译自动拉起查看器
      vim.g.vimtex_quickfix_mode = 0 -- 别每次保存都弹 quickfix
      vim.g.vimtex_imaps_enabled = 1 -- 数学模式简写（`a → \alpha 等）
      vim.g.vimtex_mappings_prefix = "<localleader>" -- 默认键仍保留在 \ll 等
    end,
    config = function()
      -- 给论文写作加一组好按的键（NvChad 的 leader = 空格）
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function(ev)
          local function map(lhs, cmd, desc)
            vim.keymap.set("n", lhs, cmd, { buffer = ev.buf, desc = desc })
          end
          map("<leader>ll", "<cmd>VimtexCompile<cr>", "LaTeX: 编译 / 连续编译开关")
          map("<leader>lk", "<cmd>VimtexStop<cr>", "LaTeX: 停止编译")
          map("<leader>lv", "<cmd>VimtexView<cr>", "LaTeX: 打开/定位 PDF（正反搜索）")
          map("<leader>le", "<cmd>VimtexErrors<cr>", "LaTeX: 错误列表")
          map("<leader>lt", "<cmd>VimtexTocOpen<cr>", "LaTeX: 章节大纲")
          map("<leader>lc", "<cmd>VimtexClean<cr>", "LaTeX: 清理辅助文件")
        end,
      })
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

  -- treesitter：⚠️ 上游默认分支已从 master 切到 main（重写版）——queries 从
  -- <插件>/queries/ 挪到 <插件>/runtime/queries/，parser+query 改由 install() 装进
  -- stdpath("data")/site/。starter 的 `build = ":TSUpdate | TSInstallAll"` 在 main 分支会漏装，
  -- 结果是绝大多数语言没有 highlights query（症状：连 Python 语法高亮都没有）。
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- 显式钉住：别再被上游默认分支变更带走一次
    lazy = false, -- main 分支不支持 lazy-load（作者 README 明确）
    build = ":TSUpdate",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, ts_langs)
    end,
    config = function()
      -- iqibdl 出网走公共 WiFi、直连 GitHub 不通：parser 源码拉不下来（安装器反而会把
      -- 同步进去的 site/queries 清掉）。所以这台机器不联网安装，直接消费
      -- 「从 hpcore 同步来的 site/parser/*.so」+「插件自带的 runtime/queries」。
      if vim.uv.os_gethostname() == "iqibdl" then
        local plugin = vim.fn.stdpath "data" .. "/lazy/nvim-treesitter"
        if vim.uv.fs_stat(plugin .. "/runtime/queries") then
          vim.opt.rtp:prepend(plugin .. "/runtime")
        end
        return
      end
      require("nvim-treesitter").install(ts_langs)
    end,
  },

  -- ============ Web 开发 ============

  -- mason 自身配置：沿用 NvChad 的（PATH=skip 等），并把 GitHub release 下载
  -- 统一改走自建 gh 代理（AGENTS 规则：GitHub 操作不直连；iqibdl 公共 WiFi 上直连必失败，
  -- 其它端走代理也更稳且不依赖 shell 里的 Clash 代理变量）
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("force", require "nvchad.configs.mason", opts or {})
      opts.github = opts.github or {}
      opts.github.download_url_template = "https://gh.zeroicey.me/https://github.com/%s/releases/download/%s/%s"
      return opts
    end,
  },

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
        -- Python（uv 项目）
        "basedpyright",
        "ruff",
        -- LaTeX
        "texlab",
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
