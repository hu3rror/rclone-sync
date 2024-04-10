<#
 Runs `rclone sync` to sync folders.
#>

# 设置 rclone flags
$rcloneFlags = "--dry-run --progress --fast-list --transfers=8 --max-backlog=-1 --log-level=NOTICE"

# 显示完整执行命令
$showCommand = $true

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
        [string]$taskName,
        [Parameter()]
        [string[]]$exclude = @(),
        [Parameter()]
        [string]$rcloneFlags = "",
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

    # 添加 taskName 参数
    if ($taskName.Length -gt 0) {

        # 创建日志文件夹
        $logFolder = Join-Path -Path $PSScriptRoot -ChildPath "logs"

        if (-not (Test-Path -Path $logFolder -PathType Container)) {
            New-Item -Path $logFolder -ItemType Directory | Out-Null
        }

        # 定义日志文件名称格式
        $logFile = Join-Path -Path $logFolder -ChildPath "$taskName.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

        $rcloneCommand += " --log-file=$logFile"
    }

    # 添加更多 rclone flags 选项
    if ($rcloneFlags.Length -gt 0) {
        $rcloneCommand += " $rcloneFlags"
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

# 遍历同步配置
foreach ($config in $syncConfig) {
    Sync-Folders `
        -localFolder $config.localFolder `
        -destName $config.destName `
        -destFolder $config.destFolder `
        -taskName $config.taskName `
        -exclude $config.exclude `
        -rcloneFlags $rcloneFlags `
        -showCommand:$showCommand
}