# Animal Mayhem 2.0

Phase 1 vertical slice: a **3D jungle animal adventure / puzzle** in Godot 4.

This is a new game direction. It is **not** a reskin of the Flutter/Flame rectangle puzzle in `animal_mayhem/`. Do not mix the two projects.

## Vision

Control a team of animals in a living jungle. Explore, switch animals, use abilities in the world, and complete a mission.

## Godot version

**Godot 4.4.1 stable** (Forward+/Mobile renderer; this project uses the **mobile** renderer for Android).

## Open the project

1. Install [Godot 4.4.1](https://godotengine.org/download/archive/4.4.1-stable/).
2. Import `animal_mayhem_2/` as a project (the folder that contains `project.godot`).
3. Press Play. Main scene: `scenes/main.tscn`.

Headless check (editor binary required):

```bash
godot --headless --path animal_mayhem_2 --import --quit
godot --headless --path animal_mayhem_2 --quit-after 2
```

## Run

- Editor: Play (`F5`).
- Desktop testing: WASD move, Space action, 1/2/3 switch animals, right-mouse or right-side drag to look.
- Mobile: left virtual joystick, right-side look drag, contextual action button, animal portraits.

## Export Android APK

1. In Godot: **Editor → Manage Export Templates** and install **4.4.1** templates.
2. Install Android SDK / JDK as required by Godot’s Android export docs.
3. Open **Project → Export**, preset **Android** (`export_presets.cfg`).
4. Package id: `com.animalmayhem.adventure`
5. Export debug APK (debug keystore is fine for Phase 1).

This environment does not ship Android export templates; export is intended on a Godot + Android SDK machine.

## Controls

| Action | Mobile | Editor |
| --- | --- | --- |
| Move | Left joystick | WASD |
| Look | Drag on the right half | Right-mouse drag |
| Ability | Contextual button (PUSH / CLIMB / COIL) | Space |
| Switch animal | Bottom portraits | 1 Buffalo, 2 Monkey, 3 Snake |
| Pause | II | II |

## Current animals

| Animal | Ability | Role |
| --- | --- | --- |
| Buffalo | Force / push | Clears the fallen tree |
| Monkey | Climb | Reaches the high rock |
| Snake | Narrow gap + coil | Slips the rock split and coils the post |

Meshes are **project-owned constructed animals** (`AnimalVisuals`) with generated hide/fur/scale maps. **No licensed photogrammetry animal GLTF** passed the PR #18 audit. Jungle materials use Poly Haven CC0 textures (including mud, leaves, rock wall). See `ASSETS.md`.

## Current mission

**The Lost Explorer**

Camp → blocked path (Buffalo push) → high rocks (Monkey climb) → narrow gap + coil post (Snake) → vine wall opens → reach the explorer → mission complete.

## Asset licensing

- Code, assembled animal meshes, shaders: project-owned.
- Jungle PBR textures and rainforest HDRI: Poly Haven, CC0 (listed in `ASSETS.md`).
- Animal albedo maps and all audio: original / project-generated.
- No purchased packs, no scraped images, no third-party characters.

See `ASSETS.md`.

## Known limitations

- Animal bodies are lofted constructed meshes (semi-realistic / realistic-inspired), not scanned GLTF. Faces and fur are simplified.
- Vegetation uses instanced / procedural meshes with CC0 tiling textures, not photogrammetry trees.
- Inactive animals wait in place (no follow-AI — out of visual-pass scope).
- One jungle, one mission, three animals — by design.
- Android APK is not built in this cloud environment (no export templates / SDK).

## Architecture

Gameplay, presentation, animals, world, mission, UI, and audio are separated under `scripts/` and `scenes/`. Abilities are small classes (`ForceAbility`, `ClimbAbility`, `CoilAbility`). Animal stats live in `AnimalDefinition` / `AnimalCatalog`.
