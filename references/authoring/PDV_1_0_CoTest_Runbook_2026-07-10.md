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

Expected backend state before in-game smoke:

- `pdv_verify`: FAIL=0. The known medallion glyph fallback warning is allowed.
- Quest matrix: 1057 rows, 169 quest keys, 135 watched quests, 26 faucet acts.
- `pdv_deity_signal_remap_adversary_check`: PASS. Its
  `potentialOffRosterHostileSurfaces` count is expected to remain nonzero
  because the source guard, not row deletion, owns that cross-origin policy.
- Likes/dislikes version: `LIKES_DISLIKES_VERSION = 15`.
- Signal-floor smoke gate: backend PASS; runtime OPEN is expected until live
  Papyrus markers exist.

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
2. **Signal-floor representative smoke.** Close the remaining runtime/manual openings
   from `PDV_SignalFloorSmokeLedger.md`. Use the table below. This is the best
   first co-test target because it directly checks the new MCM harness, backend
   matrix expansion, Book of Days aggregation, and the risky organic routes.
   Cards 2, 3, 4, 5, and 7 have passed after retest; continue with the next
   open card.
3. **Race sittings for 1.0.** Work the **Felt-Family Race Sittings
   (deduplicated plan)** section below - ten checklist sittings that prove every
   pending felt family (107 at snapshot) ONCE each (the raw `--sitting <Race>`
   sheets repeat shared price/sting families across races; the plan assigns each
   to a single sitting). Each race sitting feeds C-FELT-FAMILY, C-PACING-SIGNOFF, and
   C-PLACEMENT-FINAL. If a race's beta-feel verdict has regressed, re-run its
   beta-feel packet during the same sitting to clear the C-RACE-RUBRIC stale
   state. (`--sitting <Race>` is still useful for a live single-race regen, but it
   re-lists shared families the plan has already assigned elsewhere.)
4. **Cross-cutting 1.0 smoke.** Experience Mode two-mode smoke, Requiem Track B,
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
- [ ] `Nord-Kyne|boon`  (e.g. Kyne's Sky - Seeker)
- [ ] `Nord-OldWays|boon`  (e.g. Old Ways - Seeker)
- [ ] `Nord-Shor|boon`  (e.g. Shor's Favor - Seeker)
- [ ] `Nord-Stuhn|boon`  (e.g. Stuhn's Ward - Seeker)
- [ ] `Nord-Talos|boon`  (e.g. Talos's Resolve - Seeker)
- [ ] `Nord-Tsun|boon`  (e.g. Tsun's Trial - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Kyne|neglect`  (e.g. The Weather Stops Cooperating)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Dibella|price`  (e.g. murder-defenseless)
- [ ] `Kyne|price`  (e.g. kill-hostile-beast)
- [ ] `Shor|price`  (e.g. murder-defenseless)
- [ ] `Stuhn|price`  (e.g. murder-defenseless)
- [ ] `Talos|price`  (e.g. murder-defenseless)
- [ ] `Tsun|price`  (e.g. murder-defenseless)

### 2. Imperial sitting (13 families) - `set PDV_GLO_OriginRace to 1`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Imperial-Akatosh|boon`  (e.g. Akatosh's Covenant - Seeker)
- [ ] `Imperial-Arkay|boon`  (e.g. Arkay's Vigil - Seeker)
- [ ] `Imperial-Civic|boon`  (e.g. Civic Faith - Seeker)
- [ ] `Imperial-Dibella|boon`  (e.g. Dibella's Grace - Seeker)
- [ ] `Imperial-Julianos|boon`  (e.g. Julianos's Wisdom - Seeker)
- [ ] `Imperial-Kynareth|boon`  (e.g. Kynareth's Breath - Seeker)
- [ ] `Imperial-Mara|boon`  (e.g. Mara's Mercy - Seeker)
- [ ] `Imperial-Stendarr|boon`  (e.g. Stendarr's Mercy - Seeker)
- [ ] `Imperial-Talos|boon`  (e.g. Talos's Resolve - Seeker)
- [ ] `Imperial-Zenithar|boon`  (e.g. Zenithar's Trade - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Imperial|neglect`  (e.g. The Divines Grow Distant)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Kynareth|price`  (e.g. raise-undead)
- [ ] `Stendarr|price`  (e.g. murder-defenseless)

### 3. Breton sitting (12 families) - `set PDV_GLO_OriginRace to 2`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Breton-GreenWay|boon`  (e.g. Green Way - Seeker)
- [ ] `Breton-HiddenArt|boon`  (e.g. Hidden Art - Seeker)
- [ ] `Breton-KnightsRoad|boon`  (e.g. Knight's Vow - Seeker)
- [ ] `Breton-Tradition|boon`  (e.g. Tradition's Footing - Seeker)

**neglect** - Prime neglect eligible, run a dawn, read the neglect debuff in Active Effects:
- [ ] `Neglect-Breton|neglect`  (e.g. The Tradition Grows Distant)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `Akatosh|price`  (e.g. kill-dragon)
- [ ] `Arkay|price`  (e.g. raise-undead)
- [ ] `CreedLoss-Breton|price`  (e.g. The Vow Broken)
- [ ] `Julianos|price`  (e.g. murder-defenseless)
- [ ] `Magnus|price`  (e.g. raise-undead)
- [ ] `Mara|price`  (e.g. murder-defenseless)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects:
- [ ] `Disfavor-MercyProtection|disfavor-sting`  (e.g. The Ward Thins)

### 4. Khajiit sitting (12 families) - `set PDV_GLO_OriginRace to 6`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Khajiit-Alkosh|boon`  (e.g. Alkosh's Order - Seeker)
- [ ] `Khajiit-Azurah|boon`  (e.g. Azurah's Twilight - Seeker)
- [ ] `Khajiit-BaanDar|boon`  (e.g. Baan Dar's Guile - Seeker)
- [ ] `Khajiit-Khenarthi|boon`  (e.g. Khenarthi's Road - Seeker)
- [ ] `Khajiit-Rajhin|boon`  (e.g. Rajhin's Shadow - Seeker)

**substrate-favor** - prime the substrate/context state, read the effect in Active Effects:
- [ ] `Khajiit-Lunar|substrate-favor`  (e.g. Khajiit Lunar Road)
- [ ] `Khajiit-Substrate|substrate-favor`  (e.g. Lunar Hardiness)

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

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects:
- [ ] `Disfavor-WarHonor|disfavor-sting`  (e.g. Honor Falters)

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

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects:
- [ ] `Disfavor-DeathAncestors|disfavor-sting`  (e.g. Rest Turns Uneasy)
- [ ] `Disfavor-SkyStormHunt|disfavor-sting`  (e.g. Weather Turns Sharp)

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

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects:
- [ ] `Disfavor-VoidSecrets|disfavor-sting`  (e.g. Quiet Unease)

### 9. Bosmer sitting (8 families) - `set PDV_GLO_OriginRace to 4`

**boon** - prime the tier state via debug MCM, read one effect in Active Effects:
- [ ] `Bosmer-BanditRoad|boon`  (e.g. Bandit Road - Seeker)
- [ ] `Bosmer-Exchange|boon`  (e.g. The Exchange - Seeker)
- [ ] `Bosmer-LivingStory|boon`  (e.g. Living Story - Seeker)

**price** - commit one displeasing act for the lane, record the loss surface (toast / Book of Days / Ledger row) - or read the price effect in Active Effects where one exists:
- [ ] `BaanDar|price`  (e.g. murder-defenseless)
- [ ] `Yffre|price`  (e.g. raise-undead)
- [ ] `Zen|price`  (e.g. steal-item)

**disfavor-sting** - cycle domain + set band, hit apply-domain-sting, read the named debuff in Active Effects:
- [ ] `Disfavor-MoonLuckShadow|disfavor-sting`  (e.g. Fortune Slips)
- [ ] `Disfavor-OrderTradeLore|disfavor-sting`  (e.g. The Ledger Sours)

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
