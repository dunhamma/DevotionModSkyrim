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
- Quest matrix compile passes at 1071 cells / 135 watched quests / 169 keys / 26 faucet acts (2026-07-09 signal-floor + quest-matrix session; was 884/90). LIKES_DISLIKES_VERSION = 15.
- `pdv_verify` has no `FAIL`; only the existing medallion glyph fallback warning is allowed.
- Formal offer check passes with 45 post-Kyne message records.
- Eligibility reward coverage includes Altmer `PDV_Syrabane`, Altmer `PDV_Trinimac`, Breton Hidden Art `Magnus`, and Breton Green Way `Y'ffre`.
- The adversary checker passes.

Stop if any new readback gate fails. Do not continue into Skyrim to "see if it
works"; fix the machine proof first.

### 0.1 Machine-provable discharge - do NOT spend in-game time on these

Everything below is proven by tooling with NO Skyrim session. Discharge it first;
the in-game run then only covers what a human must actually observe. Re-running
these before a smoke sitting is far cheaper than re-proving in game.

| Claim | Discharged by | Needs game? |
|---|---|---|
| Every cell's valence/tag/magnitude is sign-correct CSV->JSON | `pdv_quest_matrix_compile.mjs --check` + valence audit (734 +, 237 -, 0 mismatch) | NO |
| New quests are registered/watched | `questWatch.editorIds` in the compiled JSON (135 quests) | NO |
| Crypt-clear + Paarthurnax kill/spare fan-outs name the right deities | `pdv_deity_signal_remap_adversary_check.mjs` asserts each deity in the .psc | NO |
| Anti-farm caps exist on every repeatable | `ConsumeDailyRepeatMultiplier` (crypt/faucet) + `dailyCap`/`cooldownDays` columns (LD) | NO |
| Likes/dislikes codegen folded + version bumped | grep `LoadRowsForDeity` + `LIKES_DISLIKES_VERSION = 15` | NO |
| Every authored tag is in that deity's Part B approve/disapprove | tag-vs-Part-B static check (see note) | NO |
| Crypt + plant-food FormLists are populated | `dotnet ... --author-undead-crypt-clear-sites --check` / green-pact audit | NO |
| Papyrus compiles clean | `pdv_compile.mjs` 0 error / 0 warning | NO |
| No `echo` rows survive; magnitude->piety values correct | compile value table (milestone 8-18 / small 2-6) | NO |

Recommended NEW static gate: a **tag-vs-Part-B consistency check** (author a
`pdv_tag_profile_audit.mjs`) - it caught `Auri-El + kill_honorable_combat`
off-profile in this session before any play. Until it exists, run the parse
check ad hoc. Known-safe parser exceptions: Prince self-serve
(`serve_a_daedra:<self>`), `destroy_reject_daedra:<prince>` hostile branches,
Z'en inheriting Zenithar's `theft_burglary` by paired-echo, and deities whose
profile is operative-only (Syrabane) / header-aliased (The Hist, Azurah/Azura).

What STILL needs the game (nothing above proves these): route acceptance /
actual piety movement, Book of Days / toast / Prisma legibility + one-per-quest
aggregation, Active Effects application, save/load stack, live stance/
reachability filtering, crypt `IsCleared()` timing, Paarthurnax `OnDeath` /
SPARE latch firing, LD table reload on a version bump, runtime daily-cap
enforcement, and the Green Way location/harvest/plant hooks.

## 1. Devotion Dev Setup

### 1.0 Efficient execution plan - batch by origin + save-state

The costly moves in-game are origin switches, fresh saves, and log capture. Do
NOT walk the sections top-to-bottom; walk them by ORIGIN so each origin is set
once. Capture logs once per sitting, not per test. Suggested sittings:

| Sitting | Origin | Save | Covers (sections / 2026-07-09 cases) |
|---|---|---|---|
| A | Nord (0) | **fresh, NOT v15-stamped** | LD v15 366/303 FIRST (needs the version reload), then shrine cap (2), MQ spine setstage (10.1/10.2 Dagon flip), crypt-clear (10.3), cowardice-god DB dislikes (10.8), Paarthurnax kill+spare (10.4) |
| B | Bosmer (4) | save | Y'ffre Green Way + necromancy + bardic (10.7), DA05 duplicate-branch (9) |
| C | Breton (2) | fresh | P2 exact-stage (4), formal offers (5), neglect/recovery (7), multi-deity route (3) |
| D | Altmer (3) | save | Syrabane/Trinimac offers + rewards (6) |
| E | any disposable | disposable | taboo/hostile (8), readback-refresh rows (10.5: DBDestroy/MS10/CR13), remaining adversary (9), borderline prove-or-drop rows |

Rules that save the most time:
- Run 0.1 machine discharge first - it removes ~half the "does it exist / is it
  wired" questions from every sitting below.
- The **LD v15 (366/303) case MUST be the first act on a save that has never
  loaded version 15** - once the table stamps, you cannot re-observe the reload
  without another fresh save. Do it before any setstage in Sitting A.
- `setstage` quest fan-out is origin-agnostic for WHICH cells score, but which
  deities are VISIBLE depends on the origin roster + reachability gate - pick the
  origin that makes the target deity reachable (e.g. death gods read on any
  origin; Talos is Concordat-gated for Imperials).
- One hard save before each origin/quest/state change so you can reload instead
  of rebuilding the save.

### 1.1 MO2 setup and per-sitting prep

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

## 10. 2026-07-09 Signal-Floor + Quest-Matrix Session

Scope: everything authored in the 2026-07-09 session (see
`PDV_SignalFloor_MasterHandoff_2026-07-09.md`). All static-proven only; NONE
runtime-proven yet. Use a clean save; `coc` skips Story location triggers -
enter via load door/fast-travel. Each case: capture the standard evidence shape
(section 10).

### 10.1 Main-quest per-deity fan-out (progression beats now count)
Steps: `setstage MQ305 200` (Dragonslayer), `setstage MQ206 220` (read the
Elder Scroll), `setstage MQ302 300` (Season Unending).
- Runtime-route proof: MQ305 fires the death gods **Arkay/Tu'whacca (milestone
  gain) + Khenarthi**; MQ206 fires **Julianos/Hermaeus Mora/Magnus (milestone)
  + Xarxes**; MQ302 fires **Mara/Stendarr + Akatosh + Stuhn**.
- Manual visual: one aggregated toast + one Book of Days line per quest fire
  naming the reacting deities; focused-panel Ledger shows the movement.

### 10.2 Mehrunes Dagon correction (valence flip)
Steps: `setstage MQ305 200` (or MQ206 220) with Dagon in the dashboard roster.
- Proof: Dagon takes a **LOSS** (`serve_empire_order`, not a gain) - the Prince
  of Destruction does not cheer the world being saved. Confirm his ordinary
  dragon-KILL beats (MQ104/106/303) still register as GAINS.

### 10.3 Crypt-clear signal
Steps: enter then fully clear a draugr barrow on `PDV_FLST_UndeadCryptClearSites`
(e.g. Bleak Falls Barrow); re-clear-eligible sites the same day.
- Runtime-route: `Undead crypt clear fired for location ...` marker once per
  site; fan-out to **Arkay(C)/Meridia(C)/Stendarr(S)/Tu'whacca(S)/Azura(m)/
  Y'ffre(m)**; a second qualifying clear the same day is daily-repeat-capped.
- Manual visual: gains appear in Ledger/Book of Days; no double-fire on re-enter
  of an already-cleared site after save/load.

### 10.4 Paarthurnax kill/spare fork (Codex-built)
Steps (KILL): kill the Paarthurnax actor. Steps (SPARE): reach `MQ305 200` and
leave Paarthurnax alive (or trigger the load-catchup latch).
- KILL proof: **Shor/Tsun/Kyne (-S), Stendarr/Stuhn (-C), Mara (-S)** losses;
  Khajiit also get the existing Alkosh chaos-aid consequence. One-shot
  (`PDV.Paarthurnax.KillSeen`).
- SPARE proof: **Stuhn(+C)/Stendarr(+C)/Mara(+S)/Kyne(+m)** gains via the
  `RoutePaarthurnaxSpare` latch. Confirm kill and spare are mutually exclusive.

### 10.5 Readback-refresh quest rows
Steps: `setstage DBDestroy 200`, `setstage MS10 100`, `setstage CR13 200` (as a
werewolf).
- Proof: DBDestroy = **Sithis milestone LOSS** (break_oath_betray) + Stendarr/
  Talos gains; MS10 = **Zenithar milestone gain** + Z'en; CR13 = **Hircine cure
  LOSS + Y'ffre gain**.

### 10.6 Likes/dislikes v15 (events 366 + 303) - NEW SAVE REQUIRED
Prereq: a save that has NOT stamped `PDV.LD.Version=15`; confirm log
`Likes/dislikes table + stances loaded (version 15)`.
Steps: feed as a vampire (366); kill a non-hostile animal out of combat (303).
- Proof: 366 = **Arkay/Stendarr-class LOSSES** (large tier, cap 1/day - second
  feed same day capped); 303 = **Kyne/Kynareth LOSSES** (cap 3/day). Driver copy
  states the trigger; no stale re-fire after save/load.

### 10.7 Y'ffre Green Way + necromancy + bardic (Bosmer, origin 4)
Steps: visit a Bosmer sacred site (Eldergleam Sanctuary / Ancestor Glade /
All-Maker stone); consume a plant food on `PDV_FLST_GreenPact_PlantFoods`;
`setstage DLC1VQ04 200` (Soul Cairn necromancy); `setstage BardsCollegePoeticEdda 200`.
- Proof: site visit = Y'ffre gain; plant consumption = **Y'ffre LOSS**
  (Meat Mandate); DLC1VQ04 = Y'ffre necromancy LOSS; Poetic Edda = Y'ffre
  bardic GAIN (the Storyteller).

### 10.8 Cowardice-god assassination dislikes
Steps: `setstage DB01 200`, `setstage DB11 200` (regicide).
- Proof: **Talos/Tsun/HoonDing take LOSSES** on the treacherous-murder /
  assassination beats (new Part B axis), alongside the existing Kyne/Baan Dar/
  Rajhin/Khenarthi reactions.

### Borderline rows to prove-or-drop
`DA14Start 70` (Sanguine), `DLC2RRFavor01 200` (Zenithar keep-vs-report),
`T03 105` (Y'ffre, manual-FormID stage), the HearthFires adoption stages
(`BYOHRelationshipAdoption 10` / `BYOHRelationshipAdoptableOrphanage 200`,
Dibella). If any fires silently or wrong, drop or re-anchor the row.

## 11. Evidence Notes

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
