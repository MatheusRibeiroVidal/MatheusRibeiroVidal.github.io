# Get the current directory where the script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Go to the root of the repo (where docs and Zola_builder are located)
Set-Location -Path $scriptDir

# Sync changes done in Obsidian
## use --update to autoupdate the timestamp in /now
.\sync_from_obsidian.bat
#.\sync_from_obsidian.bat --update

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
Copy-Item -Recurse -Force $publicPath\* $docsPath\

# Go back to the root of the repo (where docs and Zola_builder are located)
Set-Location -Path $scriptDir

# Find the number of commits with "Auto - Content Update" in the message
$commitCount = git log --oneline --grep="^Auto - Content Update" | Measure-Object | Select-Object -ExpandProperty Count

# Create the commit title
$commitTitle = "Auto - Content Update $($commitCount + 1)"

# Get the list of added, modified, and removed .md files
$updatedMdFiles = git diff --cached --name-status | Where-Object { $_ -match "^[ADM].*\.md" }

# Format the body (description) if there are updated .md files
$commitBody = ""
if ($updatedMdFiles) {
    $commitBody = "`nUpdated .md files:`n" + ($updatedMdFiles -join "`n")
}

# Full commit message with title + body
$fullMessage = "$commitTitle`n`n$commitBody"

# Git commit and push
git add -A

if ($commitBody -ne "") {
    git commit -m $commitTitle -m $commitBody
} else {
    git commit -m $commitTitle
}

git push


Write-Host "Changes have been committed and pushed successfully with message:`n$fullMessage"
