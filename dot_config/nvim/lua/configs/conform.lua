local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    go = { "gofmt" },
    -- Web 前端（prettierd 由 mason 安装）
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    vue = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    scss = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    -- LaTeX：texlab 自带格式化（vimtex 只管编译）
    tex = { "texlab" },
    -- Python：ruff 一肩挑（lint 修复 + import 排序 + 格式化），black/isort 不再需要
    python = { "ruff_fix", "ruff_format" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
