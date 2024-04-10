<#
 Runs `rclone sync` to sync folders.
#>

# Set/get config file path
param (
    [Parameter(Mandatory = $true)]
    [string]$ConfigFile = "config.json"
)

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
        [switch]$showCommand,
        [Parameter()]
        [int]$maximumLogFiles = 15
    )

    # rclone sync folder command
    $rcloneCommand = "rclone sync $localFolder `"${destName}:$destFolder`""

    # add exclude parameter
    $excludeArgs = $exclude | ForEach-Object { "--exclude `"$_`"" }    # convert array to comma separated string

    if ($excludeArgs.Length -gt 0) {
        $rcloneCommand += " $($excludeArgs -join " ")"
    }

    # add --log-file parameter
    $logFile = Join-Path -Path $logFolder -ChildPath "Untitled.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

    if ($taskName.Length -gt 0) {
        $logFile = Join-Path -Path $logFolder -ChildPath "$taskName.$destName.$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"    # define log file name format
    }

    $rcloneCommand += " --log-file=$logFile"

    # add more rclone flags options
    if ($rcloneFlags.Length -gt 0) {
        $rcloneCommand += " $rcloneFlags"
    }

    # show full rclone command
    if ($showCommand) {
        Write-Host $rcloneCommand
    }

    # run full rclone command
    Invoke-Expression $rcloneCommand

    # clean log files
    $logFiles = Get-ChildItem -Path $logFolder -Filter "$taskName.$destName.*.log" -File | Sort-Object LastWriteTime
    if ($logFiles.Count -gt $maximumLogFiles) {
        $oldLogFiles = $logFiles[0..($logFiles.Count - $maximumLogFiles - 1)]
        foreach ($oldLogFile in $oldLogFiles) {
            Remove-Item -Path $oldLogFile.FullName -Force
        }
    }
}

# ------ Sync-Folders Function End ------



# ------ main Start ------

# check if rclone is installed
if (-not (Get-Command "rclone" -ErrorAction SilentlyContinue)) {
    Write-Error "rclone is not installed, please install rclone first."
    return
}

# create log folder
$logFolder = Join-Path -Path $PSScriptRoot -ChildPath "logs"

if (-not (Test-Path -Path $logFolder -PathType Container)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

# check if config.json file exists
if (-not (Test-Path -Path $ConfigFile -PathType Leaf)) {
    Write-Error "cannot find sync config file：$ConfigFile"
    return
}

# read sync config from config.json file and convert to object
$syncConfig = Get-Content -Path $ConfigFile | ConvertFrom-Json

# traverse sync config
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

# ------ main End ------
