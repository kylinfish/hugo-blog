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
