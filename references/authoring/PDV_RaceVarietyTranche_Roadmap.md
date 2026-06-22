# PDV Race Variety Tranche Roadmap

**Created:** 2026-06-12
**Status:** DESIGN-LOCKED 2026-06-12 (all five tranches folded into race sheets; magnitudes tunable) — no records, scripts, or contracts authored yet; effect families gated behind `PDV_RaceEffectReviewLedger.md`
**Owner:** Companion to `references/authoring/PDV_RaceGameplayBalanceAudit.md` and `references/authoring/PDV_RaceRewardBudgetLedger.md`
**Precedent:** Argonian variety tranche (landed 2026-06-11, `PDV_ArgonianVariety_RecordBatch.manifest.json`) and Khajiit Lunar Lattice (landed 2026-06-11)

## Purpose

The Argonian variety tranche answered the only `Thin/Watch` verdict in the
balance audit with five bespoke, runtime-proven gameplay mechanics. This
roadmap asks the follow-up question directly: **which other races carry the
same thin-feeling risk in ordinary play, and what would a race-shaped
variety tranche look like for each?**

This is a proposal layer. Nothing here changes locked architecture, locked
race rules, the hybrid boon budget, or the contextual-favor one-active cap.
Every proposed mechanic must still pass the effect-review ledger, the
reward-budget ledger, and a per-race record-batch manifest before any
authoring tool is built.

## The Argonian Pattern: Five Thickness Levers

The Argonian tranche was not five random features. It hit five distinct
texture gaps that together make a race feel alive between quests. Reusing
the levers (not the content) is the cheapest path to parity, because the
runtime machinery for several of them is already proven:

| Lever | Argonian instance | Proven machinery to reuse |
|---|---|---|
| L1. State-keyed ambient texture | Hist dreams keyed to posture (8-12% per sleep, 2-day floor, 60% on posture change) | Sleep-event dream roller with posture hook |
| L2. Place anchor + maintenance ritual | Bed-of-choice declaration (cell-keyed) + Rooted Rest at return-sleep 3 | Cell-keyed declaration at `OnSleepStop` (GetFurnitureReference is None at OnSleepStart — cell is the reliable key) |
| L3. Playstyle signature | Shadowscale veil (once/day invisibility moment on sneak kill while Void focus) | Focus-gated once/day kill-event signature |
| L4. Curated one-shot pilgrimage set | Waters That Remember (6 curated LCTNs, first-arrival vision, milestone MessageBox, anti-farm forever) | LCTN arrival router + one-shot StorageUtil keys + bounded interior poll where needed |
| L5. Permanent-choice rite | Hist Adaptations (one-active choice menu, 7-day cooldown, swap clear-before-add, fades below composite 75 and returns at dawn) | MESG rite menu + one-active SPEL swap + dawn fade/restore |

All proposed effects below stay at Rooted-Rest scale: ~5% magnitudes,
10-minute pulses, once/day caps, one-shot pilgrimage pulses. None add a new
always-on boon family, so the two-family hybrid budget is untouched.

## Thinness Risk Ranking

Sourced from the balance audit verdicts, the reward-budget ledger, and the
race sheets' own implementation notes ("vanilla hook surface" sections):

| Rank | Race | Audit verdict | Where it will feel thin in play | Tranche priority |
|---|---|---|---|---|
| 1 | Bosmer | `Watch` — "sparse vanilla Bosmer content can weaken non-hunter paths" | Living Story, Exchange, and Bandit Road players get far fewer felt beats than Old Contract hunters; no Y'ffre shrine exists in Skyrim | P1 |
| 2 | Orc | `Watch` — "Stronghold/crafting are rich and City plus Legion/Exile still need dynamic situational parity" | City and Legion/Exile Orcs have lower piety rates AND fewer authored surfaces — double thinness; the locked self-made-community row has no built mechanic yet | P1 |
| 3 | Altmer | `Watch` — "can still feel punitive if normal Skyrim play is over-taxed" | Friction (Lorkhan pressure, crisis) is the richest layer; positive ordinary-session texture is mostly the dawn rite. A race can be content-rich and still feel thin if the richness is all cost | P1 |
| 4 | Redguard | `Watch` — "death-duty and martial hooks can swallow sect nuance"; Ash'abah stigma "sparse without custom support" | Non-martial Redguard play is under-served; sect distinction lives mostly in scoring weights the player never feels; the locked sword-tending rite is named but unbuilt | P2 |
| 5 | Khajiit | `Watch` — Lattice landed; residual "Baan Dar, Rajhin, and Alkosh are crowded out by Khenarthi/Azurah" | Focus distinctness only; substrate is now rich | P2 (small) |
| — | Nord, Imperial | `Watch` (ceiling) | Not thin — hook-dense. Their open work is caps and concrete-act filters | No tranche |
| — | Breton, Dunmer | `Overstack Risk` | The opposite problem. Adding variety mechanics here would worsen the audit's stated risk | No tranche |

The explicit non-goal: Breton, Dunmer, Nord, and Imperial do not get
tranches. The audit says their remaining work is restraint (ceilings,
budget gates, stack control), and a variety tranche is the wrong medicine.

---

## Bosmer — "The Story Goes On" Tranche (P1)

Target: make the three non-hunter paths produce felt beats at the cadence
Old Contract hunters already get from GPC and hunting signals. Everything
is path-gated by `PDV_State_BosmerPath`; nothing adds Old Contract burden
to other paths (locked shared-Pact-memory rule).

| Lever | Proposal | Notes |
|---|---|---|
| L1 — Green dreams | Sleep dreams keyed to active path + (Old Contract only) GPC band. Living Story dreams retell the player's recent quests as Story fragments; Exchange dreams weigh unsettled debts; Bandit Road dreams are road-fire stories; Old Contract dreams sharpen or sour with the GPC band | Direct reuse of the Argonian dream roller. Path change = elevated dream chance that night, same as posture change |
| L2 — Hearth of the Telling (Living Story) | Cell-keyed declaration of a community hearth (inn or home). Sleeping there after discovering 3+ new locations since the last stay grants `A Tale Carried` (Speech +5, 10 min) — the story was brought home and told | Reuses bed-of-choice cell tech. Anti-farm: location-discovery delta, not sleep count |
| L3 — Path signatures | Exchange: `Scales at Rest` — once/day, completing any favor/bounty/contract quest grants a brief barter pulse. Bandit Road: `Baan Dar Opens the Gap` — once/day, dropping below 20% health in combat grants a 5s movement burst (escape texture, distinct from the weekly Champion luck moment, which stays rare per the locked sheet) | Both are once/day, quiet surfacing. Old Contract intentionally gets no new signature — it is already the richest path |
| L4 — Songs of the Green | Six curated green sites; first arrival each = one vision line + small Y'ffre/path pulse; all six = milestone. Locked set: the Gildergreen (Whiterun), Kynesgrove's grove, Eldergleam Sanctuary, Evergreen Grove, Clearspring Tarn, Autumnshade Clearing | RESOLVED 2026-06-12: Eldergleam stays in both sets under the shared-site rule (shared LCTNs allowed with race-distinct vision text). Kynareth-proxy logic (locked) makes the Gildergreen the anchor site |
| L5 — The Naming | Rite at the declared hearth (or any green site), 7-day cooldown: Y'ffre told the Bosmer their forms, and the diaspora Bosmer retells their own. One-active choice of told-self: Hunter (+5 archery), Speaker (+5 speech), Wanderer (+8% stamina regen), Keeper (+5% barter). Fades at dawn if path coherence breaks (path switch or, for Old Contract, Apostate band); returns at dawn on recovery | Mirrors Hist Adaptations exactly. The "form held by story" frame is the strongest lore fit in the whole roadmap — Bosmer fear losing their form when the Story stops being told |

## Orc — "Witnessed" Tranche (P1)

Target: close the City / Legion-Exile felt-content gap without violating
the locked feasibility rule (curated hooks or `PDV_SacredPlace` state only —
no broad social simulation). The headline item builds the locked but
unbuilt self-made-community row on proven Argonian tech.

| Lever | Proposal | Notes |
|---|---|---|
| L1 — The Watcher's regard | Not dreams — Malacath observes, he does not visit. Rare top-left observation lines after qualifying mode-coded conduct ("The work was true. It was seen."), keyed to `PDV_State_OrcLifeMode`. Silence itself is the neglect texture, so lines stay rare (cap 1/dawn) | Cheapest lever; pure texture on existing signal routes |
| L2 — Self-made community (City + Legion/Exile) | Cell-keyed declaration of a chosen forge/home/workplace: "This place is mine to keep." Return-plus-investment (sleep there after a qualifying quality-craft or completed-service day) builds standing; at 3 invested returns grants `Hearth-Held` (small health regen pulse, 10 min) | This IS the locked `PDV_SacredPlace` City/Exile row, implemented with the proven bed-of-choice cell mechanic instead of a new substrate. City presentation: belonging built; Legion/Exile presentation: burden returned from (locked phrasing) |
| L3 — The Code Holds | Once/day, surviving a fight after dropping below 20% health without leaving the cell grants a brief post-combat survival restore (a flat Health restore in the live build, not a rate-regen pulse -- Requiem-proof). Quiet in City/Legion modes, Noted in Stronghold context | Distinct from the Stronghold Champion fury (15%, full restore): this is small, all-modes, all-tiers texture. Endurance-shaped, which is the Legion/Exile devotional language |
| L4 — The Four Holds of the Code | One-shot first-arrival pulse at each of the four strongholds (Dushnikh Yal, Mor Khazgur, Narzulbur, Largashbur); all four = milestone. For a City or Exile Orc this is belonging-across-distance — the same emotional job Waters That Remember does for Argonians | Largashbur is hostile pre-`The Cursed Tribe`; arrival pulse must fire on the location, not on friendly entry. Anti-farm one-shot forever |
| L5 — Trial of Iron | Rite at a forge inside the declared community place or any stronghold, 7-day cooldown: one-active discipline — Hammer (+5 smithing), Shield (+5 armor), Tusk (+5 unarmed), Yoke (+15 carry). Fades at dawn if mode standing collapses (e.g. sustained oath-breaking); returns on recovery | Forge-sited rite keeps it inside Malacath's devotional language: conduct, not prayer |

## Altmer — "The Return Made Daily" Tranche (P1)

Target: the inverse problem. Altmer is friction-rich and texture-poor on
the positive side; the audit's worry is punitive feel. This tranche adds
ordinary-session positive surfaces that are coherence-shaped, never
volume-shaped, and never weaken the Lorkhan economy (all locked).

| Lever | Proposal | Notes |
|---|---|---|
| L1 — Contemplations | Dawn-window lines keyed to `PDV_State_AltmerCrisis` and ThalmorAlignment band. A `Dissonant` Altmer's dawn reads differently from a coherent one; resolution day gets one Marked line. Makes the crisis arc legible as lived experience, not just Survey state | Texture on the existing dawn rite + crisis state; no new piety |
| L2 — Chamber of Study | Cell-keyed declaration of a study (home, College quarters, inn room). Reading a qualifying text (the locked `PDV_ALT_POS_STUDY_TEXT` list) inside the declared study grants `Ordered Mind` (+5% magicka regen, 10 min). The declaration prompt fires on first qualifying read in an ownable cell | Bed-of-choice tech keyed to book-read instead of sleep. Gives self-cultivation a *place*, which Altmer currently lack entirely |
| L3 — Syrabane's Hand | Once/day, a ward that fully absorbs a hostile spell grants a brief spell-cost pulse ("Syrabane's hand steadies yours"). Coherence-gated: suppressed while a crisis is unresolved | Protection-shaped per the locked Syrabane boundary ("favor should feel like warding someone still on the path"); not a damage reward |
| L4 — Wayshrines of the Chantry | RESOLVED 2026-06-12 as a hybrid eight-station circuit: two base-game stations (College Hall of the Elements + one authored Auri-El surface) felt in early play, then the five Forgotten Vale wayshrines (Illumination, Sight, Learning, Resolution, Radiance) + the Inner Sanctum as the deep arc; first arrival each = vision line + small Auri-El pulse; milestone at all eight. The Initiate's Ewer pilgrimage is literally this mechanic in vanilla lore | Dawnguard.esm is already a framework master (Ancestor Glade precedent), so the Vale stations add no new dependency |
| L5 — Disciplines of Return | Rite at the declared study, 7-day cooldown: one-active cultivation discipline — one school of magic gets -5% cost OR +5% regen variants across four choices. Fades at dawn while a crisis is unresolved or after an alignment-band break; returns at dawn on coherent recovery | The fade/return rule turns the existing crisis system into something the player *feels* in their build, gently — which is exactly the "judged by coherence" core design intent |

## Redguard — "The Far Shores Keep Watch" Tranche (P2)

Target: give sect identity and the ancestor layer non-martial felt
surfaces, and build the two devotional surfaces the locked sheet already
names but does not implement (sword-tending rite; light Ash'abah texture).

| Lever | Proposal | Notes |
|---|---|---|
| L1 — Far Shores dreams | Sleep dreams keyed to sect + ancestor-layer posture. Crown dreams are inheritance (the line of swords); Forebear dreams are the road and the wind; Ash'abah dreams are the dead at rest because of work the dreamer did — or restless because it waits | Dream roller reuse; the Ash'abah variant quietly carries the stigma burden 1.0 cannot socially simulate |
| L2 — Sword-Tending Rite | At the portable Far Shores token in a private/player-owned context (the locked Tu'whacca surface), tending the blade grants a small Leki pulse and counts as the daily Yokudan observance. 24h cooldown | Implements the rite the locked sheet already lists as "optional sword-tending rite." No new state — hangs off the token |
| L3 — Sect signatures | Crown: `Leki's Measure` — once/day, killing a hostile with a one-handed weapon while at full health grants a brief blade pulse (discipline texture: you were never touched). Forebear: `Tava's Departure` — once/day, leaving a walled city on foot at dawn grants a brief stamina-regen road blessing. Ash'abah: `The Unclean Hour` — once/day, the first undead destroyed inside a tomb grants a brief undead-resist pulse | All once/day and small, so HoonDing make-way stays rare per the locked Crown make-way rule — these never touch the make-way frame |
| L4 — The Halls of the Dead | Six one-shot stations of death-duty: the Halls of the Dead in Whiterun, Windhelm, Solitude, Markarth, and Riften, plus Falkreath's graveyard. First respectful visit each = ancestor-layer pulse + sect-flavored vision line; all six = milestone | Non-martial by design — visiting and paying respect, not clearing. Strongest for Ash'abah (locked: Hall duty is their best vanilla surface), meaningful for all sects via the always-active ancestor layer |
| L5 — The Remembering of Names | Rite at the Far Shores token in private context, 7-day cooldown: one-active ancestral observance — Blade (Leki, +5 one-handed), Road (Tava, +8% stamina regen), Rest (Tu'whacca, +5% health regen), Harvest (Zeht, +5% barter). Fades at dawn if sect coherence breaks (mid-switch window); returns on settled sect | Gives the "ancestors always present" layer a player-authored expression instead of only passive modifiers |

## Khajiit — Focus Distinctness Addendum (P2, small)

The Lattice closed the substrate gap; what remains is the audit's
"Khenarthi/Azurah crowd out the others." Three focus-gated signatures,
no new substrate work:

- `Rajhin's Borrowed Moment` — once/day, a successful pickpocket of a
  notable target while Rajhin-focused grants a brief sneak pulse.
- `Baan Dar's Improvisation` — once/day, surviving combat that started
  while outnumbered 3+ grants a brief stamina pulse (pariah luck texture,
  parallel to the Bosmer Bandit Road signature but trigger-distinct).
- `Alkosh's Long Breath` — rare: dragon kills while Alkosh-focused grant a
  Marked time-flavor line and a small pulse. Naturally scarce; no cap
  needed beyond the encounter rate.

Road-home cadence already exists in the locked design; no L2/L4 work here.

---

## Build Order And Gates

Follow the Argonian tranche's proven path per race:

1. **Design lock pass — DONE 2026-06-12** — all five tranches are folded
   into their race sheets, the effect-review ledger carries the variety
   tranche gate, and the decisions below are resolved.
2. **Record batch manifest** — one
   `PDV_<Race>Variety_RecordBatch.manifest.json` per race (MESG/FLST/SPEL/
   MGEF + manager VMAD props), authored by a narrow
   `tools/pdv-<race>-variety-author` following the Argonian author's
   fail-closed `--dry-run`/`--check` shape.
3. **Runtime wiring** — dream roller, cell-declaration, signature, LCTN
   router, and rite handlers are parameterized reuses of the Argonian
   manager code paths; budget each as modification, not new systems.
4. **Beta packet addendum** — extend the race's beta packet with the
   tranche checklist + a `DebugSeed<Race>` SetPQV harness, exactly as
   `PDV_BetaTestPacket_Argonian.md` does.
5. **Ledger refresh** — reward-budget ledger, completeness gap ledger, and
   (if reward families shift) the cumulative-magnitude hand-tuning rule
   from `pdv_cumulative_rebalance.mjs` (the tool is one-shot-spent; edits
   are by hand now).

**Build status (2026-06-13):** Bosmer batch **records + runtime layer landed,
machine-verified, in-game smoke PENDING.** The four Songs LCTN FormIDs are
resolved (slot-2 `WhiterunWindDistrictLocation` swapped to
`WhiterunTempleofKynarethLocation 01F87D` — the former is not an LCTN); the
author tool wrote the 2 MESG / 7 SPEL+MGEF / 6-entry FLST / 10 VMAD props
(`--check` PASS), and the `PDV__ManagerQuest.psc` Bosmer runtime layer (step 3)
is applied + compiled 0/0 (with the location hook in `PDV_ActionRouter` and the
Baan Dar Gap routed through `PDV_EventBus.RouteBosmerBaanDarGap` from the shared
Khajiit/Bosmer combat-session poll, replacing the direct low-health `OnHitEx`
route). Debug MCM gained Bosmer→LivingStory/Exchange + "Seed Bosmer variety"
controls. **Remaining gate: the fresh-save smoke** in
`PDV_BetaTestPacket_Bosmer.md` ("Single-Session Smoke (MCM-driven)") — until it
returns PASS, Bosmer is **NOT runtime-proven**. Orc, Altmer, Redguard, and the
Khajiit addendum remain design-locked but unbuilt.

Suggested order: **Bosmer → Orc → Altmer → Redguard → Khajiit addendum.**
Bosmer first because three of its four paths are under-served at once;
Orc second because the tranche doubles as the unbuilt locked
self-made-community row; Altmer third because its tranche is mostly
texture on already-wired state and de-risks the audit's punitive-feel
concern before external beta.

## Resolved Decisions (2026-06-12)

All five tranches are design-locked into their race sheets as of this date.
Magnitudes remain tunable inside the effect-review gate; shapes, gates,
caps, and fade rules are locked.

1. **Shared pilgrimage sites — RESOLVED: share with distinct visions.**
   Two races' curated sets may include the same LCTN with race-distinct
   vision text. Eldergleam Sanctuary stays in both the Argonian Waters set
   and the Bosmer Songs set; a sacred tree is sacred to both theologies.
2. **Altmer pilgrimage pacing — RESOLVED: hybrid eight stations.** Two
   base-game stations (College Hall of the Elements + one authored Auri-El
   surface) front-run the five Forgotten Vale wayshrines + Inner Sanctum;
   milestone fires at all eight.
3. **Lever-4 master flags — RESOLVED: Dawnguard.esm acceptable.** The
   Argonian Waters set already made Dawnguard.esm a hard framework master
   (Ancestor Glade), and SSE ships with all DLC, so the dependency cost is
   already paid; the Vale stations add nothing new.
4. **Signature overlap — RESOLVED: keep both Baan Dar signatures.**
   `Baan Dar Opens the Gap` (Bosmer, escape-below-20%-health) and
   `Baan Dar's Improvisation` (Khajiit, survive-outnumbered-3+) are
   intentionally trigger-distinct expressions of a canonically shared
   deity (the stance matrix already reconciles Baan Dar across both
   races via the shared-deity SGE work). The pairing is documented here
   and cross-noted in both race sheets.
   `PDV_PairedEquityWaivers.csv` is NOT the home for this record: that
   file's schema (`cluster,editor_id,outcome_stage,deity,reason`) is
   quest-matrix-cell-shaped and consumed by `pdv_paired_equity_audit.mjs`;
   signatures are not matrix cells. If the equity audit later grows a
   signature lens, migrate this note into whatever schema it defines.
5. **Orc L2 vs future substrate — forward note (no decision needed).** If
   a true `PDV_SacredPlace` system is ever built, the cell-keyed
   Hearth-Held mechanic migrates into it; carry this note in the Orc
   record-batch manifest the way Hist-fold tuning is held in the Argonian
   manifest.

## Post-Lock Doc-Sync Note

The Argonian race sheet predates the tranche pattern and does not carry a
variety-tranche section (its tranche is documented in
`PDV_ArgonianVariety_RecordBatch.manifest.json` and the beta packet
addendum). Backfilling a matching section into
`race-sheets/PDV_RaceDesign_Argonian.md` for sheet parity is a low-priority
doc-sync task; the shipped records stay authoritative.
