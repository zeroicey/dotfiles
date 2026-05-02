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
