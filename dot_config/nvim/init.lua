-- ============================================================================
--  nvim 单文件配置 · 纯原生（无插件）
--  hpcore · Neovim v0.12.6 · 2026-10-19 从零重写
--
--  定位：AI 时代以「阅读 + 少量编辑」为主。
--  选项基线 = 社区推荐 + dotfiles 里 NvChad 之前那版（commit b84c985）
--  键位   = 同一版（去掉依赖插件的部分）
-- ============================================================================

-- ---------------------------------------------------------------------------
--  0. 前置
-- ---------------------------------------------------------------------------

-- leader 必须先设，否则任何 <leader> 都落到默认的 "\"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 关掉内置 provider 的自动探测：本机没有 python3/node 宿主，
-- 探测会在启动时白跑一次并留告警。日后要装插件宿主再开。
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 注：netrw 保留（不设 loaded_netrw）。以前关它是因为有 neo-tree，
-- 现在零插件，:Ex / :Explore 就是唯一的目录浏览器。


local o = vim.opt

-- ---------------------------------------------------------------------------
--  1. 备份 / 交换 / 撤销
-- ---------------------------------------------------------------------------

-- 不生成 ~ 结尾的备份文件（主力是 git，备份只会制造同名垃圾文件）
o.backup = false
o.writebackup = false

-- 不生成 .swp 交换文件。代价：崩溃/断电会丢未保存内容；
-- 收益：目录里不再出现 .file.swp，也不会被「交换文件已存在」拦住。
o.swapfile = false

-- 撤销历史持久化：退出重开仍能 u 回去（swapfile 关掉后的主要兜底）
o.undofile = true
o.undolevels = 1000
local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
o.undodir = undodir


-- ---------------------------------------------------------------------------
--  2. 缩进：默认值
-- ---------------------------------------------------------------------------
--
--  这里只放「兜底默认」。真正的分语言策略在 §11 的一张表里。

o.expandtab = true
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4
o.autoindent = true
o.smartindent = true

-- 注释续行时自动加 // 或 #；"j" 让 join 时不留双空格
o.formatoptions = "tcqj"


-- ---------------------------------------------------------------------------
--  3. 搜索
-- ---------------------------------------------------------------------------

o.ignorecase = true   -- 搜索默认不区分大小写……
o.smartcase = true    -- ……但输入里出现大写字母时自动区分
o.incsearch = true    -- 边打字边跳转
o.hlsearch = true     -- 高亮所有匹配
o.inccommand = "split" -- :s 替换实时预览（原生能力，替代一部分插件体验）


-- ---------------------------------------------------------------------------
--  4. 行号与光标
-- ---------------------------------------------------------------------------

o.number = true
o.relativenumber = true
o.numberwidth = 4

-- 高亮光标行，但只亮行号列（不全行铺底色，阅读时不刺眼）
o.cursorline = true
o.cursorlineopt = "number"

-- 符号列常驻：诊断/标记出现时正文不会左右跳（旧配置的选择）
o.signcolumn = "yes"

-- 光标形状：所有模式都用方块。默认的 insert 是细竖线（ver25），在终端里
-- 隔着 ssh 看很弱，且插字符时看不准位置。t: 那段保持不动（终端缓冲区专用）。
o.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block,t:block-blinkon500-blinkoff500-TermCursor"


-- ---------------------------------------------------------------------------
--  5. 阅读体验（滚动 / 折行）
-- ---------------------------------------------------------------------------

o.scrolloff = 5      -- 光标距上下边缘保留 5 行（沿用旧配置）
o.sidescrolloff = 8  -- 左右滚动同样留白

o.wrap = true        -- 长行折行显示
o.linebreak = true   -- 折行发生在单词边界，不切断单词
o.breakindent = true -- 折行后保持缩进层级，读嵌套代码/缩进列表不糊

-- 超过 500 列的语法高亮不做：超大单行文件（压缩过的 js/json）不会卡死
o.synmaxcol = 500


-- ---------------------------------------------------------------------------
--  6. 界面
-- ---------------------------------------------------------------------------

o.termguicolors = true  -- 终端 24 位真彩色
o.background = "dark"   -- 明暗两版主题都取暗色

-- 全局状态栏：0=永不 1=仅分屏 2=始终 3=全局单条
o.laststatus = 3
o.cmdheight = 1         -- 命令区 1 行，给正文留空间
o.ruler = true          -- 右下角显示光标位置
o.showmode = false      -- 不显示 -- INSERT --（状态栏已能看出来）

-- 浮动窗口（LSP 悬停、补全文档、诊断详情）加圆角边框
o.winborder = "rounded"

-- 填充字符：表形式更可读（0.12 接受）
o.fillchars = {
  eob = " ",      -- 文件末尾以下不留 ~ 噪音
  fold = " ",
  foldsep = " ",
  diff = "╱",
  horiz = "─",
  vert = "│",
  msgsep = "‾",
}

o.mouse = "a"           -- 鼠标全模式（阅读时滚轮、点击定位）
o.updatetime = 250      -- 触发 CursorHold 的间隔，短一点诊断更跟手
o.timeoutlen = 500      -- 键序列等待时间
o.ttimeoutlen = 10      -- ESC 与后续字节的合并窗口，越小 ESC 越跟手

-- ⚠️ 给后来的人（实测，真 pty，2026-10-19）：ttimeoutlen 直接等于「ESC 后允许多大间隔
--     才认作一个组合键」。实测间隔 5ms 时 >=10 够用，间隔 50ms 需 >=50，120ms 需 >=200。
--     所以以后要加 Alt/Meta 系映射（终端把它编成 ESC+字符），一旦这个值小于链路把两者
--     拆开发送的间隔，映射会静默失效（不报错、就是不触发）。现在没有 Alt 映射，取 10。
o.pumheight = 12        -- 补全菜单最多 12 行，不遮挡正文


-- ---------------------------------------------------------------------------
--  7. 窗口与分屏
-- ---------------------------------------------------------------------------

o.splitright = true  -- 新分屏出现在右侧
o.splitbelow = true  -- 新分屏出现在下方
o.hidden = true      -- 允许切走未保存的缓冲区（内容不丢，只是隐藏）
o.confirm = true     -- :q 有未保存改动时弹确认，而不是直接报错


-- ---------------------------------------------------------------------------
--  8. 文件、编码、外部改动
-- ---------------------------------------------------------------------------

o.fileencoding = "utf-8"
o.autoread = true    -- 文件被外部修改时自动重读

-- 关闭项目级配置（.nvim.lua / .exrc）自动加载，避免打开陌生仓库时执行代码
o.exrc = false
o.secure = true

-- shell：zsh 优先，没有就 bash，再没有就 sh
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  o.shell = "cmd"
elseif vim.fn.executable("zsh") == 1 then
  o.shell = "zsh"
elseif vim.fn.executable("bash") == 1 then
  o.shell = "bash"
else
  o.shell = "sh"
end


-- ---------------------------------------------------------------------------
--  9. 提示音
-- ---------------------------------------------------------------------------

o.errorbells = false
o.belloff = "all"


-- ---------------------------------------------------------------------------
-- 10. 剪贴板（headless 专用）
-- ---------------------------------------------------------------------------
--
-- 背景：hpcore 没有 pbcopy/xclip/wl-copy，默认 clipboard provider 为空，
-- 一设 clipboard=unnamedplus 每次 y 都报 "clipboard: No provider"。
--
-- 实测（2026-10-13，ssh -> herdr -> Ghostty）：
--   · 写方向（yank 送到终端剪贴板）走 OSC 52 通
--   · 读方向（"+p 从终端取回）不通 —— 原生实现会阻塞 10 秒再粘出陈旧值
-- 所以这里只接管「写」，粘贴走终端自己的 Cmd+V / Ctrl+Shift+V。
--
-- 有本地剪贴板工具的机器（或 tmux 内）自动跳过，交给 Nvim 自己的探测。
--
-- ⚠️ 下面这张检测表必须与 Nvim 自带的探测顺序**对齐**（见
--    `runtime/autoload/provider/clipboard.vim` 第 236–260 行）：只要 Nvim 自己能找到某一个
--    provider，我们就不能拿 OSC 52 去覆盖它。漏一项 = 那类平台上剪贴板反而变坏。
--    （0.12.6 实测顺序：mac → wl-copy → waycopy → xsel → xclip → lemonade → doitclient
--      → win32yank.exe → putclip+getclip → **clip+powershell（Windows 靠这个）** → termux → tmux → osc52）
local has_local_clipboard =
     vim.fn.has("mac") == 1
  or ((vim.env.WAYLAND_DISPLAY or "") ~= "" and vim.fn.executable("wl-copy") == 1)
  or ((vim.env.DISPLAY or "") ~= "" and (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1))
  or vim.fn.executable("lemonade") == 1
  or vim.fn.executable("doitclient") == 1
  or vim.fn.executable("win32yank.exe") == 1
  or (vim.fn.executable("putclip") == 1 and vim.fn.executable("getclip") == 1)
  or (vim.fn.executable("clip") == 1 and vim.fn.executable("powershell") == 1)
  or vim.fn.executable("termux-clipboard-set") == 1
  or ((vim.env.TMUX or "") ~= "" and vim.fn.executable("tmux") == 1)

if not has_local_clipboard then
  -- 记录本会话最后一次 yank/delete/change，供 p 使用
  local last = { {}, "v" }
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      local ev = vim.v.event
      if type(ev.regcontents) == "table" and #ev.regcontents > 0 then
        last = { ev.regcontents, (ev.regtype ~= "" and ev.regtype) or "v" }
      end
    end,
  })

  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52 (copy) + local paste",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = {
      ["+"] = function() return { last[1], last[2] } end,
      ["*"] = function() return { last[1], last[2] } end,
    },
  }
end

-- ⚠️ `unnamedplus` 必须**无条件**设，与上面有没有装 OSC 52 无关：
--   · 有本地 provider（mac / Windows 的 clip+powershell / tmux …）⇒ 交给 Nvim 自己的 provider
--   · 没有（hpcore 这种 headless）⇒ 交给上面那段 OSC 52
-- 早先把它写在 `if not has_local_clipboard` 里面，后果是 **mac/Windows 上 y 根本不到系统剪贴板**
-- （2026-10-19 多端同步时在 hpstation 上验收才抓到：`clipboard(opt)` 为空）。
o.clipboard = "unnamedplus"


-- ---------------------------------------------------------------------------
-- 11. 分语言缩进 —— 统一在这一张表里改
-- ---------------------------------------------------------------------------
--
--  sw = shiftwidth（一次缩进的空格数）
--  ts = tabstop（一个真实 Tab 的显示宽度）
--  et = expandtab（true = 用空格；false = 用真 Tab）
--
--  默认（不在下表里的语言）：sw=4 ts=4 空格。
--
--  ⚠️ Go 必须 et=false —— gofmt 输出真 Tab，用空格会被 gofmt 反复改回来。
--  ⚠️ Makefile 必须 et=false —— recipe 行只认真 Tab，空格会直接报错。

local indent_default = { sw = 4, ts = 4, et = true }

local indent_by_ft = {
  -- ── 2 空格：web 前端 + 配置/脚本（prettier / 社区惯例）───────────────
  html = { sw = 2, ts = 2, et = true },
  css = { sw = 2, ts = 2, et = true },
  scss = { sw = 2, ts = 2, et = true },
  less = { sw = 2, ts = 2, et = true },
  javascript = { sw = 2, ts = 2, et = true },
  javascriptreact = { sw = 2, ts = 2, et = true },
  typescript = { sw = 2, ts = 2, et = true },
  typescriptreact = { sw = 2, ts = 2, et = true },
  vue = { sw = 2, ts = 2, et = true },
  svelte = { sw = 2, ts = 2, et = true },
  astro = { sw = 2, ts = 2, et = true },
  json = { sw = 2, ts = 2, et = true },
  jsonc = { sw = 2, ts = 2, et = true },
  yaml = { sw = 2, ts = 2, et = true },
  toml = { sw = 2, ts = 2, et = true },
  lua = { sw = 2, ts = 2, et = true },   -- lua 社区（stylua）惯例是 2
  vim = { sw = 2, ts = 2, et = true },
  sh = { sw = 2, ts = 2, et = true },
  bash = { sw = 2, ts = 2, et = true },
  zsh = { sw = 2, ts = 2, et = true },
  markdown = { sw = 2, ts = 2, et = true },

  -- ── 4 空格：系统语言 + 后端（各自社区惯例）─────────────────────────
  c = { sw = 4, ts = 4, et = true },
  cpp = { sw = 4, ts = 4, et = true },
  java = { sw = 4, ts = 4, et = true },
  kotlin = { sw = 4, ts = 4, et = true },
  scala = { sw = 4, ts = 4, et = true },
  csharp = { sw = 4, ts = 4, et = true },
  python = { sw = 4, ts = 4, et = true },
  rust = { sw = 4, ts = 4, et = true },  -- rustfmt 标准
  php = { sw = 4, ts = 4, et = true },
  swift = { sw = 4, ts = 4, et = true },

  -- ── 真 Tab：这两个语言的格式器只认真 Tab ────────────────────────────
  go = { sw = 4, ts = 4, et = false },      -- gofmt
  gomod = { sw = 4, ts = 4, et = false },
  make = { sw = 4, ts = 4, et = false },    -- Makefile recipe
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local s = indent_by_ft[vim.bo[args.buf].filetype] or indent_default
    vim.opt_local.shiftwidth = s.sw
    vim.opt_local.tabstop = s.ts
    vim.opt_local.softtabstop = s.et and s.sw or 0
    vim.opt_local.expandtab = s.et
  end,
})


-- ---------------------------------------------------------------------------
-- 12. 自动命令
-- ---------------------------------------------------------------------------

-- 文件被外部改动（git checkout / 另一个进程写入）时自动重读。
-- 只在这几个事件上检查，避免 CursorHold 频繁 stat 拖慢大项目。
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "CursorHold", "FocusGained" }, {
  callback = function()
    if vim.bo.modified then
      return
    end
    vim.cmd("checktime")
  end,
})

-- 重进 nvim 时恢复上次的光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


-- ---------------------------------------------------------------------------
-- 13. 键位
-- ---------------------------------------------------------------------------
--
-- 全部来自 dotfiles commit b84c985（NvChad 之前那版），去掉依赖插件的部分。
-- 依赖插件、本次未移植的：<A-e> 文件树、Neotree 相关全部、telescope 相关。

local map = function(mode, lhs, rhs, opts)
  local options = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, options)
end

-- ── 13.1 基础 ────────────────────────────────────────────────────────────
map("n", "<Space>", "", { desc = "No-op (leader key)" })
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("n", ";", ":", { desc = "Open the command" })

-- ── 13.2 移动与编辑 ──────────────────────────────────────────────────────
map("n", "J", "5j", { desc = "Move Down 5 Lines" })
map("n", "K", "5k", { desc = "Move Up 5 Lines" })
map("n", "H", "^", { desc = "Go to First Character of Line" })
map("n", "L", "$", { desc = "Go to End of Line" })

map("v", "J", "5j", { desc = "Extend Selection Down 5 Lines" })
map("v", "K", "5k", { desc = "Extend Selection Up 5 Lines" })
map("v", "H", "^", { desc = "Extend Selection to First Character" })
map("v", "L", "g_", { desc = "Extend Selection to End of Line" })

map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })

-- 粘贴后自动重排缩进。
-- 原版优先走 conform 格式化、失败才回落 normal! ==；
-- 这里只保留纯原生的回落逻辑（零插件）。
local function paste_then_fix(cmd)
  local count = vim.v.count > 0 and tostring(vim.v.count) or ""
  local reg = vim.v.register
  local keys = (reg and reg ~= "" and reg ~= '"') and (count .. '"' .. reg .. cmd) or (count .. cmd)
  vim.cmd.normal({ bang = true, args = { keys } })

  local s = vim.api.nvim_buf_get_mark(0, "[")
  local e = vim.api.nvim_buf_get_mark(0, "]")
  if s[1] == 0 or e[1] == 0 then
    return
  end
  if vim.bo.readonly or not vim.bo.modifiable then
    return
  end

  local view = vim.fn.winsaveview()
  pcall(vim.cmd, "silent! undojoin")
  pcall(vim.cmd, string.format("silent keepjumps %d,%dnormal! ==", s[1], e[1]))
  vim.fn.winrestview(view)
end

map("n", "p", function() paste_then_fix("p") end, { desc = "Paste After and Fix Indent" })
map("n", "P", function() paste_then_fix("P") end, { desc = "Paste Before and Fix Indent" })
map("n", "gp", function() paste_then_fix("gp") end, { desc = "Paste After, Cursor After, Fix Indent" })
map("n", "gP", function() paste_then_fix("gP") end, { desc = "Paste Before, Cursor After, Fix Indent" })

-- ── 13.3 文件与缓冲区 ────────────────────────────────────────────────────
map("n", ",q", ":q<CR>", { desc = "Quit" })
map("n", ",w", ":w<CR>", { desc = "Write (Save)" })
map("n", "<leader>r", ":update<CR>:source<CR>", { desc = "Save and Reload Config" })

-- 关当前缓冲区：有未保存改动就拒绝；关掉后切到下一个缓冲区
map("n", "<leader>bd", function()
  local bufnr = vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("Buffer has unsaved changes. Save it before closing.", vim.log.levels.WARN)
    return
  end

  local listed = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  local current_index
  for index, buf in ipairs(listed) do
    if buf == bufnr then
      current_index = index
      break
    end
  end

  if #listed > 1 and current_index then
    vim.api.nvim_set_current_buf(listed[current_index % #listed + 1])
  end

  local ok, err = pcall(vim.cmd.bdelete, bufnr)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
  end
end, { desc = "Close Current Buffer" })

-- 格式化：有 LSP 就走 LSP，没有就整篇重排缩进（零插件兜底）
map("n", ",f", function()
  if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
    vim.lsp.buf.format({ async = true })
  else
    local view = vim.fn.winsaveview()
    pcall(vim.cmd, "silent keepjumps normal! gg=G")
    vim.fn.winrestview(view)
  end
end, { desc = "Format File" })

-- ── 13.4 搜索与跳转 ──────────────────────────────────────────────────────
map("n", "gb", "<C-o>", { desc = "Go Back" })
-- 注：旧配置把 f 映射成了 /，那会废掉原生行内跳字符（f/t/;/,）。
-- 2026-10-19 按用户裁决去掉，f 交还原生；搜索用 / 或 ? 本身。

-- ── 13.5 窗口 ────────────────────────────────────────────────────────────
map("n", "<leader>h", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<leader>j", "<C-w>j", { desc = "Go to Down Window" })
map("n", "<leader>k", "<C-w>k", { desc = "Go to Up Window" })
map("n", "<leader>l", "<C-w>l", { desc = "Go to Right Window" })

map("n", "<leader>\\", "<C-w>v", { desc = "Split Window Vertically" })
map("n", "<leader>-", "<C-w>s", { desc = "Split Window Horizontally" })
map("n", "<leader>o", ":only<CR>", { desc = "Keep Only Current Window" })

map("n", "=", "<cmd>vertical resize +5<cr>", { desc = "Increase Window Width" })
map("n", "-", "<cmd>vertical resize -5<cr>", { desc = "Decrease Window Width" })
map("n", "+", "<cmd>horizontal resize +2<cr>", { desc = "Increase Window Height" })
map("n", "_", "<cmd>horizontal resize -2<cr>", { desc = "Decrease Window Height" })

-- ---------------------------------------------------------------------------
-- 14. 主题：Catppuccin（机械移植自官方 catppuccin/nvim，仅非插件组）
-- ---------------------------------------------------------------------------
--
-- 来源：catppuccin/nvim 的 groups/{editor,syntax,treesitter,lsp,semantic_tokens}.lua
-- 方法：把官方 group 文件喂桩执行，拿到它算出的真实颜色，再反解回符号表达式；
--       生成的表达式已逐个 flavour 比对过，与官方输出逐位一致。
--       blend() 的取整方式与官方 utils/colors.lua 相同（floor(x + 0.5)）。
-- 未移植：groups/integrations/ 下 69 个插件整合（telescope / neotree / which-key …）
--         —— 那些组只对插件生效，本配置零插件，移植进来是死内容。
--
-- 换 flavour 只改下面这一行： latte（浅色）| frappe | macchiato | mocha

local flavour = "mocha"

-- 官方调色板：catppuccin/palette 的 palette.json，26 色 × 4 flavour
local palettes = {
  latte = {
    rosewater = "#dc8a78", flamingo = "#dd7878", pink = "#ea76cb", mauve = "#8839ef", red = "#d20f39",
    maroon = "#e64553", peach = "#fe640b", yellow = "#df8e1d", green = "#40a02b", teal = "#179299",
    sky = "#04a5e5", sapphire = "#209fb5", blue = "#1e66f5", lavender = "#7287fd", text = "#4c4f69",
    subtext1 = "#5c5f77", subtext0 = "#6c6f85", overlay2 = "#7c7f93", overlay1 = "#8c8fa1", overlay0 = "#9ca0b0",
    surface2 = "#acb0be", surface1 = "#bcc0cc", surface0 = "#ccd0da", base = "#eff1f5", mantle = "#e6e9ef",
    crust = "#dce0e8",
  },
  frappe = {
    rosewater = "#f2d5cf", flamingo = "#eebebe", pink = "#f4b8e4", mauve = "#ca9ee6", red = "#e78284",
    maroon = "#ea999c", peach = "#ef9f76", yellow = "#e5c890", green = "#a6d189", teal = "#81c8be",
    sky = "#99d1db", sapphire = "#85c1dc", blue = "#8caaee", lavender = "#babbf1", text = "#c6d0f5",
    subtext1 = "#b5bfe2", subtext0 = "#a5adce", overlay2 = "#949cbb", overlay1 = "#838ba7", overlay0 = "#737994",
    surface2 = "#626880", surface1 = "#51576d", surface0 = "#414559", base = "#303446", mantle = "#292c3c",
    crust = "#232634",
  },
  macchiato = {
    rosewater = "#f4dbd6", flamingo = "#f0c6c6", pink = "#f5bde6", mauve = "#c6a0f6", red = "#ed8796",
    maroon = "#ee99a0", peach = "#f5a97f", yellow = "#eed49f", green = "#a6da95", teal = "#8bd5ca",
    sky = "#91d7e3", sapphire = "#7dc4e4", blue = "#8aadf4", lavender = "#b7bdf8", text = "#cad3f5",
    subtext1 = "#b8c0e0", subtext0 = "#a5adcb", overlay2 = "#939ab7", overlay1 = "#8087a2", overlay0 = "#6e738d",
    surface2 = "#5b6078", surface1 = "#494d64", surface0 = "#363a4f", base = "#24273a", mantle = "#1e2030",
    crust = "#181926",
  },
  mocha = {
    rosewater = "#f5e0dc", flamingo = "#f2cdcd", pink = "#f5c2e7", mauve = "#cba6f7", red = "#f38ba8",
    maroon = "#eba0ac", peach = "#fab387", yellow = "#f9e2af", green = "#a6e3a1", teal = "#94e2d5",
    sky = "#89dceb", sapphire = "#74c7ec", blue = "#89b4fa", lavender = "#b4befe", text = "#cdd6f4",
    subtext1 = "#bac2de", subtext0 = "#a6adc8", overlay2 = "#9399b2", overlay1 = "#7f849c", overlay0 = "#6c7086",
    surface2 = "#585b70", surface1 = "#45475a", surface0 = "#313244", base = "#1e1e2e", mantle = "#181825",
    crust = "#11111b",
  },
}

local P = assert(palettes[flavour], "未知 flavour: " .. tostring(flavour))
local is_light = (flavour == "latte")

-- 与官方 blend() 逐位一致：alpha=0 得 bg，alpha=1 得 fg
local function blend(fg, bg, alpha)
  local t = { fg:sub(2), bg:sub(2) }
  local f, b = {}, {}
  for i = 1, 2 do
    local o = (i == 1) and f or b
    o[1] = tonumber(t[i]:sub(1, 2), 16)
    o[2] = tonumber(t[i]:sub(3, 4), 16)
    o[3] = tonumber(t[i]:sub(5, 6), 16)
  end
  local function ch(i)
    return math.floor(math.min(math.max(0, alpha * f[i] + (1 - alpha) * b[i]), 255) + 0.5)
  end
  return string.format("#%02X%02X%02X", ch(1), ch(2), ch(3))
end

-- shade(name, a)：调色板颜色按 a 混向 base（等价官方的 darken(X, a, base)）
local function shade(name, amount) return blend(P[name], P.base, math.abs(amount)) end
-- pick(浅色值, 深色值)：仅 latte 取前者（等价官方的 vary_color）
local function pick(latte_value, dark_value) return is_light and latte_value or dark_value end

-- 高亮组。字段：fg / bg / sp / link / 样式开关（bold, italic, underline, undercurl,
-- strikethrough）/ blend（浮窗透明混合度）。
local groups = {
  -- ── editor ──
  ColorColumn = { bg = P.surface0 },
  Conceal = { fg = P.overlay1 },
  Cursor = { fg = P.base, bg = P.rosewater },
  lCursor = { fg = P.base, bg = P.rosewater },
  CursorIM = { fg = P.base, bg = P.rosewater },
  CursorColumn = { bg = P.mantle },
  CursorLine = { bg = pick(shade("mantle", 0.7), shade("surface0", 0.64)) },
  Dimmed = { fg = P.overlay1 },
  Directory = { fg = P.blue },
  EndOfBuffer = { fg = P.surface1 },
  ErrorMsg = { fg = P.red, bold = true, italic = true },
  VertSplit = { fg = P.crust },
  Folded = { fg = P.blue, bg = P.surface1 },
  FoldColumn = { fg = P.overlay0 },
  SignColumn = { fg = P.surface1 },
  SignColumnSB = { fg = P.surface1, bg = P.crust },
  Substitute = { fg = pick(P.red, P.pink), bg = P.surface1 },
  LineNr = { fg = P.surface1 },
  CursorLineNr = { fg = P.lavender },
  MatchParen = { fg = P.peach, bg = shade("surface1", 0.7), bold = true },
  ModeMsg = { fg = P.text, bold = true },
  MsgSeparator = { link = "WinSeparator" },
  MoreMsg = { fg = P.blue },
  NonText = { fg = P.overlay0 },
  Normal = { fg = P.text, bg = P.base },
  NormalNC = { fg = P.text, bg = P.base },
  NormalSB = { fg = P.text, bg = P.crust },
  NormalFloat = { fg = P.text, bg = P.mantle },
  FloatShadow = { bg = P.overlay0, blend = 80 },
  FloatShadowThrough = { bg = P.overlay0, blend = 100 },
  OkMsg = { fg = P.green },
  Pmenu = { fg = P.overlay2, bg = P.mantle },
  PmenuBorder = { fg = P.blue, bg = P.mantle },
  PmenuSel = { bg = P.surface0, bold = true },
  PmenuMatch = { fg = P.text, bold = true },
  PmenuMatchSel = { bold = true },
  PmenuSbar = { bg = P.surface0 },
  PmenuThumb = { bg = P.overlay0 },
  PmenuKind = { fg = P.blue, bg = P.mantle },
  PmenuKindSel = { fg = P.blue, bg = P.surface0, bold = true },
  PmenuExtra = { fg = P.overlay0 },
  PmenuExtraSel = { fg = P.overlay0, bg = P.surface0, bold = true },
  ComplMatchIns = { link = "PreInsert" },
  PreInsert = { fg = P.overlay2 },
  ComplHint = { fg = P.subtext0 },
  ComplHintMore = { link = "Question" },
  Question = { fg = P.blue },
  QuickFixLine = { bg = shade("surface1", 0.7), bold = true },
  Search = { fg = P.text, bg = shade("sky", 0.3) },
  IncSearch = { fg = P.mantle, bg = shade("sky", 0.9) },
  CurSearch = { fg = P.mantle, bg = P.red },
  SpecialKey = { link = "NonText" },
  SpellBad = { sp = P.red, undercurl = true },
  SpellCap = { sp = P.yellow, undercurl = true },
  SpellLocal = { sp = P.blue, undercurl = true },
  SpellRare = { sp = P.green, undercurl = true },
  StatusLine = { fg = P.text, bg = P.mantle },
  StatusLineNC = { fg = P.surface1, bg = P.mantle },
  TabLine = { fg = P.overlay0, bg = P.crust },
  TabLineFill = { bg = P.mantle },
  TabLineSel = { link = "Normal" },
  TermCursor = { fg = P.base, bg = P.rosewater },
  TermCursorNC = { fg = P.base, bg = P.overlay2 },
  Title = { fg = P.blue, bold = true },
  Visual = { bg = P.surface1, bold = true },
  VisualNOS = { bg = P.surface1, bold = true },
  WarningMsg = { fg = P.yellow },
  Whitespace = { fg = P.surface1 },
  WildMenu = { bg = P.overlay0 },
  WinBar = { fg = P.rosewater },
  WinBarNC = { link = "WinBar" },
  WinSeparator = { fg = P.crust },
  -- ── syntax ──
  Comment = { fg = P.overlay2, italic = true },
  SpecialComment = { link = "Special" },
  Constant = { fg = P.peach },
  String = { fg = P.green },
  Character = { fg = P.teal },
  Number = { fg = P.peach },
  Float = { link = "Number" },
  Boolean = { fg = P.peach },
  Identifier = { fg = P.flamingo },
  Function = { fg = P.blue },
  Statement = { fg = P.mauve },
  Conditional = { fg = P.mauve, italic = true },
  Repeat = { fg = P.mauve },
  Label = { fg = P.sapphire },
  Operator = { fg = P.sky },
  Keyword = { fg = P.mauve },
  Exception = { fg = P.mauve },
  PreProc = { fg = P.pink },
  Include = { fg = P.mauve },
  Define = { link = "PreProc" },
  Macro = { fg = P.mauve },
  PreCondit = { link = "PreProc" },
  StorageClass = { fg = P.yellow },
  Structure = { fg = P.yellow },
  Special = { fg = P.pink },
  Type = { fg = P.yellow },
  Typedef = { link = "Type" },
  SpecialChar = { link = "Special" },
  Tag = { fg = P.lavender, bold = true },
  Delimiter = { fg = P.overlay2 },
  Debug = { link = "Special" },
  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Error = { fg = P.red },
  Todo = { fg = P.base, bg = P.flamingo, bold = true },
  qfLineNr = { fg = P.yellow },
  qfFileName = { fg = P.blue },
  htmlH1 = { fg = P.pink, bold = true },
  htmlH2 = { fg = P.blue, bold = true },
  mkdCodeDelimiter = { fg = P.text, bg = P.base },
  mkdCodeStart = { fg = P.flamingo, bold = true },
  mkdCodeEnd = { fg = P.flamingo, bold = true },
  debugPC = { bg = P.crust },
  debugBreakpoint = { fg = P.overlay0, bg = P.base },
  illuminatedWord = { bg = P.surface1 },
  illuminatedCurWord = { bg = P.surface1 },
  Added = { fg = P.green },
  Changed = { fg = P.blue },
  diffAdded = { fg = P.green },
  diffRemoved = { fg = P.red },
  diffChanged = { fg = P.blue },
  diffOldFile = { fg = P.yellow },
  diffNewFile = { fg = P.peach },
  diffFile = { fg = P.blue },
  diffLine = { fg = P.overlay0 },
  diffIndexLine = { fg = P.teal },
  DiffAdd = { bg = shade("green", 0.18) },
  DiffChange = { bg = shade("blue", 0.07) },
  DiffDelete = { bg = shade("red", 0.18) },
  DiffText = { bg = shade("blue", 0.3) },
  healthError = { fg = P.red },
  healthSuccess = { fg = P.teal },
  healthWarning = { fg = P.yellow },
  GlyphPalette1 = { fg = P.red },
  GlyphPalette2 = { fg = P.teal },
  GlyphPalette3 = { fg = P.yellow },
  GlyphPalette4 = { fg = P.blue },
  GlyphPalette6 = { fg = P.teal },
  GlyphPalette7 = { fg = P.text },
  GlyphPalette9 = { fg = P.red },
  rainbow1 = { fg = P.red },
  rainbow2 = { fg = P.peach },
  rainbow3 = { fg = P.yellow },
  rainbow4 = { fg = P.green },
  rainbow5 = { fg = P.sapphire },
  rainbow6 = { fg = P.lavender },
  csvCol0 = { fg = P.red },
  csvCol1 = { fg = P.peach },
  csvCol2 = { fg = P.yellow },
  csvCol3 = { fg = P.green },
  csvCol4 = { fg = P.sky },
  csvCol5 = { fg = P.blue },
  csvCol6 = { fg = P.lavender },
  csvCol7 = { fg = P.mauve },
  csvCol8 = { fg = P.pink },
  escCsvCol0 = { link = "csvCol0" },
  markdownHeadingDelimiter = { fg = P.peach, bold = true },
  markdownCode = { fg = P.flamingo },
  markdownCodeBlock = { fg = P.flamingo },
  markdownLinkText = { fg = P.blue, underline = true },
  markdownH1 = { link = "rainbow1" },
  markdownH2 = { link = "rainbow2" },
  markdownH3 = { link = "rainbow3" },
  markdownH4 = { link = "rainbow4" },
  markdownH5 = { link = "rainbow5" },
  markdownH6 = { link = "rainbow6" },
  -- ── treesitter ──
  gitcommitSummary = { fg = P.rosewater, italic = true },
  zshKSHFunction = { link = "Function" },
  -- ── lsp ──
  LspReferenceText = { bg = P.surface1 },
  LspReferenceRead = { bg = P.surface1 },
  LspReferenceWrite = { bg = P.surface1 },
  DiagnosticVirtualTextError = { fg = P.red, bg = shade("red", 0.095), italic = true },
  DiagnosticVirtualTextWarn = { fg = P.yellow, bg = shade("yellow", 0.095), italic = true },
  DiagnosticVirtualTextInfo = { fg = P.sky, bg = shade("sky", 0.095), italic = true },
  DiagnosticVirtualTextHint = { fg = P.teal, bg = shade("teal", 0.095), italic = true },
  DiagnosticVirtualTextOk = { fg = P.green, bg = shade("teal", 0.095), italic = true },
  DiagnosticError = { fg = P.red, bg = "NONE", italic = true },
  DiagnosticWarn = { fg = P.yellow, bg = "NONE", italic = true },
  DiagnosticInfo = { fg = P.sky, bg = "NONE", italic = true },
  DiagnosticHint = { fg = P.teal, bg = "NONE", italic = true },
  DiagnosticOk = { fg = P.green, bg = "NONE", italic = true },
  DiagnosticUnderlineError = { sp = P.red, underline = true },
  DiagnosticUnderlineWarn = { sp = P.yellow, underline = true },
  DiagnosticUnderlineInfo = { sp = P.sky, underline = true },
  DiagnosticUnderlineHint = { sp = P.teal, underline = true },
  DiagnosticUnderlineOk = { sp = P.green, underline = true },
  DiagnosticFloatingError = { fg = P.red },
  DiagnosticFloatingWarn = { fg = P.yellow },
  DiagnosticFloatingInfo = { fg = P.sky },
  DiagnosticFloatingHint = { fg = P.teal },
  DiagnosticFloatingOk = { fg = P.green },
  DiagnosticSignError = { fg = P.red },
  DiagnosticSignWarn = { fg = P.yellow },
  DiagnosticSignInfo = { fg = P.sky },
  DiagnosticSignHint = { fg = P.teal },
  DiagnosticSignOk = { fg = P.green },
  LspDiagnosticsDefaultError = { fg = P.red },
  LspDiagnosticsDefaultWarning = { fg = P.yellow },
  LspDiagnosticsDefaultInformation = { fg = P.sky },
  LspDiagnosticsDefaultHint = { fg = P.teal },
  LspSignatureActiveParameter = { bg = P.surface0, bold = true },
  LspDiagnosticsError = { fg = P.red },
  LspDiagnosticsWarning = { fg = P.yellow },
  LspDiagnosticsInformation = { fg = P.sky },
  LspDiagnosticsHint = { fg = P.teal },
  LspDiagnosticsVirtualTextError = { fg = P.red, italic = true },
  LspDiagnosticsVirtualTextWarning = { fg = P.yellow, italic = true },
  LspDiagnosticsVirtualTextInformation = { fg = P.sky, italic = true },
  LspDiagnosticsVirtualTextHint = { fg = P.teal, italic = true },
  LspDiagnosticsUnderlineError = { sp = P.red, underline = true },
  LspDiagnosticsUnderlineWarning = { sp = P.yellow, underline = true },
  LspDiagnosticsUnderlineInformation = { sp = P.sky, underline = true },
  LspDiagnosticsUnderlineHint = { sp = P.teal, underline = true },
  LspCodeLens = { fg = P.overlay0 },
  LspCodeLensSeparator = { link = "LspCodeLens" },
  LspInlayHint = { fg = P.overlay0, bg = pick(shade("mantle", 0.7), shade("surface0", 0.64)) },
  LspInfoBorder = { link = "FloatBorder" },
  -- ── other ──
  ["@attribute"] = { link = "Constant" },
  ["@attribute.c_sharp"] = { fg = P.yellow },
  ["@boolean"] = { link = "Boolean" },
  ["@character"] = { link = "Character" },
  ["@character.special"] = { link = "SpecialChar" },
  ["@character.special.html"] = { fg = P.red },
  ["@comment"] = { link = "Comment" },
  ["@comment.documentation"] = { link = "Comment" },
  ["@comment.error"] = { fg = P.base, bg = P.red },
  ["@comment.hint"] = { fg = P.base, bg = P.blue },
  ["@comment.note"] = { fg = P.base, bg = P.blue },
  ["@comment.todo"] = { fg = P.base, bg = P.flamingo },
  ["@comment.warning"] = { fg = P.base, bg = P.yellow },
  ["@comment.warning.gitcommit"] = { fg = P.yellow },
  ["@conditional"] = { link = "Conditional" },
  ["@constant"] = { link = "Constant" },
  ["@constant.builtin"] = { fg = P.peach },
  ["@constant.java"] = { fg = P.teal },
  ["@constant.macro"] = { link = "Macro" },
  ["@constructor"] = { fg = P.yellow },
  ["@constructor.lua"] = { link = "@punctuation.bracket" },
  ["@constructor.python"] = { fg = P.sky },
  ["@define"] = { link = "Define" },
  ["@diff.delta"] = { link = "diffChanged" },
  ["@diff.minus"] = { link = "diffRemoved" },
  ["@diff.plus"] = { link = "diffAdded" },
  ["@error"] = { link = "Error" },
  ["@exception"] = { link = "Exception" },
  ["@field"] = { fg = P.lavender },
  ["@float"] = { link = "Float" },
  ["@function"] = { link = "Function" },
  ["@function.builtin"] = { fg = P.peach },
  ["@function.builtin.bash"] = { fg = P.red, italic = true },
  ["@function.call"] = { link = "Function" },
  ["@function.macro"] = { fg = P.pink },
  ["@function.method"] = { link = "Function" },
  ["@function.method.call"] = { link = "Function" },
  ["@function.method.call.php"] = { link = "Function" },
  ["@function.method.php"] = { link = "Function" },
  ["@include"] = { link = "Include" },
  ["@keyword"] = { link = "Keyword" },
  ["@keyword.conditional"] = { link = "Conditional" },
  ["@keyword.conditional.ternary"] = { link = "Operator" },
  ["@keyword.coroutine"] = { link = "Keyword" },
  ["@keyword.debug"] = { link = "Exception" },
  ["@keyword.directive"] = { link = "PreProc" },
  ["@keyword.directive.css"] = { link = "Keyword" },
  ["@keyword.directive.define"] = { link = "Define" },
  ["@keyword.exception"] = { link = "Exception" },
  ["@keyword.export"] = { fg = P.mauve },
  ["@keyword.function"] = { fg = P.mauve },
  ["@keyword.import"] = { link = "Include" },
  ["@keyword.import.c"] = { fg = P.yellow },
  ["@keyword.import.cpp"] = { fg = P.yellow },
  ["@keyword.modifier"] = { link = "Keyword" },
  ["@keyword.operator"] = { fg = P.mauve },
  ["@keyword.repeat"] = { link = "Repeat" },
  ["@keyword.return"] = { fg = P.mauve },
  ["@keyword.storage"] = { link = "Keyword" },
  ["@keyword.type"] = { link = "Keyword" },
  ["@label"] = { link = "Label" },
  ["@label.yaml"] = { fg = P.yellow },
  ["@lsp.type.enumMember"] = { fg = P.teal },
  ["@lsp.type.variable"] = {  },
  ["@lsp.typemod.function.builtin"] = { link = "@function.builtin" },
  ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
  ["@markup"] = { fg = P.text },
  ["@markup.environment"] = { fg = P.pink },
  ["@markup.environment.name"] = { fg = P.blue },
  ["@markup.heading"] = { fg = P.blue },
  ["@markup.heading.1.html"] = { link = "@markup" },
  ["@markup.heading.1.markdown"] = { link = "rainbow1" },
  ["@markup.heading.2.html"] = { link = "@markup" },
  ["@markup.heading.2.markdown"] = { link = "rainbow2" },
  ["@markup.heading.3.html"] = { link = "@markup" },
  ["@markup.heading.3.markdown"] = { link = "rainbow3" },
  ["@markup.heading.4.html"] = { link = "@markup" },
  ["@markup.heading.4.markdown"] = { link = "rainbow4" },
  ["@markup.heading.5.html"] = { link = "@markup" },
  ["@markup.heading.5.markdown"] = { link = "rainbow5" },
  ["@markup.heading.6.html"] = { link = "@markup" },
  ["@markup.heading.6.markdown"] = { link = "rainbow6" },
  ["@markup.heading.html"] = { link = "@markup" },
  ["@markup.heading.markdown"] = { bold = true },
  ["@markup.italic"] = { fg = P.red, italic = true },
  ["@markup.link"] = { fg = P.lavender },
  ["@markup.link.label"] = { fg = P.lavender },
  ["@markup.link.label.html"] = { fg = P.text },
  ["@markup.link.url"] = { fg = P.blue, italic = true, underline = true },
  ["@markup.list"] = { fg = P.teal },
  ["@markup.list.checked"] = { fg = P.green },
  ["@markup.list.unchecked"] = { fg = P.overlay1 },
  ["@markup.math"] = { fg = P.blue },
  ["@markup.quote"] = { fg = P.pink },
  ["@markup.raw"] = { fg = P.green },
  ["@markup.strikethrough"] = { fg = P.text, strikethrough = true },
  ["@markup.strong"] = { fg = P.red, bold = true },
  ["@markup.underline"] = { link = "Underlined" },
  ["@method"] = { link = "Function" },
  ["@method.call"] = { link = "Function" },
  ["@method.call.php"] = { link = "Function" },
  ["@method.php"] = { link = "Function" },
  ["@module"] = { fg = P.yellow, italic = true },
  ["@namespace"] = { fg = P.yellow, italic = true },
  ["@number"] = { link = "Number" },
  ["@number.css"] = { fg = P.peach },
  ["@number.float"] = { link = "Float" },
  ["@operator"] = { link = "Operator" },
  ["@parameter"] = { fg = P.maroon },
  ["@preproc"] = { link = "PreProc" },
  ["@property"] = { fg = P.lavender },
  ["@property.class.css"] = { fg = P.yellow },
  ["@property.css"] = { fg = P.blue },
  ["@property.id.css"] = { fg = P.yellow },
  ["@property.scss"] = { fg = P.blue },
  ["@punctuation.bracket"] = { fg = P.overlay2 },
  ["@punctuation.delimiter"] = { link = "Delimiter" },
  ["@punctuation.delimiter.regex"] = { link = "@string.regexp" },
  ["@punctuation.special"] = { link = "Special" },
  ["@repeat"] = { link = "Repeat" },
  ["@storageclass"] = { link = "Keyword" },
  ["@string"] = { link = "String" },
  ["@string.documentation"] = { fg = P.teal },
  ["@string.escape"] = { fg = P.pink },
  ["@string.plain.css"] = { fg = P.text },
  ["@string.regex"] = { fg = P.pink },
  ["@string.regexp"] = { fg = P.pink },
  ["@string.special"] = { link = "Special" },
  ["@string.special.path"] = { link = "Special" },
  ["@string.special.path.gitignore"] = { fg = P.text },
  ["@string.special.symbol"] = { fg = P.flamingo },
  ["@string.special.symbol.ruby"] = { fg = P.flamingo },
  ["@string.special.url"] = { fg = P.blue, italic = true, underline = true },
  ["@string.special.url.html"] = { fg = P.green },
  ["@symbol"] = { fg = P.flamingo },
  ["@symbol.ruby"] = { fg = P.flamingo },
  ["@tag"] = { fg = P.blue },
  ["@tag.attribute"] = { fg = P.yellow, italic = true },
  ["@tag.builtin"] = { fg = P.blue },
  ["@tag.delimiter"] = { fg = P.teal },
  ["@text"] = { fg = P.text },
  ["@text.danger"] = { fg = P.base, bg = P.red },
  ["@text.diff.add"] = { link = "diffAdded" },
  ["@text.diff.delete"] = { link = "diffRemoved" },
  ["@text.emphasis"] = { fg = P.red, italic = true },
  ["@text.environment"] = { fg = P.pink },
  ["@text.environment.name"] = { fg = P.blue },
  ["@text.literal"] = { fg = P.green },
  ["@text.math"] = { fg = P.blue },
  ["@text.note"] = { fg = P.base, bg = P.blue },
  ["@text.reference"] = { fg = P.lavender },
  ["@text.strike"] = { fg = P.text, strikethrough = true },
  ["@text.strong"] = { fg = P.red, bold = true },
  ["@text.title"] = { fg = P.blue },
  ["@text.title.1.markdown"] = { link = "rainbow1" },
  ["@text.title.2.markdown"] = { link = "rainbow2" },
  ["@text.title.3.markdown"] = { link = "rainbow3" },
  ["@text.title.4.markdown"] = { link = "rainbow4" },
  ["@text.title.5.markdown"] = { link = "rainbow5" },
  ["@text.title.6.markdown"] = { link = "rainbow6" },
  ["@text.todo"] = { fg = P.base, bg = P.flamingo },
  ["@text.todo.checked"] = { fg = P.green },
  ["@text.todo.unchecked"] = { fg = P.overlay1 },
  ["@text.underline"] = { link = "Underlined" },
  ["@text.warning"] = { fg = P.base, bg = P.yellow },
  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { fg = P.mauve },
  ["@type.css"] = { fg = P.lavender },
  ["@type.definition"] = { link = "Type" },
  ["@type.qualifier"] = { link = "Keyword" },
  ["@type.tag.css"] = { fg = P.blue },
  ["@variable"] = { fg = P.text },
  ["@variable.builtin"] = { fg = P.red },
  ["@variable.member"] = { fg = P.lavender },
  ["@variable.parameter"] = { fg = P.maroon },
  ["@variable.parameter.bash"] = { fg = P.green },
  FloatBorder = { fg = P.blue, bg = P.mantle },
  FloatTitle = { fg = P.subtext0, bg = P.mantle },
}

-- 应用
vim.o.background = is_light and "light" or "dark"
for name, hl in pairs(groups) do
  vim.api.nvim_set_hl(0, name, hl)
end
vim.g.colors_name = "catppuccin-" .. flavour

-- 终端缓冲区（:terminal）的 16 色。想用终端自身配色就注释掉这一段。
local term = { P.surface1, P.red, P.green, P.yellow, P.blue, P.mauve, P.teal, P.subtext1,
               P.surface2, P.red, P.green, P.yellow, P.blue, P.mauve, P.teal, P.subtext0 }
for i, c in ipairs(term) do
  vim.g["terminal_color_" .. (i - 1)] = c
end


-- ---------------------------------------------------------------------------
-- 15. 状态栏（原生 %! 表达式，配色照抄官方 Catppuccin lualine 主题）
-- ---------------------------------------------------------------------------
--
-- 颜色映射来自 catppuccin/nvim 的 lua/catppuccin/utils/lualine.lua（未做发挥）：
--   normal   a = blue  底 / mantle 字（带粗体）   b = surface0 底 / blue 字
--   insert   a = green 底 / base 字              b = surface0 底 / green 字
--   visual   a = mauve 底 / base 字              b = surface0 底 / mauve 字
--   replace  a = red   底 / base 字              b = surface0 底 / red 字
--   command  a = peach 底 / base 字              b = surface0 底 / peach 字
--   terminal a = green 底 / base 字              b = surface0 底 / green 字
--   c 段      = mantle 底 / text 字（非当前窗口退回蓝色，同上游 inactive）
--
-- 注：normal 的 a 段字色上游用 mantle，其他模式用 base —— 我按原样抄，没统一。

local stat_modes = {
  normal   = { color = P.blue,  fg = P.mantle, label = "NORMAL" },
  insert   = { color = P.green, fg = P.base,   label = "INSERT" },
  visual   = { color = P.mauve, fg = P.base,   label = "VISUAL" },
  replace  = { color = P.red,   fg = P.base,   label = "REPLACE" },
  command  = { color = P.peach, fg = P.base,   label = "COMMAND" },
  terminal = { color = P.green, fg = P.base,   label = "TERM" },
}

for key, m in pairs(stat_modes) do
  vim.api.nvim_set_hl(0, "StMode" .. key .. "A", { bg = m.color, fg = m.fg, bold = true })
  vim.api.nvim_set_hl(0, "StMode" .. key .. "B", { bg = P.surface0, fg = m.color })
end

vim.api.nvim_set_hl(0, "StC", { bg = P.mantle, fg = P.text })
vim.api.nvim_set_hl(0, "StCDim", { bg = P.mantle, fg = P.overlay0 })
vim.api.nvim_set_hl(0, "StDiagError", { bg = P.mantle, fg = P.red })
vim.api.nvim_set_hl(0, "StDiagWarn", { bg = P.mantle, fg = P.yellow })
vim.api.nvim_set_hl(0, "StDiagInfo", { bg = P.mantle, fg = P.sky })
vim.api.nvim_set_hl(0, "StDiagHint", { bg = P.mantle, fg = P.teal })
-- 非当前窗口（上游 inactive 段）：a/b 都退成 mantle 底，c 段退成 overlay0
vim.api.nvim_set_hl(0, "StModeInactiveA", { bg = P.mantle, fg = P.blue })
vim.api.nvim_set_hl(0, "StModeInactiveB", { bg = P.mantle, fg = P.surface1, bold = true })
vim.api.nvim_set_hl(0, "StInactive", { bg = P.mantle, fg = P.overlay0 })

-- 当前模式 -> 上面那张表的键。
-- 注意 mode() 的取值很碎：i/ic/ix、R/Rc/Rv、c/cv/ce、t/nt、v/V/s/S、
-- 块选是单字节 "\22"（Ctrl-V）与 "\19"（Ctrl-S）。
-- 顺序要紧：先判 R，否则 "Rv" 会被当成含 v 的 visual。
local function stat_mode_key(m)
  m = m or vim.api.nvim_get_mode().mode
  local c = m:sub(1, 1)
  if c == "i" then return "insert" end
  if c == "R" then return "replace" end
  if c == "c" then return "command" end
  if c == "t" then return "terminal" end
  if c == "v" or c == "V" or c == "s" or c == "S" or m == "\22" or m == "\19" then
    return "visual"
  end
  return "normal"
end

-- 状态栏里 % 是转义字符，文件名/客户端名里的 % 必须写双
local function stat_esc(s)
  return (s:gsub("%%", "%%%%"))
end

function _G.NativeStatusline()
  local key = stat_mode_key()

  -- laststatus=3 时是全局状态栏；但浮窗/非当前窗口仍会问一次
  local cur = vim.api.nvim_get_current_win()
  local win = tonumber(vim.g.statusline_winid or 0)
  local active = (win == 0) or (win == cur)

  local hl_a = active and ("StMode" .. key .. "A") or "StModeInactiveA"
  local hl_b = active and ("StMode" .. key .. "B") or "StModeInactiveB"
  local hl_c = active and "StC" or "StInactive"
  local hl_dim = active and "StCDim" or "StInactive"

  local out = {}
  local function put(s) out[#out + 1] = s end

  -- ── 左：模式块 ─────────────────────────────────────────────────────
  put("%#" .. hl_a .. "# " .. stat_modes[key].label .. " ")

  -- ── 左：文件名（b 段，模式色字）──────────────────────────────────
  local name = vim.fn.expand("%:~:.")
  if name == "" then
    name = "[No Name]"
  end
  local flags = ""
  if vim.bo.modified then flags = flags .. " +" end
  if vim.bo.readonly then flags = flags .. " ro" end
  put("%#" .. hl_b .. "# %<" .. stat_esc(name) .. flags .. " ")

  -- ── 右：全部内容 ───────────────────────────────────────────────────
  put("%=")
  put("%#" .. hl_c .. "#")

  -- 诊断计数（逐个严重级上色；无诊断时整段不出现）
  local counts = vim.diagnostic.count(0)
  local sev = {
    { 1, "E", "StDiagError" },
    { 2, "W", "StDiagWarn" },
    { 3, "I", "StDiagInfo" },
    { 4, "H", "StDiagHint" },
  }
  local has_diag = false
  for _, s in ipairs(sev) do
    local n = counts[s[1]]
    if n and n > 0 then
      has_diag = true
      put(" %#" .. (active and s[3] or "StInactive") .. "#" .. s[2] .. ":" .. n)
    end
  end
  if has_diag then
    put(" %#" .. hl_c .. "#")
  end

  -- 已挂载的 LSP 客户端（没挂就不占位）
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    local names = {}
    for _, c in ipairs(clients) do
      names[#names + 1] = c.name
    end
    put(" " .. stat_esc(table.concat(names, ",")) .. " ")
  end

  -- 原生进度（LSP 加载 / :make 等），0.12 自带；非当前窗口不显示
  local progress = ""
  if active and package.loaded["vim.ui"] and vim.ui.progress_status then
    local ok, p = pcall(vim.ui.progress_status)
    if ok and type(p) == "string" then
      progress = p
    end
  end
  if progress ~= "" then
    put("%#" .. hl_dim .. "# " .. stat_esc(progress) .. " ")
  end

  -- 终端缓冲区的退出码（0.12 原生，失败就跳过）
  local ok_ec, exitcode = pcall(function()
    return require("vim._core.util").term_exitcode()
  end)
  if ok_ec and exitcode and exitcode ~= "" then
    put("%#" .. hl_dim .. "# exit " .. tostring(exitcode) .. " ")
  end

  -- filetype（空 ft 不占位）
  local ft = vim.bo.filetype
  if ft ~= "" then
    put("%#" .. hl_dim .. "# " .. stat_esc(ft) .. " ")
  end

  -- 非 utf-8 才提醒编码（utf-8 是常态，不占位）
  local enc = vim.bo.fileencoding
  if enc ~= "" and enc ~= "utf-8" then
    put("%#" .. hl_dim .. "# " .. stat_esc(enc) .. " ")
  end

  -- 行:列 + 百分比
  put("%#" .. hl_c .. "#" .. " %l:%c %3p%% ")

  return table.concat(out)
end

vim.o.statusline = "%!v:lua.NativeStatusline()"


-- ---------------------------------------------------------------------------
-- 16. 缓冲区列表（原生 tabline 实现，零插件）
-- ---------------------------------------------------------------------------
--
-- 做法：把 tabline 占为己用（bufferline.nvim 也是这么干的），理由：
--   · tabline 是屏幕顶部那条「与窗口无关、只画一次」的横条
--   · winbar 则是每个窗口各一条，分屏时会重复好几行
-- ⚠️ 代价：真·tabpage（:tabnew）不再显示在顶栏。本配置不用 tabpage，故接受。
--
-- 只在「列出的缓冲区 > 1」时才占那一行（showtabline 动态切 1/2）。
--
-- 配色沿用官方 Catppuccin 给 barbar.nvim 的映射（integrations/barbar.lua），
-- 连组名都照官方——以后真装 barbar，这些组已经是现成的：
--   当前未改  bg surface1 / fg text        当前已改   bg surface1 / fg yellow
--   可见（在别的窗口里）bg mantle / fg text 上面已改   bg mantle  / fg yellow
--   其它       bg mantle  / fg overlay0    上面已改   bg mantle  / fg yellow

vim.api.nvim_set_hl(0, "BufferCurrent", { bg = P.surface1, fg = P.text })
vim.api.nvim_set_hl(0, "BufferCurrentMod", { bg = P.surface1, fg = P.yellow })
vim.api.nvim_set_hl(0, "BufferVisible", { bg = P.mantle, fg = P.text })
vim.api.nvim_set_hl(0, "BufferVisibleMod", { bg = P.mantle, fg = P.yellow })
vim.api.nvim_set_hl(0, "BufferInactive", { bg = P.mantle, fg = P.overlay0 })
vim.api.nvim_set_hl(0, "BufferInactiveMod", { bg = P.mantle, fg = P.yellow })

-- 什么算「该显示的缓冲区」：列出的、且不是纯内部缓冲区
local function bufline_is_listed(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if not vim.bo[buf].buflisted then
    return false
  end
  local bt = vim.bo[buf].buftype
  return bt == "" or bt == "acwrite" or bt == "help" or bt == "terminal"
end

local function bufline_list()
  local out = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if bufline_is_listed(buf) then
      out[#out + 1] = buf
    end
  end
  return out
end

-- 名字只取尾段（全路径在顶栏放不下），无名给占位
local function bufline_name(buf)
  local full = vim.api.nvim_buf_get_name(buf)
  if full == "" then
    return "[No Name]"
  end
  local tail = vim.fn.fnamemodify(full, ":t")
  if tail == "" then
    tail = full
  end
  -- tabline 里 % 是转义字符
  return (tail:gsub("%%", "%%%%"))
end

function _G.NativeBufferline()
  local bufs = bufline_list()
  if #bufs == 0 then
    return ""
  end

  -- 当前窗口的缓冲区 = 当前；在别的窗口里显示着的 = 可见；剩下 = 非活动
  local current = vim.api.nvim_get_current_buf()
  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(win)
    if b ~= current then
      visible[b] = true
    end
  end

  local parts = { "%#TabLineFill#" }
  for _, buf in ipairs(bufs) do
    local is_cur = (buf == current)
    local is_vis = visible[buf]
    local hl, hl_mod
    if is_cur then
      hl, hl_mod = "BufferCurrent", "BufferCurrentMod"
    elseif is_vis then
      hl, hl_mod = "BufferVisible", "BufferVisibleMod"
    else
      hl, hl_mod = "BufferInactive", "BufferInactiveMod"
    end

    parts[#parts + 1] = "%#" .. hl .. "# " .. bufline_name(buf)
    if vim.bo[buf].modified then
      parts[#parts + 1] = "%#" .. hl_mod .. "# +%#" .. hl .. "#"
    end
    parts[#parts + 1] = " "

    -- 太长时从这里截断（裁掉的是后面的缓冲区，保住当前及之前的）
    if is_cur then
      parts[#parts + 1] = "%<"
    end
    parts[#parts + 1] = "%#TabLineFill# "
  end

  return table.concat(parts)
end

vim.o.tabline = "%!v:lua.NativeBufferline()"

-- 只有一个缓冲区时把顶栏收起来（不白白占一行）
local bufline_group = vim.api.nvim_create_augroup("native_bufferline", { clear = true })
local function bufline_refresh()
  vim.schedule(function()
    local n = #bufline_list()
    local want = n > 1 and 2 or 1
    if vim.o.showtabline ~= want then
      vim.o.showtabline = want
    end
  end)
end
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufFilePost", "VimEnter" }, {
  group = bufline_group,
  callback = bufline_refresh,
})
bufline_refresh()

-- 切换缓冲区：沿着 bufline_list() 的顺序环回，跳过缓冲区列表看不见的那些
local function bufline_cycle(step)
  local bufs = bufline_list()
  if #bufs < 2 then
    return
  end

  local current = vim.api.nvim_get_current_buf()
  local idx = nil
  for i, b in ipairs(bufs) do
    if b == current then
      idx = i
      break
    end
  end

  local next_buf
  if idx then
    next_buf = bufs[((idx - 1 + step) % #bufs) + 1]
  else
    -- 当前缓冲区不在列表里（如临时 scratch）：从第一/最后一个开始
    next_buf = (step > 0) and bufs[1] or bufs[#bufs]
  end

  vim.api.nvim_set_current_buf(next_buf)
end

-- ⚠️ 9 / 0 是用户指定直接占用的：会覆盖原生「0 = 跳行首」与「9 = 计数前缀」。
--    想去掉就把下面两行注释掉（原生行为立即恢复）。
map("n", "9", function() bufline_cycle(-1) end, { desc = "上一个 buffer" })
map("n", "0", function() bufline_cycle(1) end, { desc = "下一个 buffer" })
