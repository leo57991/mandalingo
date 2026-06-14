# Google Drive Playtest Telemetry

The prototype sends consented anonymous gameplay events from the GitHub Pages build to a Google Apps Script Web App. The script writes each event to a Google Sheet stored in Google Drive.

## Data Collected

- Random session ID generated for the current game session.
- Event timestamp and elapsed session time.
- NPC or shelf interactions.
- Vocabulary IDs, seen counts, and encounter locations.
- Notebook opens.
- Whether a guess was entered and its character count.

The game does not transmit the guess text, player name, email, Google identity, or browsing history.

## Google Sheet Setup

1. Create or open the Google Sheet that will receive playtest events.
2. Open **Extensions > Apps Script**.
3. Replace the editor contents with `Integrations/GoogleAppsScript/Code.gs`.
4. Save the project.
5. Select **Deploy > New deployment > Web app**.
6. Set **Execute as** to yourself.
7. Set access to **Anyone** so anonymous GitHub Pages players can submit events.
8. Deploy and copy the production URL ending in `/exec`.

The Apps Script endpoint is public by necessity. The receiver limits payload size, accepts only known event names, and protects the sheet against formula injection, but it cannot strongly authenticate a public browser game.

## Godot Configuration

Edit the `[telemetry]` section in `project.godot`:

```ini
[telemetry]

enabled=true
endpoint_url="https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"
build_id="prototype-v0.1"
consent_version=1
```

Commit and push the configuration change. GitHub Actions will publish the endpoint in the next Pages build.

## Consent Behavior

When telemetry is configured, first-time players see a consent prompt before gameplay. Their choice is stored locally in `user://telemetry_consent.cfg`.

- Accepting begins anonymous event submission.
- Declining disables submission.
- With telemetry disabled or no endpoint URL, the prompt does not appear and no data is sent.

## Event Rows

The Apps Script creates an `Events` sheet with these columns:

`server_received_at`, `client_timestamp`, `session_id`, `build_id`, `event_name`, `elapsed_ms`, `target`, `target_kind`, `vocab_id`, `vocab_ids`, `location`, `seen_count`, `guess_length`, `has_guess`, `details_json`

The event names are:

- `session_start`
- `interaction`
- `vocabulary_seen`
- `notebook_opened`
- `guess_updated`
