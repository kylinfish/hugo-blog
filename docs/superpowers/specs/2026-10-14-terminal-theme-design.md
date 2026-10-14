# Terminal Theme Redesign — Design Spec

Date: 2026-10-14
Status: Approved in chat, pending spec review

## Goal

Replace the LoveIt theme with a custom, lightweight Hugo theme styled after the
author's own terminal setup (iTerm2 + oh-my-posh powerline, One Dark palette,
SauceCodePro Nerd Font). Page structure is inspired by
https://www.charles-hsiao.com/ (terminal hero, traceroute career timeline,
compact post list).

Success = every existing page renders under the new theme with no broken
shortcodes, URLs unchanged, and the site reads like a terminal session.

## Decisions (from brainstorming)

| Topic | Decision |
|---|---|
| Scope | Custom theme, LoveIt removed from the build |
| Features kept | TOC, code copy button |
| Features dropped | Site search, comments (Disqus/FB), share buttons, GA (UA id is dead) |
| Palette | Tokyo Night default; 4 switchable schemes (amended 2026-10-14, see below) |
| Homepage blocks | `whoami` + `traceroute career`, latest posts, 造物誌 projects |

## 1. Architecture

- Theme lives at `themes/terminal/`; `config.toml` sets `theme = "terminal"`.
  Rollback = set it back to `"LoveIt"`.
- `.gitignore` currently ignores `themes/`. Change to `themes/*` plus
  `!themes/terminal/` so the new theme is versioned while LoveIt stays a clone.
- Plain CSS (`themes/terminal/static/css/terminal.css`) and one small vanilla
  JS file (`themes/terminal/static/js/terminal.js`). No SCSS, no npm. Must
  build on Hugo v0.101.0 (current local version).
- Root-level overrides `layouts/_default/about.html`, `static/css/about.css`
  and `assets/css/_custom.scss` are LoveIt-specific: about.html is rewritten
  for the new theme, `_custom.scss` is deleted.
- Config cleanup: remove LoveIt-only `[params.*]` blocks (comment, share,
  analytics, header.typeit, etc.). Keep `[menu.main]`, `[permalinks]`,
  `[outputs]`, `[markup]`, social params, author.

### Compatibility contract

| Content feature | Usage | Handling |
|---|---|---|
| `admonition` shortcode | ~110 uses, types: note, notice, info, tip, success, question, warning, danger, example, summary, primary | Reimplement in theme; positional and `type=` forms; optional title arg; open/close arg accepted |
| `link` shortcode | 3 uses | Reimplement (href, content, title) |
| `highlight`, `figure`, `youtube` | Hugo built-ins | No change |
| `featuredImage` front matter | 58 posts | Shown at top of post and as og:image |
| `description` front matter | 56 posts | Used as summary + meta description |
| `toc` front matter | 6 posts | `toc: false` hides TOC |
| Permalinks `/:filename` | all posts | Unchanged |
| Outputs HTML/RSS/JSON | home | RSS + index.json kept (JSON kept for llms / future use) |
| `static/baseline.html`, `static/llms.txt` | standalone | Untouched |

Implementation must grep the LoveIt shortcode sources for exact argument
signatures before reimplementing.

## 2. Visual Language

- Palette (CSS custom properties on `:root`):
  bg `#282c34`, bg-alt `#21252b`, fg `#abb2bf`, comment `#5c6370`,
  blue `#61afef`, purple `#c678dd`, green `#98c379`, yellow `#e5c07b`,
  red `#e06c75`, cyan `#56b6c2`, orange `#d19a66`.
- Fonts: Source Code Pro (Google Fonts) for UI chrome, headings, code.
  Post body text uses the system CJK stack (`"PingFang TC", "Noto Sans TC",
  sans-serif`) for long-read comfort.
- Header: powerline prompt bar — segments ` win ` (blue) → current path
  e.g. `~/posts/<slug>` (purple) → site name `墨冊` (bg-alt). Segments act as
  breadcrumbs. Arrow via CSS clip-path (no Nerd Font dependency).
- Nav: menu items rendered as `cd posts/`, `cd tags/`, … from `[menu.main]`.
- Admonitions: log-level label `[INFO]`, `[WARN]`, `[TIP]`, `[ERR]`… with a
  colored left border; color per type mapped onto the palette.
- Code blocks: Chroma classes with a One Dark stylesheet; copy button top-right
  (`copy` → `copied!`).
- Responsive: single column on mobile (16px gutter, no horizontal scroll); TOC
  collapses into a `<details>` above the article under 1024px.

## 3. Pages

### Homepage (`index.html`)
1. `$ whoami` — avatar, name, subtitle ("筆墨日積終將成冊，知識月累便可結果"),
   social links (GitHub, LinkedIn, Twitter, Email, RSS).
2. `$ traceroute career` — hops from new `data/career.yaml`
   (`year`, `org`, `role`, `current: bool`). Seeded from about.md; author
   fills the rest. Last hop links `→ about`.
3. `$ ls -lt posts/ | head -8` — 8 latest posts: date · tags · title ·
   description. Footer link `ls posts/ →`.
4. `$ ls ~/projects` — posts in category 造物誌 (up to 6).

### Post (`single.html`)
- `$ cat <slug>.md` line, title, meta segment bar (date, reading time,
  categories, tags), featuredImage, content, right-side TOC styled like
  `tree`, prev/next as `cd ../<prev>`.

### Lists (`list.html`, `terms.html`, `taxonomy`)
- `/posts/`: grouped by year, `ls -l` style rows, paginated.
- `/tags/`, `/categories/`: term list with counts, like `ls | wc -l` output.
- Term pages reuse the post row partial.

### Others
- About: keep content of `content/about.md`, restyle with new theme.
- 404: `zsh: command not found: <path>` with link home.
- Footer: `© 2017–{{now.Year}} Win Yu · exit 0`.

## Out of Scope

Search, comments, share buttons, analytics, light mode, Hugo upgrade, content
edits (other than seeding `data/career.yaml`).

## Verification

- `hugo` builds with zero errors/warnings about missing shortcodes/templates.
- Spot check: home, `/posts/`, `/tags/`, one post per admonition type, a post
  with `link` shortcode, a post with `toc: false`, about, 404.
- Compare `public/` URL list before vs after: no removed post URLs.
- Mobile width (375px) screenshot of home and a post.

## Amendment 2026-10-14 — color schemes

Supersedes "dark mode only". Four schemes, defined once in
`themes/terminal/data/colorschemes.json` and rendered to CSS custom properties
by `assets/css/themes.css` (a Hugo template):

- dark: tokyonight (default), rose-pine (onedark and catppuccin-mocha dropped by the author)
- light: catppuccin-latte (default when the system prefers light), rose-pine-dawn

First visit follows `prefers-color-scheme`; a manual pick is saved in
localStorage (`theme`), and `auto` returns to following the system. An inline
head script sets `data-theme` before CSS paints (no flash); without JS the CSS
falls back to tokyonight / latte via the media query.

Switching: a powerline `◐ <scheme> ▾` segment in the header opens a listbox,
and pressing `:` opens a vim-style command line (`:colorscheme <name>`,
`:colo`, Tab completion, `E185` / `E492` errors).

Light-scheme accents are darkened where needed so every text token reaches
4.5:1 on the background (`scripts/check-contrast.py`).
