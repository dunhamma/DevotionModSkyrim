# PDV Session Handoff — Lore-Grounded Deity Signal Remap (10 races)

**Date:** 2026-07-08
**Status:** DESIGN COMPLETE for all 10 races. Daedric Prince track NOT started.
**Nature:** Design/planning artifact. NO code, records, CSVs, or .psc were
changed this session — everything below is a target spec to implement + reconcile.
**Source of truth for the raw session log:** the plan file
`~/.claude/plans/no-i-want-you-wise-mountain.md` (outside the repo; this handoff
embeds its durable content so the design survives).

---

## 0. Why this exists

The current action->deity mapping is generic/"lazy": ~29 shared eventIds
(smith, cook, read-lore, kill-undead...) reused across ~31 gods in
`references/authoring/PDV_DeityLikesDislikes.csv`, plus some advertised signals
that never fire (e.g. Bosmer "proper hunt"/"forest kept" route only from
`PDV_EventSignalActivator` refs that `PDV_FinalPlacementManifest.json` marks
`dev-only` / never placed). We designed a bespoke, lore-grounded gain/loss set
per god/lane for every race. This handoff is the design + the NEXT-SESSION
cross-check job.

---

## 1. Standing decisions (apply to every race + the Daedric track)

- **D1 - Bespoke-first, MEDIUM density.** Each god gets a lore-rich distinctive
  set (~6-9 gains, ~4-6 losses). Generic acts kept only where truly on-theme.
- **D2 - Confirm roster per race.** Ship the existing roster by default but flag
  lore-supported excluded gods for a yes/no before designing.
- **D3 - Regular-play signal rule.** CORE signals must fire in normal Skyrim play
  (combat, shrine prayer, quest completion, exploration, relevant magic, brawls).
  Survival-Mode / niche behaviors (deliberate camping, hunting, weather) are
  BONUS only, never the floor. High overlap between kindred gods is fine.
- **D4 - Offer/cross-lane mechanism = PER-ARCHITECTURE, never universal.** A
  blanket "enough other-lane signals -> offer" rule would collapse distinct
  races into one worship-everything system. Each race declares its own rule
  (see per-race sections). Push back hard where an auto-offer blurs distinctness.
- **D5 - Cross-race deity reuse.** Same god = same signal set wherever it appears
  (Baan Dar Bosmer<->Khajiit; Azura/Azurah Dunmer<->Khajiit; Z'en, Kynareth,
  Syrabane Breton<->Altmer, the 8 civic Divines Nord/Imperial/Breton...). Race
  changes FRAMING/stance/emphasis, not signals. High overlap / complete likeness
  is fine and expected. Quest-matrix rows reuse the existing act-tag vocabulary.

---

## 2. Per-race locked design (the target signal sets)

Notation: **G** = gains, **L** = losses. "SIG" = the signature signal.

### 2.1 Bosmer (4 lanes, one Y'ffre ledger backs two)
- **Old Contract (Y'ffre strict/PactBound):** the law - GPC compliance meter,
  carnivore code (meat yes / plants+wood no, bows EXEMPT), the ritual hunt,
  defend the Green, forced reckoning.
- **Living Story (Y'ffre moderate):** the Spinner's diaspora path - tell/hear/
  preserve a story, help preserve/protect/remember (community/tradition/life),
  nature sites, heal, keep faith. NO food policing, NO GPC. L: false story/deceit
  (corrupt the tale), betray a community, let something meaningful be lost.
- **Y'ffre (shared) G:** the hunt (stalked first-arrow kill); eat meat/eat-what-
  you-kill; rest under open sky; nature sites (renewable); heal/mend; tell/hear a
  story; beast-tongue (calm/command an animal); keep a hard oath; defend the Green.
  **L:** eat plant food/potions (OC); break an oath; wanton slaughter of a tame/
  sacred animal; raise undead/necromancy; wood taboo (OC, bows exempt); desecrate
  a grove/nature site (SIG - Nettlebane on the Eldergleam); serve a Daedric Prince;
  flora harvest & brewing (OC); false story/deceit; enchant-item (soul-binding);
  assault-innocent. DROP smith-item. Lore virtue = OATH-KEEPING (not "courage").
- **Z'en (Exchange):** the ledger. Emphasis everyday-weighted + carried through
  quests. G: complete a paid contract; pay/settle a bounty; cook from harvest;
  heal (a debt of care); Reciprocity cycle (produce+trade); return property;
  proportionate justice (redress a wrong / restore a livelihood); honor an oath
  under pressure. L: steal; pick owned lock; assault/murder innocent; extortion;
  sabotage a livelihood (irredeemable debt); frame/harm the uninvolved.
  DEFERRED: disproportionate overkill. Steps down 1 from Zenithar on labor.
- **Baan Dar (Bandit Road):** the reversal + solidarity with the powerless; ONE
  unforgivable = betray an outcast. G: sleep rough; road-travel on foot; rob/
  outsmart the powerful (NOT commoners); survive against the odds; stand with
  outcasts (free a captive, aid a beggar/refugee); outwit a powerful foe. L:
  betray an outcast (~-2.0); serve entrenched power; prey on the powerless.
  Neglect anchor: settle into comfort ~14 days. DO NOT double-count the existing
  low-health gap / weekly Luck / outnumbered-pulse EFFECTS as piety.
- **D4 offers:** cross-lane deeds build EVIDENCE toward a COSTED, confirmed
  path-SWITCH (Living Story = 1 act; Exchange/Bandit Road = 2 deeds/week; Old
  Contract = recommit + 3 days; switching costs standing). NEVER a second patron.
  Old Contract (PactBound) never offers while bound (only exit = forced reckoning).

### 2.2 Nord (Old Ways 7 + Nine Divines 8 + Talos; blended within chosen baseline)
- **Old Ways:** Kyne (SIG learn a Word/the Voice; + fair hunt, rest under sky);
  Shor (SIG reach Sovngarde/defeat Alduin; valor, honor the dead); Tsun (SIG
  survive a fight at severe disadvantage; shield-brother); Stuhn (SIG spare a
  beaten foe/free a prisoner; ransom, fair spoils); Mara-as-Handmaiden; Talos/
  Ysmir; **Orkey** (REPLACES Arkay for Old-Ways baseline).
- **Orkey (LOCKED):** standard tiers + grim propitiation flavor (NOT inverted
  meter). Reuses Arkay's death-signal detection (burial rites, lay undead to
  rest, anti-necromancy) reframed as appeasing the Old Knocker, + distinctive
  G: refuse an immortality bargain, cure undeath after taking it (SIG),
  facilitate Sovngarde passage. L: embrace undeath (vampirism/lichdom, heaviest),
  necromancy, hubris of immortality.
- **Nine Divines signatures:** Akatosh = OATH & COVENANT (keeping oaths /
  quest-completion-as-kept-oath, capped); Kynareth = sleep under sky (see rebuild);
  Mara = marriage/family/compassion; Dibella = exceptional craft + Temple/Bards
  quests + aid lovers; Julianos = study a spell tome; Arkay = death-rites/cycle;
  Stendarr = spare the surrendering/anti-Daedra; Zenithar = honest fair sale.
- **Regular-play rebuild (D3):** Kyne/Kynareth cores anchor on wild-creature
  kills (capped), shrine prayer, shouts (Kyne)/exploration (Kynareth) + a SMALL
  honorable-combat echo; survival acts (sleep-out/hunt/weather) = bonuses only.
  Stuhn density = brawls, keep-a-follower-alive, let-a-fleeing-foe-go, settle-a-
  bounty-by-payment. Akatosh density = quest-completion = kept oath (capped) +
  shrine + study. Distinctive losses added: Kynareth (desecrate grove/tree/fire/
  slaughter), Dibella (deface art/cruelty/vandalism), Julianos (destroy books/
  reckless magic/break law).
- **Mercy triad:** three distinct lanes - Stuhn martial-mercy / Stendarr
  justice-mercy / Mara compassion (primary on own lane, step-down echo).
- **Honorable-combat overlap:** BROAD step-down (Shor full + Tsun/Kyne/Talos
  small echo) PLUS a context bonus (near-death->Tsun, with-a-shout->Kyne,
  vs-Thalmor->Talos).
- **Talos:** everyday martial (Voice, honorable battle, dragon-slaying/Ysmir) +
  SIGNATURE defiance (hidden-shrine worship, protect a worshipper, Diplomatic
  Immunity, Stormcloak oath/war beats, kill a Thalmor Justiciar). L: submit/
  betray a worshipper, publicly renounce, desecrate a shrine, side with Thalmor.
  Nord = proud/heavy; Imperial = Concordat-gated.
- **D4 offers:** broad -> primary PATRON OFFERS within the chosen baseline
  (multiple possible; decline=cooldown; commit=70% carry). Old Ways vs Nine
  Divines broad worship deliberately share one deed surface - distinctness lands
  at the PATRON level (ACCEPTED, not differentiated at broad).

### 2.3 Imperial (civic axis + Talos-Concordat + 8 Divines reused)
- **Civic-duty axis (its own SECULAR track):** serve the Legion (oath/rank/field
  ops); uphold Imperial law (bring criminals to justice, settle a bounty, aid the
  guard); hold civic office (Thane/aid a Jarl); defend the realm's order; honor
  the Emperor/crown as head-of-state. L: treason/aid-the-Thalmor/regicide;
  lawlessness (serious crime/resist arrest/escape justice); sedition = join the
  rebellion (civic LOSS + Talos GAIN - the bind). SPLIT: burial->Arkay, prayer->
  Divines, SACRED covenant (Dragonfire/Amulet)->Akatosh. REWARDS = standing &
  privileges (v2 investigation) + small interim discipline/order buffs.
- **Talos = ConcordatStanding track:** -100..+100, five bands; offers GATED
  (blocked while publicly compliant unless a costly-defiance RUPTURE); standing
  modulates Talos piety (x1.5..x0.5). Imperial Talos = private/guilty conscience.
- 8 Divines reused with civic reflavor (Arkay/Zenithar/Julianos/Stendarr lean
  institutional; Kynareth/Dibella lighter). Re-audit: the 8 signals are identical
  to Nord's; distinctness lives in the WRAPPER (ACCEPTED, gods not re-forked).
- **Signature bind:** civic axis vs Talos via ConcordatStanding; Civil War =
  Legion (civic+/compliance) vs Stormcloak (civic-/Talos+/defiance).
- **D4 offers:** broad Nine Divines -> primary offers (like Nord); civic axis is
  its own parallel track; Talos Concordat-gated.

### 2.4 Orc (Malacath, 3 life-modes; Trinimac deferred v2)
- No prayer/shrine floor - PURE DEED. G everyday: the FORGE (quality item, SIG
  "the forge is the Orc's prayer"); honorable combat vs worthy foes; harden a
  skill; endure hardship; slay daedra/dragons. Multipliers produce the mode
  calendars (~2/day Stronghold -> ~0.9/day Legion-Exile).
- **Mode signatures + WITNESS axis (re-audit sharpen):** Stronghold = the CLAN
  witnesses & confirms (Blood-Kin / "The Cursed Tribe" DA06); City = keep dignity
  before a HOSTILE audience; Legion-Exile = keep the Code with NO ONE watching
  (self-made far from home). This witness-axis stops the modes blurring.
- **Oath-keeping = broadest signature** (a contract IS an oath). **Oath-breaking
  = heaviest loss + lasting "oathbreaker" mark** worked off through deeds.
- **Jealousy = relying on softness is a loss** (begging/charity/the-easy-path;
  not a hard jealous lock - a City Orc can integrate). Other L: betray blood-kin/
  desert sworn service; theft; self-erasure (deny Orc identity, curated).
- Curse: werewolf conditionally TOLERATED if discipline shown; vampire =
  near-total collapse.
- **D4 offers: NONE.** One god - no patron offers; life-mode switch is DEED-GATED.

### 2.5 Khajiit (lunar substrate + 5 paths; LIGHT-touch pass, architecture untouched)
- Silent emergence (>=50 piety + >=15 lead at dawn, NO formal offers - the D4
  exemplar); five focused paths Khenarthi/Azurah/Baan Dar/Rajhin/Alkosh.
- **Community harm = substrate + god echo** (wounds the Lattice AND the relevant
  god - Khenarthi for caravans, Baan Dar for outcasts).
- **NEW GAINS (medium density):** Azurah = guard/reveal a secret + twilight-shrine
  meditation + FIGHT THE SHADOW-DARK (destroy undead/shadow, esp. at night - her
  war on Lorkhaj; fixes her regular-play starvation); Khenarthi = attend funeral/
  last rites (psychopomp SIG) + courier deliveries + hospitality + travel/rest
  through storms; Rajhin = the story-worthy LEGENDARY theft + the perfect no-alarm
  heist + the clean nonviolent escape (theft-as-ART vs Baan Dar's survival-theft);
  Alkosh = DEFEND A KHAJIIT SETTLEMENT (Elsweyr-defense, his strongest new) +
  temple ritual + destroy undead as time-perversion.
- **NEW LOSSES:** soul-trap a Khajiit (Azurah+Khenarthi - psychopomp violation);
  Rajhin trio (steal from the poor / brute-force / betray a fellow thief); Azurah
  identity sins (lie-to-exploit / profane Khajiit identity); grave desecration
  (Khenarthi - OWNED graves/Halls-of-Dead + necromancy on interred; dungeon urn-
  looting EXCLUDED); Rajhin artless spam; Alkosh chaos-spreading + temple sanctity.
- CUT (weak hooks): Azurah night-skill-learning, Alkosh punctuality/cowardice/
  chaos-magic, Rajhin ring-artifact. Baan Dar = nothing new (Bosmer set + capstones).
- **D4 offers: NONE** - silent moon-emergence (the moons decide).

### 2.6 Dunmer (ancestors + 3 Good Daedra + House of Troubles propitiation)
- **Offers (from the sheet):** formal offer within the Good Daedra triad at the
  global gate, framed as "a Reclamation deepening through the life already lived"
  - NEVER a conversion; the ancestor layer never turns off (others ~0.75x when
  one Good Daedra foregrounds).
- **Ancestor substrate:** G ash-prayer at the portable shrine (dawn/dusk),
  ancestor-witnessed honorable kill, Grey Quarter/diaspora solidarity, tend the
  Hall of the Dead (tomb proxy), defeat necromancers, family-duty quests. L
  necromancy on Dunmer dead = ULTIMATE taboo (-4.0), rob a Dunmer crypt, sell
  grave-goods, vampirism = ancestors SILENT (x0.0), werewolf strained (x0.5).
- **Boethiah adds:** overthrow a corrupt authority (SIG); win outnumbered +
  solo-duel a named boss; defeat a named Altmer/Thalmor rival. NOT signals:
  random murder/generic crime.
- **Mephala adds:** information is power (extract/pass intel; eavesdrop/steal
  documents); the quiet kill (stealth/poison assassination of NAMED enemies -
  Morag Tong); betrayal-for-the-web (curated branches serving the hidden network).
- **Azura (D5 reuse):** Azurah set + Dunmer overlays (cure-the-taint vs Molag
  Bal, mercy-to-the-cursed, Reclamation framing, dawn/dusk-as-twilight).
- **House of Troubles (LOCKED = act-based WARDS on existing Prince ledgers +
  stance; NO new systems, NO passive drips):** WARDS credit ancestors/relevant
  Good Daedra = refuse the Mace/Razor/Wabbajack; cure vampirism (+ancestor
  restoration w/ a scar); destroy vampires & Dagon's servants; restore sanity;
  rebuild-not-destroy; shield the weak. INVITES = existing stigma machinery.

### 2.7 Redguard (Tu'whacca + Leki + HoonDing + ancestor layer + 3 sects)
- **Sects/offers (from the sheet):** sect chosen at setup; switching DEED-GATED
  (2 sect-coded signals in 7 days; Ash'abah entry needs a MAJOR burden signal;
  never drift out of Ash'abah by a quiet week). Patron commitment = global
  formal-offer gate; sect filters priority/framing. Sect WITNESS-axis (Orc
  precedent): Crown = ceremony & lineage (ancestors x1.3); Forebear = making way
  through foreign terrain (x0.8); Ash'abah = the burden only Tu'whacca witnesses
  (x1.5). Candidates: Onsi deferred, Ruptga folded into HoonDing as flavor,
  Sep rejected.
- **Tu'whacca:** existing 6 + Far Shores token prayer, burial-witness quests,
  anti-vampire lane (destroy vampires / defeat a lich), tomb-entry reverence
  (small, once/site), refuse-desecration branches. + death-duty abandonment (-3.0)
  and vampire-reentry (+4.0) locked.
- **Leki (BLADE-GATED):** worthy-foe blade kill (one-handed, equal/higher-level,
  OPEN combat no sneak - everyday floor), mastery milestones (25/50/75/100),
  smith a high-tier blade, accept an open challenge & win, duel-to-first-blood
  (Ansei restraint), train/study the sword, boss/dragon felled by the blade.
  L: flee/decline an accepted challenge (cowardice) + strike a yielded opponent
  (treachery). CUT: parry-sequence, disarm, refuse-magic-aid, grindstone.
- **HoonDing (COMMUNAL doctrine):** "the way is made when the Redguard PEOPLE
  face an external obstacle... and a Redguard makes a way through." G: breakthrough
  trio (outnumbered victory / siege-breach / escape-impossible-odds; Alduin = SIG)
  + free the enslaved & oppressed (the heart) + clear an occupied space
  (completion-gated) + lead the charge + restore passage (refuse a road-toll,
  force a barred way/master locks, caravan escort). L: submit to oppression;
  fleeing-while-others-depend-on-you (scoped, grace rules; solo escape stays a
  GAIN); the oppressor's instrument (Thalmor/DB contract on a Redguard, heaviest);
  refuse-to-free (CURATED branches only). NOT adopted: bar-the-way.
- **Vampire earn-halt = BUILD (mirror Imperial):** onset copy promises piety
  stops while vampiric but only narrative shipped; gate AwardPiety (incl.
  earn-then-cure-before-dawn edge).

### 2.8 Breton (3 traditions + tracks; Syrabane added to Hidden Art)
- **Offers (from the sheet):** tradition chosen EXPLICITLY at setup, STABLE for
  1.0; only major authored forks redirect (Green Way werewolf trial opens
  Hircine). No generic broad lane; patron offers only within the chosen tradition.
  Divines are the Knight's Road pantheon specifically; NO Talos lane.
- **Knight's Road:** KnightlyVowIntegrity (0-100; TG join -30, DB join -40,
  kill-a-Vigilant -25, betrayals/abandonment -10..-15; Stendarr-shrine
  restoration CAPS at 75). G: Defend-the-Road ambient floor (predator-faction
  kills, NO sneak openers) + charity/no-reward favors + escort/protect +
  Paarthurnax-mercy + Dawnguard anti-vampire. Divines via D5 reuse.
- **Hidden Art (FULL Daedric contract):** boon+PRICE+WitchcraftExposure-as-stigma
  (Hidden 0-24 x1.0 / Suspected / Known / NOTORIOUS 75+ x1.25 - dual valid
  end-states). Per-patron G: Mora = forbidden texts/Black Books; Nocturnal =
  Nightingale oath/notable thefts; Namira = curated ritual beats; Hircine =
  beast-hunts. **+ SYRABANE** = the benign Aedric-style magic patron (see 2.9).
- **Green Way:** standing-stone pilgrimage = SIG (all 13 doomstones); Y'ffre
  carry-over per D5 MINUS Pact parts (no meat mandate/GPC/PactBound); spriggan
  groves; herbcraft/rare-ingredient gathering; Kynareth-shrine bridge; the
  werewolf trial fork ("beast serves the Green" vs Hircine=ruptures to Hidden
  Art); urban-drift neglect. Magnus = thin study-secondary; Phynaster FLAVOR-ONLY.

### 2.9 Altmer (Auri-El + 4 secondaries + ThalmorAlignment/crisis machinery)
- **Offers/mechanics (from the sheet):** secondaries commit via the shared
  patron-offer gate; ThalmorAlignment (-100..+100, five bands) modulates Lorkhan
  penalties (x0.75 Defiant .. x1.5 Enforcer); Trinimac offer GATED at 70+; four
  authored CRISIS states (Dragonborn declaration, Sovngarde, marriage, beast-blood)
  REPLACE flat penalties at big moments - resolved by coherent living. Defiant
  anti-Thalmor Altmer playable via self-cultivation (Magnus/Syrabane/Xarxes).
- **Auri-El (sunlit-places CUT):** G dawn acknowledgment; the Forgotten Vale
  CHANTRY WAYSHRINE PILGRIMAGE (SIG, Dawnguard); Auriel's Bow arc; orthodoxy
  affirmation; ancestor-spine; crisis-resolution + coherence beats. L tiered
  Lorkhan-adjacency (T1 -10 direct Talos/Sovngarde/Amulet; T2 -5 Nordic-framework
  incl. Dragonborn declaration/Thu'um/Companions/Wuuthrad; T3 small capped
  mortal-validation; T4 alignment-only) + consort-with-Daedra.
- **Magnus:** College rank advancement, Eye of Magnus arc (SIG), Psijic Order,
  rare arcane texts, milestone-gated skill growth (spam still rejected). L
  necromancy, Daedric magic artifacts. Signal-poor flag FIXED.
- **Syrabane (D5 MERGED single set, first NEW deity script):** lineage-craft
  (spell-learning, enchanting, conjuration, witch-alchemy) + protection (ward
  milestones, cure disease/lift curses, defend apprentices & mages); L betray/
  fail an apprentice. Breton reads folk-magic; Altmer reads the hero-ancestor's
  formal art.
- **Xarxes:** archive recovery (SIG - preserve vs let Mora consume); genealogy/
  lineage quests; rare lore tomes; lore-significant sites. L destroy records/burn
  books (-3.0 heaviest); falsify lineage; Daedric knowledge-pacts.
- **Trinimac (PARITY, NOT sparse - user override):** fills to medium density; the
  ThalmorAlignment 70+ gate stays as ACCESS mechanism only. G Daedra slain in
  defense of order; defend elven interests; enforcement missions; Thalmor
  recognition; weapon-mastery milestones; + existing orthodoxy pair. L accept a
  Daedric artifact (the betrayal that unmade him) + SERVE BOETHIAH (his devourer,
  ultimate anti-Trinimac) + dishonorable kills.

### 2.10 Argonian (Hist + People/home + Sithis change-doctrine; architecture PRESERVED)
- NO-OFFER race (substrate-gated). Enriched signals are seated IN the locked
  architecture, NOT replacing it:
  - **Bed of Choice = "the family I chose"** (HOME anchor): one PDV_SacredPlace
    (MaxLocations=1, NOT road-cycling); 3 qualifying sleeps in a rolling 30 days;
    miss = lose place bonus + LIGHT People decay.
  - **Community BUFFERS low Hist** (the People hold you when the trees can't).
  - **Hist relation = CROSS-LAYER MODIFIER** on Layer 2/3 scoring.
  - Leaky floor (-1/dawn after 3 grace-days, floor 20; only offset).
- **Hist G:** near-water rest/sleep, enter a wetland/swamp, wade a river, meditate
  near water, tend living growth, near-water combat win (env/reflective ONLY).
  L: abandonment (-4), corruption (-8, vampire+domination), void-overreach (-6).
- **People G:** help named Argonians (Derkeethus/Keerava/Wujeeta), the WINDHELM
  ASSEMBLAGE dock lane (EXTRA-HEAVY), Riften docks, protect/defend/feed/heal,
  bed-returns. L: kill/exploit the People, the Jaree-Ra piracy betrayal, miss the
  bed cadence.
- **Sithis (change-doctrine primary; >=3-signal gate, quarter-piety until active):**
  G Nisswo change-ACCEPTANCE dialogue + void-philosophy choices (mainstream) +
  the DB ladder as the DARK END (join->Astrid->Emperor->Listener). **Order-
  destruction FOLDED INTO ASSASSINATION** (killing a pillar IS the unmaking).
  L raise-undead + refuse/betray a contract. CUTS KEPT: death-witness gain CUT
  (undetectable); heal-as-Sithis-loss CUT (collides with Hist/People healing).

---

## 3. Build backlog (implementation items surfaced)

- **Syrabane** = first NEW deity script (`PDV_Deity_Syrabane.psc`), shared Breton
  Hidden Art + Altmer secondary (D5).
- **Redguard vampire earn-halt** = wire (mirror Imperial VampireHalt).
- **Trinimac** = fill to parity (medium density; keep the 70+ access gate).
- **House of Troubles** = act-based wards on existing Prince ledgers + stance
  (no new systems).
- **Bosmer stub-wiring** = "proper hunt"/"forest kept" are dev-only activators,
  never placed - wire the existing kill classifier or cut; Nettlebane/Eldergleam
  quest-branch losses.
- **Generic->bespoke migration** = the CSV `pdv_likesdislikes_gen` layer + the
  curated `PDV_Deity_*.psc` layer + the quest-matrix tranches all need the new
  signals; respect codegen (VERSION bump), count-frozen quest matrix (tune via
  tranches), anti-farm caps (daily-only; weekly caps dropped for piety, kept only
  for reward EFFECTS like cheat-death).
- **CAP POLICY:** piety = once-a-day caps + repeat-decay + global ~4.3/day
  ceiling. No weekly caps on piety.

---

## 4. NEXT-SESSION CROSS-CHECK TASK (the ask)

Reconcile this remap against the shipped guides + locked architecture, and
produce a divergence ledger so we know what to update vs what already matches.

1. **Vs the Nexus race guides** (`docs/player-guides/races/*.md`): for each race,
   diff the guide's "How You Gain/Lose Piety" against section 2 here. Flag: (a)
   guide describes a signal we CUT/changed; (b) guide is missing a new bespoke
   signal; (c) guide describes a signal that is a known STUB (Bosmer proper-hunt/
   forest-kept) - the guides must not promise what doesn't fire. NOTE: a separate
   spawned session was updating these guides to the CURRENT live state - reconcile
   against its output, don't double-edit.
2. **Vs the architecture docs** (`references/PDV_RaceArchitecture_DesignReference.md`
   sections 4.x/10.1-10.10; `race-sheets/PDV_RaceDesign_*.md`; `AGENTS.md`): flag
   where the remap DIVERGES from LOCKED architecture and therefore needs a
   ratification decision, e.g.:
   - Nord: Orkey REPLACES Arkay for Old-Ways baseline (sheet excludes Orkey as
     non-worshippable + uses "Orkey" as an Arkay display-alias - THIS IS A REVERSAL,
     needs sheet update).
   - Orc: Trinimac flagged for v2 (sheet is Malacath-only); Trinimac ALSO filled
     to parity as an Altmer secondary "not sparse" (overrides the sheet's
     "sparse by design" for Trinimac).
   - Imperial: civic-duty AXIS is NEW (sheet frames civic acts as feeding the
     Divines) - needs sheet update.
   - Breton: Syrabane ADDED to Hidden Art (not in the sheet's Hidden Art roster).
   - Altmer: Trinimac parity override; sunlit-places cut.
   - Dunmer: House of Troubles ADDED as propitiation (sheet treats them as
     stigma-only pressure) - confirm the "act-based wards on existing ledgers"
     framing lands in the manifest.
   - Redguard: sect witness-axis multipliers (x1.3/x0.8/x1.5) - confirm vs sheet.
3. **Reconcile the standing decisions** D1-D5 against `PDV_STANDARDS.md` +
   `AGENTS.md` conventions (esp. D3 regular-play rule vs the existing survival-mode
   signals in several sheets; D4 per-architecture offers vs the shared offer gate).
4. **Deliverable:** a divergence ledger (per race: MATCHES / GUIDE-UPDATE /
   ARCH-RATIFY / BUILD) that gates the actual implementation pass.

---

## 5. Remaining scope (not started)

**Daedric Prince track** - the 16 Princes as a standalone boon/price/stigma
contract system, reconciled against the race-side readings already designed here
(Dunmer Good Daedra, House of Troubles, Breton Hidden Art four, Hircine/Molag Bal
curse-access, Khajiit dark pressures). Boethiah is a full pilot in
`race-sheets/PDV_DaedricContent_Manifest.md`; the other 15 are PrincePathType
stubs. Same method: D2 roster confirm -> per-Prince lore dig -> grill -> lock.

---

## 6. Provenance / method

Designed via per-race lore digs (UESP + Imperial Library) cross-checked against
in-repo theology (`PDV_RaceArchitecture_DesignReference.md`, `PDV_RaceDesign_*.md`,
`PDV_DaedricContent_Manifest.md`) and the live signal layers (CSV + `PDV_Deity_*.psc`
+ `PDV_QuestReactionMatrix_Full.csv`). Each race was grilled decision-by-decision
with the owner; owner overrides are marked inline above (e.g. Trinimac parity,
order-destruction->assassination, Argonian architecture-preservation). This is a
DESIGN target - nothing here has been wired, and all numbers remain tunable.
