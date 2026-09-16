require "nvchad.autocmds"

-- treesitter 高亮守卫。NvChad 的 FileType autocmd 会无条件 pcall(vim.treesitter.start)，
-- 而 Neovim 的 highlighter 一旦建成就把 b:syntax 置空（highlighter.lua: vim.bo[bufnr].syntax = ''）。
-- 如果这门语言没有 highlights query（parser 未装 / query 未装），结果就是「一点颜色都没有」
-- —— 这正是 Python 白字的成因。所以只在 query 真实存在时才让 ts 接管，
-- 否则停掉高亮器并把正则语法高亮接回来（兜底所有没装 parser 的 filetype）。
local function ts_or_syntax(buf)
  local ft = vim.bo[buf].filetype
  if ft == "" then
    return
  end

  local lang = vim.treesitter.language.get_lang(ft) or ft
  local has_query = pcall(vim.treesitter.language.add, lang)
    and vim.treesitter.query.get(lang, "highlights") ~= nil

  if has_query then
    -- 已存在的高亮器可能是「空 query」那个（NvChad 无条件 start 的结果），重建一次
    pcall(vim.treesitter.stop, buf)
    pcall(vim.treesitter.start, buf, lang)
  else
    pcall(vim.treesitter.stop, buf)
    pcall(vim.cmd, "syntax on")
    if vim.b[buf].current_syntax == nil then
      pcall(function()
        vim.bo[buf].syntax = ft
      end)
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    ts_or_syntax(args.buf)
  end,
})

-- 启动时打开的文件，其 FileType 早于 lazy 载入插件/rtp；NvChad 在 VimEnter 后发 User FilePost，
-- 在这里再兜一次（此时 queries 已在 runtimepath 里）
vim.api.nvim_create_autocmd("User", {
  pattern = "FilePost",
  callback = function()
    ts_or_syntax(vim.api.nvim_get_current_buf())
  end,
})
