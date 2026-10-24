#!/bin/zsh
# builds test.html (doctype wrapper + debug hook __dbg) from gesso-ghost-dogs.html
cd "$(dirname "$0")"
python3 - <<'PY'
s=open('gesso-ghost-dogs.html').read()
a="const SAVE_KEY = 'gesso-ghost-dogs-v2';"
s=s.replace(a,"const SAVE_KEY = 'dbg' + Math.random(); window.__dbg = { S, P, W, camS, get G(){ return G; }, get STEED(){ return STEED; }, step(dt){ update(dt); render(dt); }, cine(d,m){ cineStart(d,m); }, scene, camera, renderer, T, musicWav: (s, sc) => renderMusicWav(s, sc) };")
open('test.html','w').write('<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head><body>\n'+s+'</body></html>')
PY
