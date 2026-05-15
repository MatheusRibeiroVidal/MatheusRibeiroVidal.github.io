# MRV Website Automation Scripts & Batch Commands - Reference Guide

## Overview
Your website automation system has 3 batch files, 1 PowerShell script, and 2 Python scripts that work together to sync content from Obsidian, build the Zola site, and deploy to GitHub Pages.

---

## Configuration File: `paths.config`
**Location:** `C:\Projects\mrv\paths.config`

All scripts read from this single config file. Key paths:
- `OBSIDIAN_CONTENT_FOLDER` — Obsidian vault content source
- `OBSIDIAN_STATIC_FOLDER` — Obsidian vault static assets (images, etc.)
- `REPO_FOLDER` — Local git repository (C:\Projects\mrv)
- `CHARMERA_GALLERY_FOLDER` — Photo folder source
- `CHARMERA_INDEX_MD` — Gallery index location in Obsidian

---

## Batch Files (Windows Automation)

### 1. `runwebsite.bat` — Main Launcher
**Purpose:** Interactive menu for all website operations

**Usage:** Double-click or run `runwebsite.bat`

**Menu Options:**
```
1. Serve (local preview)
   - Syncs content from Obsidian
   - Syncs photos from Charmera
   - Starts Zola dev server with drafts enabled
   - Opens browser to http://127.0.0.1:1111

2. Build (build + manual commit)
   - Syncs all content from Obsidian and Charmera
   - Builds the Zola site
   - Updates last_update_to_site timestamp (only if .md files changed)
   - Builds site with Zola
   - Opens GitHub Desktop for manual review and commit

3. Auto-build (build + auto-commit)
   - Runs sync_from_obsidian.bat with --update_now flag
   - Automatically archives now.md to then.md if changed
   - Syncs from Charmera
   - Builds site
   - Auto-commits with message: "Auto - Content Update #N"
   - Auto-pushes to GitHub
   - Closes window after 2 seconds
```

**How it works:**
- Calls `builderserver.ps1` with `-serve`, `-build`, or `-auto` parameter
- Passes paths from `paths.config` to PowerShell
- Returns exit code to batch for menu flow

---

### 2. `sync_from_obsidian.bat` — Content Sync
**Purpose:** One-way sync from Obsidian vault to repository

**Usage:** 
```batch
sync_from_obsidian.bat           # Basic sync
sync_from_obsidian.bat --update_now  # Sync + archive now.md
```

**What it does:**
1. Reads OBSIDIAN_CONTENT_FOLDER and REPO_FOLDER from paths.config
2. Uses `robocopy` to mirror:
   - Obsidian content → zola/content/
   - Obsidian static → zola/static/
3. If `--update_now` flag: runs `now2then.py` before syncing

**Key note:** Uses `/MIR` (mirror) flag, so deleted files in Obsidian are deleted in repo too.

---

### 3. `sync_from_charmera.bat` — Gallery Photo Sync
**Purpose:** Sync Kodak Charmera photos and auto-generate gallery index

**Usage:**
```batch
sync_from_charmera.bat
```

**What it does:**
1. Reads CHARMERA_GALLERY_FOLDER from paths.config
2. Syncs photos to zola/static/charmera/
3. Runs `update_charmera_index.py` to auto-generate charmera/_index.md
4. Gallery index picks up all photos in the folder automatically

**Workflow:**
1. Drop new photos in CHARMERA_GALLERY_FOLDER
2. Run this batch
3. Photos + index are synced to repo
4. Next build includes new photos

---

## PowerShell Script: `builderserver.ps1` — Core Build Engine
**Location:** `C:\Projects\mrv\builderserver.ps1`

**Purpose:** Orchestrates syncing, building, and committing

**Three Modes:**

### Mode: `-serve`
```powershell
.\builderserver.ps1 -serve
```
1. Calls sync_from_charmera.bat
2. Calls sync_from_obsidian.bat
3. Builds with `zola build`
4. Starts `zola serve --drafts` in new window
5. Opens browser to http://127.0.0.1:1111

### Mode: `-build`
```powershell
.\builderserver.ps1 -build
```
1. Calls sync_from_charmera.bat
2. Calls sync_from_obsidian.bat
3. Detects which .md files changed (MD5 hash comparison)
4. If .md files changed: updates `last_update_to_site` timestamp in config.toml
5. Builds with `zola build`
6. Copies `zola/public/` → `zola/public/` (already built, so this is no-op)
7. Opens GitHub Desktop for manual commit/push review

**Use this when:** You want to review changes before committing

### Mode: `-auto`
```powershell
.\builderserver.ps1 -auto
```
Smart automation workflow:

1. **Detect now.md changes** (using MD5 file hashing):
   - Compares Obsidian now.md vs repo version
   - If different, runs `now2then.py` to archive old status
   - Syncs updated files

2. **Sync from Charmera** (photos + gallery index)

3. **Sync from Obsidian** (content + static files)

4. **Update timestamp**
   - Reads zola/config.toml
   - If .md files changed: updates `last_update_to_site` to current time

5. **Build site**
   - Runs `zola build`
   - Generates public/ folder

6. **Auto-commit**
   - Stages all changes
   - Creates commit: `Auto - Content Update #N`
   - N is auto-incremented from git log
   - Includes list of changed .md files in commit body

7. **Auto-push**
   - `git push origin main`
   - Pushes to GitHub immediately

8. **Auto-close**
   - Closes window after 2 seconds

**Use this when:** You want fully automated sync → build → commit → push

**Smart Feature:** Only archives now.md if it actually changed. Doesn't archive on every build.

---

## Python Scripts

### 1. `now2then.py` — Archive Now Status
**Location:** `C:\Projects\mrv\now2then.py`

**Purpose:** Archive current "now" status to "then" (history log)

**Usage:**
```bash
python now2then.py
```

**What it does:**
1. Reads OBSIDIAN_CONTENT_FOLDER from paths.config
2. Reads now.md from Obsidian vault
3. Extracts "place" field from frontmatter (location)
4. Creates backup: now_backup.md
5. Appends archival entry to then.md with:
   - Timestamp: `# <time>2026-05-15|14:30:45</time>`
   - Location: `in <place>München</place>`
   - All bullet points from now.md (preserving indentation)
   - Heading: "Back then, I was:"

**Output:**
```markdown
# <time>2026-05-15|14:30:45</time> in <place>München</place>
Back then, I was:
- Working on thesis
- Learning Zola
  - Deep diving into templating
```

**Called automatically by:**
- `sync_from_obsidian.bat --update_now`
- `builderserver.ps1 -auto` (if now.md changed)

**Note:** This script archives the *old* content before syncing the updated version.

---

### 2. `update_charmera_index.py` — Gallery Indexer
**Location:** `C:\Projects\mrv\update_charmera_index.py`

**Purpose:** Scan photo folder and generate gallery index automatically

**Usage:**
```bash
python update_charmera_index.py
```

**What it does:**
1. Reads CHARMERA_GALLERY_FOLDER from paths.config
2. Scans for images: .jpg, .jpeg, .png, .gif
3. Sorts alphabetically
4. Generates charmera/_index.md with:
   - Frontmatter with title, description, template
   - `[extra]` section with images array
   - Each image as `/charmera/{filename}`

**Output example:**
```markdown
+++
title = "Charmera Gallery"
description = "A selection of photos from my Kodak Charmera."
template = "gallery.html"

[extra]
images = [
    "/charmera/photo_001.jpg",
    "/charmera/photo_002.jpg",
]
+++
```

**Called automatically by:**
- `sync_from_charmera.bat`
- `builderserver.ps1 -serve`
- `builderserver.ps1 -auto`

**Workflow:**
1. Add new photos to CHARMERA_GALLERY_FOLDER
2. Run sync_from_charmera.bat (or use runwebsite.bat)
3. Index auto-generates
4. Next build includes new photos

---

## Typical Workflows

### Quick Local Preview
```batch
runwebsite.bat
[Choose 1: Serve]
# Edit in Obsidian, see changes live at http://localhost:1111
# Ctrl+C to stop server
```

### Manual Build & Review
```batch
runwebsite.bat
[Choose 2: Build]
# GitHub Desktop opens
# Review changes, write commit message
# Push manually when satisfied
```

### Fully Automated (Sync → Build → Commit → Push)
```batch
runwebsite.bat
[Choose 3: Auto-build]
# Runs to completion automatically
# Window closes after 2 seconds
```

Or directly:
```powershell
.\builderserver.ps1 -auto
```

### Add New Photos to Gallery
```batch
# 1. Copy photos to CHARMERA_GALLERY_FOLDER
# 2. Run:
sync_from_charmera.bat
# 3. Commit and push:
git add zola/static/charmera/ zola/content/charmera/_index.md
git commit -m "Add new gallery photos"
git push
```

### Archive Current Status
```bash
python now2then.py
sync_from_obsidian.bat
git add -A
git commit -m "Archive now to then"
git push
```

---

## Deployment & GitHub Actions

After any commit is pushed:

1. **Validate Zola Build** — Checks site builds correctly
2. **Build and Deploy to GitHub Pages** — Builds with Zola, uploads artifact
3. **pages-build-deployment** — GitHub's automatic Pages deployment

Site updates at **ribeirovidal.com** within 1-2 minutes.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **"paths.config not found"** | Create paths.config in C:\Projects\mrv with required variables |
| **Obsidian files not syncing** | Check OBSIDIAN_CONTENT_FOLDER path in paths.config exists |
| **Photos not showing in gallery** | Run sync_from_charmera.bat to regenerate index |
| **now.md timestamp not updating** | Manually update the `updated` field in now.md frontmatter (script doesn't do this automatically) |
| **Build errors in zola** | Run `zola build` in C:\Projects\mrv\zola to see detailed errors |
| **GitHub push fails** | Check git remote: `git remote -v` |

---

## Known Issues & Notes

**1. now.md timestamp issue:**
- The `now2then.py` script now automatically updates the `updated` field in now.md frontmatter
- User should update it manually only if needed for specific reasons

**2. Auto-increment counter:**
- The `-auto` mode increments "Auto - Content Update #N" by reading git log
- Detects existing auto-commit messages and increments the number

**3. Timestamp format:**
- now2then.py uses: `YYYY-MM-DD|HH:MM:SS` (pipe separator for display)
- Zola config uses: `YYYY-MM-DDTHH:MM:SS` (ISO 8601 format)
- Make sure format matches when manually editing

---

## Quick Reference Commands

```bash
# Local preview
zola serve --drafts

# Build production
cd C:\Projects\mrv\zola
zola build

# Sync operations
python now2then.py
sync_from_obsidian.bat
sync_from_charmera.bat

# Git operations
git status
git add -A
git commit -m "message"
git push origin main

# Full automation
.\builderserver.ps1 -auto

# List recent commits
git log --oneline -10
```

---

**Last Updated:** 2026-05-15
**Scripts Location:** C:\Projects\mrv\
**Repository:** MatheusRibeiroVidal/MatheusRibeiroVidal.github.io
