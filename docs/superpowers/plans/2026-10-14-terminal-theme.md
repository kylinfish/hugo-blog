# Terminal Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace LoveIt with a custom One Dark / powerline terminal theme at `themes/terminal/`, keeping every post URL and shortcode working.

**Architecture:** A self-contained Hugo theme (Go templates + plain CSS + one vanilla JS file) bundled with Hugo Pipes (concat → minify → fingerprint). A shell script `scripts/check-theme.sh` builds the site into a temp dir and greps the output; every task adds assertions to it before writing templates (red → green).

**Tech Stack:** Hugo v0.101.0 (local, non-extended is fine — no SCSS), Go templates, CSS custom properties, vanilla JS, Google Fonts (Source Code Pro).

**Spec:** `docs/superpowers/specs/2026-10-14-terminal-theme-design.md`

## Global Constraints

- Must build on Hugo v0.101.0 — no features newer than that (no `hugo.toml`, no `.Site.Params` renames, no `css.Sass` dart).
- No npm, no SCSS, no build step besides `hugo`.
- Palette: bg `#282c34`, bg-alt `#21252b`, fg `#abb2bf`, comment `#5c6370`, blue `#61afef`, purple `#c678dd`, green `#98c379`, yellow `#e5c07b`, red `#e06c75`, cyan `#56b6c2`, orange `#d19a66`. Dark only.
- Fonts: Source Code Pro for UI/code/headings; post body uses `"PingFang TC","Noto Sans TC","Microsoft JhengHei",system-ui,sans-serif`.
- Post permalinks stay `/:filename/`. RSS + `index.json` stay.
- `static/baseline.html`, `static/llms.txt`, `firebase.json`, `workers/` are not touched.
- Dropped: search, comments, share buttons, analytics, light mode.
- Do not stage `content/about.md` (author has an uncommitted edit there).
- Mobile: 16px side gutter, no horizontal page scroll at 375px.

## Review Focus

1. **Year-long CSS cache** — `firebase.json` serves `**/*.css` with `max-age=31536000`. Unfingerprinted CSS would leave returning visitors on a stale stylesheet. Pinned by Task 1 assertion `css/bundle.min.<hash>.css`.
2. **CJK heading anchors in the TOC** — `a.hash` for Chinese headings is percent-encoded while `id` is not; the active-section highlight must `decodeURIComponent`. Pinned in Task 2 JS + assertion that the TOC links carry `#` anchors.
3. **Admonition argument forms** — positional with/without title, `type=` named form, an unquoted multi-word title (`{{< admonition summary 文章系列>}}`), an `open` arg of `false`. Pinned by Task 1 assertions on three real posts.
4. **Posts with no headings / `toc:` given as a map** (`toc: {enable: true, auto: true}`) — must not crash or render an empty TOC. Pinned by Task 2 assertions on `lumen_tinker` (no headings) and `mailquill-gmail-statements-to-ledger` (map form).
5. **Long CJK titles and remote `featuredImage` URLs on mobile** — rows must wrap, images must not overflow. Checked visually in Task 5 at 375px.

Known, out of scope: `firebase.json` rewrites `** → /index.html`, so production never serves the 404 page. Task 4 still builds it.

---

## File Map

```
themes/terminal/
  theme.toml
  assets/css/terminal.css      base, header, footer, list rows, admonitions
  assets/css/post.css          article, TOC, code, chroma One Dark
  assets/css/home.css          whoami, traceroute, projects
  assets/js/terminal.js        code copy + TOC active highlight
  layouts/_default/baseof.html
  layouts/_default/single.html post page
  layouts/_default/list.html   sections + term pages
  layouts/_default/terms.html  /tags/, /categories/
  layouts/page/single.html     root pages (about)
  layouts/index.html           homepage
  layouts/index.json           JSON output for home
  layouts/404.html
  layouts/partials/head.html
  layouts/partials/header.html powerline bar + nav
  layouts/partials/footer.html
  layouts/partials/post-row.html
  layouts/partials/pager.html
  layouts/shortcodes/admonition.html
  layouts/shortcodes/link.html
data/career.yaml               traceroute hops (root data dir)
scripts/check-theme.sh         build + assertions
config.toml                    rewritten
.gitignore                     themes/* + !themes/terminal/
deleted: layouts/_default/about.html, static/css/about.css, assets/css/_custom.scss
```

---

### Task 1: Theme skeleton that builds every page

**Files:**
- Create: `scripts/check-theme.sh`, `themes/terminal/theme.toml`, all files under `themes/terminal/layouts/` except `index.html` (minimal here, full in Task 3), `_default/single.html` (minimal here, full in Task 2), `page/single.html` and `404.html` (Task 4)
- Create: `themes/terminal/assets/css/terminal.css`, empty `post.css`, empty `home.css`, stub `assets/js/terminal.js`
- Modify: `config.toml` (full rewrite), `.gitignore`

**Interfaces:**
- Produces: partial `post-row.html` (context: a Page), partial `pager.html` (context: a Pager), CSS classes `.wrap .prompt-line .cmd .pl .pl-seg .rows .row .tags .tag .more .page-title .count .year .terms .pager .adm .adm-<type>`, site params `site.Params.subtitle`, `site.Params.avatar`, `site.Params.since`, `site.Params.social.{github,linkedin,twitter,email}`.
- `scripts/check-theme.sh` contains a line `# --- assertions above this line ---`; later tasks insert their blocks directly above it.

- [ ] **Step 1: Write the check script (the failing test)**

`scripts/check-theme.sh`:

```bash
#!/usr/bin/env bash
# Build the site into a temp dir and assert the terminal theme renders.
set -uo pipefail
cd "$(dirname "$0")/.."
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
FAILS=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; FAILS=$((FAILS + 1)); }
has()   { if grep -qE -- "$2" "$OUT/$1" 2>/dev/null; then pass "$1 has $2"; else fail "$1 has $2"; fi; }
lacks() { if grep -qE -- "$2" "$OUT/$1" 2>/dev/null; then fail "$1 lacks $2"; else pass "$1 lacks $2"; fi; }

echo "== build"
if ! LOG="$(hugo -d "$OUT" 2>&1)"; then echo "$LOG"; echo "BUILD FAILED"; exit 1; fi
if echo "$LOG" | grep -E 'ERROR|found no layout'; then fail "build log clean"; else pass "build log clean"; fi

echo "== post urls"
missing=0
for f in content/posts/*.md; do
  grep -qE '^draft *[:=] *true' "$f" && continue
  slug="$(basename "$f" .md)"
  [ -f "$OUT/$slug/index.html" ] || { fail "missing /$slug/"; missing=$((missing + 1)); }
done
[ "$missing" -eq 0 ] && pass "every post url exists"

echo "== task 1: skeleton"
has index.html 'class="pl-seg pl-user"'
has index.html 'css/bundle\.min\.[0-9a-f]{64}\.css'
has index.html 'js/terminal\.min\.[0-9a-f]{64}\.js'
lacks index.html 'id="header-desktop"'
has index.html 'class="row"'
has posts/index.html 'class="year"'
has tags/index.html 'class="terms"'
has tags/mysql/index.html 'class="row"'
has index.json '"url":'
has index.xml '<rss'
has dementia-disease/index.html 'adm adm-warning'
has dementia-disease/index.html '\[WARN\]</span> 症狀'
has rdbms_design/index.html '\[SUMMARY\]</span> 文章系列'
has api_token_design/index.html 'href="https://[^"]+" target="_blank" rel="noopener noreferrer"'

# --- assertions above this line ---

echo
if [ "$FAILS" -eq 0 ]; then echo "ALL PASS"; else echo "$FAILS FAILED"; exit 1; fi
```

```bash
chmod +x scripts/check-theme.sh
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `scripts/check-theme.sh`
Expected: FAIL — LoveIt is still the theme, so `pl-seg pl-user` / `bundle.min` assertions fail.

- [ ] **Step 3: Version the theme dir and rewrite config**

`.gitignore` — replace the line `themes/` with:

```
themes/*
!themes/terminal/
```

`config.toml` — full replacement (menus, permalinks, outputs copied from the current file):

```toml
baseURL = "https://kylinyu.win"
defaultContentLanguage = "zh-tw"
languageCode = "zh-TW"
hasCJKLanguage = true
title = "墨冊"
theme = "terminal"
paginate = 20

[author]
  name = "Win Yu"
  email = ""
  authorlink = "https://kylinyu.win"

[params]
  subtitle = "筆墨日積終將成冊，知識月累便可結果"
  avatar = "/img/avatar-2.jpg"
  since = 2017
  [params.social]
    github = "kylinfish"
    linkedin = "openwinyu"
    twitter = "kylinwin"
    email = "kylinfish@gmail.com"

[permalinks]
  posts = "/:filename"

[sitemap]
  changefreq = "weekly"
  filename = "sitemap.xml"
  priority = 0.5

[menu]
  [[menu.main]]
    identifier = "posts"
    name = "所有文章"
    url = "/posts/"
    weight = 1
  [[menu.main]]
    identifier = "tags"
    name = "標籤"
    url = "/tags/"
    weight = 2
  [[menu.main]]
    identifier = "categories"
    name = "分類"
    url = "/categories/"
    weight = 3
  [[menu.main]]
    identifier = "makelog"
    name = "造物誌"
    url = "/categories/造物誌/"
    title = "造物誌 · 用 coding agent 做的 side project"
    weight = 4
  [[menu.main]]
    identifier = "MySQL"
    name = "MySQL"
    url = "/tags/mysql/"
    title = "MySQL"
    weight = 5
  [[menu.main]]
    identifier = "es"
    name = "ElasticSearch"
    url = "/tags/elasticsearch/"
    title = "ElasticSearch"
    weight = 6
  [[menu.main]]
    identifier = "about"
    name = "AboutMe"
    url = "/about/"
    title = "AboutMe"
    weight = 7

[markup]
  [markup.highlight]
    noClasses = false
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true
  [markup.tableOfContents]
    startLevel = 2
    endLevel = 3

[outputs]
  home = ["HTML", "RSS", "JSON"]
  page = ["HTML"]
  section = ["HTML", "RSS"]
  taxonomy = ["HTML", "RSS"]
  taxonomyTerm = ["HTML"]
```

`themes/terminal/theme.toml`:

```toml
name = "terminal"
license = "MIT"
description = "One Dark powerline terminal theme for 墨冊"
min_version = "0.101.0"
```

- [ ] **Step 4: Base layout and partials**

`themes/terminal/layouts/_default/baseof.html`:

```html
<!DOCTYPE html>
<html lang="{{ site.LanguageCode }}">
<head>
  {{- partial "head.html" . }}
</head>
<body class="kind-{{ .Kind }}">
  {{- partial "header.html" . }}
  <main class="wrap">
    {{- block "main" . }}{{ end }}
  </main>
  {{- partial "footer.html" . }}
  {{- $js := resources.Get "js/terminal.js" | minify | fingerprint }}
  <script src="{{ $js.RelPermalink }}" defer></script>
</body>
</html>
```

`themes/terminal/layouts/partials/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} · {{ site.Title }}{{ end }}</title>
{{- $desc := .Description | default site.Params.subtitle }}
<meta name="description" content="{{ $desc }}">
<meta property="og:title" content="{{ .Title | default site.Title }}">
<meta property="og:description" content="{{ $desc }}">
<meta property="og:url" content="{{ .Permalink }}">
<meta property="og:type" content="{{ if .IsPage }}article{{ else }}website{{ end }}">
{{- with .Params.featuredImage }}
<meta property="og:image" content="{{ . | absURL }}">
{{- end }}
<meta name="theme-color" content="#21252b">
<link rel="icon" href="{{ "favicons/favicon.ico" | relURL }}">
<link rel="apple-touch-icon" href="{{ "favicons/apple-touch-icon.png" | relURL }}">
{{- range .AlternativeOutputFormats }}
<link rel="{{ .Rel }}" type="{{ .MediaType.Type }}" href="{{ .Permalink }}">
{{- end }}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@400;600;700&display=swap">
{{- $css := slice (resources.Get "css/terminal.css") (resources.Get "css/post.css") (resources.Get "css/home.css") | resources.Concat "css/bundle.css" | minify | fingerprint }}
<link rel="stylesheet" href="{{ $css.RelPermalink }}" integrity="{{ $css.Data.Integrity }}">
```

`themes/terminal/layouts/partials/header.html`:

```html
{{- $path := "~" }}
{{- if eq .Kind "page" }}{{ $path = path.Join "~" .Section .File.ContentBaseName }}
{{- else if eq .Kind "section" }}{{ $path = path.Join "~" .Section }}
{{- else if eq .Kind "taxonomy" }}{{ $path = path.Join "~" .Data.Plural }}
{{- else if eq .Kind "term" }}{{ $path = path.Join "~" .Data.Plural .Title }}
{{- else if eq .Kind "404" }}{{ $path = "~/404" }}
{{- end }}
{{- $cur := .RelPermalink }}
<header class="site-header">
  <div class="bar">
    <a class="pl" href="{{ "/" | relURL }}" aria-label="{{ site.Title }} home">
      <span class="pl-seg pl-user">win</span>
      <span class="pl-seg pl-path">{{ $path }}</span>
      <span class="pl-seg pl-site">{{ site.Title }}</span>
    </a>
    <nav class="nav">
      {{- range site.Menus.main }}
      <a href="{{ .URL | relURL }}"{{ with .Title }} title="{{ . }}"{{ end }}{{ if eq $cur .URL }} class="active"{{ end }}>{{ .Name }}</a>
      {{- end }}
    </nav>
  </div>
</header>
```

`themes/terminal/layouts/partials/footer.html`:

```html
<footer class="site-footer">
  <div class="bar">
    <span>© {{ site.Params.since }}–{{ now.Year }} {{ site.Author.name }}</span>
    <span><a href="{{ "index.xml" | relURL }}">rss</a> · <span class="ok">exit 0</span></span>
  </div>
</footer>
```

`themes/terminal/layouts/partials/post-row.html`:

```html
<li class="row">
  <time class="row-date" datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format "2006-01-02" }}</time>
  <div>
    <a class="row-title" href="{{ .RelPermalink }}">{{ .Title }}</a>
    {{- with .GetTerms "tags" }}
    <div class="tags">{{ range . }}<a class="tag" href="{{ .RelPermalink }}">{{ .LinkTitle }}</a>{{ end }}</div>
    {{- end }}
    {{- with .Description | default .Summary | plainify }}
    <p class="row-desc">{{ . }}</p>
    {{- end }}
  </div>
</li>
```

`themes/terminal/layouts/partials/pager.html`:

```html
{{- if gt .TotalPages 1 }}
<nav class="pager">
  {{- with .Prev }}<a href="{{ .URL }}">← prev</a>{{ else }}<span></span>{{ end }}
  <span>page {{ .PageNumber }}/{{ .TotalPages }}</span>
  {{- with .Next }}<a href="{{ .URL }}">next →</a>{{ else }}<span></span>{{ end }}
</nav>
{{- end }}
```

- [ ] **Step 5: Page templates (minimal home + single, full list/terms/json)**

`themes/terminal/layouts/index.html` (replaced in Task 3):

```html
{{ define "main" }}
<p class="prompt-line"><span class="cmd">ls -lt posts/ | head -8</span></p>
<ul class="rows">
  {{- range first 8 (where site.RegularPages "Section" "posts") }}{{ partial "post-row.html" . }}{{ end }}
</ul>
{{ end }}
```

`themes/terminal/layouts/_default/single.html` (replaced in Task 2):

```html
{{ define "main" }}
<article class="post">
  <h1 class="post-title">{{ .Title }}</h1>
  <div class="post-body">{{ .Content }}</div>
</article>
{{ end }}
```

`themes/terminal/layouts/_default/list.html`:

```html
{{ define "main" }}
<p class="prompt-line"><span class="cmd">ls -l {{ .Title }}/</span></p>
<h1 class="page-title">{{ .Title }} <span class="count">({{ len .Pages }})</span></h1>
{{- $pag := .Paginate .Pages.ByDate.Reverse }}
{{- range $pag.Pages.GroupByDate "2006" }}
<h2 class="year">{{ .Key }}</h2>
<ul class="rows">
  {{- range .Pages }}{{ partial "post-row.html" . }}{{ end }}
</ul>
{{- end }}
{{ partial "pager.html" $pag }}
{{ end }}
```

`themes/terminal/layouts/_default/terms.html`:

```html
{{ define "main" }}
<p class="prompt-line"><span class="cmd">ls {{ .Data.Plural }}/ | wc -l</span></p>
<h1 class="page-title">{{ .Title }} <span class="count">{{ len .Data.Terms }}</span></h1>
<ul class="terms">
  {{- range .Data.Terms.ByCount }}
  <li><a href="{{ .Page.RelPermalink }}">{{ .Page.Title }}</a><span class="count">{{ .Count }}</span></li>
  {{- end }}
</ul>
{{ end }}
```

`themes/terminal/layouts/index.json`:

```
{{- $out := slice }}
{{- range where site.RegularPages "Section" "posts" }}
{{- $out = $out | append (dict "title" .Title "url" .Permalink "date" (.Date.Format "2006-01-02") "description" (.Description | default .Summary | plainify) "tags" (.Params.tags | default slice)) }}
{{- end }}
{{- $out | jsonify }}
```

- [ ] **Step 6: Shortcodes**

`themes/terminal/layouts/shortcodes/admonition.html`:

```html
{{- $labels := dict "note" "NOTE" "notice" "NOTE" "primary" "NOTE" "abstract" "SUMMARY" "summary" "SUMMARY" "info" "INFO" "example" "EXAMPLE" "quote" "QUOTE" "tip" "TIP" "success" "OK" "question" "ASK" "warning" "WARN" "failure" "FAIL" "danger" "ERR" "bug" "BUG" -}}
{{- $type := "note" -}}{{- $title := "" -}}{{- $openArg := "" -}}
{{- if .IsNamedParams -}}
  {{- $type = .Get "type" | default "note" -}}
  {{- $title = .Get "title" | default "" -}}
  {{- $openArg = .Get "open" -}}
{{- else -}}
  {{- $type = .Get 0 | default "note" -}}
  {{- $title = .Get 1 | default "" -}}
  {{- $openArg = .Get 2 -}}
{{- end -}}
{{- $open := ne (printf "%v" $openArg) "false" -}}
{{- $label := index $labels $type | default "NOTE" -}}
<details class="adm adm-{{ $type }}"{{ if $open }} open{{ end }}>
  <summary class="adm-title"><span class="adm-label">[{{ $label }}]</span>{{ with $title }} {{ . }}{{ end }}</summary>
  <div class="adm-body">{{ .Inner | .Page.RenderString }}</div>
</details>
```

`themes/terminal/layouts/shortcodes/link.html`:

```html
{{- $href := "" -}}{{- $content := "" -}}{{- $title := "" -}}
{{- if .IsNamedParams -}}
  {{- $href = .Get "href" -}}
  {{- $content = .Get "content" | default $href -}}
  {{- $title = .Get "title" | default "" -}}
{{- else -}}
  {{- $href = .Get 0 -}}
  {{- $content = .Get 1 | default $href -}}
  {{- $title = .Get 2 | default "" -}}
{{- end -}}
<a href="{{ $href }}"{{ with $title }} title="{{ . }}"{{ end }}{{ if hasPrefix $href "http" }} target="_blank" rel="noopener noreferrer"{{ end }}>{{ $content | markdownify }}</a>
```

- [ ] **Step 7: Base CSS + empty bundles + JS stub**

`themes/terminal/assets/css/post.css`:

```css
/* post page — filled in Task 2 */
```

`themes/terminal/assets/css/home.css`:

```css
/* homepage — filled in Task 3 */
```

`themes/terminal/assets/js/terminal.js`:

```js
// code copy + TOC highlight — filled in Task 2
```

`themes/terminal/assets/css/terminal.css`:

```css
:root {
  --bg: #282c34; --bg-alt: #21252b; --line: #3e4451;
  --fg: #abb2bf; --fg-hi: #e6e6e6; --comment: #5c6370;
  --blue: #61afef; --purple: #c678dd; --green: #98c379; --yellow: #e5c07b;
  --red: #e06c75; --cyan: #56b6c2; --orange: #d19a66;
  --mono: "Source Code Pro", "SauceCodePro Nerd Font", ui-monospace, Menlo, monospace;
  --cjk: "PingFang TC", "Noto Sans TC", "Microsoft JhengHei", system-ui, sans-serif;
  --wrap: 1100px;
  color-scheme: dark;
}
* { box-sizing: border-box; }
html { font-size: 16px; }
body { margin: 0; background: var(--bg); color: var(--fg); font-family: var(--mono); line-height: 1.6; -webkit-font-smoothing: antialiased; }
a { color: var(--blue); text-decoration: none; }
a:hover { text-decoration: underline; }
img { max-width: 100%; height: auto; }
.wrap { max-width: var(--wrap); margin: 0 auto; padding: 24px 16px 64px; }

/* prompt line: ❯ cmd */
.prompt-line { color: var(--comment); margin: 32px 0 12px; font-size: .9375rem; }
.prompt-line::before { content: "❯ "; color: var(--green); }
.prompt-line .cmd { color: var(--fg-hi); }

/* header: powerline bar + cd nav */
.site-header { position: sticky; top: 0; z-index: 10; background: var(--bg-alt); border-bottom: 1px solid var(--line); }
.site-header .bar { max-width: var(--wrap); margin: 0 auto; padding: 8px 16px; display: flex; flex-wrap: wrap; gap: 8px 16px; align-items: center; justify-content: space-between; }
.pl { display: flex; align-items: stretch; min-width: 0; font-size: .875rem; font-weight: 600; }
.pl:hover { text-decoration: none; }
.pl-seg { padding: 2px 16px 2px 10px; margin-right: -6px; color: var(--bg); white-space: nowrap; clip-path: polygon(0 0, calc(100% - 8px) 0, 100% 50%, calc(100% - 8px) 100%, 0 100%); }
.pl-seg + .pl-seg { padding-left: 16px; clip-path: polygon(0 0, calc(100% - 8px) 0, 100% 50%, calc(100% - 8px) 100%, 0 100%, 8px 50%); }
.pl-user { background: var(--blue); }
.pl-path { background: var(--purple); overflow: hidden; text-overflow: ellipsis; max-width: 50vw; }
.pl-site { background: var(--line); color: var(--fg-hi); }
.nav { display: flex; flex-wrap: wrap; gap: 4px 14px; font-size: .875rem; }
.nav a { color: var(--fg); }
.nav a::before { content: "cd "; color: var(--comment); }
.nav a.active { color: var(--yellow); }

/* footer */
.site-footer { border-top: 1px solid var(--line); color: var(--comment); font-size: .8125rem; }
.site-footer .bar { max-width: var(--wrap); margin: 0 auto; padding: 16px; display: flex; flex-wrap: wrap; gap: 8px 16px; justify-content: space-between; }
.site-footer .ok { color: var(--green); }

/* ls -l rows */
.rows { list-style: none; margin: 0; padding: 0; }
.row { display: grid; grid-template-columns: 7.5rem minmax(0, 1fr); gap: 4px 16px; padding: 12px 0; border-bottom: 1px dashed var(--line); }
.row-date { color: var(--comment); font-size: .875rem; padding-top: 3px; }
.row-title { color: var(--fg-hi); font-family: var(--cjk); font-weight: 600; font-size: 1.0625rem; overflow-wrap: anywhere; }
.row-desc { margin: 4px 0 0; font-family: var(--cjk); font-size: .9375rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.tags { display: flex; flex-wrap: wrap; gap: 2px 10px; font-size: .8125rem; margin-top: 2px; }
.tag { color: var(--cyan); }
.tag::before { content: "#"; color: var(--comment); }
.more { display: inline-block; margin-top: 12px; font-size: .875rem; }
.page-title { color: var(--fg-hi); font-family: var(--cjk); font-size: 1.5rem; margin: 8px 0 16px; }
.count { color: var(--comment); font-size: .875rem; font-weight: 400; margin-left: 8px; }
.year { color: var(--yellow); font-size: 1rem; margin: 32px 0 4px; }
.year::before { content: "drwxr-xr-x  "; color: var(--comment); }
.terms { list-style: none; padding: 0; columns: 3 14rem; column-gap: 24px; }
.terms li { padding: 2px 0; break-inside: avoid; }
.pager { display: flex; justify-content: space-between; margin-top: 24px; font-size: .875rem; color: var(--comment); }

/* admonitions as log lines */
.adm { --c: var(--blue); margin: 20px 0; border-left: 3px solid var(--c); background: var(--bg-alt); border-radius: 0 4px 4px 0; }
.adm-title { cursor: pointer; padding: 8px 14px; font-family: var(--mono); font-size: .875rem; color: var(--fg-hi); list-style: none; }
.adm-title::-webkit-details-marker { display: none; }
.adm-label { color: var(--c); font-weight: 700; }
.adm-body { padding: 0 14px 10px; }
.adm-body > :first-child { margin-top: 0; }
.adm-body > :last-child { margin-bottom: 0; }
.adm-abstract, .adm-summary, .adm-info { --c: var(--cyan); }
.adm-example, .adm-quote { --c: var(--purple); }
.adm-tip, .adm-success { --c: var(--green); }
.adm-question { --c: var(--yellow); }
.adm-warning { --c: var(--orange); }
.adm-failure, .adm-danger, .adm-bug { --c: var(--red); }

@media (max-width: 640px) {
  .row { grid-template-columns: minmax(0, 1fr); }
  .pl-path { max-width: 40vw; }
}
```

- [ ] **Step 8: Run the check**

Run: `scripts/check-theme.sh`
Expected: `ALL PASS`. If `found no layout` appears, the log names the missing kind — add that template.

- [ ] **Step 9: Commit**

```bash
git add .gitignore config.toml scripts/check-theme.sh themes/terminal
git commit -m "feat(theme): terminal theme skeleton replaces LoveIt"
```

---

### Task 2: Post page — meta bar, cover, TOC, code copy

**Files:**
- Modify: `themes/terminal/layouts/_default/single.html` (full replacement)
- Modify: `themes/terminal/assets/css/post.css` (full replacement)
- Modify: `themes/terminal/assets/js/terminal.js` (full replacement)
- Modify: `scripts/check-theme.sh` (add block)

**Interfaces:**
- Consumes: `.pl`, `.pl-seg`, `.tags`, `.tag`, `.prompt-line` from Task 1.
- Produces: classes `.post .post-title .post-body .toc .toc-side .toc-inline .copy-btn`; `page/single.html` in Task 4 reuses `.post .post-title .post-body`.

- [ ] **Step 1: Add failing assertions** (insert above `# --- assertions above this line ---`)

```bash
echo "== task 2: post page"
has es-reindex/index.html 'cat es-reindex\.md'
has es-reindex/index.html 'class="pl pl-meta"'
has es-reindex/index.html 'class="toc toc-side"'
has es-reindex/index.html 'id="TableOfContents"'
has es-reindex/index.html '<a href="#[^"]+">'
has mailquill-gmail-statements-to-ledger/index.html 'class="post-cover"'
has mailquill-gmail-statements-to-ledger/index.html 'class="toc toc-side"'
lacks lumen_tinker/index.html 'class="toc'
has es_reindex_for_merge_indices/index.html 'class="chroma"'
has es_reindex_for_merge_indices/index.html 'class="post-nav"'
```

- [ ] **Step 2: Run to confirm failure**

Run: `scripts/check-theme.sh`
Expected: the `task 2` lines FAIL; everything else ok.

- [ ] **Step 3: Write `single.html`**

```html
{{ define "main" }}
{{- $tocOn := true }}
{{- with .Params.toc }}
  {{- if reflect.IsMap . }}{{ $tocOn = ne .enable false }}{{ else if eq . false }}{{ $tocOn = false }}{{ end }}
{{- end }}
{{- $toc := and $tocOn (ge (len (findRE "<li>" .TableOfContents)) 2) }}
<p class="prompt-line"><span class="cmd">cat {{ .File.ContentBaseName }}.md</span></p>
<div class="post-layout{{ if $toc }} has-toc{{ end }}">
  <article class="post">
    <header>
      <h1 class="post-title">{{ .Title }}</h1>
      {{- with .Params.subtitle }}<p class="post-subtitle">{{ . }}</p>{{ end }}
      <div class="pl pl-meta">
        <span class="pl-seg pl-date">{{ .Date.Format "2006-01-02" }}</span>
        <span class="pl-seg pl-time">{{ .ReadingTime }} min</span>
        {{- range .GetTerms "categories" }}<a class="pl-seg pl-cat" href="{{ .RelPermalink }}">{{ .LinkTitle }}</a>{{ end }}
      </div>
      {{- with .GetTerms "tags" }}
      <div class="tags post-tags">{{ range . }}<a class="tag" href="{{ .RelPermalink }}">{{ .LinkTitle }}</a>{{ end }}</div>
      {{- end }}
    </header>
    {{- with .Params.featuredImage }}
    <img class="post-cover" src="{{ . }}" alt="" loading="eager">
    {{- end }}
    {{- if $toc }}
    <details class="toc toc-inline"><summary>tree .</summary>{{ .TableOfContents }}</details>
    {{- end }}
    <div class="post-body">{{ .Content }}</div>
    <nav class="post-nav">
      {{- with .NextInSection }}<a href="{{ .RelPermalink }}"><span>← cd ../</span>{{ .Title }}</a>{{ else }}<span></span>{{ end }}
      {{- with .PrevInSection }}<a class="next" href="{{ .RelPermalink }}"><span>cd ../ →</span>{{ .Title }}</a>{{ end }}
    </nav>
  </article>
  {{- if $toc }}
  <aside class="toc toc-side"><div class="toc-head">tree .</div>{{ .TableOfContents }}</aside>
  {{- end }}
</div>
{{ end }}
```

- [ ] **Step 4: Write `post.css`**

```css
/* layout */
.post-layout { display: grid; grid-template-columns: minmax(0, 1fr); gap: 40px; }
.post-layout.has-toc { grid-template-columns: minmax(0, 1fr) 240px; }
.post { min-width: 0; max-width: 780px; }
.post-title { font-family: var(--cjk); color: var(--fg-hi); font-size: 1.875rem; line-height: 1.35; margin: 4px 0 8px; overflow-wrap: anywhere; }
.post-subtitle { color: var(--comment); font-family: var(--cjk); margin: 0 0 12px; }
.pl-meta { flex-wrap: wrap; row-gap: 4px; margin: 12px 0 8px; font-weight: 400; }
.pl-date { background: var(--blue); }
.pl-time { background: var(--green); }
.pl-cat { background: var(--yellow); color: var(--bg); }
.post-tags { margin-bottom: 16px; }
.post-cover { display: block; width: 100%; border: 1px solid var(--line); border-radius: 6px; margin: 16px 0; }

/* body */
.post-body { font-family: var(--cjk); font-size: 1.0625rem; line-height: 1.85; color: #c8ccd4; overflow-wrap: break-word; }
.post-body h2, .post-body h3, .post-body h4 { font-family: var(--mono), var(--cjk); color: var(--fg-hi); line-height: 1.4; margin: 2em 0 .6em; scroll-margin-top: 72px; }
.post-body h2::before { content: "## "; color: var(--purple); }
.post-body h3::before { content: "### "; color: var(--purple); }
.post-body h4::before { content: "#### "; color: var(--purple); }
.post-body a { text-decoration: underline; text-underline-offset: 3px; }
.post-body blockquote { margin: 1.2em 0; padding: 4px 16px; border-left: 3px solid var(--comment); background: var(--bg-alt); color: var(--fg); }
.post-body table { display: block; overflow-x: auto; border-collapse: collapse; font-size: .9375rem; }
.post-body th, .post-body td { border: 1px solid var(--line); padding: 6px 10px; }
.post-body th { background: var(--bg-alt); color: var(--fg-hi); }
.post-body hr { border: 0; border-top: 1px dashed var(--line); margin: 2em 0; }
.post-body img { border-radius: 4px; }
.post-body figure { margin: 1.5em 0; text-align: center; }
.post-body figcaption { color: var(--comment); font-size: .875rem; }
.post-body :not(pre) > code { font-family: var(--mono); font-size: .875em; color: var(--orange); background: var(--bg-alt); padding: 1px 6px; border-radius: 3px; }

/* code blocks */
.highlight { position: relative; margin: 1.2em 0; }
.post-body pre { font-family: var(--mono); font-size: .875rem; line-height: 1.6; background: var(--bg-alt); border: 1px solid var(--line); border-radius: 6px; padding: 14px 16px; overflow-x: auto; margin: 0; }
.highlight .lntable pre { border: 0; border-radius: 0; }
.copy-btn { position: absolute; top: 6px; right: 6px; font: 600 .75rem var(--mono); color: var(--comment); background: var(--bg); border: 1px solid var(--line); border-radius: 4px; padding: 2px 8px; cursor: pointer; opacity: 0; transition: opacity .15s; }
.highlight:hover .copy-btn, .copy-btn:focus { opacity: 1; }
.copy-btn.done { color: var(--green); }
@media (hover: none) { .copy-btn { opacity: 1; } }

/* toc as tree */
.toc { font-size: .8125rem; }
.toc ul { list-style: none; margin: 0; padding-left: 14px; border-left: 1px solid var(--line); }
.toc nav > ul { padding-left: 0; border: 0; }
.toc a { display: block; padding: 2px 0; color: var(--fg); font-family: var(--cjk); }
.toc a.active { color: var(--yellow); }
.toc-side { position: sticky; top: 72px; align-self: start; max-height: calc(100vh - 96px); overflow-y: auto; }
.toc-head, .toc-inline summary { color: var(--green); margin-bottom: 8px; cursor: pointer; }
.toc-inline { display: none; background: var(--bg-alt); border: 1px solid var(--line); border-radius: 6px; padding: 10px 14px; margin: 16px 0; }

/* prev / next */
.post-nav { display: flex; justify-content: space-between; gap: 16px; margin-top: 48px; padding-top: 16px; border-top: 1px dashed var(--line); font-family: var(--cjk); font-size: .9375rem; }
.post-nav a { max-width: 48%; }
.post-nav .next { text-align: right; }
.post-nav span { display: block; color: var(--comment); font-family: var(--mono); font-size: .8125rem; }

@media (max-width: 1024px) {
  .post-layout.has-toc { grid-template-columns: minmax(0, 1fr); }
  .toc-side { display: none; }
  .toc-inline { display: block; }
}
@media (max-width: 640px) {
  .post-title { font-size: 1.5rem; }
  .post-body { font-size: 1rem; }
}

/* chroma — One Dark */
.chroma { color: #abb2bf; background: var(--bg-alt); }
.chroma .k, .chroma .kc, .chroma .kd, .chroma .kn, .chroma .kp, .chroma .kr { color: #c678dd; }
.chroma .kt, .chroma .nc, .chroma .nn { color: #e5c07b; }
.chroma .na, .chroma .nf, .chroma .fm { color: #61afef; }
.chroma .nb, .chroma .bp, .chroma .o, .chroma .ow { color: #56b6c2; }
.chroma .nt, .chroma .nv, .chroma .vi, .chroma .vg, .chroma .vc, .chroma .err, .chroma .gd { color: #e06c75; }
.chroma .s, .chroma .s1, .chroma .s2, .chroma .sb, .chroma .sc, .chroma .sd, .chroma .se, .chroma .sh, .chroma .si, .chroma .sx, .chroma .sr, .chroma .ss, .chroma .gi { color: #98c379; }
.chroma .m, .chroma .mi, .chroma .mf, .chroma .mh, .chroma .mo, .chroma .il { color: #d19a66; }
.chroma .c, .chroma .c1, .chroma .cm, .chroma .cs, .chroma .ch, .chroma .cp, .chroma .cpf { color: #5c6370; font-style: italic; }
.chroma .gh, .chroma .gu { color: #61afef; }
.chroma .hl { display: block; background: #3e4451; }
.chroma .ln, .chroma .lnt { color: #4b5263; margin-right: 12px; }
.chroma .lntable { border-spacing: 0; }
.chroma .lntd { vertical-align: top; padding: 0; }
```

- [ ] **Step 5: Write `terminal.js`**

```js
(function () {
  // copy button on every code block in a post
  document.querySelectorAll('.post-body pre').forEach(function (pre) {
    var box = pre.closest('.highlight');
    if (!box) {
      box = document.createElement('div');
      box.className = 'highlight';
      pre.parentNode.insertBefore(box, pre);
      box.appendChild(pre);
    }
    if (box.querySelector('.copy-btn')) return;
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = 'copy';
    btn.addEventListener('click', function () {
      // with line numbers the code lives in the last table cell
      var code = box.querySelector('.lntd:last-child code') || box.querySelector('code') || pre;
      navigator.clipboard.writeText(code.innerText).then(function () {
        btn.textContent = 'copied!';
        btn.classList.add('done');
      }, function () {
        btn.textContent = 'error';
      });
      setTimeout(function () {
        btn.textContent = 'copy';
        btn.classList.remove('done');
      }, 1500);
    });
    box.appendChild(btn);
  });

  // highlight the TOC entry of the section being read
  var links = document.querySelectorAll('.toc-side a');
  if (!links.length || !('IntersectionObserver' in window)) return;
  var byId = {};
  links.forEach(function (a) {
    // CJK heading ids are percent-encoded in href but not in the DOM
    byId[decodeURIComponent(a.hash.slice(1))] = a;
  });
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting || !byId[e.target.id]) return;
      links.forEach(function (a) { a.classList.remove('active'); });
      byId[e.target.id].classList.add('active');
    });
  }, { rootMargin: '-72px 0px -70% 0px' });
  Object.keys(byId).forEach(function (id) {
    var h = document.getElementById(id);
    if (h) observer.observe(h);
  });
})();
```

- [ ] **Step 6: Run the check**

Run: `scripts/check-theme.sh`
Expected: `ALL PASS`.

- [ ] **Step 7: Manual JS check** — `hugo serve` then open `http://localhost:1313/es-reindex/`: click `copy` on a code block → button shows `copied!`; scroll → TOC entry turns yellow. Open `/claude-code-resume-ccr/` and confirm a Chinese-heading TOC entry highlights.

- [ ] **Step 8: Commit**

```bash
git add themes/terminal scripts/check-theme.sh
git commit -m "feat(theme): post page with powerline meta, tree TOC and code copy"
```

---

### Task 3: Homepage — whoami, traceroute, latest posts, projects

**Files:**
- Create: `data/career.yaml`
- Modify: `themes/terminal/layouts/index.html` (full replacement)
- Modify: `themes/terminal/assets/css/home.css` (full replacement)
- Modify: `scripts/check-theme.sh` (add block)

**Interfaces:**
- Consumes: `post-row.html`, `.prompt-line`, `.rows`, `.more`, `site.Params.{subtitle,avatar,social}`.
- Produces: `site.Data.career.hops[]` with keys `period` (string), `org` (string), `role` (string, may be empty), `current` (bool, optional). Order oldest → newest.

- [ ] **Step 1: Add failing assertions**

```bash
echo "== task 3: homepage"
has index.html '<span class="cmd">whoami</span>'
has index.html '<span class="cmd">traceroute career</span>'
has index.html 'class="hop is-current"'
has index.html 'RHINOSHIELD'
has index.html '<span class="cmd">ls -lt posts/ \| head -8</span>'
has index.html '<span class="cmd">ls ~/projects</span>'
has index.html 'class="project"'
has index.html 'href="https://github.com/kylinfish"'
```

- [ ] **Step 2: Run to confirm failure**

Run: `scripts/check-theme.sh`
Expected: `task 3` lines FAIL except the `ls -lt` line.

- [ ] **Step 3: Seed `data/career.yaml`**

```yaml
# traceroute career — oldest first; mark the last hop current: true
# period is free text ("2015–2019", "2018", "now")
hops:
  - period: "2018"
    org: "PIXNET"
    role: ""
  - period: "now"
    org: "RHINOSHIELD 犀牛盾"
    role: "Official Web Manager"
    current: true
```

- [ ] **Step 4: Write `index.html`**

```html
{{ define "main" }}
<section class="home-block">
  <p class="prompt-line"><span class="cmd">whoami</span></p>
  <div class="whoami">
    <img class="avatar" src="{{ site.Params.avatar | relURL }}" alt="{{ site.Author.name }}" width="96" height="96">
    <div>
      <h1 class="whoami-name">{{ site.Author.name }} <span>@ {{ site.Title }}</span></h1>
      <p class="whoami-sub">{{ site.Params.subtitle }}<span class="cursor" aria-hidden="true">▋</span></p>
      <div class="social">
        {{- with site.Params.social }}
        {{- with .github }}<a href="https://github.com/{{ . }}">github</a>{{ end }}
        {{- with .linkedin }}<a href="https://www.linkedin.com/in/{{ . }}">linkedin</a>{{ end }}
        {{- with .twitter }}<a href="https://twitter.com/{{ . }}">twitter</a>{{ end }}
        {{- with .email }}<a href="mailto:{{ . }}">email</a>{{ end }}
        {{- end }}
        <a href="{{ "index.xml" | relURL }}">rss</a>
      </div>
    </div>
  </div>
</section>

{{- with site.Data.career.hops }}
<section class="home-block">
  <p class="prompt-line"><span class="cmd">traceroute career</span></p>
  <ol class="hops">
    {{- range $i, $h := . }}
    <li class="hop{{ if $h.current }} is-current{{ end }}">
      <span class="hop-n">{{ add $i 1 }}</span>
      <span class="hop-period">{{ $h.period }}</span>
      <span class="hop-org">{{ $h.org }}</span>
      {{- with $h.role }}<span class="hop-role">{{ . }}</span>{{ end }}
      {{- if $h.current }}<span class="hop-now">● current</span>{{ end }}
    </li>
    {{- end }}
  </ol>
  <a class="more" href="{{ "about/" | relURL }}">→ about</a>
</section>
{{- end }}

<section class="home-block">
  <p class="prompt-line"><span class="cmd">ls -lt posts/ | head -8</span></p>
  <ul class="rows">
    {{- range first 8 (where site.RegularPages "Section" "posts") }}{{ partial "post-row.html" . }}{{ end }}
  </ul>
  <a class="more" href="{{ "posts/" | relURL }}">ls posts/ →</a>
</section>

{{- with index site.Taxonomies.categories "造物誌" }}
<section class="home-block">
  <p class="prompt-line"><span class="cmd">ls ~/projects</span></p>
  <div class="projects">
    {{- range first 6 .Pages }}
    <a class="project" href="{{ .RelPermalink }}">
      <span class="project-name">{{ .File.ContentBaseName }}/</span>
      <span class="project-title">{{ .Title }}</span>
    </a>
    {{- end }}
  </div>
  <a class="more" href="{{ "categories/造物誌/" | relURL }}">cd ~/projects →</a>
</section>
{{- end }}
{{ end }}
```

- [ ] **Step 5: Write `home.css`**

```css
.home-block { margin-bottom: 40px; }
.home-block .prompt-line:first-child { margin-top: 16px; }

/* whoami */
.whoami { display: flex; gap: 20px; align-items: center; }
.avatar { flex: none; width: 96px; height: 96px; border-radius: 50%; border: 2px solid var(--green); object-fit: cover; }
.whoami-name { margin: 0; color: var(--fg-hi); font-size: 1.5rem; }
.whoami-name span { color: var(--comment); font-size: 1rem; font-weight: 400; }
.whoami-sub { margin: 4px 0 8px; color: var(--green); font-family: var(--cjk); }
.cursor { margin-left: 2px; color: var(--green); animation: blink 1s steps(1) infinite; }
@keyframes blink { 50% { opacity: 0; } }
@media (prefers-reduced-motion: reduce) { .cursor { animation: none; } }
.social { display: flex; flex-wrap: wrap; gap: 4px 14px; font-size: .875rem; }
.social a::before { content: "→ "; color: var(--comment); }

/* traceroute */
.hops { list-style: none; margin: 0; padding: 0; font-size: .9375rem; }
.hop { display: grid; grid-template-columns: 2rem 5rem minmax(0, 1fr); gap: 0 12px; padding: 4px 0; }
.hop-n { color: var(--comment); text-align: right; }
.hop-period { color: var(--yellow); }
.hop-org { color: var(--fg-hi); font-family: var(--mono), var(--cjk); }
.hop-role, .hop-now { grid-column: 3; }
.hop-role { font-family: var(--cjk); font-size: .875rem; }
.hop-now { color: var(--green); font-size: .8125rem; }

/* projects */
.projects { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 12px; }
.project { display: block; padding: 12px 14px; background: var(--bg-alt); border: 1px solid var(--line); border-radius: 6px; color: var(--fg); }
.project:hover { border-color: var(--blue); text-decoration: none; }
.project-name { display: block; color: var(--blue); font-weight: 600; overflow-wrap: anywhere; }
.project-title { display: block; margin-top: 4px; font-family: var(--cjk); font-size: .875rem; }

@media (max-width: 640px) {
  .whoami { flex-direction: column; align-items: flex-start; }
}
```

- [ ] **Step 6: Run the check**

Run: `scripts/check-theme.sh`
Expected: `ALL PASS`.

- [ ] **Step 7: Commit**

```bash
git add data/career.yaml themes/terminal scripts/check-theme.sh
git commit -m "feat(theme): terminal homepage with whoami, traceroute and projects"
```

---

### Task 4: About, 404, remove LoveIt leftovers

**Files:**
- Create: `themes/terminal/layouts/page/single.html`, `themes/terminal/layouts/404.html`
- Delete: `layouts/_default/about.html`, `static/css/about.css`, `assets/css/_custom.scss`
- Modify: `scripts/check-theme.sh` (add block)

**Interfaces:**
- Consumes: `.post .post-title .post-body .prompt-line` from Tasks 1–2.

- [ ] **Step 1: Add failing assertions**

```bash
echo "== task 4: about + 404 + cleanup"
has about/index.html 'cat about\.md'
lacks about/index.html 'class="pl pl-meta"'
has 404.html 'command not found'
lacks about/index.html 'about\.css'
if [ -e layouts/_default/about.html ] || [ -e assets/css/_custom.scss ]; then fail "LoveIt overrides removed"; else pass "LoveIt overrides removed"; fi
```

- [ ] **Step 2: Run to confirm failure**

Run: `scripts/check-theme.sh`
Expected: `task 4` lines FAIL.

- [ ] **Step 3: Write `page/single.html`** (root-level content has type `page`, so `about.md` uses this)

```html
{{ define "main" }}
<p class="prompt-line"><span class="cmd">cat {{ .File.ContentBaseName }}.md</span></p>
<article class="post">
  <h1 class="post-title">{{ .Title }}</h1>
  <div class="post-body">{{ .Content }}</div>
</article>
{{ end }}
```

- [ ] **Step 4: Write `404.html`**

```html
{{ define "main" }}
<p class="prompt-line"><span class="cmd">cd <span class="nf-path">this-page</span></span></p>
<pre class="nf">zsh: command not found: <span class="nf-path">this-page</span>
[exit 127]</pre>
<p><a href="{{ "/" | relURL }}">cd ~</a> · <a href="{{ "posts/" | relURL }}">ls posts/</a></p>
<script>
  document.querySelectorAll('.nf-path').forEach(function (el) { el.textContent = decodeURIComponent(location.pathname); });
</script>
<style>.nf { color: var(--red); font-size: .9375rem; white-space: pre-wrap; }</style>
{{ end }}
```

- [ ] **Step 5: Delete LoveIt overrides**

```bash
git rm layouts/_default/about.html static/css/about.css assets/css/_custom.scss
```

- [ ] **Step 6: Run the check**

Run: `scripts/check-theme.sh`
Expected: `ALL PASS`.

- [ ] **Step 7: Commit**

```bash
git add themes/terminal scripts/check-theme.sh
git commit -m "feat(theme): about and 404 pages, drop LoveIt overrides"
```

---

### Task 5: Visual verification at desktop and mobile

**Files:** none created; fixes go into the CSS/template that owns the defect.

- [ ] **Step 1: Start the server**

Run (background): `hugo serve --disableFastRender -p 1313`

- [ ] **Step 2: Screenshot each page at 1280px and 375px** with the agent-browser skill:
`/`, `/posts/`, `/tags/`, `/categories/造物誌/`, `/es-reindex/`, `/mailquill-gmail-statements-to-ledger/`, `/dementia-disease/`, `/about/`, `/404.html`.

- [ ] **Step 3: Check against this list** (fix any failure in the owning file, re-run `scripts/check-theme.sh`):
  1. No horizontal page scroll at 375px (`document.documentElement.scrollWidth <= 375`).
  2. Powerline bar segments show arrow shapes; long path ellipsizes instead of pushing nav off-screen.
  3. Long CJK titles wrap in rows and post header; remote `featuredImage` (GitHub URL) fits width.
  4. Admonitions show colored `[LABEL]` and collapse on click.
  5. TOC is on the right at 1280px and a `tree .` `<details>` at 375px.

- [ ] **Step 4: Show screenshots to the author** and collect visual tweaks; apply them as separate commits.

- [ ] **Step 5: Commit any fixes**

```bash
git add themes/terminal
git commit -m "style(theme): visual fixes from desktop/mobile review"
```

- [ ] **Step 6: Tell the author to fill `data/career.yaml`** (PIXNET period/role are seeded guesses from the 2018 ModernWeb talk).
