# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the source code for **ribeirovidal.com** — a personal website built with [Zola](https://www.getzola.org/), a static site generator. The site contains blog posts, projects, a photo gallery, and personal pages (about, now, recipes, etc.).

**Tech Stack:**
- Zola v0.17+ (static site generator)
- SCSS/SASS for styling (compiled to CSS)
- Tera templating (Zola's template engine)
- ElasticLunr for client-side search
- Theme: "simplr" (custom, can switch to "apollo_adapted")
- Deployment: GitHub Pages via GitHub Actions

## Key Architecture

### Directory Structure

```
mrv/ (repository root)
├── zola/                           # Main Zola project directory
│   ├── config.toml                 # Site configuration (theme, menu, analytics)
│   ├── content/                    # Markdown content (synced from Obsidian)
│   │   ├── _index.md              # Homepage
│   │   ├── posts/                 # Blog posts
│   │   ├── projects/              # Project portfolio
│   │   ├── recipes/, concerts/, recommendations/, charmera/, now/, then/
│   │   └── about.md
│   ├── static/                     # Static assets (images, icons, fonts)
│   │   └── charmera/              # Gallery photos (auto-synced)
│   ├── themes/
│   │   ├── simplr/                # Active custom theme
│   │   │   ├── sass/              # SCSS source (auto-compiled)
│   │   │   ├── templates/         # Tera templates (HTML)
│   │   │   └── static/            # Theme assets
│   │   └── apollo_adapted/        # Alternative theme (can switch)
│   └── public/                     # Build output (not committed)
├── builderserver.ps1              # PowerShell build orchestrator
├── watch_cv.ps1                   # CV file watcher (auto-sync to website)
├── runwebsite.bat                 # Interactive Windows menu
├── sync_from_obsidian.bat         # Sync content from Obsidian vault
├── sync_from_charmera.bat         # Sync gallery photos
├── now2then.py                    # Archive current "now" status to history
├── update_charmera_index.py       # Generate gallery index from photos
├── paths.config                   # Configuration file (paths to Obsidian, repo, photos)
├── .claude/references/AUTOMATION.md  # Detailed automation reference
└── .github/workflows/
    ├── zola.yml                   # Validates Zola builds on push
    └── deploy.yml                 # Builds and deploys to GitHub Pages
```

### Content Workflow

1. **Content source:** Markdown files in Obsidian vault
2. **Sync to repo:** `sync_from_obsidian.bat` mirrors to `zola/content/`
3. **Local preview:** `zola serve --drafts` with hot-reload
4. **Build & deploy:** `zola build` outputs to `zola/public/`, then copied to `docs/` (GitHub Pages)
5. **Gallery workflow:** Photos in Charmera folder → `sync_from_charmera.bat` → photos synced to `zola/static/charmera/` and index auto-generated
6. **Status archival:** `now2then.py` archives current "now" status to "then" history with timestamp and location

### Theme System

- **Active theme:** `zola/themes/simplr/` (referenced in `zola/config.toml`)
- **Alternative theme:** `zola/themes/apollo_adapted/`
- **To switch themes:** Edit `zola/config.toml` line 1: `theme = "simplr"` → change to `"apollo_adapted"` or another theme
- **Styling:** SCSS files in `sass/` auto-compile to CSS; edit `sass/theme/light.scss` and `sass/theme/dark.scss` for colors
- **Templates:** HTML templates in `templates/` (Tera syntax)
- **Typography & layout:** Edit `sass/parts/_typography.scss` and `sass/parts/_layout.scss`

### Configuration

**zola/config.toml** controls:
- `theme` — Active theme name
- `base_url` — Published domain (https://ribeirovidal.com/)
- `title`, `description` — Site metadata
- `menu` — Top navigation links (weight controls order)
- `contextual_menu` — Hidden section links (recipes, charmera, concerts, now, then, recommendations)
- `socials` — Footer social links
- `compile_sass = true` — Auto-compile SCSS
- `minify_html = true` — Production optimization
- `last_update_to_site` — Timestamp (auto-updated by build scripts)
- Analytics settings (GoatCounter, Umami)

**paths.config** (not in repo, local only):
- `OBSIDIAN_CONTENT_FOLDER` — Path to Obsidian vault content source
- `OBSIDIAN_STATIC_FOLDER` — Path to Obsidian vault static assets
- `REPO_FOLDER` — Path to this repo
- `CHARMERA_GALLERY_FOLDER` — Path to photo folder
- `CHARMERA_INDEX_MD` — Path to charmera/_index.md in Obsidian
- `CV_SOURCE` — Path to your CV file (used by `watch_cv.ps1`)

## Common Commands

### Local Development

```bash
# Preview site locally with hot-reload (includes draft posts)
cd zola
zola serve --drafts

# Then visit http://localhost:1111
```

### Building

```bash
# Production build
cd zola
zola build

# Output appears in zola/public/
```

### Windows Automation (Recommended for full workflow)

```batch
# Interactive menu with all options
runwebsite.bat

# Or directly via PowerShell:
.\builderserver.ps1 -serve   # Local preview with auto-sync
.\builderserver.ps1 -build   # Build + manual commit review
.\builderserver.ps1 -auto    # Full automation: sync → build → commit → push

# Start CV file watcher (run in separate PowerShell window)
.\watch_cv.ps1              # Monitor CV file and auto-sync to website
```

### Python Utility Scripts

```bash
# Archive current "now" status to "then" (history)
python now2then.py

# Generate gallery index from photos in CHARMERA_GALLERY_FOLDER
python update_charmera_index.py

# One-way sync from Obsidian vault to repo
sync_from_obsidian.bat           # Basic sync
sync_from_obsidian.bat --update_now  # Sync + archive now.md

# Sync gallery photos and regenerate index
sync_from_charmera.bat
```

### Git Operations

```bash
# View recent commits
git log --oneline -10

# Check status and build changes
git status
git diff

# Manual commit and push
git add -A
git commit -m "Description of changes"
git push origin main
```

## Deployment

GitHub Actions runs on every push to `main`:

1. **zola.yml** — Validates that site builds correctly
2. **deploy.yml** — Builds site with `zola build` and deploys `zola/public/` to GitHub Pages

Site updates at **https://ribeirovidal.com/** within 1-2 minutes after push.

## Content Frontmatter

All markdown files use TOML frontmatter:

```toml
+++
title = "Page Title"
description = "Short description for SEO"
date = 2026-05-15
updated = 2026-05-15

[taxonomies]
tags = ["tag1", "tag2"]   # For blog posts only

draft = false             # Set to true to hide from published site
+++

# Markdown content below
```

## Special Content Pages

- **now.md** — Current status/what you're doing (updated regularly, then archived)
- **then.md** — History of past "now" statuses (auto-populated by `now2then.py`)
- **charmera/_index.md** — Gallery with `template = "gallery.html"` and `images = [...]` array (auto-generated)
- **recipes/, concerts/, recommendations/** — Custom content sections (not in main menu, accessible via contextual_menu)

## Key Files to Know

| File | Purpose |
|------|---------|
| `zola/config.toml` | Site configuration (theme, menu, analytics) |
| `zola/themes/simplr/` | Active theme directory |
| `zola/content/` | All markdown content |
| `builderserver.ps1` | Core build orchestration script |
| `now2then.py` | Archive "now" to "then" with timestamp |
| `update_charmera_index.py` | Auto-generate gallery index |
| `.claude/references/AUTOMATION.md` | Detailed automation reference |
| `.github/workflows/` | CI/CD pipeline configurations |

## Theme Customization

### Switch Themes

Edit `zola/config.toml` line 1:
```toml
theme = "simplr"          # Current
# or
theme = "apollo_adapted"  # Alternative
```

Then test locally with `zola serve` and push to deploy.

### Customize Colors

In active theme directory (e.g., `zola/themes/simplr/`):

```scss
// sass/theme/light.scss
--primary-color: #your-color;
--bg-0: #background;
--text-0: #foreground;
```

### Edit Templates

Tera templates in `zola/themes/[theme]/templates/`:
- `base.html` — Base layout
- `page.html` — Single page template
- `section.html` — Section (posts, projects) listing
- `partials/` — Reusable components (nav, footer, etc.)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Site won't build | Run `cd zola && zola build` to see detailed errors |
| Content not syncing | Verify `paths.config` exists with correct Obsidian paths; check `OBSIDIAN_CONTENT_FOLDER` exists |
| Photos not in gallery | Run `python update_charmera_index.py` and `sync_from_charmera.bat` to regenerate index |
| Theme not switching | Restart `zola serve` after editing `config.toml`; clear browser cache |
| GitHub Pages not updating | Check GitHub Actions workflows in `.github/workflows/` for build errors |

## Related References

- [Zola Documentation](https://www.getzola.org/)
- [Tera Template Docs](https://tera.netlify.app/)
- `.claude/references/AUTOMATION.md` — In-depth automation workflow guide
