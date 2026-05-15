---
name: zola-theme-manager
description: Manage, customize, and switch Zola themes on ribeirovidal.com. Use this skill when the user wants to change the site's look, switch between themes (simplr/apollo_adapted), customize colors/typography/layouts, create new themes, test themes locally, or troubleshoot theme issues. Include this whenever the user mentions theme changes, design updates, styling, or "how do I switch themes".
compatibility: Requires Zola project at C:\Projects\mrv\zola with themes in zola/themes/
---

# Zola Theme Manager

Manage, customize, and deploy themes for your Zola site. This skill helps you switch between themes, customize appearance, test locally, and deploy changes.

## Quick Actions

### 1. Switch Theme

To switch between **simplr** (current) and **apollo_adapted** (alternative):

**Step 1: Change config**
```bash
cd C:\Projects\mrv\zola
# Edit config.toml and change:
theme = "simplr"        # or "apollo_adapted"
```

**Step 2: Test locally**
```bash
zola serve
# Visit http://localhost:1111 to preview
```

**Step 3: Deploy**
```bash
# Exit zola serve (Ctrl+C)
git add zola/config.toml
git commit -m "Switch theme to [theme-name]"
git push
# GitHub Actions automatically deploys
```

### 2. Customize Colors

Colors are defined in theme SASS files. Location depends on active theme:

**For simplr theme:**
- Light mode: `zola/themes/simplr/sass/theme/light.scss`
- Dark mode: `zola/themes/simplr/sass/theme/dark.scss`

**For apollo_adapted theme:**
- Light mode: `zola/themes/apollo_adapted/sass/theme/light.scss`
- Dark mode: `zola/themes/apollo_adapted/sass/theme/dark.scss`

**Example: Change primary accent color**

In light.scss, find:
```scss
--primary-color: #d85a3d;  /* terracotta */
```

Change to your desired color (hex format):
```scss
--primary-color: #e67e50;  /* new terracotta */
```

Then test locally with `zola serve` — changes appear instantly with hot-reload.

**Common colors in your themes:**
- `--primary-color` — Main accent (buttons, links, highlights)
- `--bg-0`, `--bg-1`, `--bg-2` — Background layers (primary, secondary, tertiary)
- `--text-0`, `--text-1` — Text colors (primary, muted)
- `--border-color` — Element borders

### 3. Customize Typography

Typography is in: `sass/parts/_typography.scss` for each theme.

**Change font family:**
```scss
$body-font: "Lora";           /* body text */
$heading-font: "Inter";       /* headings */
$mono-font: "Monaco";         /* code blocks */
```

**Change font sizes:**
```scss
$font-size-base: 1rem;
$font-size-lg: 1.125rem;
$font-size-xl: 1.25rem;
```

**Change line height:**
```scss
$line-height-body: 1.6;      /* body text spacing */
$line-height-heading: 1.2;   /* heading spacing */
```

### 4. Customize Layouts

Main layout controls are in: `sass/parts/_layout.scss`

**Change container width:**
```scss
$container-width: 900px;      /* max width of content */
```

**Change breakpoints (mobile/tablet/desktop):**
```scss
$breakpoint-mobile: 600px;
$breakpoint-tablet: 1200px;
$breakpoint-desktop: 1400px;
```

**Change spacing/padding:**
```scss
$spacing-base: 1rem;          /* base unit */
$padding-container: 2rem;     /* container padding */
$gap-section: 3rem;           /* space between sections */
```

### 5. Test Theme Locally

```bash
cd C:\Projects\mrv\zola
zola serve
```

The site rebuilds automatically as you:
- Edit content (Markdown files)
- Modify templates (HTML)
- Change SASS/CSS
- Update config.toml

Visit `http://localhost:1111` and refresh your browser to see changes.

**Test on different screen sizes:**
- Open DevTools (F12)
- Toggle device toolbar to test mobile/tablet layouts
- Check breakpoints: 600px (mobile), 1200px (desktop)

### 6. Customize Components

Components are individual UI elements: cards, navigation, buttons, galleries, etc. Each lives in its own SASS file.

**Navigation/Header Styling**

File: `sass/parts/_header.scss` and `sass/parts/_nav.scss`

Common customizations:
```scss
/* Change nav background */
.site-header {
  background-color: var(--bg-1);
  padding: 1rem 0;
}

/* Style nav links */
.nav-link {
  color: var(--text-0);
  border-bottom: 2px solid transparent;
  transition: all 0.2s ease;
  
  &:hover {
    border-bottom-color: var(--primary-color);
  }
}

/* Active link styling */
.nav-link.active {
  color: var(--primary-color);
  font-weight: 600;
}
```

Test with `zola serve` — navigation changes appear instantly.

**Card Styling**

File: `sass/parts/_cards.scss`

Cards are used for projects, post previews, etc.

```scss
.card {
  background: var(--bg-0);
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.card-title {
  font-size: 1.25rem;
  color: var(--text-0);
  margin-bottom: 0.5rem;
}

.card-description {
  color: var(--text-1);
  font-size: 0.95rem;
  line-height: 1.5;
}
```

**Gallery Styling**

File: `sass/parts/_gallery.scss`

For your Charmera photo gallery:

```scss
.gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1.5rem;
}

.gallery-item {
  position: relative;
  overflow: hidden;
  border-radius: 8px;
  background: var(--bg-1);
}

.gallery-item img {
  width: 100%;
  height: 250px;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.gallery-item:hover img {
  transform: scale(1.05);
}
```

**Button Styling**

File: `sass/parts/_misc.scss` or create `sass/parts/_buttons.scss`

```scss
.btn {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  background: var(--primary-color);
  color: white;
  border-radius: 4px;
  text-decoration: none;
  transition: all 0.2s ease;
  border: none;
  cursor: pointer;
  font-weight: 500;
}

.btn:hover {
  background: var(--primary-color);
  filter: brightness(0.9);
  transform: translateY(-2px);
}

.btn-secondary {
  background: var(--bg-1);
  color: var(--text-0);
  border: 1px solid var(--border-color);
}
```

**Code Block Styling**

File: `sass/parts/_code.scss`

```scss
pre {
  background: var(--bg-1);
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  border-left: 3px solid var(--primary-color);
}

code {
  font-family: "Monaco", monospace;
  font-size: 0.9rem;
  line-height: 1.4;
}

/* Inline code */
p code, li code {
  background: var(--bg-1);
  padding: 0.2rem 0.4rem;
  border-radius: 3px;
  color: var(--primary-color);
}
```

**Testing Component Changes**

After editing any component:
1. Run `zola serve`
2. Navigate to a page using that component (e.g., `/projects` for cards, `/charmera` for gallery)
3. Refresh and verify changes appear
4. Test hover states and interactions in browser DevTools

### 7. Create and Use Custom Shortcodes

Shortcodes are reusable content blocks you can use in Markdown. Create them in your template files and reference them in content.

**Where to Create Shortcodes**

File: `templates/shortcodes/` for each theme

Your site already has examples:
- `note.html` — Highlighted note blocks
- `mermaid.html` — Mermaid diagrams

**Example 1: Create a "Callout" Shortcode**

Create file: `zola/themes/simplr/templates/shortcodes/callout.html`

```html
<div class="callout callout-{{ type }}">
  <div class="callout-icon">
    {% if type == "warning" %}
      ⚠️
    {% elif type == "info" %}
      ℹ️
    {% elif type == "success" %}
      ✅
    {% else %}
      💡
    {% endif %}
  </div>
  <div class="callout-content">
    {{ body | safe }}
  </div>
</div>
```

Style in `sass/parts/_misc.scss`:

```scss
.callout {
  padding: 1rem 1.5rem;
  border-left: 4px solid var(--primary-color);
  border-radius: 4px;
  margin: 1.5rem 0;
  background: rgba(var(--primary-color-rgb), 0.05);
}

.callout-warning {
  border-color: #f59e0b;
  background: rgba(245, 158, 11, 0.05);
}

.callout-info {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.05);
}

.callout-success {
  border-color: #10b981;
  background: rgba(16, 185, 129, 0.05);
}

.callout-icon {
  font-size: 1.5rem;
  margin-right: 0.75rem;
  display: inline-block;
}

.callout-content {
  display: inline-block;
  vertical-align: middle;
}
```

**Use in Markdown:**

```markdown
{% callout(type="warning") %}
This is a warning message that stands out.
{% end %}

{% callout(type="info") %}
Here's some helpful information.
{% end %}
```

**Example 2: Create a "Card Grid" Shortcode**

For displaying multiple items in a grid:

Create file: `zola/themes/simplr/templates/shortcodes/card-grid.html`

```html
<div class="card-grid">
  {{ body | safe }}
</div>
```

Style:

```scss
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}
```

**Use:**

```markdown
{% card_grid() %}
  Your card HTML here, or nested content
{% end %}
```

**Example 3: Create a "Highlight" Shortcode**

For emphasizing text with background color:

Create file: `zola/themes/simplr/templates/shortcodes/highlight.html`

```html
<mark class="highlight highlight-{{ color | default(value='default') }}">
  {{ body | safe }}
</mark>
```

Style:

```scss
.highlight {
  padding: 0.2rem 0.4rem;
  border-radius: 3px;
  background: var(--primary-color);
  color: white;
  font-weight: 500;
}

.highlight-yellow {
  background: #fbbf24;
  color: #1f2937;
}

.highlight-green {
  background: #10b981;
  color: white;
}

.highlight-red {
  background: #ef4444;
  color: white;
}
```

**Use:**

```markdown
This is {% highlight(color="yellow") %}very important{% end %} text.
```

**Example 4: Create a "Stats" Shortcode**

For displaying metrics or numbers:

Create file: `zola/themes/simplr/templates/shortcodes/stats.html`

```html
<div class="stats-grid">
  <div class="stat">
    <div class="stat-value">{{ number }}</div>
    <div class="stat-label">{{ label }}</div>
  </div>
</div>
```

Style:

```scss
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.stat {
  text-align: center;
  padding: 1.5rem;
  background: var(--bg-1);
  border-radius: 8px;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.stat-label {
  color: var(--text-1);
  font-size: 0.95rem;
}
```

**How to Create Your Own Shortcode**

1. **Create the HTML file:**
   - Location: `zola/themes/[theme-name]/templates/shortcodes/[name].html`
   - File name becomes the shortcode name (e.g., `timeline.html` → `{% timeline() %}`)

2. **Access variables passed to it:**
   - Use `{{ body | safe }}` for the content inside the tags
   - Use `{{ param_name }}` for named parameters
   - Example: `{% my_shortcode(type="warning", icon="✓") %}`

3. **Style it:**
   - Add CSS/SCSS to an appropriate `sass/parts/` file
   - Reference component classes like `.my-shortcode`, `.my-shortcode-title`, etc.

4. **Test it:**
   - Run `zola serve`
   - Use it in a Markdown file
   - Refresh browser to see changes

5. **Common Shortcode Parameters:**
   ```html
   <!-- Optional parameter with default -->
   {% shortcode_name(type="default") %}
   Content here
   {% end %}

   <!-- Required parameter -->
   {% shortcode_name(title="My Title") %}
   Content here
   {% end %}

   <!-- Multiple parameters -->
   {% shortcode_name(type="warning", icon="⚠️", dismissible="true") %}
   Content here
   {% end %}
   ```

### 6. Create a Theme Variation

To create a new theme based on an existing one:

**Step 1: Copy existing theme**
```bash
cd C:\Projects\mrv\zola\themes
cp -r simplr my-new-theme
```

**Step 2: Update theme metadata**
Edit `my-new-theme/theme.toml`:
```toml
name = "my-new-theme"
description = "My custom theme based on simplr"
```

**Step 3: Customize**
Edit SASS files in `my-new-theme/sass/` for colors, typography, layouts.

**Step 4: Test and deploy**
```bash
# In zola/config.toml, change:
theme = "my-new-theme"

# Test locally:
zola serve

# Deploy when ready:
git add -A
git commit -m "Create new theme: my-new-theme"
git push
```

## File Structure

Understanding your theme directory helps with customization:

```
zola/themes/[theme-name]/
├── sass/                          # SASS source files
│   ├── theme/
│   │   ├── light.scss            # Light mode colors
│   │   └── dark.scss             # Dark mode colors
│   ├── parts/
│   │   ├── _typography.scss      # Font settings
│   │   ├── _layout.scss          # Container/spacing
│   │   ├── _header.scss          # Navigation styling
│   │   ├── _nav.scss             # Nav menu
│   │   ├── _cards.scss           # Card components
│   │   └── [other parts]
│   └── main.scss                 # Imports all parts
├── templates/                     # HTML templates
│   ├── base.html                 # Base layout
│   ├── page.html                 # Single pages
│   ├── section.html              # Category pages
│   ├── index.html                # List pages
│   ├── homepage.html             # Home page
│   └── partials/                 # Reusable HTML snippets
│       ├── header.html
│       └── nav.html
├── static/                        # Theme assets
│   ├── js/                        # JavaScript files
│   ├── css/                       # Compiled CSS (auto-generated)
│   └── fonts/                     # Font files
└── theme.toml                     # Theme metadata
```

## Common Customization Workflows

### Scenario 1: Change Theme Colors Globally

1. Identify which CSS variables control color
2. Edit `sass/theme/light.scss` and `sass/theme/dark.scss`
3. Test with `zola serve` (hot-reload rebuilds instantly)
4. Commit and push

### Scenario 2: Adjust Spacing/Margins

1. Edit `sass/parts/_layout.scss`
2. Modify `$spacing-base`, `$padding-container`, `$gap-section`
3. Test responsiveness on mobile/tablet/desktop
4. Deploy

### Scenario 3: Change Typography

1. Edit `sass/parts/_typography.scss`
2. Update font families or sizes
3. Ensure fonts are loaded (check `sass/fonts.scss`)
4. Test readability and line-height
5. Deploy

### Scenario 4: Create a New Theme from Scratch

1. Copy simplr: `cp -r simplr new-theme`
2. Update `theme.toml`
3. Modify all SASS files for your design
4. Create/modify templates as needed
5. Test thoroughly locally
6. Switch in config.toml and deploy

## Deployment

All theme changes are automatically deployed via GitHub Actions:

1. **Edit theme files locally**
2. **Test with `zola serve`**
3. **Commit changes:**
   ```bash
   git add zola/themes/[theme-name]/ zola/config.toml
   git commit -m "Customize [theme-name] theme: [what changed]"
   git push
   ```
4. **GitHub Actions triggers:**
   - `Validate Zola Build` — Checks build succeeds
   - `Build and Deploy to GitHub Pages` — Builds with Zola and uploads
   - `pages-build-deployment` — Deploys to GitHub Pages
5. **Site updates at ribeirovidal.com within 1-2 minutes**

## Troubleshooting

**Build fails after theme changes:**
- Check for SASS syntax errors (missing colons, braces)
- Ensure all variables are defined before use
- Run `zola build` in `C:\Projects\mrv\zola\` to see error details

**Changes don't appear locally:**
- Hard refresh browser (Ctrl+Shift+R)
- Check that `zola serve` is still running
- Verify you edited the correct theme (check `config.toml` for active theme)

**Theme looks broken:**
- Check that all font files exist in `static/fonts/`
- Verify CSS is loading (check DevTools Network tab)
- Ensure template files haven't been corrupted

**Can't switch themes:**
- Make sure theme folder exists in `zola/themes/`
- Check spelling of theme name in `config.toml`
- Run `zola build` to catch config errors

## Your Current Themes

**simplr** (current, production)
- Location: `zola/themes/simplr/`
- Status: Actively used on ribeirovidal.com
- Colors: Terracotta (light), Amber (dark)
- Typography: Lora (body), Inter (headings), Monaco (code)

**apollo_adapted** (alternative, customized)
- Location: `zola/themes/apollo_adapted/`
- Status: Available for quick switching
- Customized from original Apollo theme
- Can be activated by changing `config.toml`

Both themes are fully functional and can be deployed immediately by switching in config.toml.
