# 🌐 www.ribeirovidal.com

A clean, editorial personal website showcasing projects, blog posts, gallery, and more. Built with [Zola](https://www.getzola.org/) and a custom modern theme.

Visit the live site: **[ribeirovidal.com](https://ribeirovidal.com)**

## 📖 Overview

This is the source code for Matheus Ribeiro Vidal's personal website — a space to share thoughts, projects, interests, and experiences. Content is written in Obsidian and synced to the website using custom Python scripts and Zola.

The site features:

- **Posts** — Blog articles on various topics
- **Projects** — Portfolio of completed work and research
- **About** — Personal information and background
- **Search** — Full-text search across all content
- **Dark/Light Themes** — Toggle between color schemes

## 🎨 Design & Theme

The site uses a custom Zola theme called **simplr**, built from scratch with focus on:

- **Readability first** — Generous whitespace, proper line-height, serif body text (Lora) with sans-serif headings (Inter)
- **Warm color palette** — Terracotta accent in light mode, amber in dark mode (inspired by earthy, parchment tones)
- **Interactive elements** — Cards lift on hover, sticky navigation, masonry gallery with lightbox
- **Responsive design** — Mobile-first approach working across all device sizes
- **Performance** — Minified HTML, SASS compilation, optimized assets

The design draws inspiration from [Rutar's personal site](https://rutar.org/).

## 🛠️ Tech Stack

- **Static Site Generator** — [Zola](https://www.getzola.org/) v0.17+
- **Styling** — SCSS/SASS (compiled to CSS)
- **Templating** — Tera (Zola's template engine)
- **Search** — ElasticLunr (client-side full-text search)
- **Analytics** — GoatCounter (privacy-focused)
- **Code Highlighting** — Syntect (Ayu Light theme)
- **Markdown** — CommonMark with custom shortcodes

## 🐍 Content Workflow with Python Scripts

This project uses custom Python scripts to streamline content management in Obsidian. These scripts help synchronize content between your Obsidian vault and the website, and automate gallery indexing.

### Configuration (paths.config)

Before running any scripts, create or update `paths.config` in the project root:

```ini
# paths.config
OBSIDIAN_CONTENT_FOLDER=/path/to/obsidian/vault/content
OBSIDIAN_STATIC_FOLDER=/path/to/obsidian/vault/static
REPO_FOLDER=/path/to/mrv/repo
CHARMERA_GALLERY_FOLDER=/path/to/photo/folder
CHARMERA_INDEX_MD=/path/to/obsidian/vault/content/charmera/_index.md
```

### Script 1: `now2then.py` — Archive Now Page to History

Automatically archives your current "now" status to a "then" history log.

**What it does:**
- Reads the current `now.md` file from your Obsidian vault
- Extracts the location from the frontmatter (`place` field)
- Archives the bullet points with a timestamped heading to `then.md`
- Creates a backup of `now.md` before making changes

**Usage:**

```bash
python now2then.py
```

**Example workflow:**

Your `now.md` might look like:
```markdown
+++
title = "Now"
place = "São Paulo, Brazil"
+++

- Working on website redesign
- Reading about machine learning
- Learning to cook better
```

After running the script, `then.md` gets:
```markdown
+++
title = "Then"
+++

---

# <time>2026-05-15|14:30:45</time> in <place>São Paulo, Brazil</place>
Back then, I was:
- Working on website redesign
- Reading about machine learning
- Learning to cook better
```

The `place` variable defaults to "Hiding" if not found in frontmatter.

### Script 2: `update_charmera_index.py` — Auto-Index Gallery Photos

Automatically generates the gallery index from your Kodak Charmera photo folder.

**What it does:**
- Scans your Charmera photo folder for images (.jpg, .jpeg, .png, .gif)
- Generates the Zola gallery template with relative paths to all images
- Updates `charmera/_index.md` with the gallery configuration

**Usage:**

```bash
python update_charmera_index.py
```

**How it works:**

It creates a `_index.md` file like:
```markdown
+++
title = "Charmera Gallery"
description = "A selection of photos from my Kodak Charmera."
template = "gallery.html"

[extra]
images = [
    "/charmera/photo_001.jpg",
    "/charmera/photo_002.jpg",
    "/charmera/photo_003.jpg",
]
+++
```

Just drop new photos into your `CHARMERA_GALLERY_FOLDER` and run this script to update the index.

## 🤖 Automation with Batch & PowerShell Scripts

Windows automation scripts handle syncing, building, and deploying the site. All scripts read from `paths.config` for system-specific paths.

### Script 1: `runwebsite.bat` — Main Launcher

Interactive menu for all website operations. Double-click to run.

**Menu options:**

1. **Serve (local preview)** 
   - Syncs content from Obsidian and Charmera
   - Starts Zola dev server with drafts enabled
   - Opens browser to `http://127.0.0.1:1111`

2. **Build (build + manual commit)**
   - Syncs all content
   - Builds the site with Zola
   - Updates `last_update_to_site` timestamp in config
   - Copies `public/` to `docs/` folder
   - Opens GitHub Desktop for manual commit/push

3. **Auto-build (build + auto-commit)**
   - Syncs all content with smart `now.md` detection
   - If `now.md` changed, automatically archives it to `then.md`
   - Builds the site
   - Auto-commits with message: `Auto - Content Update #N`
   - Auto-pushes to GitHub
   - Closes automatically after 2 seconds

### Script 2: `sync_from_obsidian.bat` — Obsidian Sync

One-way sync from Obsidian vault to repository.

**What it does:**
- Reads paths from `paths.config`
- Syncs `OBSIDIAN_CONTENT_FOLDER` → `zola/content/`
- Syncs `OBSIDIAN_STATIC_FOLDER` → `zola/static/`
- Validates all paths exist before syncing
- Uses `robocopy` for fast, efficient file mirroring

**Usage:**

```batch
REM Basic sync
sync_from_obsidian.bat

REM Sync AND archive now.md to then.md
sync_from_obsidian.bat --update_now
```

**The `--update_now` flag:**
- Runs `now2then.py` BEFORE syncing
- Archives current "now" status to history
- Then syncs the updated `then.md` to the repository
- Used automatically in auto-build mode

### Script 3: `sync_from_charmera.bat` — Gallery Photo Sync

Syncs Kodak Charmera photos and auto-generates gallery index.

**What it does:**
- Reads paths from `paths.config`
- Syncs photos from `CHARMERA_GALLERY_FOLDER` → `zola/static/charmera/`
- Runs `update_charmera_index.py` to generate `charmera/_index.md`
- Validates folders exist before syncing
- Creates missing folders if needed

**Usage:**

```batch
sync_from_charmera.bat
```

**Workflow:**
1. Add new photos to your Charmera folder
2. Run this script
3. Photos are copied to the site's static folder
4. Gallery index is auto-generated with all photo paths

### Script 4: `builderserver.ps1` — Build Engine (PowerShell)

Core build logic orchestrating syncs, builds, and commits. Called by `runwebsite.bat`.

**Three modes:**

#### `-serve` Mode (Local Development)
```powershell
.\builderserver.ps1 -serve
```
- Syncs from Charmera
- Syncs from Obsidian
- Builds with Zola
- Starts `zola serve --drafts` in new window
- Opens browser automatically

#### `-build` Mode (Manual Commit)
```powershell
.\builderserver.ps1 -build
```
- Syncs from Charmera
- Syncs from Obsidian
- Detects which .md files changed
- Updates `last_update_to_site` timestamp if .md files modified
- Builds with Zola
- Copies `public/` → `docs/` (for GitHub Pages)
- Opens GitHub Desktop for manual review & commit
- **No auto-push** (manual control over what gets committed)

#### `-auto` Mode (Fully Automated)
```powershell
.\builderserver.ps1 -auto
```

Smart automation workflow:
1. **Detects `now.md` changes** using MD5 file hashing
   - Compares Obsidian version vs repo version
   - If different, runs `now2then.py` to archive the old status
2. **Syncs from Charmera** (photos + gallery index)
3. **Syncs from Obsidian** (content + static files)
4. **Updates timestamp** — Sets `last_update_to_site` if .md files changed
5. **Builds site** — Runs `zola build`
6. **Copies to docs folder** — `public/` → `docs/` (GitHub Pages)
7. **Auto-commits** — Creates commit with message: `Auto - Content Update #N`
   - Includes list of changed .md files in commit body
   - Increments counter based on git log
8. **Auto-pushes** — Pushes to remote immediately
9. **Auto-closes** — Closes after 2 seconds

**Key feature:** Smart `now.md` detection means archiving only happens when you actually update your current status, not on every build.

### Typical Workflow Examples

#### Quick Local Development
```batch
runwebsite.bat
[Choose option 1: Serve]
# Site opens at http://localhost:1111
# Edit in Obsidian, see changes live
# Ctrl+C to stop server
```

#### Manual Build & Review
```batch
runwebsite.bat
[Choose option 2: Build]
# Site builds and GitHub Desktop opens
# Review changes, write commit message
# Push manually
```

#### Fully Automated Update
```batch
runwebsite.bat
[Choose option 3: Auto-build]
# Everything builds, commits, and pushes automatically
# Window closes when done
```

Or via command line:
```powershell
.\builderserver.ps1 -auto
```

Or from Task Scheduler for scheduled updates:
```batch
runwebsite.bat auto
```

### Path Configuration

All scripts read from `paths.config`:

```ini
OBSIDIAN_CONTENT_FOLDER=C:\Users\[user]\Documents\Obsidian\MRVcom\website\content
OBSIDIAN_STATIC_FOLDER=C:\Users\[user]\Documents\Obsidian\MRVcom\website\static
REPO_FOLDER=C:\Projects\mrv
CHARMERA_GALLERY_FOLDER=C:\Users\[user]\Pictures\KodakCharmera\to_upload
CHARMERA_INDEX_MD=C:\Users\[user]\Documents\Obsidian\MRVcom\website\content\charmera\_index.md
```

Update these paths to match your system before running any scripts.

### Obsidian Integration Tips

The scripts expect your Obsidian vault to have this structure:

```
Obsidian Vault/
├── MRVcom/
│   └── website/
│       ├── content/          # Referenced by OBSIDIAN_CONTENT_FOLDER
│       │   ├── posts/
│       │   ├── projects/
│       │   ├── charmera/
│       │   ├── now.md
│       │   ├── then.md
│       │   └── ...
│       └── static/           # Referenced by OBSIDIAN_STATIC_FOLDER
```

## 🚀 Getting Started

### Prerequisites

- [Zola](https://www.getzola.org/documentation/getting-started/installation/) (v0.17 or later)
- Python 3.7+ (for the automation scripts)

### Installation

```bash
# Clone the repository
git clone https://github.com/MatheusRibeiroVidal/mrv.git
cd mrv

# Navigate to the Zola directory
cd zola

# Serve locally with hot-reload
zola serve

# The site will be available at http://localhost:1111
```

### Building for Production

```bash
cd zola
zola build

# Output will be in the `public` directory
```

## 📁 Project Structure

```
mrv/ (GitHub repository)
├── zola/                           # Zola project root
│   ├── config.toml                 # Site configuration
│   ├── content/                    # Content (synced from Obsidian)
│   │   ├── _index.md               # Homepage
│   │   ├── about.md                # About page
│   │   ├── posts/                  # Blog posts
│   │   ├── projects/               # Project portfolio
│   │   └── [other content]         # Additional content managed via Obsidian
│   ├── static/                     # Static assets (images, icons, fonts)
│   ├── themes/
│   │   └── simplr/             # Custom theme
│   │       ├── sass/               # Style source files
│   │       ├── templates/          # HTML templates
│   │       ├── static/             # Theme static assets
│   │       └── theme.toml          # Theme metadata
│   ├── sass_current/               # Backup/working SASS files
│   ├── templates_current/          # Backup/working template files
│   └── public/                     # Built site output (not committed)
├── now2then.py                     # Archive "now" status to history
├── update_charmera_index.py        # Auto-index gallery photos
├── paths.config                    # Configuration for Python scripts
└── README.md                       # This file

# Separate Obsidian Vault (local, not in repo)
Obsidian Vault/
├── MRVcom/website/
│   ├── content/                    # Source for zola/content/
│   │   └── [synced to GitHub repo]
│   └── static/                     # Source for zola/static/
└── Photos/
    └── KodakCharmera/pics/to_mrv/  # Photo source for gallery
```

**Note:** The Obsidian vault is kept separate from the Git repository and synced manually or via the Python scripts.

## ✍️ Adding Content

### Creating a Blog Post

```bash
# Create a new post in zola/content/posts/
# File: zola/content/posts/my-new-post.md

+++
title = "My New Post"
description = "A brief description"
date = 2026-05-15
updated = 2026-05-15

[taxonomies]
tags = ["tag1", "tag2"]
+++

# Your content here

Your markdown content goes here...
```

### Creating a Project

```bash
# File: zola/content/projects/my-project.md

+++
title = "My Project"
description = "What this project is about"
date = 2026-05-15
updated = 2026-05-15
+++

# Your content here
```

## 🎨 Customization

### Site Configuration

Edit `zola/config.toml` to customize:

- `title` — Site title
- `description` — Site tagline
- `base_url` — Published domain
- `menu` — Navigation links (weight controls order)
- `socials` — Social media links in footer
- `theme` — Color scheme (`light`, `dark`, `auto`, `toggle`)
- Analytics settings (GoatCounter, Umami)

### Quick Theme Switching

To switch between available themes:

1. **Available themes** — Located in `zola/themes/`:
   - `simplr/` — Current production theme
   - `apollo_adapted/` — Alternative Apollo theme (customized version)

2. **Switch theme**:
   ```bash
   # Edit zola/config.toml
   theme = "simplr"        # Change this to your desired theme
   # or
   theme = "apollo_adapted"
   ```

3. **Test locally**:
   ```bash
   cd zola
   zola serve
   # Visit http://localhost:1111 to preview
   ```

4. **Deploy**:
   ```bash
   cd zola
   zola build
   git add -A
   git commit -m "Switch theme to [theme-name]"
   git push
   # GitHub Actions automatically builds and deploys to GitHub Pages
   ```

**Note:** Switching themes will update the entire site appearance. Test locally first before pushing to production.

### Theme Customization

The active theme is in `zola/themes/[theme-name]/`:

#### Colors

Edit `sass/theme/light.scss` and `sass/theme/dark.scss`:
- `--primary-color` — Main accent (terracotta/amber)
- `--bg-0`, `--bg-1`, `--bg-2` — Background layers
- `--text-0`, `--text-1` — Text colors

#### Typography

Edit `sass/parts/_typography.scss`:
- Font families (Lora, Inter, Monaco)
- Font sizes and weights
- Line height and spacing

#### Layouts

Edit `sass/parts/_layout.scss` for:
- Container widths
- Breakpoints for responsive design
- Grid/flexbox layouts

### Navigation Styling

The top navigation bar is in `templates/partials/nav.html`. Section buttons highlight in the accent color on hover/active states with a bottom border and subtle background tint.

### Date Formatting

- **Project pages**: Show date only (YYYY-MM-DD) for posted/updated dates
- **Now page**: Shows full timestamp (YYYY-MM-DD HH:MM:SS) for updates
- Edit `templates/macros/macros.html` to change formats

## 📚 Content Development Workflow

The typical workflow for adding/updating content:

1. **Write in Obsidian** — Edit content in your Obsidian vault at `OBSIDIAN_CONTENT_FOLDER`
2. **Run sync scripts** — Execute Python scripts to sync and process content
3. **Preview locally** — Use `zola serve` to see changes live at `http://localhost:1111`
4. **Deploy** — Commit and push to publish changes

### Quick Workflow Example

```bash
# 1. Write or edit content in Obsidian (automatic sync via folders)

# 2. Update gallery from new Charmera photos
python update_charmera_index.py

# 3. Archive old "now" status to history (when ready to move on)
python now2then.py

# 4. Preview locally
cd zola && zola serve

# 5. Commit and push when satisfied
git add -A
git commit -m "Content update: new posts and gallery photos"
git push
```

## 🔧 Development

### Live Development with Hot-Reload

```bash
cd zola
zola serve
```

The site rebuilds automatically when you:
- Edit content files
- Modify templates
- Update SASS files
- Change `config.toml`

### Building Static Assets

SASS files are automatically compiled to CSS. No separate build step needed.

### Testing Locally

Visit `http://localhost:1111` to see all pages:
- Homepage: `/`
- Blog posts: `/posts`
- Projects: `/projects`
- About: `/about`
- Now: `/now`
- Tags: `/tags`
- Search: Built-in site search

## 📱 Responsive Design

The site is fully responsive with breakpoints for:
- Mobile (< 600px)
- Tablet (600px - 1200px)
- Desktop (> 1200px)

All components adapt gracefully to different screen sizes.

## 🔍 Search

Full-text search is enabled and indexes:
- Page titles
- Descriptions
- Content
- URLs

Search is client-side using ElasticLunr — no backend needed.

## 📊 Analytics

The site uses GoatCounter for privacy-focused analytics. Configure in `config.toml` under `[extra.analytics.goatcounter]`.

## 🚢 Deployment

The site is designed for static hosting (GitHub Pages, Netlify, Vercel, etc.):

1. Build with `zola build` (creates `zola/public/`)
2. Deploy the `public/` directory to your host
3. No server-side rendering or databases needed

## 📝 Content Frontmatter

All content files use TOML frontmatter:

```toml
+++
title = "Page Title"
description = "Short description for SEO"
date = 2026-05-15        # Publication date (YYYY-MM-DD)
updated = 2026-05-15     # Update date (optional)

[taxonomies]
tags = ["tag1", "tag2"]   # For blog posts

# Optional fields:
draft = false             # Hide from published site
template = "page.html"    # Override template
+++
```

## 🎯 Shortcodes

Available custom shortcodes:

### Note

```
{% note() %}
This is a highlighted note block.
{% end %}
```

### Mermaid Diagrams

```
{% mermaid() %}
graph TD
    A --> B
{% end %}
```

## 🔗 Connect

- **Email** — matheus@ribeirovidal.com
- **GitHub** — [@MatheusRibeiroVidal](https://github.com/MatheusRibeiroVidal)
- **LinkedIn** — [matheusribeirovidal](https://www.linkedin.com/in/matheusribeirovidal)
- **Instagram** — [@theusvid](https://www.instagram.com/theusvid/)
- **Itch.io** — [churrogelato](https://churrogelato.itch.io/)
- **ORCID** — [0009-0009-2651-461X](https://orcid.org/0009-0009-2651-461X)

## 📜 License

This project uses a **dual licensing model**:

### Website Content — CC BY-SA 4.0
All written content (blog posts, project descriptions, etc.) on the website is licensed under the [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/) license.

**What this means:**
- ✅ **You can** share, adapt, and build upon the content
- ✅ **You must** give credit to Matheus Ribeiro Vidal
- ✅ **You must** license your contributions under the same CC BY-SA 4.0 license
- ✅ **You can** use it commercially

### Theme Code — MIT License
The `simplr` Zola theme is licensed under the [MIT License](https://opensource.org/licenses/MIT).

**What this means:**
- ✅ **You can** use, modify, and distribute the theme code
- ✅ **You can** use it commercially
- ✅ **You must** include the original license and copyright notice
- ✅ **No warranty** is provided

### Other Assets
- **Icons** — Various open-source icon sets (see individual LICENSE files in `zola/static/icons/`)
- **Base theme inspiration** — [Apollo theme](https://github.com/not-matthias/apollo) by not-matthias (MIT licensed)

Feel free to use this project as inspiration for your own website, and refer to the appropriate license for what you're using!

## 🙏 Credits

- **Theme inspiration** — [Rutar.org](https://rutar.org/)
- **Base theme** — [Apollo](https://github.com/not-matthias/apollo) by [not-matthias](https://github.com/not-matthias)
- **Static site generator** — [Zola](https://www.getzola.org/)
- **Icons** — Various open-source icon sets
