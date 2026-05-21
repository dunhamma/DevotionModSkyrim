#!/usr/bin/env node
/*
 * Read-only verifier for the PDV race/Daedric content manifests.
 *
 * It validates the authored content rows in race-sheets/PDV_*Content_Manifest.md
 * against the manifest's own locked conventions: ASCII-only player-facing text,
 * per-Surface length budgets, slot-ID uniqueness and naming convention, the
 * voice-by-Surface matrix, non-empty source citations, and non-empty draft
 * prose. It does not modify any file, the ESP, or MO2 state.
 *
 * Usage: node tools/pdv_content_verify.mjs [--json]
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const RACE_SHEETS = path.join(PROJECT_ROOT, "race-sheets");

// Manifests to verify, in order. Missing files are reported as INFO, not FAIL,
// so the Daedric manifest can be absent until Workstream C lands.
const MANIFEST_FILES = [
  "PDV_RaceContent_Manifest.md",
  "PDV_DaedricContent_Manifest.md",
];

const VALID_VOICES = new Set(["Narrator", "Player-2nd", "God-voice"]);
const VALID_SURFACINGS = new Set(["Quiet", "Noted", "Marked"]);
const SLOT_PREFIXES = ["Msg", "Notif", "Bless", "Dlog", "PrismaToast", "Price"];
const SLOT_RE = new RegExp(`^PDV_(${SLOT_PREFIXES.join("|")})_[A-Za-z0-9_]+$`);
const SLOT_ID_MAX = 64;
const TITLE_HARD = 40;
const RESERVED_NOTE_RE = /texture-only|reserved/i;
const COLUMN_COUNT = 8; // Slot ID, Surface, Surfacing, Voice, Budget, Source, Notes, Draft prose

class ContentVerifier {
  constructor() {
    this.findings = [];
    this.slotSeen = new Map();
  }

  add(status, check, detail, location = null) {
    this.findings.push({ status, check, detail, path: location });
  }

  pass(check, detail, location = null) {
    this.add("PASS", check, detail, location);
  }

  info(check, detail, location = null) {
    this.add("INFO", check, detail, location);
  }

  warn(check, detail, location = null) {
    this.add("WARN", check, detail, location);
  }

  fail(check, detail, location = null) {
    this.add("FAIL", check, detail, location);
  }

  counts() {
    const result = {};
    for (const finding of this.findings) {
      result[finding.status] = (result[finding.status] || 0) + 1;
    }
    return result;
  }

  run() {
    let verifiedAny = false;
    for (const fileName of MANIFEST_FILES) {
      const filePath = path.join(RACE_SHEETS, fileName);
      if (!fs.existsSync(filePath)) {
        this.info("Manifest presence", `${fileName} not present yet; skipped.`, fileName);
        continue;
      }
      verifiedAny = true;
      this.verifyFile(filePath, fileName);
    }
    if (!verifiedAny) {
      this.fail("Manifest presence", "No content manifest files found to verify.", RACE_SHEETS);
    }
    return this.findings;
  }

  verifyFile(filePath, fileName) {
    const text = fs.readFileSync(filePath, "utf8");
    const lines = text.split(/\r?\n/);

    this.checkAscii(lines, fileName);

    let rowCount = 0;
    let tokenCount = 0;
    for (let i = 0; i < lines.length; i += 1) {
      const line = lines[i];
      tokenCount += (line.match(/%s/g) || []).length;
      if (!line.startsWith("| PDV_")) continue;
      const cells = splitRow(line);
      const loc = `${fileName}:${i + 1}`;
      if (cells.length !== COLUMN_COUNT) {
        this.fail(
          "Row shape",
          `Authored row has ${cells.length} columns, expected ${COLUMN_COUNT}.`,
          loc,
        );
        continue;
      }
      rowCount += 1;
      this.checkRow(cells, loc);
    }

    this.info("Manifest scan", `${rowCount} authored rows; ${tokenCount} %s tokens.`, fileName);
  }

  checkAscii(lines, fileName) {
    let violations = 0;
    for (let i = 0; i < lines.length; i += 1) {
      const line = lines[i];
      for (let c = 0; c < line.length; c += 1) {
        if (line.charCodeAt(c) > 0x7f) {
          violations += 1;
          this.fail(
            "ASCII-only",
            `Non-ASCII character U+${line.charCodeAt(c).toString(16).toUpperCase()} ('${line[c]}').`,
            `${fileName}:${i + 1}`,
          );
          break;
        }
      }
    }
    if (violations === 0) {
      this.pass("ASCII-only", "All lines are ASCII.", fileName);
    }
  }

  checkRow(cells, loc) {
    const [slot, surface, surfacing, voice, budget, source, notes, prose] = cells;

    // Slot-ID convention and uniqueness.
    if (!SLOT_RE.test(slot)) {
      this.fail("Slot ID convention", `'${slot}' does not match PDV_(${SLOT_PREFIXES.join("|")})_*.`, loc);
    } else if (slot.length > SLOT_ID_MAX) {
      this.warn(
        "Slot ID length",
        `'${slot}' is ${slot.length} chars; CK EditorIDs are safer at or under ${SLOT_ID_MAX}.`,
        loc,
      );
    }
    if (this.slotSeen.has(slot)) {
      this.fail("Slot ID uniqueness", `'${slot}' is also defined at ${this.slotSeen.get(slot)}.`, loc);
    } else {
      this.slotSeen.set(slot, loc);
    }

    // Surfacing value.
    if (!VALID_SURFACINGS.has(surfacing)) {
      this.fail("Surfacing value", `'${surfacing}' is not Quiet / Noted / Marked.`, loc);
    }

    // Voice value plus a soft matrix check on the unambiguous slot patterns.
    if (!VALID_VOICES.has(voice)) {
      this.fail("Voice value", `'${voice}' is not Narrator / Player-2nd / God-voice.`, loc);
    } else {
      const expected = expectedVoice(slot);
      if (expected && voice !== expected) {
        this.warn(
          "Voice matrix",
          `'${slot}' is ${voice}; the voice matrix expects ${expected}. Confirm the deviation is documented.`,
          loc,
        );
      }
    }

    // Source citation.
    if (source === "" || source === "--") {
      this.fail("Source citation", `'${slot}' has no Source.`, loc);
    }

    // Draft prose presence and budget.
    if (prose === "" || prose === "--") {
      if (RESERVED_NOTE_RE.test(notes)) {
        this.info("Empty prose", `'${slot}' is intentionally reserved.`, loc);
      } else {
        this.fail("Empty prose", `'${slot}' has no Draft prose.`, loc);
      }
      return;
    }

    const hard = parseBudget(budget);
    if (hard === null) {
      this.warn("Budget format", `'${slot}' Budget '${budget}' is not hard/target form.`, loc);
      return;
    }

    const titleBody = parseTitleBody(prose);
    if (surface === "MessageBox" && titleBody) {
      if (titleBody.title.length > TITLE_HARD) {
        this.fail(
          "Budget cap",
          `'${slot}' title is ${titleBody.title.length} chars, over the ${TITLE_HARD} cap.`,
          loc,
        );
      }
      if (titleBody.body.length > hard) {
        this.fail(
          "Budget cap",
          `'${slot}' body is ${titleBody.body.length} chars, over the ${hard} cap.`,
          loc,
        );
      }
      if (titleBody.title.length <= TITLE_HARD && titleBody.body.length <= hard) {
        this.pass("Budget cap", `'${slot}' within title/body budget.`, loc);
      }
    } else if (prose.length > hard) {
      this.fail("Budget cap", `'${slot}' prose is ${prose.length} chars, over the ${hard} cap.`, loc);
    } else {
      this.pass("Budget cap", `'${slot}' within budget.`, loc);
    }
  }
}

function splitRow(line) {
  // A markdown table row: | a | b | ... |  -> drop the empty leading/trailing cells.
  const parts = line.split("|").map((cell) => cell.trim());
  return parts.slice(1, parts.length - 1);
}

function parseBudget(budget) {
  const match = budget.match(/^(\d+)\/(\d+)$/);
  if (!match) return null;
  return Number(match[1]);
}

function parseTitleBody(prose) {
  const match = prose.match(/^Title:\s*"([^"]*)"\s*Body:\s*"([^"]*)"\s*$/);
  if (!match) return null;
  return { title: match[1], body: match[2] };
}

function expectedVoice(slot) {
  // Only the unambiguous slot families are checked; Notification and most
  // MessageBox families legitimately carry more than one voice.
  if (slot.startsWith("PDV_Bless_")) return "Narrator";
  if (slot.startsWith("PDV_Price_")) return "Narrator";
  if (slot.startsWith("PDV_Dlog_")) return "Player-2nd";
  if (/_Survey_/.test(slot) || /Posture_/.test(slot)) return "Narrator";
  return null;
}

function printHuman(findings, counts) {
  console.log("PDV content verifier");
  console.log(`Timestamp: ${localTimestamp()}`);
  console.log(
    `Summary: ${["FAIL", "WARN", "PASS", "INFO"]
      .map((key) => `${key}=${counts[key] || 0}`)
      .join(", ")}`,
  );
  console.log();
  for (const finding of findings) {
    if (finding.status === "PASS") continue; // keep the report short; PASS is counted only
    const location = finding.path ? ` [${finding.path}]` : "";
    console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${location}`);
  }
}

function localTimestamp() {
  return new Date().toLocaleString(undefined, {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
}

function parseArgs(argv) {
  const args = { json: false };
  for (const arg of argv) {
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "-h" || arg === "--help") {
      console.log("Usage: node tools/pdv_content_verify.mjs [--json]");
      process.exit(0);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));
const verifier = new ContentVerifier();
const findings = verifier.run();
const counts = verifier.counts();

if (args.json) {
  console.log(
    JSON.stringify(
      { timestamp_utc: new Date().toISOString(), timestamp_local: localTimestamp(), counts, findings },
      null,
      2,
    ),
  );
} else {
  printHuman(findings, counts);
}

process.exitCode = counts.FAIL ? 1 : 0;
