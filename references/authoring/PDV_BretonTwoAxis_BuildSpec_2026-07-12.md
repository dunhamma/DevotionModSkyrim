# Breton Two-Axis Split: Tradition Practice vs Patron Championing - Build Spec (2026-07-12)

**Status:** Implemented 2026-07-12; source/record/readback/static gates are ready
for in-game smoke. Supersedes the pool-as-T3-gate decision in
`PDV_BretonTraditionReconciliation_BuildSpec_2026-07-11.md` Part 1. The two-axis
model below is now the live build authority. Green Way pilgrimage/rustic-home
enrichment from the 07-11 spec remains future enrichment, not a blocker for the
two-axis smoke cards, because the current Green Way lane has GREEN wired source
coverage in the regenerated signal-floor ledger.

**Owner decision record (2026-07-12 session):** the 07-11 lock treated the tradition
pool as the exclusive gate on which patron can reach T3. Owner states that lock was in
error - the intended model was always two orthogonal axes. Lore review (Varieties of
Faith: The Bretons; Druids of Galen; Wyrd Covens) confirms: pantheon worship and
cultural tradition coexist in the same Breton ("many islanders profess devotion to the
Eight Divines but harbor a deep respect for Y'ffre and druidic culture").

**Implementation closeout (updated 2026-07-13):** `PDV__ManagerQuest.psc` now tiers Breton
traditions from `KnightlyVowCount`, `HiddenArtCount`, and `GreenWayCount`
as practice-point stores (thresholds 25/50; four points maximum per day), retires
the pool-piety helpers, and grants T3 only when the
active Champion patron is resonant with the active tradition. A non-resonant
Champion patron grants `PDV_Bless_Breton_PatronChampion` beside the practiced
tradition. `PDV_EventBus.psc` and `PDV_ActionRouter.psc` forward likes/dislikes
event IDs into the practice layer; quest-reaction tags feed the same layer after
the actual piety/stigma path lands. `PDV_Msg_Breton_Talos_Offer` is now authored
and wired, so Breton formal offers include Talos.

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

## 2. Tradition tier = practice points

Replace the pooled-piety tier read in `GetBretonTraditionTier` / retire
`GetBretonTraditionPietyPoolTier` + `GetBretonTraditionPoolPiety`
([PDV__ManagerQuest.psc:13258-13289]).

- T1/T2 use the existing stores (`PDV.Breton.KnightlyVowCount`,
  `HiddenArtCount`, `GreenWayCount`) as weighted practice points: 25 -> T1 and
  50 -> T2. Renewable actions grant 1 point; curated quest/tag and dedicated
  tradition signals grant 2. A hard aggregate cap of 4 points per in-game day
  applies across all source types, in addition to each source's once-per-day
  guard. Seeker is therefore impossible before day 7 and should normally land
  around days 9-10 under varied ordinary play, comparable to deity piety pacing.
- T3 requires: active patron in the tradition's resonance set AND that patron at
  Champion (85). Non-resonant Champion routes to the PatronChampion boon instead.
- Pressure tracks unchanged in role (gate/modify/rupture, never a second boon).
- Retune ALL THREE practice-pulse magnitudes: +25 pegs a 0-100 track in ~2 acts.
  Extend build-spec-07-11 Part 2D's per-source scaling (renewable +2..+5, curated
  source +5, milestone +15..20) from DruidicStanding to WitchcraftExposure and to the
  new count ticks. Exposure keeps its -1/dawn fade; vow keeps reset-to-100 semantics.

## 3. Dual-feed signal wiring (final state per lane)

Principle: a signal in a lane's set awards practice points ONLY when that
tradition is active (off-tradition -> CrossTraditionPressure path, existing), but
pays deity piety ALWAYS (deity axis is never tradition-gated). Existing curated
awards currently gated on tradition (Stendarr MERCY at [18072], Magnus
DISCIPLINED_STUDY at [18097], Mara MERCY at [18102]) are ungated on the piety side.

### Knight's Road (KnightlyVowCount / KnightlyVowIntegrity)
- P2: `PDV_FLST_P2_BretonVowSources`, `BretonKnightsRoadSources` - wired + ESP-
  populated but thin (VowSources = 2). Future enrichment can broaden this, but the
  current smoke contract has GREEN source coverage.
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
  and 2C (renewable forage/alchemy/tend + rustic-rest keyword split) remain future
  enrichment. The current Green Way smoke contract uses the existing GREEN P2/event
  source coverage.
- Quest tags: `honor_the_wild`, `the_hunt` (+); `defile_nature`, `necromancy` (-).
- Curated: Y'ffre SIGNAL_LIVING_STORY (live).

### Hidden Art (HiddenArtCount / WitchcraftExposure)
- P2: `BretonHiddenArtSources` (3 occult books live), `BretonHiddenArtSpells` -
  populated for smoke; future curation can broaden the spell whitelist.
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
4. DONE: dual-feed hooks route event-ID practice ticks through the likes/dislikes
   path and quest-tag practice ticks after `ApplyDeityReaction`. No CSV rows changed
   in this two-axis tranche, so `LIKES_DISLIKES_VERSION` remains 16.
5. Fix Julianos sleep-handler miswire.
6. DONE for smoke scope: 07-11 Part 2A/fill residual reconciled by readback; the
   current regenerated signal-floor ledger reports Breton Knight's Road, Hidden
   Art, and Green Way as PASS with GREEN P2 source evidence. `HiddenArtSpells`,
   `VowSources`, `KnightsRoadSources`, and `GreenWaySources` are populated.
   07-11 Parts 2B/2C (new Green Way pilgrimage, rustic-home, garden-tending
   enrichment) remain future enrichment because they require new record/hook
   design beyond the two-axis smoke contract.
7. NOT DONE in this tranche: the `CIVIC_SERVICE` constants are still tied to the
   active Imperial civic-service lane in current source. Do not remove them from
   a Breton smoke-readiness pass without a separate reserved-signal cleanup.
8. DONE: regenerated deployed quest-matrix JSON, including the ARR channel. The
   Anvil optional ARR runtime JSON was stale and has been rewritten with the
   current PapyrusUtil lowercase aliases; the ARR compatibility mod JSON also
   validates against `PDV_QuestReactionMatrix_ARR.csv`.

## 6. Verify items

- Confirm active-patron focus machinery does NOT rate-suppress other-deity piety
  earns (else practice signals underpay non-patron resonant gods).
- Spec vs manifest drift: manifest showed no sourceFillEntries for 5 Breton lists
  while the 07-11 ESP readback verified all populated - reconcile which artifact is
  authoritative before fill passes (pdv_p2_formlist_esp_audit is ESP-aware).
- Gates: pdv_compile + pdv_verify --json FAIL=0 + pdv_signal_floor_audit +
  pdv_prisma_ui_audit + phase-2 reward readback + formal-offer readback +
  adversary check; felt-ledger family updates for retired pool lane vs new
  PatronChampion family.
- In-game smoke: (a) Green Way Breton + Magnus patron reaches Magnus Champion ->
  PatronChampion boon + GW stays T2; (b) same save, switch-test resonant Y'ffre ->
  GW T3 family; (c) practice T1/T2 lights from counts with zero patron piety in
  pool gods; (d) vow damage from a 364 assault; (e) daily caps hold on counter
  ticks.

## 7. Machine proof from implementation closeout

- `PDV__ManagerQuest`, `PDV_EventBus`, `PDV_ActionRouter`, and `PDV_MCM` compile
  0 errors / 0 warnings.
- Breton reward readback PASS for `PDV_Bless_Breton_PatronChampion`; formal-offer
  readback PASS for `PDV_Msg_Breton_Talos_Offer`.
- `pdv_formal_offer_check.mjs --json`: PASS, `passCount=265`.
- `pdv_phase2_reward_readback_audit.mjs --json`: PASS, `PASS=1415`.
- `pdv_prisma_ui_audit.mjs`: PASS, 89 checks.
- `pdv_deity_signal_remap_adversary_check.mjs`: PASS; only known warning is thin
  gods remaining design work.
- `pdv_signal_floor_audit.mjs`: PASS, 51/51 paths, 0 UNDER-FLOOR.
- `pdv_verify.mjs --json`: FAIL=0; current residual WARN count is non-blocking
  profile/source hygiene, not Breton two-axis wiring.
- `pdv_felt_registry_gen.mjs --check --json`: registry/ledger are synchronized;
  new pending family is `Breton-PatronChampion|boon`.
