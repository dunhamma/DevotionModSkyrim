# Wired-vs-Stub Review Summary (all 10 races)

**Purpose.** This is a review-stage companion to the 10 player race guides. Each
guide now carries inline `[WIRED]/[QUEST]/[PARTIAL]/[STUB]/[INERT]` tags on every
gain/loss bullet plus a strippable `REVIEW SCAFFOLDING` block (per-god quest
tables + Review Notes). This file rolls up the **gaps** - the described acts that
do NOT fire organically in normal play - so the signal->deity remap can be
prioritized. It is not player copy; strip/ignore for release.

**How the buckets were assigned (proof boundary).** An act is only [WIRED] if a
live `On*` (PDV_PlayerEvents), `HandleStory*` (PDV_ActionRouter), CSV like/dislike
row (blank `originGate`), or quest-stage caller reaches a piety award. Design docs,
the PreBeta gate ledger, and QASmoke route-proof do NOT count as organic firing.
`[QUEST]` = fires only from a specific vanilla quest stage via the quest-reaction
matrix. `[PARTIAL]` = organic but narrowly gated (patron/mode/track state, rare
condition, or property-based call). `[STUB]` = only reachable via a dev-only
`PDV_EventSignalActivator`/`Effect` or the debug MCM. `[INERT]` = a CSV/matrix row
or a `SIGNAL_*` constant that exists but has no organic caller (incl. quest-matrix
"echo" rows whose citation says "REVIEW before promotion"). Headline STUB/INERT
claims below were re-confirmed directly against `live-source` callers.

---

## Systemic patterns (the story across all races)

1. **The curated "signature" path lanes are the weak point everywhere.** For most
   races, the acts the guide *leads with* - the fork-defining, flavorful deeds -
   are curated `SIGNAL_*` lanes wired ONLY to dev-only `PDV_EventSignalActivator`
   objects (all 51 manifest entries are `status:"dev-only"`) or to no caller at
   all. What actually earns piety in normal play is the generic **CSV
   likes/dislikes table** (kills, crafting, sleep, reading, theft, healing) plus a
   **handful of real hooks** (food equip, book reads, location visits, harvests,
   ancestor sleep) and **promoted quest-matrix rows**. The curated lanes are the
   prime remap target.

2. **"Native day-to-day" is the reliable spine.** Across every race the
   `PDV_DeityLikesDislikes.csv` rows fire organically (native-gated via
   `ScoreFromTable`/`IsRaceNativeForPlayer`). These are correct and carry the real
   moment-to-moment economy - but they are generic (kill/craft/sleep/read), which
   is exactly why the flavor lanes were added on top and then left unhooked.

3. **Neglect rarely means what the copy implies.** Neglect debuffs are gated by a
   days-since-last-*curated*-signal timer (Khajiit, Altmer, Orc, Imperial, Redguard,
   Breton), by curse posture only (Argonian, Dunmer), or by active-patron only
   (Nord). Because many curated sources are STUB, "return to the road / keep the
   sect / hold coherence" often cannot actually reset the timer through the acts
   the copy names.

4. **Copy inversions (guide says the opposite of the code).**
   - Argonian: guide says "ordinary swimming does not count" for Hist water, but
     `IsSwimming()` is the ONLY wired near-water trigger (no shore-rest hook).
   - Altmer: guide says "observe the dawn," but the dawn/coherence pulse fires
     from sacred **book reads**, not from time-of-day (the dawn route is dev-only).
   - Khajiit: neglect copy says "return to the road," but road-life is STUB - only
     lunar-book observance + curated theft/dragon/reversal beats reset neglect.
   - Dunmer: guide frames foreign Daedric-artifact use as deviation, but equipping
     a Daedric artifact is a *positive* CSV like for Boethiah/Mephala.

5. **Dead / never-called code behind advertised mechanics.**
   - Breton `KnightlyVowIntegrity` (the Knight's Road's central honor tension) is
     only ever SET to 100 and never lowered -> the whole mechanic is INERT.
   - Altmer `ResolveAltmerCrisis()` is defined but never called (no scored crisis
     resolution).
   - Nord `HandleNordAncestorSpine` is defined with no caller (dead code).
   - Dunmer `SIGNAL_SECRET_BETRAYED` / `HandleDunmerClumsyCrime`, `SIGNAL_HONORABLE_DUEL`
     (Boethiah 2002, Leki 2602/2002), `SIGNAL_WEB_WOVEN` - defined, no caller.
   - Orc `SIGNAL_BLOOD_KIN`, `SIGNAL_EXILE_RETURN`, `RouteOrcStrongholdForge`,
     `RouteOrcOathBreak` - no organic caller (activator/matrix only).
   - Redguard Leki `SIGNAL_HONORABLE_DUEL`, `SIGNAL_VAMPIRE_REENTRY` (flag set,
     never consumed).

6. **Quest matrix: promoted vs echo.** Hand-authored rows (real UESP citations,
   magnitude small/milestone) are promoted and fire via `ApplyQuestReaction` when
   the quest is on the watch list. "Echo" rows (aspect-equity, stepped down,
   citation "cross-gen candidate ... REVIEW before promotion") are NOT promoted =
   INERT, and they are numerous (e.g. Baan Dar ~20, Khajiit ~57 across gods).

**Global liveness caveats (apply to every WIRED tag):** CSV day-to-day rows are
live only if the generated `LoadRowsForDeity` table was regenerated and
`LIKES_DISLIKES_VERSION` bumped after the last CSV edit; quest-matrix rows are live
only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

---

## Per-race gap table (STUB / INERT / PARTIAL / copy issues)

Only gaps and notable caveats are listed; fully-wired acts live in each guide.
Buckets: S=STUB, I=INERT, P=PARTIAL, Q=QUEST-only, C=copy issue.

### Bosmer (4 paths: Old Contract / Living Story / Exchange / Bandit Road)

| God/Path | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Y'ffre (Old Contract) | proper hunting (clean kill) | S | activator 071035, dev-only; no clean-kill hook | eat-meat + green-song are the real Old-Contract earns |
| Y'ffre (Old Contract) | keeping the forest | S | activator 071036, dev-only | |
| Y'ffre (Living Story) | help a community preserve something | S | activator 071037, dev-only | NatureSite activator 071038 also unused |
| Z'en (Exchange) | settle a debt / proportionate vengeance / defend ally | S | activators 071039/07103A dev-only; defend-ally not in table | only honest craft/labor (CSV) earns for Z'en |
| Baan Dar (Bandit Road) | survive against the odds | S | activator 07103C dev-only | sleep/theft/discovery (CSV) are the real earns |
| Secondary Living Story gods (Arkay/Xarxes/Mara/Stendarr) | burial/ancestry/family/mercy | I | matrix echo rows, REVIEW | almost all inert |

Only 2 of the ~8 curated lanes got organic hooks: animal-food (PACT_POSITIVE) and green-song location.

### Khajiit (lunar lattice + 5 emergent focuses)

| God | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Khenarthi | travel on foot / cycle road-homes | S | HandleKhajiitRoadHome only from activator 071030/071031 + MCM | marquee road-life identity has no organic hook |
| Khenarthi | help/trade/protect caravans | S | SIGNAL_CARAVAN_AID (+1.5) no caller (harm side dev-only) | |
| Azurah | observe dawn/dusk | S | SIGNAL_THRESHOLD_RITE (+1.5) no time-of-day caller | moon observance reaches play only via books + 2 quest stages |
| all 5 | defend a threatened Khajiit | S | no hook in PlayerEvents/ActionRouter | absent entirely |
| all 5 | ~57 quest echo rows | I | matrix REVIEW rows | |
| (copy) | neglect "return to the road" | C | road-life STUB; only lunar-book/theft/dragon/reversal reset timer | |

Real earns: sleep-outdoors + CSV rows; combat/theft/dragon/reversal (PARTIAL organic via PlayerEvents); lunar-book moon observance (PARTIAL).

### Redguard (3 sects: Crown / Forebear / Ash'abah)

| God/Sect | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Tu'whacca | Far Shores token (marquee Unique Mechanic) | S | HandleRedguardFarShoresToken only via activator 07102E | high-visibility; no OnEquipped hook |
| Tu'whacca (Ash'abah) | complete a Hall of the Dead quest | S | RouteRedguardAshAbahDeathDuty only via activator 07102D | |
| Crown / Leki | tomb respect / honorable single combat | S | activator 07102B; Leki SIGNAL_HONORABLE_DUEL no caller | |
| Forebear | road on foot / honest contract | S | activator 07102C dev-only | |
| Crown/Forebear | In My Time of Need (MS08) | I | stage routes present but P2 source FormLists unfilled | fill MS08 stage sources |
| Tu'whacca | vampire-cure re-entry reward | I | SIGNAL_VAMPIRE_REENTRY flag set, never consumed | |
| Satakal/Ruptga/Tava/Onsi | background spine | I | no CSV/curated/matrix rows (by design) | "Tava blesses passage" has no mechanic |

Real earns: undead kills + named-undead kill event, ancestor-spine book (1 book), ancestral-rest sleep, CSV, dislikes; PARTIAL: draugr-tomb clear, necromancer, HoonDing make-way (patron-gated), Leki sword.

### Nord (Old Ways / Nine Divines, emergent offer)

| God | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Talos | defy the ban (hidden shrine / help worshipper / refuse to report) | S | HandleTalosShrineDefiance only via EventBus route (activator) + MCM | TOP-3 advertised deed, zero organic firing - prime target |
| Talos | report/comply (creed betrayal) | S | inverse lane, no organic trigger | |
| Kyne/Shor | honorable animal hunt (clean kill reward) | S | only beast interaction is a -0.5 penalty (kill-hostile-beast) | no clean-hunt gain |
| Mara/Stuhn | build hearth / defend hold (marriage/home/free prisoner/aid hold) | Q | no day-to-day like row; interior hearth-rest feeds Shor substrate | scope copy to quests or add likes |
| Hircine | werewolf hunt-rite gain | S | HandleHircineHuntRite dev-only/MCM (curse penalties DO fire) | |
| Kyne+ | neglect debuffs | P | all neglect spells gated to `_activeDeity == god` | broad worshipper feels nothing |
| Kyne/Talos | shout USE | P | property-based DELTA_SHOUT_ATTACK; CSV row 40 "NOT read" | other gods get nothing |
| Shor | HandleNordAncestorSpine | I | defined, no caller (dead code) | prune or wire |

### Argonian (3 layers: Hist / People / Void)

| Layer | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Hist | rest/reflect near water | P/C | TryArgonianNearWaterMaintenance gated `IsSwimming()` once/day | COPY INVERTED: guide says swimming does NOT count, but it's the only trigger; no shore-rest hook |
| Hist | swamps/wetlands | P | same IsSwimming gate; no location-type hook | entering a marsh cell earns nothing |
| People | help Assemblage / Riften Docks / protect Saxhleel | P | only P2 community reads + Derkeethus s200; no deity actor | People layer has no generic community hook - prime remap |
| Hist | quest matrix | I | T03 rows both echo | Hist earns from quests only via shared CSV |
| Hist | neglect debuff | P/C | applies only under SILENCED/CORRUPTED (curse) posture | uncursed lapse applies no spell; copy overstates |

Note: unlike Bosmer/Khajiit, Argonian's 4 dev-only activators (071023-071026) ARE backed by real organic routes (bed-of-choice sleep, sap-vision, near-water, Hist values). Void/Sithis is healthily wired (10 promoted DB matrix rows).

### Dunmer (ancestors + 1 Reclamation)

| God/Layer | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Ancestors | stand with your people / honorable victory | S/I | no solidarity hook; SIGNAL_HONORABLE_DUEL (2002) no caller | prime remap |
| Boethiah | trial/struggle/overthrow-authority | I | SIGNAL_RIGHTEOUS_STRUGGLE fires only via focus-emergence (books/DA02), not gameplay | no outnumbered-win detector |
| Mephala | keep a secret / weave a network | I | SIGNAL_SECRET_KEPT only via DA08 focus; SIGNAL_WEB_WOVEN no caller | no keep-secret detector |
| Mephala | clumsy-crime penalty | I | HandleDunmerClumsyCrime -> SIGNAL_SECRET_BETRAYED, no caller | wire or remove |
| Ancestors | ancestor distance (neglect) | C | neglect spell is curse-only | copy overstates as a "penalty" |
| Reclamations | foreign-Daedra deviation loss | P/C | narrow (DA01 Black Star + deviation books + post-deviation sleep) | generic artifact equip is a POSITIVE like, not deviation |

Best-wired native marquee: ash-prayer urn (`OnEquipped`) + home rite are genuinely organic; all 3 Reclamations' CSV day-to-day rows WIRED.

### Imperial (Nine Divines + Talos + Concordat)

| God | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Akatosh (civic) | public service / civic duty | Q | only ~8 hand-picked quest stages (MQ103 s190, CW02A s200, ...) | NO everyday-act caller; generic clearing/craft/heal never fires civic pulse |
| Mara/Stendarr/Zenithar/Arkay | mercy/lawful-order/honest-work/death-duty beats | Q | quest-stage-only (MS08/MS13/MS14 ...) | domain gods still earn day-to-day via CSV |
| Talos | activate hidden Talos shrine | S | HandleTalosShrineDefiance only activator + MCM | guide lead, not organic |
| Talos | day-to-day | P | FOREIGN stance x0.4, thin | |
| (Concordat) | Stormcloak/Legion/report/escort pressure | I | deltas defined (ManagerQuest:14340), no organic caller | awaiting quest hooks |

WIRED: all 8 non-Talos Divines day-to-day CSV; civic neglect timer; vampire civic-halt (0x at dawn).

### Altmer (mono coherence: Auri-El / Magnus / Xarxes)

| God/System | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Auri-El | observe the dawn (time-of-day) | P/C | RouteAltmerDawnSteadiness no-arg only dev-only; organic dawn only via books | copy implies sunrise; it's book-reads |
| foundation | hold coherent under pressure (orthodox cost) | S | RouteAltmerOrthodoxCostlyEnforcement no-arg only dev-only | no Thalmor-duty detector |
| Auri-El | extra Lorkhan tiers (Talos/marriage/homestead/Thu'um) | S | dev-only ROUTE_ALTMER_LORKHAN_PRESSURE (refs 07101F-071022) | prose overpromises |
| system | crisis "reassert" resolution | I | ResolveAltmerCrisis() never called | crisis is a label + discipline fade |
| system | ThalmorAlignment | P | track (not piety); orthodox-pole movers no organic caller | can only slide heterodox organically |

WIRED: sacred Auri-El/Magnus/Xarxes book reads (dawn/scholarship/lineage pulses), CSV, magic-skill milestones (Magnus), ancestor spine; QUEST: Lorkhan/crisis MQ104 s160 / MQ304 s200 / C03 s200.

### Breton (3 traditions: Knight's Road / Hidden Art / Green Way)

| God/Tradition | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Knight's Road | KnightlyVowIntegrity honor track (central tension) | I | only ever SET to 100, never lowered (grep-confirmed); creed-loss spells unreachable | biggest gap - degradation unbuilt |
| Green Way | visit a standing stone / walk a nature site | S | no location hook; only Eldergleam quest-stage s100 | prime remap |
| Green Way | read druidic lore | P | 1 PLACEHOLDER book (The Wispmother); pool barren | fill Green Way book pool |
| Hidden Art | complete a Daedric quest | Q | no Breton hook; shared Daedric system + matrix DA04 | no signature Hidden Art quest lane |
| Hidden Art | Daedric-shrine use / Vigilant-caught exposure | S | no wired exposure input beyond books/spells | unbuilt exposure sources |
| Green Way | werewolf Druidic Trial choice | P | auto-flips to WEREWOLF (no menu); BETRAYED branch never set | choice scene unbuilt |

WIRED: Hidden Art forbidden books (OnBookRead) + spells (OnSpellLearned) + exposure, Green Way curated harvests (Spriggan/Nirnroot), Knight's Road vow lane (2 quests), CSV, Magnus ancestor spine. Breton has 0 dev-only activators.

### Orc (mono Malacath x 3 life-modes)

| Life-mode | Described act | Bucket | Evidence | Owner note |
|---|---|---|---|---|
| Stronghold | quality forge at the hold (curated) | S | RouteOrcStrongholdForge only via activator 071027 + effect | generic smithing (CSV) is the real forge earn |
| Stronghold | Blood-Kin belonging (T3 communal proof) | Q/I | DA06 s200 flips mode; SIGNAL_BLOOD_KIN no caller (piety via matrix milestone) | wire SIGNAL_BLOOD_KIN if T3 should score |
| City | dignity under pressure | Q/S | thane s200 route; else dev-only 071028 | no ambient "answer contempt" hook |
| City | self-made community / hearth | Q/S | city-home s10; SIGNAL_EXILE_RETURN (+3.0) has no caller | |
| Legion/Exile | completed service / endurance | Q/S | CW02A s200 + CW finale s500; else dev-only 071029 | endurance not wired |
| all | oath-break loss (self-erasure) | S | RouteOrcOathBreak dev-only only | absent entirely |

WIRED: generic smithing (CSV via HandleStoryCraftItem), kills, rest/inn, dislikes, four-holds location visit + ancestor spine, book-based broad conduct (PARTIAL), DA06 matrix milestone, neglect timer. Mode x1.00/0.75/0.60 lives in reward calendars, not per-act.

---

## Biggest remap targets (prioritized)

1. **Curated fork "signature" lanes with dev-only-only or no callers** - the single
   largest bucket. Bind these to real events for the race's origin:
   - Bosmer Old-Contract hunt/forest, Living-Story community, Exchange debt/vengeance, Bandit-Road reversal (6 activators 071035-07103C).
   - Redguard Far Shores token, Hall-of-Dead death-duty, Crown tomb/duel, Forebear road/contract (07102B-07102E).
   - Khajiit road-home/travel, caravan-aid, threshold-rite (071030/071031 + no-caller SIGNALs).
   - Orc stronghold-forge, exile-return, oath-break (071027/071029 + no-caller SIGNALs).
   - Nord Talos-ban defiance + Hircine hunt-rite (a top-3 Nord deed).
   - Dunmer honorable-duel / web-woven / secret-kept gameplay signals.
   - Altmer orthodox-costly-enforcement + extra Lorkhan tiers (07101F-071022).
2. **Advertised mechanics that are dead code** - Breton KnightlyVowIntegrity
   degradation, Altmer ResolveAltmerCrisis, Nord HandleNordAncestorSpine,
   Dunmer/Redguard/Orc no-caller SIGNAL_* constants.
3. **"Community / people / caravan" layers with no generic hook** - Argonian People,
   Khajiit caravans, Dunmer solidarity, Nord hold/hearth (all quest-or-nothing).
4. **Copy inversions** (cheap fixes, either reword or add the obvious hook) -
   Argonian swimming, Altmer dawn, Khajiit road-return, Dunmer artifact-as-deviation.
5. **Concordat pressure deltas (Imperial) defined but unhooked** - INERT until quest
   hooks land.
6. **Neglect gating** - decide whether neglect should key off curated timers /
   active-patron / curse only (current) or off the broadly-lived acts the copy
   names; today many neglect promises can't be satisfied through STUB acts.

## What IS reliably wired (so it is not re-touched)

Across all races: the CSV likes/dislikes economy (kills, smithing/enchant/cook/brew,
sleep open-sky/inn, read skill/lore/spell books, learn word-of-power, heal/cure,
theft/lockpick/trespass, harvest, discover-location, raise-undead/murder/assault
dislikes), native-gated. Plus real hooks: Bosmer food + green-song; Argonian
bed-of-choice + sap + near-water; Dunmer ash-urn + home rite; Altmer/Breton/Redguard/
Orc/Dunmer/Nord ancestor-spine sleep; Altmer + Breton + Dunmer + Imperial + Orc book
routes; Orc four-holds + Nord/Orc location handlers; and promoted quest-matrix rows
per god.
