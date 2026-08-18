# Animal Mayhem 2.0 — Assets

## Policy

₹0 budget. No purchased packs. No unknown-license downloads. No copyrighted game or film audio, models, or textures.

If a license cannot be fully verified, the asset is not used.

## External textures (Poly Haven, CC0)

All of the following are from [Poly Haven](https://polyhaven.com/). License: **CC0 1.0 Universal**.

Modify: Yes. Commercial use: Yes. Redistribution in APK: Yes. Attribution: not required (listed for provenance).

| Asset | Source | License |
| --- | --- | --- |
| Forest Ground 04 | https://polyhaven.com/a/forest_ground_04 | CC0 |
| Grass Path 3 | https://polyhaven.com/a/grass_path_3 | CC0 |
| Bark Brown 01 | https://polyhaven.com/a/bark_brown_01 | CC0 |
| Bark Willow | https://polyhaven.com/a/bark_willow | CC0 |
| Mossy Rock | https://polyhaven.com/a/mossy_rock | CC0 |
| Leafy Grass | https://polyhaven.com/a/leafy_grass | CC0 |
| Brown Mud 03 | https://polyhaven.com/a/brown_mud_03 | CC0 |
| Forest Leaves 03 | https://polyhaven.com/a/forest_leaves_03 | CC0 |
| Rock Wall 02 | https://polyhaven.com/a/rock_wall_02 | CC0 |
| Aerial Rocks 02 | https://polyhaven.com/a/aerial_rocks_02 | CC0 |
| Rainforest Trail HDRI | https://polyhaven.com/a/rainforest_trail | CC0 |

1K JPG/HDR variants. Maps: albedo (`diff`), OpenGL normal (`nor_gl`), roughness (`rough`).

## Animal 3D assets — audit (PR #18)

Searched for verified realistic/semi-realistic buffalo, monkey, and snake GLTF/GLB suitable for commercial APK redistribution.

| Candidate | Why not used |
| --- | --- |
| Poly Haven wildlife/mammals models | **0 results** for buffalo, monkey, or snake (https://polyhaven.com/models/nature/wildlife/mammals) |
| OpenGameArt “Monkey 3D model” (tomk) | Tagged **cartoon**; from another game (“Kill Monkey”) — excluded |
| Quaternius / Poly Pizza snake | **Low-poly cartoon**, not realistic |
| Sketchfab bison/monkey collections | License not uniformly CC0 / not fully verifiable without account scraping |
| Smithsonian 3D | CC0 bone/skull fragments, not complete textured animals |

**No external animal mesh was added.** Licensing was not compromised for screenshots.

Playable animals remain **constructed in `AnimalVisuals.build()`** (Godot meshes) plus **project-generated** albedo maps:

### Buffalo (constructed)

- Asset: project-owned assembled mesh + `buffalo_hide.png`
- Species: water-buffalo / Cape-buffalo silhouette (not a scanned species)
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Attribution required: No
- Notes: Hide map is generated noise/streaks, not a photo scan. Not photoreal GLTF.

### Monkey (constructed)

- Asset: project-owned assembled mesh + `monkey_fur.png`
- Species: macaque-like silhouette
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Notes: Fur map is generated; no hair cards / groom.

### Snake (constructed)

- Asset: project-owned overlapping capsule body + `snake_scales.png`
- Species: generic colubrid silhouette
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Notes: Scale map is a generated diamond lattice. Body is a deformed tube mesh (`SnakeTube`), not a visible capsule chain. Slither is procedural.

## PR #19 audio

| File | Origin | License |
| --- | --- | --- |
| `sfx_campfire.wav` | Generated for this project (procedural crackle) | project-owned |

`music_exploration.wav` remains original and was not replaced. Music volume is lowered so ambience stays audible.

Substitution path (unchanged): instance a licensed GLTF from `AnimalVisuals.build()` without changing movement, abilities, or mission scripts.

## Environment meshes

Hero locations (camp, trail, fallen tree, climb rocks, river, snake gap, vine gate, explorer clearing) are **authored in-engine** using the CC0 maps above. They are not photogrammetry scenes. Poly Haven 3D **models** (trees/rocks GLB) were not bundled: the files API was not available in this environment and cartoon packs were rejected.

## Audio

Original project WAVs in `assets/audio/`. `music_exploration.wav` was not replaced.

## UI

Godot Control nodes only.

## Not used

- Ripped PUBG / BGMI / GTA / movie assets
- Unknown-license marketplace GLTF
- Cartoon animal packs
- Commercial music
