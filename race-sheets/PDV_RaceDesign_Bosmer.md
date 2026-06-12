# PDV Race Design — Bosmer
**Last updated:** 2026-06-12
**Status:** Implementation locked for 1.0 experience shape; hook-costing and reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.7)
**Extended spec:** See references/PDV_BosmerPactModel_Planning.md for full Old Contract details.

---

## Religious Identity

Bosmer in Skyrim are operating without their enforcement context. The Green Pact, which Y'ffre made specifically with the Bosmer, is largely unenforced outside Valenwood — there are no Green Pact wardens checking whether a Bosmer in Whiterun ate a carrot. That absence of enforcement is itself theologically significant: the Bosmer in Skyrim has to decide whether the covenant is about the law or about the relationship with Y'ffre that the law represents.

This is what makes Bosmer the most path-divergent race in the mod. Four genuinely different answers to the same underlying question produce four genuinely different characters.

**Core design intent:** Bosmer should feel path-divergent rather than race-package-plus-patron. The path you choose at setup shapes your entire scoring logic. The four paths are not variations on a theme — they are different theologies, even though they share a cultural frame.

---

## Worship Structure

```
Bosmer choose among four devotional paths at setup:
  The Old Contract  — Y'ffre Orthodox (Green Pact compliance mechanic)
  The Living Story  — Y'ffre Moderate (community, story, secondary gods)
  The Exchange      — Z'en (reciprocal justice, debt, balance)
  The Bandit Road   — Baan Dar (exile survival, trickster, road-life)

Each path is a materially different experience
Broad worship cap: Tier 2 within your path
Tier 3 through focused commitment within the path
Path switching: limited, destination-sensitive, carries real cost
```

**Path implementation locks (LOCKED):** `PDV_State_BosmerPath` uses `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`. First-run setup should require a choice. If path state is unset or corrupt, fall back to `LivingStory` as the safest bridge path. `OldContract` path state remains separate from `PactBound`, `GreenPactCompliance`, and `LapsedFromPact`: path says the character is oriented toward the Old Contract, while `PactBound` says Y'ffre exclusivity is active. Non-Old-Contract path incoherence drifts toward `LivingStory`, not unset. Path switching is explicit and destination-gated; `LivingStory` is easiest to enter, `OldContract` hardest to re-enter.

**Path switching locks (LOCKED):** First-run path choice is free. Later switching is not a simple MCM toggle: MCM/status dialogue may record intent, but the world must confirm the destination through path-coded signals. `LivingStory` can be entered through one strong community/story signal and is the safe fallback. `Exchange` and `BanditRoad` require two destination-coded signals on separate in-game days within seven, evaluated at dawn, unless a major curated quest beat clearly proves the path. `OldContract` re-entry requires explicit recommitment, no terminal second renunciation, and three Pact-positive days within seven; on re-entry, `GreenPactCompliance` snaps to 30. Path deity ledgers are preserved, but only the active path gets full scoring, contextual favor, and Champion eligibility. After switching, automatic switching is locked for seven in-game days unless an authored major exception fires.

**Shared Green Pact memory (LOCKED):** Green Pact respect still matters for all Bosmer paths. Proper hunting, animal-sourced food, restraint around needless plant use where detectable, and respect for the living world can provide modest positive weighting for `LivingStory`, `Exchange`, and `BanditRoad`. Only `OldContract` carries the hard covenant burden: plant-use penalties, `GreenPactCompliance`, forced reckoning, Y'ffre exclusivity, and terminal renunciation. Other paths can be rewarded for honoring Bosmer inheritance, but they are not punished for failing Old Contract discipline. Implementation should use shared Bosmer signal weighting interpreted by the active path, not a hidden background Old Contract ledger.

**Secondary Bosmer religious layer (all paths):** Arkay, Xarxes, Mara, Stendarr — present as background influences, not core paths. These gods receive piety from appropriate acts across all Bosmer paths.

**External pressures — not core paths:** Hircine (hunt/shape/curse), Nocturnal (Guild criminal overlap). Neither is a normal Bosmer theological backbone.

---

## The Old Contract (Y'ffre Orthodox)

**The only Bosmer path with hard or semi-hard Green Pact compliance mechanics.**

### GreenPactCompliance State Model (LOCKED)

```
PactBound flag: binary — Y'ffre exclusive while true; all other Bosmer deity ledgers freeze (preserved, inert)
GreenPactCompliance meter: 0–100, act-driven, no passive decay

Bands (Y'ffre gain multiplier while PactBound):
  Apostate  (0–19)   : LOCKED — no Y'ffre gain; 3-day forced reckoning timer begins
  Lapsed    (20–49)  : 50% Y'ffre gain
  Observant (50–79)  : 100% Y'ffre gain
  Strict    (80–100) : 120% Y'ffre gain

Transitions:
  Entry       : setup choice OR MCM toggle + qualifying act
  Voluntary   : MCM Renounce, single confirmation
  Forced      : 3 in-game days at Apostate → Y'ffre confronts you with re-commit-or-renounce
  Re-entry    : permitted exactly once; GPC initializes at 20
  Terminal    : 2nd renunciation = Y'ffre ledger frozen permanently; toggle disables

Wild Hunt: lore context only. NOT a player-facing track or state.
```

**What raises GPC:**
- Eating non-plant food (meat, insects, fungi that are not technically plant matter — careful curation needed)
- Proper hunting conduct (animal kills with respect, no wanton slaughter)
- Avoiding plant-based consumables (potions with plant ingredients, cooked vegetable dishes)

**What lowers GPC:**
- Consuming plant-based food or drink
- Using plant-ingredient potions
- Working with wood in building or crafting contexts (this is the hard one — vanilla woodcutting and homestead building)

### Tier Rewards — Old Contract

**Tier 1 — Observant (GPC 50+):**
- Archery damage +3% (Y'ffre's hunter's eye)
- Poison resistance 15% (the Pact hunter knows which plants kill — stay away from all of them)
- One-handed damage +2% with daggers (hunting knife discipline)

**Tier 2 — Faithful (GPC 50+, sustained devotion):**
- Hunting kills (animals) restore minor stamina (the hunt provides)
- Animals never flee from you unprovoked (Y'ffre's children are recognized)
- GPC Strict (80+): 1.2x Y'ffre gain multiplier kicks in
- Y'ffre shrine interactions generate full piety (rare outside Valenwood; Kynareth shrines serve as proxy — see implementation notes)

**Tier 3 — Devoted (GPC 50+ maintained, full commitment):**
- *Champion moment:* Y'ffre's Mark — in outdoor/forest areas, archery damage +8% cumulative (Tier 1 + Devoted bonus). Animals never flee under any circumstances. First arrow fired in any hunt (on an animal not yet alerted) deals guaranteed bonus damage (the hunter's perfect shot). Hunting kills give a small chance to produce extra pelts/meat (Y'ffre's abundance from correct conduct).
- *The highest ceiling of any Bosmer path* — the Strict compliance burden is the payoff's justification.
- *Forced reckoning:* Three days at Apostate fires an explicit confrontation scene — this is the most dramatically surfaced neglect event in the mod. The player must choose. The second renunciation ends the path permanently.
- *Lore rationale:* The Old Contract is a covenant Y'ffre made with the Bosmer specifically. At Champion, it is fully honored and fully reciprocated. The beast-kin aspect of the contract means animals recognize you as part of the Green's order.

---

## The Living Story (Y'ffre Moderate)

**The bridge path. Accessible from almost any Bosmer playstyle. Community and oral tradition centered.**

This is not "Y'ffre-lite" and not failed orthodoxy. It's diaspora Bosmer spirituality — the form Y'ffre's covenant takes when the forest is not present to enforce it. The Living Story keeps the covenant alive through memory, community, and continued storytelling rather than strict compliance.

### Tier Rewards — The Living Story

**Tier 1 — Observant:**
- Speech +5% (the storyteller's gift)
- Outdoor stamina regen +5% (nature still provides, even without the Pact)
- Resist poison 10% (herbalists still know which plants to avoid)

**Tier 2 — Faithful:**
- Community-solidarity acts (helping NPCs preserve, protect, remember things) generate piety
- Secondary gods more active: Arkay generates piety from death-rite acts (death-rite quests give modest health regen for 2 hours); Xarxes from ancestry-adjacent choices (ancestor-research dialogue gives brief speech +5%); Mara from family/community content (family-restoration quests give minor health regen for 2 hours); Stendarr from mercy (choosing mercy in significant dialogue gives next persuasion attempt +10% chance)
- After helping preserve or protect a community or memory (quest-specific), +15% persuasion/intimidation chance on the next social check
- Nature-site visits (groves, standing stones, outdoor sanctuaries) generate modest Y'ffre piety
- ForestAttunement overlay: outdoor combat gives +5 armor rating (the forest's ambient protection)

**Tier 3 — Devoted:**
- *Champion moment:* Storyteller's Weight — at certain dialogue nodes involving memory, history, or community, special Tier 3 privilege options appear ("You can frame this as a story that people will carry forward" — diegetic privilege, not a power). After completing a quest that preserved something (a community, a tradition, a life), brief all-skills minor boost (24 hours). The secondary Bosmer gods all contribute at this tier — a Living Story Champion is genuinely multi-threaded.
- *Specific payoff:* Speech +10% cumulative (Tier 1 + Devoted bonus). Community-restoration quests give double piety. Nature sites generate stronger piety at this tier. The oral tradition privilege is the unique reward — no other path offers dialogue that frames your character as a carrier of cultural memory.
- *Lore rationale:* Y'ffre is the god of story and the Now — the force that holds the world's forms in place through narrative. At Champion, the Living Story path honors that by making you a carrier of the Story itself, even in exile.

---

## The Exchange (Z'en)

**Reciprocal justice, debt, and the rebalancing of what is owed.**

Z'en is the Bosmer god of payment in kind. Not revenge — balance. Not charity — proportionate return. The Exchange path is for Bosmer who believe the world should be even, that debts must be honored, and that sometimes collecting what is owed requires force.

### Tier Rewards — The Exchange

**Tier 1 — Observant:**
- Merchant prices marginally better (a fair exchange is what Z'en demands — and what you offer)
- Barter skill +5%
- After a successful combat against an enemy who attacked you or your allies first (not the aggressor yourself), minor health regen

**Tier 2 — Faithful:**
- After proportionate vengeance (quest completion that redressed a wrong), +10% weapon damage for 24 hours (Z'en's acknowledgment that the account is settled)
- Debt-settling acts — completing contracts you agreed to, paying debts, honoring promises — generate piety
- Proportionate trade (fair exchanges, not exploitative ones) generates modest piety; merchant prices -2% for 24 hours after each clean exchange
- Justice-facing quest choices (helping hold guards with legitimate arrests, mediating disputes correctly) score Z'en piety

**Tier 3 — Devoted:**
- *Champion moment:* Balance Restored — when completing a debt-settling, vengeance, or justice quest (the debt has been paid), brief boon fires: for 24 hours, one relevant skill receives +15% XP gain, reflecting Z'en's acknowledgment that the account is now clean. The *quality* of the restoration — whether it was proportionate, clean, deserved — should be reflected in the weight of the piety event.
- *Specific payoff:* Proportionate kill (after being attacked first, defending correctly) gives minor stamina regen per kill. Commerce with honest merchants gives brief speech boost for next major check. Z'en recognition dialogue in merchant and justice contexts (specific NPCs respond with "there's someone who understands fair trade").
- *Lore rationale:* Z'en teaches that the universe runs on exchange — nothing is free, everything has a price, and debts are sacred. At Champion, the Exchange Bosmer has internalized this so deeply that the world's balances respond to them.

---

## The Bandit Road (Baan Dar)

**Exile survival, trickster cunning, road-life improvisation.**

Baan Dar is the Bosmer-native survival trickster. Not the polished criminal mystique of Nocturnal — the desperate cleverness of the exile making do. The Bandit Road is for Bosmer who left the Green, or never fully joined it, and found their theology on the road with other people who had nowhere to go.

### Tier Rewards — The Bandit Road

**Tier 1 — Observant:**
- Pickpocket +5%
- Sneak +3%
- After sleeping outdoors (road life), next day's first stealth encounter has slightly better detection threshold

**Tier 2 — Faithful:**
- After surviving against severe odds (combat, trapped situation, outnumbered), +40 stamina immediately and +10 stamina/sec regen for 30 seconds
- Road-life acts (sleeping outdoors, traveling between areas without using inns, surviving in harsh conditions) generate piety
- Exile/outsider NPCs more favorable — roadside wanderers, refugees, other pariahs respond with friendlier dialogue and 5% better barter prices
- Baan Dar's network: after successfully pickpocketing a high-value target, +15% movement speed for 30 seconds (get out while you can)

**Tier 3 — Devoted:**
- *Champion moment:* Baan Dar's Luck — once per in-game week, surviving near-death combat (below 10% health and winning, or escaping an encounter designed to be impossible) gives a 24-hour bonus pulse: minor stats across the board, but more importantly, Baan Dar is acknowledged to have interceded. This should feel like the story Bosmer tell around fires about the one time they shouldn't have survived. Not a power — a narrative beat made mechanical.
- *Specific payoff:* Operating outside city walls (in the wilderness, on roads, in smaller settlements) gives slightly stronger piety than equivalent acts inside hold capitals — Baan Dar's territory. After a successful survival of a very difficult encounter, speech with other exile/road NPCs improves briefly. Pariah solidarity — helping other outcasts or road-folk generates strong Baan Dar piety.
- *Lore rationale:* Baan Dar is the patron of outcasts, clever exiles, and the people who survived by not being where power was looking. At Champion, the Bandit Road Bosmer is the character in the story about the time they shouldn't have made it. Baan Dar writes those stories.

---

## Signature Friction

**Path identity is the primary friction for all Bosmer.** You made a choice at setup, and the game holds you to it — not by blocking you from other content, but by the fact that your scoring logic rewards your path's specific behaviors. A Bandit Road player who starts accumulating wealth and civic standing is scoring very few Baan Dar signals. A Living Story player who never helps anyone preserve anything is letting their path go quiet.

**Old Contract specific:** Green Pact compliance is the most mechanically demanding friction in the mod. Every plant-based potion choice, every piece of food, potentially every woodcutting act, is a theological decision. For a game where alchemy and plant consumption are pervasive, this is *real* friction. Players who want the highest Bosmer ceiling have to pay attention to what they consume at every turn.

**Forced reckoning moment:** Three consecutive in-game days at Apostate GPC → Y'ffre confronts you with a choice. This is not a gradual fade — it's a designed scene. The neglect system has a dramatic climax point unique in the mod.

**Path switching cost:** Limited, destination-sensitive, requires meaningful threshold events. You don't casually switch from Old Contract to Living Story. The Living Story is the easiest bridge; the Old Contract is the hardest to re-enter.

---

## Neglect Texture

- **Old Contract:** Apostate band's three-day timer IS the neglect texture. You know it's running. Y'ffre is waiting. The forced reckoning scene is the most dramatically surfaced neglect event in the entire mod — designed, not ambient.
- **Living Story:** The oral tradition dries up. Community signals that were generating piety stop firing because you stopped engaging with community. The secondary gods (Arkay, Xarxes, Mara, Stendarr) go quiet one by one as their respective acts disappear from your play. Y'ffre's presence becomes background noise.
- **Exchange:** Unpaid debts accumulate without recognition. Unjust acts (attacking first, breaking agreements) generate implicit Z'en-displeasure (possibly minor negative piety). The justice of the world starts ignoring you — no bonus on proportionate acts, no clean satisfaction at debt-settling.
- **Bandit Road:** Baan Dar's luck goes dormant. When you survive near-death by skill and not by luck, you notice the absence of the one time Baan Dar should have interceded. The weekly luck window passes without firing. The pariah solidarity bonus fades. Road life without Baan Dar's favor is just poverty.

---

## Signal Examples

| Path | Action | Cadence | Notes |
|------|--------|---------|-------|
| Old Contract | Eat meat/animal-sourced food | GPC positive | Anti-farm: each meal type per day |
| Old Contract | Eat plant-based food or use plant potion | GPC negative | Per consumption act |
| Old Contract | Kill an animal in proper hunting context | +piety | Daily cap; sneak or first-arrow only counts as "hunt" |
| Living Story | Help NPC preserve something (community, memory, life) | +piety | Quest-specific; can't be trivial help |
| Living Story | Nature-site visit (grove, standing stone, outdoor sanctuary) | +piety | Per site, daily cap |
| Living Story | Help a grieving NPC or complete a burial-related quest | +piety (Arkay) | Death-rite adjacent |
| Exchange | Complete a quest that redresses a wrong | +piety (major) | Proportionate vengeance specifically |
| Exchange | Honor a promise or contract under pressure | +piety | Pledge-keeping acts |
| Exchange | Attack an enemy who attacked your allies first | +piety | Not aggressor; defender |
| Bandit Road | Sleep outdoors | +piety | Daily cap; same as Khajiit road signal |
| Bandit Road | Survive combat while severely outnumbered | +piety | Outnumbered 3+ or heavily outleveled |
| Bandit Road | Successful pickpocket from notable target | +piety | Notable target: named, wealthy, or story-relevant |
| All | Y'ffre / relevant shrine interaction | +piety | Kynareth shrine serves as Y'ffre proxy (see below) |
| All (secondary) | Death-rite quest completion | +piety (Arkay) | Small; all paths have secondary layer |

---

## Implementation Notes

**Vanilla hook surface:** Moderate to sparse. Bosmer-specific content in Skyrim is limited — few Bosmer NPCs, no dedicated Bosmer community. Heavy reliance on cross-content signals (hunting, theft, justice quests, outdoor lifestyle). Y'ffre has no shrine in Skyrim — Kynareth shrines serve as the proxy (Kynareth is the Imperial name for roughly the same nature-patroness; this is lore-defensible enough).

**Complexity flags:**
- **GreenPactCompliance tagging:** PDV needs to own a tag system for plant-based consumables. This requires either a keyword list applied to relevant FormIDs or a manual curation list. Plant potions, plant-based food, and potentially wood/lumber items need tags. This is the most significant custom work on the Bosmer sheet.
- **Forced reckoning scene:** One-time dialogue event triggered after 3 consecutive in-game days at Apostate GPC. Requires a running day-counter in the Apostate state. The scene needs localized dialogue for Bosmer that feels like Y'ffre actually confronting you — not a generic popup. Medium custom content, high impact.
- **Proportionate vengeance detection (Exchange):** Hardest Exchange signal to implement. "Attacked first" can be checked via Story Manager kill data (was the killed actor hostile before the player engaged?). "Proportionate" is harder — limit to quest-completion events where the quest involved a wrongdoer rather than trying to assess proportionality at fight-time.
- **Baan Dar's luck:** Weekly cap + near-death health threshold + winning condition. Requires tracking health floor during combat and checking outcome. Low-complexity script; medium-complexity trigger condition (needs to distinguish "escaped" from "died and loaded").
- **Path switching:** Requires explicit state-management logic in the MCM. The destination-sensitivity (Living Story is easy bridge, Old Contract is hardest to re-enter) needs a per-destination check on what threshold event qualifies. This is design-complete but implementation-nontrival.

**Cost class profile:**
- Hunting kill signals: Cost Class A (Story Manager kill events)
- GPC consumption tracking: Cost Class B-C (requires consumable tagging pass)
- Proportionate vengeance: Cost Class B (quest-completion event + aggressor-check)
- Forced reckoning: Cost Class C (custom content + timer)
- Baan Dar luck trigger: Cost Class B (health-threshold event tracking)

### Implementation acceptance criteria (content review, 2026-06-01)

Derived from the LOCKED rules above; these are pass/fail checks for when the Papyrus layer is authored.

- **Path onboarding has a safe default, not a hard block.** First-run setup requires an explicit path choice, but if `PDV_State_BosmerPath` is ever unset or corrupt it must resolve to `LivingStory` (= 1), never to an unset/limbo state. Non-Old-Contract path incoherence drifts to `LivingStory`, not unset. (Source: "Path implementation locks (LOCKED)".)
- **Green Pact compliance is Old-Contract-only.** The `GreenPactCompliance` meter, plant-consumption penalties, the `PlantConsumed` notification, the Apostate forced-reckoning timer, and Y'ffre exclusivity must fire **only** when `PDV_State_BosmerPath == OldContract` (= 0). On `LivingStory`, `Exchange`, and `BanditRoad`, honoring Bosmer inheritance may give modest positive weighting but plant use carries **zero** penalty. Implementation must read shared Bosmer signals interpreted by the active path — **not** a hidden background Old Contract ledger. (Source: "Shared Green Pact memory (LOCKED)"; Signal Examples friction table.)

---

## Variety Tranche — "The Story Goes On" (DESIGN-LOCKED 2026-06-12)

Roadmap source: `references/authoring/PDV_RaceVarietyTranche_Roadmap.md`.
Purpose: bring Living Story, Exchange, and Bandit Road felt-beat density up to
the Old Contract baseline. All five mechanics are path-gated by
`PDV_State_BosmerPath`; none add Old Contract burden to other paths (the
shared-Pact-memory lock holds). Magnitudes are tunable; shapes, gates, caps,
and fade rules are locked. Effect families remain blocked behind the race row
in `PDV_RaceEffectReviewLedger.md` before any record authoring.

**Green Dreams (all paths).** Sleep dreams keyed to the active path; Old
Contract dreams additionally key to the GPC band. Living Story dreams retell
recent quests as Story fragments; Exchange dreams weigh unsettled debts;
Bandit Road dreams are road-fire stories. Argonian dream-roller cadence:
~8-12% per sleep, 2-day floor, elevated chance the night after a path change
(or, Old Contract, a band change). Top-left lines only.

**Hearth of the Telling (Living Story only).** Cell-keyed declaration of a
community hearth (inn or home), prompted at sleep-stop; declining re-prompts
after 3 in-game days. Sleeping in the declared hearth after discovering 3+
new locations since the last stay grants `A Tale Carried` (Speech +5,
10 min) — the story was brought home and told. Anti-farm is the
location-discovery delta, not sleep count.

**Path signatures (once/day, Quiet surfacing).**
- Exchange — `Scales at Rest`: completing any favor/bounty/contract quest
  grants a brief barter pulse.
- Bandit Road — `Baan Dar Opens the Gap`: dropping below 20% health in
  combat grants a ~5s movement burst (escape texture; deliberately distinct
  from the weekly Champion luck moment, which stays rare).
- Old Contract gets no new signature — it is already the richest path.
- Cross-race note: Khajiit carries a trigger-distinct Baan Dar signature
  (`Baan Dar's Improvisation`, survive-outnumbered). Both are intentional;
  the pairing is documented in the roadmap's resolved decisions.

**Songs of the Green (all paths).** Six curated green sites; first arrival
each = one vision line + small Y'ffre/path pulse; all six = milestone
MessageBox. Locked set: the Gildergreen (Whiterun), Kynesgrove's grove,
Eldergleam Sanctuary, Evergreen Grove, Clearspring Tarn, Autumnshade
Clearing. Eldergleam is intentionally shared with the Argonian Waters set
under the shared-site rule: shared LCTNs are allowed with race-distinct
vision text. One-shot forever, anti-farm by design.

**The Naming (rite).** At the declared hearth or any Songs site, 7-day
cooldown, "Not yet" does not spend the cooldown. Y'ffre told the Bosmer
their forms; the diaspora Bosmer retells their own. One-active told-self:
Hunter (+5 archery), Speaker (+5 speech), Wanderer (+8% stamina regen),
Keeper (+5% barter); choosing again swaps (clear-before-add). Fades at dawn
on path-coherence break (path switch, or Apostate band while Old Contract);
returns automatically at dawn on recovery.

---

## Curse State Summary

**Vampire (all paths):**
- Harder theological break than werewolfism across all Bosmer paths
- Old Contract: PactBound breaks immediately — the living covenant does not extend to the undead; Y'ffre is closed
- Living Story / Exchange / Bandit Road: significant strain but not complete collapse; the theology is more flexible about edge cases

**Werewolf by path:**
```
Old Contract:
  Serious theological violation — Hircine provides an illicit rival route to shapeshifting
  Echoes the Wild Hunt without Y'ffre's sanction
  GreenPactCompliance mechanics continue to run but gaining compliance is harder

Living Story / Exchange / Bandit Road:
  Contested strain rather than automatic collapse
  Same general treatment across these three routes
  Werewolfism is not welcomed but is not theologically annihilating
  The Wild Hunt linkage makes it intelligible — not orthodox, not approved, but intelligible
```

Lore rationale: The wild hunt linkage makes werewolfism intelligible to Bosmer theology in a way it isn't for Imperials or Altmer. It does not make it Green Pact-approved or Y'ffre-sanctioned. The Old Contract is the path with the hardest response — it's the path that takes the covenant most literally.
