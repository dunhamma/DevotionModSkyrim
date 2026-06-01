# PDV Recognition Dialogue Scale Packet

Last revised: 2026-06-01 AEST
Status: Planned V2 enhancement packet. V1 must not add new NPC conversation
lines, voiced responses, lip files, scene content, or broad recognition topics.
Use this packet to preserve the CK-safe proof shape for a future V2
recognition/dialogue pass.

## Purpose

This packet defines the CK-safe pattern for scaling PDV recognition and dialogue surfaces beyond the proven Nord pilots when V2 dialogue scope opens. It exists because recognition is a high-value immersion surface, but PDV has already proven that generated dialogue shape can pass static readback and still be unsafe at runtime.

The current evidence is:

- Phase 11 Arngeir/Kynareth recognition was originally generated, then removed after CrashLogger tied a CTD to the generated topic/branch shape. The live replacement was rebuilt through manual CK authoring, SEQ refresh, strict readback, and runtime positive/negative proof.
- Phase 18 Nord recognition now has CK-authored Froki, Heimskr, Andurs, and Aela surfaces with branch/topic/unnamed INFO readback by speaker, prompt, response, owning topic, and condition stack.
- Architecture v3 treats `dialogue-v1` as manifest/readback proof for CK-authored dialogue scaffolding, not generated dialogue creation support.

The goal is not to make dialogue automatic. The goal is to keep each future
manual CK recognition line cheap to specify, cheap to verify, and hard to
accidentally over-scale after V1 ships.

The Phase 20 no-in-game gate may still mirror the first packet as V2 prep only:
Altmer Auri-El crisis recovery, planned Runil identity, explicit positive and
negative gates, and Survey/status fallback. That keeps recognition available for
future planning without turning it into V1 content, generated dialogue, or a
runtime claim.

## Non-Goals

- No generated dialogue creation.
- No generic branch/topic/INFO writer.
- No bypassing Creation Kit for dialogue graph creation.
- No promotion of `dialogue-v1` into product authoring support until CK-owned graph mutation, active-plugin save, MO2 readback, verifier proof, command evidence, and runtime proof all exist for that exact operation.
- No new V1 NPC conversation lines, voiced responses, lip files, scene content,
  or broad recognition topics.
- No new voice, lip, scene, quest-stage, or package authoring scope in this packet.
- No broad NPC commentary system. Recognition stays curated and state-gated.

## Operating Boundary

Dialogue authoring is CK-first, readback-second, and V2-only unless a later
scope decision explicitly reopens no-voice recognition content.

1. Plan the recognition packet in a manifest or runbook.
2. Author the branch/topic/INFO manually in Creation Kit against `PlayerDevotion_Framework.esp` or the explicitly assigned plugin.
3. Save in CK.
4. Refresh SEQ.
5. Close CK or otherwise restore MO2/MCP availability before readback if the live tooling becomes unavailable while CK is open.
6. Run strict verifier/readback.
7. Run runtime positive and negative dialogue proof.

Do not run MO2 readback or verifier work as if it proves CK authoring while CK-side changes are still unsaved. Do not treat a passing manifest scaffold as a live dialogue record.

## Pulled-Forward Tool Lane

Use the vendored creation-authoring dialogue helpers before broad recognition
work:

```powershell
node .\tools\creation-authoring\src\cli.mjs dialogue-scaffold .\fixtures\dialogue-v1\dialogue-v1.rows.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --output-file .\scratch\dialogue-v1.scaffold.json

node .\tools\creation-authoring\src\cli.mjs dialogue-bind .\fixtures\dialogue-v1\dialogue-v1.creation-authoring.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --readback .\fixtures\dialogue-v1\dialogue-v1.readback.json `
  --output-file .\scratch\dialogue-v1.bind-report.json
```

For production PDV packets, replace the fixture rows/profile/readback with the
current recognition packet paths. The scaffold step reduces manual manifest
authoring; the bind step reduces manual readback comparison. Neither step
creates dialogue in CK or allows promotion without command evidence and runtime
proof.

## Recognition Packet Template

Every recognition surface must be specified with these fields before CK authoring starts.

| Field | Requirement |
| --- | --- |
| `id` | Stable kebab-case packet id, for example `altmer-ondolemar-auriel-crisis`. |
| `owningRace` | One of the ten player-origin races, or `all` only for a deliberately universal surface. |
| `owningDeityOrPath` | Deity, broad path, Daedric path, curse posture, or race substrate being recognized. |
| `speaker` | NPC display name and form identity if known. |
| `locationOrFactionContext` | Why this speaker is appropriate: location, faction, quest role, temple, hold, guild, tribe, caravan, or shrine context. |
| `positiveGate` | Exact state that makes the line appear. Use CK-readable globals/properties where possible. |
| `negativeGates` | At least two explicit blockers. Include wrong origin and one wrong deity/state/tier/curse/faction case where relevant. |
| `prompt` | Player prompt text, final or draft. |
| `response` | NPC response text, final or draft. |
| `branchIdentity` | Expected branch EditorID. |
| `topicIdentity` | Expected topic EditorID. |
| `infoIdentity` | Expected INFO hint. CK may save INFO unnamed; verification must allow identity by topic, speaker, prompt, response, and conditions. |
| `seqRequirement` | Whether SEQ refresh is required. For new dialogue, default is required. |
| `verifierCommand` | Exact command expected to read back this packet. If no strict verifier exists yet, the packet is not ready for mass scaling. |
| `runtimePositiveProof` | In-game setup and expected visible line. |
| `runtimeNegativeProof` | In-game setup proving the line is absent for each required blocker. |
| `fallbackIfTooExpensive` | Non-dialogue fallback surface if CK dialogue is too expensive: Survey/status text, MCM Player line, message, proof activator, perk/service gate, or no 1.0 surface. |

Minimal draft shape:

```json
{
  "id": "race-speaker-surface",
  "owningRace": "Altmer",
  "owningDeityOrPath": "Auri-El",
  "speaker": "TBD",
  "locationOrFactionContext": "TBD",
  "positiveGate": ["origin Altmer", "active Auri-El", "tier >= Champion"],
  "negativeGates": ["non-Altmer origin", "active deity not Auri-El", "tier below Champion"],
  "prompt": "TBD",
  "response": "TBD",
  "branchIdentity": "PDV_DIAL_Altmer_TBD_AurielRecognitionBranch",
  "topicIdentity": "PDV_TIF_Altmer_TBD_AurielRecognition",
  "infoIdentity": "PDV_INFO_Altmer_TBD_AurielRecognition",
  "seqRequirement": "required-after-ck-save",
  "verifierCommand": "TBD strict verifier command",
  "runtimePositiveProof": "TBD",
  "runtimeNegativeProof": ["TBD wrong-origin", "TBD wrong-deity", "TBD wrong-tier"],
  "fallbackIfTooExpensive": "Survey/status readout only"
}
```

## Scalable Tiers

### Pre-Beta

Required:

- One proven non-Nord recognition packet before adding many lines.
- Recognition only where it proves a race's scaling spine or a major edge case.
- Positive proof plus wrong-origin and wrong-state negative proof.
- Survey/status fallback for every race whose dialogue is deferred.
- SEQ refresh and strict readback after every CK dialogue save.

Optional:

- One additional line for the active spine race if it proves contrast that Survey/status cannot carry.
- One dialogue line for a P2 audit race only if it exposes ceiling/over-trigger risk.

Not allowed:

- Roster-wide recognition cloning.
- Dialogue as compensation for missing normal-play hooks.
- Dialogue packets without explicit fallback.

### Content-Feel Beta

Required:

- At least one recognition or explicit non-dialogue fallback surface for each race's primary felt identity.
- Each active race packet must include one expected build and one edge build.
- Runtime proof must cover positive and negative availability for every newly added line.
- A central recognition ledger or manifest must track all live packets.

Optional:

- Second-line depth for races where social recognition is part of the core fantasy: Imperial civic religion, Breton vows/Hidden Art, Khajiit caravan/road, Argonian People, Orc stronghold/city dignity.
- Deity-specific recognition for the most visible focused patron lanes.

Not allowed:

- Broad town-bark systems.
- Unverified generated dialogue.
- Lines that expose exact piety math to the player.

### V1

Required:

- Each race has non-voiced recognition for its main identity where needed:
  Survey/status, MCM Player text, MessageBox, notification, spell/effect
  description, book/note, safe service or shrine gate, or Prisma toast.
- No new NPC conversation lines, voiced responses, lip files, scene content, or
  broad recognition topics are added for V1.
- The existing Nord and Arngeir dialogue surfaces remain technical proof and
  prototype evidence, not a content-volume requirement for V1.
- Daedric and curse recognition surfaces show price/stigma/rupture where
  relevant instead of normalizing the path.

Optional:

- V2 packet drafts for iconic NPC recognition, including Runil for Altmer
  mortality/scar/recovery, as long as they remain prep-only.
- Recovery/scar recognition through non-voiced surfaces when the state is
  already Survey/status-visible.

Not allowed:

- Any new V1 dialogue path, even if it can be reproduced and read back.
- Any dialogue path whose creation or condition stack cannot be reproduced and
  read back when V2 work starts.

## Acceptance Gate Before Adding Many Lines

Before scaling recognition content beyond the current Nord set in V2, complete
one non-Nord packet through the full chain:

1. Packet fields complete.
2. CK-readable gate confirmed. If a condition needs a helper global, add and verify that helper before dialogue authoring.
3. Manual CK branch/topic/INFO authored.
4. SEQ refreshed.
5. Saved ESP readback resolves branch, topic, INFO identity, speaker, prompt, response, and conditions.
6. Strict verifier command exists and passes.
7. Runtime positive case shows the line.
8. Runtime negatives hide the line for wrong origin and wrong state.
9. Save/load sanity does not create duplicate or stale dialogue availability.
10. Fallback is documented in case the line is cut.

Mass scaling starts only after this gate passes once outside Nord and only after
V2 dialogue scope is explicitly opened. Until then, new recognition requests are
packet drafts, not implementation-ready content.

## Recommended First Non-Nord Candidates

Use a candidate that is small, high-signal, and easy to prove with existing state. Avoid a first packet that needs new quest-stage parsing, broad faction surgery, or multiple helper globals.

| Candidate | Why it is useful | Risk | First-pass posture |
| --- | --- | --- | --- |
| Altmer Auri-El crisis recovery recognition | Matches the active scaling spine and tests whether Altmer can feel recognized without adding broad reward volume. | Speaker choice may require careful vanilla-lore fit. | Best first candidate if a CK-readable Altmer crisis/scar or Auri-El tier gate already exists. |
| Khajiit road/moon recognition | Proves a contrast race whose feel should be quiet, cadence-based, and not chore-like. | Vanilla Khajiit NPC availability is limited and caravan context may need location/faction care. | Good second candidate after Altmer, or first if the chosen speaker has clean conditions. |
| Argonian People/Hist recognition | Tests non-Sithis Argonian identity before Void depth. | Sparse vanilla Argonian social surfaces and possible need for helper globals. | Use only if the People/Hist gate is already CK-readable. |
| Orc city/stronghold dignity recognition | Strong fit for social recognition that is not just combat or smithing. | Stronghold access and faction context can complicate conditions. | Good Content-Feel Beta candidate, not necessarily the first architecture proof. |
| Imperial civic/Talos pressure recognition | High value for public/private religion feel. | Can become a faction-politics tracker if too broad. | Use after the first non-Nord packet proves the repeatable path. |

Recommended first V2 proof: Altmer Auri-El crisis recovery recognition, if the positive gate can be expressed through existing origin, active deity/tier, and crisis/scar readback globals. If that requires new helper state, stop and add the helper/readback contract before CK dialogue work.

Ratified first V2 speaker candidate: Runil in Falkreath. He is the preferred first
Altmer recognition candidate because his Altmer mortality/death context fits
crisis recovery without turning the first packet into Thalmor politics. The
first packet should test Altmer origin plus Auri-El/crisis-or-scar readback if
that gate is CK-readable. If it needs new helper state or fragile conditions,
defer dialogue and use the V1 Survey/status fallback only until the V2 CK
dialogue proof is worth the time.

Lore cross-review guardrail: Runil should speak to mortality, death duty, scar,
and recovery from an Altmer who has lived with Dominion/war context. Do not use
him as a generic Thalmor mouthpiece or as an Orthodox Auri-El proclamation
speaker. If the line cannot stay in that mortality/recovery lane, use the
Survey/status fallback instead.

## Fallback Surfaces

For V1, use the cheapest non-voiced surface that still tells the player what
changed and why. For V2, use this same fallback whenever dialogue is too
expensive for a race/deity/path:

- `Survey Devotion` wording.
- MCM Player page row.
- One-shot message after a major transition.
- Service/privilege gate without a new dialogue line.
- A placed proof/ritual activator for internal validation only.
- No recognition surface for V1 if the race already has enough player-facing
  clarity elsewhere.

Fallback is not failure. Unverified dialogue is failure.

## Closeout Rule

A recognition packet is closed only when it has three proofs in the same direction:

- Static intent: packet/manifest says what should exist.
- Saved-record proof: verifier/readback confirms what CK saved.
- Runtime proof: the right player sees the line and the wrong player does not.

If any one of those is missing, the packet remains draft or readback-only and cannot be used as evidence that recognition/dialogue scaling is ready.
