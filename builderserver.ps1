param(
    [switch]$serve,
    [switch]$build,
    [switch]$auto
)

# Get the current directory where the script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Go to the root of the repo
Set-Location -Path $scriptDir

# Define relative paths
$zolaBuildPath = Join-Path $scriptDir "zola"
$docsPath = Join-Path $scriptDir "docs"
$publicPath = Join-Path $zolaBuildPath "public"
$configPath = Join-Path $scriptDir "zola\config.toml"

# Validate that only one mode is selected
$modeCount = @($serve, $build, $auto) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
if ($modeCount -eq 0) {
    Write-Host "Error: Please specify a mode: -serve, -build, or -auto"
    exit
}
if ($modeCount -gt 1) {
    Write-Host "Error: Please specify only one mode"
    exit
}

# Check if zola exists
if (-Not (Test-Path $zolaBuildPath)) {
    Write-Host "Error: zola folder not found!"
    exit
}

# ============================================================================
# SERVE MODE
# ============================================================================
if ($serve) {
    Write-Host "Running in SERVE mode..."
    
		
    # Sync changes from Charmera
	.\sync_from_charmera.bat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Sync from Charmera failed!" -ForegroundColor Red
        exit 1
    }
	
    # Sync changes from Obsidian
    .\sync_from_obsidian.bat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Sync from Obsidian failed!" -ForegroundColor Red
        exit 1
    }

    
    # Build Zola site
    Set-Location -Path $zolaBuildPath
    zola build
    
    # Start Zola server in a new window
    Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", "zola serve --drafts" -WindowStyle Normal -WorkingDirectory "$zolaBuildPath"
    
    # Go back to root
    Set-Location -Path $scriptDir
    
    Write-Host "Zola server started. Opening browser..."
}

# ============================================================================
# BUILD MODE
# ============================================================================
if ($build) {
    Write-Host "Running in BUILD mode..."
    
    # Sync changes from Charmera
	.\sync_from_charmera.bat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Sync from Charmera failed!" -ForegroundColor Red
        exit 1
    }
	
    # Sync changes from Obsidian
    .\sync_from_obsidian.bat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Sync from Obsidian failed!" -ForegroundColor Red
        exit 1
    }
	    
    # Stage files to detect changes
    git add .
    
    # Check if any staged .md files exist
    $mdFilesChanged = git diff --cached --name-only | Where-Object { $_ -like '*.md' }
    
    # Update timestamp if .md files changed
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
    
    # Build Zola site
    Set-Location -Path $zolaBuildPath
    zola build
    
    # Check if public folder exists
    if (-Not (Test-Path $publicPath)) {
        Write-Host "Error: public folder not found in $zolaBuildPath!"
        exit
    }
    
    # Ensure docs folder exists
    if (-Not (Test-Path $docsPath)) {
        Write-Host "Error: docs folder not found!"
        exit
    }
    
    # Copy contents from public to docs
    Copy-Item -Recurse -Force "$publicPath\*" $docsPath\
    
    # Go back to root
    Set-Location -Path $scriptDir
    
    # Commit changes
    github
    
    Write-Host "Build complete. Changes ready to commit."
}

# ============================================================================
# AUTO MODE (Auto-commit with changelog)
# ============================================================================
if ($auto) {
    Write-Host "Running in AUTO mode..."
    
    # Check if now.md changed BEFORE syncing
    $configPath = Join-Path $scriptDir "paths.config"
    $obsidianNowPath = ""
    
    if (Test-Path $configPath) {
        Get-Content $configPath | ForEach-Object {
            if ($_ -match '^OBSIDIAN_CONTENT_FOLDER=(.+)') {
                $obsidianNowPath = Join-Path $matches[1] "now.md"
            }
        }
    }
    
    $nowMdChanged = $false
    if ($obsidianNowPath -and (Test-Path $obsidianNowPath)) {
        $repoNowPath = Join-Path $scriptDir "zola\content\now.md"
        if (Test-Path $repoNowPath) {
            $obsidianHash = (Get-FileHash $obsidianNowPath -Algorithm MD5).Hash
            $repoHash = (Get-FileHash $repoNowPath -Algorithm MD5).Hash
            if ($obsidianHash -ne $repoHash) {
                $nowMdChanged = $true
                Write-Host "now.md content has changed"
            }
        } else {
            # If repo file doesn't exist yet, consider it changed
            $nowMdChanged = $true
        }
    }
    
    # Sync changes from Charmera
	.\sync_from_charmera.bat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Sync from Charmera failed!" -ForegroundColor Red
        exit 1
    }
	
    # Sync changes from Obsidian (with timestamp update if now.md changed)
    if ($nowMdChanged) {
        Write-Host "Updating date on now.md and archiving to then.md"
        .\sync_from_obsidian.bat --update_now
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Sync from Obsidian failed!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "No updates found on now.md"
        .\sync_from_obsidian.bat
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Sync from Obsidian failed!" -ForegroundColor Red
            exit 1
        }
    }
	
    
    # Stage files to detect changes
    git add .
    
    # Check if any staged .md files exist
    $mdFilesChanged = git diff --cached --name-only | Where-Object { $_ -like '*.md' }
    
    # Update timestamp in config.toml if .md files changed
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
    
    # Build Zola site
    Set-Location -Path $zolaBuildPath
    zola build
    
    # Check if public folder exists
    if (-Not (Test-Path $publicPath)) {
        Write-Host "Error: public folder not found in $zolaBuildPath!"
        exit
    }
    
    # Ensure docs folder exists
    if (-Not (Test-Path $docsPath)) {
        Write-Host "Error: docs folder not found!"
        exit
    }
    
    # Copy contents from public to docs
    Copy-Item -Recurse -Force "$publicPath\*" $docsPath\
    
    # Go back to root
    Set-Location -Path $scriptDir
    
    # Find the number of commits with "Auto - Content Update"
    $commitCount = git log --oneline --grep="^Auto - Content Update" | Measure-Object | Select-Object -ExpandProperty Count
    
    # Create the commit title
    $commitTitle = "Auto - Content Update $($commitCount + 1)"
    
    # Stage all changes
    git add -A
    
    # Get the list of added, modified, and removed .md files
    $updatedMdFiles = git diff --cached --name-status | Where-Object { $_ -match "^[ADM].*\.md" }
    
    # Format the commit body if there are updated .md files
    $commitBody = ""
    if ($updatedMdFiles) {
        $commitBody = "`nUpdated .md files:`n" + ($updatedMdFiles -join "`n")
    }
    
    # Check if there are actually changes to commit
    $hasChanges = git diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        # There are changes to commit
        $fullMessage = "$commitTitle`n`n$commitBody"
        
        # Commit with title and body
        if ($commitBody -ne "") {
            git commit -m $commitTitle -m $commitBody
        } else {
            git commit -m $commitTitle
        }
        
        # Push to remote
        git push
        
        Write-Host "Changes have been committed and pushed successfully with message:`n$fullMessage"
    } else {
        Write-Host "No changes to commit. Working tree clean."
    }
    
    # Auto-close the window after 2 seconds
    Start-Sleep -Seconds 2
}