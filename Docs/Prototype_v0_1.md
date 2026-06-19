# Chinese Immersion RPG - Prototype v0.1

Goal: test whether complete beginners can acquire Chinese vocabulary through immersion, contextual clues, repetition, and audio.

Status: **2D baseline finalized on 2026-06-19.** This version is the comparison point for future presentation experiments.

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
- Prototype v0.1 active vocabulary is limited to `你好`, `這`, `是`, `蘋果`, `茶`, and `水`.
- Notebook discovery is explicit: a line only unlocks the vocabulary id assigned to that line, never arbitrary substrings inside the displayed text.
- A single dialogue line may explicitly mark multiple vocabulary ids. For example, `這是水` marks `這`, `是`, and `水`, while audio playback uses the final/primary id for that line.
- Pronouns and identity words such as `我`, `你`, `他`, `我們`, `你們`, `他們`, `人`, and `誰` are intentionally out of scope until the scene can provide stronger contextual evidence.

## 2.5D Experiment Boundary

The next prototype may replace the top-down 2D presentation with 2.5D, but it should preserve this version's learning hypothesis and content as closely as possible.

- Keep the grocery store, active vocabulary, NPC identities, dialogue intent, notebook rules, and interaction loop unchanged during the first 2.5D pass.
- Test whether depth, camera angle, character facing, object placement, and contextual actions make meanings easier or harder to infer.
- Keep vocabulary objects immediately recognizable and interactions readable without translation or pinyin.
- Do not add combat, progression, story systems, or additional vocabulary merely to justify the new presentation.
- Compare the 2.5D experiment against this baseline using voluntary re-interaction, plausible player guesses, guess revisions, and engagement time.

## TODO

- Add voice recordings for each vocabulary entry.
- Replace placeholder polygons with final store art.
- Run external playtests and review the consented telemetry in Google Drive.
- Add more environmental actions for natural inference.
