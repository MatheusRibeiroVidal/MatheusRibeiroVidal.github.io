---
name: project-mrv-site
description: ribeirovidal.com personal site built with Zola; mrv-modern is the ACTIVE theme as of 2026-05; old Apollo overrides moved to sass_current/ and templates_current/
metadata:
  type: project
---

Site is a Zola static site at `zola/`. The **active theme is `mrv-modern`** (`theme = "mrv-modern"` at top of config.toml). Apollo was the previous theme.

**Key architecture (current):**
- Theme source: `zola/themes/mrv-modern/` — all edits to styling and templates go here.
- Sass: `zola/themes/mrv-modern/sass/` (entry: `main.scss`; parts in `parts/`; theme vars in `theme/light.scss` and `theme/dark.scss`).
- Templates: `zola/themes/mrv-modern/templates/` (nav: `partials/nav.html`; base: `base.html`; etc.)
- Old Apollo overrides are preserved in `zola/sass_current/` and `zola/templates_current/` (untracked, not compiled).
- No root-level `zola/sass/` or `zola/templates/` directories exist — theme is the sole source.

**Active design tokens (mrv-modern):**
- Light: bg `#f9f7f4` (parchment), primary `#c0392b` (terracotta/deep red)
- Dark: bg `#141414` (near-black), primary `#e6a817` (amber/gold)
- Both exposed as CSS var `--primary-color`
- Body: "Lora" serif; UI/headings: "Inter"; Code: "JetBrains Mono"
- Nav: sticky top bar, `.nav-link` class on menu links, `.nav-brand` on logo

**Nav link active state:**
- Template marks current section with `aria-current="page"` and class `active`
- Active/hover style: accent `--primary-color` text + 2px bottom border + subtle tinted bg

**Content types:**
- Homepage, posts section, individual pages, projects (cards), gallery (/charmera), taxonomy pages (tags), special pages (now.md, about.md, etc.)

**Why:** mrv-modern was a full redesign replacing Apollo. Old files in `*_current/` dirs are backups/reference only.
**How to apply:** All frontend changes go into `zola/themes/mrv-modern/`. Never touch `sass_current/` or `templates_current/` for live edits.
