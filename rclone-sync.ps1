<#
 Runs `rclone sync` to sync folders. / 运行 `rclone sync` 来同步文件夹。
#>

# ------ main Start / 主程序开始------

# Set/get config file path / 设置/获取配置文件路径
param (
    [Parameter(Mandatory = $true)]
    [string]$ConfigFile = "config.json",
    [Parameter()]
    [string]$RclonePath = "rclone",
    [Parameter()]
    [string]$LogFolderPath = (Join-Path -Path $PSScriptRoot -ChildPath "logs")
)

# check if rclone is installed / 检查是否安装了 rclone
if (-not (Get-Command $RclonePath -ErrorAction SilentlyContinue)) {
    Write-Error "rclone is not installed, please install rclone first. / rclone 未安装, 请先安装 rclone。"
    return
}

# create log folder / 创建日志文件夹
if (-not (Test-Path -Path $LogFolderPath -PathType Container)) {
    New-Item -Path $LogFolderPath -ItemType Directory | Out-Null
}

# check if config.json file exists / 检查 config.json 文件是否存在
if (-not (Test-Path -Path $ConfigFile -PathType Leaf)) {
    Write-Error "cannot find sync config file：$ConfigFile. / 找不到同步配置文件：$ConfigFile。"
    return
}

# read sync config from config.json file and convert to object / 从 config.json 文件读取同步配置并转换为对象
$syncConfig = Get-Content -Path $ConfigFile | ConvertFrom-Json

# ------ main End / 主程序结束------


# ------ Sync-Folders Function Start / 同步文件夹函数开始 ------
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
        [switch]$showCommand,
        [Parameter()]
        [int]$maximumLogFiles = 15
    )

    # rclone sync folder command / rclone 同步文件夹命令
    $rcloneCommand = "$RclonePath sync $localFolder `"${destName}:$destFolder`""

    # add exclude parameter / 添加排除参数
    $excludeArgs = $exclude | ForEach-Object { "--exclude `"$_`"" }    # convert array to comma separated string / 将数组转换为逗号分隔的字符串

    if ($excludeArgs.Length -gt 0) {
        $rcloneCommand += " $($excludeArgs -join " ")"
    }

    # add --log-file parameter / 添加 --log-file 参数
    $logFile = Join-Path -Path $LogFolderPath -ChildPath "Untitled.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

    if ($taskName.Length -gt 0) {
        $logFile = Join-Path -Path $LogFolderPath -ChildPath "$taskName.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"    # define log file name format / 定义日志文件名格式
    }

    $rcloneCommand += " --log-file=$logFile"

    # add more rclone flags options / 添加更多 rclone 参数选项
    if ($rcloneFlags.Length -gt 0) {
        $rcloneCommand += " $rcloneFlags"
    }

    # show full rclone command / 显示完整的 rclone 命令
    if ($showCommand) {
        Write-Host $rcloneCommand
    }

    # run full rclone command / 运行完整的 rclone 命令
    Invoke-Expression $rcloneCommand

    # check if log file is empty or first line is "INFO  : There was nothing to transfer" and delete if true / 检查日志文件是否为空或第一行是"INFO  : There was nothing to transfer",如果是则删除
    $logContent = Get-Content -Path $logFile -ErrorAction SilentlyContinue
    if ($logContent -and $logContent[0] -like "*INFO  : There was nothing to transfer*") {
        Remove-Item -Path $logFile -Force
    } elseif ((Get-Content $logFile).Length -eq 0) {
        Remove-Item -Path $logFile -Force
    }

    # clean log files / 清理日志文件
    $logFiles = Get-ChildItem -Path $LogFolderPath -Filter "$taskName.$destName.*.log" -File | Sort-Object LastWriteTime
    if ($logFiles.Count -gt $maximumLogFiles) {
        $oldLogFiles = $logFiles[0..($logFiles.Count - $maximumLogFiles - 1)]
        foreach ($oldLogFile in $oldLogFiles) {
            Remove-Item -Path $oldLogFile.FullName -Force
        }
    }
}

# ------ Sync-Folders Function End / 同步文件夹函数结束 ------

# ------ traverse sync config / 遍历同步配置 ------
foreach ($config in $syncConfig) {
    if ($config.enabled) {
        Sync-Folders `
            -localFolder $config.localFolder `
            -destName $config.destName `
            -destFolder $config.destFolder `
            -taskName $config.taskName `
            -exclude $config.exclude `
            -rcloneFlags $config.rcloneFlags `
            -showCommand:$config.showCommand `
            -maximumLogFiles $config.maximumLogFiles
    }
}

# ------ traverse sync config end / 遍历同步配置结束 ------