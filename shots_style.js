// headless shot list for the painting-match pass: title, day, dusk, night (frames go to out/ via the receiver on :8804)
(async () => {
  const D = __dbg, tick = () => new Promise(r => setTimeout(r, 0));
  const run = async (n, f) => { for (let i = 0; i < n; i++) { if (f) f(); D.step(0.033); if (i % 5 === 0) await tick(); } };
  for (const id of ['hud', 'tools']) { const e = document.getElementById(id); if (e) e.style.visibility = 'hidden'; }
  document.getElementById('title').style.visibility = 'hidden'; D.S.t = 0; await run(30); await D.shot('hl_title.jpg');
  document.getElementById('title').style.visibility = ''; document.getElementById('bStart').click();
  D.S.riding = false; D.S.clock = 0.3 * 420; D.P.x = 40; D.P.z = 60; const d = D.W.dogs[0];
  const cam = () => { d.x = D.P.x + 1.6; d.z = D.P.z + 0.9; D.camS.yaw = D.P.head + Math.PI * 0.7; D.camS.tdist = 4.2; D.camS.pitch = 0.18; D.camS.lastDrag = D.S.t; D.S.cineT = 0; };
  await run(24, cam); await D.shot('hl_day.jpg');
  D.S.clock = 0.5 * 420; await run(16, cam); await D.shot('hl_dusk.jpg');
  D.S.clock = 0.78 * 420; await run(16, cam); await D.shot('hl_night.jpg');
  const gl = D.renderer.getContext(), c = document.getElementById('game');
  return { lost: gl.isContextLost(), canvas: [c.width, c.height], pr: D.renderer.getPixelRatio(), errs: window.__E, passes: D.composer && D.composer.passes.map(p => (p.constructor.name || 'anon') + ':' + p.enabled) };
})()
