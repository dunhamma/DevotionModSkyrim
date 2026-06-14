#!/usr/bin/env node
/*
 * Print or write the in-game Daedric smoke-test packet from the current
 * all-Prince contract. This is read-only: it does not inspect or write ESP data.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const CONTRACT_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const DEFAULT_OUTPUT = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricInGameSmokePacket.md");

const organicSources = {
  Boethiah: { quest: "DA02", stage: 100, checker: "Boethiah", note: "" },
  Azura: { quest: "DA01", stage: 100, checker: "Azura", note: "" },
  Vaermina: { quest: "DA16", stage: 190, checker: "Vaermina", note: "Skull branch after killing Erandur; do not use stage 200." },
  Meridia: { quest: "DA09", stage: 500, checker: "Meridia", note: "" },
  Molag: { quest: "DA10", stage: 200, checker: "Molag", note: "Curse-access Prince; still needs no-double-fire manual proof." },
  Mephala: { quest: "DA08", stage: 60, checker: "Mephala", note: "" },
  Malacath: { quest: "DA06", stage: 200, checker: "Malacath", note: "" },
  Dagon: { quest: "DA07", stage: 100, checker: "Dagon", note: "" },
  Sheo: { quest: "DA15", stage: 200, checker: "Sheo", note: "" },
  Namira: { quest: "DA11", stage: 100, checker: "Namira", note: "" },
  Sanguine: { quest: "DA14", stage: 200, checker: "Sanguine", note: "" },
  Vile: { quest: "DA03", stage: 200, checker: "Vile", note: "" },
  Mora: { quest: "DA04", stage: 100, checker: "Mora", note: "" },
  Nocturnal: { quest: "TG09", stage: 200, checker: "Nocturnal", note: "Nightingale oath surface; still needs feel proof." },
  Peryite: { quest: "DA13", stage: 100, checker: "Peryite", note: "" },
  Hircine: { quest: "DA05", stage: 100, checker: "Hircine", note: "Content-surface proof; not lycanthropy curse-onset proof." },
};

function usage() {
  return [
    "Usage: node .\\tools\\pdv_daedric_ingame_packet.mjs [options]",
    "",
    "Options:",
    "  --write [path]   Write markdown packet. Defaults to references/authoring/PDV_DaedricInGameSmokePacket.md.",
    "  --help           Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = {
    write: false,
    output: DEFAULT_OUTPUT,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--write") {
      options.write = true;
      const next = argv[index + 1];
      if (next && !next.startsWith("--")) {
        options.output = path.resolve(next);
        index += 1;
      }
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function loadPrinces() {
  const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
  if (!Array.isArray(contract.princes) || contract.princes.length !== 16) {
    throw new Error(`Expected 16 princes in ${CONTRACT_PATH}.`);
  }
  return contract.princes;
}

function qasmokePosition(ordinal) {
  const column = ordinal % 6;
  const row = Math.floor(ordinal / 6);
  return {
    x: 1024 + (column * 192),
    y: -768 + (row * 176),
    z: 64,
  };
}

function qasmokeName(prince) {
  return `PDV DAEDRIC ${String(prince.stem).toUpperCase()}`;
}

function qasmokeBaseEditorId(prince) {
  return `PDV_ACTI_Daedric_${prince.stem}_LiveSender`;
}

function qasmokeRefEditorId(prince) {
  return `PDV_REFR_Daedric_${prince.stem}_LiveSender_QASmoke`;
}

function renderPacket(princes) {
  const lines = [];
  lines.push("# PDV Daedric In-Game Smoke Packet");
  lines.push("");
  lines.push("Status: ready for tester execution");
  lines.push(`Generated: ${new Date().toLocaleString("en-AU", { timeZone: "Australia/Sydney" })} AEST`);
  lines.push("");
  lines.push("## Preflight");
  lines.push("");
  lines.push("From the repo, run the readiness preflight before launching Skyrim:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_test_readiness.mjs --deep");
  lines.push("```");
  lines.push("");
  lines.push("1. Launch Skyrim through Anvil MO2 with the `Devotion Dev` profile.");
  lines.push("2. Start from a throwaway save or main-menu `coc qasmoke`.");
  lines.push("3. Open `Mod Configuration > Devotion > Player` and enable `Developer Options`.");
  lines.push("4. Open `Mod Configuration > Devotion > Debug`.");
  lines.push("5. Enable debug traces:");
  lines.push("");
  lines.push("```text");
  lines.push("set PDV_GLO_DebugLevel to 2");
  lines.push("```");
  lines.push("");
  lines.push("## Fast MCM Sweep");
  lines.push("");
  lines.push("Use `Route all Princes` on the MCM Debug page, then run:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_runtime_check.mjs --strict-manager --source mcm");
  lines.push("```");
  lines.push("");
  lines.push("This proves route markers only. It does not replace Active Effects, summary, Prisma, save/load, stack, or curse checks.");
  lines.push("");
  lines.push("## QASmoke Physical Sender Proof");
  lines.push("");
  lines.push("Use `coc qasmoke`, then find the activators named below. If the room is cluttered, use the console `help` command for the ACTI base and `player.placeatme <ACTI FormID>` to place a temporary copy next to the player. The placed copy uses the same scripted activator base.");
  lines.push("");
  lines.push("| Prince | Activator name | ACTI EditorID | QASmoke REFR EditorID | Position | Checker |");
  lines.push("|---|---|---|---|---|---|");
  princes.forEach((prince, index) => {
    const pos = qasmokePosition(index);
    lines.push(`| ${prince.displayName} | ${qasmokeName(prince)} | ${qasmokeBaseEditorId(prince)} | ${qasmokeRefEditorId(prince)} | x=${pos.x}, y=${pos.y}, z=${pos.z} | \`node .\\tools\\pdv_daedric_runtime_check.mjs --prince ${prince.stem} --strict-manager --source qasmoke --no-generic\` |`);
  });
  const genericPos = qasmokePosition(princes.length);
  lines.push(`| Generic silence | PDV DAEDRIC GENERIC SILENCE | PDV_ACTI_Daedric_GenericSilenceProbe | PDV_REFR_Daedric_GenericSilenceProbe_QASmoke | x=${genericPos.x}, y=${genericPos.y}, z=${genericPos.z} | \`node .\\tools\\pdv_daedric_runtime_check.mjs --strict-manager --source qasmoke\` |`);
  lines.push("");
  lines.push("Example in-game lookup:");
  lines.push("");
  lines.push("```text");
  lines.push('help "PDV DAEDRIC AZURA" 4 ACTI');
  lines.push("player.placeatme <ACTI FormID from help>");
  lines.push("```");
  lines.push("");
  lines.push("## Organic Quest-Stage Sender Proof");
  lines.push("");
  lines.push("After controlled proof, use these exact stage routes from a throwaway save where PO3 quest-stage events are active and `PDV_PlayerEvents` has loaded.");
  lines.push("");
  lines.push("| Prince | Console route | Checker | Note |");
  lines.push("|---|---|---|---|");
  princes.forEach((prince) => {
    const route = organicSources[prince.stem];
    if (!route) {
      throw new Error(`Missing organic route for ${prince.stem}.`);
    }
    lines.push(`| ${prince.displayName} | \`setstage ${route.quest} ${route.stage}\` | \`node .\\tools\\pdv_daedric_runtime_check.mjs --prince ${route.checker} --strict-manager --source organic --no-generic\` | ${route.note} |`);
  });
  lines.push("");
  lines.push("The `--source organic` checker requires the exact `eventbus_200_po3_queststage_daedric_*` manager marker, so an MCM or QASmoke route cannot count as organic proof.");
  lines.push("");
  lines.push("## Manual Observations To Capture");
  lines.push("");
  lines.push("- Active Effects at Seeker, Devoted, Champion, and lapse.");
  lines.push("- `Show Prince summary` after signal, tier, stigma, live sender, generic silence, and lapse.");
  lines.push("- Prisma or notification display for commitment, boon, price/stigma, and lapse.");
  lines.push("- Generic silence leaves piety, tier, signal count, stigma, and Active Effects unchanged.");
  lines.push("- Hircine and Molag Bal curse-access behavior does not double-fire race `CurseState` rows.");
  lines.push("- Save/load sanity after one standard Prince, one native/tolerated Prince, and one curse-access Prince.");
  lines.push("");
  lines.push("## Evidence Intake");
  lines.push("");
  lines.push("Initialize or inspect the structured evidence ledger:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --init");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --summary");
  lines.push("```");
  lines.push("");
  lines.push("After a successful all-Prince MCM route sweep:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince all --include-generic");
  lines.push("```");
  lines.push("");
  lines.push("After a successful single-Prince QASmoke proof:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --from-runtime-check --source qasmoke --prince Azura --no-generic");
  lines.push("```");
  lines.push("");
  lines.push("After a successful single-Prince organic proof:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --from-runtime-check --source organic --prince Azura --no-generic");
  lines.push("```");
  lines.push("");
  lines.push("After Molag Bal or Hircine curse-access proof, record the no-double-fire slot:");
  lines.push("");
  lines.push("```text");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --record --prince Molag --slot curseNoDoubleFire --status pass --note \"Molag Bal proof did not double-fire race CurseState rows\"");
  lines.push("node .\\tools\\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot curseNoDoubleFire --status pass --note \"Hircine proof did not double-fire race CurseState rows\"");
  lines.push("```");
  lines.push("");
  lines.push("Manual display slots use the same shape with `--slot activeEffects`, `summaryMessage`, `prismaNotification`, `saveLoad`, `stackLegibility`, `curseNoDoubleFire`, or `manualFeel`.");
  lines.push("");
  lines.push("## Automated Gates To Re-Run After Testing");
  lines.push("");
  lines.push("```text");
  lines.push("dotnet run --project .\\tools\\pdv-daedric-author\\PdvDaedricAuthor.csproj -- --check");
  lines.push("node .\\tools\\pdv_content_verify.mjs");
  lines.push("node .\\tools\\pdv_verify.mjs --strict-phase20-race-costing --json");
  lines.push("node .\\tools\\pdv_phase2_reward_readback_audit.mjs --json");
  lines.push("node .\\tools\\pdv_daedric_beta_gate.mjs");
  lines.push("```");
  lines.push("");
  return `${lines.join(os.EOL)}${os.EOL}`;
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  const packet = renderPacket(loadPrinces());
  if (options.write) {
    fs.mkdirSync(path.dirname(options.output), { recursive: true });
    fs.writeFileSync(options.output, packet, "utf8");
    console.log(`Wrote ${options.output}`);
  } else {
    process.stdout.write(packet);
  }
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
