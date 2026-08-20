import assert from "node:assert/strict";
import test from "node:test";

import {
  classifyPenaltyPair,
  parseRecordBlocks,
} from "./lib/pdv_penalty_serialization.mjs";

test("accepts both engine-valid penalty encodings", () => {
  assert.equal(classifyPenaltyPair({ magnitude: -3, flags: ["Recover"] }).status, "PASS");
  assert.equal(classifyPenaltyPair({ magnitude: 8, flags: ["Recover", "Detrimental"] }).status, "PASS");
});

test("rejects both sign and Detrimental combinations that produce a buff", () => {
  assert.equal(classifyPenaltyPair({ magnitude: -3, flags: ["Recover", "Detrimental"] }).code, "DOUBLE_NEGATIVE");
  assert.equal(classifyPenaltyPair({ magnitude: 8, flags: ["Recover"] }).code, "POSITIVE_BUFF");
});

test("rejects a reversible-looking penalty that lacks Recover", () => {
  const result = classifyPenaltyPair({ magnitude: -3, flags: [] });
  assert.equal(result.status, "FAIL");
  assert.equal(result.code, "MISSING_RECOVER");
});

test("rejects zero or non-numeric magnitudes", () => {
  assert.equal(classifyPenaltyPair({ magnitude: 0, flags: ["Recover"] }).code, "ZERO_MAGNITUDE");
  assert.equal(classifyPenaltyPair({ magnitude: "missing", flags: ["Recover"] }).code, "INVALID_MAGNITUDE");
});

test("parses adjacent houseCARL record blocks without dropping the first block", () => {
  const source = [
    "type=Spell  formid=000001:Devotion.esp  editorid=PDV_SPEL_Neglect_Test  winner=Devotion.esp  override_depth=1",
    "fields (from Devotion.esp):",
    "  EditorID = PDV_SPEL_Neglect_Test",
    "  Effects[0].BaseEffect = 000002:Devotion.esp",
    "  Effects[0].Data.Magnitude = -3",
    "",
    "type=MagicEffect  formid=000002:Devotion.esp  editorid=PDV_MGEF_Neglect_Test  winner=Devotion.esp  override_depth=1",
    "fields (from Devotion.esp):",
    "  EditorID = PDV_MGEF_Neglect_Test",
    "  Flags = Recover, NoDuration",
  ].join("\n");

  const blocks = parseRecordBlocks(source);
  assert.equal(blocks.length, 2);
  assert.equal(blocks[0].type, "Spell");
  assert.equal(blocks[0].formId, "000001:Devotion.esp");
  assert.equal(blocks[0].fields.get("Effects[0].Data.Magnitude"), "-3");
  assert.equal(blocks[1].type, "MagicEffect");
  assert.equal(blocks[1].fields.get("Flags"), "Recover, NoDuration");
});
