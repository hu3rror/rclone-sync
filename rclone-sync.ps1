<#
 Runs `rclone sync` to sync folders.
#>

# 定义 Sync-Folders 函数
function Sync-Folders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CloudServiceName,
        [Parameter(Mandatory = $true)]
        [string]$LocalFolder,
        [Parameter(Mandatory = $true)]
        [string]$DestFolder,
        [Parameter()]
        [string[]]$Exclude = @(),
        [Parameter()]
        [string]$RcloneOptions = "",
        [Parameter()]
        [switch]$ShowCommand
    )

    # 检查 rclone 是否已安装
    if (-not (Get-Command "rclone" -ErrorAction SilentlyContinue)) {
        Write-Error "rclone 未安装,请先安装 rclone。"
        return
    }

    # rclone 同步文件夹主要命令
    $rcloneCommand = "rclone sync $LocalFolder `"${CloudServiceName}:$DestFolder`""

    # 添加 exclude 参数
    $excludeArgs = $Exclude | ForEach-Object { "--exclude `"$_`"" }

    if ($excludeArgs.Length -gt 0) {
        $rcloneCommand += " $($excludeArgs -join " ")"
    }

    # 添加更多 rclone flags 选项
    if ($RcloneOptions.Length -gt 0) {
        $rcloneCommand += " $RcloneOptions"
    }

    # 显示 rclone 完整命令
    if ($ShowCommand) {
        Write-Host $rcloneCommand
    }

    # 执行 rclone 完整命令
    Invoke-Expression $rcloneCommand
}

# 读取同步配置
$syncConfig = Get-Content -Path "sync-config.json" | ConvertFrom-Json

# 设置同步选项
$rcloneOptions = "--dry-run -vv"

# 是否显示完整命令
$ShowCommand = $true

# 遍历同步配置
foreach ($config in $syncConfig) {
    Sync-Folders `
        -CloudServiceName $config.cloud_service_name `
        -LocalFolder $config.local_folder `
        -DestFolder $config.destination_folder `
        -Exclude $config.exclude `
        -RcloneOptions $rcloneOptions `
        -ShowCommand:$ShowCommand
}