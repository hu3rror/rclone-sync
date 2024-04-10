## rclone-sync.ps1 - Folder Synchronization Script

### Description
This PowerShell script runs `rclone sync` to synchronize folders.

### Installation
1. Clone the repo.
2. Ensure rclone is installed.
3. Copy `config.example.json` to `config.json`.
4. Edit `config.json` as needed.
5. (Optional) Edit variables in `rclone-sync.ps1` as needed.
6. Run the script:
```powershell
.\rclone-sync.ps1 -ConfigFile .\config.json
```
### Usage
**Required Parameters:**
- `destName`: Destination Cloud storage name specified in `rclone config`, e.g. `"MyOneDrive"`
- `localFolder`: Local folder path, e.g. `"C:\\Users\\username\\Downloads"`
- `destFolder`: Destination folder path, e.g. `"/Backups/Downloads"`

**Optional Parameters:**
- `taskName`: Task name, e.g. `"Downloads"`
- `exclude`: Array of files or folders to exclude, e.g. `["/*.txt", "/.git/"]`
- `rcloneFlags`: Additional rclone flags, e.g. `"--dry-run --progress --fast-list --transfers=8 --max-backlog=-1 --log-level=NOTICE"`
- `showCommand`: Display the full `rclone` command: `$true` or `$false`
- `maximumLogFiles`: Maximum number of log files to keep, e.g. `15`