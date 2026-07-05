# PDV 1.0 Mega Test Packet -- consolidated remaining in-game proof (2026-07-02; updated 2026-07-05)

Status: STRICT BETA-READINESS GATE PASSED 2026-07-05; residual runtime/manual proof remains below.
Owner plan: `C:\Users\Admin\.claude\plans\kick-off-session-let-s-mighty-flask.md`.

**What this is.** One ordered packet consolidating every remaining in-game proof between the
current build and the next 1.0 work. It sequences the existing sheets -- it does NOT replace
them. **On any conflict, the source run sheet wins**; this packet only owns the order, the save
plan, and the evidence-sink map.

**Proof boundary.** Everything below is Route/runtime or Manual/acceptance proof. The
machine/readback bucket is already closed (see Preflight Evidence). Do not let a passing
section here claim anything for compatibility, final-world placement, V2 scope, or public
support without the matching proof bucket.

**Evidence intake rule.** Ledger statuses are `pending` / `evidence-recorded` /
`not-applicable` only -- never write `pass`/`done` into
`PDV_Phase20_ManualEvidenceLedger.json`; the beta gate derives the verdict.

**Handoff reconciliation.** `PDV_SessionHandoff_2026-07-05_QuestExpansion.md` was written
before `PDV_SessionHandoff_2026-07-05_DunmerCloseout.md`. Its Quest Expansion smoke queue is
still valid, but its "Dunmer is the only blocker" statement is superseded. Imperial closed on
2026-07-04, Dunmer closed on 2026-07-05, and the current strict audit passes.

---

## Preflight Evidence (latest sanity pass 2026-07-05)

| Gate | Result |
|---|---|
| `node .\tools\pdv_compile.mjs` | 0 errors / 0 warnings (PDV__ManagerQuest recompiled) |
| `node .\tools\pdv_verify.mjs --json` | FAIL=0, WARN=1 (medallion glyph fallback, known), PASS=3513 |
| `node .\tools\pdv_integrity_harness.mjs` | signal_e2e 39 GREEN / 0 RED; deity_chain 0 blockers; eligibility 147/0 |
| `node .\tools\pdv_prisma_ui_audit.mjs` | PASS (49 checks) |
| `node .\tools\pdv_prisma_toast_fallback_audit.mjs` | PASS incl. negative fixtures |
| `node .\tools\pdv_prisma_to_oneoh_audit.mjs` | PASS incl. negative fixtures |
| `node .\tools\pdv_book_of_days_audit.mjs` | PASS=110, WARN=0, FAIL=0 |
| `node .\tools\pdv_requiem_penalty_audit.mjs` | PASS (incl. Imperial ResistDisease -5 preservation) |
| `node .\tools\pdv_daedric_beta_gate.mjs --json` | PASS=16 |
| `node .\tools\pdv_beta_readiness_audit.mjs --strict --json` | STRICT_GATE_PASS; PASS=31, WARN=1, INFO=2, blockers=[] |

Build state: live-source and MO2 were hash-identical for `PDV__ManagerQuest.psc`, `PDV_MCM.psc`,
`PDV_DaedricPath_Hircine.psc` in the 2026-07-02 preflight. Rerun the quick sanity commands below
before a new testing sitting if any code, plugin, Prisma, reward, Daedric, or runtime-surfacing
file changed:

```powershell
git status --short
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
node .\tools\pdv_verify.mjs --json
```

---

## Session plan (post-strict-gate residual queue)

| Sitting | Instance | Sections | Approx |
|---|---|---|---|
| 1 | **Anvil** | A. Quest Expansion smoke rows -> E. day-to-day signal sweep, including 361/362 -> C1/C2 Prisma residual rows | medium |
| 2 | **Anvil** | F. Prince V2 path-deepening -> C3 focus-trap re-confirm if Prisma changed | medium |
| 3 | **Authoria** | D. Requiem felt sweep (A1-A9, B1, B2) + penalty feltness and tuning notes | medium |
| 4 | **Repo-side** | Rerun strict audit, then resume Experience Mode -> ARR package -> WS-3 branding only if no new blockers appear | short |

Shared preflight, every sitting: disposable **new save** (or main-menu `coc qasmoke`);
MO2 Anvil: disable `Devotion - Living Deities Test` (skip on Authoria -- not in that list);
console `set PDV_GLO_OriginRace to <n>` + `set PDV_GLO_DebugLevel to 2`; seeds via
**MCM -> Devotion -> Developer Options** (never `cqf`). Origin indices: 0 Nord, 1 Imperial,
2 Breton, 3 Altmer, 4 Bosmer, 5 Dunmer, 6 Khajiit, 7 Argonian, 8 Orc, 9 Redguard.
Papyrus log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
Walk into location-anchored hooks via load door / fast-travel -- `coc` skips Story
location-change triggers. Make a hard save at the clean start so origin flips and terminal
refuse tests can reload.

---

## A. Quest Expansion smoke rows  [next Anvil test]

Source handoff: `references/authoring/PDV_SessionHandoff_2026-07-05_QuestExpansion.md`.
Source contract: `references/authoring/PDV_QuestExpansion_Architecture.md`.

Run these on a disposable save after the quick sanity commands pass. They are route/runtime and
manual-display proof for the 40-50 quests-per-deity expansion and meta-faucets, not a reason to
reopen the race strict gate unless they expose a regression.

**Why grouped by origin.** Every probe quest scores several deities, but a delta only *lands*
when the scored deity is native/active for the current origin -- and meta lanes apply the stance
multiplier (a foreign face lands at `0.4x`). Testing each lane/probe under the origin whose
native pantheon it feeds gives a clean full-value confirmation. Set the origin once per block:
console `set PDV_GLO_OriginRace to <n>` + `set PDV_GLO_DebugLevel to 2` on a fresh disposable
save, then run every row in that block before flipping. Fire a matrix stage with
`setstage <editorID> <stage>`; steal/outdoor/time rows need the described in-world action.
Markers: cell fires log `[PDV] EventBus: <deity> event <id> delta <x>`; meta lanes land as a
Ledger driver with the humanized reason (`meta_zen_wage`, `meta_julianos_*`, ... -- copy pass
DONE 954bde5b) plus an `AwardPiety` line.

### A0. Run once (any origin -- fold into the Imperial block)
- **Matrix reload count**: on load, confirm `832` cells / `118` keys / `90` watched quests.
- **Yield negative** (needs Julianos native -> do under Imperial): `setstage MG01 200` (First
  Lessons). Julianos scores from its CELL (`EventBus: Julianos event ... delta`); `meta_julianos`
  must NOT also fire -- MG01 carries a Julianos cell so `metaSkip` suppresses the lane.
- **Once-guard negative**: after any meta lane fires for a quest, `setstage` that same quest again
  -> `PDV.Meta.Done.<qid>` suppresses; confirm no second award.

### A1. Imperial (origin 1) -- Divines hub + mage-aid + wheel
- **Julianos mage-aid lane**: `setstage MG05 200` (Containment; mageAid, no Julianos cell)
  -> `meta_julianos` awards Julianos.
- **Akatosh 10th-quest wheel**: advance 10 distinct watched quest stages; on the fire that takes
  `PDV.Meta.QuestCount` to a multiple of 10 the wheel fires -> Akatosh awards (Xarxes `0` by
  race-gate).
- **Probes**: `DLC1SeranaCureSelfQuest 200` (Arkay echo), `MS05 300` (Dibella +C),
  `FreeformSkyhavenTempleA 50` (Akatosh +S), `FreeformRiftenThane 200` (civic divines).

### A2. Bosmer (origin 4) -- Z'en gold wage
- **Gold-wage lane**: `setstage MS05 300` (Tending the Flames; gold class, no Z'en cell)
  -> `meta_zen_wage` awards Z'en. (Dibella cell reads `0` for Bosmer; the Z'en award is the proof.)
- **Z'en yield negative**: `setstage FreeformSkyhavenTempleA 50` -> Z'en scores from its ECHO cell,
  `meta_zen_wage` suppressed (metaSkip).

### A3. Dunmer (origin 5) -- Azura mage-aid/twilight + 362 steal
- **Azura mage-aid lane**: `setstage MG05 200` -> `meta_azura` awards Azura (no Azura cell on MG05).
- **Azura twilight lane**: `set gamehour to 5` (dawn) or a dusk hour, then fire any watched quest
  with no Azura cell -> `meta_azura` (twilight arm).
- **362 steal proof**: steal an owned loose item or owned container item (NOT a pickpocket)
  -> Mephala/Boethiah steal-likes wake; `RouteAction complete: event 362` and
  `PDV.Meta.LastTheftTime` advances.
- **Probes**: `DLC1SeranaCureSelfQuest 200` (Azura +S -- the primary cell, strongest single probe),
  `MQ301 240` (Mephala deceit echo).

### A4. Khajiit (origin 6) -- Khenarthi outdoors + Rajhin steal
- **Khenarthi outdoors lane**: standing OUTDOORS, `setstage` a watched quest with no Khenarthi cell
  -> `meta_khenarthi` awards Khenarthi. Repeat the same fire INDOORS -> lane silent (negative).
- **362 steal**: same steal action -> Rajhin steal-like wakes.
- **Probe**: `MQ301 240` (Rajhin / Baan Dar deceit).

### A5. Altmer (origin 3) -- Xarxes wheel (shared counter's second deity)
- **10th-quest wheel**: advance 10 watched quest stages -> wheel fires -> Xarxes awards
  (Akatosh `0` by race-gate). Proves both arms of the shared Akatosh/Xarxes counter.

### A6. Nord (origin 0) -- mercy cluster (doubles as the Section E Nord spot-check)
- **Probe**: `MQ301 240` -> Kyne / Stuhn / Stendarr / Mara `mercy_spare` cluster scores.

### A7. Redguard (origin 9) -- Tu'whacca
- **Probe**: `DLC1SeranaCureSelfQuest 200` -> Tu'whacca `cure_undeath` echo scores.

### A8. Orc (origin 8) -- Malacath civic
- **Probe**: `FreeformRiftenThane 200` -> Malacath civic/thane scores.

### A9. Nocturnal path (any origin -- reuse the Dunmer or Imperial save)
Open the Nocturnal path first (MCM -> Devotion -> Developer Options -> Daedric debug, 3 commitment
signals). The lanes award the Nocturnal DEITY face, so the path must be active.
- **Theft-window lane (tier 1)**: perform a 362 steal, then fire a watched quest ->
  `meta_nocturnal_theft` awards Nocturnal (`LastTheftTime > LastFulfillTime`).
- **Night lane (tier 2)**: with no recent theft, fire a watched quest at a night hour
  (`set gamehour to 1`) -> `meta_nocturnal_night`.

Tester notes:

- Stance multipliers apply to meta lanes; a foreign face can land at `0.4x`. Each block above is
  already under the lane's native origin, so a full-value award is expected -- a `0.4x` reading
  there is a real finding, not a stance artifact.
- The meta Ledger copy pass and Daedric-path name-repair hardening were marked DONE in the same
  handoff (954bde5b); this sitting is runtime smoke, not re-authoring those follow-ups.
- The wheel counter increments on every meta-eligible watched fire, so other rows in a sitting also
  advance `PDV.Meta.QuestCount` -- just watch for the `%10 == 0` fire rather than counting from zero.

## B. Closed race strict-gate packets  [do not retest without regression]

Imperial and Dunmer are both closed for the current beta-feel packet. Do not run these as next
tests unless a new change touches their route handlers, Survey/status wording, focused Devotion
panel filtering, Book of Days/Ledger payloads, rewards/Active Effects, Dunmer home logic, or
Good Daedra/deviation-price surfaces.

- Imperial: PASS 2026-07-04; final-world placement remains separate.
- Dunmer: PASS 2026-07-05; all slots 1-8 plus shared Daedric inn-sleep proof recorded.
- Current strict audit: `STRICT_GATE_PASS` 2026-07-05, with no blockers.

## C. Prisma verification (beats wired 2026-07-01 + universal surfaces)

### C1. Universal sheet U1-U9 (once on the current build)
Run `references/authoring/PDV_RunSheet_Universal_Prisma_V1.md`. U6 (neglect drop) and U7
(recovery at piety 15, no tier-up) are the newest rows; U8 covers offer accept/refuse with the
LOCKED per-race strings (see the table there for exact Nord/Imperial/Dunmer/Altmer/Redguard
toast copy). Blank Book of Days line anywhere = FAIL.

### C2. Beat spot-checks (the 2026-07-01 wires -- confirm each renders; MCM-driven, origin flips on disposable saves)
Copy authority: `PDV_PrismaParity_AuthoringDraft.md` (LOCKED 2026-06-25) for offer/Altmer copy;
`PDV_PrismaAuthoringBeats_Copy.md` for the rest.

| # | Beat | Origin | Do | See |
|---|---|---|---|---|
| 1 | Nord offer ACCEPT | 0 | Seed commitment signals -> Evaluate -> Accept | Toast + PINNED BoD "The broad faith narrows to one; {patron} has named you their own."; Ledger shows the carryover driver |
| 2 | Nord offer REFUSE | 0 | fresh save, same gate -> Refuse | Toast + PINNED BoD "...you turned {patron} away, and {patron} will not ask again."; no forced panel |
| 3 | Altmer alignment band | 3 | drive Thalmor alignment across a committed band (MCM debug) | Toast "The Thalmor question turns in you: {band}." + chronicle (locked copy); remember the band label lags raw by design |
| 4 | Hircine renunciation | any | open Hircine path (MCM Daedric debug), then Renounce | Renunciation toast + PINNED reorientation chronicle from PRODUCTION RenouncePath (not the debug button); no double entry on the same tick; residue toast still arrives later |
| 5 | Khajiit Champion pin | 6 | force a Khajiit patron to Champion, Run Dawn; then wait 22+ days | Champion chronicle is PINNED (survives pruning) with tier-band suffix |
| 6 | Redguard sect Champion toast | 9 | drive a sect to Champion entry | per-sect toast ("The {sect} way, made public.") alongside the existing chronicle |

### C3. Cold-view focus-trap re-confirm (~15 min, any save)
From a COLD game start (no prior panel open this session), fire a gameplay toast, then open the
panel. ESC must release input every time; `DevotionPrismaBridge.log` clean (no focus-before-
OnDomReady). This re-proves the `g_panelFocusPending` defer after the DLL rebuild.

## D. Requiem felt sweep  [Authoria instance -- feel is only provable here]

Run `references/authoring/PDV_RequiemSmokeTest_Tracker.md` Track B. Magnitudes are PROVISIONAL:
record TUNED values as notes; do NOT re-run cumulative-rebalance tools (not idempotent).

- **Sweep A (A1-A9):** each converted Fortify-Health reward is felt -- `player.getav Health`
  before/after + HP bar. A7 Mara sleep-mercy (once/day 25/40), A8 Dunmer home-prayer ANCESTOR
  WATCH (2026-07-04 rework: home prayer arms a visible once-per-day near-death full restore
  that expires at dawn; NO instant heal -- an on-the-spot pulse is a regression), A9 Orc Code
  Holds near-death restore.
- **Sweep B1:** Redguard Tu'whacca event-heal (T2<T3, once/day), Namira heal-on-feed
  (tier-scaled, stops at cap), Ash'abah stigma (Survey label + marked-moment notice, NO piety
  drop), Breton Vigilant nod (WitchcraftExposure >= 50 Survey line).
- **Sweep B2:** HoonDing -- dragon make-way once/day (+Trace), 2nd same-day dragon decayed x0.7,
  generic bandit silent, listed named boss fires once + dedups, road-passage routes
  Forebear/Leki NOT HoonDing, Champion cheat-death save at <20% health once/day. Plus one
  approved Ash'abah clearable undead site scores; a non-listed clearable site stays silent.
- **Penalty feltness:** Argonian Hist Distant -10 max Health, Breton Tradition Distant -10,
  Breton Excommunication -15 (Active Effects shows a Maximum Health label, bar ceiling drops,
  no old Health Regeneration line); Imperial civic lapse stays ResistDisease -5 with NO
  Health-based effect. Prove unrelated Requiem regen changes are not being counted.

Evidence sink: Redguard + Daedric/Namira blocks of `PDV_Phase20_ManualEvidenceLedger.json`;
route checker `node .\tools\pdv_phase20_runtime_check.mjs`.

## E. Day-to-day signal sweep (Anvil -- broadest native coverage)

Per `PDV_InGameTestingNeeded_Runbook.md` section 5. DebugLevel 2 (3 for cap checks). Marker:
`[PDV] EventBus: <deity> event <id> delta <x>` -- delta must match `PDV_DeityLikesDislikes.csv`
exactly.

- combat by victim 300/301/302 (draugr/Dremora/dragon), 303/304 negatives
- craft at stations 330-333; knowledge 340-345 (incl. word wall, `player.incPCS`, new location)
- devotional sleep 313/314; transgression 360/**361 trespass**/
  **362 steal-item via AddToPlayer**/364/365/368. For `362`, steal an owned
  loose item or owned container item, not a pickpocket; proof is
  `RouteAction complete: event 362` or an advanced `PDV.Meta.LastTheftTime`
  timestamp, with deity delta only if the current table scores it.
- race-gate negative: flip `PDV_GLO_OriginRace`, same act scores 0 for non-native gods
- attribution filter: environmental kill logs `skipped non-scoring attribution`
- anti-farm: capped act stops at daily cap, 0.7^n decay; dawn bank moves PietyToday -> Piety
- this run doubles as the fresh-save proof of the expanded likes/dislikes rows and the
  now-runnable `362` route.

Already confirmed 2026-06-10: 300/301/345 CSV-exact + race-gate + attribution. Remaining:
craft / book / sleep / full transgression set incl. 361 and 362, plus Nord-origin spot-checks.

## F. Prince V2 path-deepening (per runbook section 6)

Marker: `[PDV] PrinceV2: <Prince> event <id> deepen <x>`.

- deepen-not-initiate: BEFORE committing (e.g. Namira), liked act -> NO marker, no path piety
- open the path (MCM Daedric debug, 3 commitment signals) -> same act fires; MCM contract `p=` rises
- dual-face: off-race origin (0) opens Azura PATH -> PrinceV2 fires; native origin (5/6) ->
  Azura is the DEITY face (EventBus line, not PrinceV2), path inert -- no double-dip
- curse coordination: werewolf active + Hircine path open -> beast kill deepens Hircine with
  NO double-fired curse transition
- after any Daedric change: rerun `node .\tools\pdv_daedric_runtime_check.mjs` +
  `node .\tools\pdv_daedric_beta_gate.mjs --json` (must stay PASS=16)

---

## Stop conditions (abort the packet, bring back notes)

- an accepted source fires for the wrong race, or generic gameplay becomes a scoring faucet
- a generic act scores a non-native god (race-gate leak)
- an UNcommitted transgressive Prince path deepens from an ambient act
- Survey/status shows route IDs / raw counters instead of player wording
- a reward or price stacks invisibly or cannot be explained from the UI
- Prisma opens as a BLOCKING panel where only a toast/notification is expected
- save/load changes visible state unexpectedly
- any Book of Days line renders BLANK

## After the run (owner, repo side)

1. Intake Quest Expansion, day-to-day, Prisma, Prince V2, and Requiem results into their
   existing trackers/runbook sections; do not create a new parallel handoff unless the result
   changes the next-session queue.
2. Rerun the gate: `node .\tools\pdv_beta_readiness_audit.mjs --strict --json`; the expected
   result remains `STRICT_GATE_PASS` unless a new regression was found.
3. Fold any new defects into existing trackers; magnitude notes feed the scaling/anti-farm pass.
4. If the gate still passes and no residual test opens a blocker, proceed to Experience Mode
   build, then ARR compat package, then WS-3 branding/packaging per the 1.0 plan.
