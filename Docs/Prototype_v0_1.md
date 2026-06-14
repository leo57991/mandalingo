# Chinese Immersion RPG - Prototype v0.1

Goal: test whether complete beginners can acquire Chinese vocabulary through immersion, contextual clues, repetition, and audio.

This prototype deliberately avoids combat, progression systems, explicit quizzes, direct translation, and story-heavy content.

Workflow rule: every Godot project change made through Codex must be committed and pushed to GitHub. See `Docs/Workflow_Rules.md`.

## Environment

- 2D top-down grocery store.
- Entrance at the bottom.
- Counter on the right side.
- Three middle shelves:
  - Shelf A: apples.
  - Shelf B: tea.
  - Shelf C: water.

## Learning Loop

1. Explore the store.
2. Approach NPCs and objects.
3. Listen to Chinese speech.
4. Observe repeated context.
5. Infer meanings naturally.
6. Return to objects/NPCs voluntarily.

## Architecture Notes

- English exists only as internal metadata in vocabulary resources.
- Player-facing dialogue should remain Chinese-first.
- Audio paths are scaffolded but not yet populated.
- Placeholder geometry is intentionally simple until art direction begins.

## TODO

- Add voice recordings for each vocabulary entry.
- Replace placeholder polygons with final store art.
- Configure and deploy the Google Drive playtest telemetry endpoint.
- Add more environmental actions for natural inference.
