# PDV Variety Manifest -- Orc "Witnessed" Tranche (DRAFT)

**Status:** DRAFT (no-deploy prep). Nothing in this file deploys, authors records, or changes the live build.
**Created:** 2026-06-19
**Provenance:** Read and reconciled from `race-sheets/PDV_RaceDesign_Orc.md` (Variety Tranche -- "Witnessed", DESIGN-LOCKED 2026-06-12), `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` (Orc -- "Witnessed" Tranche, P1), `references/authoring/PDV_RaceEffectReviewLedger.md` (Orc rows + Variety Tranche Gate), `references/authoring/PDV_NextBuildPass_RecordSpec.md` (sec. 3, Orc Witnessed tranche), `references/authoring/PDV_OrcRewardRecords.spec.json` (supportSpells + messageRecords blocks), and the Bosmer precedent (`PDV_BosmerVariety_RecordBatch.manifest.json`, `PDV_BosmerVariety_PapyrusHandoff.md`, `PDV_SessionHandoff_BosmerVarietyLocal.md`). All text ASCII-only per `PDV_STANDARDS.md` hygiene.

---

## PROVISIONAL MAGNITUDES -- DO NOT AUTHOR UNTIL ROW REVIEW

> Every magnitude, duration, and piety value in this manifest is PROVISIONAL.
> The Orc effect family is still `pending` in `PDV_RaceEffectReviewLedger.md`
> (Orc row: "life-mode baseline small-to-moderate; forge gated by quality/
> value/context; below deep commitment (provisional)"). The roadmap and race
> sheet lock the SHAPES, GATES, CAPS, and FADE rules only; magnitudes remain
> tunable behind the Variety Tranche Gate. Do NOT promote any value below to a
> real record-authoring run until the Orc per-race row review signs off. Where
> a record already exists on the live ESP (see Reconciliation), its shipped
> magnitude is recorded for reference, NOT as an approval to re-author or
> re-tune outside the gate.

---

## What This Is

A DRAFT record manifest for the Orc "Witnessed" variety tranche -- the five-beat
mirror of the proven Argonian variety set, design-locked into the Orc race sheet
on 2026-06-12. It follows the Bosmer manifest pattern
(`PDV_BosmerVariety_RecordBatch.manifest.json`) but is written as a Markdown prep
artifact, not the live JSON batch manifest, because the Orc tranche is in a mixed
state: several records were already authored in the 2026-06-14 build pass while
the rite menu, the strongholds FormList, and most of the runtime layer remain
unbuilt. The first job of this document is to make that "what exists vs what is
missing" boundary explicit so a later author pass does not duplicate live records.

The locked design surfaces five beats (roadmap levers L1-L5):

- L1 -- The Watcher's regard (rare Malacath observation lines, all modes)
- L2 -- Self-made community (cell-keyed Hearth-Held, City + Legion/Exile)
- L3 -- The Code Holds (below-20%-health survival signature, all modes)
- L4 -- The Four Holds of the Code (four-stronghold pilgrimage)
- L5 -- Trial of Iron (forge-sited one-active discipline rite)

---

## Reconciliation: What Already Exists vs What Is Missing

This is the most important section of the draft. Unlike the Bosmer tranche (which
was a clean batch), the Orc tranche was PARTIALLY built in the 2026-06-14 pass.
`PDV_NextBuildPass_RecordSpec.md` sec. 3 and `PDV_OrcRewardRecords.spec.json`
(`status`: "Witnessed first record tranche plus Four Holds route/messages added
2026-06-14") confirm the following.

### AUTHORED + readback-clean (2026-06-14) -- DO NOT re-author

| Beat | Records that already exist on the live ESP |
|---|---|
| L5 Trial of Iron (discipline spells) | `PDV_SPEL_Orc_TrialOfIron_Tusk` (+ `PDV_MGEF_Orc_TrialOfIron_Tusk_Unarmed`), `_Shield` (+ `_Shield_Armor`), `_Hammer` (+ `_Hammer_Smithing`), `_Yoke` (+ `_Yoke_CarryWeight`) |
| L3 The Code Holds | `PDV_SPEL_OrcCodeHolds` (+ `PDV_MGEF_OrcCodeHolds_HealRate`), `PDV_SPEL_OrcCodeHolds_Devoted` (+ `PDV_MGEF_OrcCodeHolds_Devoted_HealRate`) |
| L2 Hearth-Held (buff + notices) | `PDV_SPEL_OrcHearthHeld` (+ `PDV_MGEF_OrcHearthHeld_StaminaRate`), `PDV_Notif_Orc_HearthHeld_Declare` / `_Return` / `_MissedCadence` |
| L1 The Watchers (notices) | `PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold` / `_City` / `_LegionExile` |
| L4 Four Holds (notices + milestone + route) | `PDV_Notif_Orc_FourHolds_DushnikhYal` / `_MorKhazgur` / `_Narzulbur` / `_Largashbur`, `PDV_Msg_Orc_FourHolds_Milestone`; route 75 wired through `PDV_EventTypes` / `PDV_EventBus` / `PDV_EventSignalActivator` / `PDV_EventSignalEffect` / `PDV_Deity_Malacath` / `PDV__ManagerQuest.HandleOrcFourHoldsVisit`; QASmoke ACTI/REFR proof surfaces for all four strongholds readback-clean |

These records are wired on `PDV__ManagerQuest` and are readback-clean. They are
listed here only so an author pass does not recreate them. Their shipped
magnitudes are carried in the beat tables below marked AUTHORED.

### MISSING -- the real remaining authoring work

| Gap | Type | Beat | Note |
|---|---|---|---|
| Trial of Iron rite-menu MESG | MESG | L5 | No 4-choice rite menu record exists. Bosmer shipped `PDV_MESG_BosmerNaming` for this; Orc has the four discipline spells but no menu to pick them from. PROPOSED below. |
| Strongholds FormList | FLST | L4 | Four Holds currently uses a StorageUtil one-shot tracker + event route, not a FormList (per the 2026-06-14 route note). A FLST is OPTIONAL; recorded below as a decision, not a required record. |
| Manager runtime: Trial of Iron / The Watchers / Hearth-Held behavior | Papyrus | L5/L1/L2 | `PDV_NextBuildPass_RecordSpec.md` Open: "Trial-of-Iron/Watchers/Hearth-Held manager behavior remain deferred." Only `HandleOrcFourHoldsVisit` exists. |
| Final-world stronghold emitters | Papyrus / placement | L4 | Open: "final-world `ChangeLocation`/placement emitters for the four strongholds" -- route is proven only via QASmoke, not organic arrival. |
| Hearth-Held cell restriction | Papyrus | L2 | Open: "Hearth-Held runtime cell restriction (forges+strongholds only vs any home/inn)" is an unresolved design decision. |
| Code Holds runtime/manual proof | proof | L3 | Records closed, but "runtime/manual proof of the combat-end survival payout remains pending." |
| DebugSeedOrc SetPQV harness | Papyrus (debug MCM) | all | No `DebugSeedOrc` seeder exists (Bosmer shipped `DebugSeedBosmer`). Needed for the beta packet's life-mode/coherence-gated phases. |

---

## Locked Spine This Tranche Hangs Off (reused, do not re-author)

- State track: `PDV_StateTrack_OrcLifeMode` (mirror `PDV_GLO_OrcLifeMode`),
  exposed in script as `PDV_State_OrcLifeMode`.
- Life-mode enum (NOTE the value order; the race-sheet prose lists modes in a
  different display order than the enum):
  **City = 0, Stronghold = 1, LegionExile = 2** (from
  `PDV_OrcRewardRecords.spec.json` `stateSurfaces.enum`). Any script gate must
  use these values, not the prose order.
- Spine deity: `PDV_Deity_Malacath` (the one religious spine; R5). No side gods.
- Mode ceiling rate multipliers (LOCKED, ProcessDawn pre-clamp): Stronghold
  x1.00, City x0.75, LegionExile x0.60. Tranche piety pulses ride these, so the
  same act yields less in City/Exile by design.
- Three-day soft-switch lockout after a mode change (StateTrack evidence-gate
  pattern): the rite/coherence fade must respect it.

---

## Record Manifest by Beat

Magnitudes shown are PROVISIONAL. Rows marked AUTHORED reflect the shipped
record's current value (for reference only). Rows marked PROPOSED have no record
yet.

### L1 -- The Watcher's regard (all modes)

| Field | Value |
|---|---|
| Proposed EditorIDs | `PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold` / `_City` / `_LegionExile` -- **AUTHORED** |
| Record type | MESG (notification kind) x3 |
| Gameplay shape | Trigger: qualifying mode-coded conduct on existing signal routes. Gate: `PDV_State_OrcLifeMode` (mode-split text). Cap: 1/dawn. Fade: n/a (one-shot line). |
| Provisional magnitude | None -- notice only, NO piety (locked: silence is the neglect texture, so lines stay rare). |
| Surfacing / copy hook | Top-left notice. Shipped bodies: Stronghold "The stronghold saw the work. Malacath saw why it mattered."; City "No chief named it. Malacath counted it anyway."; LegionExile "The road was foreign. The code still crossed it with you." |
| Anti-farm cap | 1/dawn day-key guard (encode day+1 per the StorageUtil zero-default lesson). |
| Author tool / Papyrus hook | Records exist. MISSING: manager runtime to SELECT the mode-split line and enforce the 1/dawn cap after qualifying conduct. New StorageUtil key: `PDV.OrcWatch.LastDay`. |

### L2 -- Self-made community / Hearth-Held (City + Legion/Exile)

| Field | Value |
|---|---|
| Proposed EditorIDs | Buff: `PDV_SPEL_OrcHearthHeld` (+ `PDV_MGEF_OrcHearthHeld_StaminaRate`) -- **AUTHORED**. Notices: `PDV_Notif_Orc_HearthHeld_Declare` / `_Return` / `_MissedCadence` -- **AUTHORED**. Declaration prompt: `PDV_MESG_Orc_MarkHearth` -- **PROPOSED** (mirror `PDV_MESG_BosmerMarkHearth`). |
| Record type | SPEL+MGEF (timed buff) + 3 MESG notices + 1 MESG declaration prompt (proposed). |
| Gameplay shape | Trigger: declaration prompted at sleep-stop in an ownable cell ("This place is mine to keep"); invested return = sleep there after a day with a qualifying quality-craft or completed-service act. Gate: City (0) or LegionExile (2) only. Cap: 3 invested returns then the wake grants Hearth-Held. Fade: timed buff (no dawn fade). |
| Provisional magnitude | AUTHORED buff: StaminaRateMult +5.0 for 600s. (Race sheet says "small health-regen pulse"; the shipped record is a Stamina-regen pulse -- flag this mismatch to the row review.) Roadmap "3 invested returns" vs RecordSpec "3 invested returns in 30 days" -- cadence window PROVISIONAL. |
| Surfacing / copy hook | Declare/Return/MissedCadence notices (shipped). City presentation = belonging built; Legion/Exile = burden returned from (locked phrasing -- the notice bodies should read mode-split, currently single-voiced). |
| Anti-farm cap | Investment delta, NOT sleep count (locked: "repeated visits alone never qualify"). Cell-keyed via parent cell at sleep-stop (GetFurnitureReference is None at OnSleepStart; cell is the reliable key -- Argonian/Bosmer precedent). |
| Author tool / Papyrus hook | Records mostly exist. MISSING: `PDV_MESG_Orc_MarkHearth` declaration record; manager runtime (declaration, invested-return counting, qualifying-act gate, cell restriction decision); StorageUtil keys `PDV.OrcHearth.DeclaredCell`, `PDV.OrcHearth.InvestedReturns`, `PDV.OrcHearth.DeclineDay`, `PDV.OrcHearth.QualifyingActToday`. OPEN DESIGN: forges+strongholds-only vs any ownable cell. |

### L3 -- The Code Holds (signature, all modes, once/day)

| Field | Value |
|---|---|
| Proposed EditorIDs | `PDV_SPEL_OrcCodeHolds` (+ `PDV_MGEF_OrcCodeHolds_HealRate`), `PDV_SPEL_OrcCodeHolds_Devoted` (+ `PDV_MGEF_OrcCodeHolds_Devoted_HealRate`) -- **AUTHORED** |
| Record type | SPEL+MGEF (timed self-cast) x2 (tier-split). |
| Gameplay shape | Trigger: surviving a fight after dropping below 20% health without leaving the cell. Gate: all modes (Quiet in City/Legion, Noted in stronghold context). Cap: once per combat. Fade: timed buff. |
| Provisional magnitude | AUTHORED: Observant/Faithful HealRate +2.0 / 10s; Devoted HealRate +3.0 / 10s (race sheet/RecordSpec also promise +30 stamina restore on the Devoted tier -- NOT present in the shipped Devoted MGEF; flag to row review). Piety +0.5 Malacath/combat (PROVISIONAL). |
| Surfacing / copy hook | Quiet (effect only). Shipped text: "You dropped near death and held the code. Health returns..." Distinct from the Stronghold Champion fury (which stays a Champion moment). |
| Anti-farm cap | Once per combat (combat-session keyed, not day-keyed). |
| Author tool / Papyrus hook | Records exist. Shares the below-20%-health hook with Bosmer Baan Dar Gap and Argonian Sithis T3 via the `PDV_PlayerEvents` combat-session poll (LIVE/readback-clean 2026-06-14). MISSING: runtime/manual proof of the combat-end survival payout (records closed, payout unproven). |

### L4 -- The Four Holds of the Code (pilgrimage)

| Field | Value |
|---|---|
| Proposed EditorIDs | `PDV_Notif_Orc_FourHolds_DushnikhYal` / `_MorKhazgur` / `_Narzulbur` / `_Largashbur`, `PDV_Msg_Orc_FourHolds_Milestone` -- **AUTHORED**. Optional FLST: `PDV_FLST_OrcFourHolds` -- **PROPOSED (likely NOT needed)**. |
| Record type | 4 MESG notices + 1 MESG messageBox milestone. Tracker = StorageUtil one-shot keys + event route 75 (NOT a FLST, per the 2026-06-14 route decision). |
| Gameplay shape | Trigger: first arrival at each of the four strongholds (Dushnikh Yal, Mor Khazgur, Narzulbur, Largashbur). Gate: location-based, fires on the LOCATION not on friendly entry (Largashbur is hostile pre-`The Cursed Tribe`). Cap: one-shot forever per hold; milestone at all four. Fade: n/a. |
| Provisional magnitude | +1.0 Malacath piety per first arrival (PROVISIONAL); milestone = MessageBox, no extra piety stated. |
| Surfacing / copy hook | Per-hold notice + all-holds milestone MessageBox (shipped bodies in spec). |
| Anti-farm cap | FormID-keyed one-shot forever (Waters-That-Remember pattern). StorageUtil keys `PDV.OrcHolds.Seen.<FormID>`, `PDV.OrcHolds.Count`, `PDV.OrcHolds.Milestone`. |
| Author tool / Papyrus hook | Records + route + `HandleOrcFourHoldsVisit` + QASmoke proof surfaces exist (readback-clean). MISSING: final-world `ChangeLocation`/placement emitters so the route fires on organic arrival (currently QASmoke-only). NOTE on `coc`: location-change triggers do not fire on `coc`; walk/fast-travel in. |

### L5 -- Trial of Iron (rite)

| Field | Value |
|---|---|
| Proposed EditorIDs | Discipline spells: `PDV_SPEL_Orc_TrialOfIron_Tusk` / `_Shield` / `_Hammer` / `_Yoke` (+ matching MGEFs) -- **AUTHORED**. Rite menu: `PDV_MESG_Orc_TrialOfIron` -- **PROPOSED (MISSING)** (mirror `PDV_MESG_BosmerNaming`). |
| Record type | 4 SPEL+MGEF ability spells (one-active) + 1 MESG rite menu (proposed). |
| Gameplay shape | Trigger: rite at a forge inside the declared community place or any stronghold. Gate: forge-sited; 7-day cooldown; "Not yet" does NOT spend the cooldown. Cap: one active at a time, swap is clear-before-add. Fade: fades at dawn if mode standing collapses (sustained oath-breaking); returns automatically at dawn on recovery (Hist-Adaptations / Naming contract). |
| Provisional magnitude | AUTHORED: Tusk UnarmedDamage +5.0, Shield DamageResist (armor) +5.0, Hammer Smithing +5.0, Yoke CarryWeight +15.0. +0.5 Malacath piety per switch (PROVISIONAL). |
| Surfacing / copy hook | Per-discipline confirmation text (shipped, e.g. "You chose the tusk in the Trial of Iron. Unarmed damage rises by 5."). Rite-menu body must list the four disciplines (effects go in the BODY, not the buttons -- Skyrim lays buttons in one horizontal row). |
| Anti-farm cap | 7-day cooldown (game-time delta, not spent on "Not yet"). One-active swap prevents stacking. |
| Author tool / Papyrus hook | Discipline spells exist. MISSING: `PDV_MESG_Orc_TrialOfIron` menu record; manager runtime (`ApplyOrcTrialOfIron` clear-before-add, `SyncOrcTrialOfIron` dawn fade/restore on mode-standing collapse, forge-site detection, 7-day cooldown). StorageUtil keys `PDV.OrcTrial.Active`, `PDV.OrcTrial.ModeAtRite`, `PDV.OrcTrial.LastRiteTime`. |

---

## Proposed New Records Summary (the actual gap to author)

| EditorID | Type | Beat | State |
|---|---|---|---|
| `PDV_MESG_Orc_TrialOfIron` | MESG (4 disciplines + "Not yet") | L5 | PROPOSED -- missing |
| `PDV_MESG_Orc_MarkHearth` | MESG (declare / "Not yet") | L2 | PROPOSED -- missing |
| `PDV_FLST_OrcFourHolds` | FLST | L4 | PROPOSED -- likely NOT needed (route uses StorageUtil one-shot tracker; decide before authoring) |

Everything else in the five beats is already authored and readback-clean; the
balance of the remaining work is the Papyrus runtime layer and the final-world
emitters, not new records.

---

## Manager Runtime Layer (Papyrus) -- to author, mirror the Bosmer handoff

Model on `PDV_BosmerVariety_PapyrusHandoff.md` (property decls + call-site
insertions + functions, all origin/mode-guarded and None-guarded so they stay
inert until records bind). Confirmed live handler today: only
`HandleOrcFourHoldsVisit`.

| Function (proposed) | Beat | Mirrors |
|---|---|---|
| `HandleOrcSleepEvents` (dispatcher) | L2/L5 | `HandleBosmerSleepEvents` |
| `TryOrcHearthSleep` | L2 | `TryBosmerHearthSleep` |
| `TryOrcTrialOfIron` + `ApplyOrcTrialOfIron` + `GetOrcTrialSpell` + `RemoveOrcTrialSpells` | L5 | `TryBosmerNaming` / `ApplyBosmerNaming` / `GetBosmerNamingSpell` / `RemoveBosmerNamingSpells` |
| `SyncOrcTrialOfIron` (dawn fade/restore) | L5 | `SyncBosmerNaming` |
| `TryOrcWatcherLine` (1/dawn, mode-split) | L1 | (new -- texture on existing signal routes) |
| `TryOrcCodeHolds` (combat-session payout) | L3 | shared below-20% poll (`PDV_PlayerEvents` + `PDV_EventBus`) |
| `HandleOrcFourHoldsVisit` | L4 | **EXISTS** (route 75) |
| `DebugSeedOrc` (set life mode, clear cooldowns, seed investment) | all | `DebugSeedBosmer` (use `SetState`, NOT `ForceState` -- the Bosmer setter-name correction) |

Dawn-sync wiring: add `SyncOrcTrialOfIron(...)` and the Watcher-arming call to the
existing Orc block in `RunDawnRefreshTrackStates()`, alongside the life-mode
fade/restore. The combat signature and any location hook route through
`PDV_PlayerEvents` / `PDV_ActionRouter` / `PDV_EventBus` per the variety-tranche
hook architecture lesson (the Bosmer location hook landed in
`PDV_ActionRouter.HandleStoryChangeLocation`, NOT `PDV_PlayerEvents`, despite the
draft handoff assuming otherwise -- expect the same for Orc Four Holds emitters).

---

## Dependencies / Blocked-On

1. **Row review gate (HARD BLOCK).** The Orc row in
   `PDV_RaceEffectReviewLedger.md` is `pending`. Per `PDV_STANDARDS.md` and the
   ManualEvidenceLedger convention, no race-level magnitude is approved until the
   per-race row review signs off. All PROVISIONAL values above are blocked on
   this. Do NOT author the proposed records or re-tune the shipped ones until the
   review lands.
2. **Two design mismatches to surface to the row review (found during this
   reconciliation):**
   - Hearth-Held: race sheet says "small health-regen pulse"; the shipped
     `PDV_MGEF_OrcHearthHeld_StaminaRate` is a Stamina-regen pulse. Decide which
     is canonical before runtime wiring.
   - Code Holds Devoted: race sheet / RecordSpec promise "+30 stamina restore" on
     the Devoted tier; the shipped `PDV_MGEF_OrcCodeHolds_Devoted_HealRate` has
     only the HealRate +3 effect. Decide whether to add the stamina effect.
3. **Life-mode enum value order.** Gates must use City=0 / Stronghold=1 /
   LegionExile=2 (spec enum), NOT the prose display order in the race sheet. A
   wrong index silently misroutes mode-split text and the City/Exile gate (the
   startup-choice index-equals-value lesson generalizes here).
4. **Hearth-Held cell restriction is an OPEN design decision** (forges +
   strongholds only vs any ownable cell). Blocks the L2 declaration/runtime.
5. **Four Holds FLST vs one-shot tracker.** The 2026-06-14 build chose a
   StorageUtil one-shot tracker + route 75 over a FLST. `PDV_FLST_OrcFourHolds`
   is listed PROPOSED but is likely unnecessary; confirm the tracker is the
   canonical mechanism before authoring any FLST (avoids a FormList index/order
   drift surface that does not need to exist).
6. **Final-world emitters needed (NOT just records).** Four Holds is proven only
   via QASmoke; organic `ChangeLocation`/placement emitters for the four
   strongholds are unbuilt. Route proof is not arrival proof.
7. **Author vehicle.** No `tools/pdv-orc-variety-author` exists (confirmed: Glob
   `pdv-orc-variety*` returns nothing). The Bosmer precedent built
   `tools/pdv-bosmer-variety-author` from the Argonian author. Because most Orc
   records already exist via `PDV_OrcRewardRecords.spec.json` and the Phase 20
   reward author, a NEW narrow author tool may only be needed for the two/three
   proposed records (`PDV_MESG_Orc_TrialOfIron`, `PDV_MESG_Orc_MarkHearth`,
   optional FLST) plus the VMAD forward-wiring of any new manager properties.
   Decide: extend the existing Orc reward author vs. a new variety author.
8. **FormID verification.** The four stronghold LCTNs and the QASmoke ACTI/REFR
   proof surfaces are already readback-clean; no new FormID resolution is needed
   for the existing records. Any new FLST entries (if the FLST decision flips)
   would need houseCARL FormID verification before a real write, fail-closed on
   unverified slots (FormList index/order-drift lesson).
9. **ESP lock.** Any future write requires Skyrim/CK to release `Devotion.esp`
   (houseCARL ESP-lock workaround applies if Mutagen overlay holds it).
10. **Proof boundary.** Records readback-clean is machine proof only. Runtime
    route proof, manual in-game proof, and final-world placement are separate
    buckets (proof-boundary discipline). The Code Holds payout, Trial of Iron
    rite, Hearth-Held cadence, Watcher cadence, and organic Four Holds arrival
    all remain runtime/manually UNPROVEN.

---

## Build Order (when unblocked) -- mirror the Argonian/Bosmer path

1. Land the row review; freeze magnitudes (or confirm the shipped ones).
2. Resolve the two design mismatches (Hearth-Held AV; Code Holds Devoted stamina).
3. Author the missing records (`PDV_MESG_Orc_TrialOfIron`, `PDV_MESG_Orc_MarkHearth`,
   FLST only if the decision flips) + forward-wire any new VMAD manager properties.
4. Apply the `PDV__ManagerQuest.psc` Orc runtime layer (Trial/Watchers/Hearth-Held
   + `DebugSeedOrc`) and the final-world Four Holds emitters; recompile via
   `tools/pdv_compile.mjs` (0/0); `tools/pdv_verify.mjs` (FAIL=0).
5. Fresh-save smoke per beat (VMAD props bake at first init): seed with
   `DebugSeedOrc <mode>`; confirm mode-gating, 1/dawn Watcher cap, 3-investment
   Hearth-Held, once-per-combat Code Holds, 7-day Trial cooldown + dawn
   fade/restore on mode collapse, one-shot Four Holds arrival.
6. Extend `PDV_BetaTestPacket_Orc.md` with the variety checklist + the seeder
   harness; add BetaContract rows + run `pdv_completeness_audit.mjs`; doc-sync
   AGENTS.md + the roadmap Build status line.

---

## Notes Carried Forward

- Forward note (Resolved Decision 5): if a true `PDV_SacredPlace` system is ever
  built, the cell-keyed Hearth-Held mechanic migrates into it -- carry this note
  in whatever live Orc record-batch manifest supersedes this draft (Hist-fold
  style).
- The Watcher lines stay rare BY DESIGN -- silence is the neglect texture. Do not
  tune the cadence up to "feel rewarding"; that would erase the intended quiet.
- All player-facing text ASCII-only; mode-split copy must keep the locked
  framing (City = belonging built; Legion/Exile = burden returned from).