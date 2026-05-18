# CV File Watcher
# Monitors CV file changes and syncs to zola/static/cv/
# Run this script in the background while developing

param(
    [string]$ConfigPath = ".\paths.config"
)

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Configuration file not found: $ConfigPath"
    exit 1
}

$config = @{}
Get-Content $ConfigPath | Where-Object { $_ -match '^\w+=' } | ForEach-Object {
    $key, $value = $_ -split '=', 2
    $config[$key] = $value.Trim()
}

$CV_SOURCE = "C:\Users\Matheus\Documents\My_Files\Profissional\CVs\CV_MatheusRibeiroVidal_with_recommendations.pdf"
$CV_DEST_DIR = Join-Path $config["REPO_FOLDER"] "zola\static\cv"
$CV_DEST_FILE = Join-Path $CV_DEST_DIR "CV_MatheusRibeiroVidal.pdf"

# Create destination directory if it doesn't exist
if (-not (Test-Path $CV_DEST_DIR)) {
    New-Item -ItemType Directory -Path $CV_DEST_DIR -Force | Out-Null
    Write-Host "Created directory: $CV_DEST_DIR"
}

# Initial sync if destination doesn't exist
if (-not (Test-Path $CV_DEST_FILE)) {
    Copy-Item -Path $CV_SOURCE -Destination $CV_DEST_FILE -Force
    Write-Host "Initial sync: CV copied to $CV_DEST_FILE"
}

# File watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path -Parent $CV_SOURCE
$watcher.Filter = (Split-Path -Leaf $CV_SOURCE)
$watcher.IncludeSubdirectories = $false

$lastSyncTime = Get-Item $CV_DEST_FILE | Select-Object -ExpandProperty LastWriteTime

$action = {
    # Add a small delay to ensure file is fully written
    Start-Sleep -Milliseconds 500

    $sourceFile = Get-Item $CV_SOURCE -ErrorAction SilentlyContinue
    if ($sourceFile) {
        $sourceTime = $sourceFile.LastWriteTime

        # Only sync if source is newer than destination
        if ($sourceTime -gt $lastSyncTime) {
            Copy-Item -Path $CV_SOURCE -Destination $CV_DEST_FILE -Force
            $lastSyncTime = $sourceTime
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Host "[$timestamp] CV synced: $CV_DEST_FILE"
        }
    }
}

$watcher.EnableRaisingEvents = $true
Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action | Out-Null

Write-Host "CV File Watcher started"
Write-Host "Watching: $CV_SOURCE"
Write-Host "Syncing to: $CV_DEST_FILE"
Write-Host "Press Ctrl+C to stop."

# Keep the script running
while ($true) {
    Start-Sleep -Seconds 1
}
