# Animal Mayhem 2.0 — Assets

## Policy

₹0 budget. No purchased packs. No unknown-license downloads. No copyrighted game or film audio, models, or textures.

If a license is unclear, the asset is not used.

## External textures (Poly Haven, CC0)

All of the following are from [Poly Haven](https://polyhaven.com/). License: **CC0 1.0 Universal**.

| Asset | Source | License | Modify | Commercial | Redistribute in APK |
| --- | --- | --- | --- | --- | --- |
| Forest Ground 04 (`forest_ground_04_*_1k.jpg`) | https://polyhaven.com/a/forest_ground_04 | CC0 | Yes | Yes | Yes |
| Grass Path 3 (`grass_path_3_*_1k.jpg`) | https://polyhaven.com/a/grass_path_3 | CC0 | Yes | Yes | Yes |
| Bark Brown 01 (`bark_brown_01_*_1k.jpg`) | https://polyhaven.com/a/bark_brown_01 | CC0 | Yes | Yes | Yes |
| Bark Willow (`bark_willow_*_1k.jpg`) | https://polyhaven.com/a/bark_willow | CC0 | Yes | Yes | Yes |
| Mossy Rock (`mossy_rock_*_1k.jpg`) | https://polyhaven.com/a/mossy_rock | CC0 | Yes | Yes | Yes |
| Leafy Grass (`leafy_grass_*_1k.jpg`) | https://polyhaven.com/a/leafy_grass | CC0 | Yes | Yes | Yes |
| Rainforest Trail HDRI (`rainforest_trail_1k.hdr`) | https://polyhaven.com/a/rainforest_trail | CC0 | Yes | Yes | Yes |

1K JPG/HDR variants were chosen for mobile size. Maps used: albedo (`diff`), OpenGL normal (`nor_gl`), roughness (`rough`).

CC0 does not require attribution. Poly Haven is listed here for provenance.

## Animal presentation (project-owned)

No CC0 photogrammetry buffalo / monkey / snake GLTF was available from Poly Haven’s animal set at the time of this pass.

Playable animals remain **constructed in `AnimalVisuals.build()`** from Godot meshes (capsules, spheres, cylinders) plus **project-generated** albedo maps:

| File | Use | Origin |
| --- | --- | --- |
| `assets/animals/textures/buffalo_hide.png` | Buffalo hide albedo | Generated for this project |
| `assets/animals/textures/monkey_fur.png` | Monkey fur albedo | Generated for this project |
| `assets/animals/textures/snake_scales.png` | Snake scale albedo | Generated for this project |

These maps improve roughness/color variation. They are **not** scanned animal skins and **not** a substitute for licensed realistic GLTF.

Status: **improved production stand-in**. Silhouettes, materials, scale, idle/walk motion, and shadows are the visual upgrade. Faces, fur cards, and muscle deformation are still simplified.

Substitution path (unchanged): drop licensed GLTF into `assets/animals/` and instance them from `AnimalVisuals.build()` without changing movement, abilities, or mission scripts.

## Environment meshes

Trees, rocks, grass cards, bushes, camp, river plane, bridge plank, vine gate, and landmarks are **generated in-engine** (`JungleBuilder`) using the CC0 PBR maps above. They are not photogrammetry tree/rock assets.

## Audio

All files in `assets/audio/` were synthesized for this project (original Animal Mayhem 2.0 generators). They are original to this game.

| File | Use |
| --- | --- |
| `music_exploration.wav` | Original exploration music (project-owned; not replaced) |
| `jungle_ambience.wav` | Birds / wind / insects bed |
| `water_loop.wav` | River proximity (volume eases with distance) |
| `sfx_*.wav` | Footsteps, push, climb, coil, gate, switch, complete, occasional animal cues |

Not PUBG, BGMI, film, or other-game music. Not a famous melody.

## UI

Drawn with Godot Control nodes. No third-party UI kits.

## Not used

- Copyrighted ripped game models
- PUBG / BGMI / movie character assets
- Cartoon marketplace animals with unclear licenses
- Commercial music or famous animal sound motifs
