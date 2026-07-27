#!/usr/bin/env node
/*
 * Read-only Prisma toast fallback and P2 book-route hardening audit.
 *
 * This is source/contract proof only. In-game Prisma display, route logs,
 * Book of Days manual behavior, and acceptance feel remain separate proof
 * surfaces.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const LIVE_SOURCE = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";
const MANIFEST = path.join(ROOT, "references", "authoring", "PDV_Phase20_P2ImmersiveReceivers.manifest.json");

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  const sourceRoot = path.resolve(args.sourceRoot || LIVE_SOURCE);
  const managerPath = path.join(sourceRoot, "PDV__ManagerQuest.psc");
  const playerEventsPath = path.join(sourceRoot, "PDV_PlayerEvents.psc");
  const eventBusPath = path.join(sourceRoot, "PDV_EventBus.psc");
  const findings = [];
  const pass = (check, detail, filePath = null) => findings.push({ status: "PASS", check, detail, path: filePath });
  const fail = (check, detail, filePath = null) => findings.push({ status: "FAIL", check, detail, path: filePath });

  const manager = readRequired(managerPath, "Manager source", pass, fail);
  const playerEvents = readRequired(playerEventsPath, "PlayerEvents source", pass, fail);
  const eventBus = readRequired(eventBusPath, "EventBus source", pass, fail);
  const manifest = readJsonRequired(MANIFEST, "P2 immersive receiver manifest", pass, fail);

  if (manager) {
    verifySharedFallback(manager, managerPath, pass, fail);
    verifyToastHelpers(manager, managerPath, pass, fail);
    verifyRawNotifications(manager, managerPath, pass, fail);
    verifyBookNotice(manager, managerPath, pass, fail);
    verifyNoToastPanelOrJournalSideEffect(manager, managerPath, pass, fail);
  }

  if (manager && playerEvents && eventBus && manifest) {
    verifyNordBookRoute({ manager, playerEvents, eventBus, manifest }, { managerPath, playerEventsPath, eventBusPath, manifestPath: MANIFEST }, pass, fail);
  }

  runSelfTests(pass, fail);

  const passCount = findings.filter((finding) => finding.status === "PASS").length;
  const failCount = findings.filter((finding) => finding.status === "FAIL").length;
  const summary = {
    status: failCount === 0 ? "PASS" : "FAIL",
    passCount,
    failCount,
    sourceRoot: toDisplayPath(sourceRoot),
    findings
  };

  if (args.json) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    printTextSummary(summary);
  }

  process.exit(failCount === 0 ? 0 : 1);
}

function parseArgs(argv) {
  const args = { json: false, sourceRoot: null };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--source-root") {
      args.sourceRoot = argv[++i];
    } else if (arg === "--help" || arg === "-h") {
      console.log("Usage: node tools/pdv_prisma_toast_fallback_audit.mjs [--json] [--source-root PATH]");
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function readRequired(filePath, label, pass, fail) {
  if (!fs.existsSync(filePath)) {
    fail(label, "File is missing.", filePath);
    return "";
  }
  const text = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  pass(label, `Read ${text.length} characters.`, filePath);
  return text;
}

function readJsonRequired(filePath, label, pass, fail) {
  if (!fs.existsSync(filePath)) {
    fail(label, "File is missing.", filePath);
    return null;
  }
  try {
    const parsed = JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
    pass(label, "Parsed JSON.", filePath);
    return parsed;
  } catch (error) {
    fail(label, `JSON parse failed: ${error.message}`, filePath);
    return null;
  }
}

function functionBlock(source, name) {
  const match = source.match(new RegExp(`(?:Bool\\s+|String\\s+)?Function\\s+${name}\\b[\\s\\S]*?EndFunction`, "i"));
  return match ? match[0] : "";
}

function eventBlock(source, name) {
  const match = source.match(new RegExp(`Event\\s+${name}\\b[\\s\\S]*?EndEvent`, "i"));
  return match ? match[0] : "";
}

function includesAll(source, snippets) {
  return snippets.every((snippet) => source.includes(snippet));
}

function verifySharedFallback(manager, filePath, pass, fail) {
  const block = functionBlock(manager, "SendPrismaToastPayloadOrFallback");
  if (!block) {
    fail("Shared toast fallback helper", "SendPrismaToastPayloadOrFallback is missing.", filePath);
    return;
  }
  const required = [
    "PDV_PrismaBridge.IsAvailable()",
    "PDV_PrismaBridge.SendOverlayJson(payload)",
    "ShowToastFallbackNotification(fallbackTitle, fallbackMessage)",
    "return sent"
  ];
  if (includesAll(block, required)) {
    pass("Shared toast fallback helper", "Helper tries Prisma overlay first and falls back to top-left only through the shared fallback.", filePath);
  } else {
    fail("Shared toast fallback helper", "Helper must use IsAvailable, SendOverlayJson, shared fallback, and return the send result.", filePath);
  }

  const fallbackBlock = functionBlock(manager, "ShowToastFallbackNotification");
  if (fallbackBlock.includes("Debug.Notification(fallbackText)")) {
    pass("Shared vanilla fallback", "Only the shared fallback helper emits the player-facing top-left fallback.", filePath);
  } else {
    fail("Shared vanilla fallback", "ShowToastFallbackNotification must be the single player-facing Debug.Notification fallback.", filePath);
  }
}

function verifyToastHelpers(manager, filePath, pass, fail) {
  const helpers = [
    "SendPrismaToast",
    "SendPrismaEventToast",
    "SendPrismaShiftToast",
    "SendPrismaSubstrateToast",
    "SendPrismaDaedricToast",
    "SendPrismaDaedricMilestoneToast"
  ];

  for (const helper of helpers) {
    const block = functionBlock(manager, helper);
    if (!block) {
      fail(`${helper} helper`, "Function is missing.", filePath);
    } else if (block.includes("SendPrismaToastPayloadOrFallback(")) {
      pass(`${helper} helper`, "Routes through the shared Prisma-first fallback helper.", filePath);
    } else {
      fail(`${helper} helper`, "Must route through SendPrismaToastPayloadOrFallback or explicitly document no fallback.", filePath);
    }
  }
}

function verifyRawNotifications(manager, filePath, pass, fail) {
  const fallbackRange = functionBlock(manager, "ShowToastFallbackNotification");
  const debugNeglectPrimeRange = functionBlock(manager, "DebugPrimeRaceLaneNeglect");
  const allowedLiteralFragments = [
    "PDV seed:",
    "PDV Phase 0:",
    "Talos betrayal did not apply;"
  ];

  const lines = manager.split(/\r?\n/);
  const failures = [];
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (!line.includes("Debug.Notification(")) continue;
    if (fallbackRange.includes(line.trim())) continue;
    if (debugNeglectPrimeRange.includes(line.trim())) continue;
    if (allowedLiteralFragments.some((fragment) => line.includes(fragment))) continue;
    failures.push({ line: i + 1, text: line.trim() });
  }

  if (failures.length === 0) {
    pass("Raw Debug.Notification allowlist", "Only seed/debug diagnostics and the shared fallback helper use raw top-left notifications.", filePath);
  } else {
    for (const item of failures) {
      fail("Raw Debug.Notification allowlist", `Unallowlisted raw notification at line ${item.line}: ${item.text}`, filePath);
    }
  }
}

function verifyBookNotice(manager, filePath, pass, fail) {
  const block = functionBlock(manager, "ShowP2BookNotice");
  if (!block) {
    fail("ShowP2BookNotice", "Function is missing.", filePath);
    return;
  }

  if (block.includes("Debug.Notification(")) {
    fail("ShowP2BookNotice", "Book notices must not directly emit top-left notifications.", filePath);
  } else {
    pass("ShowP2BookNotice", "No direct top-left notification is present.", filePath);
  }

  const surfaceBlock = functionBlock(manager, "SurfaceP2BookReadNotice");
  if (!surfaceBlock) {
    fail("P2 book-read surface", "SurfaceP2BookReadNotice is missing.", filePath);
    return;
  }

  if (!block.includes("SurfaceP2BookReadNotice(reason, titleText, messageText)")) {
    fail("ShowP2BookNotice delegation", "Compatibility wrapper must delegate to SurfaceP2BookReadNotice.", filePath);
  } else {
    pass("ShowP2BookNotice delegation", "Compatibility wrapper delegates to the explicit book-read surface.", filePath);
  }

  const guardIndex = surfaceBlock.indexOf("if !IsP2BookNoticeReason(reason)");
  const sendIndex = surfaceBlock.indexOf("SurfaceP2Acknowledgement(");
  if (guardIndex >= 0 && sendIndex > guardIndex) {
    pass("ShowP2BookNotice book guard", "Explicit book-read surface is gated by IsP2BookNoticeReason(reason).", filePath);
  } else {
    fail("ShowP2BookNotice book guard", "SurfaceP2BookReadNotice must gate delivery with IsP2BookNoticeReason(reason).", filePath);
  }

  const reasonBlock = functionBlock(manager, "IsP2BookNoticeReason");
  if (
    reasonBlock.includes('reason == "po3_book"') ||
    reasonBlock.includes('StringStartsWith(reason, "po3_book_")') ||
    reasonBlock.includes('StringContainsToken(reason, "po3_book")')
  ) {
    pass("P2 book reason predicate", "Book predicate accepts the stable po3_book reason family.", filePath);
  } else {
    fail("P2 book reason predicate", "IsP2BookNoticeReason must accept po3_book and po3_book_* reasons.", filePath);
  }
}

function verifyNoToastPanelOrJournalSideEffect(manager, filePath, pass, fail) {
  const blocks = [
    functionBlock(manager, "SendPrismaToastPayloadOrFallback"),
    functionBlock(manager, "ShowToastFallbackNotification"),
    functionBlock(manager, "ShowP2BookNotice")
  ].join("\n");
  const forbidden = [
    "SendPrismaJournalPayload(",
    "PDV.Diegetic.Journal.Open",
    "RequestPanelRefresh(",
    "OpenDevotionPanel(",
    "ToggleDevotionPanel(",
    "PDV_PrismaBridge.SendJson("
  ];

  const hits = forbidden.filter((snippet) => blocks.includes(snippet));
  if (hits.length === 0) {
    pass("Toast side-effect boundary", "Toast/fallback/book-notice helpers do not open panels or Book of Days.", filePath);
  } else {
    fail("Toast side-effect boundary", `Toast helpers contain forbidden side-effect snippets: ${hits.join(", ")}`, filePath);
  }
}

function verifyNordBookRoute({ manager, playerEvents, eventBus, manifest }, paths, pass, fail) {
  const onBookRead = eventBlock(playerEvents, "OnBookRead");
  if (/RouteP2ImmersiveSource\(akBook as Form,\s*"po3_book"(?:,\s*logicalEventId)?\)/.test(onBookRead)) {
    pass("Book read event route", "OnBookRead routes books into the P2 immersive source path.", paths.playerEventsPath);
  } else {
    fail("Book read event route", "OnBookRead must call RouteP2ImmersiveSource(akBook as Form, \"po3_book\").", paths.playerEventsPath);
  }

  const p2Route = functionBlock(playerEvents, "RouteP2ImmersiveSource");
  if (
    p2Route.includes("PDV_FLST_P2_NordOldWaysSources") &&
    p2Route.includes('"nord_old_ways"') &&
    p2Route.includes('RouteNordOldWaysState(sourceKind + "_nord_old_ways_ancestor")')
  ) {
    pass("Nord Old Ways P2 route", "P2 source routing maps Nord Old Ways books to the EventBus.", paths.playerEventsPath);
  } else {
    fail("Nord Old Ways P2 route", "Nord Old Ways P2 route is missing or not source-preserving.", paths.playerEventsPath);
  }

  const busRoute = functionBlock(eventBus, "RouteNordOldWaysState");
  if (busRoute.includes("HandleNordOldWaysState") && busRoute.includes('"eventbus_" + eventType + "_" + sourceId')) {
    pass("Nord Old Ways EventBus route", "EventBus preserves sourceId when forwarding Nord Old Ways state.", paths.eventBusPath);
  } else {
    fail("Nord Old Ways EventBus route", "RouteNordOldWaysState must forward a source-bearing reason to the manager.", paths.eventBusPath);
  }

  const managerHandler = functionBlock(manager, "HandleNordOldWaysState");
  if (
    managerHandler.includes('SurfaceP2BookReadNotice(reason, "The Old Ways"') &&
    managerHandler.includes("RouteNordFamily(reason")
  ) {
    pass("Nord Old Ways manager surface", "Manager surfaces the approved Nord book route through SurfaceP2BookReadNotice.", paths.managerPath);
  } else {
    fail("Nord Old Ways manager surface", "HandleNordOldWaysState must route accepted Nord Old Ways reasons to SurfaceP2BookReadNotice.", paths.managerPath);
  }

  const nordEntry = findManifestSource(manifest, "PDV_FLST_P2_NordOldWaysSources", "Skyrim.esm:0ED161", "Book1CheapNordsArise");
  if (nordEntry && nordEntry.sourceKind === "book" && nordEntry.status === "approved-for-fill") {
    pass("Nord 000ED161 source fill", "Book1CheapNordsArise / Nords Arise! is an approved Nord Old Ways P2 book source.", paths.manifestPath);
  } else {
    fail("Nord 000ED161 source fill", "Skyrim.esm:0ED161 Book1CheapNordsArise must remain approved in PDV_FLST_P2_NordOldWaysSources.", paths.manifestPath);
  }
}

function findManifestSource(manifest, property, formKey, editorId) {
  const entries = Array.isArray(manifest?.sourceFillEntries) ? manifest.sourceFillEntries : [];
  const group = entries.find((entry) => entry.property === property);
  if (!group || !Array.isArray(group.sources)) return null;
  return group.sources.find((source) => source.formKey === formKey && source.editorId === editorId) ?? null;
}

function runSelfTests(pass, fail) {
  const minimalManager = [
    "Bool Function SendPrismaToastPayloadOrFallback(String payload, String fallbackTitle, String fallbackMessage, Bool allowFallback = True)",
    "if PDV_PrismaBridge.IsAvailable()",
    "sent = PDV_PrismaBridge.SendOverlayJson(payload)",
    "endIf",
    "if !sent && allowFallback",
    "ShowToastFallbackNotification(fallbackTitle, fallbackMessage)",
    "endIf",
    "return sent",
    "EndFunction",
    "Function ShowToastFallbackNotification(String titleText, String messageText)",
    "Debug.Notification(fallbackText)",
    "EndFunction",
    "Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(payload, titleText, messageText, allowFallback)",
    "EndFunction",
    "Bool Function SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(j, \"\", context, allowFallback)",
    "EndFunction",
    "Bool Function SendPrismaShiftToast(String shiftMode, String context, String symbolName, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(j, shiftMode, context, allowFallback)",
    "EndFunction",
    "Bool Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String stateLabel, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(j, substrate, context, allowFallback)",
    "EndFunction",
    "Bool Function SendPrismaDaedricToast(String princeName, String phase, String context, String symbolName, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(j, princeName, context, allowFallback)",
    "EndFunction",
    "Bool Function SendPrismaDaedricMilestoneToast(String princeName, String tierLabel, String flavorText, String boonText, String priceText, String symbolName, Bool allowFallback = True)",
    "return SendPrismaToastPayloadOrFallback(j, princeName, flavorText, allowFallback)",
    "EndFunction",
    "Function ShowP2BookNotice(String reason, String titleText, String messageText)",
    "SurfaceP2BookReadNotice(reason, titleText, messageText)",
    "EndFunction",
    "Function SurfaceP2BookReadNotice(String reason, String titleText, String messageText)",
    "if !IsP2BookNoticeReason(reason)",
    "return",
    "endIf",
    "SendPrismaToast(\"journal\", \"good\", titleText, messageText)",
    "EndFunction",
    "Bool Function IsP2BookNoticeReason(String reason)",
    "return StringContainsToken(reason, \"po3_book\")",
    "EndFunction"
  ].join("\n");

  const minimalPlayerEvents = [
    "Event OnBookRead(Book akBook)",
    "RouteP2ImmersiveSource(akBook as Form, \"po3_book\")",
    "EndEvent",
    "Function RouteP2ImmersiveSource(Form sourceForm, String sourceKind)",
    "if ShouldRouteP2Source(PDV_FLST_P2_NordOldWaysSources, sourceForm, \"nord_old_ways\", sourceKind)",
    "PDV_EventBusService.RouteNordOldWaysState(sourceKind + \"_nord_old_ways_ancestor\")",
    "endIf",
    "EndFunction"
  ].join("\n");

  const minimalEventBus = [
    "Function RouteNordOldWaysState(String sourceId)",
    "PDV_Manager.HandleNordOldWaysState(\"eventbus_\" + eventType + \"_\" + sourceId)",
    "EndFunction"
  ].join("\n");

  const minimalManifest = {
    sourceFillEntries: [
      {
        property: "PDV_FLST_P2_NordOldWaysSources",
        sources: [
          { formKey: "Skyrim.esm:0ED161", editorId: "Book1CheapNordsArise", sourceKind: "book", status: "approved-for-fill" }
        ]
      }
    ]
  };

  const cases = [
    {
      name: "removing RouteP2ImmersiveSource from OnBookRead",
      run: () => {
        const findings = collect((p, f) => verifyNordBookRoute({
          manager: minimalManager + '\nFunction HandleNordOldWaysState(String reason)\nif RouteNordFamily(reason, "x", "y", "z", "Nord Old Ways state")\nSurfaceP2BookReadNotice(reason, "The Old Ways", "x")\nendIf\nEndFunction',
          playerEvents: minimalPlayerEvents.replace('RouteP2ImmersiveSource(akBook as Form, "po3_book")', ""),
          eventBus: minimalEventBus,
          manifest: minimalManifest
        }, {}, p, f));
        return findings.some((finding) => finding.status === "FAIL" && finding.check === "Book read event route");
      }
    },
    {
      name: "changing ShowP2BookNotice to direct top-left only",
      run: () => {
        const bad = minimalManager.replace('SendPrismaToast("journal", "good", titleText, messageText)', "Debug.Notification(titleText + messageText)");
        const findings = collect((p, f) => verifyBookNotice(bad, "", p, f));
        return findings.some((finding) => finding.status === "FAIL" && finding.check.startsWith("ShowP2BookNotice"));
      }
    },
    {
      name: "adding a new unallowlisted gameplay Debug.Notification",
      run: () => {
        const findings = collect((p, f) => verifyRawNotifications(`${minimalManager}\nFunction NewGameplayNotice()\nDebug.Notification("new gameplay")\nEndFunction`, "", p, f));
        return findings.some((finding) => finding.status === "FAIL" && finding.check === "Raw Debug.Notification allowlist");
      }
    },
    {
      name: "making toast fallback open a panel or Book of Days",
      run: () => {
        const bad = minimalManager.replace("return sent", "RequestPanelRefresh()\nSendPrismaJournalPayload(True)\nreturn sent");
        const findings = collect((p, f) => verifyNoToastPanelOrJournalSideEffect(bad, "", p, f));
        return findings.some((finding) => finding.status === "FAIL" && finding.check === "Toast side-effect boundary");
      }
    }
  ];

  for (const selfTest of cases) {
    try {
      if (selfTest.run()) {
        pass("Audit negative fixture", `${selfTest.name} is caught by the audit.`);
      } else {
        fail("Audit negative fixture", `${selfTest.name} was not caught by the audit.`);
      }
    } catch (error) {
      fail("Audit negative fixture", `${selfTest.name} threw unexpectedly: ${error.message}`);
    }
  }
}

function collect(callback) {
  const findings = [];
  const pass = (check, detail, filePath = null) => findings.push({ status: "PASS", check, detail, path: filePath });
  const fail = (check, detail, filePath = null) => findings.push({ status: "FAIL", check, detail, path: filePath });
  callback(pass, fail);
  return findings;
}

function printTextSummary(summary) {
  console.log(`pdv_prisma_toast_fallback_audit: ${summary.status}`);
  console.log(`sourceRoot=${summary.sourceRoot}`);
  console.log(`PASS=${summary.passCount} FAIL=${summary.failCount}`);
  for (const finding of summary.findings) {
    const suffix = finding.path ? ` (${toDisplayPath(finding.path)})` : "";
    console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${suffix}`);
  }
}

function toDisplayPath(filePath) {
  if (!filePath) return "";
  const normalized = path.resolve(filePath);
  const rel = path.relative(ROOT, normalized);
  if (rel && !rel.startsWith("..") && !path.isAbsolute(rel)) {
    return rel;
  }
  return normalized;
}
