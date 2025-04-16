# Get the current directory where the script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Go to the root of the repo (where docs and Zola_builder are located)
Set-Location -Path $scriptDir

# Sync changes done in Obsidian
.\sync_from_obsidian.bat

# Check if there are any staged .md changes (added/modified/deleted)
$changedMdFiles = git diff --cached --name-status | Where-Object { $_ -match "^[ADM].*\.md" }

if ($changedMdFiles) {
    # Update the last_update_to_site timestamp in config.toml
    $configPath = Join-Path $scriptDir "Zola_builder\config.toml"
    if (Test-Path $configPath) {
        $ts = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        (Get-Content $configPath) | ForEach-Object {
            if ($_ -match '^last_update_to_site\s*=\s*".*"') {
                "last_update_to_site = `"$ts`""
            } else {
                $_
            }
        } | Set-Content $configPath
        Write-Host "Updated last_update_to_site in config.toml to $ts"
        
        # Add it to the staging area
        git add $configPath
    } else {
        Write-Host "config.toml not found at $configPath"
    }
} else {
    Write-Host "No .md content changes detected — config.toml not updated"
}

# Define the paths
$zolaBuildPath = ".\Zola_builder"  # Folder where Zola builds
$docsPath = ".\docs"
$publicPath = "$zolaBuildPath\public"  # Corrected path to public folder inside Zola_builder

# Check if Zola_builder exists before proceeding
if (-Not (Test-Path $zolaBuildPath)) {
    Write-Host "Error: Zola_builder folder not found!"
    exit
}

# Build Zola site (run Zola from the Zola_builder folder)
Set-Location -Path $zolaBuildPath
# Get the current directory where the script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define relative paths
$zolaBuildPath = Join-Path $scriptDir "Zola_builder"  # Relative path to Zola_builder
$docsPath = Join-Path $scriptDir "docs"  # Relative path to docs folder
$publicPath = Join-Path $zolaBuildPath "public"  # Relative path to public folder inside Zola_builder

# Check if Zola_builder exists before proceeding
if (-Not (Test-Path $zolaBuildPath)) {
    Write-Host "Error: Zola_builder folder not found!"
    exit
}

# Build Zola site (run Zola from the Zola_builder folder)
 Set-Location -Path $zolaBuildPath
# Start Zola in a new window
Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", "zola serve" -WindowStyle Normal -WorkingDirectory "$zolaBuildPath"


# Go back to the root of the repo (where docs and Zola_builder are located)
Set-Location -Path $scriptDir

# Open default browser to local Zola preview
# Start-Process "http://127.0.0.1:1111/"