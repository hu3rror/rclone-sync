# Rclone Sync Script

English | [中文](README_zh-CN.md)

This PowerShell script is designed to automate the process of syncing folders using the `rclone` command-line tool.

## Features

- Supports multiple sync configurations defined in a JSON config file
- Automatically creates a log folder and log files for each sync task
- Cleans up old log files based on a configurable maximum number of files
- Provides options to exclude specific files/folders from the sync process
- Allows customization of `rclone` flags for each sync task

## Prerequisites

1. Install `rclone` on your system. You can download it from the official website: [https://rclone.org/downloads/](https://rclone.org/downloads/)
2. Create a `config.json` file in the same directory as the script, with the sync configurations.

## Usage

1. Open a PowerShell terminal and navigate to the directory where the script is located.
2. Run the script with the following command:

   ```powershell
   .\rclone-sync.ps1 -ConfigFile "config.json"
   ```

   This will execute the sync tasks defined in the `config.json` file.

3. Optionally, you can specify the path to the `rclone` executable and the log folder path:

   ```powershell
   .\rclone-sync.ps1 -ConfigFile "config.json" -RclonePath "C:\Program Files\rclone\rclone.exe" -LogFolderPath "C:\Logs"
   ```

## Configuration

The sync configurations are defined in the `config.json` file, which should be located in the same directory as the script. The file should contain an array of sync configurations, with the following properties:

- `enabled`: A boolean value indicating whether the sync task is enabled.
- `localFolder`: The local folder path to be synced.
- `destName`: The name of the remote destination (as defined in the `rclone` configuration).
- `destFolder`: The remote folder path to sync to.
- `taskName`: (Optional) A name for the sync task, used for log file naming.
- `exclude`: (Optional) An array of file/folder patterns to exclude from the sync process.
- `rcloneFlags`: (Optional) Additional `rclone` flags to be used for the sync task.
- `showCommand`: (Optional) A boolean value indicating whether to display the full `rclone` command before execution.
- `maximumLogFiles`: (Optional) The maximum number of log files to keep for each sync task.