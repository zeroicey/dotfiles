# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## What's included

| Config | Tool | Description |
|--------|------|-------------|
| `dot_config/ghostty/` | [Ghostty](https://ghostty.org/) | Terminal — Cascadia Code NF, transparent bg |
| `dot_config/nvim/` | [Neovim](https://neovim.io/) | Lazy.nvim + LSP, Treesitter, Tokyonight, etc. |
| `dot_config/tmux/` | [tmux](https://github.com/tmux/tmux) | Catppuccin Frappe, vim keybinds, TPM |
| `dot_config/yazi/` | [yazi](https://github.com/sxyazi/yazi) | File manager — show hidden files |
| `dot_zshrc` | Zsh | Zimfw, aliases, zoxide, fzf, proxy helpers |
| `dot_zimrc` | [Zim](https://github.com/zimfw/zimfw) | Shell modules — completions, syntax highlighting |
| `dot_fzf.zsh` | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder config |
| `dot_powershell/Microsoft.PowerShell_profile.ps1` | PowerShell | Windows 专用；仅 Windows 生效（`.chezmoiignore` 按 OS 过滤），由 `run_onchange_install-pwsh-profile.ps1.tmpl` 同步到 `$PROFILE` |

## 跨平台模型（2026-08-24 起）

本仓库面向多台机器（Linux/macOS/Windows），GitHub 是唯一事实源：

- **平台过滤**：`.chezmoiignore` 本身就是模板，按 `{{ .chezmoi.os }}` 控制哪些文件在哪个平台生效。`dot_powershell/` 只在 Windows 落地；Windows 端只保留 nvim + gitconfig + PowerShell profile（zsh/tmux/ghostty/yazi/herdr 在 Windows 自动忽略），详见下方「Windows 同步」。
- **别名对齐**：各端 `v/vi/vim→nvim`、`lg→lazygit`、`ls/ll/l→eza`、`cd→zoxide`、`proxyon/proxyoff`（mihomo `127.0.0.1:7890`）尽量保持一致；工具缺失时自动回退（如 PowerShell 无 eza 用 `Get-ChildItem`）。
- **AI 合并工作流**：任一机器改配置/加插件 → commit & push 到 GitHub；其他机器 `chezmoi update`（等价 git pull + apply）拉取，平台差异由模板处理，冲突由 AI 解决。
- **一键重建**：新机器 `chezmoi init --apply` 即还原环境。Windows 需先装 chezmoi、Git、Neovim（见下方「Windows 同步」），macOS 用 brew，Arch 用 pacman。
- **注意**：chezmoi 不会把源目录名（如 `Documents/`、`AppData/`）自动映射到 Windows 特殊目录；Windows 侧特殊路径一律用 `run_` 脚本处理（见上面 PowerShell 例）。

## Windows 同步（2026-08-25 起）

Windows 只保留 **Neovim + git 全局配置 + PowerShell profile**，zsh/tmux/ghostty/yazi/herdr 由 `.chezmoiignore` 按 OS 过滤，不会在 Windows 落地。

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

首次 apply 会自动执行 `run_onchange_install-pwsh-profile.ps1.tmpl`，把 PowerShell profile 装到 `$PROFILE`。

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
