# PDV Variety Manifest -- Altmer "The Return Made Daily" (DRAFT)

**Status:** DRAFT (no-deploy prep). Nothing in this file is authored, written to the framework ESP, compiled, or deployed. It is a prep artifact only.
**Created:** 2026-06-19
**Provenance:** Read and reconciled from `race-sheets/Race_Altmer.md`, `race-sheets/PDV_RaceDesign_Altmer.md` (Variety Tranche section + ThalmorAlignment/Lorkhan/crisis locks), `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` (Altmer "The Return Made Daily", Resolved Decisions 2 and 3), `references/authoring/PDV_RaceEffectReviewLedger.md` (Variety Tranche Gate + Altmer race rows), the shipped Bosmer precedent `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json` + `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md` + `references/authoring/PDV_SessionHandoff_BosmerVarietyLocal.md`, and the live manager snapshot `generated/live-devotion-snapshot/2026-06-15-final-polish/Scripts/Source/PDV__ManagerQuest.psc` (for the existing Altmer hook/getter names).

---

## !!! PROVISIONAL MAGNITUDES -- DO NOT AUTHOR UNTIL ROW REVIEW !!!

Every magnitude, duration, and effect axis in this manifest is **PROVISIONAL**. Per the `PDV_RaceEffectReviewLedger.md` Variety Tranche Gate (2026-06-12), the Altmer race row is still **Pending** -- it has not completed the holistic effect review (floor family, ceiling family, magnitude range, cadence, grant/removal owner, stack cap, Survey copy, rejected hooks, curse/Daedric interaction, manual feel note). **No record in this manifest may be authored to the ESP, and no author tool may be built, until the Altmer row in that ledger is reviewed and these magnitudes are ratified.** This document only proposes the record shapes that the locked design implies; it does not approve them.

The locked design covers **shapes, gates, caps, and fade rules ONLY**. Magnitudes are tunable inside the gate and are written here as starting points, not commitments.

---

## What is locked vs. what this manifest proposes

**Locked (do not relitigate):**

- The five-lever tranche shape is design-locked into `race-sheets/PDV_RaceDesign_Altmer.md` ("Variety Tranche -- The Return Made Daily", 2026-06-12) and the roadmap.
- L4 is a **hybrid eight-station circuit**: two base-game stations (College of Winterhold Hall of the Elements + one authored Auri-El surface) felt early, then the five Forgotten Vale wayshrines (Illumination, Sight, Learning, Resolution, Radiance) + the Inner Sanctum as the deep arc; milestone at all eight. (Roadmap Resolved Decision 2.)
- `Dawnguard.esm` is already a hard framework master (Ancestor Glade / Argonian Waters precedent), so the Forgotten Vale stations add no new dependency. (Roadmap Resolved Decision 3.)
- Rite effects follow the Hist Adaptations contract: one active at a time, swap is clear-before-add, "Not yet" does not spend the cooldown, fade at dawn on coherence break, restore at dawn on recovery. (Effect-review ledger Variety Tranche Gate.)
- Tranche effects add **no new always-on boon family**: pilgrimage pulses are one-shot, signatures are once/day ~10-minute-class pulses, the rite is one-active with dawn fade/restore. The two-family hybrid boon budget is untouched. The Lorkhan economy is never weakened by this tranche.

**This manifest proposes (NOT locked):** the concrete EditorIDs, record types, provisional magnitudes, surfacing copy, anti-farm keys, and author-tool/Papyrus hooks needed to build the locked design once the effect-review gate opens.

---

## Reconciliation with the Bosmer precedent (what exists vs. what is missing)

The Bosmer "The Story Goes On" tranche is the only variety tranche past Argonian with a written record batch + Papyrus handoff, so it is the precedent this manifest mirrors.

| Aspect | Bosmer (exists) | Altmer (this DRAFT) |
|---|---|---|
| Record-batch manifest JSON | `PDV_BosmerVariety_RecordBatch.manifest.json` (records written + Papyrus applied 2026-06-12) | **MISSING** -- no `PDV_AltmerVariety_RecordBatch.manifest.json` yet; this markdown is the prep step before that JSON is drafted |
| Papyrus runtime handoff | `PDV_BosmerVariety_PapyrusHandoff.md` (paste-in spec) | **MISSING** -- not written; the Papyrus-hook column below is the seed for it |
| Author tool | `tools/pdv-bosmer-variety-author/` (built, run) | **MISSING** -- no `tools/pdv-altmer-variety-author` |
| Local-completion handoff | `PDV_SessionHandoff_BosmerVarietyLocal.md` | **MISSING** -- not needed until the JSON + author tool exist |
| Design lock | Bosmer race sheet "The Story Goes On" | **EXISTS** -- Altmer race sheet "The Return Made Daily" (locked 2026-06-12) |
| Beta packet addendum | folded into `PDV_BetaTestPacket_Bosmer.md` | Altmer packet exists (`PDV_BetaTestPacket_Altmer.md`, current packet Pass) but carries **no tranche addendum** yet |

Conventions carried over from the Bosmer batch (so the eventual Altmer JSON stays consistent):
- EditorID prefixes: `PDV_MESG_` (MessageBox), `PDV_SPEL_` (spell, with paired `MGEF`), `PDV_FLST_` (FormList).
- Timed self-buffs are `SPEL+MGEF` in the Rooted-Rest/Tale-Carried family (self-cast, fixed duration). One-active rite options are `SPEL+MGEF ability` (constant ability added/removed by the manager, not timed).
- All player-facing text is ASCII-only (plain `'` and `"`, `--` not em-dash). Path/state gating lives in the **manager script**, not in the records.
- The author tool is fail-closed: it refuses a real ESP write while any FLST entry has `verified=false`; `--dry-run` and `--check` still run structurally and report PENDING slots.
- Mutagen `ActorValue` enum member names must be confirmed at `--dry-run` (the `atRiskEnumNames` lesson: `MagicResist -> ResistMagic`; suspect `MagickaRate` vs `MagickaRateMult`, etc.). Never change a FormID or magnitude to satisfy the compiler.

---

## Existing manager surface this tranche hangs off (reused -- do not re-author)

Grounded in `generated/live-devotion-snapshot/2026-06-15-final-polish/Scripts/Source/PDV__ManagerQuest.psc`:

- Origin gate: `Bool IsAltmerOrigin()` (`ORIGIN_ALTMER = 3`).
- Crisis state: `Int GetAltmerCrisisState()` reading `PDV_AltmerCrisisTrack` (`PDV_StateTrack`); states `None=0 / Dissonant=1 / Questioning=2 / Reasserting=3 / ScarredResolved=4`. Labels via `GetAltmerCrisisStateLabel()`.
- ThalmorAlignment band: `PDV_ThalmorAlignmentTrack` (`PDV_ReputationTrack`, -100..+100), read via `.GetValue()`; bands `OpenHeterodox / PrivateHeterodox / Uncommitted / PublicOrthodox / ThalmorEnforcer`. (Reminder, per the durable note: the committed band LABEL lags the raw value via lock-in grace -- gate emitters on the raw `.GetValue()`, not the band label.)
- Dawn rite hook: `Function RunDawnAwardAltmerAuriElDawn()` and `Function HandleAltmerDawnSteadiness(String reason)`; the dawn refresh path already runs per-day. Contemplations and the rite/Hand dawn fade-restore ride this existing dawn pass.
- Positive-income study tag: `PDV_ALT_POS_STUDY_TEXT` (book-read positive-income tag, value `+3..+5`) -- the **piety** side of Chamber of Study stays owned by this existing tag; the tranche only adds the place-anchor buff.
- Suppression hook: `Bool IsAltmerFavorSuppressedByCurse()` -- the tranche's positive surfaces must respect this (vampire terminal/exile, werewolf hard halt).

The pilgrimage interior-poll and one-active rite machinery are **parameterized reuses** of the shipped Argonian/Bosmer manager code paths (e.g. `TryArgonianEldergleamInterior`, `SyncBosmerNaming`); budget them as modifications, not new systems.

---

## Record manifest -- one row group per locked tranche beat

Lever IDs (L1..L5) match the roadmap. `[PROV]` marks every provisional magnitude.

### L1 -- Contemplations (dawn-window texture, no new piety)

| Field | Value |
|---|---|
| Proposed EditorID(s) | `PDV_MESG_AltmerContemplation_Coherent`, `PDV_MESG_AltmerContemplation_Dissonant`, `PDV_MESG_AltmerContemplation_Resolution` (text-only MESG, or top-left `Debug.Notification` lines if no button is wanted -- see Dependencies) |
| Record type | MESG (notification-class) or pure script copy strings |
| Gameplay shape | Trigger: the existing dawn pass (`RunDawnAwardAltmerAuriElDawn` / dawn refresh). Gate: keyed to `GetAltmerCrisisState()` + `PDV_ThalmorAlignmentTrack.GetValue()` band. A `Dissonant` dawn reads differently from a coherent one; the resolution day gets one Marked line. No cap/fade beyond the once-per-dawn line cadence. |
| Provisional magnitude | **None -- pure texture.** No piety, no buff. (Locked: "no new piety, no new records beyond MESG/line content".) |
| Surfacing / copy hook | Top-left dawn line. Voice: judged-by-coherence, narrator-distant; e.g. coherent "Dawn. The road back is still the road." / dissonant "Dawn comes anyway, though something in you turned aside." / resolution (Marked) one line. ASCII only. |
| Anti-farm cap | Once per in-game day (dawn-window only). Encode the day key as `day+1` (StorageUtil int day-keys default to 0 -- the day-0 self-suppression trap). Suggested key `PDV.Alt.ContemplationLastDay`. |
| Author-tool / Papyrus hook | Author tool: only if MESG records are used (else none). Papyrus: new manager fn `HandleAltmerContemplation(String reason)` called from the dawn pass; reads crisis + alignment to pick the line. Respect a shown-MessageBox suppression so a crisis MessageBox and a contemplation line never stack the same dawn. |

### L2 -- Chamber of Study (place anchor) + Ordered Mind (buff)

| Field | Value |
|---|---|
| Proposed EditorID(s) | `PDV_MESG_AltmerMarkStudy` (declaration prompt); `PDV_SPEL_AltmerOrderedMind` (+ paired `PDV_MGEF_AltmerOrderedMind_MagickaRegen`) |
| Record type | MESG; SPEL+MGEF (timed self-buff, Rooted-Rest family) |
| Gameplay shape | Trigger: first qualifying read (a `PDV_ALT_POS_STUDY_TEXT` book) inside an ownable cell prompts the cell-keyed declaration; declining re-prompts after 3 in-game days. Once declared, reading a qualifying text inside the declared study casts Ordered Mind. Cell is the reliable key (mirrors bed-of-choice; furniture ref is unreliable). No fade -- it is a timed pulse, not an ability. |
| Provisional magnitude | `+5%` magicka regen, `600s` (10 min). **[PROV]** -- axis is MagickaRateMult-family; confirm exact AV name (`MagickaRateMult` vs `MagickaRate`) at dry-run. The piety side stays owned by the existing `PDV_ALT_POS_STUDY_TEXT` tag (+3..+5); Ordered Mind adds NO piety. |
| Surfacing / copy hook | Declaration MESG body: "Make this your place of study? The Elder Way is kept by returning to it." Buttons: ["Yes, this is my study", "Not yet"]. Buff line: "Your study orders the mind. The arts come easier for a while." |
| Anti-farm cap | Buff is gated to the declared cell + a qualifying-text read; not a per-read faucet -- once-per-day buff cap suggested (`PDV.Alt.OrderedMindLastDay`, `day+1` encoding). Declaration decline cooldown 3 days (`PDV.Alt.StudyDeclineDay`, `day+1`). |
| Author-tool / Papyrus hook | Author tool: 1 MESG + 1 SPEL+MGEF + forward VMAD wiring of `PDV_MESG_AltmerMarkStudy` and `PDV_SPEL_AltmerOrderedMind`. Papyrus: `TryAltmerMarkStudy(...)` (cell-keyed declaration) + `TryAltmerOrderedMind(...)` (gated cast), called from the qualifying-book-read route that already feeds `PDV_ALT_POS_STUDY_TEXT`. Keys: `PDV.Alt.Study.DeclaredCell`. |

### L3 -- Syrabane's Hand (signature, once/day)

| Field | Value |
|---|---|
| Proposed EditorID(s) | `PDV_SPEL_AltmerSyrabanesHand` (+ paired `PDV_MGEF_AltmerSyrabanesHand_SpellCost`) |
| Record type | SPEL+MGEF (timed self-buff) |
| Gameplay shape | Trigger: a ward fully absorbs a hostile spell. Gate: coherence-gated -- **suppressed while a crisis is unresolved** (`GetAltmerCrisisState()` not `None` and not `ScarredResolved`). Protection-shaped, never a damage reward (locked Syrabane boundary). Once/day. No fade (timed pulse). |
| Provisional magnitude | Brief spell-cost reduction pulse, e.g. spell cost `-10%` for `30s`. **[PROV]** -- magnitude/duration unset by the lock; modeled on Bosmer once/day signatures (~10-min-class, but a combat pulse should be short). Effect axis: a spell-cost/magicka-cost MGEF (confirm AV at dry-run). |
| Surfacing / copy hook | Top-left: "Syrabane's hand steadies yours." (exact locked phrase). |
| Anti-farm cap | Once per in-game day (`PDV.Alt.SyrabaneLastDay`, `day+1` encoding). Plus the crisis-unresolved suppression gate. |
| Author-tool / Papyrus hook | Author tool: 1 SPEL+MGEF + VMAD wiring. Papyrus: `TryAltmerSyrabanesHand(Actor playerRef)` gated on origin + crisis-clear + once/day, called from a ward-absorb detection hook. **Dependency/risk:** there is no existing "ward fully absorbed a hostile spell" event in the manager; the detection route is the L3 build risk (see Dependencies). Mirror the Bosmer combat-session-poll lesson -- prefer a bounded poll over a flaky raw hit hook. |

### L4 -- Wayshrines of the Chantry (pilgrimage, hybrid eight stations, one-shot forever)

| Field | Value |
|---|---|
| Proposed EditorID(s) | `PDV_FLST_AltmerChantryWayshrines` (8-entry LCTN FormList); `PDV_MGEF_AltmerChantryPulse` / `PDV_SPEL_AltmerChantryPulse` (small Auri-El arrival pulse, optional if the pulse routes through an existing Auri-El signal instead -- see hook); `PDV_MESG_AltmerChantryMilestone` (all-eight milestone MessageBox) |
| Record type | FLST (LCTN list) + MESG (milestone) + optional small SPEL+MGEF arrival pulse |
| Gameplay shape | Trigger: first arrival at each of the eight stations = vision line + small Auri-El pulse. Milestone at all eight. One-shot per station forever (anti-farm by construction). Stations: (1) College of Winterhold Hall of the Elements, (2) one authored Auri-El surface [TBD], (3-7) the five Forgotten Vale wayshrines (Illumination, Sight, Learning, Resolution, Radiance) [Dawnguard.esm], (8) the Inner Sanctum [Dawnguard.esm]. |
| Provisional magnitude | "small Auri-El pulse" per station. **[PROV]** -- prefer routing the pulse through the existing Auri-El positive-income path (like Bosmer Songs route through `HandleBosmerPactPositiveSignal`) rather than a new always-on boon; if a dedicated pulse spell is authored, keep it tiny and one-shot. No buff persistence. |
| Surfacing / copy hook | Per-station first-arrival vision line (Auri-El/return-coded, ASCII). Milestone MESG: an all-eight "the Chantry is complete" line. The Initiate's Ewer pilgrimage is the in-lore frame. |
| Anti-farm cap | One-shot per station forever (`PDV.Alt.Chantry.Seen.<FormID>`), milestone fires once (`PDV.Alt.Chantry.Milestone`), count in `PDV.Alt.Chantry.Count`. For any station whose LCTN spans an exterior approach but whose sacred point is interior (Vale precedent), use the armed-interior-poll pattern from `TryArgonianEldergleamInterior` / `TryBosmerEldergleamInterior`. |
| Author-tool / Papyrus hook | Author tool: 8-entry FLST (fail-closed on unverified slots) + MESG + optional SPEL+MGEF + VMAD wiring. Papyrus: `HandleAltmerChantryArrival(Location loc)` (location-change router, mirrors `HandleBosmerLocationChange`) + `AwardAltmerWayshrine(Int siteFormId)` (one-shot award + milestone) + an interior poll for any interior-keyed Vale station. **All eight LCTN FormIDs need verification before any write (see Dependencies).** |

### L5 -- Disciplines of Return (rite, one-active, 7-day cooldown, dawn fade/restore)

| Field | Value |
|---|---|
| Proposed EditorID(s) | `PDV_MESG_AltmerDisciplines` (rite menu); four one-active abilities `PDV_SPEL_AltmerDiscipline_<School>` x4 (+ paired `PDV_MGEF_AltmerDiscipline_<School>` each). Exact school set is locked at effect review -- placeholder names below. |
| Record type | MESG + 4x SPEL+MGEF ability (constant ability, manager-managed add/remove) |
| Gameplay shape | Trigger: rite at the declared study (the L2 Chamber of Study cell), 7-day cooldown; "Not yet" does NOT spend the cooldown. One-active cultivation discipline; choosing again swaps (clear-before-add). Fade at dawn while a crisis is unresolved or after an alignment-band break; restore automatically at dawn on coherent recovery. Follows the Hist Adaptations contract exactly. |
| Provisional magnitude | Four choices, each one school of magic at **either** `-5%` cost **or** `+5%` regen. **[PROV]** -- the exact four schools and whether each is cost or regen is locked at effect review, not here. Each ability is `+5%`-class. |
| Surfacing / copy hook | Rite MESG body lists the four disciplines (effects in the BODY, not the buttons -- Skyrim lays buttons in one row). Buttons: the four discipline names + "Not yet". Apply line: "You set the discipline. It holds while you hold to the path." Fade line: "The discipline goes quiet -- you have wandered from coherence." Restore line: "You return to coherence. The discipline holds again." |
| Anti-farm cap | 7-day rite cooldown (`PDV.Alt.Disc.LastRiteTime`, float game-time, mirror Bosmer Naming's 7.0 check). One active at a time (`PDV.Alt.Disc.Active`, 0=none/1-4). Records the alignment band + crisis state at rite time for the coherence check (`PDV.Alt.Disc.BandAtRite`). |
| Author-tool / Papyrus hook | Author tool: 1 MESG + 4 SPEL+MGEF abilities + VMAD wiring (mirrors the Bosmer Naming 5-record + MESG block). Papyrus: `TryAltmerDisciplinesRite(...)`, `ApplyAltmerDiscipline(Int index)`, `RemoveAltmerDisciplineSpells(...)`, `GetAltmerDisciplineSpell(Int index)`, `SyncAltmerDisciplines(Actor playerRef)` (dawn fade/restore via `IsAltmerDisciplineCoherent`), called from the dawn pass beside the existing Altmer dawn award. Direct copy of the `SyncBosmerNaming` family. |

---

## VMAD wiring (forward-wire on the manager, like the Bosmer batch)

Target quest: `PDV__ManagerQuest`. Proposed properties (provisional set; finalize against the JSON when it is drafted):

```
Message  Property PDV_MESG_AltmerMarkStudy            Auto
Message  Property PDV_MESG_AltmerDisciplines          Auto
Message  Property PDV_MESG_AltmerChantryMilestone     Auto
Spell    Property PDV_SPEL_AltmerOrderedMind          Auto
Spell    Property PDV_SPEL_AltmerSyrabanesHand        Auto
Spell    Property PDV_SPEL_AltmerDiscipline_S1        Auto
Spell    Property PDV_SPEL_AltmerDiscipline_S2        Auto
Spell    Property PDV_SPEL_AltmerDiscipline_S3        Auto
Spell    Property PDV_SPEL_AltmerDiscipline_S4        Auto
FormList Property PDV_FLST_AltmerChantryWayshrines    Auto
; PDV_SPEL_AltmerChantryPulse only if the arrival pulse is a dedicated spell
; (preferred: route the pulse through the existing Auri-El positive signal instead)
; Contemplation MESG properties only if L1 uses MESG records rather than script lines
```

Properties bake into the save at first init (existing-save migration note carries over from the Bosmer batch): the test path is a new game / `coc qasmoke`; existing saves stay silently inert until a lazy `GetFormFromFile` fallback adds the authored FormIDs.

---

## StorageUtil key plan (script state only -- no records back these)

Modeled on the Bosmer key plan. Day-keys use the `day+1` encoding to dodge the day-0 zero-default self-suppression trap.

- Contemplations: `PDV.Alt.ContemplationLastDay`, `PDV.Alt.ContemplationLastBand`.
- Chamber of Study: `PDV.Alt.Study.DeclaredCell`, `PDV.Alt.StudyDeclineDay`, `PDV.Alt.OrderedMindLastDay`.
- Syrabane's Hand: `PDV.Alt.SyrabaneLastDay`.
- Chantry: `PDV.Alt.Chantry.Seen.<FormID>`, `PDV.Alt.Chantry.Count`, `PDV.Alt.Chantry.Milestone`, plus an `...Active` interior-poll arm key per interior-keyed Vale station.
- Disciplines: `PDV.Alt.Disc.Active` (0/1-4), `PDV.Alt.Disc.LastRiteTime` (float game-time), `PDV.Alt.Disc.BandAtRite`, `PDV.Alt.Disc.CrisisAtRite`.

---

## Dependencies / blocked-on

1. **BLOCKED ON EFFECT-REVIEW GATE (hard).** No record may be authored and no author tool built until the Altmer row in `PDV_RaceEffectReviewLedger.md` completes the holistic review and ratifies these magnitudes. This is the governing blocker.
2. **Eight Chantry LCTN FormIDs need verification.** Only conceptual names are locked. The two base stations (College Hall of the Elements; the "one authored Auri-El surface" -- which is itself **TBD/undesigned**) and the six Dawnguard.esm Forgotten Vale stations (5 wayshrines + Inner Sanctum) all need resolved + `verified=true` FormIDs (via `tools/pdv_extract_vanilla_gameplay_refs.mjs` or the houseCARL LCTN query, the Bosmer precedent). The author tool must be fail-closed on unverified slots. **Open design item: what is the "one authored Auri-El surface"?** -- the locked text names it but does not specify the record; it may need its own activator/marker authored first.
3. **Vale interior-vs-exterior LCTN check.** Several Forgotten Vale wayshrines may have the sacred point inside an interior cell while the LCTN spans the exterior approach (the Eldergleam lesson). Each interior-keyed station needs the armed-interior-poll pattern and its interior cell FormIDs verified.
4. **L3 ward-absorb detection has no existing hook.** The manager has no "ward fully absorbed a hostile spell" event. This detection route must be designed (prefer a bounded poll over a raw hit hook, per the Bosmer Baan Dar lesson) before Syrabane's Hand can fire. This is the highest-risk runtime piece.
5. **ActorValue enum-name confirmation at dry-run.** MagickaRate/MagickaRateMult, spell-cost axis, and any regen axis must be confirmed against the live Mutagen build at `--dry-run` (the `MagicResist -> ResistMagic` / `ValueModifier` vs `PeakValueModifier` family of drift). Regen AVs use `PeakValueModifier`, not `ValueModifier` (durable convention). Never change a FormID or magnitude to satisfy the compiler.
6. **Author tool not built.** `tools/pdv-altmer-variety-author` does not exist; it should be cloned from `tools/pdv-bosmer-variety-author` (same `Ensure*/Wire*/WriteModIfNeeded` + fail-closed `--dry-run`/`--check` shape) only after items 1-2 are resolved.
7. **No record-batch JSON / Papyrus handoff yet.** This markdown is the prep step; the next artifacts are `PDV_AltmerVariety_RecordBatch.manifest.json` and `PDV_AltmerVariety_PapyrusHandoff.md`, both still to be written.
8. **Curse suppression must be respected.** All positive surfaces (Ordered Mind, Syrabane's Hand, Chantry pulse, Disciplines) must route through / honor `IsAltmerFavorSuppressedByCurse()` -- Altmer vampire is terminal/exile-limited and werewolf is a hard devotion halt; the rite/buffs must suppress accordingly.
9. **Build-order position.** Per the roadmap, Altmer is third in the suggested order (Bosmer -> Orc -> Altmer -> Redguard -> Khajiit addendum). Orc "Witnessed" is expected to land before Altmer; do not start the Altmer ESP write ahead of that without an explicit re-prioritization.

---

## Proof boundary (carry into the eventual beta packet addendum)

Nothing in this manifest is proven. When the records eventually land, the Bosmer gate sequence applies: resolve + verify all FLST FormIDs -> `--dry-run` (enum drift) -> real write + `--check` slot dump -> `pdv_verify.mjs` (FAIL=0) -> apply the Papyrus layer + `pdv_compile.mjs` (0/0) -> fresh-save / `coc qasmoke` smoke per lever (VMAD props bake at first init) -> fold results into a `PDV_BetaTestPacket_Altmer.md` tranche addendum with a `DebugSeedAltmer` SetPQV harness (clear rite/signature cooldowns, seed crisis + alignment states, seed Chantry arrivals) modeled on `DebugSeedBosmer`. Until that fresh-save smoke returns PASS, the Altmer tranche is **NOT runtime-proven**.