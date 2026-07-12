# PDV 1.0 Co-Test Runbook - 2026-07-10

Purpose: one working sheet for live testing together. Use this when the tester
asks "what do I do next?", reports an observation, or needs the exact command,
surface, or evidence sink for the remaining smoke path to 1.0.

This document is an operator dashboard, not the pass/fail authority. The
generated ledgers still decide state:

- 1.0 ship gate:
  `references/authoring/PDV_1_0_EndStateContract.json` plus
  `node .\tools\pdv_1_0_endstate_gate.mjs` ->
  `references/authoring/PDV_1_0_EndStateBurndown.md`
- Signal-floor backend/runtime smoke:
  `references/authoring/PDV_SignalFloorSmokeScenarios_2026-07-09.json` plus
  `node .\tools\pdv_signal_floor_smoke_gate.mjs --write-ledger` ->
  `references/authoring/PDV_SignalFloorSmokeLedger.md`
- Detailed remap smoke procedures:
  `references/authoring/PDV_DeitySignalRemap_InGameSmoke_Runbook.md`
- 1.0 race/cross-cutting packet:
  `references/authoring/PDV_MegaPacket_OneOh_2026-07-02.md`

## Current Status At Creation

Generated 2026-07-10 from live tools:

- Signal-floor smoke gate: **PASS after MQ305, MQ206, DBDestroy, MS10, and MQ302 retests**. The source/runtime-JSON
  / MCM harness checks pass, and the 2026-07-10 source fix reachability-gates
  `TABOO` / `HOSTILE` non-Daedric quest reactions before they can write piety
  or Book of Days surface. Cards 2, 3, 4, 5, and 7 now have in-game manual
  evidence recorded; broader signal-floor runtime/manual openings remain.
- 1.0 end-state gate: **RED** in read mode, **1 PASS / 1 STALE / 16 RED**.
  Recent manager/deployed drift voided several older machine proofs. Before
  using live play time as 1.0 evidence, run the recertification preflight below
  and get the generated burndown back to the expected machine-green shape.

Do not promote any signal-floor row, race sitting, or 1.0 criterion from this
runbook alone. Record evidence into the named ledgers, then let the tool-derived
gates calculate the verdict.

## Proof Buckets

Keep these separate when reporting results:

| Bucket | What proves it | What it does not prove |
|---|---|---|
| Backend/static | Source CSVs, generated JSON, script tokens, record readback, verifier/audit PASS | In-game event firing, UI display, save/load behavior |
| Runtime-route | Papyrus log marker from the actual route or the controlled debug route named for that purpose | Book of Days clarity, Survey/status clarity, Active Effects feel |
| Manual/display | Tester-visible Book of Days, Survey/status, Prisma/toast, Active Effects, duplicate suppression, wrong-origin silence, save/load stack check | Full 1.0 ship readiness |
| 1.0 claim | `pdv_1_0_endstate_gate.mjs` rollup PASS after all machine and evidence slots close | Any individual local pass by itself |

## How We Use This Together

When testing live, use this loop:

1. Codex runs or reviews the preflight and names the next open slice.
2. Tester runs the exact in-game steps from the relevant card below.
3. Tester reports observations using the capture template.
4. Codex records the evidence in the right structured ledger or files a defect.
5. Codex reruns the relevant generated gate and updates the status documents.

If a symptom appears mid-test, stop the case and report the symptom before
continuing. Do not keep stacking more evidence on a save whose state may now be
unclear.

## Machine Preflight

Run this before a serious 1.0 smoke sitting, and again after code, ESP, Prisma,
StorageUtil JSON, or deployed-script changes:

```powershell
git status --short
node .\tools\pdv_1_0_endstate_gate.mjs
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_signal_floor_smoke_gate.mjs --check --json
node .\tools\pdv_prisma_ui_audit.mjs --json
```

If the 1.0 burndown reports source/deployed drift, recertify before relying on
the result:

```powershell
node .\tools\pdv_1_0_endstate_gate.mjs --run
```

For a signal-floor/remap-specific sitting, add:

```powershell
node .\tools\pdv_quest_tranche_merge.mjs
node .\tools\pdv_quest_matrix_compile.mjs --check --json
node .\tools\pdv_quest_matrix_compile.mjs --papyrusutil-check --json
node .\tools\pdv_deity_signal_remap_adversary_check.mjs
node .\tools\pdv_signal_floor_smoke_gate.mjs --check --json
```

After the 2026-07-12 reserved-signal dispatch package lands, also add:

```powershell
node .\tools\pdv_signal_e2e_gate.mjs
node .\tools\pdv_verify.mjs --strict-curated-signal-dispatch --json
```

If `--strict-curated-signal-dispatch` is not recognized, the coding package is
not fully merged into this checkout yet. Stop and finish the backend merge
before running the reserved-signal smoke cards below.

Expected backend state before in-game smoke:

- `pdv_verify`: FAIL=0. The known medallion glyph fallback warning is allowed.
- Quest matrix after the 2026-07-12 matrix-freshness package: 1057 rows, 169
  quest keys, 135 watched quests, 26 faucet acts. If the tools still report the
  older 1056 / 168 / 134 counts, Package B is not deployed.
- `pdv_deity_signal_remap_adversary_check`: PASS. Its
  `potentialOffRosterHostileSurfaces` count is expected to remain nonzero
  because the source guard, not row deletion, owns that cross-origin policy.
- Likes/dislikes version: `LIKES_DISLIKES_VERSION = 16`.
- Signal-floor smoke gate: backend PASS; runtime OPEN is expected until live
  Papyrus markers exist.
- Reserved-signal package: `pdv_signal_e2e_gate.mjs` PASS and
  `pdv_verify --strict-curated-signal-dispatch` FAIL=0. The four built signals
  burn from the reserved list, and Khenarthi `OPEN_ROAD` burns by removal.

## In-Game Setup

Use the Anvil MO2 profile `Devotion Dev`; `Devotion.esp` must be enabled.
Disable `Devotion - Living Deities Test` if it appears.

Use a disposable new save or main-menu `coc qasmoke`. Clear logs before a clean
run:

```powershell
Remove-Item "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus*.log" -ErrorAction SilentlyContinue
```

In game:

```text
set PDV_GLO_DebugLevel to 2
set PDV_GLO_OriginRace to <originIndex>
```

Origin indices:

| Index | Race |
|---:|---|
| 0 | Nord |
| 1 | Imperial |
| 2 | Breton |
| 3 | Altmer |
| 4 | Bosmer |
| 5 | Dunmer |
| 6 | Khajiit |
| 7 | Argonian |
| 8 | Orc |
| 9 | Redguard |

Use MCM Developer Options for debug seeding. Do not use `cqf` as a substitute
for tester proof. For location hooks, walk through a load door or fast-travel
into the location; `coc` can skip Story Manager location-change triggers.

## Immediate Test Queue

Order matters because the current gate has source/deployed drift and the
signal-floor smoke state is open at runtime:

1. **Recertify machine gates.** Run `pdv_1_0_endstate_gate.mjs --run` after the
   deployed/live state is settled. Do not spend a long in-game sitting while the
   burndown is drift-red unless the point is defect reproduction.
2. **Reserved-signal dispatch + matrix freshness, if the 2026-07-12 package has
   landed.** Run the machine gates above, then work the **Reserved Signal +
   Matrix Freshness Cards** section. This prevents stale JSON/name-normalization
   bugs from contaminating later Khajiit or signal-floor evidence.
3. **Signal-floor representative smoke.** Close the remaining runtime/manual openings
   from `PDV_SignalFloorSmokeLedger.md`. Use the table below. This is the best
   first co-test target because it directly checks the new MCM harness, backend
   matrix expansion, Book of Days aggregation, and the risky organic routes.
   Cards 2, 3, 4, 5, and 7 have passed after retest; continue with the next
   open card.
4. **Race sittings for 1.0.** Work the **Felt-Family Race Sittings
   (deduplicated plan)** section below - ten checklist sittings that prove every
   pending felt family (107 at snapshot) ONCE each (the raw `--sitting <Race>`
   sheets repeat shared price/sting families across races; the plan assigns each
   to a single sitting). Each race sitting feeds C-FELT-FAMILY, C-PACING-SIGNOFF, and
   C-PLACEMENT-FINAL. If a race's beta-feel verdict has regressed, re-run its
   beta-feel packet during the same sitting to clear the C-RACE-RUBRIC stale
   state. (`--sitting <Race>` is still useful for a live single-race regen, but it
   re-lists shared families the plan has already assigned elsewhere.)
5. **Cross-cutting 1.0 smoke.** Experience Mode two-mode smoke, Requiem Track B,
   dislike anti-stack under Requiem, ARR acceptance, and Bordello compatibility
   packaging.

## Signal-Floor Smoke Cards

The Debug: State & Rewards MCM page has a `Signal-floor smoke` selector and run
button for the 12 non-borderline scenarios. That controlled route is useful for
log collection, but it does not replace organic proof where the card says
"organic route required".

For every card, capture:

- Papyrus route marker, if present.
- Book of Days line or explicit absence.
- Survey/status lane result.
- Toast/Prisma result.
- Active Effects or stack result when relevant.
- Repeat/save-load behavior.
- Wrong-origin or generic-source silence when relevant.

| # | Scenario | Route to run | Expected result | Required manual checks |
|---:|---|---|---|---|
| 1 | Quest fan-out and aggregation | `setstage DLC2SV01 200`; controlled MCM index 1 is allowed for route smoke | Hist, Y'ffre, and Syrabane rows exist; visible landed deities are origin-roster gated (Altmer: Y'ffre + Syrabane, Argonian: Hist) | One toast, one Book of Days line naming landed deities, coherent Survey/status |
| 2 | Main-quest death gods and Dagon correction | `setstage MQ305 200`; controlled MCM index 2 | Arkay and Tu'whacca milestone gains, Khenarthi gain, Mehrunes Dagon loss | Dagon is a loss; reachable gods only; repeat after save/load does not stack |
| 3 | Main-quest lore gods | `setstage MQ206 220`; controlled MCM index 3 | Source rows include Julianos, Hermaeus Mora, Magnus, Xarxes, and Dagon; Altmer display is roster-gated: Magnus/Xarxes visible, Dagon loss visible, no Shor/Talos/Nord combat fan-out | Lore gains visible where reachable; Dagon correction remains negative; no stale Nord fan-out |
| 4 | Sithis strongest negative | `setstage DBDestroy 200`; controlled MCM index 4 | Split-origin proof: Argonian shows the Sithis milestone loss; Nord or Breton shows the Stendarr/Talos gains | Argonian Sithis loss is strongest negative; Nord/Breton Stendarr/Talos gains are visible |
| 5 | Zenithar milestone | `setstage MS10 100`; controlled MCM index 5 | Split-origin proof: Nord/Imperial/Breton shows the Zenithar milestone gain; Bosmer shows the Z'en small gain | Zenithar and Z'en gains are visible where reachable |
| 6 | Hircine cure dislike | Controlled MCM index 6 for this sitting. Organic proof requires an active Companions `CR13` Farkas/Vilkas Purity quest; a generic werewolf save plus `setstage CR13 200` is not reliable. | Hircine loss plus Y'ffre gain | Controlled route/display proof now; organic CR13 proof remains separate unless the save is already on the active cure quest |
| 7 | Season Unending | `setstage MQ302 300`; controlled MCM index 7 | Imperial shows Mara, Stendarr, and Akatosh; Stuhn skips there by roster gate. Nord shows Stuhn too. | Stage 300 smoke stands in for the concession-stage coverage set |
| 8 | Crypt clear | Enter and clear a listed undead crypt through a load door; Bleak Falls is acceptable; controlled MCM index 8 only for route smoke | Arkay, Meridia, Stendarr, Tu'whacca, Azura, and Y'ffre gains once per site | Same-site repeat stays blocked/capped; `coc` is not organic proof |
| 9 | Likes/dislikes v15 | Fresh or unstamped save; fire vampire feed 366 and non-combat animal kill 303; controlled MCM index 9 | Arkay/Stendarr losses for 366; Kyne/Kynareth losses for 303; v15 reload marker | Daily caps hold; old save loads the v15 table once |
| 10 | Green Way behavior | Bosmer Old Contract: visit sacred site, then consume plant food; controlled MCM index 10 only for route smoke | Y'ffre site gain and plant-consumption loss | Plant proof must use real item consumption; debug route is not enough |
| 11 | Paarthurnax kill fork | Reachable listed-god race, Nord recommended; kill Paarthurnax; controlled MCM index 11 only for route smoke | Shor/Tsun/Kyne/Stendarr/Stuhn/Mara reactions; Khajiit keeps Alkosh chaos-aid case | Repeat after save/load is blocked |
| 12 | Paarthurnax spare fork | Paarthurnax alive and neither latch set; complete/load `MQ305` stage 200; controlled MCM index 12 only for route smoke | Stuhn/Stendarr/Mara/Kyne gains once | If kill latch already fired, spare remains silent |
| 13 | Borderline prove-or-drop rows | Review `DA14Start` s70, `DLC2RRFavor01` s200, `T03` s105, HearthFires adoption stages | Decide prove, revise, or drop | Manual review only; no generated runtime marker expected |

## Reserved Signal + Matrix Freshness Cards (2026-07-12, post-build)

Authority: `references/authoring/PDV_HO_ReservedSignalDispatch_QuestMatrixFreshness_2026-07-12.md`.
Run this section only after the coding package lands, compiles, and passes the
reserved-signal gates in **Machine Preflight**. These cards close
backend/static and runtime-route proof for the dispatch package. Manual-display
proof (toast, Book of Days, Survey/status, Active Effects) is recorded in the
normal race sitting or signal-floor ledger; do not call the package manually
proven from MCM route markers alone.

Use MCM Developer Options for the new reserved-signal debug buttons. Do not use
`cqf`. For organic routes, Codex must name the exact quest/stage/source from the
landed code or compiled matrix before the tester runs the case; do not guess
stage IDs from the design note.

Preconditions:
- `tools/pdv_reserved_signals.json` is present in the main tree and no longer
  lists the four built signals as live known gaps.
- Khenarthi `OPEN_ROAD` is removed, not routed.
- Manager and MCM compile 0/0 if debug buttons changed.
- `Reload quest matrix` in MCM reports the expected 135 core watched quests
  after JSON deployment; if a runtime route logs `0 quest entries`, stop and
  rerun the matrix compile/deploy path.

| # | Scenario | Route to run | Expected result | Required manual checks |
|---:|---|---|---|---|
| RS1 | Khenarthi `CARAVAN_AID` | Controlled MCM reserved-signal button, then organic caravan-aid route if a caravan combat save is available. | Khenarthi receives a small pulse through `PDV.Signal.KhenarthiCaravanAid`; daily cap holds on repeat. | Runtime marker, driver reason names the caravan-aid event, toast/Book of Days/ledger are readable where Khenarthi is reachable. |
| RS2 | Rajhin `LEGEND_MADE` | Controlled MCM button, then one organic high-value theft route (single stolen item value >= 500) or the landed TG08B latch. | Rajhin receives a medium pulse; same-day repeat is capped; one-shot latch does not double-fire. | Runtime marker, no ordinary low-value theft triggers this row, display names Rajhin cleanly. |
| RS3 | Mephala `WEB_WOVEN` | Controlled MCM button, then one landed curated quest-stage source from `PDV_FLST_P2_MephalaWebSources`. | Mephala receives the pulse through normal reachability/stance gates; no origin hardcode. | Prove one Dunmer/Khajiit-relevant route if available; wrong-origin silence remains intact where Mephala is not reachable. |
| RS4 | Boethiah `HONORABLE_DUEL` | Controlled MCM button, then organic brawl-victory or `DA02` champion-duel source from the landed route list. | Boethiah receives the pulse through normal reachability/stance gates; daily cap or latch holds on repeat. | Prove the route does not fire from generic combat; display text says when it fired, not poetic filler. |
| RS5 | Khenarthi `OPEN_ROAD` removal | Backend only unless a regression appears. Search/gate confirms no constant, registry row, debug button, or dispatch route survives. | The e2e reserved list burns this entry by removal. | Any live `OPEN_ROAD` pulse is a defect; road-home cadence remains the Khajiit travel identity route. |

Matrix freshness / name-normalization cards:

| # | Scenario | Route to run | Expected result | Required manual checks |
|---:|---|---|---|---|
| RM1 | Runtime JSON deployed and reloadable | Run matrix compile/deploy, then MCM Developer Options -> `Reload quest matrix`. | MCM reports 135 core watched quests; ARR channel is regenerated if present. | If counts are stale, stop before testing quest rows. |
| RM2 | `Y'ffre` spelling class | Fire one landed tranche10 row whose matrix deity name is exactly `Y'ffre`. | Runtime lands on `PDV_Yffre`, not a silent zero-row drop. | Book of Days/toast names Y'ffre correctly; no fallback `Yffre` miss. |
| RM3 | `Baan Dar` spelling class | Fire one landed row whose matrix deity name is exactly `Baan Dar`. | Runtime lands on `PDV_BaanDar`. | Display keeps the space and does not expose raw EditorID spelling. |
| RM4 | `Azura` spelling across Dunmer and Khajiit | Fire one landed `Azura` matrix row as Dunmer, then one as Khajiit. | Both land on `PDV_Azura`; Khajiit focus copy can still present Azurah elsewhere without breaking matrix routing. | Record both origins separately; no apostrophe/name-normalization silent drop. |
| RM5 | Wrong-origin silence | Fire one known Khajiit-roster-only or origin-limited row as an unrelated origin, Altmer recommended. | The route stays silent or only reachable deities surface. | No off-roster hostile/taboo fan-out; adversary check remains PASS. |
| RM6 | ARR compatibility matrix freshness | Regenerate the ARR package from the current matrix after core JSON is green. | ARR `PDV_QuestReactionMatrix_ARR.json` no longer predates tranche10; no new Requiem masters. | Backend/package proof only unless running an ARR profile smoke. |

## Efficient Sitting Split

Use these as the default live order unless a bug report points elsewhere:

| Sitting | Origin/save | Primary purpose |
|---|---|---|
| A | Fresh Nord or unstamped save | LD v15 first, MQ305/MQ206/MQ302, Dagon correction, crypt clear, Card 4 Stendarr/Talos half, Paarthurnax kill/spare |
| B | Bosmer | Green Way sacred site and plant-food proof, Y'ffre-sensitive rows, wrong-origin silence where useful |
| C | Breton or Altmer | Formal-offer/reward overlap spot checks while running quest-stage fan-out |
| D | Disposable edge save | Borderline prove-or-drop rows, repeat/save-load adversary checks, generic-source silence |
| E | Argonian | Card 4 Sithis loss half, Hist/Sithis-sensitive rows |

After each sitting, regenerate the relevant ledgers:

```powershell
node .\tools\pdv_signal_floor_smoke_gate.mjs --write-ledger
node .\tools\pdv_1_0_endstate_gate.mjs
```

## Felt-Family Race Sittings (deduplicated plan)

SNAPSHOT of `PDV_FeltFamilyEvidenceLedger.json` as of 2026-07-11 (107 pending families). This is a generated point-in-time bundle; if the ledger grows or credits land, regenerate it. Each family is proven ONCE: every shared price/sting is assigned to a single race sitting whose native gods exercise it, so running these ten sittings proves all 107 with zero re-tests (the raw per-race `--sitting` sheets repeat shared families across races). Sink every observation into `PDV_FeltFamilyEvidenceLedger.json`; close each sitting with the race pacing sign-off in `PDV_PacingSignoffLedger.json` (C-PACING-SIGNOFF) and any in-world hook proof (C-PLACEMENT-FINAL).

| # | Sitting | Origin idx | Families | Running total |
|---|---|---|---|---|
| 1 | Nord | 0 | 13 | 13 |
| 2 | Imperial | 1 | 13 | 26 |
| 3 | Breton | 2 | 12 | 38 |
| 4 | Khajiit | 6 | 12 | 50 |
| 5 | Altmer | 3 | 11 | 61 |
| 6 | Orc | 8 | 11 | 72 |
| 7 | Redguard | 9 | 10 | 82 |
| 8 | Dunmer | 5 | 9 | 91 |
| 9 | Bosmer | 4 | 8 | 99 |
| 10 | Argonian | 7 | 8 | 107 |

### 1. Nord sitting (13 families) - `set PDV_GLO_OriginRace to 0`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [x] `Nord-Kyne|boon`  (e.g. Kyne's Sky - Seeker)
- [x] `Nord-OldWays|boon`  (e.g. Old Ways - Seeker)
- [x] `Nord-Shor|boon`  (e.g. Shor's Favor - Seeker)
- [x] `Nord-Stuhn|boon`  (e.g. Stuhn's Ward - Seeker)
- [x] `Nord-Talos|boon`  (e.g. Talos's Resolve - Seeker)
- [x] `Nord-Tsun|boon`  (e.g. Tsun's Trial - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [x] `Neglect-Kyne|neglect`  (e.g. The Weather Stops Cooperating)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [x] `Dibella|price`  (e.g. murder-defenseless)
- [x] `Kyne|price`  (e.g. kill-hostile-beast)
- [x] `Shor|price`  (e.g. murder-defenseless)
- [x] `Stuhn|price`  (e.g. murder-defenseless)
- [x] `Talos|price`  (e.g. murder-defenseless)
- [x] `Tsun|price`  (e.g. murder-defenseless)

### 2. Imperial sitting (13 families) - `set PDV_GLO_OriginRace to 1`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [x] `Imperial-Akatosh|boon`  (e.g. Akatosh's Covenant - Seeker)
- [x] `Imperial-Arkay|boon`  (e.g. Arkay's Vigil - Seeker)
- [x] `Imperial-Civic|boon`  (e.g. The Divines' Regard - Seeker)
- [x] `Imperial-Dibella|boon`  (e.g. Dibella's Grace - Seeker)
- [x] `Imperial-Julianos|boon`  (e.g. Julianos's Wisdom - Seeker)
- [x] `Imperial-Kynareth|boon`  (e.g. Kynareth's Breath - Seeker)
- [x] `Imperial-Mara|boon`  (e.g. Mara's Mercy - Seeker)
- [x] `Imperial-Stendarr|boon`  (e.g. Stendarr's Mercy - Seeker)
- [x] `Imperial-Talos|boon`  (e.g. Talos's Resolve - Seeker)
- [x] `Imperial-Zenithar|boon`  (e.g. Zenithar's Trade - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [x] `Neglect-Imperial|neglect`  (e.g. The Divines Grow Distant)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [x] `Kynareth|price`  (e.g. raise-undead)
- [x] `Stendarr|price`  (e.g. murder-defenseless)

### 3. Breton sitting (active runtime checklist; generic Tradition lane retired) - `set PDV_GLO_OriginRace to 2`

Build note, 2026-07-12: the Breton **two-axis split** is now landed and ready
for in-game smoke. Authority: `PDV_BretonTwoAxis_BuildSpec_2026-07-12.md`.
Tradition T1/T2 now lights from practice COUNTS
(`KnightlyVowCount` / `HiddenArtCount` / `GreenWayCount`), not pooled deity
piety. Patron championing is orthogonal over the 11-god Breton roster plus
Daedric-via-20C. Resonant Champion patrons unlock the active tradition T3;
non-resonant Champion patrons grant the modest
`PDV_Bless_Breton_PatronChampion` beside the practiced tradition.

Run BX1-BX7 below for the current build. B1/B1a/B3 remain historical proof for
the superseded pool-gated build and should not be used as two-axis proof. The
old Breton ancestor substrate and generic `Tradition's Footing` lane remain
retired at runtime.

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Breton-GreenWay|boon`  (e.g. Green Way - Seeker)
- [ ] `Breton-HiddenArt|boon`  (e.g. Hidden Art - Seeker)
- [x] `Breton-KnightsRoad|boon`  (e.g. Knight's Vow - Seeker; B1/B1a passed 2026-07-12)
- [ ] `Breton-PatronChampion|boon`  (e.g. Patron's Mark - Champion; BX1)
- [x] `Breton-Tradition|boon` is N/A - the generic Tradition's Footing lane is retired; absence confirmed via B3 on 2026-07-12.

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Breton|neglect`  (e.g. The Tradition Grows Distant)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [x] `Akatosh|price`  (e.g. kill-dragon)
- [x] `Arkay|price`  (e.g. raise-undead)
- [ ] `CreedLoss-Breton|price`  (e.g. The Vow Broken)
- [x] `Julianos|price`  (e.g. murder-defenseless)
- [ ] `Magnus|price`  (e.g. raise-undead)
- [x] `Mara|price`  (e.g. murder-defenseless)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects and confirm the source label says `Favor Slips`:
- [x] `Disfavor-MercyProtection|disfavor-sting`  (e.g. Mercy withdraws for a while.)

### 4. Khajiit sitting (12 families) - `set PDV_GLO_OriginRace to 6`

Runtime note, 2026-07-12: Initial Khajiit setup pass succeeded through origin
6, moon observance, road-home cadence, and Survey/status display. Tester found
the Survey correct but too paragraph-heavy. Source hotfix compacted
`GetKhajiitSurveyText()` to present-state lines only (`Lunar Lattice`, standing,
moon practice, road home, and current moon phase) and removed the past-tense
"lunar source read" sentence from Survey because accepted P2 book notices already
feed Book of Days. Compile 0/0 for `PDV__ManagerQuest` and `PDV_MCM`; verifier
FAIL=0 WARN=1; Prisma UI audit PASS 89. Manual retest of the new copy is owed
after a full Skyrim relaunch. Do not mark the reward-family rows below complete
until their Active Effects / Book of Days / toast surfaces are explicitly read.
2026-07-12 Baan Dar focused-emergence pass recorded: tester confirmed the
remaining Baan Dar steps passed as expected, covering the focused Seeker boon
surface and no-offer/no-wrong-focus expectations for `Khajiit-BaanDar|boon`.
2026-07-12 Rajhin focused-emergence pass recorded: tester confirmed
`Khajiit focus -> Rajhin` swaps the active focused boon as soon as target piety
is applied in the debug harness; no dawn pass is needed for this controlled
focus-swap proof.
2026-07-12 Alkosh focused-emergence pass recorded: tester confirmed
`Khajiit focus -> Alkosh` plus Alkosh target piety produced the expected focused
boon swap, with no commitment offer or wrong-focus reward stack.
2026-07-12 Azurah and Khenarthi focused-emergence passes recorded: tester
confirmed both remaining focused boon families passed through the behavior-button
paths (moon observance for Azurah, road-home cadence for Khenarthi), not debug
patron override.
Post-build reserved-signal note: when the 2026-07-12 reserved-signal package
lands, fold Khenarthi `CARAVAN_AID` and Rajhin `LEGEND_MADE` manual-display
proof into this Khajiit sitting if those gods are reachable on the test save.
The reserved-signal section owns backend/static and runtime-route proof; this
race sitting owns visible Khajiit-facing readability. Phase-blessing and
substrate LOW/HIGH band cards remain separate pending additions.

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [x] `Khajiit-Alkosh|boon`  (e.g. Alkosh's Order - Seeker; focused-emergence pass 2026-07-12)
- [x] `Khajiit-Azurah|boon`  (e.g. Azurah's Twilight - Seeker; behavior-button focus pass 2026-07-12)
- [x] `Khajiit-BaanDar|boon`  (e.g. Baan Dar's Guile - Seeker; focused-emergence pass 2026-07-12)
- [x] `Khajiit-Khenarthi|boon`  (e.g. Khenarthi's Road - Seeker; behavior-button focus pass 2026-07-12)
- [x] `Khajiit-Rajhin|boon`  (e.g. Rajhin's Shadow - Seeker; immediate focus-swap pass 2026-07-12)

**substrate-favor** - prime the substrate/context state, read the effect in Active Effects:
- [ ] `Khajiit-Lunar|substrate-favor`  (e.g. Khajiit Lunar Road)
- [x] `Khajiit-Substrate|substrate-favor`  (e.g. Lunar Hardiness; observed during prior Khajiit pushes 2026-07-12)

2026-07-12 hotfix note: tester saw Lunar Hardiness but not Khajiit Lunar Road.
`PDV_Bless_Khajiit_Lunar_T1` is the Khajiit substrate Mid slot, but the generic
first-tier race-reward sync was still managing that shared spell and could strip
it after substrate grant. `PDV__ManagerQuest.psc` now leaves Khajiit Lunar_T1 to
`PDV_Substrate_KhajiitLunar`; `tools/pdv_reward_runtime_order_lint.mjs` now
fails on substrate-owner violations, and `PDV_SubstrateBase.psc` reconciles
unchanged tiers so a stripped Mid boon can re-add on the next substrate signal.
Retest before checking `Khajiit-Lunar|substrate-favor`.

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-KhajiitLunar|neglect`  (e.g. The Moons Withdrawn)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Alkosh|price`  (e.g. murder-defenseless)
- [ ] `Azurah|price`  (e.g. murder-defenseless)
- [ ] `Khenarthi|price`  (e.g. raise-undead)
- [ ] `Rajhin|price`  (e.g. murder-defenseless)

### 5. Altmer sitting (11 families) - `set PDV_GLO_OriginRace to 3`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Altmer-AuriEl|boon`  (e.g. Auri-El's Dawn - Seeker)
- [ ] `Altmer-Magnus|boon`  (e.g. Magnus's Arts - Seeker)
- [ ] `Altmer-Orthodox|boon`  (e.g. Altmer Orthodox Steadiness)
- [ ] `Altmer-Syrabane|boon`  (e.g. Syrabane's Guard - Seeker)
- [ ] `Altmer-Trinimac|boon`  (e.g. Trinimac's Charge - Seeker)
- [ ] `Altmer-Xarxes|boon`  (e.g. Xarxes's Record - Seeker)

**curse** - prime the curse state via debug MCM, read the curse effect in Active Effects:
- [ ] `Altmer-CurseState|curse`
- [ ] `Altmer-VampireExiledPath|curse`

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Altmer|neglect`  (e.g. The Dawn Withheld)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Auriel|price`  (e.g. murder-defenseless)
- [ ] `Xarxes|price`  (e.g. accept-daedric-artifact)

### 6. Orc sitting (11 families) - `set PDV_GLO_OriginRace to 8`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Orc-City|boon`  (e.g. Private Fidelity - Seeker)
- [ ] `Orc-LegionExile|boon`  (e.g. Foreign Discipline - Seeker)
- [ ] `Orc-Malacath|boon`  (e.g. Malacath's Regard - Seeker)
- [ ] `Orc-Stronghold|boon`  (e.g. Forge-Worthy - Seeker)
- [ ] `Orc-TrialOfIron|boon`  (e.g. Trial of Iron - Tusk)
- [ ] `Orc-supportSpells|boon`  (e.g. The Code Holds)
- [ ] `OrcCodeHolds|boon`  (e.g. The Code Holds - Devoted)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Orc|neglect`  (e.g. The Code Goes Unkept)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Malacath|price`  (e.g. steal-item)
- [ ] `Trinimac|price`  (e.g. accept-daedric-artifact)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects and confirm the source label says `Favor Slips`:
- [x] `Disfavor-WarHonor|disfavor-sting`  (e.g. Honor recoils for a while.)

### 7. Redguard sitting (10 families) - `set PDV_GLO_OriginRace to 9`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Redguard-AncestorSpine|boon`  (e.g. Ancestor Spine - Seeker)
- [ ] `Redguard-HoonDing|boon`  (e.g. HoonDing's Way - Seeker)
- [ ] `Redguard-Leki|boon`  (e.g. Leki's Sword-Song - Seeker)
- [ ] `Redguard-Tuwhacca|boon`  (e.g. Tu'whacca's Ward - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Redguard|neglect`  (e.g. Ancestors at a Distance)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `HoonDing|price`  (e.g. murder-defenseless)
- [ ] `Leki|price`  (e.g. murder-defenseless)
- [ ] `Tuwhacca|price`  (e.g. raise-undead)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects and confirm the source label says `Favor Slips`:
- [x] `Disfavor-DeathAncestors|disfavor-sting`  (e.g. Rest grows uneasy for a while.)
- [x] `Disfavor-SkyStormHunt|disfavor-sting`  (e.g. Weather turns cold for a while.)

### 8. Dunmer sitting (9 families) - `set PDV_GLO_OriginRace to 5`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Dunmer-Azura|boon`  (e.g. Azura's Twilight - Seeker)
- [ ] `Dunmer-Boethiah|boon`  (e.g. Boethiah's Struggle - Seeker)
- [ ] `Dunmer-Mephala|boon`  (e.g. Mephala's Web - Seeker)
- [ ] `Dunmer-Reclamation|boon`  (e.g. Reclamation Communion - Faithful)

**substrate-favor** - prime the substrate/context state, read the effect in Active Effects:
- [ ] `Dunmer-Substrate|substrate-favor`  (e.g. Dunmer Ancestor's Steadiness)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Dunmer|neglect`  (e.g. The Ancestors' Silence)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Boethiah|price`  (e.g. heal-or-cure-npc)
- [ ] `Mephala|price`  (e.g. kill-hostile-humanoid)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects and confirm the source label says `Favor Slips`:
- [ ] `Disfavor-VoidSecrets|disfavor-sting`  (e.g. Unease clings for a while.)

### 9. Bosmer sitting (8 families) - `set PDV_GLO_OriginRace to 4`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Bosmer-BanditRoad|boon`  (e.g. Bandit Road - Seeker)
- [ ] `Bosmer-Exchange|boon`  (e.g. The Exchange - Seeker)
- [ ] `Bosmer-LivingStory|boon`  (e.g. Living Story - Seeker)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `BaanDar|price`  (e.g. murder-defenseless)
- [ ] `Yffre|price`  (e.g. raise-undead)
- [ ] `Zen|price`  (e.g. steal-item)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects and confirm the source label says `Favor Slips`:
- [ ] `Disfavor-MoonLuckShadow|disfavor-sting`  (e.g. Fortune slips for a while.)
- [ ] `Disfavor-OrderTradeLore|disfavor-sting`  (e.g. Order sours for a while.)

### 10. Argonian sitting (8 families) - `set PDV_GLO_OriginRace to 7`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Argonian-Hist|boon`  (e.g. Hist Communion - Faithful)
- [ ] `Argonian-People|boon`  (e.g. Chosen People - Kin)
- [ ] `Argonian-Sithis|boon`  (e.g. Void Distance - Faced)
- [ ] `Argonian-supportSpells|boon`  (e.g. Void-Held Surge)

**substrate-favor** - prime the substrate/context state, read the effect in Active Effects:
- [ ] `Argonian-Substrate|substrate-favor`  (e.g. Hist Memory)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-ArgonianHist|neglect`  (e.g. The Hist Distant)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Sithis|price`  (e.g. raise-undead)
- [ ] `TheHist|price`  (e.g. murder-defenseless)


## Co-Test Defects / Follow-Ups

- 2026-07-11: Old Ways Nord Julianos dislike debug retest passed as silence proof. Do not credit this to `Julianos|price`; the expected proof was that an Old Ways Nord cannot reach Julianos through generic likes/dislikes. Tester observed no toast, no Book of Days entry, no Active Effect, and Papyrus log shows `DebugFireDislike: Julianos is not reachable in the current origin/baseline.`
- 2026-07-11: `Disfavor-SkyStormHunt|disfavor-sting` retro-credited from the already-run Kyne/Kynareth weather proof. Papyrus log shows `Kynareth -> SkyStormHunt Light`; tester confirmed this had already been covered, so no repeat Imperial step is required.
- 2026-07-11: `Favor Slips` source-label write landed in the live ESP and readback passed. Runtime visual recheck is still owed because the player-facing Active Effects source label must be seen in game.
- 2026-07-11: Breton co-test paused before boon proof. Current source keys Knight's Road reward sync to Stendarr specifically; architecture review is pending on whether this remains the intended anchor model.

- 2026-07-12: RESOLVED the 2026-07-11 Knight's Road/Stendarr anchor question. Architecture review (v3 12.5 + race sheet 10.3) confirmed the tradition is the lane, not a single deity. Manager reconciliation landed (compile 0/0, verifier FAIL=0): pooled piety across the tradition deity pool lights T1/T2, a focused patron unlocks T3, and the generic "Tradition's Footing" lane is retired. See `PDV_BretonTraditionReconciliation_BuildSpec_2026-07-11.md`. Green Way pilgrimage/sleep enrichment deferred to a focused session (spec Part 2).
- 2026-07-12: CORRECTION to a same-session claim -- the six Breton P2 FormLists were NOT empty; that was a wrong-field houseCARL query (`FormIDs` vs `Items`). Lists are populated; the fill tool ran as a verified no-op (ESP byte-identical). Residual is a stale signal-floor ledger, tracked separately.
- 2026-07-12: HOTFIX for B1 runtime display defect. Tester confirmed Mara can now light Knight's Vow/Aegis, but toast and Book of Days only named Mara and Active Effects still showed `Breton Inherited Ward`. Manager hotfix now emits a tradition-specific reward toast/Book of Days entry (`Knight's Road deepens`; `The Knight's Road names you Seeker/Devoted.`), keeps the reward spell, and clears the retired Breton ancestor substrate on reward/dawn/legacy signal sync. Compile 0/0; verifier FAIL=0; Prisma UI audit PASS 89.
- 2026-07-12: HOTFIX follow-up for B1/B1a pooled math and Knight's Road reward feel. Manager now sums piety across the eligible tradition deity pool for broad T1/T2 instead of reading the best single deity tier, while focused patron still owns T3. Live Knight's Road reward records now preserve Block and replace Restoration with Magic Resistance (`Knight's Aegis`: Block +13, Magic Resistance +8%; `Knight's Bulwark`: Block +25, Magic Resistance +18%, Armor +50). Scoped Knight's-Road-only reward readback PASS; ESP backup `Backups\phase20-race-rewards\Devotion.esp.20260712-131544.bak`. Same closeout fixed Breton neglect readback so `The Tradition Grows Distant` now carries Maximum Health -10 plus Magic Resistance -5; ESP backup `Backups\phase20-race-rewards\Devotion.esp.20260712-131917.bak`. Phase 2 reward readback PASS=1410 WARN=0 FAIL=0; Requiem penalty audit PASS=44; SEQ refresh PASS unchanged; compile 0/0; verifier FAIL=0 WARN=1. Runtime/manual proof remains `Neglect-Breton|neglect` plus the other open Breton cards below.
- 2026-07-12: Breton B1/B1a/B3 runtime/manual proof PASSED. Tester confirmed Knight's Road pooled piety lights T1/T2 from mixed eligible deity sources, including the mixed-source 25/50 case; `Knight's Aegis` appears with the updated reward effects; toast and Book of Days name Knight's Road rather than Mara; and the old `Breton Inherited Ward` / generic `Tradition's Footing` surfaces are absent after retirement sync. This closes `Breton-KnightsRoad|boon` and confirms `Breton-Tradition|boon` as not-applicable/retired. Remaining Breton sitting items: Green Way boon, Hidden Art boon, Breton neglect, CreedLoss-Breton, Magnus price, and B2/B4/B5.
- 2026-07-12: BACKEND CLEANUP QUEUED FOR NEXT SKYRIM-CLOSED WINDOW. Papyrus load noise includes one PDV-owned stale VMAD property, `PDV_Faction_Hunted_Vigilant`, still present on `PDV__ManagerQuest` after the source property was retired. Do not touch the ESP while Skyrim holds it. When Skyrim is closed, strip only that orphan VMAD property from `Devotion.esp`, then verify with `pdv_verify` and a fresh Papyrus-log load that the warning is gone. External noise from missing CC plugins, NiOverride, FISS, or other mods is out of this PDV cleanup scope.
- 2026-07-12: HOTFIX for B2 focused Champion presentation. Tester reported that Julianos-at-85 granted the Knight's Road T3 route in the log but the visible toast used the public `Devoted` band and did not clearly call out Julianos as Champion. `PDV__ManagerQuest` now keeps public tier bands for ordinary standing, but tier toasts use `Champion` for Champion reaches, and Breton T3 tradition presentation names the focused patron (`Julianos names you Champion through the Knight's Road.`) while still granting the tradition reward spell (`Knight's Bulwark - Champion`). Synced to live MO2 source; `PDV__ManagerQuest` and `PDV_MCM` compile 0/0; verifier FAIL=0 WARN=1; Prisma UI audit PASS 89. Manual B2 retest is still owed after relaunch/reload because the running game had the old PEX loaded.
- 2026-07-12: B2 partial runtime/manual proof recorded after the focused Champion hotfix. Active Effects now shows the T3 reward stack as `Knight's Bulwark - Champion` with Armor, Block, and Magic Resistance. This proves the focused Champion reward/effect stack side of B2, but does not by itself prove the updated toast/Book of Days patron wording; that presentation retest remains open.
- 2026-07-12: HOTFIX follow-up for B2 duplicate Champion toasts. Retest showed the intended Breton-specific toast (`Julianos names you Champion through the Knight's Road.`) plus an extra generic tier toast (`Devotion deepens / Julianos names you Champion.`). Architecture check confirmed this was not a rejection of the focused-patron model: Breton lanes are two-phase, with broad tradition T1/T2 and focused patron T3. Source now suppresses the generic tier surface only for Breton in-tradition focused Champion transitions and lets the Breton tradition presentation own the single toast/Book-of-Days entry. Synced to live MO2 source; `PDV__ManagerQuest` and `PDV_MCM` compile 0/0; verifier FAIL=0 WARN=1; Prisma UI audit PASS 89. Manual B2 presentation retest still owed after full Skyrim relaunch.
- 2026-07-12: BOOK-READ FARM CLOSED. The generic book faucet (events 340 skill / 341 spell tome / 342 lore) never tracked "already read", so the same lore book could be re-read up to its per-deity daily cap every day forever, and the once-per-day Azura/Hermaeus Mora book faucets refreshed off any shelf book. Fix in `PDV_PlayerEvents.psc`: a once-ever `PDV.BookRead.<formID>.Seen` guard (`MarkGenericBookRead`) marks each book base form on first read, shared across `OnBookRead` and the `OnItemRemoved` consume-on-learn tome ingress so a learn plus a later re-read of another copy credit exactly once. Azura `fate_threshold` and HM `disciplined_study` now also require an unread book; HM `forbidden_knowledge` keeps its own per-form manager guard and is untouched, as are the P2 racial-source and Altmer Talos-Mistake one-shots. Compile 0/0; verifier FAIL=0. Runtime-route + manual-display proof owed via the Book-Read Unread Cap card below. Save-compat: existing saves have no seen keys, so every previously-read book credits once more post-update, then never again (expected, no migration).

- 2026-07-12: BRETON TWO-AXIS SPLIT LANDED; ready for BX smoke after a full Skyrim relaunch/new save. Owner ruled the 2026-07-11 pool-as-T3-gate model an error; the intent was always two orthogonal axes (tradition = practice track; patron championing over the full 11-god roster, so a Green Way Breton can champion Magnus). Authority: `PDV_BretonTwoAxis_BuildSpec_2026-07-12.md`. Source now tiers traditions from practice counts, grants resonant Champion patrons through the tradition T3, grants non-resonant Champion patrons `PDV_Bless_Breton_PatronChampion`, includes Talos in Breton formal offers, and surfaces Breton two-axis state through Survey/status, Book of Days, and Prisma toasts. Pool-gated B1/B1a are historical only; run BX1-BX7 for current proof. Backend/readback gates passed: manager/EventBus/ActionRouter/MCM compile 0/0, Breton reward and formal-offer readback PASS, Prisma UI audit PASS 89, phase-2 reward readback PASS=1415, signal-floor audit PASS 51/51, adversary check PASS, and verifier FAIL=0.

## Breton Tradition + Dislike Cards (2026-07-12, superseded by BX for reward tiering)

These cards cover the superseded pool-gated reconciliation (Part 1) and the
softer Y'ffre dislike set (Part 3). B1/B1a/B2/B3 are historical for the code that
was live when they were run; do not use them as proof for the current two-axis
build. B4/B5 remain valid Green Way dislike/like smoke cards on a save that has
loaded `LIKES_DISLIKES_VERSION = 16`.

| # | Scenario | Steps | Expected | Manual checks |
|---:|---|---|---|---|
| B1 | PASSED 2026-07-12 - Tradition breadth lights T1/T2 (not single-deity) | Knight's Road Breton, broad patron state. Build pooled piety across the eligible Knight's Road deities, with Stendarr at 0 if possible. | Knight's Vow (T1) lights at pooled Seeker; Knight's Aegis (T2) at pooled Devoted, with NO Stendarr piety required. Toast title should be `Knight's Road deepens`; Book of Days should add `The Knight's Road names you Seeker/Devoted.` | Reward spell present in Active Effects/Magic; the pre-fix bug (only Stendarr moved it) is gone; the display is not Mara-only; `Breton Inherited Ward` clears and does not return |
| B1a | PASSED 2026-07-12 - Mixed-source pool math | Knight's Road Breton, broad patron state. Split piety across eligible Knight's Road deities, e.g. Mara + Arkay + Julianos totaling 25, then 50; no one deity needs to cross the threshold. | Knight's Vow lights at pooled 25; Knight's Aegis lights at pooled 50; broad pool remains capped at Devoted. | Confirmed: the lane is a general tradition total, not best-single-deity tier |
| B2 | PARTIAL 2026-07-12 - Focused patron unlocks T3 | Same save; accept a focused patron offer within Knight's Road; take that deity to Champion. | `Knight's Bulwark - Champion` lights only after commitment + Champion; broad phase alone caps at T2. Exactly one toast/Book-of-Days entry should name the patron as Champion, e.g. `Julianos names you Champion through the Knight's Road.` | Active Effects T3 stack PASSED: Armor, Block, and Magic Resistance all show from `Knight's Bulwark - Champion`. Still owed: post-duplicate-hotfix toast/Book of Days wording must name the focused patron as Champion with no second generic `Devotion deepens` tier toast |
| B3 | PASSED 2026-07-12 - Generic Tradition lane and ancestor substrate retired | Any Breton, broad worship; also valid on the B1 migrated save after one reward sync/dawn. | No "Tradition's Footing" Health buff granted; no `Breton Inherited Ward`; migrated saves lose both obsolete effects | Confirmed retired successfully: Survey/Active Effects show only the active tradition family, no generic tradition Health spell, and no mixed-inheritance substrate copy |
| B4 | Green Way Y'ffre dislikes (softer set) | Green Way Breton, fresh save. Fire raise-undead (365) and assault-innocent (364). | Y'ffre loss surfaces for both; necromancy is the stronger (-medium) | Loss visible (toast / Book of Days / panel Ledger); daily caps hold; NO smithing or food penalty (softer set) |
| B5 | Green Way hunt like | Same save; kill wild game (non-combat animal, event 303). | Y'ffre small gain (respectful hunt); cook-meal also gains | Gain visible; pairs with cook; a minor Kynareth -303 is expected (cross-deity, by design) |

## Breton Two-Axis Split Cards (2026-07-12, ready for smoke)

The two-axis build is source/record/readback complete. These cards close the
runtime-route and manual-display buckets for the current Breton model (tradition
practice vs patron championing). Use origin index 2 (Breton); seed tradition via
the Debug MCM; use a **fresh save or a full relaunch into a save that has not
cached the older manager PEX**. `LIKES_DISLIKES_VERSION` remains 16 because this
build did not change CSV rows; the new practice layer consumes existing event
IDs and quest tags.

Preconditions to check first (backend, before any in-game step):
- `GetBretonTraditionPoolPiety`/`GetBretonTraditionPietyPoolTier` retired; tier
  reads practice counts.
- Record `PDV_Bless_Breton_PatronChampion` exists (spec + readback).
- `LIKES_DISLIKES_VERSION = 16`.
- `HandleBretonSleepEvents` no longer awards Julianos under Hidden Art.

| # | Scenario | Steps | Expected | Manual checks |
|---:|---|---|---|---|
| BX1 | Cross-tradition patron championing (the headline case) | Green Way Breton, fresh save. Commit to **Magnus** as patron (non-resonant for Green Way); take Magnus to Champion (85). | Magnus reaches his own Champion tier and grants the modest `PDV_Bless_Breton_PatronChampion` boon; Green Way tradition family stays capped at T2. | Both surface at once: Magnus Champion recognition (Survey/BoD/toast) AND a Green Way T2 family effect; total always-on effects = 2, not 3; NO Green Way T3 spell |
| BX2 | Resonant patron unlocks tradition T3 (folds old B2) | Any tradition; commit to a patron IN that lane's resonance set (e.g. Knight's Road + Stendarr, or Green Way + Y'ffre); take to Champion. | Tradition T3 family lights and IS the champion payoff; exactly one toast/BoD names the patron as Champion through the lane; NO separate PatronChampion boon stacked on top. | One always-on T3 family + Champion recognition; no double boon; no generic `Devotion deepens` second toast |
| BX3 | Practice-count tier (replaces B1/B1a) | Fresh Breton, any tradition, NO patron and zero pool-god piety. Fire that lane's practice signals (vow acts / occult study / Green Way behavior) to hit the count thresholds. | Tradition T1 lights at the low count threshold, T2 at the high one, with zero deity piety in the pool. | Counter-driven, not piety-driven; caps at T2 without a patron; daily anti-farm cap holds on the count ticks |
| BX4 | Overlap resonance sets | For each overlap: prove the patron sources T3 in a lane it overlaps into. Mara -> Knight's Road AND Green Way AND Hidden Art; Dibella -> Green Way AND Hidden Art (NOT Knight's Road); Kynareth -> Knight's Road AND Green Way. | In each overlapping lane, that patron at Champion sources the tradition T3 (resonant path, not PatronChampion). Dibella under Knight's Road takes the non-resonant PatronChampion path instead. | Resonance membership is name-based and correct per lane; Dibella is explicitly NOT resonant in Knight's Road |
| BX5 | Dual-feed (practice tick + deity piety) | Active tradition A, patron in tradition B (off-tradition). Fire a signal in tradition A's set. | The practice counter for A ticks (tradition-gated), AND the deity(s) the signal maps to still receive piety regardless of active tradition. Off-tradition patron keeps earning piety. | Piety is never tradition-gated; only the practice tick is; CrossTraditionPressure still records an off-tradition source |
| BX6 | Julianos sleep-handler fix | Hidden Art Breton; trigger the hearth-cover sleep signal (`HandleBretonSleepEvents`). | Mara receives the hearth-cover credit; Julianos does NOT get a LAWFUL_ORDER award from sleep. Julianos credit now comes only from study signals (341/342). | The old miswire is gone: no Julianos movement on a Hidden Art sleep; Mara hearth-cover present |
| BX7 | Pulse retune (no track pegging) | Any lane; fire a single renewable practice signal and read the pressure track delta. | Renewable source moves the track a small amount (+2..+5), not +25; a curated source ~+5; a milestone +15..20. Track no longer pegs 0->100 in ~2 acts. | Neglect/fray decay stays meaningful because the track is not instantly maxed; magnitudes match spec section 2 |

Ledger note: once these pass, the two-axis build re-opens the felt-family verdicts
for `Breton-GreenWay|boon`, `Breton-HiddenArt|boon`, and adds
`Breton-PatronChampion|boon`; sink evidence into `PDV_FeltFamilyEvidenceLedger.json`
and re-run the felt gate. B1/B1a evidence stays as historical (pool-gated build)
and is NOT carried forward as two-axis proof.

## Book-Read Unread Cap Card (2026-07-12)

Proves the once-ever per-book guard from the 2026-07-12 follow-up. **Compile +
readback proven**; this card closes the runtime-route and manual-display
buckets. Origin does not matter (any race); use a lore god's origin so the 342
credit is reachable (e.g. Imperial index 1 reaches Arkay/Julianos). Set
`PDV_GLO_DebugLevel to 2` and watch the Papyrus log plus the piety readout.
Repeat traces to watch for: `Generic book read repeat skipped: <formID>` and
`Spell tome learn repeat skipped: <formID>`.

| # | Scenario | Steps | Expected | Manual checks |
|---:|---|---|---|---|
| BR1 | Lore book once-only | Read any unlisted lore book, then close and re-read the same book. | First read gives one 342 credit; re-read logs `Generic book read repeat skipped` and awards nothing. | Piety readout moves once only; no toast/Book of Days on the repeat |
| BR2 | Skill book once-only | Read a `PDV_FLST_FaucetSkillBooks` entry, then re-read it. | First read gives one 340 credit; re-read is skipped. | Piety guard is independent of vanilla skill training; trace fires on repeat |
| BR3 | Spell tome, unknown spell | Read a tome for an unknown spell (consumed on learn); `player.additem` another copy of the same tome and read it (spell now known, book opens). | Learn gives one 341 credit via `OnItemRemoved`; the second copy logs `Spell tome learn`/`Generic book read repeat skipped` and awards nothing. | Shared key holds across the two ingresses; no double-credit |
| BR4 | Spell tome, already-known spell | Read a tome whose spell is already known and never routed before, then re-read. | First read gives one 341 credit via `OnBookRead`; re-read skipped. | Single credit; repeat trace present |
| BR5 | Once-ever, not once-per-day | After BR1-BR4, wait 24+ game hours and re-read any of those books; then read a brand-new unread book. | Old books stay skipped after the day rollover; the new book credits normally. | Guard is permanent per form, and does not over-suppress fresh books |
| BR6 | Daily book faucets need unread book | While Azura/HM faucet-eligible, read a fresh book (first-ever) and note the faucet credit; next day, re-read the same book, then read a new one. | Azura `fate_threshold` / HM `disciplined_study` credit only the unread book; the re-read gives no faucet credit; a new book does. HM `forbidden_knowledge` behaves exactly as before. | Forbidden-knowledge per-form guard unchanged; no daily refresh off a re-read |
| BR7 | Non-regression: P2 + Altmer | Read a P2 racial-source book twice, and the Talos Mistake once. | P2 once-ever behavior and the Altmer one-shot are unchanged from before the fix. | No behavior change on the already-guarded paths |

## 1.0 Open Gate Map

The generated burndown is current authority. These are the practical closeout
lanes this runbook feeds:

| Criterion | How testing closes it | Evidence sink |
|---|---|---|
| C-RACE-RUBRIC | Re-run the race beta-feel packet for any race whose ledger verdict regresses below Pass (currently STALE from source drift) | Per-race beta-feel packet ledgers |
| C-FELT-FAMILY | Work the ten checklists in **Felt-Family Race Sittings (deduplicated plan)** above - every pending family (107 at snapshot), each proven once | `PDV_FeltFamilyEvidenceLedger.json` |
| C-DISLIKE-DEBUFF-TUNING | Dedicated anti-stack/Requiem-felt sitting | `PDV_1_0_ManualSignoffLedger.json` (`dislikeStackTuning`) |
| C-PACING-SIGNOFF | One dated real-play pacing sign-off per race | `PDV_PacingSignoffLedger.json` |
| C-PLACEMENT-FINAL | Pending in-world hook proofs folded into race sittings | `PDV_InWorldHookProofLedger.json` |
| C-REQUIEM-TRACKB | Authoria/Requiem sweeps A, B1, and B2 | `PDV_1_0_ManualSignoffLedger.json` (`requiemTrackB`) |
| C-EXPMODE-SMOKE | Pilgrim's Path and Wayfarer's Path runtime smoke | `PDV_1_0_ManualSignoffLedger.json` (`experienceModeSmoke`) |
| C-COMPAT-ARR | Accepted ARR package evidence | `PDV_1_0_ManualSignoffLedger.json` (`compatARR`) |
| C-COMPAT-BORDELLO | Six list compatibility packages | `PDV_1_0_ManualSignoffLedger.json` (`compatBordello`) |

If the burndown reports machine gates as RED because of drift, close that first.
Those machine gates are not replaced by manual smoke notes.

`C-PRINCE-GATE` is machine-PASS and does not block 1.0, so it is not a closeout
lane above. It does still carry open Daedric runtime evidence slots in
`PDV_DaedricRuntimeEvidenceLedger.json` (via
`pdv_daedric_evidence_intake.mjs`). Optional but recommended: when a Daedric
pact is active during a race sitting, spot-check Prince surfacing in Survey and
Book of Days and record the slot. Deeper Prince path work is explicitly post-1.0
(`X-MEGA-F`).

## Capture Template

Use this when reporting a result back to Codex:

```text
Scenario or gate:
Save/origin:
Route used: organic / controlled MCM / both
Commands or actions:
Papyrus marker:
Book of Days:
Survey/status:
Toast/Prisma:
Active Effects/stack:
Repeat/save-load:
Wrong-origin/generic silence:
Verdict by bucket: backend / runtime-route / manual-display / defect
Notes:
Screenshot/log snippet:
```

Codex should then update the structured ledger or file a defect, never just
reply "pass" in chat.

## Stop Conditions

Stop the sitting and capture the save/log if any of these happen:

- A route fires for the wrong race, wrong origin, or a generic source that
  should be silent.
- A generated Book of Days line is blank, stale, duplicated, or names the wrong
  deity/surface.
- A toast, Prisma panel, Survey/status, or Active Effects label exposes raw IDs,
  counters, dev labels, or missing text.
- A repeat route stacks after it should be latched, capped, or blocked.
- Save/load changes piety, rewards, neglect, price, or disfavor state by itself.
- A Requiem-felt debuff over-stacks, is invisible, never fades, or bites
  ordinary play.
- A debug-controlled route is accidentally treated as organic proof.
- The generated burndown or smoke ledger regresses after evidence recording.

## What To Ask During Testing

Use short prompts so Codex can answer with exact next steps:

- "What is next from the co-test runbook?"
- "I am on origin <race>; what should I run now?"
- "Here is what I saw for scenario <n>."
- "This looked wrong: <symptom>."
- "Which ledger does this close?"

Codex should answer with the next command/action, the expected visible surfaces,
and the proof bucket it would close.
