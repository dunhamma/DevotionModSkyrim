#!/usr/bin/env node
/*
 * Generates the Papyrus LoadRowsForDeity(...) function body for PDV__ManagerQuest
 * from references/authoring/PDV_DeityLikesDislikes.csv. Keyed by the deity's
 * DeityName (the CSV "actor" column MUST match the runtime DeityName string).
 *
 * Output goes to stdout; paste/replace the LoadRowsForDeity function in
 * PDV__ManagerQuest.psc with it. Columns used: actor[0], eventId[1], baseDelta[5],
 * dailyCap[6], cooldownDays[7]. (Notes may contain commas but come after these.)
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CSV = path.resolve(__dirname, "..", "references", "authoring", "PDV_DeityLikesDislikes.csv");

function papyrusFloat(value) {
  const text = String(value).trim();
  return text.includes(".") ? text : `${text}.0`;
}

function main() {
  const lines = fs.readFileSync(CSV, "utf8").split(/\r?\n/).filter((line) => line.trim().length > 0);
  lines.shift(); // header

  const order = [];
  const byActor = new Map();
  for (const line of lines) {
    const cols = line.split(",");
    const actor = cols[0].trim();
    const eventId = cols[1].trim();
    const delta = cols[5].trim();
    const dailyCap = cols[6].trim();
    const cooldown = cols[7].trim();
    if (!actor || !eventId) continue;
    if (!byActor.has(actor)) {
      byActor.set(actor, []);
      order.push(actor);
    }
    byActor.get(actor).push({ eventId, delta, dailyCap, cooldown });
  }

  const out = [];
  out.push("Function LoadRowsForDeity(PDV_DeityBase deity)");
  out.push("    String ldName = deity.DeityName");
  order.forEach((actor, index) => {
    const keyword = index === 0 ? "if" : "elseIf";
    out.push(`    ${keyword} ldName == "${actor}"`);
    for (const row of byActor.get(actor)) {
      out.push(`        WriteLD(deity, ${row.eventId}, ${papyrusFloat(row.delta)}, ${row.dailyCap}, ${papyrusFloat(row.cooldown)})`);
    }
  });
  out.push("    endIf");
  out.push("EndFunction");

  const totalRows = lines.length;
  process.stderr.write(`Generated LoadRowsForDeity: ${order.length} deities, ${totalRows} rows.\n`);
  process.stdout.write(out.join("\n") + "\n");
}

main();
