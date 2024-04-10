## rclone-sync.ps1 - 文件夹同步脚本

[English](README.md) | 中文

### 描述
此 PowerShell 脚本运行 `rclone sync` 来同步文件夹。

### 安装
1. 克隆仓库。
2. 确保已安装 rclone。
3. 将 `config.example.json` 复制到 `config.json`。
4. 根据需要编辑 `config.json`。
5. （可选）根据需要编辑 `rclone-sync.ps1` 中的变量。
6. 运行脚本：
```powershell
.\rclone-sync.ps1 -ConfigFile .\config.json
```
### 用法
**必需参数：**
- `destName`: 在 `rclone config` 中指定的目的地云存储名称，例如 `"MyOneDrive"`
- `localFolder`: 本地文件夹路径，例如 `"C:\\Users\\username\\Downloads"`
- `destFolder`: 目标文件夹路径，例如 `"/Backups/Downloads"`

**可选参数：**
- `taskName`: 任务名称，例如 `"Downloads"`
- `exclude`: 要排除的文件或文件夹数组，例如 `["/*.txt", "/.git"]`
- `rcloneFlags`: 其他 rclone 标记，例如 `"--dry-run --progress --fast-list --transfers=8 --max-backlog=-1 --log-level=NOTICE"`
- `showCommand`: 显示完整的 `rclone` 命令：`$true` 或 `$false`
- `maximumLogFiles`: 保留的最大日志文件数，例如 `15`