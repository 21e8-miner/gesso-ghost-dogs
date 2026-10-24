// headless Chrome (software GL) over CDP: node hl.mjs <url> <script.js> [--w 1280 --h 800 --dpr 1.75 --timeout 900]
// waits for __dbg.S.ready, then evaluates the async script file in the page and prints its result
import { spawn } from 'node:child_process';
import fs from 'node:fs'; import path from 'node:path'; import os from 'node:os';
const [url, scriptFile, ...rest] = process.argv.slice(2), opt = {};
for (let i = 0; i < rest.length; i += 2) opt[rest[i].replace(/^--/, '')] = rest[i + 1];
const W = +(opt.w || 1280), H = +(opt.h || 800), DPR = +(opt.dpr || 1.75), TIMEOUT = +(opt.timeout || 900) * 1000;
const sleep = ms => new Promise(r => setTimeout(r, ms));
const prof = fs.mkdtempSync(path.join(os.tmpdir(), 'gessohl_')), port = 9400 + Math.floor(Math.random() * 500);
const ch = spawn('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', ['--headless=new', `--user-data-dir=${prof}`, '--no-first-run', '--use-angle=swiftshader',
  '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist', '--disable-background-timer-throttling', `--remote-debugging-port=${port}`, 'about:blank'], { stdio: 'ignore' });
let code = 1;
try {
  let tgt = null;
  for (let i = 0; i < 60 && !tgt; i++) { await sleep(500); try { tgt = (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json()).find(t => t.type === 'page'); } catch (e) {} }
  const ws = new WebSocket(tgt.webSocketDebuggerUrl); await new Promise((r, j) => { ws.onopen = r; ws.onerror = j; });
  let id = 0; const pend = new Map(), logs = [];
  ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pend.has(d.id)) { const p = pend.get(d.id); pend.delete(d.id); d.error ? p.j(new Error(JSON.stringify(d.error))) : p.r(d.result); }
    else if (d.method === 'Runtime.exceptionThrown') logs.push('EXC ' + (d.params.exceptionDetails.exception || {}).description);
    else if (d.method === 'Runtime.consoleAPICalled' && /error|warn/.test(d.params.type)) logs.push(d.params.type + ' ' + d.params.args.map(a => a.value || a.description || '').join(' ')); };
  const send = (method, params = {}) => new Promise((r, j) => { const i = ++id; pend.set(i, { r, j }); ws.send(JSON.stringify({ id: i, method, params })); });
  const ev = async e => { const r = await send('Runtime.evaluate', { expression: e, awaitPromise: true, returnByValue: true }); if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception ? r.exceptionDetails.exception.description : r.exceptionDetails.text); return r.result.value; };
  await send('Runtime.enable'); await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: W, height: H, deviceScaleFactor: DPR, mobile: false });
  await send('Page.navigate', { url });
  let ready = false; for (let i = 0; i < 400 && !ready; i++) { await sleep(500); try { ready = await ev('!!(window.__dbg && window.__dbg.S.ready)'); } catch (e) {} }
  if (!ready) throw new Error('never ready: ' + await ev("document.getElementById('bStart').textContent").catch(() => '?'));
  const out = await Promise.race([ev(fs.readFileSync(scriptFile, 'utf8')), sleep(TIMEOUT).then(() => { throw new Error('timeout'); })]);
  console.log('RESULT', JSON.stringify(out)); if (logs.length) console.log('CONSOLE\n' + logs.slice(0, 15).join('\n')); code = 0;
} catch (e) { console.log('ERR', e.message); }
finally { try { ch.kill(); } catch (e) {} fs.rmSync(prof, { recursive: true, force: true }); process.exit(code); }
