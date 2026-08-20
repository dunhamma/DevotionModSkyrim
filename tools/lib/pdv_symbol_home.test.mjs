import assert from "node:assert/strict";
import test from "node:test";

import { stripQualifiers, substantialFunctionBlock } from "./pdv_symbol_home.mjs";

test("stripQualifiers removes stacked manager and module forward references", () => {
  assert.equal(
    stripQualifiers("Manager.Prisma.SendPrismaToast()\nPDV_Manager.LedgerRuntime.AwardPiety()"),
    "SendPrismaToast()\nAwardPiety()",
  );
});

test("substantialFunctionBlock selects a race-adapter body over an empty base virtual", () => {
  const family = [
    "Function HandleRoad(String reason)\n    ; base stub\nEndFunction",
    "Function HandleRoad(String reason)\n    if reason != \"\"\n        SendNotice(reason)\n    endIf\nEndFunction",
  ].join("\n");
  const block = substantialFunctionBlock(family, "HandleRoad");
  assert.match(block, /SendNotice\(reason\)/);
});

test("substantialFunctionBlock returns empty text for an absent symbol", () => {
  assert.equal(substantialFunctionBlock("Function Present()\nEndFunction", "Missing"), "");
});
