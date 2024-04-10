<#
 Runs `rclone sync` to sync folders.
#>

function Sync-Folders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CloudServiceName,
        [Parameter(Mandatory = $true)]
        [string]$LocalFolder,
        [Parameter(Mandatory = $true)]
        [string]$DestFolder
    )

    # 检查 rclone 是否已安装
    if (-not (Get-Command "rclone" -ErrorAction SilentlyContinue)) {
        Write-Error "rclone 未安装,请先安装 rclone。"
        return
    }

    # 同步文件夹
    rclone sync $LocalFolder "${CloudServiceName}:$DestFolder"
}

# 读取同步配置
$syncConfig = Get-Content -Path "sync-config.json" | ConvertFrom-Json

# 执行同步
foreach ($config in $syncConfig) {
    Sync-Folders -CloudServiceName $config.cloud_service_name -LocalFolder $config.local_folder -DestFolder $config.destination_folder
}