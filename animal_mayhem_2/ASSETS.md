# Animal Mayhem 2.0 — Phase 1 assets

## Policy

₹0 budget. No purchased packs. No unknown-license downloads. No copyrighted game or film audio.

## 3D models

Playable animals and jungle set dressing are **generated in-engine** from Godot primitive meshes (capsules, spheres, cylinders, boxes) plus StandardMaterial3D / a small water shader.

This is a **clean substitution interface**:

- `AnimalVisuals.build(kind, parent)` — replace with GLTF instances later.
- `JungleBuilder` — replace terrain/trees with authored scenes later.

Status: **temporary production stand-in**, not final commercial art. Silhouettes are meant to read as buffalo / monkey / snake, not as cartoon icons.

## Audio

All files in `assets/audio/` were synthesized for this project (Python stdlib `wave`). They are original to Animal Mayhem 2.0.

| File | Use |
| --- | --- |
| `music_exploration.wav` | Jungle exploration music (original pentatonic pad + melody) |
| `jungle_ambience.wav` | Birds / wind / insects bed |
| `water_loop.wav` | River proximity |
| `sfx_*.wav` | Footsteps, push, climb, coil, gate, switch, complete, animal cues |

Not PUBG, film, or other-game music. Not a famous melody.

## UI

Drawn with Godot Control nodes. No third-party UI kits.

## Future replacement

Drop licensed CC0 / purchased realistic animals into `assets/animals/` and point `AnimalVisuals` at them without changing ability or mission scripts.
