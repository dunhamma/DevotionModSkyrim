# PDV Variety Manifest -- Bosmer "The Story Goes On" (DRAFT)

**Status:** DRAFT (no-deploy prep). Nothing in this file deploys, authors records, edits the live ESP, or changes any .psc/.pex. It is a planning artifact only.
**Created:** 2026-06-19
**Provenance:** Read and reconciled from `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` (Bosmer section + Resolved Decisions), `race-sheets/PDV_RaceDesign_Bosmer.md` (section "Variety Tranche -- The Story Goes On", DESIGN-LOCKED 2026-06-12), `references/authoring/PDV_RaceEffectReviewLedger.md` (Variety Tranche Gate + Bosmer race-review row), `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json`, `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md`, `references/authoring/PDV_SessionHandoff_BosmerVarietyLocal.md`, and `tools/pdv-bosmer-variety-author/Program.cs` (for the as-coded magnitudes).

---

## PROVISIONAL MAGNITUDES -- DO NOT AUTHOR UNTIL ROW REVIEW

> All magnitudes, durations, and effect ActorValues in this manifest are PROVISIONAL.
> The Bosmer row in `PDV_RaceEffectReviewLedger.md` is still **Pending** (Variety
> Tranche Gate, 2026-06-12). That gate locks shapes, gates, caps, and fade rules
> ONLY -- every magnitude must pass the race-row review before it is treated as
> final. Do not treat any number below as committed. The locked design intent is
> the constraint; the numbers are sketches that satisfy it.
>
> Tranche budget shape that MUST hold (any drift is a budget change requiring
> re-review): pilgrimage pulses are one-shot, signatures are once/day
> 10-minute-class pulses, the rite effect is one-active with dawn fade/restore,
> and NO new always-on boon family is added. The two-family hybrid boon budget
> stays untouched.

---

## Reconciliation -- what already exists vs what this draft adds

This tranche is **not greenfield**. A prior local Windows session
(2026-06-12) already drafted the record contract, built the author tool, and
wrote a paste-in Papyrus layer. This DRAFT manifest does not duplicate that
work; it consolidates it into one record-author view and flags the gaps and the
one magnitude drift it found.

| Artifact | Path | State as read |
|---|---|---|
| Record contract (authoritative for IDs/text) | `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json` | Records WRITTEN to `Devotion.esp` + VMAD forward-wired; `--check` PASS, `pdv_verify` FAIL=0 (per its own `status` field). All 6 Songs LCTN FormIDs resolved. |
| Author tool | `tools/pdv-bosmer-variety-author/` | Built (0/0), `--dry-run`/`--check` PASS. `bin/`+`obj/` present (untracked). |
| Papyrus runtime layer | `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md` | Paste-in spec; per the RecordBatch `status` it was APPLIED + compiled 0/0 into the canonical `PDV__ManagerQuest.psc` / `PDV_ActionRouter` / `PDV_PlayerEvents`. |
| Effect-review gate | `PDV_RaceEffectReviewLedger.md` Bosmer row | **Pending** -- magnitudes not yet row-reviewed. |
| Runtime proof | `PDV_BetaTestPacket_Bosmer.md` single-session smoke | **PENDING** -- roadmap Build-status line (2026-06-13) holds Bosmer **NOT runtime-proven** until the fresh-save smoke returns PASS. |

**Net for this DRAFT:** the records and script layer are effectively authored
already; what is genuinely *missing/open* is (1) effect-review row sign-off on
the provisional magnitudes, (2) the in-game fresh-save smoke, and (3) the one
magnitude drift called out below. Treat the RecordBatch manifest as the
source of truth for any EditorID/player-text edit; treat this file as the
planning/cross-check view.

---

## Path-gating key (enforced in the manager script, NOT in records)

`PDV_State_BosmerPath` / `PDV_BosmerPathTrack`: OldContract=0, LivingStory=1,
Exchange=2, BanditRoad=3. Player origin index `ORIGIN_BOSMER=4`. Old Contract
intentionally receives only Green Dreams and the all-path Naming -- it is
already the richest path and gets no new signature.

---

## Record manifest by tranche beat

Magnitudes shown are the **as-coded provisional** values from
`tools/pdv-bosmer-variety-author/Program.cs` unless a drift note says
otherwise. "Type" SPEL+MGEF means one Spell plus its backing Magic Effect
(and, for timed buffs, a presentation MGEF in the Rooted-Rest pattern).

### L1 -- Green Dreams (all paths)

| Field | Value |
|---|---|
| Proposed EditorID | (none -- no record) |
| Record type | Script-only; no MGEF/SPEL/MESG/FLST |
| Gameplay shape | Trigger: sleep-stop. Gate: `ORIGIN_BOSMER`, path-keyed text (Old Contract also GPC-band-keyed). Cap: 2-day floor, ~10% base / ~60% armed the night after a path change. Fade: n/a (flavor only) |
| Provisional magnitude | None -- pure top-left text, no piety, no AV change (PROVISIONAL: dream chance 10%/60%, 2-day floor) |
| Surfacing / copy hook | `Debug.Notification` top-left lines via `GetBosmerDreamText(pathState)`; a shown MESG that night suppresses the dream so a menu + toast never stack |
| Anti-farm cap | 2-day floor on `PDV.BosDream.LastDay`; armed flag consumed on fire |
| Author-tool / Papyrus hook | No author-tool record. Papyrus: `TryBosmerPathDream`, `GetBosmerDreamText`, `ArmBosmerDreamOnPathChange` + sleep-dispatch (2a) and dawn-arm (2b) call sites |

### L2 -- Hearth of the Telling (Living Story only)

| Field | Value |
|---|---|
| Proposed EditorID (declare prompt) | `PDV_MESG_BosmerMarkHearth` (MESG) |
| Proposed EditorID (reward buff) | `PDV_SPEL_BosmerTaleCarried` (+ backing MGEF) |
| Record type | MESG (2-button) + SPEL+MGEF (timed self-buff, Rooted-Rest family) |
| Gameplay shape | Trigger: sleep-stop in a cell. Gate: path == LivingStory. Declaration is cell-keyed (parent cell at sleep-stop; `GetFurnitureReference` is None at sleep-start). Reward fires on return-sleep in the declared cell after 3+ new locations discovered since last stay. Fade: timed buff expiry |
| Provisional magnitude | `A Tale Carried` = Speech **+5**, **600s** (10 min). PROVISIONAL |
| Surfacing / copy hook | MESG body "Make this hearth the place your stories come home to?..."; buttons `["Yes, this hearth is mine","Not yet"]`. Buff text "You told the tale, and the telling settled..."; `Debug.Notification` on cast |
| Anti-farm cap | Declaration: button-index-0 declares, decline re-prompts only after 3 in-game days (`PDV.BosHearth.DeclineDay`, day+1 encoded). Reward: location-discovery delta >= 3 since last stay (NOT sleep count) |
| Author-tool / Papyrus hook | `pdv-bosmer-variety-author` (MESG + SPEL+MGEF). Papyrus: `TryBosmerHearthSleep`, sleep dispatch (2a), location-discovery counter inside `HandleBosmerLocationChange` (2d), `HandleBosmerLivingStoryCommunityKept` for the piety route |

### L3a -- Scales at Rest (Exchange signature, once/day)

| Field | Value |
|---|---|
| Proposed EditorID | `PDV_SPEL_BosmerScalesAtRest` (+ backing MGEF) |
| Record type | SPEL+MGEF (timed self-buff) |
| Gameplay shape | Trigger: completing any favor/bounty/contract quest (fires from `HandleBosmerExchangeSignal`). Gate: path == Exchange. Cap: once/day. Fade: timed expiry |
| Provisional magnitude | Speech **+10**, **120s**. PROVISIONAL (note: race sheet calls this "a brief barter pulse"; implemented on Speech because vanilla prices are Speech-governed, no separate barter AV) |
| Surfacing / copy hook | Quiet surfacing -- `Debug.Notification` "The account is even. The bargains fall your way for a while." Buff text "The account is even. For a while, every bargain falls a little your way." |
| Anti-farm cap | `PDV.BosSig.ScalesLastDay == today+1` once/day guard (day+1 encoded so day 0 is not self-suppressed) |
| Author-tool / Papyrus hook | `pdv-bosmer-variety-author` (SPEL+MGEF). Papyrus: `TryBosmerScalesAtRest` + Exchange call site (2c) |

### L3b -- Baan Dar Opens the Gap (Bandit Road signature, once/day)

| Field | Value |
|---|---|
| Proposed EditorID | `PDV_SPEL_BosmerBaanDarGap` (+ backing MGEF; plus a no-magnitude watcher MGEF in the author tool's gap-spell shape) |
| Record type | SPEL+MGEF (timed self-buff) |
| Gameplay shape | Trigger: player health drops below 20% in combat (via the shared Khajiit/Bosmer combat-session poll in `PDV_PlayerEvents`, routed through `PDV_EventBus.RouteBosmerBaanDarGap` -- the flaky direct `OnHitEx` low-health route was deliberately replaced). Gate: path == BanditRoad, `IsInCombat`. Cap: once/day. Fade: timed expiry |
| Provisional magnitude | **DRIFT -- needs row-review decision.** Author tool + RecordBatch manifest: SpeedMult **+40**, **15s**. Race sheet + Papyrus handoff lever map: "~5s movement burst" (handoff table reads "+30, 5s"). The authored record currently is +40/15s. PROVISIONAL and **inconsistent across docs** -- resolve at row review before it is treated as final |
| Surfacing / copy hook | Quiet surfacing -- `Debug.Notification` "Baan Dar opens the gap. Run." Buff text identical |
| Anti-farm cap | `PDV.BosSig.GapLastDay == today+1` once/day guard. Deliberately distinct from the weekly Champion luck moment (which stays rare per the locked sheet) |
| Author-tool / Papyrus hook | `pdv-bosmer-variety-author` (SPEL+MGEF, gap-spell shape). Papyrus: `TryBosmerBaanDarGap` (manager) called from the external `PDV_PlayerEvents` combat-session poll (2e); expected markers `Baan Dar combat session opened for origin 4.`, `Bosmer Baan Dar gap detected (combat_poll).`, `Bosmer Baan Dar Opens the Gap fired.` |

### L4 -- Songs of the Green (all paths)

| Field | Value |
|---|---|
| Proposed EditorID | `PDV_FLST_BosmerGreenSongs` (FLST, 6 entries) |
| Record type | FormList of 6 vanilla LCTNs (no new MGEF/SPEL; reward is a small piety pulse + vision MessageBox routed in script) |
| Gameplay shape | Trigger: first arrival at each curated green LCTN (location-change entry; Eldergleam is held for an OnUpdate interior poll on the cave cells, mirroring the Argonian Waters set). Reward: one vision line + small Y'ffre/path pulse per site; milestone MessageBox at all six. Fade: n/a (one-shot forever) |
| Provisional magnitude | Per-site "small path-keyed piety" routed through `HandleBosmerPactPositiveSignal("green_song")` -- magnitude inherited from the active path's living-world signal (PROVISIONAL; no dedicated green-song signal authored). Locked set: Gildergreen (via `WhiterunTempleofKynarethLocation` anchor, the Wind-District swap), Kynesgrove grove, Eldergleam Sanctuary (shared with Argonian Waters), Evergreen Grove, Clearspring Tarn, Autumnshade Clearing |
| Surfacing / copy hook | `Debug.MessageBox` vision line per site + milestone MessageBox; first-arrival only |
| Anti-farm cap | One-shot per site forever (`PDV.BosSongs.Seen.<FormID>`); milestone fires once at count >= list size |
| Author-tool / Papyrus hook | `pdv-bosmer-variety-author` (FLST, fail-closed on any `verified=false` slot -- all 6 now resolved). Papyrus: `HandleBosmerLocationChange` (location entry 2d), `TryBosmerEldergleamInterior` (OnUpdate poll 2f, shared cave cells 0x3A9EC/0x3A9E0/0x3A9E3, LCTN 0x000192AC), `AwardBosmerSong` |

### L5 -- The Naming (rite, all paths)

| Field | Value |
|---|---|
| Proposed EditorID (rite menu) | `PDV_MESG_BosmerNaming` (MESG, 5-button) |
| Proposed EditorIDs (told-selves) | `PDV_SPEL_BosmerNaming_Hunter`, `_Speaker`, `_Wanderer`, `_Keeper` (each SPEL+MGEF ability) |
| Record type | MESG (5-button) + 4 x SPEL+MGEF ability (constant-effect, one active at a time) |
| Gameplay shape | Trigger: sleep at the declared hearth or any Songs site. Gate: 7-day cooldown; "Not yet" does NOT spend the cooldown. One-active told-self; choosing again swaps (clear-before-add). Fade: at dawn on path-coherence break (path switch, or Apostate GPC band < 20 while Old Contract); returns automatically at dawn on recovery |
| Provisional magnitude | Hunter = Archery **+5**; Speaker = Speech **+5**; Wanderer = StaminaRateMult **+8** (8%); Keeper = CarryWeight **+15**. PROVISIONAL. (Reconciliation: Keeper was sketched "+5% barter" in the design but ships as CarryWeight because vanilla prices are Speech-governed -- already Speaker; race sheet + manifest + tool are in sync on this.) |
| Surfacing / copy hook | MESG body lists all four told-selves (effects live in the BODY, not the buttons -- Skyrim lays buttons in one horizontal row); buttons `["Hunter","Speaker","Wanderer","Keeper","Not yet"]`. Fade/restore lines via `Debug.Notification` ("The told-self goes quiet..." / "You are yourself again...") |
| Anti-farm cap | 7-day cooldown on `PDV.BosNaming.LastRiteTime` (game-time days); decline (button 4) does not spend it |
| Author-tool / Papyrus hook | `pdv-bosmer-variety-author` (MESG + 4 SPEL+MGEF ability). Papyrus: `TryBosmerNaming`, `ApplyBosmerNaming`, `RemoveBosmerNamingSpells`, `GetBosmerNamingSpell`, `SyncBosmerNaming`, `IsBosmerNamingCoherent` + sleep dispatch (2a) and dawn sync (2b) |

---

## VMAD wiring (manager properties to bind)

Forward-wired on `PDV__ManagerQuest` by the author tool (10 properties). Names
match the Papyrus Step-1 declarations exactly so they resolve:

`PDV_MESG_BosmerMarkHearth`, `PDV_SPEL_BosmerTaleCarried`,
`PDV_SPEL_BosmerScalesAtRest`, `PDV_SPEL_BosmerBaanDarGap`,
`PDV_MESG_BosmerNaming`, `PDV_SPEL_BosmerNaming_Hunter`,
`PDV_SPEL_BosmerNaming_Speaker`, `PDV_SPEL_BosmerNaming_Wanderer`,
`PDV_SPEL_BosmerNaming_Keeper`, `PDV_FLST_BosmerGreenSongs`.

Existing-save note (carried from the RecordBatch manifest): VMAD props bake at
first init, so the test path is a new game / `coc qasmoke`. Existing saves keep
the features silently inert until a lazy `GetFormFromFile` fallback pass adds
the authored FormIDs.

---

## Reserved StorageUtil keys (script state only -- no records)

Dreams: `PDV.BosDream.LastDay`, `PDV.BosDream.LastPath`, `PDV.BosDream.Armed`.
Hearth: `PDV.BosHearth.DeclaredCell`, `PDV.BosHearth.DeclineDay`,
`PDV.BosHearth.DiscoveryAtLastStay`.
Locations: `PDV.BosLoc.Seen.<FormID>`, `PDV.BosLoc.DiscoveryCount`.
Signatures: `PDV.BosSig.ScalesLastDay`, `PDV.BosSig.GapLastDay`.
Songs: `PDV.BosSongs.Seen.<FormID>`, `PDV.BosSongs.Count`,
`PDV.BosSongs.Milestone`, `PDV.BosSongs.EldergleamActive`.
Naming: `PDV.BosNaming.Active` (0=none, 1-4 = Hunter/Speaker/Wanderer/Keeper),
`PDV.BosNaming.PathAtRite`, `PDV.BosNaming.LastRiteTime`.

Day-keys use the day+1 encoding so a day-0 fresh game does not self-suppress
(StorageUtil int day-keys default to 0).

---

## Dependencies / blocked-on

1. **Effect-review row sign-off (BLOCKING for "final" magnitudes).** The
   Bosmer row in `PDV_RaceEffectReviewLedger.md` is **Pending**. Until it is
   reviewed, every magnitude here stays PROVISIONAL. Open review questions on
   that row: which path effects are distinct without four simultaneous reward
   packages, and how Z'en/Baan Dar effects avoid generic kindness/trade/theft
   faucets.
2. **Baan Dar Opens the Gap magnitude drift (BLOCKING -- pick one).** Author
   tool + RecordBatch manifest = SpeedMult +40 / 15s; race sheet + Papyrus
   handoff lever map = "~5s" ("+30, 5s"). The authored record is +40/15s. The
   docs disagree. Resolve at row review and re-sync whichever side is wrong
   (the source-of-truth precedent is: verify which side is authoritative
   before "fixing" -- do not assume the record is wrong).
3. **Fresh-save in-game smoke (BLOCKING for runtime-proven).** Per the roadmap
   Build-status line, Bosmer is NOT runtime-proven until the
   `PDV_BetaTestPacket_Bosmer.md` "Single-Session Smoke (MCM-driven)" returns
   PASS. The shared combat-session cadence for Baan Dar Opens the Gap is the
   flagged real risk. Seeding is MCM-driven (`DebugSeedBosmer <path 0-3>` via
   the debug MCM dev page), not cqf-only.
4. **No FormID verification outstanding.** All 6 Songs LCTN FormIDs are
   resolved and `verified=true` in the RecordBatch manifest
   (Eldergleam 0192AC, Kynesgrove 018A4E, WhiterunTempleofKynareth 01F87D
   [Wind-District swap], EvergreenGrove 019174, ClearspringTarn 019157,
   AutumnshadeClearing 018EE4). Eldergleam interior cells:
   0x3A9EC / 0x3A9E0 / 0x3A9E3.
5. **No author-tool build outstanding.** `tools/pdv-bosmer-variety-author` is
   built and passes `--dry-run`/`--check`. ActorValue enum names
   (Archery/Speech/SpeedMult/StaminaRateMult/CarryWeight) validated clean on
   this Mutagen build -- if a future re-run reports an unknown enum member, fix
   the C# member name only, never the FormIDs or magnitudes.
6. **ESP write lock.** Any real author-tool write needs Skyrim/CK to release
   `Devotion.esp` first (the houseCARL-holds-ESP-lock class of failure).
7. **Papyrus likely-fix carryovers (if the layer is ever re-applied from the
   handoff).** `PDV_BosmerPathTrack.ForceState(...)` setter name in
   `DebugSeedBosmer` (mirror `DebugSetBosmerPathState`; the variety-hook
   precedent is `SetState`, not `ForceState`) and the
   `GetActorValuePercentage("Health")` signature on the local SKSE build.

---

## Closeout gate (after smoke PASS -- not yet done)

Per the session handoff: write/confirm `PDV_BetaTestPacket_Bosmer.md` from
smoke evidence; add BetaContract rows + run `pdv_completeness_audit.mjs`;
flip the roadmap Build-status line (Bosmer -> runtime-proven) and the
RecordBatch manifest `status`; add the AGENTS decisions-log entry; flip the
`PDV_RaceEffectReviewLedger.md` Bosmer row off Pending once magnitudes are
signed off. None of this is performed by this DRAFT.
