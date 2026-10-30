#!/bin/zsh
# builds index.html for GitHub Pages: the artifact file (no doctype, by the artifact contract) wrapped as a standalone document
cd "$(dirname "$0")"
python3 - <<'PY'
s = open('gesso-ghost-dogs.html').read()
head = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">'
        '<meta name="description" content="Gesso & the Ghost Dogs: an open-world art-book game. A plaster figure and his ghost dogs cross a painted plain where ink rises by night.">'
        '<meta property="og:title" content="Gesso &amp; the Ghost Dogs"><meta property="og:description" content="A wandering game in eight plates (or nine). Play in the browser.">'
        '<meta name="theme-color" content="#1d1912"></head><body>\n')
open('index.html', 'w').write(head + s + '\n</body></html>')
print('index.html', len(s))
PY
