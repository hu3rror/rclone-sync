<#
 Runs `rclone sync` to sync folders.
#>

# ------ Sync-Folders Function Start ------
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
    $excludeArgs = $exclude | ForEach-Object { "--exclude `"$_`"" }    # 将数组转换为逗号分隔的字符串

    if ($excludeArgs.Length -gt 0) {
        $rcloneCommand += " $($excludeArgs -join " ")"
    }

    # 添加 --log-file 参数
    if ($taskName.Length -gt 0) {
        $logFile = Join-Path -Path $logFolder -ChildPath "$taskName.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"    # 定义日志文件名称格式
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

    # 清理日志文件
    $logFiles = Get-ChildItem -Path $logFolder -Filter "$taskName.$destName.*.log" -File | Sort-Object LastWriteTime
    if ($logFiles.Count -gt $maximumLogFiles) {
        $oldLogFiles = $logFiles[0..($logFiles.Count - $maximumLogFiles - 1)]
        foreach ($oldLogFile in $oldLogFiles) {
            Remove-Item -Path $oldLogFile.FullName -Force
        }
    }
}
# ------ Sync-Folders Function End ------


# ------ constants and variables Start ------

# 设置 rclone flags
$rcloneFlags = "--dry-run --progress --fast-list --transfers=8 --max-backlog=-1 --log-level=NOTICE"

# 显示完整执行命令
$showCommand = $true

# 设置最大日志文件数量
$maximumLogFiles = 15

# 检测 config.json 文件是否存在
if (-not (Test-Path -Path "config.json" -PathType Leaf)) {
    Write-Error "找不到同步配置文件：config.json"
    return
}

# JSON 字符串转换为对象
$syncConfig = Get-Content -Path "config.json" | ConvertFrom-Json

# 定义日志文件夹路径
$logFolder = Join-Path -Path $PSScriptRoot -ChildPath "logs"


# ------ constants and variables End ------


# ------ main Start ------

# 创建日志文件夹
if (-not (Test-Path -Path $logFolder -PathType Container)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

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

# ------ main End ------