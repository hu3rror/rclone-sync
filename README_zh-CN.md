# Rclone 同步脚本

[English](README.md) | 中文

这个 PowerShell 脚本旨在使用 `rclone` 命令行工具自动同步文件夹。

## 功能

- 支持在 JSON 配置文件中定义多个同步配置
- 自动创建日志文件夹和每个同步任务的日志文件
- 根据可配置的最大日志文件数量清理旧的日志文件
- 提供选项从同步过程中排除特定的文件/文件夹
- 允许为每个同步任务自定义 `rclone` 参数

## 先决条件

1. 在您的系统上安装 `rclone`。您可以从官方网站下载: [https://rclone.org/downloads/](https://rclone.org/downloads/)
2. 在与脚本相同的目录中创建一个 `config.json` 文件,其中包含同步配置。

## 使用方法

1. 打开 PowerShell 终端,导航到脚本所在的目录。
2. 使用以下命令运行脚本:

   ```powershell
   .\rclone-sync.ps1 -ConfigFile "config.json"
   ```

   这将执行 `config.json` 文件中定义的同步任务。

3. 您也可以指定 `rclone` 可执行文件的路径和日志文件夹路径:

   ```powershell
   .\rclone-sync.ps1 -ConfigFile "config.json" -RclonePath "C:\Program Files\rclone\rclone.exe" -LogFolderPath "C:\Logs"
   ```

## 配置

同步配置定义在 `config.json` 文件中,该文件应位于与脚本相同的目录中。该文件应包含一个同步配置数组,每个配置具有以下属性:

- `enabled`: 一个布尔值,指示是否启用同步任务。
- `localFolder`: 要同步的本地文件夹路径。
- `destName`: 远程目标的名称(如 `rclone` 配置中所定义)。
- `destFolder`: 要同步到的远程文件夹路径。
- `taskName`: (可选) 同步任务的名称,用于日志文件命名。
- `exclude`: (可选) 要从同步过程中排除的文件/文件夹模式数组。
- `rcloneFlags`: (可选) 要用于同步任务的其他 `rclone` 参数。
- `showCommand`: (可选) 一个布尔值,指示是否在执行前显示完整的 `rclone` 命令。
- `maximumLogFiles`: (可选) 每个同步任务要保留的最大日志文件数量。