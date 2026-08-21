#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags, makeFlagReader } from "./lib/pdv_cli.mjs";
import { extractHousecarlText, openHousecarl } from "./lib/pdv_housecarl_stdio.mjs";
import {
  buildCensus,
  extractPapyrusCopy,
  extractPrismaCopy,
  flattenRuntimeRecords,
  parseHousecarlDetail,
  parseHousecarlInventory,
  parseManifestRows,
  readUtf8,
  recordTypes,
  renderCsv,
  renderFormalOfferUx,
  renderNordKynePacket,
  renderPenpotUxMapSvg,
  renderPietyNarrativeViability,
  stableHash,
  stableStringify,
  validateCensus,
} from "./lib/pdv_copy_census.mjs";
import {
  buildCopyFlowModel,
  readFlowManifest,
  renderFullFlowPenpotSvg,
} from "./lib/pdv_copy_flow.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const OUTPUT_DIR = path.join(ROOT, "generated", "pdv-copy-census");
const LIVE_SNAPSHOT = path.join(OUTPUT_DIR, "PDV_DevotionLiveRecords.json");
const JSON_REPORT = path.join(OUTPUT_DIR, "PDV_CopyCensus.json");
const CSV_REPORT = path.join(OUTPUT_DIR, "PDV_CopyCensus.csv");
const PILOT_PACKET = path.join(OUTPUT_DIR, "PDV_NordKyne_LearningPacket.md");
const FORMAL_OFFER_UX = path.join(OUTPUT_DIR, "PDV_FormalOfferUX.json");
const PIETY_VIABILITY = path.join(OUTPUT_DIR, "PDV_PietyNarrative_Viability.json");
const PENPOT_MAP = path.join(OUTPUT_DIR, "PDV_CommitmentJourney_Penpot.svg");
const FULL_PENPOT_MAP = path.join(OUTPUT_DIR, "PDV_FullJourney_Penpot.svg");
const FLOW_ASSIGNMENTS = path.join(OUTPUT_DIR, "PDV_CopyFlowAssignments.json");
const FLOW_MANIFEST = path.join(ROOT, "references", "authoring", "PDV_CopyFlowMap.json");

const argv = process.argv.slice(2);
const knownFlags = new Set(["--check", "--help", "--json", "--output-dir", "--refresh-live", "--self-test"]);
assertKnownFlags(argv, knownFlags, {
  toolName: "pdv_copy_census",
  onHelp: () => {
    console.log("Usage: node tools/pdv_copy_census.mjs [--refresh-live] [--check] [--json] [--output-dir PATH] [--self-test]");
    console.log("  --refresh-live  Read Devotion.esp through houseCARL and refresh the ignored local snapshot.");
    console.log("  --check         Rebuild from the local snapshot and fail if reports are absent or stale; writes nothing.");
    console.log("  --output-dir    Override the ignored report directory (primarily for fixtures/CI).");
  },
});
const flags = makeFlagReader(argv);
const outputDir = path.resolve(flags.value("--output-dir") ?? OUTPUT_DIR);
const paths = {
  snapshot: path.join(outputDir, path.basename(LIVE_SNAPSHOT)),
  json: path.join(outputDir, path.basename(JSON_REPORT)),
  csv: path.join(outputDir, path.basename(CSV_REPORT)),
  packet: path.join(outputDir, path.basename(PILOT_PACKET)),
  formalOfferUx: path.join(outputDir, path.basename(FORMAL_OFFER_UX)),
  pietyViability: path.join(outputDir, path.basename(PIETY_VIABILITY)),
  penpotMap: path.join(outputDir, path.basename(PENPOT_MAP)),
  fullPenpotMap: path.join(outputDir, path.basename(FULL_PENPOT_MAP)),
  flowAssignments: path.join(outputDir, path.basename(FLOW_ASSIGNMENTS)),
};

if (flags.has("--self-test")) {
  runSelfTest();
  process.exit(0);
}

try {
  if (flags.has("--refresh-live")) {
    const snapshot = await refreshLiveSnapshot();
    fs.mkdirSync(outputDir, { recursive: true });
    fs.writeFileSync(paths.snapshot, stableStringify(snapshot), "utf8");
  }
  if (!fs.existsSync(paths.snapshot)) {
    throw new Error(`Live snapshot is missing: ${paths.snapshot}\nRun node tools/pdv_copy_census.mjs --refresh-live first.`);
  }
  const result = buildFromSources(JSON.parse(readUtf8(paths.snapshot)));
  const errors = validateCensus(result.census);
  if (errors.length) throw new Error(`Census schema validation failed:\n- ${errors.join("\n- ")}`);
  if (flags.has("--check") && result.flow.summary.unresolvedLiveRows) {
    throw new Error(`Flow classification has ${result.flow.summary.unresolvedLiveRows} unresolved live rows; regenerate for inspection and extend the reviewed flow map.`);
  }
  if (flags.has("--check")) checkReports(result);
  else writeReports(result);
  printSummary(result.census, result.flow, flags.has("--json"), flags.has("--check"));
} catch (error) {
  console.error(`FAIL pdv_copy_census: ${error.message}`);
  process.exit(1);
}

function buildFromSources(snapshot) {
  const manifestPaths = [
    "race-sheets/PDV_RaceContent_Manifest.md",
    "race-sheets/PDV_DaedricContent_Manifest.md",
  ];
  const papyrusPaths = listFiles("live-source/Scripts/Source", (file) => file.toLowerCase().endsWith(".psc"));
  const prismaPaths = listFiles("native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion", (file) => /\.(?:html|js)$/i.test(file));
  const manifestRows = manifestPaths.flatMap((relative) => parseManifestRows(readUtf8(path.join(ROOT, relative)), relative));
  const espRows = flattenRuntimeRecords(snapshot.records ?? []);
  const papyrusRows = papyrusPaths.flatMap((relative) => extractPapyrusCopy(readUtf8(path.join(ROOT, relative)), relative));
  const prismaRows = prismaPaths.flatMap((relative) => extractPrismaCopy(readUtf8(path.join(ROOT, relative)), relative));
  const sourceFiles = [...manifestPaths, ...papyrusPaths, ...prismaPaths];
  const sourceFingerprint = Object.fromEntries(sourceFiles.sort().map((relative) => [relative, stableHash(readUtf8(path.join(ROOT, relative)).replace(/\r\n/g, "\n"), 64)]));
  sourceFingerprint["live:Devotion.esp"] = snapshot.pluginFingerprint || stableHash(snapshot.records ?? [], 64);
  const census = buildCensus({
    runtimeRows: [...espRows, ...papyrusRows, ...prismaRows],
    manifestRows,
    sourceFingerprint,
    extractionCoverage: {
      livePlugin: snapshot.coverage ?? {},
      papyrus: { files: papyrusPaths.length, rows: papyrusRows.length, dynamic: papyrusRows.filter((row) => row.dynamic).length, excludedDeveloperDebug: papyrusRows.filter((row) => row.excluded).length },
      prisma: { files: prismaPaths.length, rows: prismaRows.length, dynamic: prismaRows.filter((row) => row.dynamic).length },
      writingReferences: { files: manifestPaths.length, rows: manifestRows.length },
    },
    sourceClasses: [
      { source: "live Devotion.esp", classification: "current runtime authority", note: "Direct houseCARL readback; player-visible record fields only." },
      { source: "live-source/Scripts/Source", classification: "current runtime/gameplay authority", note: "Tracked player-facing Papyrus/MCM source; dynamic expressions require manual review." },
      { source: "native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion", classification: "current runtime presentation authority", note: "Tracked Prisma HTML/JS view copy." },
      { source: "race-sheets/PDV_RaceContent_Manifest.md", classification: "current voice/lore reference plus useful historical content bank", note: "Never presumed to match the live game." },
      { source: "race-sheets/PDV_DaedricContent_Manifest.md", classification: "current voice/lore reference plus useful historical content bank", note: "Never presumed to match the live game." },
      { source: "race-sheets/writer-review", classification: "stale generated review", note: "Excluded from extraction." },
      { source: "_retired, archives, scratch review packs", classification: "irrelevant archive/debug material", note: "Excluded from extraction." },
    ],
  });
  const flow = buildCopyFlowModel(census, readFlowManifest(FLOW_MANIFEST));
  if (flow.summary.missingSurfaceRows) throw new Error(`Flow assignment left ${flow.summary.missingSurfaceRows} live rows without a player surface.`);
  const serializableFlow = { ...flow };
  delete serializableFlow.byCopyId;
  return {
    census,
    flow,
    csv: renderCsv(census),
    packet: renderNordKynePacket(census),
    formalOfferUx: stableStringify(renderFormalOfferUx(census)),
    pietyViability: stableStringify(renderPietyNarrativeViability()),
    penpotMap: renderPenpotUxMapSvg(),
    fullPenpotMap: renderFullFlowPenpotSvg(flow),
    flowAssignments: stableStringify(serializableFlow),
  };
}

function listFiles(relativeDir, predicate) {
  const absolute = path.join(ROOT, relativeDir);
  if (!fs.existsSync(absolute)) return [];
  const pending = [absolute];
  const found = [];
  while (pending.length) {
    const dir = pending.pop();
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) pending.push(full);
      else if (predicate(full)) found.push(path.relative(ROOT, full).replace(/\\/g, "/"));
    }
  }
  return found.sort();
}

async function refreshLiveSnapshot() {
  const session = openHousecarl({ cwd: ROOT, timeoutMs: 120_000 });
  try {
    const statusText = extractHousecarlText(await session.call("housecarl_load_order_status", { lookup: "Devotion.esp" }, { timeoutMs: 120_000 }));
    if (!/Devotion Dev/i.test(statusText) || !/Devotion\.esp.*ACTIVE|ACTIVE.*Devotion\.esp/is.test(statusText)) {
      throw new Error(`Refusing live census outside the active Devotion Dev profile/plugin boundary.\n${statusText.slice(0, 2000)}`);
    }
    const records = [];
    const coverage = {};
    for (const [type, config] of Object.entries(recordTypes())) {
      const inventoryText = extractHousecarlText(await session.call("housecarl_cross_plugin_query", {
        plugins: ["Devotion.esp"],
        type,
        editorid_contains: "PDV_",
        limit: 2000,
        max_chars: 250000,
      }, { timeoutMs: 120_000 }));
      const inventory = parseHousecarlInventory(inventoryText, type);
      const reportedTotal = Number(inventoryText.match(/cross_plugin_query:\s*(\d+)\s+matches/i)?.[1] ?? inventory.length);
      if (reportedTotal !== inventory.length || /showing first|rendered \d+ of|truncat|stopped after/i.test(inventoryText)) {
        throw new Error(`${type} inventory was incomplete: houseCARL reported ${reportedTotal}, parser captured ${inventory.length}. Narrow or raise the read limits before retrying.`);
      }
      coverage[type] = { inventory: inventory.length, detailed: 0, status: inventory.length ? "extracted" : "none-found-or-manual-review" };
      for (let offset = 0; offset < inventory.length; offset += 40) {
        const chunk = inventory.slice(offset, offset + 40);
        const detailText = extractHousecarlText(await session.call("housecarl_batch_record_detail", {
          formids: chunk.map((item) => item.formId),
          fields: config.fields,
          depth: config.depth,
          max_chars: 250000,
        }, { timeoutMs: 120_000 }));
        const detailed = parseHousecarlDetail(detailText, type);
        records.push(...detailed);
        coverage[type].detailed += detailed.length;
      }
      if (coverage[type].detailed !== coverage[type].inventory) {
        coverage[type].status = "manual-review-count-mismatch";
        throw new Error(`${type} detail coverage mismatch: inventory=${coverage[type].inventory}, detailed=${coverage[type].detailed}. No snapshot was written.`);
      }
    }
    const normalized = records
      .filter((record) => record.editorId?.startsWith("PDV_"))
      .sort((a, b) => `${a.recordType}:${a.formId}`.localeCompare(`${b.recordType}:${b.formId}`));
    if (!normalized.length) throw new Error("houseCARL returned no detailed PDV records; no snapshot was written.");
    return {
      schema: "pdv.copy-census.live-snapshot.v1",
      profile: "Devotion Dev",
      plugin: "Devotion.esp",
      proof: "direct read-only houseCARL inventory plus batch record detail",
      housecarlExecutable: session.executable.replace(/\\/g, "/"),
      coverage,
      pluginFingerprint: stableHash(normalized, 64),
      records: normalized,
    };
  } finally {
    session.close();
  }
}

function writeReports(result) {
  fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(paths.json, stableStringify(result.census), "utf8");
  fs.writeFileSync(paths.csv, result.csv, "utf8");
  fs.writeFileSync(paths.packet, result.packet, "utf8");
  fs.writeFileSync(paths.formalOfferUx, result.formalOfferUx, "utf8");
  fs.writeFileSync(paths.pietyViability, result.pietyViability, "utf8");
  fs.writeFileSync(paths.penpotMap, result.penpotMap, "utf8");
  fs.writeFileSync(paths.fullPenpotMap, result.fullPenpotMap, "utf8");
  fs.writeFileSync(paths.flowAssignments, result.flowAssignments, "utf8");
}

function checkReports(result) {
  const expected = new Map([
    [paths.json, stableStringify(result.census)],
    [paths.csv, result.csv],
    [paths.packet, result.packet],
    [paths.formalOfferUx, result.formalOfferUx],
    [paths.pietyViability, result.pietyViability],
    [paths.penpotMap, result.penpotMap],
    [paths.fullPenpotMap, result.fullPenpotMap],
    [paths.flowAssignments, result.flowAssignments],
  ]);
  for (const [file, content] of expected) {
    if (!fs.existsSync(file)) throw new Error(`Expected regenerable report is missing: ${file}`);
    if (readUtf8(file) !== content) throw new Error(`Regenerable report is stale: ${file}`);
  }
}

function printSummary(census, flow, asJson, checked) {
  const output = {
    verdict: "PASS",
    mode: checked ? "check" : "write",
    rows: census.summary.rowCount,
    dynamicManualReview: census.summary.dynamicManualReview,
    excludedDeveloperDebug: census.summary.excludedDeveloperDebug,
    byRisk: census.summary.byRisk,
    unresolvedLiveRows: flow.summary.unresolvedLiveRows,
    outputDir,
  };
  if (asJson) console.log(JSON.stringify(output));
  else console.log(`PASS pdv_copy_census: rows=${output.rows} manual=${output.dynamicManualReview} excluded-dev=${output.excludedDeveloperDebug} output=${outputDir}`);
}

function runSelfTest() {
  const manifest = parseManifestRows("| PDV_Msg_Nord_Kyne_Offer | MessageBox | Marked | God-voice | 500/280 | Nord design | At Faithful | Title: \"Kyne Reaches Back\" Body: \"Will you carry my name?\" |", "fixture.md");
  if (manifest.length !== 1) throw new Error("manifest fixture did not parse");
  const detail = parseHousecarlDetail("type=Message  formid=071513 editorid=PDV_Msg_Nord_Kyne_Offer winner=Devotion.esp\n  EditorID = PDV_Msg_Nord_Kyne_Offer\n  Name = Kyne Reaches Back\n  Description = Will you carry my name?", "MESG");
  const census = buildCensus({ runtimeRows: flattenRuntimeRecords(detail), manifestRows: manifest });
  const errors = validateCensus(census);
  if (errors.length || census.rows.length !== 2 || census.rows.some((row) => row.parity !== "exact")) throw new Error(`self-test failed: ${errors.join("; ")}`);
  console.log("PASS pdv_copy_census self-test");
}
