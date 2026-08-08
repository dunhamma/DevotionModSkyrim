// Record-enum -> runtime/contract actor-value names.
//
// Skyrim's ESP record enum and the name the runtime and our contracts use differ for a
// handful of actor values. Comparing them raw reports drift that is not drift: the ESP
// stores `Speech` while a contract says `Speechcraft`, and a naive comparison flags a
// correct record as wrong. The 2026-08-08 Daedric pass had to steer around exactly that --
// nine correct records would have been reported as drifted.
//
// This is the SINGLE definition. It replaced three byte-identical copies in
// pdv_phase2_reward_readback_audit.mjs, pdv_dislike_consequence_audit.mjs and
// pdv_verify.mjs (GitHub issue #36).
//
// NOT consolidated here, deliberately -- these look similar but are a different concern,
// and folding them in would change what they mean:
//   - tools/pdv_cumulative_rebalance.mjs  EFFECT_NAMES  -> magic-effect DISPLAY names
//     ("Light Armor", "Critical Chance"). It happens to collapse Speechcraft and Speech to
//     the same string, but it is a display map, not an alias table.
//   - tools/pdv_prisma_ui_audit.mjs       labels        -> player-facing UI strings
//     ("One-handed", "Armor rating", "Magic resistance").
// Adding a pair here does not affect either of those, and vice versa.

export const ACTOR_VALUE_ALIASES = new Map([
  ["Speechcraft", "Speech"],
  ["BlockSkill", "Block"],
  ["Marksman", "Archery"],
  ["ResistPoison", "PoisonResist"],
]);

// Contract/runtime name -> the name the RECORD carries. Unknown values pass through
// unchanged, which is correct: most actor values are spelled the same on both sides.
export function recordActorValueFor(contractActorValue) {
  return ACTOR_VALUE_ALIASES.get(contractActorValue) ?? contractActorValue;
}

// Kept as a separate name because two of the call sites read as "normalize this value I
// just parsed" rather than "give me the record spelling". Same mapping either way.
export const normalizeActorValue = recordActorValueFor;
