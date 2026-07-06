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

> Update 2026-07-05: `PDV__ManagerQuest.psc` changed after this preflight -- the
> foreign-award reachability gate and the quest-reaction surfacing rework (new row
> A10). Both recompiled 0 errors / 0 warnings and live-source was re-synced to the
> MO2 build copy (hash-identical). Rerun the three sanity commands above before
> Sitting 1.
>
> Update 2026-07-06: formal-offer **Refuse** was changed after the U8 pass to obey
> the owner "refuse goes quiet" ruling. `SurfaceTransition(..., silent=True)` now
> writes the pinned refusal chronicle but skips the transient director cue; the
> warning toast was removed. Accept remains fully surfaced. Machine gates passed
> for manager+MCM compile, `pdv_verify`, `pdv_prisma_ui_audit`, and
> `pdv_formal_offer_check`; `pdv_book_of_days_audit` had one unrelated repo/live
> `app.js` LF/CRLF hash drift. Manual smoke still needs to confirm Refuse is silent
> and Accept still toasts/sounds.
>
> Update 2026-07-06: Orkey/Dibella Old Ways neglect parity is machine/readback
> closed. `pdv-neglect-esp-author --write` authored `PDV_SPEL_Neglect_Arkay` /
> `PDV_MGEF_Neglect_Arkay` as **Orkey's Neglect** (`ResistMagic -5`) and
> `PDV_SPEL_Neglect_Dibella` / `PDV_MGEF_Neglect_Dibella` as **Dibella's
> Neglect** (`Restoration -5`), wired both manager VMAD spell properties, and
> `SyncNordPatronNeglectSpells()` now handles internal Arkay/Orkey and Dibella.
> Machine gates passed; manual smoke still needs Active Effects confirmation.

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

**Why grouped by origin.** `ApplyDeityReaction` scores each deity on a quest cell -- and each
meta lane -- by the player race's STANCE toward it: `NATIVE` = full `1.0x`,
`TABOO`/`HOSTILE` flips the positive into a negative stigma, `CURSE` routes to curse handling.
As of the 2026-07-05 reachability gate (see `PDV_HO_ForeignAwardGate_2026-07-05.md`), a
`FOREIGN`/`TOLERATED` god that is NOT in the origin's dashboard roster and NOT a Daedric path is
**skipped entirely** (DebugLevel-2 trace `QuestReaction skipped unreachable foreign deity`, no
piety, no Ledger row); the reduced `0.4x` rate now applies only to roster-listed
tolerated/foreign gods and Daedric-path faces. Testing each lane/probe under the origin whose
native pantheon it feeds is what gives the clean full-value read. Set the origin once per block:
console `set PDV_GLO_OriginRace to <n>` + `set PDV_GLO_DebugLevel to 2` on a fresh disposable
save, then run every row in that block before flipping. Fire a matrix stage with
`setstage <editorID> <stage>`; steal/outdoor/time rows need the described in-world action.
Markers: cell fires log `[PDV] EventBus: <deity> event <id> delta <x>`; meta lanes land as a
Ledger driver with the humanized reason (`meta_zen_wage`, `meta_julianos_*`, ... -- copy pass
DONE 954bde5b) plus an `AwardPiety` line. As of 2026-07-05 a base quest cell also flushes ONE
aggregated top-left toast + ONE Book of Days beat per quest fire, on top of the per-god panel
driver rows -- proof lives in A10; meta and behavioral faucets stay quiet-Ledger-only.

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
  `PDV.Meta.QuestCount` to a multiple of 10 the wheel fires -> Akatosh awards full; Xarxes is
  SKIPPED (off-roster for Imperial -- expect the DebugLevel-2 skip trace, no Ledger row). This
  doubles as the **reachability-gate negative**; Xarxes' full-value arm is proven under A5.
- **Probes**: `DLC1SeranaCureSelfQuest 200` (Arkay echo), `MS05 300` (Dibella +C),
  `FreeformSkyhavenTempleA 50` (Akatosh +S), `FreeformRiftenThane 200` (civic divines).

### A2. Bosmer (origin 4) -- Z'en gold wage
- **Gold-wage lane**: `setstage MS05 300` (Tending the Flames; gold class, no Z'en cell)
  -> `meta_zen_wage` awards Z'en at full value. (Dibella's cell is SKIPPED for Bosmer -- off-roster,
  expect the skip trace at DebugLevel 2; the full-value Z'en award is the proof the lane fired.)
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
  (Akatosh SKIPPED -- off-roster for Altmer, expect the skip trace). Proves both arms of the
  shared counter and both directions of the reachability gate: Xarxes full here vs skip-trace
  under A1, Akatosh full under A1 vs skip-trace here.

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

### A10. Quest-reaction surfacing -- one toast + one Book of Days per quest fire (reuse the A3/A4 saves)

New 2026-07-05. A base quest-reaction cell now flushes a SINGLE aggregated top-left toast plus a
SINGLE Book of Days beat per quest fire, however many deities the cell fans to. This sits on top of
the per-god panel driver Ledger rows, which already worked. v1 emitted one toast PER god (6 per
assassination stage); this proves the aggregation. The per-cell `AwardPiety` + `QuestReaction
piety:` lines still appear once per landed god in the log -- the aggregation is only for the
toast + Book of Days beat. `DebugLevel 2`.

- **One toast, not N (multi-positive)**: on the A3 Dunmer save, `setstage MQ301 240` (deceit ->
  Mephala + Boethiah both native +). Expect EXACTLY ONE toast, titled by the strongest reactor:
  "{God} and 1 other mark your deed." NOT one toast per god.
- **Book of Days lists every landed god**: open Book of Days -> a single new line
  "{God} and {God} marked your deed." naming each god that landed piety on that fire. No blank line.
- **Mixed fire "A deed weighed"**: on the A4 Khajiit save, fire a Dark Brotherhood assassination
  contract stage (the 2026-07-05 log fired these: Mephala/Baan Dar/Rajhin native +, Clavicus Vile
  tolerated 0.4x, **Sithis TABOO -**). Expect ONE toast "A deed weighed" reading
  "{God} marks your deed; Sithis takes offense." and ONE Book of Days line
  "...marked your deed; Sithis took offense." Tone/symbol follow the stronger side.
- **Negative-only "A deed ill-received"**: a fire that only offends (all landed cells negative) ->
  ONE warning toast "A deed ill-received" / "{God} takes offense at your deed." + matching Book of
  Days line. (Sithis stigma folds in here -- v1 dropped it entirely via an early return.)
- **No double toast for the active patron**: with an active patron who reacts positively to the
  fire, confirm exactly ONE toast (the aggregated quest toast), never that plus the generic favor
  pulse.
- **Faucets stay quiet (negative)**: on the SAME fires, the meta lanes (`meta_*`) and any
  behavioral faucet still land ONLY as Ledger driver rows + `AwardPiety` lines -- they must NOT add
  their own toast or Book of Days line.
- **Off-roster gods absent**: reachability-skipped gods contribute nothing to the toast "and N
  others" count or the Book of Days list (they never landed piety).
- **Panel driver rows intact**: the per-god Ledger "recent drivers" still show each god's own
  reason/delta, unchanged.

Tester notes:

- Each block above runs under the lane's native origin, so a full-value award is expected -- a
  reduced or missing award there is a real finding. Off-roster gods no longer award at all
  (reachability gate): the expected evidence for them is the DebugLevel-2 skip trace and the
  ABSENCE of a Ledger driver row. An off-roster deity-face award appearing anywhere is a
  regression against the gate.
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
LOCKED per-race accept strings and the 2026-07-06 quiet-refuse ruling. Accept still gives the
race-specific toast + pinned chronicle; Refuse gives **no toast, no sound, no screen wash** and
writes only the pinned refusal chronicle. Blank Book of Days line anywhere = FAIL.

U6 follow-up after `task_e6904bb3`: on a Nord Old Ways save, commit Orkey, force
piety to 0, run dawn, and confirm **Orkey's Neglect** appears in Active Effects
as Magic Resistance -5%. Repeat for Dibella and confirm **Dibella's Neglect**
appears as Restoration -5. These are felt-effect checks; the record/readback
gate is already closed.

U4 now also carries the **curated driver-reason retest** (Sitting-1 U4 found every curated
award recording generic "a devotional rite"; fixed on main `c8a4aa34` -- awards now carry the
per-signal phrase from `HumanizeCuratedSignalReason`). Award two curated signals and confirm
distinct trigger-stating rows; Talos 101 = "defiant prayer at a Talos shrine". In-game proof
for this fix is still owed -- record it in the U4 row.

U4 also carries the **watching-Prince badge retest** (Sitting-1 U4 found a pre-pact Prince you
are building toward rendering as an ordinary god card with no indicator; fixed on main `692396bb`
-- the dashboard tagged it `system:"watching"` but the view only surfaced `god.state`, so it now
renders a distinct "Watching" kicker badge above the god name). On a no-pact save, seed a Prince
to pre-pact (Developer Options Daedric debug: commitment signals, tier 0, no pact) and confirm the
Ledger shows it as a clearly-marked "Watching" card, set apart from patron and pantheon rows.
In-game proof still owed -- record it in the U4 row. (The watching Prince's driver-row *copy* is
the curated-reason retest above; the two U4 retests are independent and can be judged on one save.)

U4 also carries the **watching-Prince Book of Days retest** (the badge above surfaces the pre-pact
Prince in the panel, but a Book-of-Days-only player had no journal line naming WHICH Prince took
interest until the deeper half-Seeker "The world tilts toward `<Prince>`." beat; fixed on main
`2f75a860` -- the FIRST time a signal leaves a Prince pre-pact with piety above zero now writes a
named, unpinned chronicle "`<Prince>` has taken an interest in you." plus one soft "`<Prince>` takes
note" cue). On a no-pact save, seed a Prince via Developer Options Daedric debug "Route live sender"
(+10, tier 0) and confirm ONE named "has taken an interest" line appears in the Book of Days naming
that Prince; route the same sender again and confirm NO duplicate of that line (a distinct "The world
tilts toward `<Prince>`." line appearing once piety crosses half-Seeker ~12.5 is the expected deeper
beat, not a duplicate). In-game proof still owed -- record it in the U4 row.

### C2. Beat spot-checks (the 2026-07-01 wires -- confirm each renders; MCM-driven, origin flips on disposable saves)
Copy authority: `PDV_PrismaParity_AuthoringDraft.md` (LOCKED 2026-06-25) for offer/Altmer copy;
`PDV_PrismaAuthoringBeats_Copy.md` for the rest.

| # | Beat | Origin | Do | See |
|---|---|---|---|---|
| 1 | Nord offer ACCEPT | 0 | Seed commitment signals -> Evaluate -> Accept | Toast + PINNED BoD "The broad faith narrows to one; {patron} has named you their own."; Ledger shows the carryover driver |
| 2 | Nord offer REFUSE | 0 | fresh save, same gate -> Refuse | **No toast, no sound, no screen wash**; PINNED BoD "...you turned {patron} away, and {patron} will not ask again."; no forced panel |
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
  Health-based effect. Nord Old Ways Orkey/Dibella neglect now also needs felt confirmation:
  Orkey's Neglect = Magic Resistance -5%, Dibella's Neglect = Restoration -5. Prove unrelated
  Requiem regen changes are not being counted.

Evidence sink: Redguard + Daedric/Namira blocks of `PDV_Phase20_ManualEvidenceLedger.json`;
route checker `node .\tools\pdv_phase20_runtime_check.mjs`.

## E. Day-to-day signal sweep -- grouped by origin race (Anvil)

Per `PDV_InGameTestingNeeded_Runbook.md` section 5. DebugLevel 2 (3 for cap checks). Marker:
`[PDV] EventBus: <deity> event <id> delta <x>` -- delta must match `PDV_DeityLikesDislikes.csv`
exactly.

**Why the grouping is different from Section A.** These are generic acts scored off the
likes/dislikes table and hard **race-gated** -- an act only scores deities native to the current
origin. But **Imperial's Nine Divines cover every 300-series event** (all combat/craft/knowledge/
sleep events have a Divine liker; every transgression has a Divine *disliker*). So this is NOT one
block per race -- it is one broad **Imperial** pass plus **two small flips** for what the Divines
cannot score. Both flips reuse a Section A origin, so you never reroll: run E2 on the A6 Nord save,
E3 on the A3 Dunmer save.

### E1. Imperial (origin 1) -- primary pass (~22/24 events + all mechanics)
Run the whole vocabulary here; every row lands on a Divine. Deltas must be CSV-exact.
- combat by victim: draugr `300`, Dremora `301`, dragon `302` (Akatosh reads this as a **dislike**,
  `-`), non-hostile animal / criminal victim `303`/`304`
- craft (use the stations): smith `330`, enchant `331`, brew `332`, cook `333`
- knowledge: skill book `340`, spell `341`, lore book `342`, word wall `343`, skill-up
  (`player.incPCS <skill>`) `344`, new location `345`
- devotional sleep: outside `313`, inside `314`
- transgression (the Divines read these as **dislikes**): owned lock `360`, **`361` trespass**
  (enter an owned home uninvited + detected), **`362` steal-item** (owned loose/container item, NOT
  a pickpocket), assault innocent `364`, raise undead `365`, daedric artifact `368`
  - **`360` owned lock -- PROVEN 2026-07-05 via menu-hook fallback (SM route dead):** the LockPick
    Story Manager event is not emitted in this setup, so 360 now routes from a
    `RegisterForMenu("Lockpicking Menu")` hook in `PDV_PlayerEvents` (crosshair-ref capture on
    open, locked->unlocked + owned/cell-owner check on close). In-game PASS on the Imperial save:
    `Zenithar event 360 delta -0.5`, CSV-exact. `362` dislike side also fired CSV-exact the same
    day (Mara/Stendarr/Zenithar/Julianos). Full record:
    `PDV_SessionHandoff_2026-07-05_PickLock360SMFix.md`.
- **`362` route proof**: `[PDV] EventBus: RouteAction complete: event 362` **or** an advanced
  `PDV.Meta.LastTheftTime` stamp (the Nocturnal meta-faucet consumes it). Under Imperial you also
  see the Divine **dislike** delta; the positive/like side is E3.
- **mechanics (origin-neutral -- prove once, here):** attribution filter (an environmental/indirect
  kill logs `skipped non-scoring attribution`); anti-farm at DebugLevel 3 (a capped act stops at its
  daily cap, `0.7^n` decay); dawn bank (`PietyToday -> Piety` at ~06:00 moves standing/tier)
- **race-gate negative:** after a native act scores (e.g. `330` -> Zenithar), `set PDV_GLO_OriginRace
  to 3`, repeat the same act -> `0`, then flip back to `1`

### E2. Nord (origin 0) -- the two Kyne combat lines the Divines can't score
Events `1`/`2` are the only sweep rows with no Divine scorer. Run on the **A6 Nord save**.
- kill-hostile-beast -> event `1`: Kyne **dislike** (`-3`, beast protection)
- kill-hostile-humanoid -> event `2`: Kyne **like** (`+`)

(doubles as the Nord-origin spot-check the runbook still owes)

### E3. Dunmer (origin 5) -- the transgression LIKE side + the `362` like-delta
The Imperial pass shows transgressions as dislikes; here the same events land as the **positive**
rows (Mephala/Boethiah are native). Run on the **A3 Dunmer save**, right after the A3 `362` steal.
- steal-item `362` -> Mephala/Boethiah **like** delta (the like-side E1 cannot show)
- owned lock `360`, trespass `361`, assault `364`, daedric artifact `368` -> confirm the
  `+` sentiment rows fire for Mephala / Boethiah / Azura
- optional Khajiit (origin 6, A4 save) extends the trickster set to Rajhin / Baan Dar / Azurah

This whole sweep doubles as the fresh-save proof of the expanded likes/dislikes rows and the
now-runnable `362` route.

Already confirmed 2026-06-10 (Imperial): `300`/`301`/`345` CSV-exact + race-gate + attribution --
skip those in E1. Remaining: craft / book / sleep / the full transgression set incl. `361` and
`362` (E1), Kyne `1`/`2` (E2), and the transgression like-side (E3).

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
