# 2.5D Grocery Store Experiment

This branch tests whether a fixed-angle 3D space strengthens contextual Mandarin inference without changing the learning system.

## First Slice

- Orthographic 3D camera with a fixed three-quarter view.
- Camera-relative WASD movement and 3D collision.
- One clearly visible apple shelf.
- One stationary assistant, 小安, beside the shelf.
- E interaction with both the shelf and 小安.
- `蘋果` appears in world-space NPC speech and the existing object dialogue UI.
- Existing vocabulary, audio, telemetry, and notebook systems remain shared with the 2D baseline.

## Validation Question

Can a beginner connect `蘋果` to the visible apples and voluntarily repeat the interaction without translation, pinyin, or a quiz?

This slice intentionally excludes additional shelves, NPC movement, combat, progression, and new vocabulary.

## HD-2D Visual Trial

The current presentation trial uses an original HD-2D-inspired treatment without copying commercial game assets:

- Pixel-art characters stand inside the orthographic 3D store as billboarded `Sprite3D` nodes.
- Nearest-neighbor texture filtering preserves deliberate pixel edges.
- A checker-tile floor, low-poly apples, hard shadows, warm focal lighting, and light distance fog give the room a staged diorama quality.
- NPC identity labels and Chinese speech remain fixed-size and legible instead of being reduced to the world's pixel scale.
- The visual treatment must keep vocabulary objects immediately recognizable; atmosphere is secondary to contextual inference.

## Web Deployment

GitHub Pages deploys from the `experiment/2.5d-grocery-store` branch so the public prototype follows the 2.5D experiment without replacing the finalized 2D baseline on `main`.
