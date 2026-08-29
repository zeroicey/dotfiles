# ============================================================
#  Microsoft PowerShell profile —— 由 chezmoi dotfiles 仓库统一管理
#  仓库源文件：dot_powershell/Microsoft.PowerShell_profile.ps1
#  安装目标：$PROFILE（由 run_onchange_install-pwsh-profile.ps1 拷贝）
#  跨平台约定：别名/命令映射尽量与 zsh 侧（dot_zshrc）保持一致
# ============================================================

# --- 加载自检（诊断"profile 没加载"问题）---
Write-Host "[dotfiles] PowerShell profile loaded @ $($MyInvocation.MyCommand.Path)" -ForegroundColor Green

# --- 编辑器/工具别名（与 zsh 侧一致）---
function Set-EditorsAliases {
    # v / vi / vim -> nvim（无 nvim 则退回 vim / notepad）
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        Set-Alias -Name v  -Value nvim -Scope Global
        Set-Alias -Name vi -Value nvim -Scope Global
        Set-Alias -Name vim -Value nvim -Scope Global
    }
    elseif (Get-Command vim -ErrorAction SilentlyContinue) {
        Set-Alias -Name v -Value vim -Scope Global
    }
    # lg -> lazygit
    if (Get-Command lazygit -ErrorAction SilentlyContinue) {
        Set-Alias -Name lg -Value lazygit -Scope Global
    }
}
Set-EditorsAliases

# --- ls / ll / l -> eza（缺失则退回 Get-ChildItem 包装）---
function Set-ListAliases {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        function global:List-Aliased { eza -lah --icons $args }
        function global:List-Aliased-Short { eza -lah --icons $args }
    }
    else {
        function global:List-Aliased { Get-ChildItem -Force $args }
        function global:List-Aliased-Short { Get-ChildItem -Force $args }
    }
    Set-Alias -Name ls -Value List-Aliased-Short -Scope Global
    Set-Alias -Name ll -Value List-Aliased -Scope Global
    Set-Alias -Name l  -Value List-Aliased-Short -Scope Global
}
Set-ListAliases

# --- cd -> zoxide（缺失则跳过）---
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    # cd 是 PowerShell 内置 AllScope 别名，不能直接覆盖；用 Remove-Item 后再绑定
    Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
    Set-Alias -Name cd -Value z -Scope Global -Option None
}

# --- 终端代理开关（对应 Linux 侧 proxyon/proxyoff；mihomo 127.0.0.1:7890）---
function proxyon {
    $env:http_proxy  = "http://127.0.0.1:7890"
    $env:https_proxy = "http://127.0.0.1:7890"
    $env:all_proxy   = "socks5://127.0.0.1:7890"
    $env:NO_PROXY    = "localhost,127.0.0.1,::1,.local,.localdomain,.ts.net,192.168.0.0/16,100.64.0.0/10,10.0.0.0/8"
    $env:no_proxy    = $env:NO_PROXY
    Write-Host "System proxy enable 🟢" -ForegroundColor Green
}
function proxyoff {
    Remove-Item Env:http_proxy  -ErrorAction SilentlyContinue
    Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:all_proxy   -ErrorAction SilentlyContinue
    Remove-Item Env:NO_PROXY    -ErrorAction SilentlyContinue
    Remove-Item Env:no_proxy    -ErrorAction SilentlyContinue
    Write-Host "System proxy disable 🔴" -ForegroundColor Red
}

# --- 终端提示符（starship 优先，缺失则跳过）---
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (starship init powershell | Out-String) })
}

# ============================================================
#  说明：
#  · 本文件是"仓库主副本"，各机器拉取后统一。
#  · hpstation 上发现的独有别名/工具绑定，合并回本文件后在各端生效。
#  · 若提示符不显示 "profile loaded"，检查：ExecutionPolicy、
#    $PROFILE 路径（是否被 OneDrive 重定向）、PowerShell 版本。
# ============================================================
