#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const DEVOTION_SOURCE = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts\\Source";
const DEVOTION_PRISMA_VIEW = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\PrismaUI\\views\\Devotion\\app.js";
const REPO_ROOT = process.cwd();
const NATIVE_BRIDGE_SOURCE = path.join(REPO_ROOT, "native", "DevotionPrismaBridge", "src", "main.cpp");

function fail(message, source = "") {
  failures.push({ message, source });
}

function pass(message, source = "") {
  passes.push({ message, source });
}

function read(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function functionBlock(source, functionName) {
  const pattern = new RegExp(`(?:Bool\\s+)?Function\\s+${functionName}\\b[\\s\\S]*?EndFunction`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
}

function eventBlock(source, eventName) {
  const pattern = new RegExp(`Event\\s+${eventName}\\b[\\s\\S]*?EndEvent`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
}

function functionNamesContaining(source, literal) {
  const result = [];
  const pattern = /(?:Bool\s+)?Function\s+(\w+)\b[\s\S]*?EndFunction/gi;
  let match;
  while ((match = pattern.exec(source))) {
    if (match[0].includes(literal)) {
      result.push(match[1]);
    }
  }
  return result.sort();
}

function countMatches(source, pattern) {
  const matches = source.match(pattern);
  return matches ? matches.length : 0;
}

function sameStringSet(actual, expected) {
  if (actual.length !== expected.length) {
    return false;
  }
  return actual.every((value, index) => value === expected[index]);
}

const failures = [];
const passes = [];

if (!fs.existsSync(DEVOTION_SOURCE)) {
  fail("Devotion source folder is missing.", DEVOTION_SOURCE);
} else {
  const pscFiles = fs
    .readdirSync(DEVOTION_SOURCE)
    .filter((name) => name.endsWith(".psc") && !name.startsWith("codex-"));

  for (const name of pscFiles) {
    const filePath = path.join(DEVOTION_SOURCE, name);
    const source = read(filePath);

    // PDV_PrismaBridge.psc declares the natives; PDV_MCM.psc is the sanctioned player-owned
    // UI entry point (the rebindable "Open Devotion panel" hotkey) that focuses the full
    // panel. Every other source is gameplay and must not open the focused panel.
    if (name !== "PDV_PrismaBridge.psc" && name !== "PDV_MCM.psc") {
      for (const forbidden of ["OpenDevotionPanel", "ToggleDevotionPanel"]) {
        if (source.includes(`PDV_PrismaBridge.${forbidden}(`)) {
          fail(`Gameplay source calls ${forbidden}; only player-owned UI entry points may open the full panel.`, filePath);
        }
      }
    }

    if (name !== "PDV__ManagerQuest.psc" && source.includes("PDV_PrismaBridge.SendJson(")) {
      fail("Non-manager source sends focused panel JSON.", filePath);
    }

    if (
      name !== "PDV__ManagerQuest.psc" &&
      name !== "PDV_PrismaBridge.psc" &&
      source.includes("PDV_PrismaBridge.SendOverlayJson(")
    ) {
      if (name !== "PDV_T3DailyLowHealthSaveEffect.psc") {
        fail("Only approved helper/capstone sources may send raw overlay JSON outside the manager.", filePath);
      } else if (!source.includes('{\\"mode\\":\\"toast\\"')) {
        fail("The capstone overlay sender must remain a toast payload, never a modal/panel payload.", filePath);
      } else {
        pass("Approved capstone overlay sender is toast-only.", filePath);
      }
    }

    if (
      name !== "PDV_MCM.psc" &&
      source.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 1)')
    ) {
      fail("Only the player-owned MCM/hotkey surface may mark Book of Days open.", filePath);
    }

    if (name !== "PDV_MCM.psc" && source.includes("SendPrismaJournalPayload(True")) {
      fail("Only the player-owned MCM/hotkey surface may request the Book of Days modal.", filePath);
    }
  }

  const managerPath = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
  if (!fs.existsSync(managerPath)) {
    fail("Manager source is missing.", managerPath);
  } else {
    const manager = read(managerPath);
    const pushBlock = functionBlock(manager, "PushDevotionPanel");
    const onUpdateBlock = eventBlock(manager, "OnUpdate");
    const startupBlock = functionBlock(manager, "SendPrismaStartupPayload");
    const medallionBlock = functionBlock(manager, "SendPrismaMedallionPayload");
    const p2BookNoticeBlock = functionBlock(manager, "ShowP2BookNotice");
    const overlaySenderFunctions = functionNamesContaining(manager, "PDV_PrismaBridge.SendOverlayJson(");
    const focusedSenderFunctions = functionNamesContaining(manager, "PDV_PrismaBridge.SendJson(");

    if (!manager.includes("Bool Property AutoPushPrismaPanel = False Auto")) {
      fail("Manager is missing the default-off full-panel push property.", managerPath);
    } else {
      pass("AutoPushPrismaPanel defaults false.", managerPath);
    }

    if (!manager.includes("Bool Property AllowPrismaBlockingSurfaces = False Auto")) {
      fail("Manager is missing the default-off blocking-surface property.", managerPath);
    } else {
      pass("AllowPrismaBlockingSurfaces defaults false.", managerPath);
    }

    if (!pushBlock.includes("if !playerRequested") || !pushBlock.includes("PDV_PrismaBridge.SendJson(")) {
      fail("PushDevotionPanel must reject non-player requests before focused SendJson.", managerPath);
    } else {
      pass("PushDevotionPanel is player-request gated.", managerPath);
    }

    if (!sameStringSet(focusedSenderFunctions, ["PushDevotionPanel"])) {
      fail(`Focused SendJson may only live in PushDevotionPanel; found ${focusedSenderFunctions.join(", ") || "none"}.`, managerPath);
    } else {
      pass("Focused SendJson is confined to PushDevotionPanel.", managerPath);
    }

    const expectedOverlaySenderFunctions = [
      "ClosePrismaJournal",
      "DebugClosePrismaSurfaces",
      "ProcessQueuedPrismaToastRetry",
      "SendPrismaCurseToast",
      "SendPrismaJournalPayload",
      "SendPrismaMedallionPayload",
      "SendPrismaStartupPayload",
      "SendPrismaToastPayloadOrFallback",
    ].sort();
    if (!sameStringSet(overlaySenderFunctions, expectedOverlaySenderFunctions)) {
      fail(`Manager overlay senders drifted; found ${overlaySenderFunctions.join(", ") || "none"}.`, managerPath);
    } else {
      pass("Manager overlay senders are confined to approved toast/modal close/open helpers.", managerPath);
    }

    if (onUpdateBlock.includes("PushDevotionPanel(")) {
      fail("OnUpdate must not auto-open the focused Devotion panel.", managerPath);
    } else {
      pass("OnUpdate does not auto-open the focused Devotion panel.", managerPath);
    }

    const awardPietyBlock = functionBlock(manager, "AwardPietyInternal");
    if (!awardPietyBlock.includes("RecordDeityDriver(deity, reason, appliedAmount)")) {
      fail("Every nonzero AwardPiety movement must record a dashboard driver for the moved deity.", managerPath);
    } else {
      pass("Every nonzero AwardPiety movement records a dashboard driver.", managerPath);
    }

    if (awardPietyBlock.includes("IsDashboardTrackedDeity(")) {
      fail("Dashboard driver capture must not be gated to active patron / emphasis only.", managerPath);
    } else {
      pass("Dashboard driver capture is not active-patron gated.", managerPath);
    }

    if (!startupBlock.includes("if !AllowPrismaBlockingSurfaces") || !startupBlock.includes("\\\"mode\\\":\\\"startup\\\"")) {
      fail("SendPrismaStartupPayload must be guarded as a blocking UI surface.", managerPath);
    } else {
      pass("Startup modal payload is default-off guarded.", managerPath);
    }

    if (!medallionBlock.includes("if !AllowPrismaBlockingSurfaces") || !medallionBlock.includes("\\\"mode\\\":\\\"medallion\\\"")) {
      fail("SendPrismaMedallionPayload must be guarded as a blocking UI surface.", managerPath);
    } else {
      pass("Medallion modal payload is default-off guarded.", managerPath);
    }

    const journalBlock = functionBlock(manager, "SendPrismaJournalPayload");
    const refreshJournalBlock = functionBlock(manager, "RefreshOpenBookOfDays");
    const appendJournalBlock = functionBlock(manager, "AppendBookOfDaysEntry");
    if (!journalBlock) {
      fail("SendPrismaJournalPayload function is missing.", managerPath);
    } else {
      if (!journalBlock.includes("if !AllowPrismaBlockingSurfaces") || !manager.includes("\\\"mode\\\":\\\"journal\\\"")) {
        fail("SendPrismaJournalPayload must be guarded as a blocking UI surface.", managerPath);
      } else {
        pass("Journal modal payload is default-off guarded.", managerPath);
      }

      const journalCalls = countMatches(manager, /SendPrismaJournalPayload\(/g);
      if (journalCalls !== 1) {
        fail(`SendPrismaJournalPayload should have exactly one definition (no additional callers within manager); found ${journalCalls} occurrences.`, managerPath);
      } else {
        pass("Journal modal payload has one definition.", managerPath);
      }

      const journalPayloadBuilderCalls = countMatches(manager, /BuildJournalPayloadJson\(/g);
      if (journalPayloadBuilderCalls !== 2) {
        fail(`BuildJournalPayloadJson must only be defined and called by the player-owned journal open payload; found ${journalPayloadBuilderCalls} occurrences.`, managerPath);
      } else {
        pass("Book of Days payload build is limited to the player-owned journal open path.", managerPath);
      }
    }

    const sendJsonCount = countMatches(manager, /PDV_PrismaBridge\.SendJson\(/g);
    if (sendJsonCount !== 1) {
      fail(`Expected exactly one focused SendJson call in the manager; found ${sendJsonCount}.`, managerPath);
    } else {
      pass("Manager has one focused SendJson call.", managerPath);
    }

    const startupCalls = countMatches(manager, /SendPrismaStartupPayload\(/g);
    const medallionCalls = countMatches(manager, /SendPrismaMedallionPayload\(/g);
    if (startupCalls !== 1) {
      fail(`SendPrismaStartupPayload should have no callers; found ${startupCalls - 1}.`, managerPath);
    } else {
      pass("Startup modal payload has no live callers.", managerPath);
    }
    if (medallionCalls !== 1) {
      fail(`SendPrismaMedallionPayload should have no callers; found ${medallionCalls - 1}.`, managerPath);
    } else {
      pass("Medallion modal payload has no live callers.", managerPath);
    }

    if (
      !refreshJournalBlock.includes("PDV_PrismaBridge.IsJournalVisible()") ||
      !refreshJournalBlock.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)')
    ) {
      fail("Book of Days refresh must reconcile stale Papyrus open state against native journal visibility.", managerPath);
    } else {
      pass("Book of Days refresh reconciles stale Papyrus open state against native visibility.", managerPath);
    }

    if (appendJournalBlock.includes("RefreshOpenBookOfDays(") || appendJournalBlock.includes("SendPrismaJournalPayload(")) {
      fail("Book of Days writes must not open or refresh the journal modal during gameplay.", managerPath);
    } else {
      pass("Book of Days writes only store chronicle data and do not open/refresh the modal.", managerPath);
    }

    if (
      !p2BookNoticeBlock.includes("SendPrismaToast(") ||
      !p2BookNoticeBlock.includes("AppendBookOfDaysEntry(")
    ) {
      fail("Accepted P2 book notices must feed both Prisma toast and Book of Days chronicle.", managerPath);
    } else {
      pass("Accepted P2 book notices feed both Prisma toast and Book of Days chronicle.", managerPath);
    }
  }

  const bridgePath = path.join(DEVOTION_SOURCE, "PDV_PrismaBridge.psc");
  if (!fs.existsSync(bridgePath)) {
    fail("Prisma bridge Papyrus source is missing.", bridgePath);
  } else {
    const bridge = read(bridgePath);
    if (!bridge.includes("Bool Function IsJournalVisible() Global Native")) {
      fail("Prisma bridge Papyrus source must expose IsJournalVisible for Book of Days key-close state.", bridgePath);
    } else {
      pass("Prisma bridge Papyrus source exposes IsJournalVisible.", bridgePath);
    }
  }

  const mcmPath = path.join(DEVOTION_SOURCE, "PDV_MCM.psc");
  if (!fs.existsSync(mcmPath)) {
    fail("MCM source is missing.", mcmPath);
  } else {
    const mcm = read(mcmPath);
    const onKeyDown = eventBlock(mcm, "OnKeyDown");
    const registerJournalHotkeyBlock = functionBlock(mcm, "RegisterJournalHotkey");
    const keyMapChangeBlock = functionBlock(mcm, "OnOptionKeyMapChange");
    const journalKeyIndex = onKeyDown.indexOf('StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey"');
    const panelKeyIndex = onKeyDown.indexOf('StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey"');
    const journalStart = onKeyDown.indexOf("Int journalState = StorageUtil.GetIntValue(None, \"PDV.Diegetic.Journal.Open\")");
    const journalEnd = panelKeyIndex > journalStart ? panelKeyIndex : onKeyDown.length;
    const journalSlice = journalStart >= 0 ? onKeyDown.slice(journalStart, journalEnd) : "";
    const visibleIndex = journalSlice.indexOf("PDV_PrismaBridge.IsJournalVisible()");
    const menuIndex = journalSlice.indexOf("Utility.IsInMenuMode()");
    const closeIndex = journalSlice.indexOf("PDV_Manager.ClosePrismaJournal()");

    if (!onKeyDown) {
      fail("MCM OnKeyDown event is missing.", mcmPath);
    } else if (visibleIndex < 0) {
      fail("Book of Days hotkey must query native bridge journal visibility before deciding close/open state.", mcmPath);
    } else {
      pass("Book of Days hotkey queries bridge journal visibility.", mcmPath);
    }

    if (journalKeyIndex < 0 || panelKeyIndex < 0 || journalKeyIndex > panelKeyIndex) {
      fail("Book of Days hotkey must be handled before the Devotion panel hotkey so shared bindings cannot open both surfaces.", mcmPath);
    } else {
      pass("Book of Days hotkey is handled before the Devotion panel hotkey.", mcmPath);
    }

    if (journalSlice.includes("OpenDevotionPanel(") || journalSlice.includes("PushDevotionPanel(")) {
      fail("Book of Days hotkey path must not open or push the focused Devotion panel.", mcmPath);
    } else {
      pass("Book of Days hotkey path does not open the focused Devotion panel.", mcmPath);
    }

    if (!journalSlice || visibleIndex < 0 || menuIndex < 0 || visibleIndex > menuIndex || closeIndex < 0 || closeIndex > menuIndex) {
      fail("Book of Days close path must run before the menu-mode open guard.", mcmPath);
    } else {
      pass("Book of Days close path is not blocked by the menu-mode open guard.", mcmPath);
    }

    if (!journalSlice.includes("StorageUtil.SetIntValue(None, \"PDV.Diegetic.Journal.Open\", 0)")) {
      fail("Book of Days hotkey must clear stale Papyrus open state when native UI is not visible.", mcmPath);
    } else {
      pass("Book of Days hotkey reconciles stale Papyrus open state.", mcmPath);
    }

    if (
      !registerJournalHotkeyBlock.includes('StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)') ||
      !registerJournalHotkeyBlock.includes("savedPanelKey == savedKey")
    ) {
      fail("Saved Book of Days/panel hotkey conflicts must self-repair on MCM reload/config init.", mcmPath);
    } else {
      pass("Saved Book of Days/panel hotkey conflicts self-repair on reload/config init.", mcmPath);
    }

    if (
      !keyMapChangeBlock.includes('StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)') ||
      !keyMapChangeBlock.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)')
    ) {
      fail("MCM keymap changes must keep Book of Days and Devotion panel hotkeys mutually exclusive.", mcmPath);
    } else {
      pass("MCM keymap changes keep Book of Days and Devotion panel hotkeys mutually exclusive.", mcmPath);
    }
  }
}

if (!fs.existsSync(NATIVE_BRIDGE_SOURCE)) {
  fail("Native Prisma bridge source is missing.", NATIVE_BRIDGE_SOURCE);
} else {
  const nativeBridge = read(NATIVE_BRIDGE_SOURCE);
  const journalPayloadDetection = nativeBridge.match(/const bool isJournalPayload[\s\S]*?;/)?.[0] ?? "";
  const domReadyBlock = nativeBridge.match(/void OnDomReady[\s\S]*?\n    \}/)?.[0] ?? "";
  const overlayPayloadBlock = nativeBridge.match(/bool SendOverlayPayload[\s\S]*?\n    \}/)?.[0] ?? "";
  if (
    !nativeBridge.includes("g_journalVisible") ||
    !nativeBridge.includes("PapyrusIsJournalVisible") ||
    !nativeBridge.includes('RegisterFunction("IsJournalVisible"')
  ) {
    fail("Native Prisma bridge must track and expose Book of Days visible state.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge tracks and exposes Book of Days visible state.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("g_journalVisible = false") || !nativeBridge.includes("g_journalVisible = true")) {
    fail("Native Prisma bridge must update Book of Days visible state on open and close.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge updates Book of Days visible state on open and close.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("class JournalEscapeSink") || !nativeBridge.includes("RegisterInputSink()")) {
    fail("Native Prisma bridge must register a Book of Days ESC input sink.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge registers a Book of Days ESC input sink.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("button->GetIDCode() == 1") || !nativeBridge.includes("RE::BSEventNotifyControl::kStop")) {
    fail("Native Book of Days ESC input sink must consume keyboard ESC before Skyrim opens the pause menu.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Book of Days ESC input sink consumes keyboard ESC.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("g_prisma->Focus(g_view, true, false);")) {
    fail("Book of Days must keep Prisma's cursor-friendly focus mode for the in-view X button.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days keeps Prisma's cursor-friendly focus mode.", NATIVE_BRIDGE_SOURCE);
  }

  if (nativeBridge.includes("g_prisma->Focus(g_view, true, true);")) {
    fail("Book of Days must not disable Prisma's focus menu; that breaks cursor/X close behavior.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days does not use the cursor-breaking focus mode.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !nativeBridge.includes("void CloseJournalSurface(") ||
    !nativeBridge.includes('CloseJournalSurface("js_panel_close")') ||
    !nativeBridge.includes('CloseJournalSurface("keyboard_escape", true)') ||
    !nativeBridge.includes('CloseJournalSurface("papyrus_journal_close")')
  ) {
    fail("Book of Days close routes must converge on CloseJournalSurface.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days close routes converge on CloseJournalSurface.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !journalPayloadDetection ||
    !journalPayloadDetection.includes('a_payload.find("\\"mode\\":\\"journal\\"")') ||
    !journalPayloadDetection.includes('a_payload.find("\\"journal\\":")') ||
    !journalPayloadDetection.includes("&&") ||
    journalPayloadDetection.includes("||") ||
    nativeBridge.includes('a_payload.find("\\"journal\\"")')
  ) {
    fail("Native bridge must require explicit journal mode plus a journal object, not any payload containing a journal key or symbol value.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native bridge only marks explicit journal-mode payloads with journal objects as Book of Days visible.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !domReadyBlock ||
    !domReadyBlock.includes("if (g_panelFocusPending && !g_lastPayload.empty())") ||
    domReadyBlock.includes("if (!g_lastPayload.empty())")
  ) {
    fail("Native DOM-ready replay of focused panel payloads must only run for an actual pending panel open.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native DOM-ready replay of focused panel payloads is gated to pending panel opens.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !overlayPayloadBlock ||
    !overlayPayloadBlock.includes("if (!g_domReady)") ||
    !overlayPayloadBlock.includes("QueueOverlayPayload(a_payload)") ||
    !overlayPayloadBlock.includes("return true") ||
    overlayPayloadBlock.indexOf("if (!g_domReady)") > overlayPayloadBlock.indexOf("g_prisma->Show(g_view)")
  ) {
    fail("Native overlay sends must defer until DOM ready before showing the shared Prisma view.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native overlay sends defer until DOM ready before showing the shared Prisma view.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !nativeBridge.includes("std::deque<std::string> g_pendingOverlayPayloads") ||
    !nativeBridge.includes("kMaxPendingOverlayPayloads") ||
    !nativeBridge.includes("QueueOverlayPayload") ||
    nativeBridge.includes("std::string g_pendingOverlayPayload;")
  ) {
    fail("Native cold-DOM overlay deferral must use a capped FIFO queue, not a single overwritten payload slot.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native cold-DOM overlay deferral uses a capped FIFO queue.", NATIVE_BRIDGE_SOURCE);
  }
}

if (!fs.existsSync(DEVOTION_PRISMA_VIEW)) {
  fail("Live Prisma UI app.js is missing.", DEVOTION_PRISMA_VIEW);
} else {
  const app = read(DEVOTION_PRISMA_VIEW);
  if (!app.includes("const symbolDisplayNames = Object.fromEntries(gallerySymbols);")) {
    fail("Prisma UI is missing the symbol display-name map.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI has a symbol display-name map.", DEVOTION_PRISMA_VIEW);
  }

  if (!app.includes('deityName = (payload = {}) => displayName(payload.deity, displayName(state.patron, "Devotion"))')) {
    fail("Prisma toast deity labels are not normalized through displayName.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma toast deity labels use display names.", DEVOTION_PRISMA_VIEW);
  }

  if (!app.includes('["azura", "Azurah"]')) {
    fail("Prisma UI is missing the Azurah display-name mapping for the normalized azura symbol key.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI maps normalized azura symbols to Azurah display text.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const overlayController = (() =>") ||
    !app.includes("const isEscapeKey = (event)") ||
    !app.includes("const onOverlayEsc = (event)") ||
    !app.includes("const closeStartupFromView = () =>") ||
    !app.includes("const closeJournalFromView = () =>")
  ) {
    fail("Prisma overlays must use the shared overlay controller and robust ESC close handler.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma overlays use the shared overlay controller and robust ESC close handler.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('window.addEventListener("keydown", onOverlayEsc, true)') ||
    !app.includes('document.addEventListener("keydown", onOverlayEsc, true)') ||
    !app.includes('window.addEventListener("keyup", onOverlayEsc, true)') ||
    !app.includes('document.addEventListener("keyup", onOverlayEsc, true)')
  ) {
    fail("Overlay ESC handler must bind at window/document capture on keydown and keyup.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Overlay ESC handler binds at window/document capture on keydown and keyup.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('overlayController.open("journal")') ||
    !app.includes('overlayController.open("startup")') ||
    !app.includes("overlayController.closeAll();\n        document.body.classList.add(\"panel-visible\")")
  ) {
    fail("Focused panel and modal opens must pass through the overlay controller.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Focused panel and modal opens pass through the overlay controller.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const isJournalPayload = (payload)") ||
    !app.includes('payload.mode === "journal"') ||
    !app.includes('typeof payload.journal === "object"') ||
    !app.includes("!Array.isArray(payload.journal)") ||
    countMatches(app, /if \(isJournalPayload\(payload\)\)/g) < 2
  ) {
    fail("Prisma UI must render Book of Days only for explicit journal-mode payloads with journal objects.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI renders Book of Days only for explicit journal-mode payloads with journal objects.", DEVOTION_PRISMA_VIEW);
  }

  const overlayHandlerStart = app.indexOf("const handleOverlayPayload = (payload) => {");
  const overlayHandlerEnd = overlayHandlerStart >= 0 ? app.indexOf("};", overlayHandlerStart) : -1;
  const overlayHandler = overlayHandlerStart >= 0 && overlayHandlerEnd > overlayHandlerStart
    ? app.slice(overlayHandlerStart, overlayHandlerEnd)
    : "";
  const clearPanelIndex = overlayHandler.indexOf('document.body.classList.remove("panel-visible")');
  const unbindPanelEscIndex = overlayHandler.indexOf('document.removeEventListener("keydown", onPanelEsc, true)');
  const journalCloseIndex = overlayHandler.indexOf("if (payload.journalClose)");
  if (
    !overlayHandler ||
    clearPanelIndex < 0 ||
    unbindPanelEscIndex < 0 ||
    journalCloseIndex < 0 ||
    clearPanelIndex > journalCloseIndex ||
    unbindPanelEscIndex > journalCloseIndex
  ) {
    fail("Overlay payloads must clear stale focused-panel DOM state before rendering toasts or journal surfaces.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Overlay payloads clear stale focused-panel DOM state before rendering.", DEVOTION_PRISMA_VIEW);
  }

  if (app.includes("if (!bridgeReceived) enableDemo()")) {
    fail("Prisma UI must not auto-render the dashboard demo when in-game overlay payloads race DOM readiness.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI demo dashboard is explicit-only and cannot auto-open in game.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const normalizeJournalSurveyText = (value) =>") ||
    !app.includes('["nord", "Nord"]') ||
    !app.includes("normalizeJournalSurveyText(journal.survey)")
  ) {
    fail("Book of Days survey/path line must normalize public race labels before rendering.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Book of Days survey/path line normalizes public race labels before rendering.", DEVOTION_PRISMA_VIEW);
  }
}

for (const item of passes) {
  console.log(`[PASS] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
}
for (const item of failures) {
  console.error(`[FAIL] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
}

if (failures.length > 0) {
  process.exit(1);
}

console.log(`Prisma UI audit passed: ${passes.length} checks.`);
