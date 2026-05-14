# Macros Documentation — `zola/templates/macros/macros.html`

All macros live in the `post_macros` namespace. Call them with `post_macros::<macro_name>(...)`.

---

## `list_tag_posts(pages, tag_name=false)`

**Definition**
Renders a page header followed by the full post list. If `tag_name` is provided it shows "Entries tagged :: `<tag>`", otherwise it shows "All articles". Internally delegates to `list_posts`.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `pages` | yes | Array of page objects to display |
| `tag_name` | no (default `false`) | Tag string to show in the header |

**Usage**
```jinja
{{ post_macros::list_tag_posts(pages=section.pages) }}
{{ post_macros::list_tag_posts(pages=section.pages, tag_name="rust") }}
```

**Example output (with tag)**
```html
<div class="page-header">Entries tagged :: rust<span class="primary-color" style="font-size:1.6em">.</span></div>
<main class="list">
  <!-- post list -->
</main>
```

---

## `list_posts(pages)`

**Definition**
Renders an unordered list of posts. Each item shows the date, title (linked), an optional DRAFT badge, an optional Archive label, a description or summary excerpt, and a "Read more" link.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `pages` | yes | Array of page objects |

**Usage**
```jinja
{{ post_macros::list_posts(pages=section.pages) }}
```

**Front-matter fields read**
| Field | Effect |
|---|---|
| `page.date` | Shown as `YYYY-MM-DD` |
| `page.draft` | Shows a `DRAFT` badge |
| `page.extra.archive` | Shows an `[Archive]` label |
| `page.description` | Preferred description text |
| `page.summary` | Fallback if no description (truncated with `…`) |

**Example output (single item)**
```html
<li class="list-item">
  <section>
    <div class="post-header">
      <time>2024-03-01</time>
      <div>
        <h1 class="title"><a href="/blog/my-post/">My Post</a></h1>
        <div class="meta">
          <div class="description">A short description.</div>
          <a class="readmore" href="/blog/my-post/">Read more ⟶</a>
        </div>
      </div>
    </div>
  </section>
</li>
```

---

## `list_terms(terms)`

**Definition**
Renders an unordered list of taxonomy terms (e.g. tags, categories). Each item is a linked term name.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `terms` | yes | Array of taxonomy term objects (each has `.name` and `.permalink`) |

**Usage**
```jinja
{{ post_macros::list_terms(terms=terms) }}
```

**Example output**
```html
<ul>
  <section class="list-item">
    <h1 class="title"><a href="/tags/rust/">rust</a></h1>
  </section>
  <section class="list-item">
    <h1 class="title"><a href="/tags/python/">python</a></h1>
  </section>
</ul>
```

---

## `tags(page, short=false)`

**Definition**
Renders an inline tag list for a page. Shows nothing if the page has no tags. In normal mode it prepends ":: tags:" and separates tags with a space; in short mode it prepends "::" and separates with commas.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `page` | yes | A page object with `page.taxonomies.tags` and `page.lang` |
| `short` | no (default `false`) | If `true`, uses compact formatting |

**Usage**
```jinja
{{ post_macros::tags(page=page) }}
{{ post_macros::tags(page=page, short=true) }}
```

**Example output (normal)**
```html
<span class="post-tags-inline">
  :: tags:&nbsp;<a class="post-tag" href="/tags/rust/">#rust</a>&nbsp;
  <a class="post-tag" href="/tags/zola/">#zola</a>
</span>
```

**Example output (short)**
```html
<span class="post-tags-inline">
  :: <a class="post-tag" href="/tags/rust/">#rust</a>,
  <a class="post-tag" href="/tags/zola/">#zola</a>
</span>
```

---

## `page_header(title)`

**Definition**
Renders a simple page header `<div>` with a styled period at the end (uses `.primary-color`).

**Parameters**
| Param | Required | Description |
|---|---|---|
| `title` | yes | String to display as the heading |

**Usage**
```jinja
{{ post_macros::page_header(title="About") }}
{{ post_macros::page_header(title=page.title) }}
```

**Example output**
```html
<div class="page-header">
    About<span class="primary-color" style="font-size: 1.6em">.</span>
</div>
```

---

## `home_page(section)`

**Definition**
Renders the full homepage layout. Hardcodes three sections:
1. **Intro** — the section title + content from the `_index.md` of the section passed in.
2. **Now** — loaded from `now.md`, shows title, last-updated timestamp, place, and content.
3. **Recommendations** — loaded from `recommendations.md`, shows title and content.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `section` | yes | The current section object (typically the root `_index.md`) |

**Pages loaded internally**
- `now.md` — must exist; uses `now_page.extra.place` and `now_page.updated`
- `recommendations.md` — must exist

**Usage**
```jinja
{{ post_macros::home_page(section=section) }}
```

**Example output (simplified)**
```html
<main>
  <article>
    <section class="body">
      <section id="intro" class="homepage-spacing">
        <div class="page-header">Home<span ...>.</span></div>
        <!-- section.content -->
        <hr>
      </section>
      <section id="now" class="homepage-spacing">
        <h1>What I'm doing now</h1>
        <div class="alt-meta">Updated on <time>2024-03-01|12:00</time> in <place>Lisbon</place></div>
        <!-- now_page.content -->
        <hr>
      </section>
      <section id="recommendations" class="homepage-spacing">
        <h1>Recommendations</h1>
        <!-- recs_page.content -->
      </section>
    </section>
  </article>
</main>
```

---

## `content(page)`

**Definition**
Renders the full single-page layout. This is the most feature-rich macro. It handles:

- Page header via `page_header`
- Archive label, post date, updated date, place
- Reading time, word count
- Cuisine, dish type, prepare time, portions (recipe fields)
- Inline tag list
- GitHub source link (via `repo_view` / `repo_url`)
- DRAFT badge
- `tl;dr` block
- Banner image with local/fallback path logic
- Optional table of contents (up to h3 depth)
- Page body content

**Parameters**
| Param | Required | Description |
|---|---|---|
| `page` | yes | A full page object |

**Key front-matter / extra fields read**
| Field | Effect |
|---|---|
| `page.extra.archive` | Shows `[Archive]` label, adjusts date format |
| `page.extra.place` | Shows "in `<place>`" after the date |
| `page.extra.read_time` | Shows estimated reading time |
| `page.extra.show_word_count` | Defaults to `true`; set to `false` to hide word count |
| `page.extra.cuisine` | Recipe cuisine type |
| `page.extra.dish_type` | Recipe dish type |
| `page.extra.prepare_time` | Recipe prep time in minutes |
| `page.extra.portions` | Recipe portion count |
| `page.extra.repo_view` | Enable source link (falls back to `config.extra.repo_view`) |
| `page.extra.repo_url` | Page-level repo URL (falls back to `config.extra.repo_url`) |
| `page.extra.tldr` | Renders a `tl;dr` summary box |
| `page.extra.banner` | If `true`, renders a banner image |
| `page.extra.local_image` | Path for the banner image |
| `page.extra.image_base` | Override the auto-derived image filename |
| `page.extra.toc` | Set to `true` to show the table of contents |
| `config.extra.toc` | Global toggle; page-level `toc` is only checked when this is `true` |

**Usage**
```jinja
{{ post_macros::content(page=page) }}
```

---

## `cards_posts(pages)`

**Definition**
Renders a card grid of posts. Each card shows an image (local, remote, or a placeholder), the post title (linked), metadata (date, draft badge, recipe info), and a description.

**Parameters**
| Param | Required | Description |
|---|---|---|
| `pages` | yes | Array of page objects |

**Image resolution order**
1. `page.extra.local_image` — resolved via `get_url()`
2. `page.extra.remote_image` — used as a direct `src`
3. Neither set — renders a `<div class="card-image-placeholder">`

**Link resolution**
- If `page.extra.link_to` is defined, the title links there (for external projects).
- Otherwise links to `page.permalink`.

**Usage**
```jinja
{{ post_macros::cards_posts(pages=section.pages) }}
```

**Example output (single card)**
```html
<div class="cards">
  <div class="card">
    <img class="card-image" alt="My Project" src="/media/project.png" />
    <div class="card-info">
      <h1 class="card-title"><a href="https://github.com/me/project">My Project</a></h1>
      <div class="meta">
        <time>2024-03-01</time>
        Italian :: Pasta :: 20 min to prepare :: 2 portions
      </div>
      <div class="card-description">A short description.</div>
    </div>
  </div>
</div>
```

---

## `show_now()`

**Definition**
Minimal widget that loads `now.md` and renders its content inside a `<section id="now">`. Useful for embedding the "now" page content anywhere without the full homepage layout.

**Parameters**
None.

**Usage**
```jinja
{{ post_macros::show_now() }}
```

**Example output**
```html
<section id="now">
  <h1>Now</h1>
  <!-- now_page.content -->
</section>
```

---

## Quick Reference

| Macro | Purpose |
|---|---|
| `list_tag_posts` | Header + post list, optionally filtered by tag |
| `list_posts` | Raw `<ul>` list of posts |
| `list_terms` | `<ul>` list of taxonomy terms |
| `tags` | Inline tag pills for a page |
| `page_header` | Styled title heading with a period accent |
| `home_page` | Full homepage (intro + now + recommendations) |
| `content` | Full single-page article with all metadata |
| `cards_posts` | Card grid of posts with images |
| `show_now` | Embed the "now" page content as a widget |
