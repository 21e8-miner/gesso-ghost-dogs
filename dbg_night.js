// headless bisect: which pass turns the night frame black? measures mean frame brightness with passes toggled
(async () => {
  const D = __dbg, gl = D.renderer.getContext(), tick = () => new Promise(r => setTimeout(r, 0));
  document.getElementById('bStart').click();
  D.S.riding = false; D.P.x = 40; D.P.z = 60;
  const px = new Uint8Array(4 * 64 * 40);
  const mean = () => { gl.readPixels(Math.floor(gl.drawingBufferWidth / 2) - 32, Math.floor(gl.drawingBufferHeight / 2) - 20, 64, 40, gl.RGBA, gl.UNSIGNED_BYTE, px); let s = 0; for (let i = 0; i < px.length; i += 4) s += px[i] + px[i + 1] + px[i + 2]; return +(s / (px.length / 4) / 3).toFixed(1); };
  const frame = async () => { for (let i = 0; i < 3; i++) { D.camS.lastDrag = D.S.t; D.S.cineT = 0; D.step(0.033); } return mean(); };
  const out = {};
  for (const [name, clock] of [['day', 0.3], ['dusk', 0.5], ['night', 0.78]]) {
    D.S.clock = clock * 420; for (let i = 0; i < 6; i++) { D.step(0.033); await tick(); }
    const row = { all: await frame() };
    const ps = D.composer.passes;
    for (let k = 1; k < ps.length - 1; k++) {
      const p = ps[k], r0 = p.render; p.render = function (r, w, rb) { if (this.needsSwap) { /* copy through */ const cp = D.composer.copyPass; cp.renderToScreen = false; cp.render(r, w, rb); } };
      row['skip_' + k + '_' + (p.constructor.name || 'anon')] = await frame(); p.render = r0;
    }
    out[name] = row; await tick();
  }
  return out;
})()
