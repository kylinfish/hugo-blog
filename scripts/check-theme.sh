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
  [ "$(basename "$f")" = _index.md ] && continue
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
echo "== task 3: homepage"
has index.html '<span class="cmd">whoami</span>'
has index.html '<span class="cmd">traceroute career</span>'
has index.html 'class="hop is-current"'
has index.html 'RHINOSHIELD'
has index.html '<span class="cmd">ls -lt posts/ \| head -8</span>'
has index.html '<span class="cmd">ls ~/projects</span>'
has index.html 'class="project"'
has index.html 'href="https://github.com/kylinfish"'
echo "== task 4: about + 404 + cleanup"
has about/index.html 'cat about\.md'
lacks about/index.html 'class="pl pl-meta"'
has 404.html 'command not found'
lacks about/index.html 'about\.css'
if [ -e layouts/_default/about.html ] || [ -e assets/css/_custom.scss ]; then fail "LoveIt overrides removed"; else pass "LoveIt overrides removed"; fi
echo "== final fixes"
lacks beautify_slides/index.html '<figcaption>[^<]*<h4'
has beautify_slides/index.html 'class="fig-title"'
if grep -q '\.post-body h1::before' themes/terminal/assets/css/post.css; then pass "body h1 style"; else fail "body h1 style"; fi
if grep -q -- '--muted:#' "$OUT"/css/bundle.min.*.css; then pass "muted token in bundle"; else fail "muted token in bundle"; fi
has es-reindex/index.html 'rel="canonical" href="https://kylinyu.win/es-reindex/"'
has es-reindex/index.html 'name="twitter:card"'
if grep -q 'position: static' themes/terminal/assets/css/terminal.css; then pass "mobile header static"; else fail "mobile header static"; fi
lacks index.xml '<title>About Win Yu</title>'
if [ "$(grep -c '<item>' "$OUT/index.xml")" -le 20 ]; then pass "rss <= 20 items"; else fail "rss <= 20 items"; fi
if grep -q LoveIt Makefile; then fail "Makefile LoveIt gone"; else pass "Makefile LoveIt gone"; fi
if grep -q '6\.5rem' themes/terminal/assets/css/home.css; then pass "hop period column"; else fail "hop period column"; fi
echo "== seo"
has index.html '<title>墨冊 · '
has index.html '"@type":"WebSite"'
has es-reindex/index.html '"@type":"BlogPosting"'
has es-reindex/index.html 'property="og:site_name" content="墨冊"'
has es-reindex/index.html 'property="article:published_time"'
has es-reindex/index.html 'class="post-cover" src="[^"]+" alt="ElasticSearch'
if [ "$(grep -o '<h1' "$OUT/es-reindex/index.html" | wc -l | tr -d ' ')" = 1 ]; then pass "es-reindex single h1"; else fail "es-reindex single h1"; fi
has about/index.html 'property="og:image" content="https://kylinyu.win/img/aboutme'
has posts/index.html '<title>所有文章 · 墨冊'
has posts/page/2/index.html '<title>所有文章 · 第 2 頁 · 墨冊'
has tags/index.html '<title>標籤 · 墨冊'
has tags/mysql/index.html '<title>標籤：MySQL · 墨冊'
has tags/mysql/index.html 'name="description" content="標籤「MySQL」的 [0-9]+ 篇文章'
lacks tags/mysql/index.html 'noindex'
has lumen_tinker/index.html 'name="description" content="Lumen 不像 Laravel'
has 404.html 'name="robots" content="noindex,follow"'
lacks sitemap.xml '/404.html'
has sitemap.xml '<loc>https://kylinyu.win/es-reindex/</loc>'
noalt="$(cat "$OUT"/*/index.html | grep -o '<img [^>]*>' | grep -cv 'alt="[^"]')"
if [ "$noalt" -eq 0 ]; then pass "every img has alt"; else fail "every img has alt ($noalt missing)"; fi
if grep -q 'rewrites' firebase.json; then fail "no SPA rewrite in firebase.json"; else pass "no SPA rewrite in firebase.json"; fi
if grep -q 'Sitemap: https://' robots.txt; then pass "robots sitemap https"; else fail "robots sitemap https"; fi

echo "== color schemes"
has index.html "localStorage.getItem\('theme'\)"
has index.html 'id="cs-list"'
if [ "$(grep -o 'role="option"' "$OUT/index.html" | wc -l | tr -d ' ')" = 7 ]; then pass "7 scheme options (auto + 6)"; else fail "7 scheme options (auto + 6)"; fi
has index.html 'class="cmdline"'
if [ "$(grep -oE 'data-theme=[a-z-]+' "$OUT"/css/bundle.min.*.css | sort -u | wc -l | tr -d ' ')" = 6 ]; then pass "6 schemes in css bundle"; else fail "6 schemes in css bundle"; fi
if grep -q 'prefers-color-scheme:light' "$OUT"/css/bundle.min.*.css; then pass "no-JS light fallback"; else fail "no-JS light fallback"; fi
if grep -qE '#[0-9a-fA-F]{3,6}\b' themes/terminal/assets/css/terminal.css themes/terminal/assets/css/post.css themes/terminal/assets/css/home.css; then fail "no hard-coded colors outside colorschemes.json"; else pass "no hard-coded colors outside colorschemes.json"; fi
if python3 -I scripts/check-contrast.py >/dev/null; then pass "wcag contrast for every scheme"; else fail "wcag contrast for every scheme"; fi

# --- assertions above this line ---

echo
if [ "$FAILS" -eq 0 ]; then echo "ALL PASS"; else echo "$FAILS FAILED"; exit 1; fi
