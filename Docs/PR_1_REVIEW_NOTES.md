# PR #1 Integration Review Notes

Reviewed on 2026-06-21.

## Pull Request

- Base: `main`
- Head: `integration/rune-and-status-menu`
- State: Draft
- Scope: large integration PR, not a single-feature PR

## Version Strategy

`main` originally represents the finalized 2D baseline. PR #1 changes the active
main scene to `res://Scenes/World/GroceryStore25D.tscn` for ongoing 2.5D
development.

The 2D baseline scene and script are not modified by this PR:

- `Scenes/World/GroceryStore.tscn`
- `Scripts/World/GroceryStore.gd`

## project.godot Review

- `run/main_scene` points to `res://Scenes/World/GroceryStore25D.tscn`.
- `DataManager` is registered as an Autoload.
- `DataManager` appears before `TelemetryManager` in the Autoload list.
- This ordering supports the architecture decision that DataManager is the
  canonical local player-event ledger and TelemetryManager owns consent and
  remote delivery.

## DataManager Review

The current specialized player-event entry points are:

- `track_rune_judgement`
- `track_rune_spell_success`
- `track_tocfl_level_unlocked`
- `track_interactable_reaction`

Future learning analytics remain documented TODOs rather than implemented
statistical systems:

- `failed_attempts_brute_force`
- `highest_failure_chars`
- `object_stall_duration`

## Validation Status

The following local validation passed before this review:

- `RuneSystemTest`
- `DataManagerTest`
- `InteractionSystemTest`
- Godot headless startup and parse validation
- `git diff --check`

Until a GitHub Actions validation workflow is added and executed, GitHub PR
checks may remain at zero. Do not claim that CI passed unless GitHub checks
actually run and complete successfully.

## Godot Sidecar Audit

PR #1 adds 22 `.uid` files. Each maps to an existing Godot script; no orphan
UID sidecars were found:

- `Scripts/Actors/NPCController3D.gd.uid`
- `Scripts/Actors/PlayerController3D.gd.uid`
- `Scripts/Resources/InteractableReaction.gd.uid`
- `Scripts/Resources/SpellPattern.gd.uid`
- `Scripts/Runes/CharToWordJudge.gd.uid`
- `Scripts/Runes/RuneJudge.gd.uid`
- `Scripts/Runes/RuneJudgeResult.gd.uid`
- `Scripts/Runes/RuneStateMachine.gd.uid`
- `Scripts/Runes/WordToSentenceJudge.gd.uid`
- `Scripts/Systems/DataManager.gd.uid`
- `Scripts/Systems/InteractableReactionMatcher.gd.uid`
- `Scripts/Systems/InteractionTarget3D.gd.uid`
- `Scripts/Systems/TocflProgressionManager.gd.uid`
- `Scripts/UI/EquipmentTab.gd.uid`
- `Scripts/UI/SpellsTab.gd.uid`
- `Scripts/UI/StatsTab.gd.uid`
- `Scripts/UI/StatusMenuUI.gd.uid`
- `Scripts/World/GroceryStore25D.gd.uid`
- `Tests/DataManagerTest.gd.uid`
- `Tests/Prototype25DSmokeTest.gd.uid`
- `Tests/RuneSystemTest.gd.uid`
- `Tests/StatusMenuTest.gd.uid`

None of these paths point to `build`, `test_build`, export output, or another
temporary artifact directory.

PR #1 also adds two normal Godot texture import sidecars:

- `Assets/Sprites/HD2D/assistant_hd2d.png.import`
- `Assets/Sprites/HD2D/player_hd2d.png.import`

Both import files correspond to existing HD2D PNG assets. Godot sidecar files
reviewed; no orphan sidecar files found; import files correspond to existing
HD2D PNG assets.

## Deploy Workflow Strategy

`.github/workflows/deploy.yml` currently listens only for pushes to
`experiment/2.5d-grocery-store`. It also retains `workflow_dispatch` for manual
deployment.

Consequently, merging PR #1 into `main` will not make a subsequent `main` push
automatically deploy GitHub Pages. This is an explicit pending decision and is
not changed as part of the PR readiness work.

## Pre-Merge Recommendation

- Keep PR #1 in Draft until a GitHub validation workflow produces results.
- If the new GitHub Actions validation succeeds, consider marking the PR ready
  for review.
- Do not merge directly without reviewing the integration diff and validation
  results.
