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

function countMatches(source, pattern) {
  const matches = source.match(pattern);
  return matches ? matches.length : 0;
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
  }

  const managerPath = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
  if (!fs.existsSync(managerPath)) {
    fail("Manager source is missing.", managerPath);
  } else {
    const manager = read(managerPath);
    const pushBlock = functionBlock(manager, "PushDevotionPanel");
    const startupBlock = functionBlock(manager, "SendPrismaStartupPayload");
    const medallionBlock = functionBlock(manager, "SendPrismaMedallionPayload");

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

    if (!pushBlock.includes("if !AutoPushPrismaPanel") || !pushBlock.includes("PDV_PrismaBridge.SendJson(")) {
      fail("PushDevotionPanel must guard SendJson behind AutoPushPrismaPanel.", managerPath);
    } else {
      pass("PushDevotionPanel guards focused SendJson.", managerPath);
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
    const journalStart = onKeyDown.indexOf("Int journalState = StorageUtil.GetIntValue(None, \"PDV.Diegetic.Journal.Open\")");
    const journalSlice = journalStart >= 0 ? onKeyDown.slice(journalStart) : "";
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
  }
}

if (!fs.existsSync(NATIVE_BRIDGE_SOURCE)) {
  fail("Native Prisma bridge source is missing.", NATIVE_BRIDGE_SOURCE);
} else {
  const nativeBridge = read(NATIVE_BRIDGE_SOURCE);
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
