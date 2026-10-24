#!/opt/homebrew/bin/python3.14
# analyze.py file.wav -> levels, spectrum balance, spectrogram PNG
import sys, numpy as np
from scipy.io import wavfile; from scipy import signal; from PIL import Image
sr, x = wavfile.read(sys.argv[1]); x = x.astype(np.float64) / 32768; m = x.mean(1)
pk = np.abs(x).max(); rms = np.sqrt((x**2).mean())
f, t, S = signal.stft(m, sr, nperseg=4096, noverlap=3072); P = np.abs(S)**2; tot = P.sum()
cent = (f[:, None]*P).sum(0)/(P.sum(0)+1e-18)
print(f'peak {20*np.log10(pk):.1f} dBFS  rms {20*np.log10(rms):.1f} dBFS  clipped {(np.abs(x)>0.999).sum()}  centroid median {np.median(cent):.0f} Hz')
print('bands: ' + '  '.join(f'{a}-{b}Hz {100*P[(f>=a)&(f<b)].sum()/tot:.1f}%' for a, b in [(20,80),(80,250),(250,800),(800,2500),(2500,8000),(8000,24000)]))
fl = np.geomspace(30, 8000, 300); idx = np.searchsorted(f, fl).clip(0, len(f)-1)
img = 10*np.log10(P[idx]+1e-14); img = np.clip((img-(img.max()-75))/75, 0, 1)[::-1]
Image.fromarray((np.stack([img**0.8, img**1.5, img**3], -1)*255).astype(np.uint8)).resize((1200, 300)).save(sys.argv[1][:-4]+'_spec.png')
