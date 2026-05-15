---
name: project-mrv-modern-theme
description: Architecture and key styling facts about the mrv-modern Zola theme located at C:\Projects\mrv\zola\themes\mrv-modern\
metadata:
  type: project
---

The site uses the mrv-modern Zola theme at `C:\Projects\mrv\zola\themes\mrv-modern\`.

Key SCSS layout facts:
- Entry point: `sass/main.scss` — imports all partials in order
- Breakpoints defined in `sass/parts/_layout.scss`: `$bp-sm: 480px`, `$bp-md: 640px`, `$bp-lg: 900px`, `$bp-xl: 1100px`
- Content column max-width: 780px (`content-wrap`); wide variant 1100px (`content-wrap--wide` used by cards/gallery pages)
- `.card` elements live in `sass/parts/_cards.scss`; cards macro in `templates/macros/macros.html` (`cards_posts`)
- Profile picture uses `.profile-pic` / `.profile-pic-container` in `sass/parts/_images.scss`; currently set to 320x320px (doubled from original 160px)
- Gallery uses CSS `columns` (masonry) in `sass/parts/_gallery.scss`: 3 cols → 2 at 800px → 1 at 480px
- Nav hides social icons at ≤520px and wraps links to a second row

**Why:** Provides fast orientation for future frontend work on this theme.
**How to apply:** Use these paths and class names directly when making style or template changes.
