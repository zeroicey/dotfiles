require "nvchad.autocmds"

-- treesitter 高亮守卫。NvChad 的 FileType autocmd 会无条件 pcall(vim.treesitter.start)，
-- 而 Neovim 的 highlighter 一旦建成就把 b:syntax 置空（highlighter.lua: vim.bo[bufnr].syntax = ''）。
-- 如果这门语言没有 highlights query（parser 未装 / query 未装），结果就是「一点颜色都没有」
-- —— 这正是 Python 白字的成因。所以只在 query 真实存在时才让 ts 接管，
-- 否则停掉高亮器并把正则语法高亮接回来（兜底所有没装 parser 的 filetype）。
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf, ft = args.buf, vim.bo[args.buf].filetype
    if ft == "" then
      return
    end

    local lang = vim.treesitter.language.get_lang(ft) or ft
    local has_query = pcall(vim.treesitter.language.add, lang)
      and vim.treesitter.query.get(lang, "highlights") ~= nil

    if not has_query then
      pcall(vim.treesitter.stop, buf)
      pcall(vim.cmd, "syntax on")
      if vim.b[buf].current_syntax == nil then
        pcall(function()
          vim.bo[buf].syntax = ft
        end)
      end
    end
  end,
})

-- auto-open file tree when nvim is launched with a directory argument
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local args = vim.fn.argv()
    if #args > 0 and vim.fn.isdirectory(args[1]) == 1 then
      vim.schedule(function()
        require("nvim-tree.api").tree.open()
      end)
    end
  end,
})

-- auto-reload files changed on disk (e.g. by external AI tools)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    pcall(vim.cmd.checktime)
  end,
})

local check_timer = vim.uv.new_timer()
check_timer:start(1000, 1500, vim.schedule_wrap(function()
  pcall(vim.cmd.checktime)
end))
