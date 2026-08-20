# Visual validation — PR #20 / PR #21

Animals are **semi-realistic constructed meshes**, not photogrammetry. A suitable licensed realistic animal GLTF was not available.

## PR #21 shots (Godot 4.4.1)

Partial X11 window grabs were saved under `animal_mayhem_2/visual_validation/pr21/` for camp views only (`01`, `02`, `03`, `05`, `10`). Landmark shots (`04`, `06`–`09`) were **not** captured: sending WASD into the Godot window from this environment did not reliably walk to mission props.

These files are **not** a visual sign-off. Capture the missing shots locally:

1. Install Godot **4.4.1**.
2. Open `animal_mayhem_2/` and press Play (`F5`).
3. Wait until the intro overlay fades (~4s).
4. Capture the **game window** (not the editor 3D dock).
5. Save into `animal_mayhem_2/visual_validation/pr21/`:

| File | Animal | Location | Status |
| --- | --- | --- | --- |
| `01_buffalo.png` | 1 Buffalo | Camp | partial X11 grab |
| `02_monkey.png` | 2 Monkey | Camp | partial X11 grab |
| `03_snake.png` | 3 Snake | Camp | partial X11 grab |
| `04_jungle.png` | Buffalo | Trail ~x=8 | **manual** |
| `05_camp.png` | Any | Explorer camp, tent + fire | partial X11 grab |
| `06_river.png` | Any | River / bridge ~x=26, z=-9 | **manual** |
| `07_buffalo_push.png` | Buffalo | Fallen tree ~x=12.5 | **manual** |
| `08_monkey_climb.png` | Monkey | Climb rocks ~24.5, 12 | **manual** |
| `09_snake_coil.png` | Snake | Coil post ~33.8, -8.5 | **manual** |
| `10_full_gameplay.png` | Buffalo | Camp, full HUD | partial X11 grab |

Do not treat headless output as visual evidence.

## Automated capture (optional)

```bash
export AM2_SCREENSHOT=/tmp/am2_A.png AM2_SHOT=A
godot --path animal_mayhem_2 --quit-after 8
```

`AM2_SHOT` letters A–J match the PR #20 table below.

## Local manual shots (Godot 4.4.1 editor)

Open `animal_mayhem_2/`, Play (`F5`), wait for the intro overlay to fade. Capture the window (not the editor 3D preview). Keep the PR #19 camera (buffalo ~25–40% of screen height, jungle visible).

| Shot | Animal | Where | What to check |
| --- | --- | --- | --- |
| A | Buffalo (1) | Camp | Recognizable buffalo, grounded hooves, hide not plastic |
| B | Monkey (2) | Camp | Macaque-like silhouette, not a capsule toy |
| C | Snake (3) | Camp | Head + tapered body, not a pipe chain |
| D | Buffalo | Fallen tree (~x=12.5) | Scale vs obstacle, PUSH still works |
| E | Monkey | Climb rocks (~24.5, 12) | Feet on rocks, CLIMB still works |
| F | Snake | Coil post (~33.8, -8.5) | Grounded slither, COIL still works |
| G | Any | Explorer camp | Tent, fire, compact HUD |
| H | Any | River / bridge | Water, bank, atmosphere |
| I | Buffalo | Jungle trail (~x=8) | Layered trees, no grass cards |
| J | Buffalo | Camp gameplay | Full HUD: objective, joystick, portraits, pause |

## Pass criteria (honest)

PASS only if the screenshot supports: recognizable animal, not cartoon primitives, not a pipe, readable size, environment in frame, grounded, natural materials, compact HUD.

Do **not** claim photorealism or commercial-quality from code compile alone.
