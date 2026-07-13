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

- Signal-floor smoke gate: **PASS after DLC2SV01, MQ305, MQ206, DBDestroy, MS10, CR13, MQ302, crypt-clear, LD v16, and Green Way retests**. The source/runtime-JSON
  / MCM harness checks pass, and the 2026-07-10 source fix reachability-gates
  `TABOO` / `HOSTILE` non-Daedric quest reactions before they can write piety
  or Book of Days surface. Cards 1, 2, 3, 4, 5, 6, 7, 8, 9, and 10 now have in-game manual
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
node .\tools\pdv_prisma_to_oneoh_audit.mjs --json
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
- Quest matrix after the 2026-07-12 matrix-freshness package: **1055 rows, 168
  quest keys, 134 watched quests, 26 faucet acts.** (The earlier 1057/169/135
  prediction was wrong: Package B found tranche10's `MQ105Ustengrav` rows were
  silently DROPPED at compile because the key drifted from the established
  `MQ105U` manual-FormID mapping. Normalizing the key surfaced a duplicate Kyne
  prove_by_struggle row already authored by tranche7, which was removed; the
  tranche10 Akatosh keep_oath row now deploys. Net: -1 row vs the old 1056, and
  the Horn-trial cell finally carries its tranche10 credit.) If the tools report
  1056 / 168 / 134, the MQ105U fix is not merged; regen with
  `pdv_quest_tranche_merge` + `pdv_quest_matrix_compile`.
- `pdv_deity_signal_remap_adversary_check`: PASS. Its
  `potentialOffRosterHostileSurfaces` count is expected to remain nonzero
  because the source guard, not row deletion, owns that cross-origin policy.
- Likes/dislikes version: `LIKES_DISLIKES_VERSION = 16`.
- Signal-floor smoke gate: backend PASS; runtime OPEN is expected until live
  Papyrus markers exist. Live co-test now has runtime/manual proof for Cards
  1, 2, 3, 4, 5, 6, 7, 8, 9, and 10; regenerate the generated ledger before treating this
  summary as machine authority.
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
| 1 note | 2026-07-12 Altmer live proof | `setstage DLC2SV01 200` after `PDV_GLO_OriginRace = 3` | `Y'ffre` and Syrabane landed; The Hist skipped as foreign; `105290|200` completed. | Tester confirmed visible Y'ffre spelling with apostrophe; this also closes RM2. |
| 2 | Main-quest death gods and Dagon correction | `setstage MQ305 200`; controlled MCM index 2 | Arkay and Tu'whacca milestone gains, Khenarthi gain, Mehrunes Dagon loss | Dagon is a loss; reachable gods only; repeat after save/load does not stack |
| 3 | Main-quest lore gods | `setstage MQ206 220`; controlled MCM index 3 | Source rows include Julianos, Hermaeus Mora, Magnus, Xarxes, and Dagon; Altmer display is roster-gated: Magnus/Xarxes visible, Dagon loss visible, no Shor/Talos/Nord combat fan-out | Lore gains visible where reachable; Dagon correction remains negative; no stale Nord fan-out |
| 4 | Sithis strongest negative | `setstage DBDestroy 200`; controlled MCM index 4 | Split-origin proof: Argonian shows the Sithis milestone loss; Nord or Breton shows the Stendarr/Talos gains | Argonian Sithis loss is strongest negative; Nord/Breton Stendarr/Talos gains are visible |
| 5 | Zenithar milestone | `setstage MS10 100`; controlled MCM index 5 | Split-origin proof: Nord/Imperial/Breton shows the Zenithar milestone gain; Bosmer shows the Z'en small gain | Zenithar and Z'en gains are visible where reachable |
| 6 | Hircine cure dislike | Controlled MCM index 6 for this sitting. Organic proof requires an active Companions `CR13` Farkas/Vilkas Purity quest; a generic werewolf save plus `setstage CR13 200` is not reliable. | Hircine loss plus Y'ffre gain | Controlled route/display proof now; organic CR13 proof remains separate unless the save is already on the active cure quest |
| 6 note | 2026-07-12 Bosmer controlled proof | MCM Signal-floor smoke `CR13 200` after `PDV_GLO_OriginRace = 4` | Hircine received negative piety; Y'ffre received positive piety; `930147|200` completed with 2 cells. | Tester confirmed visible Hircine loss plus Y'ffre gain; organic Companions cure remains separate proof. |
| 7 | Season Unending | `setstage MQ302 300`; controlled MCM index 7 | Imperial shows Mara, Stendarr, and Akatosh; Stuhn skips there by roster gate. Nord shows Stuhn too. | Stage 300 smoke stands in for the concession-stage coverage set |
| 8 | Crypt clear | Enter and clear a listed undead crypt through a load door; Bleak Falls is acceptable; controlled MCM index 8 only for route smoke | Rows exist for Arkay, Meridia, Stendarr, Tu'whacca, Azura, and Y'ffre, but visible outcome is origin/stance gated. Nord proof: Arkay/Meridia/Stendarr gains, Azura taboo loss, Tu'whacca/Y'ffre skip. | Same-site repeat stays blocked/capped; `coc` is not organic proof |
| 8 note | 2026-07-12 Nord controlled proof | MCM Signal-floor smoke `Crypt clear` after `PDV_GLO_OriginRace = 0` | Arkay +6, Meridia tolerated +1.2, Stendarr +4; Tu'whacca and Y'ffre skipped as foreign; Azura took the expected Nord taboo loss. | Tester confirmed visible route fired; organic load-door crypt clear remains separate proof. |
| 9 | Likes/dislikes v15 | Fresh or unstamped save; fire vampire feed 366 and non-combat animal kill 303; controlled MCM index 9 | Arkay/Stendarr losses for 366; Kyne/Kynareth losses for 303; v15 reload marker | Daily caps hold; old save loads the v15 table once |
| 9 note | 2026-07-12 Nord controlled proof | MCM Signal-floor smoke `Likes/dislikes v15` after `PDV_GLO_OriginRace = 0` | Runtime loaded likes/dislikes table version 16, fired Kyne event 303 and Arkay event 366, and completed the controlled debug route. | Tester confirmed visible proof passed. UI cleanup queued: because this debug button fires two separate event types, it currently produces two event-scoped toasts/Book-of-Days lines; decide whether the debug scenario should instead batch them into one summary surface. |
| 10 | Green Way behavior | Bosmer Old Contract: visit sacred site, then consume plant food; controlled MCM index 10 only for route smoke | Y'ffre site gain and plant-consumption loss | Plant proof must use real item consumption; debug route is not enough |
| 10 note | 2026-07-12 Bosmer controlled proof | MCM Signal-floor smoke `Green Way` after `PDV_GLO_OriginRace = 4` | Bosmer nature-site evidence recorded, Y'ffre green site remembered, Green Pact compliance dropped, and Y'ffre received the plant-violation loss. | Tester confirmed controlled surfaces passed; organic plant-food proof remains separate. |
| 11 | Paarthurnax kill fork | Reachable listed-god race, Nord recommended; kill Paarthurnax; controlled MCM index 11 only for route smoke | Shor/Tsun/Kyne/Stendarr/Stuhn/Mara reactions; Khajiit keeps Alkosh chaos-aid case | Repeat after save/load is blocked |
| 11 note | Prior controlled proof, do not rerun by default | 2026-07-11 generated ledger/manual evidence records controlled MCM Card 11 proof. | Shor, Tsun, Kyne, Stendarr, Stuhn, and Mara reactions landed, followed by `SignalFloorSmoke Paarthurnax kill debug routed`. | Organic kill, repeat-after-load, and Khajiit organic display remain backlog/waived, not current-sitting requirements. |
| 12 | Paarthurnax spare fork | Paarthurnax alive and neither latch set; complete/load `MQ305` stage 200; controlled MCM index 12 only for route smoke | Stuhn/Stendarr/Mara/Kyne gains once | If kill latch already fired, spare remains silent |
| 12 note | Prior controlled proof, do not rerun by default | 2026-07-11 generated ledger/manual evidence records controlled MCM Card 12 proof. | Stuhn, Stendarr, Mara, and Kyne reactions landed, followed by `SignalFloorSmoke Paarthurnax spare debug routed`. | Organic spare/latch proof remains backlog/waived, not a current-sitting requirement. |
| 13 | Borderline prove-or-drop rows | Review `DA14Start` s70, `DLC2RRFavor01` s200, `T03` s105, HearthFires adoption stages | Decide prove, revise, or drop | Manual review only; no generated runtime marker expected |

## Prisma Panel Regression Card

Run this after any Prisma, manager summary/survey, Book of Days, toast, or
`JsonSafeString` change. It proves the focused panel can parse a real payload
whose summary source includes recent-event line breaks.

Preconditions:

- `node .\tools\pdv_prisma_to_oneoh_audit.mjs --json` returns PASS.
- `node .\tools\pdv_prisma_ui_audit.mjs` returns PASS.
- `PDV__ManagerQuest`, `PDV_T3DailyLowHealthSaveEffect`, and `PDV_MCM` compile
  0/0 if touched.

| # | Scenario | Route to run | Expected result | Required manual checks |
|---:|---|---|---|---|
| PJ1 | Focused panel summary JSON escaping | On a live save, perform any piety-moving act that writes a recent devotion event. Then use the Player MCM page `Open Devotion panel` key path, not `cqf`, to open the focused panel. | The Today/summary panel renders. No `Bad JSON` status appears. Summary text may be flattened to one line where the source Survey text had line breaks. | Toast/Prisma panel visible, no blank panel, no parser error in the Prisma status text or native log, ESC/X closes the panel, Book of Days still opens/closes separately. |
| PJ1 note | 2026-07-12 live panel proof | Player MCM `Open Devotion panel` after piety-moving smoke routes. | Focused panel rendered and closed; Book of Days still opened/closed separately. Prisma bridge log recorded panel close at 19:50:43 with no Bad JSON/parser error. | Tester confirmed manual pass. |
| PJ1 note | 2026-07-12 header status-pill regression | The focused panel still exposed the debug-style `Live` state pill in its header. | Repo and live Anvil Prisma assets now match: visible `pdv-status` header node removed, two JS status writes guarded, and cache-bust string bumped to `no-live-pill-20260712`. Narrow `PDV_MCM` recompile cleared the dependency freshness gate. | `pdv_prisma_ui_audit` PASS 90; retest by reopening the focused panel and confirming no `Live` pill/button appears. |
| PJ1 note | 2026-07-12 panel style parity check | Tester also reported the expected panel visual upgrade, including border-weight changes, looked absent. | `styles.css` matched byte-for-byte between repo and live Anvil copy; no second `PrismaUI/views/Devotion` bundle was found in the active Anvil mods tree. | If the old border persists after a full panel reload, treat the border change as not present in the current stylesheet rather than a live-copy overwrite regression. |

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
- `Reload quest matrix` in MCM reports the expected 134 core watched quests
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
| RM1 | Runtime JSON deployed and reloadable | Run matrix compile/deploy, then MCM Developer Options -> `Reload quest matrix`. | MCM reports 134 core watched quests; ARR channel is regenerated if present. | If counts are stale, stop before testing quest rows. |
| RM2 | `Y'ffre` spelling class | Fire one landed tranche10 row whose matrix deity name is exactly `Y'ffre`. | Runtime lands on `PDV_Yffre`, not a silent zero-row drop. | Book of Days/toast names Y'ffre correctly; no fallback `Yffre` miss. |
| RM3 | `Baan Dar` spelling class | Fire one landed row whose matrix deity name is exactly `Baan Dar`. | Runtime lands on `PDV_BaanDar`. | Display keeps the space and does not expose raw EditorID spelling. |
| RM4 | `Azura` spelling across Dunmer and Khajiit | Fire one landed `Azura` matrix row as Dunmer, then one as Khajiit. | Both land on `PDV_Azura`; Khajiit focus copy can still present Azurah elsewhere without breaking matrix routing. | Record both origins separately; no apostrophe/name-normalization silent drop. |
| RM5 | Wrong-origin silence | Fire one known Khajiit-roster-only or origin-limited row as an unrelated origin, Altmer recommended. | The route stays silent or only reachable deities surface. | No off-roster hostile/taboo fan-out; adversary check remains PASS. |
| RM6 | ARR compatibility matrix freshness | Regenerate the ARR package from the current matrix after core JSON is green. | ARR `PDV_QuestReactionMatrix_ARR.json` no longer predates tranche10; no new Requiem masters. | Backend/package proof only unless running an ARR profile smoke. |

2026-07-12 live matrix notes:
- RM1 passed in-game/log: `Quest matrix reloaded: core 134 watched, ARR 20 watched`.
- RM3 passed as Khajiit via `setstage TG05 60`: `Baan Dar` landed/displayed with the space; HoonDing foreign reachability skipped.
- RM4 passed for Khajiit and Dunmer via `setstage DA01 100`: canonical matrix display `Azura` is acceptable; Khajiit-specific focus bridge still used Azurah internally.
- RM5 passed as Altmer via `setstage TG05 60`: `Baan Dar`, `HoonDing`, and the Khenarthi meta-faucet were skipped as unreachable foreign rows; no Baan Dar piety award or Khajiit focus bridge appeared.
- RM2 passed as Altmer via `setstage DLC2SV01 200`: `Y'ffre` landed and displayed with the apostrophe; Syrabane landed; The Hist skipped as unreachable foreign. This also closes Signal-floor Card 1 for Altmer-visible fan-out.

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

RE-OPEN NOTE (2026-07-13): the project-wide Magicka/Stamina regen -> Fortify
max-pool conversion (`PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`)
INVALIDATES any already-recorded `boon` felt-proof whose observed effect was a
Magicka/Stamina (or the 2 Argonian Health-substrate) REGEN bar - the effect is now
a flat pool MAX, so the expected Active-Effects observation changed from "regen
faster" to "Maximum Magicka/Stamina/Health rises by the Fortify amount." Before
crediting a `boon` tick for an M/S-reward family, re-prove it under Requiem as a
pool-MAX effect (see `PDV_RequiemSmokeTest_Tracker.md` Sweep C). Known
already-recorded proofs to re-open: Bosmer (BetaTestPacket L643), Breton Magnus
champion (BetaTestPacket L13), Argonian Rooted-Rest, Redguard Tu'whacca. The
Fortify magnitudes are PROVISIONAL - this sitting doubles as the tuning pass.

ADDENDUM 2026-07-13 (variety-batch live converts): three variety-batch rewards had
their LIVE `Devotion.esp` MGEFs converted RateMult -> Fortify in the 2026-07-13
closeout and need FIRST-TIME felt proof (not a re-proof): Argonian
`PDV_SPEL_ArgonianAdapt_Sap` (Fortify Magicka +10) and `PDV_SPEL_ArgonianAdapt_Marsh`
(Fortify Stamina +15), and Bosmer `PDV_SPEL_BosmerNaming_Wanderer` (Fortify Stamina
+15). These are NOT tracked in `PDV_FeltFamilyEvidenceLedger.json` (the felt registry
generator reads only race `RewardRecords` specs), so they will NOT appear in the race
sittings below - prove them via `PDV_RequiemSmokeTest_Tracker.md` Sweep C card **C13**
and sink the result into the `requiemTrackB.sweepC` slot of
`PDV_1_0_ManualSignoffLedger.json`. Khajiit Lunar T1 was already Fortify +15 (not a gap).

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
Tradition T1/T2 now lights from weighted practice points
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
- [x] `Breton-GreenWay|boon`  (`Green Way - Seeker`; organic mixed-source practice pass 2026-07-13)
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

Also-in-this-origin (NOT a felt-family row; sink to `requiemTrackB.sweepC`, see the
Sweep C addendum above): while on Bosmer, run Sweep C **C13** for
`PDV_SPEL_BosmerNaming_Wanderer` (Fortify Stamina +15) - confirm Max Stamina rises in
Active Effects when the Naming "Wanderer" told-self ability is granted.

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

Also-in-this-origin (NOT felt-family rows; sink to `requiemTrackB.sweepC`, see the
Sweep C addendum above): while on Argonian, run Sweep C **C13** for the two Adapt
converts - `PDV_SPEL_ArgonianAdapt_Sap` (Fortify Magicka +10) and
`PDV_SPEL_ArgonianAdapt_Marsh` (Fortify Stamina +15) - confirm Max Magicka / Max
Stamina rise in Active Effects when the Sacred-Waters adapt abilities are granted.

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
- 2026-07-12: BACKEND CLEANUP QUEUED FOR NEXT SKYRIM-CLOSED WINDOW. Matrix registration currently calls `Game.GetFormFromFile` for optional package rows whose plugins are not loaded (`ccbgssse020-graycowl.esl`, `Vigilant.esm`, `Glenmoril.esm`, `Unslaad.esm`, `Olenveld.esp`, `Skyrim Extended Cut - Saints and Seducers.esp`, `ForgottenCity.esp`, `DAc0da.esm`, `EbonyBladeCurse.esp`). Core still reports 134 watched and ARR reports 20 watched, so this is not blocking the current co-test, but the backend should avoid Papyrus error spam for optional missing-plugin rows.
- 2026-07-12: HOTFIX for B2 focused Champion presentation. Tester reported that Julianos-at-85 granted the Knight's Road T3 route in the log but the visible toast used the public `Devoted` band and did not clearly call out Julianos as Champion. `PDV__ManagerQuest` now keeps public tier bands for ordinary standing, but tier toasts use `Champion` for Champion reaches, and Breton T3 tradition presentation names the focused patron (`Julianos names you Champion through the Knight's Road.`) while still granting the tradition reward spell (`Knight's Bulwark - Champion`). Synced to live MO2 source; `PDV__ManagerQuest` and `PDV_MCM` compile 0/0; verifier FAIL=0 WARN=1; Prisma UI audit PASS 89. Manual B2 retest is still owed after relaunch/reload because the running game had the old PEX loaded.
- 2026-07-12: B2 partial runtime/manual proof recorded after the focused Champion hotfix. Active Effects now shows the T3 reward stack as `Knight's Bulwark - Champion` with Armor, Block, and Magic Resistance. This proves the focused Champion reward/effect stack side of B2, but does not by itself prove the updated toast/Book of Days patron wording; that presentation retest remains open.
- 2026-07-12: HOTFIX follow-up for B2 duplicate Champion toasts. Retest showed the intended Breton-specific toast (`Julianos names you Champion through the Knight's Road.`) plus an extra generic tier toast (`Devotion deepens / Julianos names you Champion.`). Architecture check confirmed this was not a rejection of the focused-patron model: Breton lanes are two-phase, with broad tradition T1/T2 and focused patron T3. Source now suppresses the generic tier surface only for Breton in-tradition focused Champion transitions and lets the Breton tradition presentation own the single toast/Book-of-Days entry. Synced to live MO2 source; `PDV__ManagerQuest` and `PDV_MCM` compile 0/0; verifier FAIL=0 WARN=1; Prisma UI audit PASS 89. Manual B2 presentation retest still owed after full Skyrim relaunch.
- 2026-07-12: BOOK-READ FARM CLOSED. The generic book faucet (events 340 skill / 341 spell tome / 342 lore) never tracked "already read", so the same lore book could be re-read up to its per-deity daily cap every day forever, and the once-per-day Azura/Hermaeus Mora book faucets refreshed off any shelf book. Fix in `PDV_PlayerEvents.psc`: a once-ever `PDV.BookRead.<formID>.Seen` guard (`MarkGenericBookRead`) marks each book base form on first read, shared across `OnBookRead` and the `OnItemRemoved` consume-on-learn tome ingress so a learn plus a later re-read of another copy credit exactly once. Azura `fate_threshold` and HM `disciplined_study` now also require an unread book; HM `forbidden_knowledge` keeps its own per-form manager guard and is untouched, as are the P2 racial-source and Altmer Talos-Mistake one-shots. Compile 0/0; verifier FAIL=0. Runtime-route + manual-display proof owed via the Book-Read Unread Cap card below. Save-compat: existing saves have no seen keys, so every previously-read book credits once more post-update, then never again (expected, no migration).
- 2026-07-12: PRISMA JSON ESCAPING HOTFIX LANDED. `JsonSafeString` now strips ASCII control characters in the manager and low-health toast helper before Prisma JSON emission, closing the focused-panel `Bad JSON` failure when `GetSurveyDevotionText()` contributes recent-event newlines to the panel summary. Synced to live MO2 source; manager, low-health effect, and MCM compile 0/0; verifier FAIL=0 WARN=1; `pdv_prisma_to_oneoh_audit` PASS 74/0; Prisma UI audit PASS 89. Manual PJ1 panel smoke remains owed.
- 2026-07-12: RESERVED-SIGNAL UI HOTFIX LANDED. RS1/RS2 panel capture without toast/Book of Days was a real manager surfacing gap, not tester procedure: the Khenarthi `CARAVAN_AID`, Rajhin `LEGEND_MADE`, Mephala `WEB_WOVEN`, and Boethiah `HONORABLE_DUEL` handlers awarded piety and trace markers but did not call the Prisma/Book-of-Days surface path. `PDV__ManagerQuest` now routes all four through `SurfaceReservedSignal`, writing a Prisma toast, Book of Days chronicle entry, recent-event panel line, and panel refresh after the daily cap accepts the pulse. Khajiit shared-deity display resolves Boethiah/Mephala as Boethra/Mafala on Khajiit and keeps Boethiah/Mephala elsewhere. `pdv_prisma_ui_audit` now guards this class. Synced to live MO2 source; manager and MCM compile 0/0; verifier FAIL=0 WARN=1; `pdv_signal_e2e_gate` PASS; `pdv_prisma_toast_fallback_audit` PASS; Prisma UI audit PASS 90; Book of Days audit PASS=125 WARN=0 FAIL=0. Do not mark the pre-fix no-toast attempts as display proof.
- 2026-07-12: RS1-RS4 controlled post-hotfix runtime/manual proof PASSED. Tester confirmed the toast and Book of Days UI pass after full relaunch. Current `Papyrus.0.log` confirms all four controlled MCM routes landed in the same sitting: Khenarthi caravan-aid 18:54:33-18:54:34, Rajhin legend-made 18:54:39-18:54:40, Mephala web-woven 18:54:47, and Boethiah honorable-duel 18:54:51-18:54:52. No `Bad JSON`, Prisma error, or Book-of-Days error appeared in the current Papyrus/Prisma bridge logs. This closes controlled MCM route+display proof for RS1-RS4; any organic-source variants remain separate proof, not required to validate the hotfix.

- 2026-07-12: BRETON TWO-AXIS SPLIT LANDED; ready for BX smoke after a full Skyrim relaunch/new save. Owner ruled the 2026-07-11 pool-as-T3-gate model an error; the intent was always two orthogonal axes (tradition = practice track; patron championing over the full 11-god roster, so a Green Way Breton can champion Magnus). Authority: `PDV_BretonTwoAxis_BuildSpec_2026-07-12.md`. Source now tiers traditions from practice counts, grants resonant Champion patrons through the tradition T3, grants non-resonant Champion patrons `PDV_Bless_Breton_PatronChampion`, includes Talos in Breton formal offers, and surfaces Breton two-axis state through Survey/status, Book of Days, and Prisma toasts. Pool-gated B1/B1a are historical only; run BX1-BX7 for current proof. Backend/readback gates passed: manager/EventBus/ActionRouter/MCM compile 0/0, Breton reward and formal-offer readback PASS, Prisma UI audit PASS 89, phase-2 reward readback PASS=1415, signal-floor audit PASS 51/51, adversary check PASS, and verifier FAIL=0.
- 2026-07-12: BRETON CO-TEST UPDATE (20:02-20:40 `Papyrus.0.log`). BX2 Hidden Art/Magnus resonant Champion runtime + Active Effects passed: log shows Magnus patron start, Magnus tier 0 -> 3, generic tier surface suppressed for Breton resonant Champion, HiddenArt T1 removed, and HiddenArt T3 added; tester screenshot showed only `Hidden Art - Champion` effects (Conjuration, Illusion, Magicka Regeneration), with no separate PatronChampion stack. Toast/Book-of-Days exact Champion wording was not separately confirmed. BX6 runtime passed: sleep hearth-cover awarded Mara event 314 and no Julianos event 314/LAWFUL_ORDER line appeared. B4 runtime passed for Y'ffre 365/364: 365 applied `OrderTradeLore Light` / `Order sours for a while` Active Effect and -1.0 loss; 364 applied -0.5 loss and debug surface. Only one Book of Days line across 365/364 is expected because both debug dislike surfaces write the same same-day `Y'ffre took offense at the act.` line and Book of Days de-dupes same day/tone/line. B5 remains open: `DebugFireDislike` correctly reports no Y'ffre dislike row for 303 because 303 is a positive Breton-gated row; prove it through the non-hostile animal kill/action route, not the dislike harness. Practice-count pacing follow-up queued: Hidden Art reached Seeker quickly because practice counts tick per source key/day, not from clamped deity piety.

- 2026-07-13: GREEN WAY ROUTE/UI + SHARED KILL CLASSIFICATION PASS. On the then-live 3/6 build, a fresh Green Way Breton received harvest `event_334`, draugr `event_300`, and `honor_the_wild` as three distinct practice acts. Tester confirmed Survey `3 proven acts`, `Green Way - Seeker` in Active Effects, Book of Days Seeker page text, the first gauge segment, and the tier toast. The first draugr attempt exposed that `PDV_ActionRouter.ActorHasKeyword` checked the actor and leveled base but not the actor race; the shared helper now includes the race fallback, `PDV_ActionRouter` compiles 0/0, and the default declaration gate requires that fallback plus undead-before-NPC ordering. The post-fix log records `event_300` at 14:59:50. This shared module covers every origin/deity consumer of generic kill events. Organic deer `event_303` also passed with Y'ffre +0.25, closing B5. The old same-day Seeker and six-act T2 targets are superseded by the staged 25/50 point contract below; retain this result only as route classification and UI plumbing proof.

- 2026-07-13: GREEN WAY OLD-MODEL DEVOTED ROUTE/UI PASS. The 16:01-16:13 `Papyrus.0.log` session began from the prior three-act Green Way save, then accepted `event_303` non-hostile animal at 16:05:19, `event_333` cook-meal at 16:08:30, and `event_313` rest-under-open-sky at 16:11:50. At 16:11:49 the manager removed `Breton GreenWay T1` and added `Breton GreenWay T2` once. Tester confirmed Survey `6 proven acts`, `Green Way - Devoted`, second Book-of-Days gauge segment, Devoted page text, and one toast. No PDV/Prisma JSON or transition error appears around the award. This closes the retired 3/6 build's Green Way T2 route/UI proof only: the session predates the 16:21 deployment of the shared 25/50 practice-point conversion and cannot prove its pacing.

- 2026-07-13: KILL CLASSIFICATION FOLLOW-THROUGH DEPLOYED. Generic undead/Daedra/dragon/NPC/animal/creature classification remains centralized in `PDV_ActionRouter`, so no race- or deity-specific copies are needed. Audit found the separate PO3 Paarthurnax/Khajiit dragon path still used direct actor-only `ActorTypeDragon` checks; `PDV_PlayerEvents` now uses actor/base/race inheritance there too. `pdv_verify` consumes the classifier gate as default-fail and explicitly verifies live `PDV__SM_KillActorNode` parent, receiver, previous sibling, and `SharesEvent` wiring. `PDV_PlayerEvents` synced and compiled 0/0; normal verifier PASS with both new checks; forced classifier self-test correctly FAILs. A Khajiit/Paarthurnax dragon regression smoke remains manual runtime proof.

- 2026-07-13: BRETON SURVEY COPY CLEANUP DEPLOYED. Green Way Survey was presenting three competing status statements (`Practice: Observant`, generic deity `Standing: Distant`, and covenant `open but unproven`) even though practice points are the Breton lane authority. The live manager now omits generic standing from chosen Breton traditions, shortens the neutral Green Way pressure line to `Y'ffre is listening.`, and tightens the beast-fork sentence. The same pass replaces stale generic Champion `patron's mark` copy in Survey/toast with the actual boon name required by the unified Champion model. Manager/MCM compiled 0/0; Book of Days audit PASS=126 WARN=0 FAIL=0; Prisma UI audit PASS=92; verifier FAIL=0. Confirm the shorter Survey once after relaunch.

- 2026-07-13: BRETON PRACTICE PACING REWORK DEPLOYED; RUNTIME PACING PROOF OPEN. Runtime proof showed the 3/6 integer-count model could reach Seeker and Devoted from three/six distinct source keys in one day. Owner target is Seeker no earlier than day 7 and preferably near day 10, paced like deity piety. The live manager now treats the existing tradition count stores as weighted practice points: renewable actions +1, curated quest/tag or dedicated tradition signals +2, aggregate maximum 4 points per in-game day, Seeker 25, Devoted 50. The existing per-source once/day guard remains. This yields earliest Seeker day 7 and earliest Devoted day 13; ordinary 2-3 point days reach Seeker around days 9-13. `Seed broad lane (origin)` now seeds the active Breton tradition to 50 instead of writing retired `PDV.Breton.TraditionHookCount`. Existing 2026-07-13 three-act evidence remains valid for route classification, reward/UI plumbing, and source diversity only; it no longer proves current pacing or the new threshold. Manager/MCM compiled 0/0; pacing adversary PASS; Book of Days audit PASS=126 WARN=0 FAIL=0; Prisma UI audit PASS=92; verifier FAIL=0. Retest the daily ceiling and 25/50 thresholds after a full relaunch.

- 2026-07-13: ALL-THREE BRETON CONVERSION PARITY + VMAD NOISE CLEANUP COMPLETE. The adversary gate now fails unless Knight's Road, Hidden Art, and Green Way each route renewable actions through +1, curated tags through +2, the shared four-point daily budget, capped practice stores, and the same concise Survey `Practice: <band> (<points> practice points).` line with no `proven acts`. Direct houseCARL readback found the retired `PDV_Faction_Hunted_Vigilant` binding still serialized as manager VMAD property 159 despite its Papyrus declaration being gone; the property entry was removed in place after backup while preserving the faction record. Post-write houseCARL readback reports 469 manager properties and no retired binding. The verifier now default-fails if that binding returns. Final gates: verifier FAIL=0, adversary PASS, Book of Days PASS=126 WARN=0 FAIL=0, Prisma UI PASS=92.

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
| B4 | PASSED 2026-07-12 - Green Way Y'ffre dislikes (softer set) | Green Way Breton, fresh save. Fire raise-undead (365) and assault-innocent (364). | Y'ffre loss surfaces for both; necromancy is the stronger (-medium) | Log proved 365 -1.0 and 364 -0.5. Tester screenshot proved 365 Active Effect `Order sours for a while.` / `Favor Slips`. One Book of Days entry across 365/364 is expected because both debug dislike surfaces write the same same-day line and de-dupe. |
| B5 | PASSED 2026-07-13 - Green Way hunt like | Same save; kill wild game (non-combat animal, event 303). Do not use `DebugFireDislike`; 303 is a positive row. | Y'ffre small gain (respectful hunt); cook-meal also gains | Organic deer kill passed. `Papyrus.2.log` records Green Way practice from `event_303`, Y'ffre `+0.25`, and completed event-303 fan-out. |

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
  reads weighted practice points at 25/50.
- Record `PDV_Bless_Breton_PatronChampion` exists (spec + readback).
- `LIKES_DISLIKES_VERSION = 16`.
- `HandleBretonSleepEvents` no longer awards Julianos under Hidden Art.

| # | Scenario | Steps | Expected | Manual checks |
|---:|---|---|---|---|
| BX1 | Cross-tradition patron championing (the headline case) | Green Way Breton, fresh save. Commit to **Magnus** as patron (non-resonant for Green Way); take Magnus to Champion (85). | Magnus reaches his own Champion tier and grants the modest `PDV_Bless_Breton_PatronChampion` boon; Green Way tradition family stays capped at T2. | Both surface at once: Magnus Champion recognition (Survey/BoD/toast) AND a Green Way T2 family effect; total always-on effects = 2, not 3; NO Green Way T3 spell |
| BX2 | ACTIVE EFFECTS PASS 2026-07-12 - Resonant patron unlocks tradition T3 (folds old B2) | Any tradition; commit to a patron IN that lane's resonance set (e.g. Hidden Art + Magnus, Knight's Road + Stendarr, or Green Way + Y'ffre); take to Champion. | Tradition T3 family lights and IS the champion payoff; exactly one toast/BoD names the patron as Champion through the lane; NO separate PatronChampion boon stacked on top. | Runtime + Active Effects passed for Hidden Art/Magnus: `Hidden Art - Champion` Conjuration, Illusion, and Magicka Regeneration only; no separate PatronChampion stack. Still owed if needed: exact toast/Book-of-Days patron wording capture. |
| BX3 | ROUTE/UI PASS; 25/50 PACING OPEN - Practice-point tier (replaces B1/B1a) | Fresh Breton, any tradition, NO patron and zero pool-god piety. Earn varied practice points across multiple days. | Renewable +1, curated +2, no more than 4 total points per day; T1 at 25 and T2 at 50 with zero deity piety in the pool. | The old three-source run proved harvest `event_334`, draugr `event_300`, and `honor_the_wild` route into Green Way and that reward/UI plumbing works, but its same-day Seeker result is superseded. Retest daily cap, earliest-day boundary, 25-point Seeker, and 50-point Devoted after deployment. |
| BX4 | Overlap resonance sets | For each overlap: prove the patron sources T3 in a lane it overlaps into. Mara -> Knight's Road AND Green Way AND Hidden Art; Dibella -> Green Way AND Hidden Art (NOT Knight's Road); Kynareth -> Knight's Road AND Green Way. | In each overlapping lane, that patron at Champion sources the tradition T3 (resonant path, not PatronChampion). Dibella under Knight's Road takes the non-resonant PatronChampion path instead. | Resonance membership is name-based and correct per lane; Dibella is explicitly NOT resonant in Knight's Road |
| BX5 | Dual-feed (practice tick + deity piety) | Active tradition A, patron in tradition B (off-tradition). Fire a signal in tradition A's set. | The practice counter for A ticks (tradition-gated), AND the deity(s) the signal maps to still receive piety regardless of active tradition. Off-tradition patron keeps earning piety. | Piety is never tradition-gated; only the practice tick is; CrossTraditionPressure still records an off-tradition source |
| BX6 | RUNTIME PASS 2026-07-12 - Julianos sleep-handler fix | Hidden Art Breton; trigger the hearth-cover sleep signal (`HandleBretonSleepEvents`). | Mara receives the hearth-cover credit; Julianos does NOT get a LAWFUL_ORDER award from sleep. Julianos credit now comes only from study signals (341/342). | Log proved the retired ancestor-spine sleep signal was ignored, Mara event 314 landed, and no Julianos event 314/LAWFUL_ORDER line appeared. Manual surface is optional follow-up if a visible Mara hearth-cover beat is required. |
| BX7 | Pulse retune (no track pegging) | Any lane; fire a single renewable practice signal and read the pressure track delta. | Renewable source moves the track a small amount (+2..+5), not +25; a curated source ~+5; a milestone +15..20. Track no longer pegs 0->100 in ~2 acts. | Neglect/fray decay stays meaningful because the track is not instantly maxed; magnitudes match spec section 2 |

### Breton Unified Champion Cards (2026-07-13, current reward authority)

These cards supersede BX1/BX2/BX4 reward expectations. Practice-count and
dual-feed behavior from BX3/BX5/BX7 remain current. A tradition grants T1/T2;
an active Champion patron always grants that patron's own Champion boon.
Resonance changes presentation only. Authority:
`PDV_BretonUnifiedChampion_BuildSpec_2026-07-13.md`.

| # | Scenario | Steps | Expected | Manual checks |
|---:|---|---|---|---|
| BUC1 | OPEN - Non-resonant Champion brings own boon | Green Way at 50 practice points (use the corrected Breton broad-lane debug seed for controlled reward proof). Set Magnus as debug patron, set Target piety 85, and apply. No dawn is required for the controlled seed. | Green Way remains Devoted and `Magnus's Aperture - Champion` appears beside it. | Exactly two Breton always-on families: Green Way T2 + Magnus Champion. No generic `Patron's Mark`, no Hidden Art T3, one Champion toast/Book entry naming Magnus. |
| BUC2 | OPEN - Resonant Champion also brings own boon | From BUC1, switch patron to Y'ffre and apply Target piety 85. | `Magnus's Aperture - Champion` strips; `Green Way - Champion` appears as Y'ffre's boon while Green Way T2 remains. | Exactly two families remain. One Champion toast/Book entry names Y'ffre through the Green Way; no duplicate generic tier toast. |
| BUC3 | OPEN - Patron swap exclusivity | Continue switching between two already-Champion patrons, then clear the patron override. | Only the current patron's Champion boon is present; clearing patron strips the Champion boon and leaves Green Way T2. | No stale prior-patron effect, no third stack, and Book/Survey identify the current focus. |
| BUC4 | OPEN - Daedric Hidden Art exception | Hidden Art Breton with a Champion Daedric pact through 20C. | `Hidden Art - Champion` is the practitioner capstone; the prince reward remains owned by the pact path. | No generic Aedric Breton Champion copy is added; stack remains within the two-family budget. |

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

2026-07-12 Book-read co-test note: runtime evidence is partial, not a full BR close. BR1 passed for first lore read plus same-book repeat skip (`A Dance in Fire, v1`). BR2 passed for first skill-book read plus same-book repeat skip (`SkillAlteration1`). BR3 proved the first unknown spell-tome learn route, but did not capture the same-tome known-copy repeat skip. BR5 proved old books stay skipped after day rollover, but did not capture a fresh unread book credit after rollover. BR6 remains open; no Azura/Hermaeus Mora unread-book faucet trace was captured. BR7 partially passed for the Breton P2 Hagravens repeat skip; Altmer Talos Mistake one-shot was not captured in this sitting.

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
| C-REQUIEM-TRACKB | Authoria/Requiem sweeps A, B1, B2, **and C (2026-07-13: Magicka/Stamina Fortify-pool rewards + M/S neglect/creed-loss penalties + Daedric Sheo/Hircine + Argonian near-death restore)** | `PDV_1_0_ManualSignoffLedger.json` (`requiemTrackB`) |
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
- The focused Prisma panel reports `Bad JSON`, renders blank, or will not close
  through ESC/X after a panel smoke case.
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
