# PDV Race Playstyle Coverage Ledger

**Created:** 2026-05-30
**Status:** Living gameplay-balance ledger
**Owner:** Companion to `references/authoring/PDV_RaceGameplayBalanceAudit.md`

## Purpose

This ledger checks whether each race supports a healthy spread of character fantasies. It is not trying to make every race good at everything. It is trying to prevent a race from accidentally collapsing into one optimal build.

Use this before adding or tuning rewards. If a new reward makes an already-strong playstyle stronger, consider whether a thin playstyle needs recognition, privilege, or a contextual favor instead.

## Rating Vocabulary

| Rating | Meaning |
|---|---|
| `Strong` | The race has clear hooks, rewards, and fantasy support for this playstyle. |
| `Supported` | The playstyle works and has some race-shaped expression, but may need tuning or more content. |
| `Thin` | The playstyle is plausible but needs more hooks, feedback, or reward wealth. |
| `Intentional Friction` | The race should make this playstyle costly, taboo, or limited for theological reasons. |
| `Not Core` | Not a launch priority for that race, but should still avoid confusing feedback. |

## Coverage Matrix

| Race | Warrior / Front-Line | Mage / Scholar | Stealth / Social | Survival / Travel | Craft / Labor / Trade | Low-Violence / Mercy | Curse / Daedric | Main Coverage Risk |
|---|---|---|---|---|---|---|---|---|
| Nord | `Strong` - Shor, Tsun, Talos, Companions, honorable combat, Hircine pressure. | `Supported` - Julianos/Kynareth/Nine Divines support exists but not primary Nord fantasy. | `Supported` - Dibella, Mara, Talos public/private pressure, hold identity. | `Strong` - Kyne/Kynareth, outdoors, weather, hunting, sleep, Greybeard/Thu'um. | `Supported` - Zenithar, household, honest work. | `Supported` - Mara, Stuhn, Stendarr, Arkay death rites. | `Supported` - Hircine runtime-proven; vampire rupture/scar. | Nord can become best at too many things because hooks are abundant; broad/focused ceilings matter. |
| Imperial | `Supported` - Legion/order, Akatosh/Stendarr, civic conflict. | `Supported` - Julianos, Akatosh, institutional study. | `Strong` - public/private Concordat logic, civic status, Talos pressure. | `Supported` - road/order framing, but not the main identity. | `Strong` - Zenithar, civic trade, honest work. | `Strong` - mercy, Arkay, Stendarr, burial and civic restraint. | `Intentional Friction` - Daedric paths and vampire collapse should be costly. | Abstract civic logic must be tied to concrete acts and not raw faction state. |
| Breton | `Strong` - Knight's Road and Green Way can both support protective combat. | `Strong` - Hidden Art, old magic, College, Daedric knowledge, druidic magic. | `Strong` - double life, cover/notoriety, occult/social rupture. | `Supported` - Green Way, standing stones, outdoor rites. | `Supported` - less central, but contracts/vows/occult resources can carry it. | `Strong` - Knight's Road mercy and unrewarded aid. | `Strong` - Hidden Art and Hircine fork access. | Too many strong routes can become too rich if all tracks reward at once. |
| Dunmer | `Strong` - Boethiah, trials, overthrow, significant victories. | `Strong` - Azura, thresholds, restoration, prophecy, forbidden knowledge deviations. | `Strong` - Mephala, hidden networks, Thieves Guild as network rather than petty crime. | `Supported` - exile, ash-prayer, diaspora, portable/private shrine. | `Supported` - community/network/trade through Mephala and ancestor continuity. | `Supported` - ancestor duty and restoration arcs; not the central fantasy. | `Strong` - native Reclamations plus deviation paths. | Strong substrate plus multiple strong focuses can overstack unless ancestor stays quiet. |
| Altmer | `Supported` - Trinimac/enforcement and defense-of-civilization route. | `Strong` - Auri-El, Syrabane, Xarxes, Magnus, Psijic study. | `Thin` - political/social coherence is strong, but stealth/social non-scholar play needs care. | `Intentional Friction` - mundane Skyrim life and Lorkhan world are pressure, not easy reward. | `Supported` - scholarship, institutional standing, genealogical record, but ordinary craft is not central. | `Thin` - restraint, protection, and restoration can work only if framed through coherence, not generic kindness. | `Intentional Friction` - Daedra, werewolf, and vampire paths are crisis or rupture, not easy alternatives. | Implementation-spec is closed; punitive feel risk now moves to costing, rejected-hook proof, and crisis/favor pacing. |
| Khajiit | `Supported` - Alkosh dragon/order and Baan Dar survival; not generic combat. | `Strong` - Azurah thresholds, twilight, fate, moon/star logic. | `Strong` - Rajhin, Baan Dar, caravan cunning, artful theft. | `Strong` - Khenarthi, road homes, moon phases, open sky. | `Supported` - caravan/trade and Baan Dar, but avoid generic vendor loops. | `Supported` - Khenarthi soul-guidance, caravan aid, exile mercy. | `Supported` - ShadowDrift, Nocturnal pressure, Hircine/Molag Bal posture, but native lattice remains. | Khenarthi/Azurah are easiest; Baan Dar/Rajhin/Alkosh need sharp hooks, and moon systems must not become chores. |
| Bosmer | `Strong` - Old Contract hunting/archery and trial logic. | `Thin` - Y'ffre/Kynareth nature magic is plausible, but Skyrim hooks are limited. | `Strong` - Living Story, Exchange, Bandit Road, Baan Dar. | `Strong` - Green Pact, outdoor life, hunting, path identity. | `Supported` - Exchange and proportionate debt can carry trade/labor meaning. | `Supported` - Living Story, mercy, restraint, and preservation, but needs curated hooks. | `Supported` - Hircine/Baan Dar/Nocturnal pressures, but not ordinary Bosmer core. | Old Contract/hunter proof density can overshadow the other three paths unless non-hunter hooks are formalized. |
| Redguard | `Strong` - Crown, Leki, HoonDing, honorable combat, make-way moments. | `Thin` - magic is not absent, but needs Yokudan/Forebear/Ash'abah framing if supported. | `Supported` - Forebear dignity, contracts, social survival, Ash'abah stigma. | `Strong` - Tava, exile, travel, Forebear road life. | `Supported` - Forebear contracts and practical dignity; avoid generic commerce. | `Strong` - Tu'whacca, death duty, burial, anti-necromancy, Ash'abah burden. | `Intentional Friction` - Daedric paths should feel foreign, taboo, or curse-access. | Death-duty and martial hooks can swallow Crown form, Forebear adaptation, and Ash'abah stigma if unchecked. |
| Orc | `Strong` - Malacath, endurance, tests, Stronghold and Legion/Exile combat. | `Thin` - magic support is not core; could exist through survival, curses, or Daedric rupture only. | `Supported` - City dignity, social humiliation/resistance, service exile. | `Supported` - exile/service endurance, harsh travel, stronghold belonging. | `Strong` - forge, labor, quality work, oaths of craft. | `Thin` - mercy is not central, but dignity, restraint, and honorable completion should exist for City/Legion modes. | `Intentional Friction` - Malacath native reading must not become generic Daedric shopping. | Stronghold smith/warrior path can dominate unless City and Legion/Exile get dynamic support. |
| Argonian | `Supported` - Hist-Touched environmental clarity, community defense, and survivability near water. | `Supported` - Hist sense, restoration/reconstruction, Saxhleel memory; needs Hist sap and death-rite support. | `Strong` - Sithis/Void, Dark Brotherhood, stealth, death-facing choices. | `Strong` - water/wetland, exile, bed of choice, Hist distance. | `Thin` - labor/community survival can exist, but needs explicit dock/Assemblage/chosen-family framing. | `Supported` - People layer and community support, but sparse vanilla hooks need custom-light surfacing. | `Strong` - Sithis threshold and vampire/werewolf posture, if kept high-cost. | Sithis/assassin path is easiest to hook; Hist/People need deliberate non-assassin payoff. |

## Under-Served Playstyle Notes

| Playstyle | Races Needing Attention | Useful Fix Shape |
|---|---|---|
| Non-combat mage/scholar outside Altmer/Dunmer/Breton/Khajiit | Bosmer, Redguard, Orc, Argonian | Use ritual, knowledge, resistance, environmental sense, or privilege. Do not add generic spell-cost buffs unless lore supports it. |
| Low-violence/restoration | Orc, Bosmer, Argonian, Altmer | Recognition, restraint, community protection, recovery arcs, and dialogue can carry value without making every race Stendarr-like. |
| Social/community play | Bosmer, Redguard, Orc City/Legion, Argonian People, Khajiit caravan | Add status readouts, curated dialogue, merchant/service privileges, or one-shot recognition moments. |
| Craft/labor beyond Orc/Zenithar | Redguard, Khajiit, Bosmer, Argonian | Tie craft to ritual, travel, debt, community, or survival rather than raw crafting loops. |
| Curse/Daedric edge builds | All races | Keep native race identity visible. Price, stigma, exit, and residue must be authored before reward magnitude is raised. |

## High-Risk Race Pass Order

Use this order for focused review:

1. **Altmer** - Closed implementation-spec with high punitive-feel risk during costing and proof.
2. **Argonian** - Hist/People routes need to compete with easier Sithis hooks.
3. **Orc** - City and Legion/Exile need parity with Stronghold.
4. **Redguard** - Sect identity needs to survive strong death-duty and warrior hooks.
5. **Bosmer** - Non-hunter paths need comparable payoff.
6. **Khajiit** - Five focus paths need equal attractiveness without moon chores.
7. **Breton** - Strong spread needs stack control.
8. **Dunmer** - Strong spread needs substrate/focus stack control.
9. **Imperial** - Strong civic identity needs concrete acts.
10. **Nord** - Hook-rich baseline needs reward ceilings.

## Required Output Per Race Pass

Each race pass should end with this block:

```text
Race:
Playstyle verdict: OK / Watch / Thin / Incomplete
Strongest fantasies:
Thinnest fantasies:
Intentional exclusions:
Needed reward support:
Needed writing/surfacing support:
Needed hook/proof support:
Next implementation-safe slice:
```

## Focused Pass: Altmer (2026-05-30)

```text
Race: Altmer
Playstyle verdict: Watch
Strongest fantasies:
- Mage, scholar, Psijic-adjacent seeker, and institutional savant.
- Auri-El dawn devotee whose play is about coherence, self-mastery, and theological continuity.
- Orthodox enforcer or Trinimac-aligned defender of civilization when `ThalmorAlignment` is high.
Thinnest fantasies:
- Stealth/social Altmer outside scholarship, politics, secrecy, or institutional cover.
- Low-violence/restoration Altmer unless support is framed as restraint, lineage protection, warding, preservation, or crisis resolution.
- Craft/labor Altmer outside records, study, genealogy, rare texts, and institutional work.
Intentional exclusions:
- Generic Daedric worship as a normal alternative to Auri-El-centered coherence.
- Werewolf advancement; it halts devotion rather than creating a rival viable path.
- Fully restored orthodox vampire play while cursed. Vampire Altmer is exile-limited at most.
Needed reward support:
- Contextual favors for coherent restraint, crisis resolution, scholarship, protective magic, orthodox enforcement, record keeping, and heterodox self-cultivation are now specified; implementation must keep them distinct.
- Recognition that can carry non-combat value: College, rare texts, genealogy, Psijic framing, Thalmor/orthodox response, and crisis resolution.
- Low-violence support through preservation and restraint, not broad Stendarr/Mara-style mercy copy.
Needed writing/surfacing support:
- First-time interpretation notices for non-obvious Lorkhan-adjacent events.
- Survey/status lines that distinguish Heterodox, Orthodox Moderate, and Thalmor Devout without sounding like raw faction UI.
- Crisis-state copy that tells the player whether they are dissonant, questioning, reasserting, scarred/resolved, or still incoherent.
Needed hook/proof support:
- Dawn, study, magic-skill, College/Psijic, and authored quest-stage hooks.
- `ThalmorAlignment` event hooks and Trinimac gate proof.
- Lorkhan rejected-surface tests so ordinary travel, friendship, and post-first-crisis Dragonborn identity are not penalized.
Next implementation-safe slice:
- Cost the closed Altmer implementation spec into runtime surfaces: crisis state/readback, favor proof, Exiled vampire cap, focused-deity hooks, and rejected-surface assertions.
```

## Focused Pass: Argonian (2026-05-30)

```text
Race: Argonian
Playstyle verdict: Thin
Strongest fantasies:
- Exile-survivor who maintains identity through water, rest, reflection, and chosen family.
- Community protector centered on Windhelm Assemblage, Riften Docks, named Saxhleel aid, and bed-of-choice cadence.
- Sithis-aware death-facing character, especially through Dark Brotherhood milestones, if full Void activation remains thresholded.
Thinnest fantasies:
- Non-assassin community worker, dock laborer, or chosen-family caretaker unless Windhelm/Riften/bed-of-choice recognition is surfaced.
- Mage/restoration Argonian unless Hist sap, water clarity, death rites, and reconstruction are made visible.
- Craft/labor Argonian outside survival, dock, community, or ritual framing.
Intentional exclusions:
- Aedra/Daedra as normal Argonian worship. Most Prince quests are tasks or foreign contacts, not Saxhleel devotion.
- Generic stealth, generic murder, and ordinary killing as Sithis signals.
- Void replacing Hist. A Sithis-heavy Argonian may be stable, but not whole in the same way as a Hist-maintained Argonian.
Needed reward support:
- Hist rewards that feel like environmental refuge: water/wetland recovery, rest near water, clarity, and softened hazard pressure.
- People rewards that are visible: community recognition, chosen-family stability, named Argonian support, and mutual aid moments.
- Low-violence support through preservation, death rites, community care, and reconstruction rather than generic mercy.
Needed writing/surfacing support:
- Survey/status text that explains Hist, People, and Void as one layered exile identity.
- Notifications for Hist thinning, People isolation, bed-of-choice stability, and Sithis threshold activation.
- Arkay priest/death-rite reactions so Argonian death theology has an external world response.
Needed hook/proof support:
- Water/wetland/rest/reflection maintenance surfaces with daily caps.
- Windhelm Assemblage, Riften Docks, named Argonian aid, and bed-of-choice cadence.
- Dark Brotherhood and curated death/void/change choices, with counter proof that generic murder does not count.
- Curse posture readback for Normal, Distant, Strained, Silenced, and Corrupted.
Next implementation-safe slice:
- Author the Argonian Hist/People implementation backlog before adding more Void runtime work: Hist sap tool, water/rest maintenance, bed-of-choice cadence, community recognition, Arkay death-rite reactions, and curse-posture proof.
```

## Focused Pass: Orc (2026-05-30)

```text
Race: Orc
Playstyle verdict: Watch
Strongest fantasies:
- Stronghold warrior-smith whose forge, oath, challenge, and community all reinforce Malacath's code.
- Legion/Exile endurance build that treats service, contract, and survival under foreign discipline as devotion.
- City Orc quality-labor and dignity build, if curated social/community hooks are authored.
Thinnest fantasies:
- Non-smith City Orc unless quality labor includes service, commission, community, and dignity beyond crafting loops.
- Low-violence Orc unless restraint means honorable completion, refusal to exploit, protection of community, or dignity under pressure.
- Magic Orc outside curse, survival, or rare rupture contexts. This should remain limited.
Intentional exclusions:
- Aedra/Daedra as normal Orc worship alongside Malacath.
- Trinimac as a standard player devotional lane in 4E 201 Skyrim.
- Generic faction membership, raw crafting, ambient insults, and ordinary travel as piety triggers.
Needed reward support:
- City rewards for quality work, named Orc solidarity, self-made community, and dignity under mixed-society pressure.
- Legion/Exile rewards for completed pressure-bearing service, private endurance, honorable discipline, and return to an invested place.
- Stronghold rewards with quality/context caps so Blood-Kin, forge, and worthy challenge stay rich but not farmable.
Needed writing/surfacing support:
- Survey/status lines for Stronghold, City, and LegionExile modes that make the current life condition legible.
- Dignity and endurance feedback that does not sound like generic warrior praise.
- Neglect text for the forge going empty, dignity eroding, or service becoming self-erasure.
Needed hook/proof support:
- Blood-Kin, `The Cursed Tribe`, stronghold aid, forge quality, and worthy challenge for Stronghold.
- Curated service/faction completion, self-made community state, named Orc aid, and quality labor for City/Legion.
- Rejected-hook tests for generic faction membership, raw craft count, ordinary travel, and broad insult simulation.
Next implementation-safe slice:
- Cost the Orc life-mode backlog before runtime build: active state, mode transition gates, one-lane favor eligibility, City/Legion self-made community, quality forge filters, service milestones, and rejected-hook proof.
```

## Focused Pass: Redguard (2026-05-30)

```text
Race: Redguard
Playstyle verdict: Watch
Strongest fantasies:
- Crown martial inheritor: orthodox form, ancestor bearing, Leki/Onsi discipline, and honorable adversity.
- Forebear road survivor: travel, contract, diplomacy, mixed-society survival, and Tava/HoonDing make-way moments.
- Ash'abah death-duty bearer: Tu'whacca, Hall of the Dead, tombs, undead cleansing, and impurity borne for others.
Thinnest fantasies:
- Mage/scholar Redguard unless framed through Yokudan ritual, Satakal cycle awareness, Tu'whacca death practice, or Forebear pragmatic learning.
- Craft/labor Redguard outside Forebear contract, service, trade, and practical dignity.
- Social Ash'abah unless stigma/recognition is authored; vanilla will not carry this alone.
Intentional exclusions:
- Generic Daedric middle ground. Most Princes are outside the Yokudan frame, with Meridia only tolerated as subordinate anti-undead utility.
- Hircine integration. Werewolf strains but does not open a true Hircine Redguard path.
- Vampire substitute path. Cure must re-enter through Tu'whacca first.
Needed reward support:
- Crown support for Yokudan form, tomb respect, honorable conduct, and rare sacred survival.
- Forebear support for road passage, honored contracts, respectful bridge-building, and difficult foreign-society success.
- Ash'abah support for burial duty, undead cleansing, impurity borne, and social cost recognized by Tu'whacca.
Needed writing/surfacing support:
- Survey lines already drafted for Crown, Forebear, and Ash'abah should stay sect-specific.
- Far Shores token copy must consistently address Tu'whacca, not Arkay.
- Ash'abah stigma needs at least light external surfacing so the burden is not only a hidden counter.
Needed hook/proof support:
- Redguard sect state, sect switching, Far Shores token, Hall/death-duty hooks, and Ash'abah entry/exit.
- Forebear road signals must reject fast travel and generic gold-making.
- HoonDing must use curated major milestones/named bosses or proof-tested odds detection with weekly caps.
- Crown honorable combat must reject generic body count and obvious exploit paths.
Next implementation-safe slice:
- Cost the Redguard sect backlog before runtime build: sect state/readback, Far Shores token, three broad-lane favor families, HoonDing cap, Ash'abah stigma surfacing, and rejected-hook proof.
```

## Focused Pass: Bosmer (2026-05-30)

```text
Race: Bosmer
Playstyle verdict: Watch
Strongest fantasies:
- Old Contract hunter: Green Pact discipline, archery, proper hunting, compliance, and Y'ffre reckoning.
- Living Story carrier: community, memory, preservation, oral tradition, and secondary gods.
- Bandit Road survivor: road life, pariah solidarity, Baan Dar reversal, and exile cunning.
Thinnest fantasies:
- Exchange outside curated debt, justice, contract, and proportionate redress hooks.
- Nature-magic Bosmer, because Skyrim has limited clean Y'ffre/Kynareth surfaces.
- Low-violence Living Story unless preservation, mercy, family, and memory hooks are authored.
Intentional exclusions:
- Generic theft as Baan Dar. Bandit Road is survival and pariah luck, not a crime counter.
- Generic commerce as Z'en. Exchange is debt, balance, and proportionate justice, not vendor optimization.
- Wild Hunt as a player-facing devotional track.
Needed reward support:
- Living Story needs community-preservation, memory, nature-site, Arkay/Xarxes/Mara/Stendarr, and story-privilege payoff.
- Exchange needs debt-settling, fair exchange, promise, defense, and proportionate redress payoff.
- Bandit Road needs road-life, outcast aid, severe-odds survival, and weekly reversal payoff.
Needed writing/surfacing support:
- Formal contextual-favor rows for all four paths, with Old Contract not allowed to own all dramatic surfacing.
- Survey and neglect texture should distinguish Story drying up, debts going unpaid, and luck going dormant.
- Kynareth proxy copy should read as Bosmer/Y'ffre interpretation, not Imperial Kynareth conversion.
Needed hook/proof support:
- Existing Phase 9 Bosmer proof remains the baseline for path setup, switching, proof routes, Old Contract re-entry, and persistence.
- Formal proof surfaces for Living Story, Exchange, and Bandit Road trigger families.
- Green Pact tag-layer gate before item-level Old Contract feedback.
- Rejected-hook tests for generic theft, generic commerce, generic killing, passive road travel, and untagged plant assumptions.
Next implementation-safe slice:
- Place and runtime-prove the eight Bosmer non-hunter favor proof ACTIs from `PDV_Phase20_BosmerProofPlacement_Runbook.md`, then compare Living Story, Exchange, and Bandit Road playfeel against the existing Old Contract/hunter baseline before tuning reward strength.
```

## Focused Pass: Khajiit (2026-05-30)

```text
Race: Khajiit
Playstyle verdict: Watch
Strongest fantasies:
- Road Khajiit: Khenarthi, open sky, road homes, caravan life, weather, and guided mercy.
- Threshold Khajiit: Azurah, dawn/dusk, fate, prophecy, magic, and major transitions.
- Trickster Khajiit: Rajhin as elegant legend-making and Baan Dar as exile survival/reversal.
Thinnest fantasies:
- Alkosh outside main-quest/dragon/order content, because the lane is intentionally rare.
- Craft/labor Khajiit unless framed through caravan service, survival, trade, or community support.
- Low-violence Khajiit outside Khenarthi guidance, caravan aid, exile mercy, and protective route choices.
Intentional exclusions:
- Formal patron offers or accept/refuse UI for Khajiit.
- Generic theft as Rajhin and generic survival as Baan Dar.
- Ordinary night travel, stealth, or moon observance as ShadowDrift.
- Moon sugar as a general devotional trigger.
Needed reward support:
- Baan Dar needs reversal, pariah aid, outmatched survival, and clever exile choices.
- Rajhin needs elegant theft, notable targets, performance, reputation, and story-worthy infamy.
- Alkosh needs named dragon, main-quest, anti-chaos, and order-keeping hooks that feel rare but real.
Needed writing/surfacing support:
- Status readouts should explain broad lunar worship, current emphasis, road-home cadence, lunar posture, and ShadowDrift without implying failure.
- Khenarthi/Azurah copy can be softer and frequent; Baan Dar/Rajhin/Alkosh copy should be sharper and rarer.
- Caravan/community recognition should make road life social, not just environmental.
Needed hook/proof support:
- Outdoor sleep/rest, non-fast-travel road movement, road-home circuit, caravan interactions, and dawn/dusk windows.
- Azura's Star and major threshold beats for Azurah.
- Thieves Guild/elegant high-value theft for Rajhin, pariah reversal for Baan Dar, named dragon/main quest for Alkosh.
- Rejected-hook tests for fast travel, one-bed road-home farming, petty theft spam, generic vendor loops, ordinary night stealth, and general moon-sugar use.
Next implementation-safe slice:
- Cost the Khajiit cadence/emphasis backlog: moon source/fallback, focused-emphasis state, road-home circuit, caravan/community hooks, Baan Dar/Rajhin split, Alkosh rare hooks, ShadowDrift boundary, and rejected-hook proof.
```

## Focused Pass: Breton (2026-05-30)

```text
Race: Breton
Playstyle verdict: Watch
Strongest fantasies:
- Knightly protector: vows, mercy, selfless defense, public honor, Stendarr/Akatosh/Mara.
- Hidden occultist: Daedric scholarship, cover, notoriety, double life, and managed exposure.
- Green Way druid: standing stones, old nature rites, Y'ffre, Magnus, Phynaster, and werewolf fork tension.
Thinnest fantasies:
- Craft/labor Breton unless tied to vows, contracts, occult resources, or druidic ritual.
- Pure mundane social Breton outside Knightly public face or Hidden Art cover.
- Hybrid all-tradition Breton, intentionally limited because normal tradition switching is not a 1.0 feature.
Intentional exclusions:
- Generic broad-worship lane.
- Casual tradition switching.
- Free Hidden Art plus Knight's Road plus Green Way reward stacking.
Needed reward support:
- Each tradition needs its own Tier 1/2 identity and contextual favors.
- Track pressure should mostly modify, gate, or rupture, not create bonus stacks.
- Hidden Art should pay strongly only when exposure/cover/notoriety cost is real.
Needed writing/surfacing support:
- Tradition setup, focus emergence, Champion entry, band crossings, Druidic Trial, curse-state split, and survey text.
- Vigilant pressure can stay deferred if exposure band text carries the launch experience.
Needed hook/proof support:
- Tradition enum, vow integrity, witchcraft exposure, druidic standing, druidic fork, curse split, and rejected generic hooks.
Next implementation-safe slice:
- Cost the Breton stack-control backlog: tradition state, three track readbacks, per-tradition favor rows, Druidic Trial, curse split, and rejected-hook proof.
```

## Focused Pass: Dunmer (2026-05-30)

```text
Race: Dunmer
Playstyle verdict: Watch
Strongest fantasies:
- Azura threshold mage/pilgrim/restorer.
- Boethiah warrior/spellsword/revolutionary.
- Mephala hidden-network rogue, social manipulator, or necessary-secret keeper.
Thinnest fantasies:
- Low-violence Dunmer outside ancestor duty, Azura restoration, burial/family obligations, and diaspora solidarity.
- Craft/labor Dunmer unless tied to shrine maintenance, household, network, or exile continuity.
- Non-Reclamation deviation play until the Daedric system carries price/stigma/exit.
Intentional exclusions:
- A Dunmer path enum for Azura/Boethiah/Mephala.
- Generic crime as Mephala, generic cruelty as Boethiah, generic twilight/magic as Azura.
- Tribunal memory as a separate controllable path.
Needed reward support:
- Ancestor broad play through ash-prayer, portable shrine, home bonus, Grey Quarter/diaspora, and shared Reclamations.
- Focus-specific payoff that is strong but does not erase the ancestor floor.
- Deviation prices that prevent non-Reclamation paths from becoming better class perks.
Needed writing/surfacing support:
- Ancestor posture/silence/restored-scarred readouts.
- Portable shrine/home-bonus text.
- Reclamation focus copy that says focus adds weight, not replacement.
Needed hook/proof support:
- Ancestor substrate, posture enum, shared patron focus, Good Daedra boundaries, portable shrine, home bonus, and deviation rejection tests.
Next implementation-safe slice:
- Cost the Dunmer stack-control backlog: ancestor substrate proof, posture state, Reclamation boundary assertions, marked-moment caps, deviation price/exit hooks, and rejected generic triggers.
```

## Focused Pass: Imperial (2026-05-30)

```text
Race: Imperial
Playstyle verdict: Watch
Strongest fantasies:
- Civic public servant: Akatosh, Arkay, Stendarr, Zenithar, lawful repair, burial duty, mercy, honest work.
- Talos conscience player: private or open defiance with real political/theological cost.
- Concordat compromise/enforcer arc, if repair and corrosion remain visible.
Thinnest fantasies:
- Survival/travel Imperial, because road life is not the main identity.
- Stealth/crime Imperial, unless framed as anti-civic pressure or Talos secrecy.
- Daedric Imperial, intentionally taboo or narrow service.
Intentional exclusions:
- Faction membership as devotion.
- Generic temple attendance as favor.
- Generic anti-Thalmor violence as Talos devotion.
- Cruelty disguised as order.
Needed reward support:
- Non-combat civic routes need strong recognition: mercy, burial, public service, honest exchange, repair.
- Talos needs private/public distinction and compliance walk-back.
- Concordat Enforcer needs Arkay/Stendarr repair gates, not just punishment.
Needed writing/surfacing support:
- Concordat standing survey/status text.
- Repair and rupture feedback.
- Civic recognition that names the act, not only the institution.
Needed hook/proof support:
- Concordat bands, offer filters, Talos acceptance movement, Enforcer repair signals, civic whitelists, and rejected-hook tests.
Next implementation-safe slice:
- Cost the Imperial civic-proof backlog: concrete act whitelists, Concordat readback, Talos filters, repair gates, non-combat proof hooks, and rejected faction/attendance hooks.
```

## Focused Pass: Nord (2026-05-30)

```text
Race: Nord
Playstyle verdict: Watch
Strongest fantasies:
- Broad Old Ways/Nine Divines Nord whose life is noticed by multiple gods.
- Focused Kyne/Talos/Shor/Tsun/Stuhn patron play with sharper identity.
- Hircine curse/Daedric edge, already proven as the first Nord Prince path.
Thinnest fantasies:
- Pure mage Nord unless Julianos/Kynareth/Nine Divines support is intentionally foregrounded.
- Stealth/criminal Nord unless Dibella/Mara/Talos secrecy or Daedric pressure supports it.
- Low-violence Nord if Mara/Stuhn/Stendarr/Arkay hooks stay too quiet beside combat and Kyne/Talos.
Intentional exclusions:
- Broad worship inheriting every patron boon.
- Generic anti-Thalmor violence as Talos favor.
- A general Nord Daedric menu before Hircine/curse price patterns are stable.
Needed reward support:
- Broad blended favors must be culturally complete but softer than focused patron rewards.
- Focused patron rewards need clear contrast and offer gates.
- Hook-rich play needs caps and anti-repeat rules for combat, tombs, travel, and Talos pressure.
Needed writing/surfacing support:
- Broad Old Ways versus Broad Nine Divines survey/status copy.
- Rare privilege dialogue for true Champion states.
- Curse/scar text that keeps native Nord identity visible after Hircine or vampire rupture.
Needed hook/proof support:
- Pantheon baseline, dawn offer gate, broad/focused cap checks, accepted patron suppression, Talos filters, Hircine interaction, and rejected-hook tests.
Next implementation-safe slice:
- Cost the Nord ceiling backlog: broad/focused reward caps, pantheon baseline readback, Kyne/Talos contrast, Hircine stack checks, and rejected dense-hook tests.
```

## Immediate Work Queue

1. **Altmer:** follow `PDV_Phase20AltmerImplementationCosting.manifest.json` for crisis state, Lorkhan routing, contextual favor proof, Exiled vampire cap, and rejected-surface assertions.
2. **Argonian:** follow `PDV_Phase20ArgonianImplementationCosting.manifest.json` to make non-assassin Hist/People play viable before adding more Void/Sithis reward.
3. **Orc:** follow `PDV_Phase20OrcImplementationCosting.manifest.json` to make City and Legion/Exile play complete through dignity, service, and self-made community rather than weaker Stronghold rewards.
4. **Redguard:** follow `PDV_Phase20RedguardImplementationCosting.manifest.json` to keep Crown, Forebear, and Ash'abah distinct beyond combat/death-duty.
5. **Bosmer/Khajiit:** follow `PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json` and `PDV_Phase20KhajiitImplementationCosting.manifest.json` to prove non-hunter Bosmer paths and behavior-specific Khajiit emphases with sharp, non-generic hooks.
6. **Stack-control:** keep Breton, Dunmer, Imperial, and Nord from becoming best-at-everything through dense or overlapping hook surfaces.
