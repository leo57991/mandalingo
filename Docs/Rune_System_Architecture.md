# Rune System Architecture

The rune system is an isolated 2.5D prototype module. It is not connected to the legacy 2D grocery-store scene.

## Responsibilities

- `RuneJudge` defines the shared evaluation contract.
- `CharToWordJudge` evaluates exact character sequences without scene dependencies.
- `WordToSentenceJudge` evaluates word sequences against resource-defined spell slots.
- `RuneStateMachine` owns input and judgement state transitions.
- `TocflProgressionManager` tracks unique spell mastery and the 60% level threshold.
- `DataManager` remains the only entry point for player events and forwards consented events to `TelemetryManager`.

## Data-driven spells

`SpellPattern` resources define legal slot order and permitted vocabulary IDs. Adding a spell should require a new `.tres` resource, not a new conditional branch in a judge.

English spell names are internal metadata. Player-facing 2.5D UI should preserve the project's immersion rules and avoid exposing translations by default.
