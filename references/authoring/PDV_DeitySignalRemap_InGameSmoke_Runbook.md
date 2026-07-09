# PDV Deity Signal Remap In-Game Smoke Runbook

Date: 2026-07-09

Scope: deity signal remap implementation smoke. This proves whether the remap
surfaces correctly in game. It does not replace the readback/verifier gates, and
green machine gates do not make this guide-ready or player-guide-ready.

Implementation input:

- `PDV_DeitySignalRemap_TestingDocHandoff_2026-07-09.md`
- implementation closeout from thread `019f3f88-cc85-76f2-a646-06ee1b83e8c8`
- tranche CSV `PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv`
- P2 exact-stage manifest `PDV_Phase20_P2ImmersiveReceivers.manifest.json`

## Proof Boundary

| Bucket | What counts here | What does not count |
|---|---|---|
| Readback proof | compile, verifier, ESP/SEQ/property checks, quest JSON compile, exact-stage source-fill checks | Papyrus route firing, visible UI, Active Effects, player feel |
| Runtime-route proof | Papyrus markers showing accepted routes, no-fire routes, duplicate suppression, shrine daily cap | Active Effects, Book of Days legibility, Survey/status clarity |
| Manual visual proof | Book of Days, toast/Prisma copy, focused panel Ledger, Survey/status, Active Effects, save/load stack | claim that implementation is guide-ready or beta-complete |

Allowed claim after readback only: smoke-ready.

Blocked until this run is recorded: runtime-route proven, manual visual proven,
player-guide-ready, strict beta/manual claim.

## 0. Readback Preflight

Run from repo root before opening Skyrim:

```powershell
node .\tools\pdv_quest_tranche_merge.mjs
node .\tools\pdv_quest_matrix_compile.mjs --check --json
node .\tools\pdv_quest_matrix_compile.mjs --papyrusutil-check --json
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest.psc --skip-verify --json
node .\tools\pdv_compile.mjs --script PDV_MCM.psc --skip-verify --json
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_formal_offer_check.mjs --json
node .\tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json
node .\tools\pdv_deity_signal_remap_adversary_check.mjs
node .\tools\pdv_eligibility_reward_coverage_audit.mjs --json
node .\tools\pdv_antifarm_sweep_audit.mjs --json
node .\tools\pdv_ledger_coverage_audit.mjs --json
node .\tools\pdv_signal_floor_audit.mjs --json
node .\tools\pdv_requiem_penalty_audit.mjs --json
node .\tools\pdv_prisma_ui_audit.mjs --json
```

Expected readback result:

- `PDV__ManagerQuest` and `PDV_MCM` compile with `0 error(s), 0 warning(s)`.
- Quest matrix compile passes at 884 cells / 90 watched quests.
- `pdv_verify` has no `FAIL`; only the existing medallion glyph fallback warning is allowed.
- Formal offer check passes with 45 post-Kyne message records.
- Eligibility reward coverage includes Altmer `PDV_Syrabane`, Altmer `PDV_Trinimac`, Breton Hidden Art `Magnus`, and Breton Green Way `Y'ffre`.
- The adversary checker passes.

Stop if any new readback gate fails. Do not continue into Skyrim to "see if it
works"; fix the machine proof first.

## 1. Devotion Dev Setup

Use Anvil MO2:

1. Select profile `Devotion Dev`.
2. Confirm `Devotion.esp` is enabled.
3. Disable `Devotion - Living Deities Test` if it appears in this profile.
4. Start a disposable new save or main-menu `coc qasmoke`.
5. Make a clean hard save before changing race origin, deity, or quest state.

Clear logs before each smoke pass:

```powershell
Remove-Item "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus*.log" -ErrorAction SilentlyContinue
```

In game, set debug and origin:

```text
set PDV_GLO_DebugLevel to 2
set PDV_GLO_OriginRace to <originIndex>
```

Origin indices:

```text
0 Nord
1 Imperial
2 Breton
3 Altmer
4 Bosmer
5 Dunmer
6 Khajiit
7 Argonian
8 Orc
9 Redguard
```

Use `MCM -> Devotion -> Developer Options` for debug actions. Do not use `cqf`
unless a later runbook explicitly says to. For offer tests, use the MCM selected
deity cursor carefully; it resets when the page resets.

Evidence to capture for each route:

- Papyrus log snippet.
- Book of Days entry or explicit absence.
- Focused panel Ledger row or explicit absence.
- Survey/status state.
- Active Effects list.
- Save/load stack note.

## 2. Shrine Repeat Click

Goal: prove the new per-deity, per-game-day shrine cap without breaking
origin-appropriate shrine aliases.

Setup:

```text
set PDV_GLO_OriginRace to 0
set PDV_GLO_DebugLevel to 2
```

Steps:

1. Use a Nord save.
2. Activate a Kynareth shrine once.
3. Open Book of Days manually.
4. Activate the same shrine again on the same game day.
5. Open Book of Days and the focused panel Ledger again.
6. Sleep or wait past the next in-game day, then activate the shrine a third time.

Runtime-route proof:

- First click routes shrine prayer.
- Same-day repeat logs a cap line like `[PDV] Shrine prayer daily cap blocked Kyne from <sourceId>`.
- Next-day click routes again.

Manual visual proof:

- First click writes exactly one Book of Days line: `You offered prayer at Kyne's shrine.`
- Same-day repeat writes no fresh Book of Days line and no duplicate Ledger movement.
- Next-day click may write a fresh shrine prayer line.
- Active Effects are not the primary proof for this route unless the click crosses a tier after dawn.

Failure symptoms:

- Same-day repeat creates a second fresh Book of Days shrine line.
- Same-day repeat adds a second Ledger movement for the same resolved deity.
- Nord line says `Kynareth` or `Khenarthi` instead of `Kyne`.
- A wrong-origin save gains visible shrine movement from a deity outside its roster.

## 3. Multi-Deity Quest Matrix Route

Goal: prove one quest outcome can fan out to multiple deity opinions while
surfacing as one toast and one Book of Days beat.

Setup:

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Command:

```text
setstage MQ104 160
```

Runtime-route proof:

- Papyrus log contains `QuestReaction: 155916|160 applied`.
- The route may also emit skipped-unreachable lines for foreign non-roster gods; those are expected when origin filtering removes off-roster deity faces.

Manual visual proof:

- Toast title is `A deed marked` or `A deed weighed`, depending on reachable positive/negative cells for the save.
- Book of Days has exactly one quest-reaction entry, not one entry per deity. The line uses one of these exact formats:
  - `<names> marked your deed.`
  - `<names> took offense at your deed.`
  - `<positive names> marked your deed; <negative names> took offense.`
- On a Breton save, the visible line must include remap-relevant names from `MQ104` such as `Akatosh` and `Mara` when those deities are reachable for the save.
- Focused panel Ledger carries the per-god detail.
- No Active Effects are expected from the quest route by itself unless the route crosses an active reward threshold and a dawn/reward sync is run.

Failure symptoms:

- More than one toast or more than one Book of Days line appears for the single `setstage`.
- The Ledger has piety movement but no Book of Days quest-reaction line.
- The Book of Days line is blank.
- Off-roster foreign deities show in the player-facing panel instead of being skipped.

## 4. Breton Exact-Stage P2 Source

Goal: prove exact-stage P2 source routing stays separate from the broader quest
matrix reaction.

Setup:

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Knight's Road command:

```text
setstage t02 200
```

Expected runtime-route proof:

- `QuestReaction: 135637|200 applied`
- `Breton tradition choice routed: po3_queststage_breton_t02_knights_road` if Breton setup was not complete.
- `Breton Knightly Vow routed: po3_queststage_breton_t02_vow`
- Repeating the same command on the same save logs a P2 repeat skip for the same route key rather than routing the P2 source twice.

Expected manual visual proof:

- Book of Days has one quest-reaction entry using the `A deed marked` format.
- If setup was not complete, Survey/status shows `Knight's Road`.
- Active Effects do not need to change immediately. If you then use MCM to make the Knight's Road focus active and set piety to a reward tier, the expected rewards are:
  - `Knight's Vow - Seeker`: Speech +5.
  - `Knight's Aegis - Devoted`: Speech +13, Restoration +8.
  - `Knight's Bulwark - Champion`: Speech +25, Restoration +18, Armor +50.

Green Way command:

```text
setstage dunEldergleamT03 100
```

Expected runtime-route proof:

- `Breton Green Way standing routed: po3_queststage_breton_eldergleam_blessings`
- Repeating the same command on the same save logs a repeat skip for route key `breton_eldergleam_blessings_stage_100`.
- This is exact-stage P2 source proof. The broader quest-matrix `T03` rows are a separate proof surface and should not be counted as the P2 route.

Expected manual visual proof:

- Survey/status shows Green Way standing movement when the save is Breton.
- Green Way reward ownership is `Y'ffre`, not `Kynareth`.
- If you use MCM to make the Green Way focus active and set piety to a reward tier, the expected rewards are:
  - `Green Way - Seeker`: Stamina Regeneration +10%.
  - `Green Way - Devoted`: Stamina Regeneration +12%, Restoration +10.
  - `Green Way - Champion`: Stamina Regeneration +20%, Restoration +18, Maximum Health +20.

Failure symptoms:

- A non-Breton origin changes Breton tradition state.
- `Kynareth` owns Green Way reward or offer surfaces.
- The same exact-stage P2 route fires twice on one save.
- A generic favor, generic marriage, generic undead kill, or generic nature visit triggers the P2 source.

## 5. Breton Formal Offers

Goal: prove active-tradition offers allow only the correct Breton focus set.

Setup:

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Use MCM Developer Options:

1. Set Breton tradition to Hidden Art (`1`) or choose it through the startup choice on a fresh Breton save.
2. Select `Magnus`.
3. Set target piety to at least `50`.
4. Use `Seed commitment signals`.
5. Use `Evaluate commitment`.

Expected in-tradition offer:

- Message title: `Magnus in the Hidden Art`.
- Message body starts: `You have kept magic disciplined and half-concealed`.
- Accept toast: `Magnus has named you their own.`
- Accept Book of Days line: `The broad faith narrows to one; Magnus has named you their own.`
- Refuse toast on a disposable save: `You turned Magnus away.`
- Refuse Book of Days line: `The broad faith stays whole; you turned Magnus away, and Magnus will not ask again.`
- Refuse has no screen wash and no D1 sound.

Off-tradition adversary:

1. Keep Breton tradition as Hidden Art (`1`).
2. Select `Stendarr`.
3. Seed commitment signals and evaluate commitment.

Expected off-tradition denial:

- No Stendarr offer MessageBox.
- No pending commitment state.
- No offer toast.
- No pinned offer Book of Days line.

Failure symptoms:

- Hidden Art offers Stendarr, Akatosh, Arkay, Julianos, Zenithar, Kynareth, or Dibella.
- Knight's Road offers `Y'ffre`.
- Green Way offers anything except `Y'ffre`.
- Bosmer, Khajiit, or Argonian produce a formal offer from this path.
- Refuse produces the acceptance sound/screen wash.

## 6. Altmer Syrabane And Trinimac Offers/Rewards

Goal: prove the newly authored Altmer Syrabane/Trinimac support is visible.

Setup:

```text
set PDV_GLO_OriginRace to 3
set PDV_GLO_DebugLevel to 2
```

Syrabane offer path:

1. Select `Syrabane` in MCM Developer Options.
2. Set target piety to at least `50`.
3. Seed commitment signals.
4. Evaluate commitment.

Expected offer:

- Message title: `Syrabane's Apprentice Ward`.
- Accept toast: `You name Syrabane your focus.`
- Accept Book of Days line: `The foundation narrows to a single disciplined road. You named Syrabane your focus.`

Trinimac offer path:

1. Select `Trinimac`.
2. Satisfy the high-orthodoxy gate using the existing Altmer debug setup for ThalmorAlignment if the offer does not appear.
3. Set target piety to at least `50`.
4. Seed commitment signals.
5. Evaluate commitment.

Expected offer:

- Message title: `Trinimac's High Example`.
- Accept toast: `You name Trinimac your focus.`
- Accept Book of Days line: `The foundation narrows to a single disciplined road. You named Trinimac your focus.`

Expected Active Effects after accept, piety tier, and dawn/reward sync:

| Focus | Seeker | Devoted | Champion |
|---|---|---|---|
| Syrabane | `Syrabane's Guard - Seeker`: Restoration | `Syrabane's Guard - Devoted`: Restoration, Magic Resistance | `Syrabane's Ward - Champion`: Restoration, Magic Resistance |
| Trinimac | `Trinimac's Charge - Seeker`: One-Handed | `Trinimac's Charge - Devoted`: One-Handed, Armor | `Trinimac's Defense - Champion`: One-Handed, Armor |

Failure symptoms:

- Offer appears for Altmer `Phynaster`; Phynaster is V1 roster/flavor-only.
- Trinimac offer appears without high-orthodoxy/proof state.
- Syrabane/Trinimac accept has no Book of Days line.
- Active Effects show only Auri-El/Magnus/Xarxes rewards after selecting Syrabane or Trinimac.

## 7. Breton Neglect And Recovery

Goal: prove the remapped Breton neglect spell is visible and clears on renewed
practice.

Setup:

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Steps:

1. Use `setstage t02 200` on a fresh Breton save to create a tradition signal.
2. Wait or sleep 6 in-game days.
3. Use MCM Developer Options -> `Run neglect pass` or run dawn.
4. Open Active Effects.
5. Renew practice with a different approved source, for example `setstage MS14 200`.
6. Run dawn/neglect pass again.
7. Save, reload, and inspect Active Effects again.

Expected runtime-route proof:

- First source logs `Breton Knightly Vow routed: po3_queststage_breton_t02_vow`.
- Renewal source logs `Breton Knightly Vow routed: po3_queststage_breton_ms14_vow`.

Expected manual visual proof:

- Neglect Active Effect: `The Tradition Grows Distant`.
- Effect text: `Maximum Health -10, Magic Resistance -5%`.
- After renewal and refresh, the neglect spell clears.
- Book of Days/Survey/status should read as a lapse/recovery, not a new tradition choice.
- After save/load, no duplicate neglect effect remains.

Failure symptoms:

- Neglect uses regeneration-rate behavior instead of flat Maximum Health/Magic Resistance loss.
- Neglect stays after renewed practice and refresh.
- Neglect stacks twice after save/load.
- Renewal changes the chosen tradition instead of repairing the current one.

## 8. Taboo Or Hostile Quest Outcome

Goal: prove hostile/taboo quest reactions become penalty/stigma instead of
positive credit.

Use one of these commands on a disposable save:

```text
setstage DA02 40
setstage DA11 100
setstage DA16 190
```

Expected runtime-route proof:

- `DA02 40`: `QuestReaction: 317654|40 applied`
- `DA11 100`: `QuestReaction: 181080|100 applied`
- `DA16 190`: `QuestReaction: 148143|190 applied`

Expected manual visual proof:

- Toast title is `A deed ill-received` or `A deed weighed` when reachable negative cells exist.
- Book of Days line uses one of:
  - `<names> took offense at your deed.`
  - `<positive names> marked your deed; <negative names> took offense.`
- Ledger shows loss/stigma for offended gods, not only positive piety.

Failure symptoms:

- The route only grants positive piety when a negative row is present for reachable deities.
- The Book of Days line is positive-only for a negative/hostile branch.
- Daedric Hidden Art price/rupture suppression ignores unhealthy Hidden Art standing.

## 9. Adversary Scenarios

Run these after the happy paths. Record explicit absence, not just "nothing odd."

| Scenario | Steps | Expected |
|---|---|---|
| Wrong race | Set origin to Dunmer (`5`), then `setstage t02 200`. | Quest matrix may still score reachable Dunmer/Daedric cells, but no Breton tradition state, no Breton reward, and logs should say Breton route ignored or show no Breton route. |
| Repeated shrine click same day | Activate the same Kynareth shrine twice as a Nord on one game day. | First click writes `You offered prayer at Kyne's shrine.`; second click logs shrine cap blocked and writes no fresh line. |
| Generic unapproved source | Kill a random undead, learn/cast a generic spell, visit a city, or stand near a shrine without activating it. | No P2 source route, no tradition state movement, no new Book of Days line from the remap source. |
| Rejected quest branch / non-terminal progress | On a fresh Breton save, run `setstage MS14 100` or another non-approved stage before `MS14 200`. | No `breton_ms14_vow` route and no Breton vow state movement. |
| Duplicate mutually exclusive branch | On a Bosmer save, run `setstage DA05 100`, then `setstage DA05 105` without reloading. | The P2 group guard should allow only one `bosmer_da05_yffre_outcome` source route. A second group route is a duplicate-branch failure. Quest-matrix reaction logs may still appear from forced console stages; do not count that as P2 source proof. |
| Off-tradition Breton offer | Hidden Art Breton, select Stendarr, seed signals, evaluate commitment. | No Stendarr offer MessageBox, no pending offer, no offer toast, no pinned offer Book of Days line. |
| Generic unapproved quest source | Run `setstage MG01 200` when testing Hidden Art. | It may trigger the older quest matrix College study rows, but it must not count as a Hidden Art P2 source or replace `MG08 200` as the remap terminal proof. |
| Save/load stack | After an accepted Syrabane/Trinimac/Breton focus reward or Breton neglect, save, quit to menu, reload. | Exactly one expected reward/neglect effect remains, no stale duplicate, Survey/status and Book of Days still agree. |

## 10. Evidence Notes

Record results in the active manual evidence surface for the owning race or
cross-system sitting. Do not edit player guides from this run alone.

Minimum note shape:

```text
Route:
Origin:
Command/action:
Papyrus marker:
Book of Days:
Toast/Prisma:
Ledger:
Survey/status:
Active Effects:
Save/load:
Verdict by bucket: readback / runtime-route / manual visual
```

Stop the run and bring back notes if:

- a Book of Days line is blank
- a rejected/generic source scores
- a wrong race changes a race-specific state
- a repeated shrine click scores the same deity twice on one day
- an off-tradition offer appears
- mutually exclusive P2 branches both route
- Active Effects duplicate or persist incorrectly after save/load
