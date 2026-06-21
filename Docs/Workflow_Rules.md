# Workflow Rules

## Version Target

Read `Docs/VERSION_STRATEGY.md` before editing the project.

- The 2.5D version is the default active development target.
- Do not modify `Scenes/World/GroceryStore.tscn` or `Scripts/World/GroceryStore.gd` unless the user explicitly requests a 2D change.
- Keep reusable systems scene-independent and place only 2.5D integration wiring in the 2.5D scene or scene script.

## GitHub Sync

Every Godot project change made through Codex must be committed and pushed to GitHub.

- Remote: `origin` (`https://github.com/leo57991/mandalingo.git`)
- Applies to scene files, scripts, resources, project settings, documentation, placeholder assets, and any other project-tracked files.
- Before ending a work session after making Godot changes, check the working tree, create an intentional commit, and push it to GitHub.
- If a push cannot be completed because of authentication, network, merge conflicts, or user approval requirements, report that clearly before ending the session.
- Do not discard local user changes in order to push.

## Godot MCP Tool Discovery

Before starting any Godot task, use `tool_search` to search for relevant Godot MCP tools, including run, debug, scene, node, and resource capabilities.

- Do not assume the initially visible tool list is complete.
- Prefer discovered Godot MCP tools when they fit the task.
- Perform this discovery before editing, running, debugging, or otherwise operating on the Godot project.
