# Breton Two-Axis Split: Tradition Practice vs Patron Championing - Build Spec (2026-07-12)

**Status:** Owner-approved design, NOT built. Supersedes the pool-as-T3-gate decision
in `PDV_BretonTraditionReconciliation_BuildSpec_2026-07-11.md` Part 1. All other
anchors of that spec (no generic broad lane, tradition is a filter, softer Green Way,
ancestor-substrate retirement, Parts 2-4 work items) remain in force.

**Owner decision record (2026-07-12 session):** the 07-11 lock treated the tradition
pool as the exclusive gate on which patron can reach T3. Owner states that lock was in
error - the intended model was always two orthogonal axes. Lore review (Varieties of
Faith: The Bretons; Druids of Galen; Wyrd Covens) confirms: pantheon worship and
cultural tradition coexist in the same Breton ("many islanders profess devotion to the
Eight Divines but harbor a deep respect for Y'ffre and druidic culture").

---

## 1. Model

Two orthogonal axes:

- **Tradition** (Knight's Road / Hidden Art / Green Way) = way of life. A PRACTICE
  track with its own tier progress, pressure tracks (KnightlyVowIntegrity /
  WitchcraftExposure / DruidicStanding), and the T1/T2 reward families.
- **Patron** = personal devotion to any god in the 11-deity Breton roster (Kynareth,
  Talos, Mara, Akatosh, Arkay, Stendarr, Julianos, Dibella, Zenithar, Magnus, Y'ffre)
  or a Daedric prince via 20C. Piety/tier machinery, unchanged.

A Green Way Breton may champion Magnus. A Knight's Road Breton may champion Dibella.
Tradition never restricts WHO you can serve; it shapes HOW you live.

### Reward semantics

- **Resonant patron** (active patron is in the tradition's resonance set, section 4):
  tradition family's T3 IS the champion payoff - full tradition-flavored T3 spell +
  Champion Survey recognition + "X names you Champion through the <lane>"
  presentation. NO second stacked deity boon (respects the <=2 always-on ceiling; the
  T3 family was budgeted as the champion boon).
- **Non-resonant patron** (roster god outside the resonance set, e.g. Zenithar):
  tradition family stays at its breadth cap (T2, practice keeps paying) + the deity's
  Champion tier grants ONE new modest generic boon record `PDV_Bless_Breton_
  PatronChampion` (single spell, below every tradition T3 in budget; race-agnostic
  design deferred - Breton-only record for now) + Champion Survey/BoD/tier
  presentation. T2 + modest champion boon = exactly 2 always-on, at ceiling.
- Tradition T1/T2 = practice-count thresholds (section 2), NOT pooled deity piety.
  `GetBretonTraditionPoolPiety` retires with the split.

## 2. Tradition tier = practice counts

Replace the pooled-piety tier read in `GetBretonTraditionTier` / retire
`GetBretonTraditionPietyPoolTier` + `GetBretonTraditionPoolPiety`
([PDV__ManagerQuest.psc:13258-13289]).

- T1/T2 from service-count thresholds on the EXISTING counters
  (`PDV.Breton.KnightlyVowCount`, `HiddenArtCount`, `GreenWayCount`), following the
  established broad-lane pattern (>=3 -> T1, >=6 -> T2; tune at build). Counter ticks
  must be daily-capped/anti-farm like every piety pulse.
- T3 requires: active patron in the tradition's resonance set AND that patron at
  Champion (85). Non-resonant Champion routes to the PatronChampion boon instead.
- Pressure tracks unchanged in role (gate/modify/rupture, never a second boon).
- Retune ALL THREE practice-pulse magnitudes: +25 pegs a 0-100 track in ~2 acts.
  Extend build-spec-07-11 Part 2D's per-source scaling (renewable +2..+5, curated
  source +5, milestone +15..20) from DruidicStanding to WitchcraftExposure and to the
  new count ticks. Exposure keeps its -1/dawn fade; vow keeps reset-to-100 semantics.

## 3. Dual-feed signal wiring (final state per lane)

Principle: a signal in a lane's set ticks the practice counter ONLY when that
tradition is active (off-tradition -> CrossTraditionPressure path, existing), but
pays deity piety ALWAYS (deity axis is never tradition-gated). Existing curated
awards currently gated on tradition (Stendarr MERCY at [18072], Magnus
DISCIPLINED_STUDY at [18097], Mara MERCY at [18102]) are ungated on the piety side.

### Knight's Road (KnightlyVowCount / KnightlyVowIntegrity)
- P2: `PDV_FLST_P2_BretonVowSources`, `BretonKnightsRoadSources` - wired + ESP-
  populated but thin (VowSources = 2). Fill pass required.
- Event-IDs gaining a practice tick (piety rows already authored in
  `PDV_DeityLikesDislikes.csv`): 351 clear-bounty, 350 heal-or-cure-npc, 300
  kill-undead, 301 kill-daedra. Vow-integrity DAMAGE from 304 murder-defenseless,
  364 assault-innocent, 362 steal-item, 366 feed-as-vampire.
- Quest-matrix act-tags ticking practice: `mercy_spare`, `protect_the_weak`,
  `uphold_law_justice`, `keep_oath` (+); `kill_the_helpless`, `murder_treacherous`
  (integrity damage). Tag-level hook in ApplyDeityReaction (new).
- Curated: Stendarr SIGNAL_MERCY (live).

### Green Way (GreenWayCount / DruidicStanding)
- P2: `BretonGreenWaySources`, `BretonGreenWayHarvests` (4 flora) - populated, thin.
- Event-IDs (breton CSV rows L322-330 already authored): 313 rest-under-open-sky,
  334 harvest-ingredient, 303 hunt-wild-game, 333 cook-meal, 300 kill-undead (+);
  365 raise-undead, 331 enchant-item, 364 assault-innocent (standing damage).
- 07-11 Parts 2B (pilgrimage: nature-site spine + 13-stone ring, discovery-based)
  and 2C (renewable forage/alchemy/tend + rustic-rest keyword split) are PROMOTED
  from deferred to REQUIRED: they are this lane's primary tier feed.
- Quest tags: `honor_the_wild`, `the_hunt` (+); `defile_nature`, `necromancy` (-).
- Curated: Y'ffre SIGNAL_LIVING_STORY (live).

### Hidden Art (HiddenArtCount / WitchcraftExposure)
- P2: `BretonHiddenArtSources` (3 occult books live), `BretonHiddenArtSpells` -
  spell whitelist still needs curation (07-11 Part 2A residual).
- Event-IDs (breton rows L315-321): 341 read-spell-tome, 342 read-lore-book, 331
  enchant-item (occult study); 333 cook-meal / 314 sleep-in-bed as hearth-COVER
  (Mara).
- Quest tags: `forbidden_knowledge` (+); Daedric-prince chains via 20C;
  `reckless_magic` (-).
- Curated: Magnus SIGNAL_DISCIPLINED_STUDY, Mara SIGNAL_MERCY(home) (live);
  build reserved Magnus SIGNAL_ARCANE_RECOVERY with the spell-list fill.
- FIX: `HandleBretonSleepEvents` [4968] awards Julianos SIGNAL_LAWFUL_ORDER gated on
  Hidden Art - miswired. Hearth-cover sleep belongs to Mara; move Julianos to study
  signals (341/342 path) or drop from the sleep handler.

## 4. Resonance sets (owner-locked 2026-07-12)

Overlap is allowed by design; a deity may be resonant in several lanes. Resonance
set membership = eligible to source that tradition's T3.

| Deity | Knight's Road | Green Way | Hidden Art | Basis |
|---|---|---|---|---|
| Stendarr | CORE | - | - | mercy/justice/smite; largest reactor (56 matrix rows) |
| Mara | CORE | OVERLAP | OVERLAP | mercy/protect; hearth-goddess -> hearth-druid (2C); her breton hearth rows ARE the cover mechanic |
| Arkay | CORE | - | - | death duty, breton kill-undead row, anti-necromancy |
| Akatosh | CORE | - | - | oath/order/covenant, breton clear-bounty row |
| Julianos | CORE | - | OVERLAP | law/justice + forbidden_knowledge positive |
| Talos | CORE | - | - | protection + honorable war (41 rows); un-strands him |
| Kynareth | OVERLAP | CORE-ADJACENT | - | half mercy/protect, half honor_the_wild/rest/harvest; CSV comment "Divine contributor, not Green Way owner" stands - Y'ffre remains the lane's presentation owner |
| Y'ffre | - | CORE | - | unchanged |
| Magnus | - | - | RESONANT (practice) | his signals are the HA practice feed; per lore he is mainstream sorcery, so he is ALSO fully championable from any tradition |
| Dibella | - | OVERLAP | OVERLAP | owner 07-12: Dibellan mysteries read occult; beauty-in-nature fits the Green. NOT Knight's Road |
| Zenithar | - | - | - | deliberately unlaned; the clean PatronChampion test case |
| Daedric via 20C | - | - | CORE (focused) | unchanged |

Sheor: no worship (lore). Phynaster: stays parked as non-selectable flavor.

## 5. Build order

1. Manager: practice-tier functions + resonance-set membership function
   (name-based, not FormList-index) + T3 gate rework + PatronChampion grant path
   in SyncBretonRewards. Ungate curated piety awards; keep practice ticks
   tradition-gated.
2. New record: `PDV_Bless_Breton_PatronChampion` (spec entry in
   PDV_BretonRewardRecords.spec.json; author via pdv-phase20-race-author;
   Requiem-proof rules apply - flat Restore-Health, no regen).
3. Pulse retune (all three tracks) + counter anti-farm caps.
4. Dual-feed hooks: event-ID practice ticks (likes/dislikes path) + quest-tag
   practice ticks (ApplyDeityReaction). CSV edits inert until pdv_likesdislikes_gen
   regen + LIKES_DISLIDES_VERSION bump (16 -> 17) - prove on a new save.
5. Fix Julianos sleep-handler miswire.
6. 07-11 Parts 2B/2C (now required) + HiddenArtSpells fill + VowSources/
   KnightsRoadSources/GreenWaySources fill passes.
7. Remove the 6 vestigial roster CIVIC_SERVICE reserved constants (per
   pdv_reserved_signals.json REMOVE recommendations) in the same sweep.
8. Regen the deployed ARR quest-matrix JSON (predates 07-11 tranche10 Y'ffre rows).

## 6. Verify items

- Confirm active-patron focus machinery does NOT rate-suppress other-deity piety
  earns (else practice signals underpay non-patron resonant gods).
- Spec vs manifest drift: manifest showed no sourceFillEntries for 5 Breton lists
  while the 07-11 ESP readback verified all populated - reconcile which artifact is
  authoritative before fill passes (pdv_p2_formlist_esp_audit is ESP-aware).
- Gates: pdv_compile + pdv_verify --json FAIL=0 + pdv_signal_floor_audit +
  pdv_1_0_endstate_gate; felt-ledger family updates for retired pool lane vs new
  PatronChampion family.
- In-game smoke: (a) Green Way Breton + Magnus patron reaches Magnus Champion ->
  PatronChampion boon + GW stays T2; (b) same save, switch-test resonant Y'ffre ->
  GW T3 family; (c) practice T1/T2 lights from counts with zero patron piety in
  pool gods; (d) vow damage from a 364 assault; (e) daily caps hold on counter
  ticks.
