#!/usr/bin/env node
/*
 * Generates the Papyrus LoadPrinceRowsForPath(...) function body for
 * PDV__ManagerQuest from references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv
 * (the V2 transgressive-Prince path-gated layer). Keyed by the path's DeityName
 * (the CSV "actor" column is "Daedric:<DeityName>"; the "Daedric:" prefix is
 * stripped so the key matches PDV_DaedricPath_*.DeityName, e.g. "Molag Bal").
 *
 * Output goes to stdout; paste/replace the LoadPrinceRowsForPath function in
 * PDV__ManagerQuest.psc with it. Columns used: actor[0], eventId[1], baseDelta[5],
 * dailyCap[6], cooldownDays[7]. Writes go through WritePLD (PDV.PLD.* namespace,
 * separate from the V1 PDV.LD.* table). Re-run + bump PRINCE_LD_VERSION on change.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CSV = path.resolve(__dirname, "..", "references", "authoring", "PDV_DeityLikesDislikes_Princes_V2.csv");

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
    let actor = cols[0].trim();
    if (actor.startsWith("Daedric:")) actor = actor.slice("Daedric:".length).trim();
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
  out.push("Function LoadPrinceRowsForPath(PDV_DaedricPathBase path)");
  out.push("    String ldName = path.DeityName");
  order.forEach((actor, index) => {
    const keyword = index === 0 ? "if" : "elseIf";
    out.push(`    ${keyword} ldName == "${actor}"`);
    for (const row of byActor.get(actor)) {
      out.push(`        WritePLD(path, ${row.eventId}, ${papyrusFloat(row.delta)}, ${row.dailyCap}, ${papyrusFloat(row.cooldown)})`);
    }
  });
  out.push("    endIf");
  out.push("EndFunction");

  const totalRows = lines.length;
  process.stderr.write(`Generated LoadPrinceRowsForPath: ${order.length} paths, ${totalRows} rows.\n`);
  process.stdout.write(out.join("\n") + "\n");
}

main();
