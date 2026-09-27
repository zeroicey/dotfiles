# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## What's included

| Config | Tool | Description |
|--------|------|-------------|
| `dot_config/ghostty/` | [Ghostty](https://ghostty.org/) | Terminal — Cascadia Code NF, transparent bg |
| `dot_config/nvim/` | [Neovim](https://neovim.io/) | Lazy.nvim + LSP, Treesitter, Tokyonight, etc. |
| `dot_config/tmux/` | [tmux](https://github.com/tmux/tmux) | Catppuccin Frappe, vim keybinds, TPM |
| `dot_config/yazi/` | [yazi](https://github.com/sxyazi/yazi) | File manager — show hidden files |
| `dot_config/fcitx5/config` | [Fcitx5](https://fcitx-im.org/) | 清空 `AltTriggerKeys`（默认抢走 `Shift_L` 做临时切中英，会覆盖 rime 的 `commit_code`） |
| `dot_local/share/fcitx5/rime/` | [Rime](https://rime.im/) 雾凇拼音 | `rime_ice.custom.yaml`（整句造句/`,` `.` 翻页/每页 9 个）+ `grammar.yaml` + NixOS 专用的 `default.custom.yaml` |
| `dot_zshrc` | Zsh | Zimfw, aliases, zoxide, fzf, proxy helpers |
| `dot_zimrc` | [Zim](https://github.com/zimfw/zimfw) | Shell modules — completions, syntax highlighting |
| `dot_fzf.zsh` | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder config |
| `dot_powershell/Microsoft.PowerShell_profile.ps1` | PowerShell | Windows 专用；仅 Windows 生效（`.chezmoiignore` 按 OS 过滤），由 `run_after_install-pwsh-profile.ps1.tmpl` 同步到 `$PROFILE` |
| `dot_config/vscode/` | VS Code | settings/keybindings/extensions 跨平台；由 `run_after_deploy-vscode.{sh,ps1}.tmpl` 同步到各平台 User 目录 |

## 跨平台模型（2026-08-24 起）

本仓库面向多台机器（Linux/macOS/Windows），GitHub 是唯一事实源：

- **平台过滤**：`.chezmoiignore` 本身就是模板，按 `{{ .chezmoi.os }}` 控制哪些文件在哪个平台生效。`dot_powershell/` 只在 Windows 落地；Windows 端只保留 nvim + gitconfig + PowerShell profile（zsh/tmux/ghostty/yazi/herdr 在 Windows 自动忽略），详见下方「Windows 同步」。
- **别名对齐**：各端 `v/vi/vim→nvim`、`lg→lazygit`、`ls/ll/l→eza`、`cd→zoxide`、`proxyon/proxyoff`（mihomo `127.0.0.1:7890`）尽量保持一致；工具缺失时自动回退（如 PowerShell 无 eza 用 `Get-ChildItem`）。
- **AI 合并工作流**：任一机器改配置/加插件 → commit & push 到 GitHub；其他机器 `chezmoi update`（等价 git pull + apply）拉取，平台差异由模板处理，冲突由 AI 解决。
- **一键重建**：新机器 `chezmoi init --apply` 即还原环境。Windows 需先装 chezmoi、Git、Neovim（见下方「Windows 同步」），macOS 用 brew，Arch 用 pacman。
- **注意**：chezmoi 不会把源目录名（如 `Documents/`、`AppData/`）自动映射到 Windows 特殊目录；Windows 侧特殊路径一律用 `run_` 脚本处理（见上面 PowerShell 例）。

## fcitx5 / Rime 输入法（2026-09-25 加入，仅 Linux）

| 位置 | 内容 |
|------|------|
| `dot_config/fcitx5/config` | **关键修复**：清空 `AltTriggerKeys`。fcitx5 5.1.19 该项默认值就是 `Key("Shift_L")`（上游 `src/lib/fcitx/globalconfig.cpp`），会抢走左 Shift 做「临时切换中英」，在中文组字时按下它会先把输入法切走、顺带上屏**第一个候选**——于是打 `nihao` 按 Shift 得到「你好」而不是 `nihao`，rime 的 `commit_code` 根本没机会执行。 |
| `dot_local/share/fcitx5/rime/rime_ice.custom.yaml` | 雾凇拼音的用户级 patch：开整句造句、`,`/`.` 翻页、每页 9 个候选、左右 Shift 都 `commit_code`。 |
| `dot_local/share/fcitx5/rime/grammar.yaml` | 八股文语法模型的上游配置模板（`grammar:/hans`）。 |
| `dot_local/share/fcitx5/rime/default.custom.yaml` | **NixOS 专用**：nixpkgs 把上游 `default.yaml` 改名了，不写这份就没有任何输入方案。别的发行版通常不需要。 |
| `run_after_setup-rime-grammar.sh.tmpl` | 下载 39 MB 的 `zh-hans-t-essay-bgw.gram` 并校验 sha256。 |

**为什么 39 MB 的语法模型不进 git**：它是上游产物（`lotem/rime-octagram-data` 的 `hans` 分支）、二进制、且会随上游更新；进 git 会永久留在历史里、每次 clone 都白拉 39 MB。归档的是「下载方式 + 校验和」。

- 网络在 mihomo 后面时：`RIME_GRAMMAR_PROXY=http://127.0.0.1:7890 chezmoi apply`（脚本也认 `https_proxy`）。
- 覆盖下载地址：`RIME_GRAMMAR_URL=... chezmoi apply`。
- 幂等且自愈：文件已在且大小正确就跳过；被误删后重新 `chezmoi apply` 会补回来。

**改完 rime 配置必须重启 fcitx5 才重编译**（引擎在跑时改文件不生效）。

⚠️ **只覆盖 Linux**：macOS 用 Squirrel、Windows 用 Weasel，rime 数据目录完全不同（`~/Library/Application Support/Rime/`、`%APPDATA%\Rime\`），未在那些平台验证过，故 `.chezmoiignore` 里按 OS 过滤掉了——故意不发未测代码。

## Windows 同步（2026-08-25 起）

Windows 只保留 **Neovim + git 全局配置 + PowerShell profile + VS Code 配置**，zsh/tmux/ghostty/yazi/herdr 由 `.chezmoiignore` 按 OS 过滤，不会在 Windows 落地。VS Code 配置以 `~/.config/vscode/` 为事实源，`run_after_deploy-vscode.ps1.tmpl` 复制到 `%APPDATA%\Code\User`。

**前置**：先装 chezmoi、Git、Neovim：

```powershell
winget install -e --id twpayne.chezmoi
winget install -e --id Git.Git
winget install -e --id Neovim.Neovim
```

> git 必须在 PATH（nvim 首次装 lazy.nvim 和插件要用它 clone）。

**关键坑 —— nvim 配置路径不匹配**：chezmoi 把 `dot_config/nvim` 部署到 `~/.config/nvim`（即 `C:\Users\<用户>\.config\nvim`），但 Windows 版 Neovim 默认读 `%LOCALAPPDATA%\nvim`（`AppData\Local\nvim`），**不读 `.config`**。必须先设环境变量对齐两者：

```powershell
setx XDG_CONFIG_HOME "%USERPROFILE%\.config"
```

设完**新开一个终端**验证 `echo $env:XDG_CONFIG_HOME` 再继续。若本机 `%LOCALAPPDATA%\nvim` 已有旧配置，先备份移走，避免两套配置打架。

**同步步骤**：

```powershell
# 1. 上面已 setx XDG_CONFIG_HOME 并新开终端
chezmoi init zeroicey
chezmoi apply --force
```

每次 apply 会自动执行 `run_after_install-pwsh-profile.ps1.tmpl`，把 PowerShell profile 装到 `$PROFILE`。

**验证**：`nvim` 启动应显示 NvChad UI（onedark 主题）且插件能装；`git config --global user.name` / `user.email` 生效；`Get-Content $PROFILE` 内容已更新。

## Quick start

```bash
chezmoi init --apply
```

## Key aliases

| Alias | Command |
|-------|---------|
| `v` / `vi` / `vim` | `nvim` |
| `lg` | `lazygit` |
| `ls` / `ll` / `l` | `eza` variants |
| `cd` | `z` (zoxide) |
| `proxyon` / `proxyoff` | Toggle `127.0.0.1:7890` proxy |

## Git hooks

Uses [Husky](https://typicode.github.io/husky/) + [commitlint](https://commitlint.js.org/) for conventional commits.
