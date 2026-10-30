# Gesso & the Ghost Dogs

**Play:** https://21e8-miner.github.io/gesso-ghost-dogs/

An open-world art-book game in one HTML file. A plaster figure called Gesso and his ghost dogs cross a painted plain where old machines still roll and ships fly the same loops overhead. Gather the green seams, read the plates, find the lost dogs, and whitewash the ink that rises out of the plain by night. Everything is drawn in code after a single painting: no textures or sounds are loaded from anywhere.

## Controls

| Key | |
| --- | --- |
| **W A S D** · Shift | Walk, run. Drag to look, scroll to zoom. |
| **Space** | Whistle. The dogs sniff out seams, or go for the ink in a fight. |
| **E** | Read a plate or a note, talk, call a lost dog, pet a dog. |
| **Right mouse** · click | Aim over the shoulder and throw gesso. **F** throws at the nearest ink. |
| **Q** | Still Life: time nearly stops; sweep the sights to mark the ink, then let fly. |
| **R** · **C** · **M** · **G** · **P** | Ride · side camera · map · wardrobe · take a plate (saves a picture). |

On a phone, drag the left side to walk and the right side to look; buttons appear for the rest.

## Under the hood

three.js r128, a single file. Painterly post chain (anisotropic Kuwahara, visibility-bitmask GI with one bounce, a measured tone curve from the painting), generative string score after Mahler's Second in native WebAudio, and a world that stays an underdrawing until you walk it.

`gesso-ghost-dogs.html` is the source, published as-is to the claude.ai artifact; `./pages.sh` wraps it as `index.html` for GitHub Pages. `./test.sh` builds a debug page for the headless harness.
