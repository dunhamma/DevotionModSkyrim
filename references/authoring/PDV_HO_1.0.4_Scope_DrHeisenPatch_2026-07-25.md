# PDV 1.0.4 Scope — DrHeisen Patch Incorporation (2026-07-25)

Source: "Authoria - Devotions Tweaks and Fixes" by DrHeisen
(`C:\Users\Admin\Downloads\Authoria - Devotions Tweaks and Fixes\`), a 5-pass
audit patch built against Devotion **1.0.2**. Its CHANGELOG maps every change to
audit finding IDs (A1-D7) and fix-plan groups. This doc records what the owner
approved for 1.0.4, what already went into 1.0.3, and what is deferred.

## Standing rule for every port

**Verify-then-port.** Their scripts are 1.0.2-based; our live source has moved
(1.0.3 curse fixes + Azura fix). NEVER copy their `.psc`/`.pex` files. For each
item: reproduce the defect in OUR live source first, then port the fix logic by
hand, then compile + verify. Anything that fails reproduction is dropped and
flagged back to DrHeisen. Their CHANGELOG is the reference for each fix's
reasoning and edge cases — read the relevant section before porting.

## Already folded into 1.0.3 (this session — not 1.0.4 work)

- `Recover` on the 2 PeakValueModifier observance effects (`0715CB`/`0715CD`).
- 4 MESG format-string fixes (`0714E1`/`E2`/`E3` `%s` sentence removed,
  `0714FF` `%%` escape).
- Azura fix at the data layer: CSV actor `azurah` -> `azura` + likes/dislikes
  regen + `LIKES_DISLIKES_VERSION` 16 -> 17 (+ verifier expectation), stances
  dual-check `"Azura" || "Azurah"`.
- CONDITIONAL (gated on in-game sting sign check): flip the ~21
  Detrimental+negative-magnitude self-cancelling pairs.

## 1.0.4 slate — correctness (full, per owner decision)

| ID | Fix | Their pass |
|---|---|---|
| A2 | Seed-once guard in `PDV_Origin` (per-load piety wipe on custom-race fallback); recheck re-detects only. CAUTION: `PDV_Origin.psc` live-ahead-of-git drift — reconcile before editing | Pass 2 §1 |
| B3 | `KickstartIfStalled()` lifecycle watchdog from player alias `OnPlayerLoadGame` (one lost tick currently kills dawn processing forever) | Pass 2 §2 |
| B16 | `StripAllPdvSpells` gaps: Altmer Discipline + Redguard Remember families + NEW `StripAllDaedricPactSpells()` (Malacath SpeedMult survives uninstall) | Pass 2 §3 |
| B4 | `Show() < 0` guards on 5 rites — worst: `EvaluateBosmerForcedReckoning` force-severs the Old Contract pact with no player input | Pass 4 §1 |
| B13 | Day-0 StorageUtil false blocks (shrine-prayer credit, `TryDeclareRestCell`, Dunmer `CandidateDay`) + 26 daily stamps moved to the 06:00 devotional day. Known class: memory `storageutil-day-key-zero-default` | Pass 4 §2 |
| B7 | Peek/commit split on `ScoreRepeatableAction` (caps/cooldowns burned on zeroed awards) | Pass 4 §2.4.3 |
| B14 | Once-per-day charges stamped only after a route lands (shrine effect + 2 signal scripts) | Pass 4 §2.4.4 |
| B12 | Orc Code Holds daily cap (their finding: `Cast()` half of the audit does NOT work — constant-effect ability; toast feedback instead) | Pass 4 §2.4.5 |
| B2 | Thalmor unprovoked-kill consults `IsHostileKill` (self-defense vs patrols mis-punished) | Pass 4 §5.8.1 |
| B8 | `RegisterForHitEventEx` above the matrix early-out (missing matrix JSON silently kills all hit detection) | Pass 4 §5.8.2 |
| B5 | MCM `OnPageReset` clears ALL ~169 `_oid*` (stale oids can hit destructive debug handlers) | Pass 4 §6.9.1 |
| B17 | `SIGNAL_TYPE_MAX` 999 -> 3200 (debug slider reaches all deities) | Pass 4 §6.9.2 |
| D5 | Curse smoke re-syncs the None-keyed `PDV.Curse.State` mirror | Pass 4 §6.9.3 |
| A3 | QR job-key leak: `ClearAllPrefix("PDV.QR.Job.<id>.")` on remove + one-time empty-queue sweep | Pass 4 §7.10.1 |
| D7 | Khajiit pickpocket bus null-guard | Pass 4 §7.10.3 |
| B1 | (done in 1.0.3 at data layer — confirm no script-side remnant needed) | Pass 4 §3.5.1 |
| D2 | AuriEl `ScoreCuratedSignal` returns its DELTA properties, not literals | Pass 4 §3.5.2 |
| B9 | Bard `PDV_BardLastRouteRealTime` cleared on load (real-time stamp survives relaunch, discards performances for hours) | Pass 5 §3 |

## 1.0.4 slate — save repair (MCM buttons ONLY, per owner decision)

- Adopt "Check stat damage" (read-only residue report) + confirm-gated
  "Repair stats" (permanent-modifier zero on the enumerated AVs while no PDV
  ability held, then normal re-sync). NO automatic once-per-save pass.
- Mechanism: PO3 `GetActorValueModifier(player, 0, av)` reads the permanent
  slot. Depends on B16 strip completeness. Requires 1.0.3's Recover flags
  (already shipped) so the re-grant cannot re-bake.
- Adopt their runtime-AV-name table (record enum != runtime name for 8:
  ResistMagic->MagicResist, Speech->Speechcraft, Archery->Marksman,
  ResistFire->FireResist, ResistFrost->FrostResist,
  ResistDisease->DiseaseResist, CriticalChance->CritChance,
  SpeechcraftModifier->SpeechcraftMod). A wrong string silently reads 0.
- Their 33-AV list was derived by querying the ESP's ValueModifier archetypes —
  re-derive against OUR current ESP, don't copy the list.
- Copy caveat verbatim into MCM text: repair also clears third-party permanent
  modifiers on those AVs. Retire the manual console procedure from CHANGELOG
  once shipped.

## 1.0.4 slate — perf (full, per owner decision)

| ID | Fix | Their pass |
|---|---|---|
| C1 | 44-pass string normalizer -> Orkey-only single pass; delete the dead journal-title repair loop; fixes "The Hist" mid-sentence caps | Pass 5 §1 |
| C2 | Faucet form cache (once per load), delete `HasQuestReactionRuntimeForm`; `GetActorRef()` on blocked-hit path | Pass 5 §2 |
| C3 | Bard poll two-state 5s live / 15s idle | Pass 5 §3 |
| C4 | Per-deity participating-event cache in `ScoreFromTable` (fail-open, sealed after rebuild; needs a LIKES_DISLIKES_VERSION bump when it lands) | Pass 5 §4 |
| D1 | `PDV__SM_KillActor` per-kill trace behind debug level (via router's level); + `ProcessDawn` once-per-session latch, `ExportDevotionReport` gate | Pass 5 §6 |
| — | Poll cadences: menu early-out first in `OnUpdate` (re-arm BEFORE the early-out return), reconcile split 10s/30s, context probes 1s->3s. Master poll and worker 0.1s stay | Pass 5 §7 |

## Design calls — RESOLVED 2026-07-26 (owner, grill-me session)

**Governing doctrine: WIRE BY DEFAULT; cut only where nothing was ever
authored, or where the feature demonstrably ships elsewhere.** Verified per
item against the live ESP and live source — not taken from the audit.

### Ships in 1.0.3 (behavior-neutral or bug-fixing)

| Item | Call | Evidence |
|---|---|---|
| SacredPlace subsystem | **CUT** (stub + drop MCM smoke hook; 3 quest records left inert) | Not unwired — **superseded**. All three quests' concepts ship live: `TryArgonianBedOfChoiceSleep` (4 sites), `TryDeclareRestCell` (4), Khajiit road-home (11). Wiring it would give three race lanes two competing home systems. |
| 21 `PDV_Bless_Nord_<god>` props | **CUT** | `PDV_Bless_Nord_Akatosh_*` and siblings **do not exist in the ESP** (0 records). The properties point at nothing — "truly empty" clause. |
| 30 DELTA/substrate knobs | **CUT** | Write-only tuning scalars, no reads, no VMAD bindings. No override cost for us (own source). KEEP AuriEl's two (live as of D2) and the same-named knobs that ARE read in other files. |
| 16 `PDV.Daedric.<Prince>.Renounced` | **CUT** | All 16 writes are inside `DebugRenouncePath()` — **debug-only**, write-only, no readers. No player-facing renunciation feature exists to wire. |
| Syrabane signal ids | **RENUMBER to 3110+** (block kept) | 4 of 5 ids collide with Boethiah's authored 2001/2002/2003/2005. Highest id in use is 3102, so 3110+ is free. ⚠ MCM `SIGNAL_TYPE_MAX` is now exactly 3200 — keep new ids under it. |
| 8 unbound T3 `HealSpell` slots | **LEAVE** (not a defect) | Only 3 `*_AvoidDeathHeal` spells exist (BaanDar/Shor/HoonDing). Nothing authored to bind; the `RestoreActorValue` fallback is live and correct. |
| Retired BOOK urn `071557` | **LEAVE unbound** | Deliberately retired and migrated away by `EnsureDunmerAncestralUrn`; MISC urn `071611` is the live one. Binding it would revive a retired token. |
| 3 threshold-less `PDV_RepTrack_*` quests | **LEAVE inert** | Nothing to cut — no code points at them. Only 2 RepTrack properties exist (Concordat, ThalmorAlignment, both live); the three same-named Breton systems are live via StorageUtil (10/6/13 refs). Record-side scaffolding only. |

### Deferred to 1.0.4 (new player-facing content — needs balance + in-game proof)

| Item | Call | Design |
|---|---|---|
| ~~**Altmer Spine**~~ | **NO ACTION** | Already wired AND already tested pre-1.0. My "wire it" call was wrong -- see the correction section below. |
| **Green Pact food positive — MEAT DONE 2026-07-26** | Meat wired; insect + KID ini deferred | `PDV_FLST_GreenPact_MeatFoods` (`071235`) populated with 22 vanilla+DLC records (8 animals raw/cooked where they exist, plus chicken/rabbit/pheasant). Code path (`RouteBosmerPactPositive` -> `HandleBosmerPactPositiveSignal`) already lived from the DrHeisen port, unreachable until now. Anti-farm: NO new cap needed — `ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerPactPositive")` already throttles this signal ID across all callers (Green Songs, proper-hunt, forest-kept), meat included. **Not yet runtime-tested** — eat cooked beef/venison as Bosmer, confirm the route fires in the Papyrus log. Insect list still empty (vanilla has ~no edible insects; needs KID rules to reach modded food) and fungi/egg stay neutral per the owner's original call. |
| **Syrabane award sites** | **WIRE** (5 signals) | Deltas already tuned 1.8–2.2. Design work = deciding what act fires "protective warding", "apprentice aid", etc. Renumber lands in 1.0.3 so the collision dies immediately. |

### CORRECTION 2026-07-26 — the Altmer Spine was never unwired

My grill-session call to "wire the Altmer Spine" was **wrong**, and the design
I proposed is what already ships. Recorded here so nobody rebuilds it.

The live path runs through the **substrate**, not the manager:

- `PDV_SubstrateBase` declares `Substrate_Always` / `_Mid` / `_High`, and
  implements the full ladder: `GetExpectedSubstrateBoon(tier)` picks by tier
  (HIGH -> High, MID -> Mid, LOW -> Always), `SyncSubstrateBoonsToTier()`
  clears the other two and grants the expected one (highest-slot-only, so
  Active Effects shows ONE identity boon), and it is called automatically from
  `RecomputeSubstrateTier` whenever the tier moves.
- The `PDV_Substrate_AltmerAncestor` record (`0715AC`) **binds all three** to
  the real spells: `0715A7` Ordered Heritage +10, `0715A9` Disciplined Heritage
  +20, `0715AB` Exemplar Heritage +30. Thresholds: metric >= 1 / 25 / 75.
- **Tested pre-1.0 by the owner.** No action needed.

**Why I got it wrong:** I grepped `PDV__ManagerQuest.psc` for
`PDV_Bless_Altmer_Spine_*`, found only `SyncRaceRewardSpell(..., False, ...)`
inside the uninstall strip, and concluded "authored but never granted". What I
had actually found is a SECOND, genuinely dead set of manager properties
pointing at the same three spells. Two paths to one set of records; I checked
the dead one. Lesson: for substrate-backed rewards, check the substrate record's
VMAD before concluding anything is unwired.

**Optional tidy (not required):** the manager's dead
`PDV_Bless_Altmer_Spine_Always/Mid/High` properties are unbound and referenced
only by `StripAllPdvSpells`. Harmless — uninstall strips the spine via the
substrate's own `ClearSubstrateBoons` regardless — but they are what caused this
misreading. Also worth noting the naming trap: the spell named "Ordered
Heritage" sits on the `Always` slot, while the substrate's own posture ladder
calls its MIDDLE state `POSTURE_ORDERED`.

### Reverted from their patch — do NOT re-apply

**7.1 broad-pantheon "containment"** (their `BROAD_SCOPE_CONTAIN` rewrite of
`BeginBroadPantheonEvent`) was applied during the port and then **reverted**:
`pdv_broad_pantheon_audit` asserts `source.concurrent-event-serialization` —
distinct logical events must SERIALIZE and a stalled owner must FAIL CLOSED
(`BROAD_SCOPE_ABORT` + `ClearBroadPantheonEventScope`). Their version instead
folds a second concurrent act into the live event as a nested depth, so the
newcomer's deltas are judged against the FIRST act's pool — their own changelog
calls it "a merge, not a corruption." It is a real contract violation. The
spin-wait (100 Hz, ≤2 real seconds) is a deliberate correctness cost. Their C5
"confirmed gone" note is therefore moot for us. Source now carries a comment
saying so.

Also **not** taken: their cut of `DELTA_ANCESTOR_SPINE` from AuriEl / Magnus /
Shor / Talos. `pdv_verify` asserts those declarations, and the 1.0.4 Altmer
Spine wire is what will read them — cutting would have destroyed the intended
values. (Azura / Malacath / Tu'whacca already return theirs.) The other 26 dead
knobs were cut as planned. Their inlining of the `dayKey`/`countKey`/
`lastFireKey` locals in `PDV_DeityBase` was also restored — the Phase 7 audit
pins those names.

### New finding — shrine daily charge spent on a prayer that awards nothing

Surfaced while triaging check 7 on 2026-07-26. **Pre-existing, not a 1.0.3
regression, not fixed.**

`PDV_ShrinePrayerEffect` stamps its once-per-day key as soon as
`RouteShrinePrayer` reports the route dispatched — which is correct as far as
B14 goes. But the manager then drops each deity in
`IsDashboardDeityInOriginRoster` when the deity is outside the player's cultural
roster, so a player praying at a foreign shrine **burns that shrine's daily
charge for zero piety, zero toast and zero journal entry**, with no feedback.

This is the same defect class B14 fixed one layer up (charge spent before the
outcome is known); B14 just moved the boundary from "before routing" to "before
the roster gate". The honest fix is for the route to report whether any deity
actually took the award, and stamp only then — i.e. push the Bool return one
level deeper, through `RouteShrinePrayer` into the manager's per-deity handler.

Worth noting the roster gate itself is intentional and should stay: praying at
another culture's shrine is an ambient world click, not devotion. The bug is
only that it costs the player their daily charge.

### Added to the 1.0.3 smoke packet (two cheap probes, debug level 1–3)

- **Brawl an NPC** — does a brawl punch route `EVT_ASSAULT_INNOCENT`? If yes, gate assault routing behind the vanilla `DGIntimidateQuest` brawl check.
- **Kill a hostile wolf** — does it classify combat or non-combat? If non-combat, the engine clears hostility on death and hostility must be latched at combat time (or read off the hit event) instead of queried from the corpse.
- **B18 (SM receiver `Stop()`/`Reset()` split): NOT touched** — the 0.1 s defer is a documented fix for the issue #17 CTD class. Do not "optimize" it.

## Message for DrHeisen (owner relays)

Their patch on top of Devotion **1.0.3** regresses it: the 1.0.2-based MGEF
overrides revert the 18 Daedric price effects to ValueModifier (prices inert
again), and the loose `PDV__ManagerQuest.pex` masks 1.0.3's curse-cure
instant-restore + Redguard vampire-cure message (and now the Azura fix).
Recommend: rebase the patch on 1.0.3 once released; as 1.0.4 upstreams the
slate above, the patch should shrink toward the ARR-specific remainder.
Their audit is credited in the 1.0.3 CHANGELOG.
