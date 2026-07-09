# PDV Signal-Floor + Quest-Matrix Session - MASTER Codex Handoff - 2026-07-09

Authoritative consolidation of the whole 2026-07-09 signal-floor / quest-matrix
session. Supersedes the earlier per-topic handoffs for status purposes (they
remain valid as detail references):
`PDV_SignalFloor_Tranche10_CodexHandoff.md`,
`PDV_SignalFloor_LikesDislikes_CodexHandoff.md`,
`PDV_SignalFloor_DeepDive_ConsolidatedCodexHandoff_2026-07-09.md`,
`PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md`.

## Current state snapshot

- Quest matrix `PDV_QuestReactionMatrix_Full.csv`: **1071 cells, 169 quest keys,
  135 watched quests, 45 deities, 26 faucet acts** (generated from the Tranche
  CSVs via `pdv_quest_tranche_merge.mjs`; Tranche10 holds this session's rows).
- Likes/dislikes `PDV_DeityLikesDislikes.csv`: **364 rows**, folded into
  `PDV__ManagerQuest.psc` `LoadRowsForDeity`, **`LIKES_DISLIKES_VERSION = 15`**.
- Gates at handoff: matrix compile `--check` PASS; adversary check PASS
  (expected thin-Hist warning only); `pdv_verify` **3546 PASS / 0 FAIL / 1 WARN**
  (pre-existing medallion-glyph fallback); formal-offer PASS; strict
  dislike-consequence audit PASS.
- Live runtime JSON regenerated at
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionMatrix.json`.

## PROOF BOUNDARY (read first)

Everything Claude authored is **authority / readback / static-gate proven ONLY**.
**No matrix row, no likes/dislikes row, and no signal in this session has been
proven to fire in-game.** The single largest remaining gate for the entire body
of work is the in-game smoke pass (Part 3E). Do not claim player-ready /
beta-feel for any of it until smoke proves visible behavior.

---

## PART 1 - What Claude authored this session (static-proven, data only)

All in the Tranche CSVs (source) -> `Full.csv` (generated) + `PDV_DeityLikesDislikes.csv`.

### 1.1 Doctrine changes (durable - apply to all future authoring)

- **Event-scale magnitude model; ECHO TIER RETIRED.** Signal weight follows
  event scale: quest = arc completion = milestone(8-18)/small(2-6); location
  cleared = small; single incident = day-to-day faucet (0.25-0.5, daily-capped).
  All 533 former `echo` rows (1-3 piety) were promoted to `small`. `value.echo.*`
  remains in `pdv_quest_matrix_compile.mjs` but is unused - **do not author new
  echo rows.** Quest awards are UNCAPPED at award time but the dawn conversion
  clamps each deity's daily total to `PIETY_DAILY_MAX_DELTA` (4.3), so milestone
  quests do not break pacing. (Part C1 of `PDV_QuestReactionMatrix.md`.)
- **Questline progression beats COUNT.** A middle/progression beat is NOT
  excludable merely for being intermediate; if a deity has a relevant read it
  gets a row. The main questline is now covered end-to-end. (Updated Part E
  procedure + `EXCL_CONTAINER_TOO_BROAD` note in
  `PDV_Phase20_QuestStageExclusionAudit.md`.)

### 1.2 Signal-floor expansion (the 20/10 combined floor)

- Tranche10 quest rows for thin Princes, zero-negative deities, mixed-surface
  and mortal deities; cowardice gods (Talos/Tsun/HoonDing) gained a treachery/
  assassination dislike axis (Part B extended; DB-line rows). Waivers for
  genuinely-thin deities in `PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md`.
- Likes/dislikes v15: +23 rows on the previously-unconsumed events **366
  (vampire-feed)** and **303 (kill-animal-noncombat)**; superset extended.

### 1.3 Low-deity deep dives + extrapolation (lowest-5 positives)

- The Hist, Dibella, Y'ffre, Zenithar, Syrabane deep-dived; ~20 rows added
  (Skaal People echoes, HearthFires adoptions, Bards College, Staff of Magnus,
  cleansed Azura's Star, TG08B theft, etc.).

### 1.4 Y'ffre theology (per user direction)

- Part B: added `slay_undead`(m, bone-law), `necromancy`(S) disapprove,
  `aesthetic_devotion`(S, the Storyteller).
- Bone-law is realized via the CRYPT-CLEAR signal (Part 2), NOT quest echoes
  (the 6 draugr quest echoes were removed). Necromancy dislikes on
  DLC1VQ04/VQ05/DA01. Bardic likes on the Bards College quests + Poetic Edda.

### 1.5 Readback-refresh rows (after Codex's refresh)

- MS10 Rise in the East (Zenithar milestone + Z'en), DBDestroy (Sithis
  break_oath_betray milestone + Stendarr/Talos), CR13 Purity (Hircine cure
  dislike + Y'ffre), C05 Hircine promotion (Silver Hand = werewolf-hunters).
  MS01/MS02 skipped (no-act / EXCL_OUTCOME_AMBIGUOUS).

### 1.6 Main-quest per-deity review (all 18 beats x 45 deities)

- +26 rows / 3 modified. Death gods (Arkay/Tu'whacca milestone + Khenarthi) on
  MQ305 - Alduin devours the honored dead, defeating him frees them. Knowledge
  gods (Julianos/Mora/Magnus milestone) on the Elder-Scroll/lore beats. Order/
  peace (Akatosh/Stuhn on Season Unending, all 3 stages). Shor/Tsun on Helgen,
  Auri-El on the dragon-slayings, HoonDing on the Odahviing trap.
- **Mehrunes Dagon CORRECTION:** his + on the two Alduin-DEFEAT beats
  (MQ206/MQ305) flipped to `-serve_empire_order` (the Prince of Destruction does
  not cheer the world being saved); his dragon-KILL rows stayed +.

---

## PART 2 - What Codex ALREADY wired this cycle (confirmed in repo)

Verified present in live source - do NOT redo:

- **Readback refresh** - `vanilla-quest-stage-readback.csv` now 751+ quests
  (MS01/MS02/DBDestroy/MS05/T01/t02/RelationshipMarriage/C05/MS10 present).
- **Part D faucet hooks** - Sanguine skooma + Sheogorath Wabbajack (faucetActs
  24 -> 26; `faucetForms.Sanguine.revel_indulge_skooma`,
  `faucetForms.Sheogorath.serve_a_daedra:sheogorath` in the compile tool).
- **Y'ffre Green Way behavioral** - location fanout (Ancestor Glade, All-Maker
  stones, Eldergleam/Gildergreen), `PDV_FLST_GreenPact_PlantFoods` filled (25
  food FormKeys), plant-consumption source implemented.
- **Crypt-clear signal (3c0e0dd6)** - `TrackUndeadCryptClearSiteVisit` +
  `HandleUndeadCryptSiteClear` + `ApplyUndeadCryptClearReactions` in
  `PDV__ManagerQuest.psc`, armed via `PDV_ActionRouter` location-change hooks,
  keyed off `PDV_FLST_UndeadCryptClearSites`, once-per-site + daily-repeat cap.
  Deity fan-out matches spec: Arkay C, Meridia C, Stendarr S, Tu'whacca S,
  Azura m, Y'ffre m.
- **Paarthurnax hook (partial)** - `PDV_PlayerEvents.psc` has a `Paarthurnax`
  ActorBase property + OnDeath classification routing a kill to Alkosh chaos-aid.
- **Manager recompiled** - the two freshness WARNs (pex/SEQ) from earlier are
  cleared; verify is back to 1 WARN.

---

## PART 3 - What REMAINS for Codex (actionable)

### 3A. Crypt-clear FormList population (verify / fill)

The crypt-clear signal is code-complete but inert if `PDV_FLST_UndeadCryptClearSites`
is empty. **Confirm the FormList is populated** with draugr/undead-crypt
**Location** records (not cells): Bleak Falls Barrow, Ustengrav, Labyrinthian,
Korvanjund, Movarth's Lair, Ansilvund, Forsaken Cave, Shroud Hearth Barrow,
etc. Use CK/houseCARL. If empty, fill it - this is the home for "cleared a
draugr crypt" that replaced the removed Y'ffre quest echoes.
- MIGRATION NOTE: once live, the existing `slay_undead` QUEST rows on incidental
  dungeon-clear quests (MQ103 Bleak Falls, CW02A/B Jagged Crown, MG07
  Labyrinthian for Arkay/Stendarr/Meridia/Tu'whacca/Azura) now double-cover
  undead-clearing. Decide per row: keep genuine undead-PURGE arcs (DA09 Break of
  Dawn, MS14 Laid to Rest) as quest milestones; consider migrating the purely
  incidental dungeon-clear rows to the crypt-clear surface.

### 3B. Paarthurnax spare/kill fork - expand the hook (optional enhancement)

The hook exists but only routes a KILL to Alkosh chaos-aid. The full multi-god
fork Claude spec'd is not wired. If desired, extend the existing Paarthurnax
`OnDeath` routing (KILL branch) and add a SPARE latch (player reaches the
Delphine/Esbern ultimatum and leaves him alive / abandons the Blades demand):
- KILL (kinslaying a repentant Voice-mentor): Shor -S, Tsun -S, Kyne -S,
  Stendarr -C (kill_the_helpless), Stuhn -C, Mara -S.
- SPARE: Stuhn +C (mercy_spare), Stendarr +C, Mara +S, Kyne +m.
This is a felt-quality enhancement, not a blocker.

### 3C. Version-pin review (Claude touched toolchain - please review)

Claude synced two version-pin literals from 14 -> 15 when bumping
`LIKES_DISLIKES_VERSION`: `EXPECTED_LIKES_DISLIKES_VERSION` in
`tools/pdv_verify.mjs` and the assert in
`tools/pdv_deity_signal_remap_adversary_check.mjs`. These are Codex-owned
toolchain files (CLAUDE.md rule 4) - please confirm the sync is acceptable.

### 3D. Plant-consumption runtime proof

`PDV_FLST_GreenPact_PlantFoods` is filled and the source is implemented, but the
runtime consumption -> Y'ffre negative piety path is not yet proven in-game.
Remaining scope (per Codex's own note in the deep-dive handoff): runtime
consumption proof + tag expansion to potions/ingredients/firewood/mod food.

### 3E. IN-GAME SMOKE MATRIX (the gate for the ENTIRE session)

Nothing above is runtime-proven. Run on a save that has NOT completed the target
quests and has NOT stamped `PDV.LD.Version=15` (for the LD checks). `coc` skips
Story location triggers - enter via load doors. Minimum representative set:

| # | Surface | Command / action | Expect |
|---|---|---|---|
| 1 | Quest fan-out + toast | `setstage DLC2SV01 200` | Hist + Y'ffre + Syrabane; ONE aggregated toast ("X marks your deed") + one Book of Days line naming all |
| 2 | Main-quest death gods | `setstage MQ305 200` | Arkay/Tu'whacca milestone gains + Khenarthi, alongside the Nord fan-out |
| 3 | Main-quest lore gods | `setstage MQ206 220` | Julianos/Mora/Magnus milestone gains |
| 4 | Mehrunes Dagon correction | `setstage MQ305 200` | Dagon LOSS (not gain) - confirm the flip fires |
| 5 | Sithis strongest negative | `setstage DBDestroy 200` | Sithis milestone loss; Stendarr/Talos gains |
| 6 | Zenithar milestone | `setstage MS10 100` | Zenithar milestone gain + Z'en |
| 7 | Hircine cure dislike | `setstage CR13 200` (as werewolf) | Hircine loss + Y'ffre gain |
| 8 | Crypt-clear signal | clear a draugr barrow on the FormList (e.g. Bleak Falls Barrow) | Arkay/Stendarr/Meridia/Tu'whacca/Azura/Y'ffre gains once per site; second clear same day capped |
| 9 | Likes/dislikes v15 | new save; vampire-feed (366) + non-combat animal kill (303) | Arkay/Stendarr-class losses (366), Kyne/Kynareth losses (303); log "version 15 loaded"; daily caps hold |
| 10 | Green Way behavioral | visit a Bosmer sacred site; consume a plant food | Y'ffre site gain; Y'ffre plant-consumption loss |
| 11 | Season Unending | `setstage MQ302 300` | Mara/Stendarr + Akatosh + Stuhn gains |

Per smoke: confirm Book of Days records it, Survey/status lane correct, toast/
Prisma coherent, no duplicate/stale effect stack after save/load, wrong-origin
routes silent. Borderline rows to prove-or-drop: DA14Start s70, DLC2RRFavor01
s200, T03 s105, the HearthFires adoption stages.

---

## PART 4 - Session commit inventory (main branch)

`6147991` tranche10 signal-floor + LD v15 · `873141b` cowardice-god assassination
dislikes · `0f7db28` low-deity deep-dive + consolidated handoff · `bc89547`
Y'ffre bone-law echoes (later removed) · `06dc22a` event-scale magnitude / echo
retired · `f872a1e` Y'ffre necromancy + bardic · `1e1cb60` readback-refresh rows ·
`d0e5141` MS01/MS02/C05 second look · `29678e0` main-quest progression + doctrine ·
`97a9bf7` MQ205 phantom-deity fix · `874e4bc` main-quest per-deity review + Dagon.
(Codex interleaved: `ab85c4d`, `6e8aa971` Bosmer/Green Pact, `3c0e0dd6` crypt-clear.)

Files authored/owned by Claude this session (all data/docs, no toolchain logic):
- `references/authoring/PDV_QuestReactionMatrix_Tranche10_SignalFloor.csv` (new source tranche)
- `references/authoring/PDV_QuestReactionMatrix_Tranche2/7` (targeted edits: Dagon flip, Mephala enrich, Hircine C05)
- `references/authoring/PDV_QuestReactionMatrix_Full.csv` (generated - never hand-edit)
- `references/authoring/PDV_DeityLikesDislikes.csv`
- `references/authoring/PDV_QuestReactionMatrix.md`, `PDV_Phase20_QuestStageExclusionAudit.md` (doctrine)
- Handoff/waiver docs listed at top.
- Version-pin sync in `tools/pdv_verify.mjs` + `pdv_deity_signal_remap_adversary_check.mjs` (see 3C).
