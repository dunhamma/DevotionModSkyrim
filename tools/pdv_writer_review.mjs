#!/usr/bin/env node
/*
 * Writer-facing review-matrix extractor for the PDV race content manifest.
 *
 * Reads race-sheets/PDV_RaceContent_Manifest.md and emits one MD plus one
 * CSV per race under race-sheets/writer-review/, grouping every drafted
 * string by the in-game moment in which the player encounters it. Also
 * emits a top-level _Index.md.
 *
 * Read-only with respect to the manifest. Output directory is overwritten
 * on each run.
 *
 * Usage: node tools/pdv_writer_review.mjs
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const RACE_SHEETS = path.join(PROJECT_ROOT, "race-sheets");
const MANIFEST = path.join(RACE_SHEETS, "PDV_RaceContent_Manifest.md");
const OUT_DIR = path.join(RACE_SHEETS, "writer-review");

const RACE_BY_SECTION = {
  10: "Nord",
  11: "Orc",
  12: "Dunmer",
  13: "Altmer",
  14: "Khajiit",
  15: "Imperial",
  16: "Redguard",
  17: "Bosmer",
  18: "Breton",
  19: "Argonian",
};

const TITLE_HARD = 40;
const COLUMN_COUNT = 8;

// Moment taxonomy. First match wins. Each entry: [regex, label, order].
// "order" controls the order of moments inside each race file.
const MOMENT_RULES = [
  [/^PDV_Bless_[^_]+_[^_]+_T1$/, "First blessing (Tier 1)", 10],
  [/^PDV_Bless_[^_]+_[^_]+_T2$/, "Deepening blessing (Tier 2)", 11],
  [/^PDV_Bless_[^_]+_[^_]+_T3$/, "Devoted blessing (Tier 3)", 12],
  [/^PDV_Notif_[^_]+_[^_]+_Tier\d+Entry$/, "Tier-up announcement", 20],
  [/^PDV_Notif_[^_]+_FocusEmergence/, "Focus emergence (silent)", 25],
  [/^PDV_Msg_[^_]+_[^_]+_ChampionEntry$/, "Champion recognition (MessageBox)", 30],
  [/^PDV_Notif_[^_]+_[^_]+_ChampionAmbient/, "Champion ambient line", 31],
  [/_NeglectTexture/, "Drifting away (neglect)", 40],
  [/^PDV_Msg_[^_]+_OfferResponse_/, "Commitment reply (player answers)", 51],
  [/^PDV_Msg_[^_]+_[^_]+_Offer$/, "Commitment offer (the god asks)", 50],
  [/^PDV_Msg_[^_]+_Survey_/, "Survey Devotion (player checks status)", 60],
  [/^PDV_Msg_[^_]+_HistPosture_/, "Substrate posture readout", 61],
  [/^PDV_Msg_[^_]+_AncestorPosture_/, "Substrate posture readout", 61],
  [/^PDV_Notif_[^_]+_FavorNoted_/, "Contextual favor (small, Noted)", 70],
  [/^PDV_Msg_[^_]+_FavorMarked_/, "Contextual favor (large, Marked)", 71],
  [/^PDV_Msg_[^_]+_CurseState_/, "Curse onset / cure", 80],
  [/^PDV_Dlog_/, "Shrine and privilege dialogue", 90],
  // Race-specific track / posture transitions
  [/^PDV_Notif_[^_]+_HistPosture_/, "Track / posture transition", 100],
  [/_ConcordatStanding_|_ConcordatStanding$|_Concordat_/, "Track / posture transition (Imperial Concordat)", 100],
  [/_ThalmorAlignment_/, "Track / posture transition (Altmer Thalmor)", 100],
  [/_LorkhanPressure_|_LorkhanInterp_/, "Track / posture transition (Altmer Lorkhan)", 100],
  [/_GreenPact_/, "Track / posture transition (Bosmer Green Pact)", 100],
  [/_OldContract_/, "Track / posture transition (Bosmer Old Contract)", 100],
  [/^PDV_Notif_[^_]+_Path_|^PDV_Msg_[^_]+_PathChoice_/, "Path / tradition setup", 101],
  [/_Tradition_/, "Path / tradition setup", 101],
  [/_DruidicTrial_|_GreenWay_/, "Druidic / Green Way trial", 102],
  [/_Track_[A-Z]/, "Track / posture transition (Breton)", 100],
  [/_LifeMode_/, "Life-mode shift (Orc)", 100],
  [/_Tribunal/, "Tribunal Memory (Dunmer)", 110],
  [/_LunarPhase_/, "Lunar phase flavor (Khajiit)", 100],
  [/_RoadHome_/, "Road home acknowledgment (Khajiit)", 110],
  [/_Sect_/, "Sect entry (Redguard)", 100],
  [/_FarShoresToken_/, "Far Shores token (Redguard)", 110],
  [/_HistSapMeditation_/, "Hist sap meditation (Argonian)", 110],
  [/_BedOfChoice_/, "Bed of choice (Argonian)", 110],
  [/_SithisActivation_/, "Sithis activation (Argonian)", 110],
  [/_AncestorPosture_/, "Ancestor posture transition (Dunmer)", 100],
];

function detectMoment(slot) {
  for (const [re, label, order] of MOMENT_RULES) {
    if (re.test(slot)) return { label, order };
  }
  return { label: "Other", order: 999 };
}

function splitRow(line) {
  const parts = line.split("|").map((c) => c.trim());
  return parts.slice(1, parts.length - 1);
}

function parseBudget(budget) {
  const m = budget.match(/^(\d+)\/(\d+)$/);
  if (!m) return { hard: null, target: null };
  return { hard: Number(m[1]), target: Number(m[2]) };
}

function parseTitleBody(prose) {
  const m = prose.match(/^Title:\s*"([^"]*)"\s*Body:\s*"([^"]*)"\s*$/);
  if (!m) return null;
  return { title: m[1], body: m[2] };
}

// Pull the deity / tone-key candidate out of a slot id.
// Strategy: drop the prefix (PDV_Bless_, etc), drop the race token (next
// segment), then take the next 1-2 segments as the deity candidate. Tier
// suffixes (_T1, _T2, _T3) and known sub-keys are stripped.
function extractDeityKey(slot, raceToken) {
  const parts = slot.split("_");
  // parts[0] = "PDV", parts[1] = surface (Bless/Notif/Msg/Dlog/...), parts[2] = race
  if (parts.length < 4) return null;
  if (parts[2] !== raceToken) return null;
  let rest = parts.slice(3);
  // Strip trailing tier / common suffixes
  const tail = new Set([
    "T1", "T2", "T3",
    "Tier1Entry", "Tier2Entry", "Tier3Entry",
    "ChampionEntry", "Offer", "NeglectTexture",
    "Accept", "Decline", "Lapse",
  ]);
  while (rest.length > 1 && (tail.has(rest[rest.length - 1]) || /^Tier\d+Entry$/.test(rest[rest.length - 1]))) {
    rest.pop();
  }
  // Heuristic: deity is usually the first 1-2 segments after race.
  // We'll return the first segment; tone match also tries first+second.
  return rest[0] || null;
}

// Normalise tone-table key for matching.
function normaliseToneKey(key) {
  return key
    .replace(/\s*\([^)]*\)\s*/g, " ") // drop parenthetical
    .replace(/\s*\/\s*/g, "/")
    .trim();
}

function toneCandidatesFromSlot(slot, raceToken) {
  const parts = slot.split("_");
  if (parts.length < 4 || parts[2] !== raceToken) return [];
  const rest = parts.slice(3).filter((p) => !/^T\d$/.test(p) && !/^Tier\d+/.test(p));
  const out = new Set();
  if (rest[0]) out.add(rest[0]);
  if (rest[0] && rest[1]) out.add(`${rest[0]} ${rest[1]}`);
  if (rest[0] && rest[1]) out.add(`${rest[0]}/${rest[1]}`);
  return [...out];
}

function findTone(toneTable, slot, raceToken) {
  const candidates = toneCandidatesFromSlot(slot, raceToken);
  for (const c of candidates) {
    const direct = toneTable.get(c);
    if (direct) return { key: c, line: direct };
  }
  // Fuzzy: any table key whose first word matches the slot's first segment
  for (const c of candidates) {
    for (const [k, v] of toneTable.entries()) {
      const norm = normaliseToneKey(k);
      if (norm === c) return { key: k, line: v };
      const firstWord = norm.split(/[\s/]+/)[0];
      if (firstWord && firstWord.toLowerCase() === c.toLowerCase()) return { key: k, line: v };
    }
  }
  return null;
}

// Synthesise a one-sentence trigger from Surfacing + Notes + Surface.
function synthesiseTrigger(surface, surfacing, notes) {
  const n = notes.trim();
  if (/Passive SPEL/i.test(n)) {
    return "Passive blessing description; visible whenever the player views active effects.";
  }
  if (surface === "Status spell readout") {
    return "Shown via Survey Devotion and on posture transitions.";
  }
  if (surface === "Notification") {
    if (n) return `HUD corner notification. ${n}.`;
    return `HUD corner notification (${surfacing}).`;
  }
  if (surface === "MessageBox") {
    if (n) return `MessageBox. ${n}.`;
    return `MessageBox (${surfacing}).`;
  }
  if (surface === "Dialogue topic") {
    if (n) return `Dialogue topic; ${n}.`;
    return `Dialogue topic shown to the player.`;
  }
  if (surface === "Blessing description") {
    return "Passive blessing description; visible whenever the player views active effects.";
  }
  return `${surface} (${surfacing}). ${n}`.trim();
}

// Parse the full manifest into a structured form.
function parseManifest(text) {
  const lines = text.split(/\r?\n/);
  const races = {}; // raceName -> { section, toneTable: Map, rows: [] }
  let currentRaceSection = null;
  let currentRaceName = null;
  let inToneTable = false;
  let toneTableLooking = false; // saw `### N.1` header, scanning for first 2-col table

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];

    // Race section header
    const top = line.match(/^##\s+(\d+)\.\s+(.+)$/);
    if (top) {
      const n = Number(top[1]);
      if (RACE_BY_SECTION[n]) {
        currentRaceSection = n;
        currentRaceName = RACE_BY_SECTION[n];
        races[currentRaceName] = {
          section: n,
          toneTable: new Map(),
          rows: [],
          headerTitle: top[2].trim(),
        };
        toneTableLooking = false;
        inToneTable = false;
      } else {
        currentRaceSection = null;
        currentRaceName = null;
        toneTableLooking = false;
        inToneTable = false;
      }
      continue;
    }

    if (!currentRaceName) continue;

    // Subsection header. The .1 subsection always opens the tone table.
    const sub = line.match(/^###\s+(\d+)\.(\d+)\s+/);
    if (sub) {
      if (Number(sub[1]) === currentRaceSection && Number(sub[2]) === 1) {
        toneTableLooking = true;
      } else {
        toneTableLooking = false;
      }
      inToneTable = false;
      continue;
    }

    // Tone-table detection: a 2-col markdown table within the .1 subsection.
    if (toneTableLooking && /^\|\s*(Deity|Voice|Layer)\s*\|\s*Tone profile\s*\|\s*$/i.test(line)) {
      inToneTable = true;
      continue;
    }
    if (inToneTable) {
      if (/^\|\s*-+\s*\|\s*-+\s*\|\s*$/.test(line)) continue; // separator
      if (line.startsWith("|")) {
        const cells = splitRow(line);
        if (cells.length === 2 && cells[0] && cells[1]) {
          races[currentRaceName].toneTable.set(cells[0], cells[1]);
          continue;
        }
        // fallthrough -> non 2-col row breaks the table
        inToneTable = false;
      } else {
        inToneTable = false;
      }
    }

    // Drafted row
    if (line.startsWith("| PDV_")) {
      const cells = splitRow(line);
      if (cells.length !== COLUMN_COUNT) continue;
      const [slot, surface, surfacing, voice, budget, source, notes, prose] = cells;
      if (!prose || prose === "--") continue;
      races[currentRaceName].rows.push({
        slot, surface, surfacing, voice, budget, source, notes, prose,
        line: i + 1,
      });
    }
  }

  return races;
}

function csvCell(s) {
  if (s == null) return "";
  const str = String(s);
  if (/[",\n]/.test(str)) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

function buildRowOutput(race, raceToken, row) {
  const { slot, surface, surfacing, voice, budget, notes, prose } = row;
  const { hard, target } = parseBudget(budget);
  const moment = detectMoment(slot);
  const toneMatch = findTone(race.toneTable, slot, raceToken);
  const tone = toneMatch ? `${toneMatch.key}: ${toneMatch.line}` : "";

  const titleBody = parseTitleBody(prose);
  let charCount, hardCap, overBudget;
  let displayProse;
  if (surface === "MessageBox" && titleBody) {
    const tLen = titleBody.title.length;
    const bLen = titleBody.body.length;
    charCount = `${tLen}+${bLen}`;
    hardCap = `${TITLE_HARD}+${hard ?? "?"}`;
    overBudget = (hard != null && (tLen > TITLE_HARD || bLen > hard));
    displayProse = `Title: "${titleBody.title}"\n  Body: "${titleBody.body}"`;
  } else {
    const len = prose.length;
    charCount = String(len);
    hardCap = hard != null ? String(hard) : "?";
    overBudget = hard != null && len > hard;
    displayProse = prose;
  }

  const trigger = synthesiseTrigger(surface, surfacing, notes);

  return {
    moment,
    tone,
    slot,
    surface,
    surfacing,
    voice,
    budgetTarget: target,
    budgetHard: hard,
    charCount,
    hardCap,
    overBudget,
    trigger,
    prose,
    displayProse,
    titleBody,
  };
}

function mdEscape(s) {
  return String(s).replace(/\|/g, "\\|").replace(/\n/g, " ");
}

function renderMd(raceName, race, outRows) {
  const grouped = new Map();
  for (const r of outRows) {
    const key = `${r.moment.order}|${r.moment.label}`;
    if (!grouped.has(key)) grouped.set(key, { label: r.moment.label, order: r.moment.order, rows: [] });
    grouped.get(key).rows.push(r);
  }
  const ordered = [...grouped.values()].sort((a, b) => a.order - b.order);

  const overCount = outRows.filter((r) => r.overBudget).length;
  const lines = [];
  lines.push(`# ${raceName} -- Writer Review`);
  lines.push("");
  lines.push(`**Source:** \`race-sheets/PDV_RaceContent_Manifest.md\` section ${race.section} (${race.headerTitle})`);
  lines.push(`**Regenerated:** ${new Date().toISOString().slice(0, 10)} via \`node tools/pdv_writer_review.mjs\``);
  lines.push(`**Rows:** ${outRows.length} drafted${overCount ? `  |  **Over budget:** ${overCount}` : ""}`);
  lines.push("");
  lines.push("Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.");
  lines.push("");

  for (const group of ordered) {
    lines.push(`## ${group.label}`);
    lines.push("");
    lines.push(`_${group.rows.length} ${group.rows.length === 1 ? "row" : "rows"}._`);
    lines.push("");
    lines.push("| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |");
    lines.push("|---|---|---|---|---|---|---|---|");
    for (const r of group.rows) {
      const flag = r.overBudget ? "**OVER**" : "";
      const tone = r.tone ? mdEscape(r.tone) : "_(no tone match)_";
      lines.push(
        `| ${tone} | \`${r.slot}\` | ${mdEscape(r.trigger)} | ${r.voice} | ${r.charCount} / ${r.hardCap} | ${flag} | ${mdEscape(r.displayProse)} |  |`,
      );
    }
    lines.push("");
  }

  return lines.join("\n");
}

function renderCsv(raceName, outRows) {
  const header = [
    "race", "moment", "moment_order", "deity_tone", "slot_id", "surface",
    "surfacing", "voice", "budget_target", "budget_hard", "char_count",
    "over_budget", "trigger", "draft_prose", "edit",
  ];
  const lines = [header.join(",")];
  for (const r of outRows) {
    lines.push([
      csvCell(raceName),
      csvCell(r.moment.label),
      csvCell(r.moment.order),
      csvCell(r.tone),
      csvCell(r.slot),
      csvCell(r.surface),
      csvCell(r.surfacing),
      csvCell(r.voice),
      csvCell(r.budgetTarget ?? ""),
      csvCell(r.budgetHard ?? ""),
      csvCell(r.charCount),
      csvCell(r.overBudget ? "OVER" : ""),
      csvCell(r.trigger),
      csvCell(r.prose),
      csvCell(""),
    ].join(","));
  }
  return lines.join("\n") + "\n";
}

function renderIndex(stats) {
  const lines = [];
  lines.push("# PDV Writer Review -- Index");
  lines.push("");
  lines.push(`**Regenerated:** ${new Date().toISOString().slice(0, 10)} via \`node tools/pdv_writer_review.mjs\``);
  lines.push("**Source:** `race-sheets/PDV_RaceContent_Manifest.md`");
  lines.push("");
  lines.push("Per-race writer-review files. Each `<Race>_Review.md` groups every drafted in-game string by the moment in which the player encounters it, with deity tone, voice, char count vs hard cap, and an empty `Edit` column for revisions.");
  lines.push("");
  lines.push("| Race | Rows | Over budget | Moments covered | MD | CSV |");
  lines.push("|---|---|---|---|---|---|");
  for (const s of stats) {
    lines.push(`| ${s.race} | ${s.rows} | ${s.over || "-"} | ${s.moments} | [${s.race}_Review.md](${s.race}_Review.md) | [${s.race}_Review.csv](${s.race}_Review.csv) |`);
  }
  lines.push("");
  lines.push("## How to use");
  lines.push("");
  lines.push("1. Open the MD for a race to read drafted strings in moment-order with full authoring context (deity tone, voice, char cap).");
  lines.push("2. Edit in the right-hand `Edit` column, or open the CSV in a spreadsheet for column sorting / filtering.");
  lines.push("3. When happy with a batch of edits, hand-merge them back into `race-sheets/PDV_RaceContent_Manifest.md` against the matching `Slot ID`.");
  lines.push("4. Re-run `node tools/pdv_content_verify.mjs` to confirm budget / voice / ASCII still pass.");
  lines.push("5. Re-run `node tools/pdv_writer_review.mjs` to regenerate this view from the updated manifest.");
  lines.push("");
  lines.push("**Note.** Regenerating overwrites every `<Race>_Review.md` and `<Race>_Review.csv`. Save your in-progress `Edit` columns before re-running, or do your revising in a copy.");
  return lines.join("\n");
}

function main() {
  if (!fs.existsSync(MANIFEST)) {
    console.error(`Manifest not found: ${MANIFEST}`);
    process.exit(2);
  }
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const text = fs.readFileSync(MANIFEST, "utf8");
  const races = parseManifest(text);

  const stats = [];
  const raceOrder = Object.values(RACE_BY_SECTION);
  let total = 0, totalOver = 0;

  for (const raceName of raceOrder) {
    const race = races[raceName];
    if (!race) {
      console.warn(`[warn] No section parsed for ${raceName}`);
      continue;
    }
    const raceToken = raceName; // section title matches slot token
    const outRows = race.rows.map((r) => buildRowOutput(race, raceToken, r));
    const md = renderMd(raceName, race, outRows);
    const csv = renderCsv(raceName, outRows);

    fs.writeFileSync(path.join(OUT_DIR, `${raceName}_Review.md`), md);
    fs.writeFileSync(path.join(OUT_DIR, `${raceName}_Review.csv`), csv);

    const overCount = outRows.filter((r) => r.overBudget).length;
    const momentLabels = new Set(outRows.map((r) => r.moment.label));
    stats.push({
      race: raceName,
      rows: outRows.length,
      over: overCount,
      moments: momentLabels.size,
    });
    total += outRows.length;
    totalOver += overCount;
  }

  fs.writeFileSync(path.join(OUT_DIR, "_Index.md"), renderIndex(stats));

  console.log(`PDV writer-review extractor`);
  console.log(`Wrote ${stats.length} race files (MD + CSV) to ${path.relative(PROJECT_ROOT, OUT_DIR)}/`);
  console.log(`Total drafted rows: ${total}`);
  if (totalOver) console.log(`Over-budget rows flagged: ${totalOver}`);
  for (const s of stats) {
    console.log(`  ${s.race.padEnd(10)} ${String(s.rows).padStart(4)} rows  ${s.moments} moments${s.over ? `  ${s.over} over` : ""}`);
  }
}

main();
