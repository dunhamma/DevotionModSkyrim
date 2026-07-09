# PDV Signal Floor - Low-Deity Deep Dive - Consolidated Codex Handoff - 2026-07-09

Consolidates the lowest-5-positive deep dive (The Hist, Dibella, Y'ffre,
Zenithar, Syrabane), the follow-up extrapolation pass (Y'ffre/Zenithar/
Syrabane), and everything routed to Codex. Supersedes nothing; companions:
`PDV_SignalFloor_Tranche10_CodexHandoff.md` (original tranche10 smoke matrix),
`PDV_SignalFloor_LikesDislikes_CodexHandoff.md` (LD v15),
`PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md` (waivers).

## A. What shipped in this deep-dive round (already done, gates green)

12 new Tranche10 rows (Full.csv 993 -> 1005 cells, 124 watched quests, 156
keys; compile/adversary/verify/formal-offer all PASS; live StorageUtil JSON
regenerated):

| Deity | Row | Why |
|---|---|---|
| The Hist + | DLC2SV01 s200 defend_kin_home m/echo | Nature-bound settled People freed as a collective - closest in-game Hist analogue |
| The Hist + | DLC2SV02 s200 honor_the_wild m/echo | Sacred stones tended and returned to a People |
| Dibella + | BYOHRelationshipAdoption s10 marriage_family m/small | Adoption = hearth-keeping (HearthFires) |
| Dibella + | BYOHRelationshipAdoptableOrphanage s200 charity+marriage_family m/small | Honorhall adoption |
| Y'ffre + | C06 s200 the_hunt S/small | Werewolf cure = setting down the unsanctioned beast-shape |
| Y'ffre + | C04 s200 the_hunt m/echo | Glenmoril witch-heads enable the cure (companion beat) |
| Syrabane + | MG07 s200 protect_the_weak m/echo | Staff of Magnus = counter-weapon to the Eye threat |
| Syrabane + | MG02 s200 protect_the_weak S/small | Saarthal hazard contained |
| Syrabane + | DA01 s100 destroy_reject_daedra:molagbal m/echo | Cleansed Azura's Star = protective soul-warding |
| Syrabane - | DA10 s200 serve_a_daedra:molagbal+kill_the_helpless m/echo | The domination blood-bargain |
| Zenithar - | TG08B s200 theft_burglary S/small | Eyes of the Falmer grand burglary |
| Z'en - | TG08B s200 theft_burglary m/small | Paired echo one step down |

New combined-quest counts: The Hist +3/-1, Dibella +11/-9, Y'ffre +11/-2,
Zenithar +10/-9 (Z'en +12/-7), Syrabane +14/-10.

**Dibella clarification (user question):** her MS05 (Tending the Flames s300,
her only C-intensity beat), T01 (Heart of Dibella) and t02 (Book of Love) rows
were ALREADY in the matrix and are LIVE - they were never dropped. They carry a
"PROVISIONAL / completion-convention" flag only because the readback scan never
covered those quest lanes, so their exact stages are UESP-derived rather than
readback-verified. The refresh below CONFIRMS them; no re-authoring needed.

## B. Codex work item 1 - READBACK REFRESH (highest value)

Extend `tools/pdv_extract_quest_stage_readback.mjs` coverage (currently only
Dawnguard/Companions/Daedric/CW/MQ/MG/DB/TG/DLC2 lanes) to add these quests,
then hand the new rows back for a small tranche addendum:

| Quest | Unlocks |
|---|---|
| `MS02` (No One Escapes Cidhna Mine) | Mephala negative (betray Madanach), Nocturnal negative |
| `MS01` (The Forsworn Conspiracy) | Mephala/Clavicus deceit reads |
| `DBDestroy` (Destroy the Dark Brotherhood) | The strongest Sithis negative in the game; Nocturnal/Mephala expose reads |
| `C05`-adjacent "Purity" (Farkas/Vilkas cures) | Hircine negatives x2; possible Y'ffre echo |
| EEC "Rise in the East" (Solitude; verify true editor_id) | Zenithar's purest civic-prosperity milestone + Z'en echo |
| `MS05` Tending the Flames | CONFIRM Dibella's provisional s300 C-beat |
| `T01` Heart of Dibella, `t02` Book of Love, `RelationshipMarriage` | Confirm provisional stages; possible direct wedding row |
| `FreeformKolskeggrB`, Shor's Stone / Soljund's Sinkhole mine quests | Zenithar restore-to-labor positives |
| Totems of Hircine radiants (CR07+) | Y'ffre/Hircine hunt-law reads (LOW priority; radiant, may be unusable) |

CAUTION: two different quests were referred to as "MS05" during research
(Tending the Flames vs Rise in the East). Resolve the actual editor_ids during
extraction - do not trust either label until read back.

Also spot-check flagged stages: `DA13 s102` (custom QE route - expected absent
from vanilla readback, documented in the tranche9 handoff; verify the QE patch
still provides it), `DA14Start s70`, `DLC2RRFavor01 s200`, `T03 s105`,
`BYOHRelationshipAdoption s10` / `BYOHRelationshipAdoptableOrphanage s200`
(stages exist in stage_indices but carry no completion_stages marker - prove
they fire at adoption).

## C. Codex work item 2 - Part D faucet hooks (from the original tranche10 handoff, still open)

- Sanguine "Drink skooma" (curated ALCH FormList, revel_indulge +C small,
  shares the 1/dawn revel cap with alcohol - no double-bank).
- Sheogorath "Fire the Wabbajack" (staff-fire OnSpellCast mirroring the
  Sanguine Rose sender, +S small, shares 1/dawn with the carry faucet).
Add faucet CSV rows ONLY together with the hooks (declared-but-not-dispatched
gate); faucetActs goes 24 -> 26.

## D. Codex work item 3 - Behavioral/substrate passes (Tier 3; biggest felt upside for the genuinely-thin two)

**Y'ffre Green Way behavioral pass** (discharges the deferred green-way signal
debt; pre-1.0 per standing directive):
1. Populate `PDV_FLST_P2_BretonGreenWayHarvests` (hook already wired, FLST
   empty) with curated wild-gathered ingredients; daily-capped.
2. Location-site fanout via `HandleBosmerLocationChange`: per-site
   `PDV.Yffre.Seen.<X>` keys for Eldergleam Sanctuary, Ancestor Glade,
   All-Maker stones, the Gildergreen; one-per-site + daily cap.
3. WEATHER hook (net-new; no deity uses weather yet) - a green/storm
   open-sky attunement pulse.
4. Plant-consumption negative (the Meat Mandate; shipped
   `PDV_Msg_Bosmer_GreenPact_PlantConsumed_Marked` copy is MECHANICS-BLOCKED
   pending a food-tag layer).

**Hist substrate enrichment** (per the 2026-06-25 decision doc - quest matrix
is NOT the Hist's home):
1. Author a curated PDV quest-stage source so `PDV_Substrate_ArgonianHist`
   posture transitions / Hist-Sap communion count as a real source-type in the
   signal-floor audit.
2. Promote the existing near-water maintenance to a counted location
   source-type; consider a marsh-rain weather signal.
3. Formally mark `argonian_people` expected-N/A in the signal-floor registry
   (credit routes to the Hist by design) instead of leaving it CRITICAL.
4. C06 werewolf-cure runtime note: prefer the werewolf-cure gate over raw
   stage for the Y'ffre row where the runtime can see curse state.

**Syrabane explicit non-goals (locked):** do NOT make him an LD day-to-day
actor and do NOT add an every-ward-cast faucet - that is the farm his locked
identity forbids and no ward-absorb detector exists. Quest-and-reward driven
for V1.

**Zenithar explicit non-goal:** no "sell goods" faucet (no clean vanilla
transaction hook); his crafting day-to-day is already the pantheon reference
model.

## E. Rejected candidates this round (do not re-add without new evidence)

Y'ffre: DA05 s205 / Skaal freeform fails (no log text), DA14 s10 (building
vandalism, not nature), defend-a-Nord-city cross-gen rows (DA06/CW03/MQ104 -
padding for a forest-god), burn/grove log sweep (zero player nature-negatives).
Zenithar: TG05 (plot reveal), TG08A (Nocturnal pact), TG09 (restitution -
Nocturnal-owned), TGTQ* (not in readback), DLC2RR03Intro/DLC2TGQuest/Kagrumez
(no log text / loot-claiming), DarkBrotherhoodSanctuaryRepair (DB-tainted),
DB01Misc (Loreius's labor, not the player's).
Syrabane: MG03 s200 / MG06 (study lane), MG04 (setup), MG05 s30 (event not
act), DLC1VQ04/05 (mixed valence + no log text), DA07 (Dagon lane), DA16
intermediates (truncated text), DLC1VQ06 finale (double-credits VQ07),
DA13 s100 (serving the plague-Prince - wrong valence).
Dibella: Markarth favors/Recorder/Angeline (radiant favors), TG01 statue
(Rajhin-owned). Hist: all funerary honor_the_dead echoes (Hist dead return to
the Root, not Sovngarde); no readback refresh warranted (candidate universe
genuinely empty).

## G. Magnitude recalibration (DONE this session) + crypt-cleared signal (Codex build)

### G1. Event-scale magnitude model - echo tier RETIRED

Design decision (2026-07-09): signal weight follows EVENT SCALE. Quests are arc
completions and sit at the top; single incidents at the bottom; a location/crypt
cleared in between.

| Event scale | Surface | Tier | Piety |
|---|---|---|---|
| Quest = arc completion | quest-reaction matrix | milestone (core) / small (peripheral) | 8-18 / 2-6 |
| Location / crypt cleared | location-cleared signal (this section) | small | 2-6 |
| Single incident (undead in the wild) | day-to-day faucet | day-to-day | 0.25-0.5 daily-capped |

Applied: all 533 `echo` rows promoted to `small` across the source tranches
(Full.csv now 891 small / 114 milestone / 0 echo). `value.echo.*` left in the
compile value table but unused; do not author new echo rows. Quest awards are
UNCAPPED (ApplyQuestReactionPiety -> AwardPiety full amount), so milestone
completions move hard toward the 85-Champion budget - intended. Chosen scope was
"retire echo -> small; keep the existing 114 milestone as the primary-arc tier"
(not "all quests milestone"), to protect the 30-45 day pacing target. Optional
future refinement (NOT applied): promote the 59 `small.C` core-tag rows to
milestone if in-game pacing shows core quests still feel light.

### G2. Generalized crypt-cleared signal (Codex - Papyrus + FormList + CK)

The mod already has the exact pattern, scoped to one sect:
`PDV__ManagerQuest.psc` `TrackRedguardAshAbahUndeadSiteVisit(Location)` arms a
site on entry; `HandleRedguardAshAbahUndeadSiteClear(Location)` fires when
`Location.IsCleared()`, once per site, with `ConsumeDailyRepeatMultiplier` for
anti-farm, keyed off `PDV_FLST_RedguardAshAbahUndeadClearSites`. Generalize it:

1. New FormList `PDV_FLST_UndeadCryptClearSites` (CK/houseCARL) - curated Location
   records for draugr barrows / undead crypts / necromancer lairs (Bleak Falls
   Barrow, Ustengrav, Labyrinthian, Korvanjund, Movarth's Lair, Ansilvund,
   Forsaken Cave, etc.). Location records, not cells; use `IsCleared()`.
2. New handlers mirroring the Ash'abah pair (arm-on-enter via the existing
   location-change hook; fire-on-`IsCleared()`), NOT origin-gated - fires for any
   player. Once per site + `ConsumeDailyRepeatMultiplier("PDV.Signal.UndeadCryptClear")`.
3. Fan out at the **small** tier (2-6) to the undead-domain deities:
   Arkay, Stendarr, Meridia, Tu'whacca, Azura, and **Y'ffre** (bone-law: draugr
   are matter walking outside its fixed story - Part B `slay_undead`(m) was added
   for exactly this). Weight by each deity's undead-tag intensity.
4. This is the correct home for "cleared a draugr crypt." The 6 Y'ffre draugr
   quest-echoes added earlier were REMOVED this session (wrong surface + echo
   weight); Y'ffre keeps the Part B `slay_undead` approval, realized via this
   signal once built.
5. MIGRATION REVIEW (after the signal is live): the existing `slay_undead` QUEST
   rows on dungeon-clear quests (MQ103 Bleak Falls, CW02A/B Jagged Crown, MG07
   Labyrinthian for Arkay/Stendarr/Meridia/Tu'whacca/Azura) now double-cover
   undead-clearing on both surfaces. Decide per row: keep as a quest milestone
   where the undead-purge IS the arc (DA09 Break of Dawn, MS14 Laid to Rest), but
   migrate the incidental dungeon-clear rows to the crypt-cleared signal to avoid
   double-crediting.

### G3. Day-to-day "kill undead in the wild" (optional, smallest tier)

If a single wild-undead kill should register at all, it belongs in the day-to-day
faucet (0.25-0.5, daily-capped), NOT the quest matrix. There is no
EVT_KILL_UNDEAD dispatch today (365 is raise-undead); adding one would need an
ActorTypeUndead branch in `ClassifyKillVictim` (PDV_ActionRouter). Low priority -
the crypt-cleared signal already captures the meaningful version.

## F. Proof boundary

Everything above section B is authority/readback/static only - compile PASS,
verify 3546/0 FAIL, adversary thin-Hist-only, live JSON written. NO in-game
smoke has run for any deep-dive row. Representative smoke additions to the
existing tranche10 matrix: `setstage DLC2SV01 200` (Hist echo + Y'ffre +
Syrabane fan-out), adoption flow (Dibella), `setstage C06 200` as a werewolf
(Y'ffre cure row), `setstage TG08B 200` (Zenithar/Z'en losses),
`setstage DA10 200` (Syrabane loss alongside existing Molag Bal/Stendarr rows).
