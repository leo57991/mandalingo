# Version Strategy

Mandalingo is one Godot repository with shared systems. The 2D baseline and the active 2.5D version are separated by Git history, main scenes, and scene integration points rather than by separate Godot projects.

## Active Development Target

The 2.5D version is the current implementation target.

- Development line starts from: `experiment/2.5d-grocery-store`
- Current feature branch: `feature/status-menu-spell-entry`
- Main scene: `res://Scenes/World/GroceryStore25D.tscn`
- Scene script: `res://Scripts/World/GroceryStore25D.gd`
- `project.godot` currently runs the 2.5D main scene.

New player-facing features should be integrated into the 2.5D scene unless a task explicitly states otherwise. Examples include the status menu, spell input, 2.5D HUD, interaction prompts, HD-2D presentation, and vertical-slice flow.

## 2D Baseline

The 2D version is the finalized gameplay-validation baseline and fallback reference.

- Main scene: `res://Scenes/World/GroceryStore.tscn`
- Scene script: `res://Scripts/World/GroceryStore.gd`
- Purpose: preserve the original immersion-learning prototype for comparison and regression reference.

Do not modify the 2D baseline scene or its scene script unless the user explicitly requests a 2D change.

## Shared Foundation

Reusable gameplay data and services should remain scene-independent and compatible with both versions when practical.

Shared areas include:

- `res://Scripts/Systems/`
- `res://Data/Vocabulary/`
- reusable UI scenes and components
- `DataManager`
- `TelemetryManager`
- `VocabularyDatabase`
- future reusable services such as save, inventory, clue, spell-entry, and player-vocabulary state managers

Shared systems must not depend on internal nodes or variables from `GroceryStore25D`. The 2.5D scene script should load components, connect signals, and coordinate scene-specific flow rather than own reusable domain logic.

## Implementation Rules

Before editing Mandalingo:

1. Confirm whether the task targets 2D, 2.5D, or a shared system.
2. Default to the 2.5D version when the task does not explicitly target 2D.
3. Keep 2.5D-only scene wiring in `GroceryStore25D.tscn` or `GroceryStore25D.gd`.
4. Keep reusable state and domain logic out of scene scripts.
5. Do not modify `GroceryStore.tscn` or `GroceryStore.gd` without an explicit request.
6. Run the 2.5D smoke test after 2.5D integration changes.
7. When changing shared systems, verify that the 2D baseline still loads when practical.

## Agent Task Header

Future coding tasks may use this standard instruction:

> Read `Docs/VERSION_STRATEGY.md` first. This task targets the 2.5D version unless explicitly stated otherwise. Do not modify the old 2D baseline scene or script.
