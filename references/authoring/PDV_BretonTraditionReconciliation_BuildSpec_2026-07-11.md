# Breton Tradition Reconciliation + Green Way Enrichment - Build Spec (2026-07-11)

**Status:** design-locked, pending sign-off then gated ESP write.
**Owner decisions captured this session; do not re-open without owner.**

Purpose: fix three linked problems found this session, all on Breton:
1. Tradition rewards drifted from v3 architecture (single-deity gate + a
   forbidden generic broad lane).
2. All six Breton P2 immersive-source FormLists ship EMPTY - the whole
   day-to-day signal layer for every Breton tradition fires nothing.
3. Green Way is the thinnest lane in the game (2/5 signal types, UNDER-FLOOR),
   with only one behavioral dislike and no location/travel signal at all.

## Verified facts (houseCARL, profile Devotion Dev, 2026-07-11)

- CORRECTION (2026-07-11): the six Breton P2 FormLists are NOT empty. An earlier
  claim of "6 empty lists" was a wrong-field houseCARL query (asked for `FormIDs`;
  the real field is `Items`). Verified populated: `071044 GreenWayHarvests` = 4
  (Spriggan Sap/Taproot/Nirnroot/Crimson Nirnroot); `071049 VowSources` = 2
  (t02/MS14); the other four contain their manifest-approved forms
  (`--check-source-fill` = 0 errors, `--fill-source-entries` = no-op, ESP
  byte-identical). Part 2a "fill 6 lists" was already satisfied. The real residual
  is a STALE signal-floor ledger that still marks these INCOMPLETE/shell.
- `PDV_Deity_Yffre` (`06CB52`) `Stance_Breton = 0` (NATIVE). Green Way Breton
  gets full-rate Y'ffre quest reactions; no stance migration needed.
- Y'ffre is in the Breton origin roster ([PDV__ManagerQuest.psc:2928]) so the
  ~20 tranche10 Y'ffre matrix rows already reach a Breton.

## Architecture anchors (do not violate)

- v3 12.5 / v3:1489: Breton receives NO generic broad lane. Broad worship is
  `PDV_GLO_PatronState` (broad = Tier 2 cap), tradition is an orthogonal filter.
- v3:326: "Breton tradition is a filter" over a multi-deity pool.
- Race sheet 10.3: tradition breadth -> Tier 2 cap; focused deity -> Tier 3.
- Green Way is the SOFTER analog of the Bosmer Green Pact: no Pact-strict food
  compliance, no strict craft taboo (owner-confirmed softer dislike set).

---

## Part 1 - Tradition reward reconciliation (manager logic)

File: `live-source/Scripts/Source/PDV__ManagerQuest.psc`.

**Model:** each tradition family becomes a two-phase lane. Broad phase (T1/T2)
lights from tradition breadth; focused phase (T3) from a committed patron.

1. New `Int Function GetBretonTraditionTier(Int traditionValue)`:
   - Resolve the tradition's eligible deity pool via
     `GetBretonTraditionPool(traditionValue)`:
     - KnightsRoad: {Stendarr, Mara, Arkay, Julianos, Akatosh} (Zenithar,
       Kynareth, Dibella only if they carry Breton stance + scoring - verify).
     - GreenWay: {Yffre}.
     - HiddenArt: the ACTIVE Daedric-via-20C patron (Hircine/Mora/Namira/
       Nocturnal); Magnus/Mara are cover/support rows, NOT the tier source.
   - Broad phase (`GetPatronState() == PATRON_STATE_BROAD`): best tier across
     the pool, capped at `TIER_DEVOTED` (Tier 2).
   - Focused phase (`PATRON_STATE_ACTIVE`, active patron in the pool): the
     committed patron's own tier, may reach `TIER_CHAMPION` (Tier 3).
2. `SyncBretonTraditionRewardFamily` ([13156]): replace the `deity` param /
   `GetTier(deity)` read with `GetBretonTraditionTier(thisTradition)`. Keep the
   existing one-active-spell-by-tier shape.
3. Retire the generic broad lane: drop the `PDV_Bless_Breton_Tradition_T1/T2`
   grants ([13134]) and force inactive. The broad role now lives in each
   tradition family's T1/T2 phase.
4. `GetFirstTierRaceRewardSpellForOrigin` ([14239]): return the ACTIVE
   tradition's T1 (KnightsRoad_T1 / HiddenArt_T1 / GreenWay_T1) instead of the
   generic Tradition_T1.
5. Verify `PDV_BretonAncestorSubstrate` ([13127]) is not a live second always-on
   boon (design ref says Breton has no substrate); if inert, leave; if live,
   flag to owner - it affects the "one family" budget claim.

Records/spec: mark `PDV_Bless_Breton_Tradition_T1/T2` deprecated in
`PDV_BretonRewardRecords.spec.json` (stop granting; defer ESP record deletion).
Rewrite the budget note: ONE active tradition family (broad T1/T2 -> focused
T3), other two suppressed. Under the <=2 always-on ceiling.

Felt ledger: drop `Breton-Tradition|boon` from
`PDV_FeltFamilyEvidenceLedger.json` (148 -> 147 families).

---

## Part 2 - Green Way signal enrichment

### 2A. Fill all six empty FormLists

Owner: fill ALL six (Knight's Road + Hidden Art + Green Way), one authoring
pass. Curate per `PDV_Phase20_P2ImmersiveReceivers.manifest.json` acceptedUse;
verify every FormKey via houseCARL; do NOT invent FormIDs.

- `BretonGreenWayHarvests` - wild-growing flora, broadened past the 6 "sacred"
  ones but excluding shop-bought/farmed reagents (owner: forage is universal).
- `BretonGreenWaySources` - Y'ffre/nature books; thin vanilla pool, backfill
  with nature-site quest-stage milestones if under target.
- `BretonHiddenArtSources` - curated occult/witchcraft books.
- `BretonHiddenArtSpells` - occult spell FormList (conjuration/illusion focus).
- `BretonKnightsRoadSources` - civic/mercy source forms.
- `BretonVowSources` - vow-breach source forms.

### 2B. Green Way pilgrimage (Breton-only, large, discovery-based)

- New `PDV_FLST_GreenWay_NatureSites` (spine) + `PDV_FLST_GreenWay_Stones`
  (secondary ring). Owner picked option (b): nature sites are the spine, the 13
  Standing Stones are the secondary ring.
  - Nature-site spine: Spriggan groves (MossMother 01927E, RoadsideRuins 04787B,
    Shadowgreen 01929C), Eldergleam Sanctuary, the Gildergreen, sacred springs.
  - Stone ring: the 13 vanilla Standing Stones (DoomstoneWarrior/Mage/Thief +
    Lord/Lady/Steed/Apprentice/Atronach/Ritual/Serpent/Shadow/Tower/Lover).
- Mechanism = LOCATION DISCOVERY, mirroring `AwardArgonianSacredWater`
  ([5263]): per-site seen key, running count, per-visit Book-of-Days beat, a
  CAPSTONE bonus when the set is complete. NEVER touches the stone activator, so
  a committed stone power is never disturbed (owner's concern resolved).
- Route via `HandleStoryChangeLocation` ([PDV_ActionRouter:239]); new
  `HandleBretonGreenWaySiteDiscovery(Location)` on the same pattern.

### 2C. Renewable loop (the "regular play feeds it" backstop)

Universal spine (any Green Way druid, wherever they live):
- Forage wild flora (2A harvest list).
- Alchemy from wild-gathered ingredients (herbalist craft; daily-capped).
- Tend growing things (Hearthfire garden/greenhouse planter harvest).

Lifestyle textures (both valid, both roll up to Y'ffre):
- Wild-ranger: outdoor sleep, hunt (any wild-game kill), walk the land.
- Hearth-druid: rest at a rustic home + garden tending.

Rustic-home bonus WITHOUT ownership detection (owner loved the idea, unsure of
mechanism):
- Mechanism A - rest-location split, KEYWORD-HEURISTIC primary (mod-agnostic;
  no whitelist can cover the hundreds of Nexus homes). Hook sleep; on wake read
  the location keywords:
  - `LocTypePlayerHouse` AND NOT (`LocTypeCity` or a major-city worldspace) ->
    rustic rest (hearth-druid). Works for vanilla + any mod home that inherits
    the standard template; a city townhouse (Breezehome, a mod home inside a
    city) correctly does not qualify.
  - `LocTypeInn` -> nothing (rented bed).
  - Exterior wilderness, no habitation keyword -> outdoor rest (ranger).
  - `PDV_FLST_GreenWay_RusticHomes` (Hearthfire homesteads Lakeview/Windstad/
    Heljarchen, extensible) is a FALLBACK whitelist / guaranteed-hit only, not
    the primary gate. A badly-tagged mod home simply misses the hearth bonus and
    still earns Green Way via forage/alchemy/ranger paths (graceful degrade).
  - Verify `LocTypePlayerHouse`/`LocTypeInn`/`LocTypeCity` FormKeys via houseCARL
    at build.
- Mechanism B - garden tending is self-gating: only homesteads have planters, so
  harvesting a planter self-identifies the hearth-druid. No ownership check.

### 2D. Magnitude tuning (owner: feed BOTH piety and DruidicStanding)

`HandleBretonGreenWayStanding` currently dumps +25 DruidicStanding per signal
([17995]) - that pegs the track in ~2 acts and makes neglect-decay meaningless.
Refactor so the DruidicStanding delta is per-source:
- Renewable signals (forage/hunt/sleep/tend/alchemy): small maintenance bump
  (+2..+5) + small daily-capped Y'ffre piety pulse. Offsets
  `DecayBretonDruidicStandingAtDawn` so "kept by living the life, frays if you
  go soft in cities."
- Pilgrimage per-site: +5 DruidicStanding + Y'ffre piety.
- Pilgrimage capstone: +15..+20 one-time + milestone Y'ffre piety + BoD beat.
- Keep the `IsBretonGreenWayForkEligible()` gate (Betrayed fork earns nothing).
- Implementation decision to confirm at build: gate Green Way behavioral/
  pilgrimage signals on `tradition == GreenWay` so a Knight's Road Breton doesn't
  silently bank unpaid Y'ffre piety (tradition-filter consistency), OR accept
  cross-tradition piety as harmless-but-unpaid. Recommend the former.

---

## Part 3 - Y'ffre dislikes (softer Breton set)

File: `references/authoring/PDV_DeityLikesDislikes.csv`. Add `breton`-tagged
rows copied from the existing Bosmer Y'ffre rows. Softer set (owner-confirmed):

Dislikes to add (breton):
- `365 raise-undead -,medium` (necromancy defiles the cycle).
- `364 assault-innocent -,small` (breaks the Pact's harmony).
- `331 enchant-item -,small` - ALREADY present as a breton row; keep.
- DO NOT add `330 smith-item` (dropped - a Breton druid may be a smith).
- DO NOT copy the strict Green Pact FOOD taboo (Bosmer Old Contract only,
  hard-gated at [6139]; softer-analog lock).

Likes to add (breton), rounding out the loop:
- `300 kill-undead +,small`, `333 cook-meal +,small` (pairs with hunt -
  "waste no kill"), `350 heal-or-cure-npc +,small`.
- New hunt like: any wild-game kill `+,small`, broad `ActorTypeAnimal` filter
  (owner: any wild game; tighten to a predator/prey keyword later if livestock
  noise shows up).
- `313 rest-under-open-sky` and `334 harvest-ingredient` already present.

Already firing via quest-reaction (no work): Nettlebane defiling the Eldergleam
(T03 s100), Black Star corruption (DA01), Soul Cairn trafficking (DLC1VQ04/05).

CSV edits are INERT until `pdv_likesdislikes_gen` is regenerated and
`LIKES_DISLIKES_VERSION` is bumped (currently 15 -> 16). Fold into the build.

---

## Part 4 - Docs

- Realign `PDV_BretonRewardRecords.spec.json` prose to 10.3 / v3 12.5 (tradition
  IS the lane; generic Footing lane was spec-era drift, now removed).
- Decisions-log line in AGENTS.md (owner-gated) noting the reconciliation.
- Update `PDV_SignalFloorLedger.csv` Breton rows after the fills + readback.

---

## Verification and gating

1. houseCARL readback: six FormLists non-empty; new pilgrimage FormLists exist
   with verified FormKeys; `LIKES_DISLIKES_VERSION` bumped.
2. `pdv_compile` the manager + `pdv_verify --json` (FAIL=0) +
   `pdv_signal_floor_audit` (Green Way off UNDER-FLOOR) +
   `pdv_1_0_endstate_gate`.
3. ESP write is user-gated: Skyrim closed, houseCARL overlay handled, backup
   first (P2 source-fill is atomic manifest+ESP).
4. In-game smoke: forage/hunt/sleep pulse (daily cap holds); discover a nature
   site + a stone (piety + BoD, capstone at set completion); a Y'ffre dislike
   (necromancy) shows the loss surface; tradition breadth lights T1/T2 and a
   focused patron lights T3.

## Follow-up (already flagged as a background task)

Harden audits to FAIL on empty/shell FormLists referenced by live routing, and
on declared-but-unpopulated signal sources, swept across ALL races - this class
of gap (6/6 Breton lists empty) slipped every current gate.
