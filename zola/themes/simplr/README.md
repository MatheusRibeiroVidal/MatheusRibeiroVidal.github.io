# simplr

A clean, editorial Zola theme designed for MRV (ribeirovidal.com).

## Design philosophy

- Wide whitespace, generous line-height — readable prose first
- Serif body (Lora) + sans-serif headings (Inter) — distinct from Apollo's monospace-heavy aesthetic
- Warm parchment/charcoal palette instead of Apollo's frigid-white/jet-black
- Terracotta accent in light mode, amber in dark mode
- Headings are clean — no `# ## ###` prefix decoration
- Cards lift on hover; gallery uses a masonry column layout with lightbox
- Sticky top nav instead of Apollo's inline header-above-content layout

## Supported content types

- Blog posts (`section.html` list + `page.html` individual)
- Project cards (`cards.html`)
- Photo gallery with lightbox (`gallery.html`)
- Homepage with embedded "now" and "recommendations" sections
- Taxonomy (tag list + tag-filtered post list)
- 404 page
- Note and mermaid shortcodes (via project-level shortcodes)

## File structure

```
themes/simplr/
  theme.toml
  sass/
    main.scss            ← entry point (imported by Zola)
    theme/
      light.scss         ← light CSS custom properties
      dark.scss          ← dark CSS custom properties
    parts/
      _layout.scss
      _nav.scss
      _typography.scss
      _posts.scss
      _cards.scss
      _gallery.scss
      _code.scss
      _toc.scss
      _note.scss
      _images.scss
      _table.scss
      _search.scss
      _footer.scss
      _mermaid.scss
  templates/
    base.html
    homepage.html
    page.html
    section.html
    index.html
    cards.html
    gallery.html
    taxonomy_list.html
    taxonomy_single.html
    404.html
    macros/
      macros.html        ← same macro API as Apollo macros
    partials/
      head.html          ← <head> element
      nav.html           ← sticky top nav
      footer.html        ← site footer
```
