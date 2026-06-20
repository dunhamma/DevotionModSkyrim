# PDV Variety Manifest -- Khajiit (Focus Distinctness Addendum) DRAFT

**Status:** DRAFT (no-deploy prep). Nothing in this document deploys, authors records, or changes the live build.
**Created:** 2026-06-19
**Provenance:** Drafted from `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` (Khajiit addendum, lines 121-136 + Resolved Decision 4), `race-sheets/PDV_RaceDesign_Khajiit.md` ("Variety Tranche -- Focus Distinctness Addendum (DESIGN-LOCKED 2026-06-12)"), `race-sheets/Race_Khajiit.md`, `references/authoring/PDV_RaceEffectReviewLedger.md` (Variety Tranche Gate + Khajiit T1 Baseline + Khajiit row), and the Bosmer precedent (`PDV_BosmerVariety_RecordBatch.manifest.json`, `PDV_BosmerVariety_PapyrusHandoff.md`, `PDV_SessionHandoff_BosmerVarietyLocal.md`). Live-script grounding read from `generated/live-devotion-snapshot/2026-06-15-final-polish/Scripts/Source/` (`PDV__ManagerQuest.psc`, `PDV_PlayerEvents.psc`, `PDV_EventBus.psc`).

---

## >> PROVISIONAL MAGNITUDES -- DO NOT AUTHOR UNTIL ROW REVIEW <<

Every magnitude, duration, and ActorValue in this manifest is **PROVISIONAL**.
The Khajiit row in `PDV_RaceEffectReviewLedger.md` is **Pilot-provisional**, not
complete; the Variety Tranche Gate (2026-06-12) requires that all three signature
effect families (`Rajhin's Borrowed Moment`, `Baan Dar's Improvisation`,
`Alkosh's Long Breath`) pass that ledger's per-race row review before any record
is authored. No author tool may write these records, and no `.psc` may bind these
properties, until that row review lands. This document is a planning artifact only.

What IS locked (per the roadmap Resolved Decisions and the race-sheet addendum):
the **shape** of each beat (trigger, gate, cap, fade), and the addendum's scope
boundary -- **three focus-gated signatures only; no new substrate, place,
pilgrimage, or rite work** (road-home cadence already owns those jobs). What is
NOT locked: the magnitude, duration, and exact ActorValue of each pulse.

---

## Scope And Precedent

This is the smallest of the five variety tranches. The Lunar Lattice already
closed the Khajiit substrate gap; this addendum answers only the residual
balance-audit risk that "Khenarthi and Azurah crowd out Baan Dar, Rajhin, and
Alkosh" (roadmap Thinness ranking, Khajiit = P2 small). It does NOT reuse the
Argonian/Bosmer L1/L2/L4/L5 levers (dreams, bed-of-choice declaration,
pilgrimage set, one-active rite). It is L3 (playstyle signature) only, applied
three times.

Precedent for the record/author/Papyrus split is the Bosmer tranche
(`PDV_BosmerVariety_RecordBatch.manifest.json` + `tools/pdv-bosmer-variety-author`
+ `PDV_BosmerVariety_PapyrusHandoff.md`). Each Khajiit signature is a single
self-cast timed-buff `SPEL` + `MGEF` pair, modeled on the Bosmer
`PDV_SPEL_BosmerScalesAtRest` / `PDV_SPEL_BosmerBaanDarGap` pattern (Speech/Speed
pulses, short duration, once/day cap enforced in the manager script, not the
record).

## What Already Exists vs What Is Missing (Khajiit-specific reconcile)

Unlike Bosmer -- where the trigger hooks (sleep dispatcher, location router,
combat-session poll) had to be authored alongside the tranche -- the Khajiit
signatures sit on **trigger routes that already ship in the live build**. The
gap is the buff-cast layer on top, not the detection.

| Beat | Detection already live? | Live route (read from snapshot) | What is MISSING (this tranche) |
|---|---|---|---|
| Rajhin's Borrowed Moment | YES | `PDV_PlayerEvents.HandleKhajiitOrganicKill` / elegant-theft path -> `PDV_EventBus.RouteKhajiitRajhinElegantTheft` (`PDV_PlayerEvents.psc:625`, `PDV_EventBus.psc:249`) | the brief sneak-pulse buff cast + once/day cap; route currently only adjusts focus weight + pulses piety |
| Baan Dar's Improvisation | YES | combat-session poll, outnumbered-3+/level-delta win gate -> `PDV_EventBus.RouteKhajiitBaanDarRoadTrick` (`PDV_PlayerEvents.psc:506-510`, `PDV_EventBus.psc:213`) | the brief stamina-pulse buff cast + once/day cap; outnumbered detection + `PDV.Khajiit.BaanDar.OutnumberedDay` cap already exist |
| Alkosh's Long Breath | YES | `OnActorKilled` named/generic dragon classify -> `RouteKhajiitAlkoshNamedDragon` / `RouteKhajiitAlkoshGenericDragon` (`PDV_PlayerEvents.psc:540-553`, `PDV_EventBus.psc:291/306`) | the Marked time-flavor line + small pulse buff; named-dragon one-shot marker already exists |

**Net:** no new event registration is needed for any of the three. Each route
already lands in the manager and adjusts focus emphasis; the tranche adds a
focus-gated buff-cast hop (and, for Rajhin/Baan Dar, a once/day cap on the buff
specifically -- distinct from the existing piety-signal caps).

Focused-emphasis enum (LOCKED, confirmed in `PDV__ManagerQuest.psc:538-543`):
`KHAJIIT_FOCUS_NONE=0`, `KHENARTHI=1`, `AZURAH=2`, `BAANDAR=3`, `RAJHIN=4`,
`ALKOSH=5`. Read via `GetKhajiitFocusedEmphasis()`. The signature buffs gate on
the player's current focused emphasis matching the deity (Rajhin=4, BaanDar=3,
Alkosh=5).

## Cross-race note (Resolved Decision 4)

`Baan Dar's Improvisation` (Khajiit, survive-outnumbered-3+) and
`Baan Dar Opens the Gap` (Bosmer Bandit Road, escape-below-20%-health) are
intentionally trigger-distinct expressions of a canonically shared deity. Both
ship; this is documented in the roadmap's Resolved Decisions, not in
`PDV_PairedEquityWaivers.csv` (wrong schema). The Bosmer record
`PDV_SPEL_BosmerBaanDarGap` already exists; the Khajiit `PDV_SPEL_Khajiit_BaanDar_Improvisation`
proposed below is a separate record with a different ActorValue and trigger.

---

## Proposed Record Manifest (DRAFT -- not authored)

Naming follows PDV convention (`PDV_SPEL_` / `PDV_MGEF_`). EditorIDs are
proposed; confirm uniqueness against the live ESP before any author run. No
`MESG` or `FLST` records are needed -- this tranche has no menu, declaration, or
curated-site set (scope boundary above). Magnitudes/durations/ActorValues below
are **PROVISIONAL placeholders** chosen to sit at Bosmer-signature scale
(short pulse, single AV); they are tuning work for the ledger row, not proposals
to lock.

### 1. Rajhin's Borrowed Moment

| Field | Value |
|---|---|
| Proposed `SPEL` EditorID | `PDV_SPEL_Khajiit_Rajhin_BorrowedMoment` |
| Proposed `MGEF` EditorID | `PDV_MGEF_Khajiit_Rajhin_BorrowedMoment_Sneak` |
| Record type | `SPEL` (self-cast, fire-and-forget timed) + `MGEF` |
| Gameplay shape | TRIGGER: successful pickpocket/elegant theft of a notable target while Rajhin-focused. GATE: `GetKhajiitFocusedEmphasis() == KHAJIIT_FOCUS_RAJHIN (4)`. CAP: once/day. FADE: timed buff expiry (no dawn fade -- this is a pulse, not a one-active rite). |
| Provisional magnitude | **PROVISIONAL** Sneak +10, duration 120s (Bosmer-pulse scale; tune in ledger row -- confirm whether a sneak *stat* pulse or a muffle/fade flavor effect is the intended texture, since the Rajhin T3 capstone already owns the fade/muffle proc) |
| Surfacing / copy hook | Quiet top-left notice; reuse the existing Rajhin shift-toast voice (`SendPrismaShiftToast("Elegant theft", "Rajhin purrs.", ...)`, `PDV__ManagerQuest.psc:3670`). PROVISIONAL line: "Rajhin lends you a borrowed moment. The shadows owe you one." |
| Anti-farm cap | once/day, keyed on a new manager StorageUtil day-key (e.g. `PDV.Khajiit.Rajhin.BorrowedDay`), encoded as `day+1` per the StorageUtil zero-default rule (memory: day-key zero default). Independent of the existing piety-signal cooldown on `RouteKhajiitRajhinElegantTheft`. |
| Author tool / Papyrus hook | NEW `tools/pdv-khajiit-variety-author` (model on `pdv-bosmer-variety-author`); writes the SPEL+MGEF and forward-wires `PDV__ManagerQuest.PDV_SPEL_Khajiit_Rajhin_BorrowedMoment`. Papyrus: add a once/day buff-cast call inside (or just after) the manager handler reached by `RouteKhajiitRajhinElegantTheft` (`HandleKhajiit...RajhinElegantTheft`), gated on focus==4. No new event registration. |

### 2. Baan Dar's Improvisation

| Field | Value |
|---|---|
| Proposed `SPEL` EditorID | `PDV_SPEL_Khajiit_BaanDar_Improvisation` |
| Proposed `MGEF` EditorID | `PDV_MGEF_Khajiit_BaanDar_Improvisation_StaminaRegen` |
| Record type | `SPEL` (self-cast timed) + `MGEF` |
| Gameplay shape | TRIGGER: surviving combat that started while outnumbered 3+ (or level-delta >= 5) with real adversity (health dipped below half). GATE: `GetKhajiitFocusedEmphasis() == KHAJIIT_FOCUS_BAANDAR (3)`. CAP: once/day. FADE: timed buff expiry. |
| Provisional magnitude | **PROVISIONAL** StaminaRateMult +15, duration 60s (pariah-luck breather; Bosmer Gap uses SpeedMult +40/15s -- keep these mechanically distinct per Resolved Decision 4, so Khajiit stays stamina-shaped not speed-shaped) |
| Surfacing / copy hook | Quiet top-left notice. PROVISIONAL line: "Outnumbered, and still standing. Baan Dar improvises, and the breath comes back to you." |
| Anti-farm cap | once/day. The detection route already stamps `PDV.Khajiit.BaanDar.OutnumberedDay` (`PDV_PlayerEvents.psc:508`); the buff cast can reuse that same day-stamp gate so detection and buff share one cap, or take its own key -- decide at ledger review. |
| Author tool / Papyrus hook | Same NEW `tools/pdv-khajiit-variety-author`. Papyrus: add the focus-gated buff cast in the manager handler reached by `RouteKhajiitBaanDarRoadTrick` (the outnumbered-win route, NOT the near-fatal `RouteKhajiitBaanDarReversal` weekly route, which is the existing T3 cheat-death moment). No new event registration -- the combat-session poll already opens for Khajiit. |

### 3. Alkosh's Long Breath

| Field | Value |
|---|---|
| Proposed `SPEL` EditorID | `PDV_SPEL_Khajiit_Alkosh_LongBreath` |
| Proposed `MGEF` EditorID | `PDV_MGEF_Khajiit_Alkosh_LongBreath_Pulse` |
| Record type | `SPEL` (self-cast timed) + `MGEF` |
| Gameplay shape | TRIGGER: dragon kill while Alkosh-focused. GATE: `GetKhajiitFocusedEmphasis() == KHAJIIT_FOCUS_ALKOSH (5)`. CAP: **none beyond encounter rate** (locked: "naturally scarce, no cap needed"). FADE: timed buff expiry. |
| Provisional magnitude | **PROVISIONAL** small pulse -- candidate MagickaRateMult or HealRateMult +10, duration 60s; "small pulse" is the only locked magnitude word. The headline of this beat is the **Marked time-flavor line**, with the stat pulse secondary. Confirm AV at ledger review so it does not double the Alkosh T3 capstone (Fire/Magic Resist). |
| Surfacing / copy hook | A **Marked** line (heavier than the quiet once/day notices), time/order-flavored, consistent with the existing Alkosh order voice (`SendPrismaShiftToast("Words marked", "Alkosh orders new words.", ...)`, `PDV__ManagerQuest.psc:1293`). PROVISIONAL line: "The dragon falls, and for a long breath the world holds still. Alkosh keeps the seam you closed." |
| Anti-farm cap | None by design (scarcity of dragon kills is the cap). Named vs generic dragon distinction already exists in `HandleKhajiitOrganicKill`; decide at ledger review whether the buff fires on generic dragons too or only named/cosmic kills (named-dragon one-shot marker `PDV.Khajiit.AlkoshNamed.<FormID>` already exists). |
| Author tool / Papyrus hook | Same NEW `tools/pdv-khajiit-variety-author`. Papyrus: add the focus-gated buff cast + Marked line in the manager handler reached by `RouteKhajiitAlkoshNamedDragon` (and optionally `RouteKhajiitAlkoshGenericDragon`). No new event registration -- `OnActorKilled` dragon classify already ships. |

---

## Dependencies / Blocked-On

This manifest is blocked on all of the following before any authoring:

1. **Effect-review row review (HARD GATE).** The Khajiit row in
   `PDV_RaceEffectReviewLedger.md` must complete the per-race completion bar for
   these three signature families (floor/ceiling family, magnitude range,
   conditions/cadence, grant/removal owner, stack cap, Survey/status copy,
   rejected hooks, curse/Daedric interaction, manual feel note). The Variety
   Tranche Gate explicitly names all three as families to fold into that row.
   Until then, magnitudes stay provisional and nothing authors.
2. **Stack-cap confirmation.** Khajiit budget is "substrate + one emphasis + one
   active favor" (ledger Khajiit row, stack cap). Confirm these once/day pulses
   count as momentary favors, not a new always-on family, so they do not breach
   the one-active-favor cap. (Shape is locked as 10-minute-class pulse, so this
   should pass, but it must be stated in the row.)
3. **AV / capstone non-overlap review.** Each provisional AV must be checked
   against the shipped Khajiit T3 capstones so a signature pulse does not silently
   double a capstone axis: Rajhin T3 = Sneak/Lockpicking/Pickpocket/Unarmed +
   fade/muffle proc; Baan Dar T3 = Armor/HealRate/Unarmed + cheat-death;
   Alkosh T3 = Fire/Magic Resist + Roar. Pick signature AVs that read as a
   distinct momentary texture, not a capstone preview.
4. **Author tool build.** No `tools/pdv-khajiit-variety-author` exists yet. It
   must be built from the `pdv-bosmer-variety-author` pattern (fail-closed
   `--dry-run` / `--check`, ESP backup before write). Watch the same
   `ActorValue` enum-name drift the Bosmer/Argonian batches hit
   (e.g. `Speech` vs `Speechcraft`, `SpeedMult`, `MagicResist` vs `ResistMagic`);
   confirm at `--dry-run`, never change magnitudes to satisfy the compiler.
5. **FormID verification.** No new vanilla FormIDs are required (no FLST, no
   pilgrimage set -- this is the one tranche that needs zero LCTN resolution).
   The only FormID concern is confirming the new SPEL/MGEF EditorIDs do not
   collide with existing Khajiit records (`PDV_Bless_Khajiit_*` family); run an
   ESP read before authoring.
6. **ESP lock.** Skyrim/CK must release `Devotion.esp` before any author write
   (standard); and the houseCARL-holds-ESP-lock workaround applies if a Mutagen
   overlay is active.
7. **Papyrus binding + recompile.** After records land, declare the three
   `Spell Property` lines in the canonical `PDV__ManagerQuest.psc`, add the
   focus-gated once/day buff-cast calls in the three existing route handlers, and
   recompile via `tools/pdv_compile.mjs` (expect 0/0). The canonical `.psc` is the
   live MO2 source dir, not the dated snapshot read here (repo-source-drift
   lesson) -- verify call-site names against live before editing.
8. **Runtime proof.** Per the proof-boundary discipline, record/readback/wiring
   proof is not runtime proof. A Khajiit beta-packet addendum + `DebugSeed`
   harness (model: `PDV_BetaTestPacket_Bosmer.md` variety addendum) is required,
   and an in-game fresh-save smoke per signature (focus-gated, once/day cap,
   wrong-focus silence, Alkosh Marked line) is the gate before any
   "runtime-proven" claim.

## Open Reconcile Notes (carry forward, do not auto-fix)

- The Khajiit addendum is the **last** item in the locked roadmap build order
  (Bosmer -> Orc -> Altmer -> Redguard -> Khajiit addendum). Bosmer itself is
  records+runtime-landed but in-game-smoke PENDING as of the roadmap's 2026-06-13
  build-status line; Orc/Altmer/Redguard remain design-locked but unbuilt. This
  Khajiit manifest is a forward-prep DRAFT and is not next in the queue.
- No `PDV_KhajiitVariety_RecordBatch.manifest.json` exists yet (Grep found only
  the Argonian and Bosmer batch manifests). This DRAFT is the precursor to that
  JSON contract, not a replacement for it; when the ledger row clears, fold this
  into a `pdv-khajiit-variety-batch.v1` JSON in the Bosmer manifest's shape.
- Surfacing channel (top-left Debug.Notification vs Prisma shift-toast vs a
  promoted `PDV_Notif_*`) should be decided alongside the wider diegetic
  surfacing work; the existing Khajiit shift-toasts give a ready voice to reuse.
