# Get the current directory where the script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Go to the root of the repo (where docs and Zola_builder are located)
Set-Location -Path $scriptDir

# Sync changes done in Obsidian
.\sync_from_obsidian.bat

# Stage the Obsidian-synced folder to detect changes (adjust if not 'content')
git add .

# Check if any staged .md files exist
$mdFilesChanged = git diff --cached --name-only | Where-Object { $_ -like '*.md' }

# Update the last_update_to_site timestamp in config.toml only if there are staged .md changes
$configPath = Join-Path $scriptDir "Zola_builder\config.toml"
if ($mdFilesChanged) {
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
    } else {
        Write-Host "config.toml not found at $configPath"
    }
} else {
    Write-Host "No staged .md file changes detected. Skipping timestamp update."
}

# Define the paths
$zolaBuildPath = Join-Path $scriptDir "Zola_builder"
$docsPath = Join-Path $scriptDir "docs"
$publicPath = Join-Path $zolaBuildPath "public"

# Check if Zola_builder exists before proceeding
if (-Not (Test-Path $zolaBuildPath)) {
    Write-Host "Error: Zola_builder folder not found!"
    exit
}

# Build Zola site (run Zola from the Zola_builder folder)
Set-Location -Path $zolaBuildPath
zola build

# Check if the public folder exists before copying
if (-Not (Test-Path $publicPath)) {
    Write-Host "Error: public folder not found in $zolaBuildPath!"
    exit
}

# Ensure docs folder exists
if (-Not (Test-Path $docsPath)) {
    Write-Host "Error: docs folder not found!"
    exit
}

# Copy contents from the public folder to docs folder
Copy-Item -Recurse -Force "$publicPath\*" $docsPath\

# Go back to the root of the repo
Set-Location -Path $scriptDir

# Commit changes to Git
github
