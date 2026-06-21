const SHEET_NAME = 'Events';
const HEADERS = [
  'server_received_at',
  'client_timestamp',
  'session_id',
  'build_id',
  'event_name',
  'elapsed_ms',
  'target',
  'target_kind',
  'vocab_id',
  'vocab_ids',
  'location',
  'seen_count',
  'guess_length',
  'has_guess',
  'details_json',
];

const ALLOWED_EVENTS = new Set([
  'session_start',
  'interaction',
  'vocabulary_seen',
  'notebook_opened',
  'guess_updated',
  'rune_judgement',
  'rune_spell_success',
  'tocfl_level_unlocked',
  'shop_camera_initialized',
]);

function doGet() {
  return jsonResponse_({ ok: true, service: 'mandalingo-telemetry' });
}

function doPost(e) {
  try {
    const raw = e && e.postData ? e.postData.contents : '';
    if (!raw || raw.length > 20000) {
      throw new Error('Invalid payload size');
    }

    const payload = JSON.parse(raw);
    if (payload.source !== 'mandalingo' || !ALLOWED_EVENTS.has(payload.event_name)) {
      throw new Error('Unsupported telemetry event');
    }

    const properties = payload.properties || {};
    const row = [
      new Date(),
      safeCell_(payload.client_timestamp),
      safeCell_(payload.session_id),
      safeCell_(payload.build_id),
      safeCell_(payload.event_name),
      numberOrBlank_(payload.elapsed_ms),
      safeCell_(properties.target),
      safeCell_(properties.target_kind),
      safeCell_(properties.vocab_id),
      safeCell_((properties.vocab_ids || []).join(',')),
      safeCell_(properties.location),
      numberOrBlank_(properties.seen_count),
      numberOrBlank_(properties.guess_length),
      properties.has_guess === true ? true : properties.has_guess === false ? false : '',
      safeCell_(JSON.stringify(properties)),
    ];

    const lock = LockService.getScriptLock();
    lock.waitLock(5000);
    try {
      const sheet = getOrCreateSheet_();
      sheet.appendRow(row);
    } finally {
      lock.releaseLock();
    }

    return jsonResponse_({ ok: true });
  } catch (error) {
    return jsonResponse_({ ok: false, error: String(error.message || error) });
  }
}

function getOrCreateSheet_() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = spreadsheet.getSheetByName(SHEET_NAME);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(SHEET_NAME);
  }
  if (sheet.getLastRow() === 0) {
    sheet.appendRow(HEADERS);
    sheet.setFrozenRows(1);
  }
  return sheet;
}

function safeCell_(value) {
  if (value === undefined || value === null) {
    return '';
  }
  let text = String(value).slice(0, 2000);
  if (/^[=+\-@]/.test(text)) {
    text = "'" + text;
  }
  return text;
}

function numberOrBlank_(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : '';
}

function jsonResponse_(value) {
  return ContentService
    .createTextOutput(JSON.stringify(value))
    .setMimeType(ContentService.MimeType.JSON);
}
