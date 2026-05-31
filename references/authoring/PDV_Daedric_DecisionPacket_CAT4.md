# PDV Daedric Decision Packet (CAT-4 unblock)

**Created:** 2026-05-31
**Status:** RATIFIED 2026-05-31. D-15..D-18 are locked in
`PDV_Architecture_v3.md` Section 11.6; this packet is the rationale of record.
Resolves the open Daedric content decisions so CAT-4 (the 15 non-pilot Princes)
can begin without re-authoring risk.
**Owner docs it serves:** `PDV_Architecture_v3.md` Section 11 (architecture),
Section 25.9 CAT-4 (content track); `race-sheets/PDV_DaedricContent_Manifest.md`
Sections 5 and 7 (provisional stigma model, stub roster);
`references/phase4/PDV_DaedricRacePrinceMatrix.csv` (per-race response source).
**Why this exists:** The Phase 20 long pole is 20C (all 16 Skyrim-present
Princes). Boethiah is the only fully authored Prince; 15 are stubs. The audit
flagged that the remaining Daedric decisions "shape the content," so resolving
them up front is the highest-leverage de-risk for the largest content block.

> Ratified 2026-05-31. D-15..D-18 now live in `PDV_Architecture_v3.md` Section
> 11.6, and the manifest Section 5 language is flipped from "provisional" to
> "locked". This packet remains the rationale of record and the alternatives
> considered.

---

## Status of the prior open list

The earlier CAT-4 note named three open items: stigma decay model, roster
shape, and cross-Prince hostility. Two are already closed in Section 11.6:

- **Roster shape:** closed by **D-12** (separate `PDV_FLST_AllDaedricPaths`)
  and the manifest Section 7 roster (16 Skyrim-present Princes, Jyggalag
  excluded).
- **Cross-Prince hostility:** closed by **D-14** (reduced rivalry math, not
  full Aedric-strength cancellation).
- **Recovery:** closed by **D-13** (mixed recovery default).

What remains genuinely open, and what this packet resolves:

| ID | Decision | Blocks |
|---|---|---|
| D-15 | Stigma data model, band thresholds, weight classes, decay rate, residue | Every per-Prince stigma row and the social-reaction read |
| D-16 | Curse-access template variation (Hircine, Molag Bal) | The two curse-access Princes |
| D-17 | Authoring order and template-variation batching | The whole 15-Prince burndown sequence |
| D-18 | Per-Prince "content-ready" definition for the 20C gate | The 20C exit gate and verifier expectations |

---

## D-15: Stigma model (proposed lock)

**Decision:** Adopt the proven `WitchcraftExposure` four-band numeric shape for
Daedric stigma, stored **per Prince**, with a derived shared social-reaction
read. Replace the manifest's provisional three-band model with this.

### D-15.1 Storage and bands

- Stigma accrues **per path**: `PDV.Daedric.<Prince>.Stigma` (StorageUtil),
  mirrored to the existing `StigmaGlobal` property on `PDV_DaedricPathBase`
  (Section 11.1). Per-path storage keeps exit and decay clean: renouncing one
  Prince lowers that Prince's line without touching another active pact.
- Bands reuse the `WitchcraftExposure` thresholds (v3 Section 6 table) so the
  player learns one visibility grammar across the mod:

  | Band | Range | Meaning |
  |---|---|---|
  | `Latent` | `0..25` | Unmarked. No notification (matches the manifest's "an unmarked path needs no notification"). |
  | `Suspected` | `26..50` | Some NPCs wary. |
  | `Known` | `51..75` | Doors and trust begin to close; dialogue gates open. |
  | `Notorious` | `76..100` | Open hostility from the wary. |

  This keeps the manifest's three *crossing notifications* (Suspected, Known,
  Notorious) exactly as authored - the `Latent` floor simply has no
  notification, which is what the manifest already assumes. **No Boethiah
  stigma prose needs to change.**

- Social reaction keys off a derived read, not a sum:
  `PDV_GLO_DaedricExposure = max(active path stigma)`. NPC wariness and the
  broad "consorts with Daedra" reactions use this max; Prince-specific dialogue
  gates use that Prince's own band. This honours D-14 (no full additive
  stacking across Princes) while letting one severe pact still read as severe.

### D-15.2 Stigma weight class (per Prince)

Base accrual per devotional act is scaled by a per-Prince class, then by the
matrix `StigmaModByRace`. Three classes, drawn from the matrix response cells:

| Class | Princes | Base per-act | Notes |
|---|---|---|---|
| `Tolerated` | Meridia, Peryite | low (about 0.5x) | Anti-undead / order-and-task utility reads as outsider devotion, not cult. May never reach `Notorious` for tolerant races; author Suspected/Known crossings, treat Notorious as rare-edge only. |
| `Standard` | Azura, Boethiah, Mephala, Malacath, Nocturnal, Hermaeus Mora, Sheogorath, Namira, Sanguine, Clavicus Vile, Vaermina | 1.0x | Full three-crossing authoring as Boethiah. |
| `High-rupture` | Mehrunes Dagon, Molag Bal | high (about 1.5x) | Reaches `Notorious` fastest; Oblivion-Crisis and vampiric-violation memory make these the loudest social ruptures. |

Native-integration override (Section 11.4) still wins: a Prince that is native
for a race accrues **zero** stigma for that race (Dunmer Reclamations, Khajiit
Boethra/Mafala, Orc Malacath). Those treatments live in the race manifest, not
here.

### D-15.3 Decay and residue

- **Decay:** slow linear abstention decay of **1 stigma/day**, reusing the
  Phase 17 decay guards (once-per-day, no same-day double-tick). At 1/day a
  full `Notorious` (100) clears to `Latent` over roughly the same horizon a
  player would feel as "a long, deliberate stretch of clean living," which
  matches the exit prose "the stigma fades only on its own slow time."
- **Residue:** stigma decays fully to zero (consistent with the Boethiah exit
  prose). The permanent part is **not** stigma points but a one-way dialogue
  flag set when a path first reaches Champion:
  `PDV.Daedric.<Prince>.WasChampion = true`. This satisfies "the memory of what
  you reached for does not fully leave you, or the people who saw it" without
  keeping a live mechanical penalty forever. Rites or authored restoration
  beats (D-13) may accelerate stigma decay but do not clear the `WasChampion`
  flag.

**Alternative considered:** a single shared `DaedricExposure` counter for all
Princes. Rejected because it makes per-path exit incoherent (renouncing one
Prince would not visibly reduce exposure while another is active) and conflicts
with D-14's per-Prince reduced-rivalry stance.

---

## D-16: Curse-access template variation (proposed lock)

**Decision:** Hircine and Molag Bal are authored as **curse-access** Princes
whose commitment and stigma are driven by the curse-state overlay (Phase 15),
not by chosen-pact commitment counting or per-act stigma. They author a
*reduced* row set.

### D-16.1 What changes versus the standard template

| Standard row | Curse-access treatment |
|---|---|
| `_Commitment` (3-signal pact) | Replaced by a **curse-onset** message fired by the curse-state module on lycanthropy/vampirism acquisition. No `CommitmentSignalsRequired` counting. |
| Stigma crossings (per-act) | **Driven by curse-state visibility**, not devotional acts. Being a known werewolf/vampire is the stigma source; the path reads its band from the curse overlay rather than a per-act counter. Do not author independent per-act stigma rows. |
| Exit (renounce) | **Cure path** (D-13 mixed recovery): cure starts recovery, rites/authored beats complete it. The renounce verb does not apply; the exit slot is a cure/residue message. |
| Boon / price / tier-up / per-race response | **Authored normally**, exactly as the standard template (Phase 13 already proved Hircine boon/price/tier on Nord). |

### D-16.2 Coordination rule (no double-fire)

Curse-access Princes **coordinate with**, and do not duplicate, the race
manifest's per-race `CurseState` rows. The curse-onset and cure messages are
owned by the curse-state module (Phase 15); the Daedric manifest authors the
Prince-voiced boon/price/tier/response content that layers on top. Any message
that would restate a `CurseState` transition is dropped in favour of the race
manifest row. Verifier check: no slot collision between
`PDV_Msg_Daedric_<Prince>_*` and the race `*_CurseState_*` rows.

### D-16.3 Hircine head start

Hircine already has runtime-proven Phase 13/15 mechanics (boon/price/stigma,
curse-entry, cure/renounce, residue). CAT-4 for Hircine is therefore a
**content-surface authoring pass only** - tone profile, boon/price/tier-up
prose, per-race response from the matrix `Hircine` row, and the curse-onset
reframe - not new mechanics. Molag Bal is the genuinely new curse-access build
and should be authored second, against the Hircine pattern.

**Alternative considered:** treat curse-access Princes as standard pacts with a
zero-signal gate. Rejected because it would double-author and risk
double-firing the curse-state transitions the race manifest already owns.

---

## D-17: Authoring order and template-variation batching (proposed lock)

**Decision:** Author one of each template variation first (the
"template-variation proof" batch), prove the four shapes, then mass-author the
remainder. This de-risks all four templates before volume, the same discipline
that made the code roadmap cheap.

### Batch 0 - Template-variation proof (do first, in this order)

| Prince | Proves | Template shape |
|---|---|---|
| Azura | Native-integration routing at scale (Dunmer + Khajiit route to race manifest; 8 non-native responses authored) | Standard + native override |
| Vaermina | A clean standard external pact with no native override | Standard, pure |
| Meridia | The `Tolerated` weight class and the "Notorious is rare-edge" rule | Tolerated |
| Molag Bal | The curse-access reduced row set (D-16) end to end | Curse-access |

Exit gate for Batch 0: `pdv_content_verify` clean for all four, matrix fidelity
confirmed against the CSV, and one human read-through that the four template
shapes each feel right. Only then proceed.

### Batch 1 - Native-integration variants

Mephala, Malacath. (Azura is in Batch 0.) Reuse the Azura native-override
pattern.

### Batch 2 - Standard external pacts

Mehrunes Dagon, Sheogorath, Namira, Sanguine, Clavicus Vile, Hermaeus Mora,
Nocturnal. (Vaermina is in Batch 0.) Note Nocturnal's commitment hook is the
Thieves Guild / Nightingale chain and does not count toward Oblivion Walker;
Clavicus Vile must keep the bargain price visible in the price descriptions
(manifest Section 7 note).

### Batch 3 - Tolerated and remaining curse-access

Peryite (Tolerated, after Meridia proves the class). Hircine (curse-access
content surface only, per D-16.3).

**Rationale:** Batch 0 fronts every decision-dependent shape, so a wrong
assumption surfaces after four Princes, not after fifteen.

---

## D-18: Per-Prince "content-ready" definition for the 20C gate (proposed lock)

A Prince is **content-ready** for the 20C gate when all of the following hold
(this is the per-Prince exit checklist the verifier and human review check
against):

1. **Tone profile** row authored.
2. **Boon descriptions** Seeker/Devoted/Champion authored (passive SPEL text).
3. **Price descriptions** Seeker/Devoted/Champion authored, paired to boons.
4. **Tier-up + lapse** notifications and the **Champion entry** MessageBox
   authored.
5. **Commitment** (standard) or **curse-onset** (curse-access, D-16) authored.
6. **Stigma crossings** authored per the D-15 band model and weight class
   (standard), or curse-state-driven and coordinated (curse-access).
7. **Neglect texture + exit** authored, with residue per D-15.3.
8. **Per-race response** authored for every non-native race; native races route
   to the race manifest with an explicit no-row note (Boethiah Section 6.8 is
   the template).
9. **Matrix fidelity:** every response state matches the Prince's row in
   `PDV_DaedricRacePrinceMatrix.csv` (state, friction, exit).
10. **Hook source named** per the matrix `VanillaHookPriority`.
11. **Mechanically clean:** `node tools/pdv_content_verify.mjs` green - ASCII,
    per-Surface budgets, slot-ID uniqueness, voice matrix, source citations,
    non-empty prose; no slot collision with race-manifest native or CurseState
    rows.
12. **Firing-density sanity** paragraph present (Boethiah Section 6.9 template):
    marked `<1 per 2h`, noted `<2 per h`, quiet = passive.

Note this is the **content** gate. It does not include runtime proof or world
placement of Daedric paths - those follow on the code track (CAT-6 promotion
and the pre-beta scaling rubric), exactly as the Aedric races do.

---

## Effect on the Phase 20 estimate

With D-15..D-18 locked, 20C stops being an open-ended design-and-author block
and becomes a sized authoring burndown: **Batch 0 (4 Princes) + 11 remaining,
each to the D-18 checklist, against a single proven stigma/curse template.**
That converts the earlier fuzzy "~20-35 days" into a countable per-Prince pass,
and fronts the only re-author risk into the first four Princes.

## Ratification checklist

- [x] D-15 stigma model: locked in v3 Section 11.6; manifest Section 5 flipped
      to "locked" (2026-05-31).
- [x] D-16 curse-access template: locked in v3 Section 11.6; manifest Section 7
      curse-access note updated (2026-05-31).
- [x] D-17 batch order: locked in v3 Section 11.6; referenced from manifest
      Section 7 (2026-05-31).
- [x] D-18 content-ready definition: locked in v3 Section 11.6 (2026-05-31).
- [x] Follow-up: mirrored the D-18 checklist into the coverage matrix
      `phase20Slices` 20C entry as `contentReadyDefinition` (plus a
      `voicedContentScope` note) (2026-05-31).
