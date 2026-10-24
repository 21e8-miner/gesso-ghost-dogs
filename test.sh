#!/bin/zsh
# builds test.html: doctype wrapper, early error capture, and the __dbg hook (dbg_hook.js) swapped in for the SAVE_KEY line
cd "$(dirname "$0")"
python3 - <<'PY'
s = open('gesso-ghost-dogs.html').read()
a = "const SAVE_KEY = 'gesso-ghost-dogs-v2';"
assert s.count(a) == 1, 'SAVE_KEY anchor missing'
s = s.replace(a, open('dbg_hook.js').read().strip())
head = '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><script>window.__E=[];window.addEventListener("error",e=>__E.push(String(e.error&&e.error.stack||e.message).slice(0,1200)))</script></head><body>\n'
open('test.html', 'w').write(head + s + '</body></html>')
PY
