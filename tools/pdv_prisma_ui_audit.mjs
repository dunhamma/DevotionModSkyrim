#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const DEVOTION_SOURCE = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts\\Source";
const DEVOTION_PRISMA_VIEW = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\PrismaUI\\views\\Devotion\\app.js";

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

    if (name !== "PDV_PrismaBridge.psc") {
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
