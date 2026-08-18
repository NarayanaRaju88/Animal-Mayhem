# Visual validation — PR #20

Animals are **semi-realistic constructed meshes**, not photogrammetry. A suitable licensed realistic animal GLTF was not available.

## Automated capture

If GPU window capture works:

```bash
export AM2_SCREENSHOT=/tmp/am2_A.png AM2_SHOT=A
godot --path animal_mayhem_2 --quit-after 8
```

`AM2_SHOT` letters A–J match the shots below.

Headless mode does **not** produce a meaningful gameplay image. Do not treat a black/empty PNG as a pass.

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
