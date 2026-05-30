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
const RACE_TOKEN_RE = /_(Nord|Imperial|Dunmer|Altmer|Khajiit|Redguard|Bosmer|Breton|Orc|Argonian)(_|$)/;
const COLUMN_COUNT = 8; // Slot ID, Surface, Surfacing, Voice, Budget, Source, Notes, Draft prose

class ContentVerifier {
  constructor() {
    this.findings = [];
    this.slotSeen = new Map();
    this.proseSeen = new Map();
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

    // Parse MessageBox title/body once; the body is the player-facing sentence,
    // so terminal-punctuation and duplicate checks run on the body, not the raw
    // "Title: ... Body: ..." wrapper (titles legitimately carry no period).
    const titleBody = parseTitleBody(prose);
    const bodyText = surface === "MessageBox" && titleBody ? titleBody.body : prose;

    // Style checks (§ 3.5 of PDV_STANDARDS).
    this.checkTerminalPunctuation(bodyText, slot, loc);
    this.checkContractions(prose, slot, loc);

    // Per-race uniqueness: race-keyed rows must be individually written.
    this.checkDuplicateProse(bodyText, slot, notes, loc);

    const hard = parseBudget(budget);
    if (hard === null) {
      this.warn("Budget format", `'${slot}' Budget '${budget}' is not hard/target form.`, loc);
      return;
    }

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

  checkDuplicateProse(bodyText, slot, notes, loc) {
    // Only race-keyed rows are compared: a deity/Prince worshipped by multiple
    // races must read differently per race, and two races must never share body
    // text. Templated (%s) rows and rows the design declares generic are exempt.
    if (!RACE_TOKEN_RE.test(slot)) return;
    if (bodyText.includes("%s")) return;
    if (/\bgeneric\b/i.test(notes)) return;
    const norm = bodyText
      .toLowerCase()
      .replace(/\s+/g, " ")
      .replace(/[\s.!?"']+$/g, "")
      .trim();
    if (norm.length < 12) return; // too short to be a meaningful duplicate
    if (this.proseSeen.has(norm)) {
      const prior = this.proseSeen.get(norm);
      this.warn(
        "Duplicate prose",
        `'${slot}' shares body text with '${prior.slot}' (${prior.loc}); race-keyed rows must be individually written.`,
        loc,
      );
    } else {
      this.proseSeen.set(norm, { slot, loc });
    }
  }

  checkTerminalPunctuation(prose, slot, loc) {
    let t = prose.trimEnd();
    // Dialogue and quoted lines wrap the sentence in straight quotes; unwrap one
    // trailing quote so the check sees the sentence's real terminal character.
    if (t.endsWith('"')) t = t.slice(0, -1).trimEnd();
    const last = t.slice(-1);
    if (last !== "." && last !== "!" && last !== "?") {
      this.warn(
        "Terminal punctuation",
        `'${slot}' does not end with a period, exclamation mark, or question mark (ends with '${last}').`,
        loc,
      );
    }
  }

  checkContractions(prose, slot, loc) {
    const CONTRACTIONS = [
      "don't", "can't", "won't", "isn't", "aren't", "wasn't", "weren't",
      "hasn't", "haven't", "hadn't", "you're", "you've", "you'll", "you'd",
      "i'm", "i've", "i'll", "i'd", "he's", "she's", "it's", "we're",
      "we've", "we'll", "we'd", "they're", "they've", "they'll", "they'd",
      "that's", "who's", "what's", "where's", "there's", "couldn't",
      "wouldn't", "shouldn't", "didn't", "doesn't",
    ];
    const lower = prose.toLowerCase();
    for (const contraction of CONTRACTIONS) {
      if (new RegExp('\\b' + contraction + '\\b').test(lower)) {
        this.warn(
          "Contraction",
          `'${slot}' contains contraction '${contraction}' -- use the full form.`,
          loc,
        );
        return; // One report per row.
      }
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
  // MessageBox rows appear in both orders in the manifests:
  //   Title: "..." Body: "..."   and   Body: "..." Title: "..."
  let match = prose.match(/^Title:\s*"([^"]*)"\s*Body:\s*"([^"]*)"\s*$/);
  if (match) return { title: match[1], body: match[2] };
  match = prose.match(/^Body:\s*"([^"]*)"\s*Title:\s*"([^"]*)"\s*$/);
  if (match) return { title: match[2], body: match[1] };
  return null;
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
