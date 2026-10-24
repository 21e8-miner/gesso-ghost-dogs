#!/opt/homebrew/bin/python3.14
# compare.py out/frame.jpg [out/compare.jpg] -> side-by-side with ref/painting.jpg plus matched-region colour stats
import sys, colorsys, numpy as np
from PIL import Image
a = Image.open('ref/painting.jpg').convert('RGB'); b = Image.open(sys.argv[1]).convert('RGB')
out = sys.argv[2] if len(sys.argv) > 2 else 'out/compare.jpg'
h = 560; a2 = a.resize((int(a.width * h / a.height), h)); b2 = b.resize((int(b.width * h / b.height), h))
sb = Image.new('RGB', (a2.width + b2.width + 10, h), 'black'); sb.paste(a2, (0, 0)); sb.paste(b2, (a2.width + 10, 0)); sb.save(out, quality=90)
def stats(im):
    x = np.asarray(im.resize((320, 272))).astype(float) / 255; hs = np.array([colorsys.rgb_to_hsv(*p) for p in x[::2, ::2].reshape(-1, 3)])
    return hs[:, 1].mean(), np.median(hs[:, 2]), np.percentile(hs[:, 2], 5), np.percentile(hs[:, 2], 95), x.reshape(-1, 3).mean(0)
for name, im in (('painting', a), ('frame', b)):
    s, v, v5, v95, m = stats(im); print(f'{name:9s} mean sat {s:.2f}  median val {v:.2f}  p5 {v5:.2f}  p95 {v95:.2f}  mean rgb #{int(m[0]*255):02x}{int(m[1]*255):02x}{int(m[2]*255):02x}')
print('wrote', out)
