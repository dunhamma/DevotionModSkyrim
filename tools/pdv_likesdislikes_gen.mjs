#!/usr/bin/env node
/*
 * Generates the Papyrus LoadRowsForDeity(...) function body for PDV__ManagerQuest
 * from references/authoring/PDV_DeityLikesDislikes.csv. Keyed by the deity's
 * DeityName (the CSV "actor" column MUST match the runtime DeityName string).
 *
 * Output goes to stdout; paste/replace the LoadRowsForDeity function in
 * PDV__ManagerQuest.psc with it. Columns used by name: actor, eventId, baseDelta,
 * dailyCap, cooldownDays, originGate. Notes may contain commas but come after
 * the metadata columns.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CSV = path.resolve(__dirname, "..", "references", "authoring", "PDV_DeityLikesDislikes.csv");
const ORIGIN_GATE = new Map([
  ["", -1],
  ["nord", 0],
  ["imperial", 1],
  ["breton", 2],
  ["altmer", 3],
  ["bosmer", 4],
  ["dunmer", 5],
  ["khajiit", 6],
  ["argonian", 7],
  ["saxhleel", 7],
  ["orc", 8],
  ["orsimer", 8],
  ["redguard", 9],
  ["yokudan", 9],
]);

function papyrusFloat(value) {
  const text = String(value).trim();
  return text.includes(".") ? text : `${text}.0`;
}

function columnIndex(header, name) {
  const index = header.indexOf(name);
  if (index < 0) {
    throw new Error(`Missing required column: ${name}`);
  }
  return index;
}

function originGateValue(rawValue, lineNumber) {
  const token = String(rawValue || "").trim();
  const value = ORIGIN_GATE.get(token.toLowerCase());
  if (value === undefined) {
    throw new Error(`Unknown originGate '${token}' on CSV line ${lineNumber}.`);
  }
  return value;
}

function main() {
  const lines = fs.readFileSync(CSV, "utf8").split(/\r?\n/).filter((line) => line.trim().length > 0);
  const header = lines.shift().split(",").map((col) => col.trim());
  const actorIndex = columnIndex(header, "actor");
  const eventIdIndex = columnIndex(header, "eventId");
  const deltaIndex = columnIndex(header, "baseDelta");
  const dailyCapIndex = columnIndex(header, "dailyCap");
  const cooldownIndex = columnIndex(header, "cooldownDays");
  const originGateIndex = columnIndex(header, "originGate");

  const order = [];
  const byActor = new Map();
  lines.forEach((line, index) => {
    const cols = line.split(",");
    const actor = String(cols[actorIndex] || "").trim();
    const eventId = String(cols[eventIdIndex] || "").trim();
    const delta = String(cols[deltaIndex] || "").trim();
    const dailyCap = String(cols[dailyCapIndex] || "").trim();
    const cooldown = String(cols[cooldownIndex] || "").trim();
    const originGate = originGateValue(cols[originGateIndex], index + 2);
    if (!actor || !eventId) return;
    if (!byActor.has(actor)) {
      byActor.set(actor, []);
      order.push(actor);
    }
    byActor.get(actor).push({ eventId, delta, dailyCap, cooldown, originGate });
  });

  const out = [];
  out.push("Function LoadRowsForDeity(PDV_DeityBase deity)");
  out.push("    String ldName = deity.DeityName");
  order.forEach((actor, index) => {
    const keyword = index === 0 ? "if" : "elseIf";
    out.push(`    ${keyword} ldName == "${actor}"`);
    for (const row of byActor.get(actor)) {
      out.push(`        WriteLD(deity, ${row.eventId}, ${papyrusFloat(row.delta)}, ${row.dailyCap}, ${papyrusFloat(row.cooldown)}, ${row.originGate})`);
    }
  });
  out.push("    endIf");
  out.push("EndFunction");

  const totalRows = lines.length;
  process.stderr.write(`Generated LoadRowsForDeity: ${order.length} deities, ${totalRows} rows.\n`);
  process.stdout.write(out.join("\n") + "\n");
}

main();
