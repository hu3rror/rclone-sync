<#
 Runs `rclone sync` to sync folders.
#>

# 定义 Sync-Folders 函数
function Sync-Folders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$destName,
        [Parameter(Mandatory = $true)]
        [string]$localFolder,
        [Parameter(Mandatory = $true)]
        [string]$destFolder,
        [Parameter()]
        [string]$logFile,
        [Parameter()]
        [string[]]$exclude = @(),
        [Parameter()]
        [string]$rcloneOptions = "",
        [Parameter()]
        [switch]$showCommand
    )

    # 检查 rclone 是否已安装
    if (-not (Get-Command "rclone" -ErrorAction SilentlyContinue)) {
        Write-Error "rclone 未安装,请先安装 rclone。"
        return
    }

    # rclone 同步文件夹主要命令
    $rcloneCommand = "rclone sync $localFolder `"${destName}:$destFolder`""

    # 添加 exclude 参数
    $excludeArgs = $exclude | ForEach-Object { "--exclude `"$_`"" }

    if ($excludeArgs.Length -gt 0) {
        $rcloneCommand += " $($excludeArgs -join " ")"
    }

    # 添加更多 rclone flags 选项
    if ($rcloneOptions.Length -gt 0) {
        $rcloneCommand += " $rcloneOptions"
    }

    # 显示 rclone 完整命令
    if ($showCommand) {
        Write-Host $rcloneCommand
    }

    # 执行 rclone 完整命令
    Invoke-Expression $rcloneCommand
}

# 读取同步配置
$syncConfig = Get-Content -Path "sync-config.json" | ConvertFrom-Json

# 设置同步选项
$rcloneOptions = "--dry-run --progress --fast-list --transfers=8 --max-backlog=-1 --log-level NOTICE"

# 是否显示完整命令
$showCommand = $true

# 遍历同步配置
foreach ($config in $syncConfig) {
    Sync-Folders `
        -localFolder $config.localFolder `
        -destName $config.destName `
        -destFolder $config.destFolder `
        -logFile $config.logFile `
        -exclude $config.exclude `
        -rcloneOptions $rcloneOptions `
        -showCommand:$showCommand
}