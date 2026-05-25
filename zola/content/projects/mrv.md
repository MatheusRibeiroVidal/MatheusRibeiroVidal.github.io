+++
title = "ribeirovidal.com"
description = "This website is built with GitHub pages, Zola, and its contents are sourced from inside an Obsidian vault. The source files are available in the repo"
weight = 6
date = "2025-03-20"
authors = ["Matheus"]

[taxonomies]
tags=["EN", "Web Dev", "Zola", "Obsidian", "Open Source", "GitHub Pages"]
[extra]
local_image = "/media/mrv.gif"
link_to = "https://github.com/MatheusRibeiroVidal/MatheusRibeiroVidal.github.io"
comment = false
banner = true
+++

# Links
- [Live site: ribeirovidal.com](https://ribeirovidal.com)
- [GitHub repo](https://github.com/MatheusRibeiroVidal/MatheusRibeiroVidal.github.io)

# ribeirovidal.com

*A personal website built with Zola, written in Obsidian, and deployed on GitHub Pages*

This is the website you are reading right now. It is a clean, editorial personal site for projects, blog posts, a photo gallery and assorted corners of my life. Content lives in an Obsidian vault, gets synced into a Zola project by custom Python scripts, and is built and published automatically through GitHub Actions.

---

## The Idea

I wanted a single place to write and publish without fighting the tooling. The constraint was simple: writing should happen in Obsidian, where I already keep my notes, and publishing should be automatic. Everything else, the theme, the build, the deploy, is built around keeping that authoring experience friction-free while the public site stays fast and static.

---

## The Stack

The site is a fully static build with no server-side runtime:

- **Static site generator**, [Zola](https://www.getzola.org/) (v0.17+), chosen for being a single fast binary with no plugin ecosystem to maintain.
- **Templating**, Tera, Zola's built-in template engine.
- **Styling**, SCSS/SASS compiled to CSS at build time, with minified HTML output.
- **Search**, client-side full-text search via ElasticLunr, so search works without a backend.
- **Code highlighting**, Syntect with the Ayu Light theme.
- **Markdown**, CommonMark extended with custom shortcodes (toggleable notes, fancy code blocks, MathJax).
- **Analytics**, GoatCounter, a privacy-focused, cookie-free option.

---

## Design

The site uses a custom Zola theme called **simplr**, built from scratch with readability as the first priority:

- Generous whitespace and line-height, with a serif body (Lora) paired with sans-serif headings (Inter).
- A warm, earthy palette: terracotta accent in light mode, amber in dark mode, with a light/dark toggle.
- Interactive touches like cards that lift on hover, sticky navigation, and a masonry gallery with a lightbox.
- Mobile-first responsive layouts.

The visual direction took inspiration from Rutar's personal site.

---

## Content Workflow

Because content is authored in Obsidian and the site is a separate Zola project, a set of Python and shell scripts bridges the two:

- **Sync scripts** copy the vault's `content` and `static` folders into the repo, driven by a local `paths.config` file so machine-specific paths never get committed.
- **`now2then.py`**, archives my current "now" page into a timestamped "then" history log, pulling the location from the page's frontmatter and backing up the original before editing.
- **`update_charmera_index.py`**, scans my Kodak Charmera photo folder and regenerates the gallery index page automatically, so adding photos does not mean hand-editing markdown.

This keeps the authoring loop inside Obsidian while the repo only ever sees clean, build-ready content.

---

## Build & Deploy

Publishing is fully automated through **GitHub Actions**. On every push to `main` (or a manual trigger), the workflow installs Zola, runs `zola build`, and deploys the generated `public/` directory to **GitHub Pages**. The result is that writing a note and pushing is all it takes for the live site to update.

---

## Key Takeaways

- A static Zola site keeps the public page fast and dependency-light while costing almost nothing to host.
- Custom sync scripts let me keep writing in Obsidian without ever touching the build internals.
- A push-to-deploy pipeline removes the last bit of manual work between drafting and publishing.

