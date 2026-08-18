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

## Animal 3D assets — audit (PR #20)

Suitable licensed realistic animal asset was not available.

Re-checked for verified GLTF/GLB buffalo, macaque/monkey, and snake meshes with clear commercial + modification + APK redistribution rights.

| Candidate | Why not used |
| --- | --- |
| Poly Haven wildlife/mammals models | **0 results** for buffalo, monkey, or snake |
| OpenGameArt “Monkey 3D model” (tomk) | Cartoon / other-game origin — excluded |
| Quaternius / Poly Pizza animals | Low-poly cartoon, not suitable |
| Sketchfab collections | License not uniformly CC0 / not fully verifiable |
| Smithsonian 3D | Bone/skull fragments, not complete animals |
| PUBG / Fortnite / film / ripped packs | Forbidden |

**No external animal mesh was added.** Licensing was not compromised for screenshots.

Playable animals remain **constructed in `AnimalVisuals.build()`** using lofted/organic meshes (`OrganicMesh`, `SnakeTube`) plus **project-generated** albedo and normal maps.

These are **semi-realistic / realistic-inspired** constructed animals, not photogrammetry and not photoreal.

### Buffalo (constructed, lofted)

- Asset: project-owned lofted mesh + `buffalo_hide.png` + `buffalo_hide_n.png`
- Species: water-buffalo / Cape-buffalo silhouette (not a scanned species)
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Attribution required: No
- Notes: Hide and normal maps are generated (noise/streaks), not a photo scan. Not a photoreal GLTF.

### Monkey (constructed, lofted)

- Asset: project-owned lofted mesh + `monkey_fur.png` + `monkey_fur_n.png`
- Species: macaque-like silhouette
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Notes: Fur maps are generated; no hair cards / groom.

### Snake (constructed, elliptical tube)

- Asset: project-owned deforming elliptical tube + lofted head + `snake_scales.png` + `snake_scales_n.png`
- Species: generic colubrid silhouette
- Source: Animal Mayhem 2.0
- Creator: project
- License: project-owned
- Commercial / modify / APK: Yes
- Notes: Scale maps are generated. Body is not a visible capsule chain. Coil remains driven by the existing COIL ability.

## Historical note (PR #18 / #19)

Earlier visual PRs reached the same licensing conclusion: no verified commercial-redistributable photogrammetry animals. PR #20 keeps that policy and upgrades constructed geometry, materials, and animation instead of importing unknown-license GLTF.

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
