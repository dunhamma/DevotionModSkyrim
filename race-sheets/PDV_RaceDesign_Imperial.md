# PDV Race Design — Imperial
**Last updated:** 2026-05-19
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.2)

---

## 2026-07-13 Progression Contract Addendum

This addendum supersedes later civic-count and route-magnitude language. The
Imperial Divines broad lane is a deity-signal pool: the Eight Divines qualify
immediately and Talos joins only after explicit stance, prayer, or defiance.
`The Divines' Regard` is highest-slot-only and caps at two tiers: Seeker grants
Poison Resist 10%; Faithful grants Poison Resist 10% plus Disease Resist 10%.

Imperial civic practice is a separate substrate. The first authentic civic act
in each 06:00 devotional day grants `+4` toward `1/25/75`; later acts grant zero.
Eligible renewable routes are Divine prayer and the first completed Smithing,
Enchanting, or Alchemy work of the day. Generic sleep and automatic Talos piety
are rejected. Vampire onset resets the metric to zero and blocks civic and
broad gains; cure seeds 20 once. Visible tiers are `Civic Steadiness`, `Civic
Discipline`, and `Civic Exemplar`.

At deity piety 50, accepting a patron preserves piety, suppresses the broad
boon, and begins focused T2. Focused T1 is compatibility-only; T3 begins at 85.
`references/authoring/PDV_BroadPantheonContracts.json` and
`PDV_SubstratePacingContracts.json` are authoritative.

## Religious Identity

Imperials are the civic face of the Nine Divines — their religion is institutional, public, and politically entangled in a way no other race's is. The White-Gold Concordat has split Imperial theology into a wound that won't close: enforcing the Talos ban means betraying the man who unified the Empire and made the Divines a legal institution; defying it means choosing personal conscience over the civic order that Imperials built their identity around.

An Imperial's religion is never just about their soul. It's always also about their role.

**Core design intent:** Imperial devotion should feel politically and socially split, with theology shaped by compliance or conscience. The ConcordatStanding track is the signature mechanic — it's running under every Imperial Nine Divines relationship whether the player notices or not.

---

## Worship Structure

```
No baseline choice required — one pantheon (Nine Divines)
Broad worship begins automatically at game start
Cap: Tier 2 (Faithful) — civic observance is culturally normal for Imperials
Tier 3 only through primary god commitment (same offer system as Nord)

ConcordatStanding track runs simultaneously:
  Affects Talos devotion directly
  Affects Arkay and Stendarr at extreme states
  Does NOT affect other Divines
```

**Available primary gods:** All Nine Divines (Akatosh, Talos, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella).

**Implementation state (LOCKED):** Imperial broad vs primary commitment uses shared patron state, not `PDV_State_ImperialWorship`. Imperial-specific pressure lives in `PDV_RepTrack_ConcordatStanding`.

**Offer-gate rule (LOCKED):** Imperial uses the global formal patron-offer gate: dawn-only evaluation, `50` persistent piety by default, qualifying signal activity on at least two separate in-game days within the last seven days, per-deity cooldowns, no persistent offer queue, and stable accepted patron in 1.0.

**Broad worship contextual favors:** Imperial broad worship should feel civic and institutional rather than mythic. The lane is led by civic acts, while institutional places amplify or surface the result when Skyrim exposes a clean hook.

## Contextual Favor Pilot Table

**Status:** Pilot cleared (2026-05-18 cross-pilot pass)

**Pilot scope:** Broad-worship lane only. Focused patron tables wait until the broad-lane pilot clears review.

**User-experience proof:** Imperial broad worship should feel like public duty under pressure: temples, law, burial, mercy, honest exchange, and the Concordat all make faith visible. It is civic and institutional, not Nord mythic-deed breadth and not Redguard sect obligation.

**Institutional amplification rule:** Imperial favors are led by civic acts, not by standing in buildings. Temples, shrines, Halls of the Dead, courts, Legion spaces, and official factions should amplify, recognize, or cleanly hook the act when Skyrim exposes them.

**Concordat favor rule:** Concordat compliance may move `ConcordatStanding`, alter access, and qualify Akatosh/civic-order favor when the authored act is genuinely order-preserving. It does not trigger Talos contextual favor. Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence.

**Lawful order favor rule:** Legion allegiance, court status, and official faction state may provide scoring context, but they do not trigger contextual favor by themselves. Favor requires a concrete public-service or order-preserving act, and the act must not be cruelty disguised as order.

**Mercy/restraint favor rule:** Bounty payment is not a generic favor trigger. It counts only when authored as preventing harm or resolving a real civic conflict; ordinary pay-bounty menu interactions do not trigger favor.

**Offer eligibility locks (LOCKED):** Talos offers normally require `Uncommitted`, `Private Defiant`, or `Open Defiant`. `Public Compliant` and `Concordat Enforcer` block Talos offers unless a fresh costly-defiance rupture signal is authored. `Public Compliant` and `Concordat Enforcer` may amplify Akatosh / Zenithar civic-order offer eligibility through genuinely order-preserving or honest civic acts, but never through cruelty or Talos compliance. `Private Defiant` Talos offers surface privately; `Uncommitted` leaves all Nine Divines eligibility neutral, including Talos, when real god-specific signals exist.

**Talos rupture acceptance (LOCKED):** Accepting a Talos offer after a costly-defiance rupture immediately moves a compliant Imperial at least to `Private Defiant`. Hidden or private rupture moves to `Private Defiant`; public or high-risk authored rupture may move to `Open Defiant`. Accepting Talos cannot leave the character publicly theologically compliant.

**Civic offer amplification (LOCKED):** `Public Compliant` and `Concordat Enforcer` may amplify Akatosh / Zenithar offer priority through recent signal strength, not by lowering the global `50` offer threshold. Amplification requires genuinely order-preserving, public-service, or honest civic-exchange acts and never applies to Talos or cruelty.

**Enforcer repair gate (LOCKED):** `Concordat Enforcer` dampens Stendarr and Arkay offer eligibility unless the player has recent mercy or death-rite repair signals such as prisoner protection, mercy under pressure, burial restoration, or anti-necromancer duty.

**In-game hook cross-check:** Imperial is buildable for 1.0 if contextual favor is led by curated civic acts rather than ambient institutions. Strong hooks: Hall of the Dead / Arkay quest stages, necromancer and undead operation clears, Talos shrine/worshipper/Thalmor quest stages, Legion and hold-service milestones, marriage/community-restoration milestones, skill-book reads, and faction/quest-stage rows that already express public duty. Medium hooks: mercy/restraint, lawful dispute resolution, and honest commerce need curated dialogue/quest conditions or value thresholds. Rejected launch hooks: ordinary bounty payment, generic temple attendance, raw faction membership, generic anti-Thalmor violence, and compliance framed as cruelty.

**Build-facing hook table (working lock):**

| Experience target | 1.0 hook candidate | Confidence | Implementation posture |
|---|---|---|---|
| Mercy and restraint under civic pressure | Curated spare/surrender/prevent-harm dialogue outcomes, prisoner release quest stages, authored conflict resolution | Medium | Whitelist meaningful outcomes; ordinary pay-bounty menu interactions do not trigger favor |
| Burial duty and death-order maintenance | Hall of the Dead / Arkay quest stages, Arkay priest/shrine interactions, necromancer operation completion, undead boss/location clear | Strong | One of the cleanest launch surfaces; per quest/site with repeat protection |
| Lawful order and public service | Legion public-service quest stages, hold aid/thane beats, lawful dispute resolution, dragon/public-safety milestones | Medium-strong | Faction state is context only; favor requires a concrete order-preserving act |
| Honest work and civic exchange | Meaningful crafting result, selling non-stolen goods above threshold, merchant/trade quest stages, honored contract/payment completion | Medium | Use quality/value filters and curated rows; no raw craft-count or gold-farming loop |
| Public/private Talos pressure | Hidden Talos shrine activation, help/refuse/report worshipper choices, Thalmor/Talos quest stages, ConcordatStanding updates | Medium-strong | Talos favor only from faithful defiance. Compliance may move standing or civic scoring, never Talos favor. |
| Enforcer repair | Recent prisoner protection, mercy under pressure, burial restoration, anti-necromancer duty | Medium | Unlocks or restores Stendarr/Arkay offer eligibility for Enforcer states; authored repair signals only |

### Broad Nine Divines

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Broad Nine Divines | Mercy and restraint under civic pressure | Mercy/restraint dialogue outcomes; surrender/spare hooks where reliable; authored prevent-harm bounty/conflict resolutions; prisoner release quest stages | Momentary combat / After-act | Quiet / Noted | Stendarr-coded steadiness. Requires meaningful pressure; generic pay-bounty menu interactions do not trigger favor. |
| Broad Nine Divines | Burial duty and death-order maintenance | Hall of the Dead quests; Arkay priest or shrine interactions; necromancer operation completion; undead boss/location-clear events | After-act | Noted | Arkay-coded rest, disease/undead protection, or institutional recognition. One of the strongest clean vanilla hook families. |
| Broad Nine Divines | Lawful order and public service | Specific Imperial Legion public-service quest stages; thane/hold aid stages; lawful dispute resolution; dragon-order/public safety beats | After-act | Noted | Akatosh/civic-order stability. Allegiance alone is context/scoring, not a favor trigger. Reward concrete order-preserving acts, not blind obedience or generic faction grinding. |
| Broad Nine Divines | Honest work and civic exchange | Meaningful crafting completion; merchant/trade quest stages; selling non-stolen goods above value threshold; work/contract completion where the bargain was honored | After-act | Quiet | Zenithar-coded commerce steadiness. Needs quality/value or curated quest filters; raw craft-count scoring is rejected. |
| Broad Nine Divines | Public/private Talos pressure | Hidden Talos shrine activation; help/refuse-to-report Talos worshipper; report/ban-enforcement choices as ConcordatStanding signals; Thalmor/Talos quest stages | After-act | Noted / Marked if high-cost | Talos favor only for authored faithful defiance, not generic rebellion. Compliance may move ConcordatStanding but should not trigger Talos favor. |

**Focused contrast note:** Focused patron design should later sharpen one civic virtue into a personal relationship. Focused Stendarr makes mercy protective; focused Arkay makes death-order sacred; focused Talos makes conscience against law costly and personal. Broad Imperial worship remains public, institutional, and capped at Faithful.

Final trigger selection depends on usable hooks: quest stages, shrine/Hall of the Dead interactions, dialogue choices, faction states, and curated story events before ambient inference.

---

## ConcordatStanding Track

This is the Imperial's signature mechanic and should be understood before the tier rewards.

```
ConcordatStanding: -100 to +100 (starts at 0, Uncommitted)

Open Defiant     (-100 to -76): Talos shift x1.5, starts at piety 60; Thalmor actively hunt player
Private Defiant  (-75 to -51):  Talos shift x1.25, starts at piety 55; Thalmor suspicious, occasional checks
Uncommitted      (-50 to +50):  Talos shift x1.0, starts at piety 50; Thalmor ignore player [WIDE BAND — intentional]
Public Compliant (+51 to +75):  Talos shift x0.75, starts at piety 45; Thalmor friendly
Concordat Enforcer (+76 to +100): Talos shift x0.5, starts at piety 35; Thalmor allied
```

**Talos commitment gate (LOCKED):** Full Talos primary commitment is normally available only in Uncommitted, Private Defiant, and Open Defiant states. Public Compliant and Concordat Enforcer block Talos offers unless a fresh costly-defiance rupture signal is authored. High Concordat compliance has a real theological cost, but a costly act of conscience can still open the door.

**Secondary modifiers at extreme states:**
- Concordat Enforcer (>+50): Arkay -15% daily shift (mass graves, inadequate death rites enabled), Stendarr -15% daily shift (mercy incompatible with active persecution)
- Open Defiant (<-50): Stendarr +15% daily shift (active resistance = merciful act); Arkay unaffected (death rites transcend politics)

| Action | Points |
|--------|--------|
| Find / activate hidden Talos shrine | -15 |
| Help Talos worshipper escape Thalmor | -15 |
| Kill Thalmor Justiciar (unprovoked) | -10 |
| Side with Stormcloaks | -20 |
| Refuse to report Talos worshipper | -5 |
| Publicly observe Talos ban | +5 |
| Report Talos worshipper to Thalmor | +15 |
| Attack Talos worshipper | +15 |
| Side with Imperial Legion | +10 |
| Escort Thalmor prisoner | +10 |

---

## Tier Rewards

### Tier 1 — Observant
*Sincere civic faith. Small blessings appropriate to each Divine's domain.*

| God | Tier 1 Blessing |
|-----|----------------|
| Akatosh | Time-pressure checks (lockpicking, persuasion) slightly more forgiving; resist dragon breath 5% |
| Talos | Shout recharge speed +5%; civil war content scores modestly regardless of Concordat state |
| Kynareth | Minor cold/storm resistance 10%; outdoor stamina regen +5% |
| Mara | Healing spells 5% more effective; vendor prices slightly better (compassionate presence) |
| Zenithar | Crafting XP +5%; honest commerce generates piety |
| Arkay | Resist disease 10%; undead deal 5% less damage |
| Stendarr | Brawl damage +5%; Vigilants of Stendarr are neutral |
| Julianos | Spell cost -3% (Novice/Apprentice) |
| Dibella | Speech +5%; favorable first impressions with new NPCs |

### Tier 2 — Faithful
*Stable civic relationship. The god's domain actively supports your civic role.*

| God | Tier 2 Blessing (adds to Tier 1) |
|-----|----------------------------------|
| Akatosh | Long devotion streaks give cumulative bonus piety; dragon-order content (Blades, dragonslaying) scores strongly; order-preservation quest choices generate piety |
| Talos | At Private Defiant: Talos shrines give enhanced blessing; hidden worship generates extra piety. At Open Defiant: an additional 1.25x multiplier applies. Civil war content scores double at this tier. |
| Kynareth | Outdoor sleep restores stamina fully; Kynareth shrine cleansing fully restores health |
| Mara | Marriage and household content generates devotion; community restoration quests score strongly; Temple of Mara gives recognition (healing discount) |
| Zenithar | After completing a major crafting project, next commerce check has favorable odds; quality work is acknowledged by relevant NPCs |
| Arkay | Death-rite quests (Hall of the Dead, burial, anti-necromancer) give next rest a full health restore; undead deal 10% less damage |
| Stendarr | After choosing mercy in dialogue, next combat has armor rating boost; Vigilants treat you as a peer |
| Julianos | Skill book reading generates piety; College-adjacent and law-adjacent content scores |
| Dibella | After persuasion success, next social check has near-automatic minor success; Bards' College content generates piety |

### Tier 3 — Devoted (primary patron only)
*This Divine knows your name. The relationship is personal — and politically costly to maintain.*

| God | Champion Moment + Tier 3 Blessing |
|-----|-----------------------------------|
| **Akatosh** | *Order held across time.* Long unbroken devotion streaks (14+ days) give a capped bonus (+15% skill XP for entire period). Amulet of Akatosh grants double vanilla effect. Dragon-soul-adjacent content gives privilege dialogue. The Empire's god of time recognizes a servant who has not wavered. |
| **Talos** | *Faith held against the law.* Shout recharge +15% total. In Stormcloak zones or after major defiance acts, brief stamina/health regen surge. At Open Defiant standing: Thalmor encounters flag you as a known defier (dialogue trigger). Defiant worship at hidden shrines generates maximum piety at this tier. This Champion is built on the gap between civic obedience and personal faith — the mod should surface that clearly when the offer fires. |
| **Kynareth** | *Wind-granted passage.* In outdoor combat during storm/rain, power attacks -10% stamina cost. Outdoor sleep removes all exposure penalty (Survival Mode). Animals are fully neutral. Kynareth's speed: in open outdoor terrain, sprinting stamina drain -10%. The sense of being welcomed by the outdoors is the payoff, not raw stats. |
| **Mara** | *The mother of the people.* After helping a family or community (reuniting, protecting, restoring), next rest heals to full. Temple of Mara gives maximum recognition (special dialogue, free healing access once per week). Marriage grants a permanent minor companion healing boost. Community-restoration quests give double piety at this tier. |
| **Zenithar** | *Honest work sanctified.* Crafted items have a small chance to produce exceptional quality (one step above perk level). After honest commerce with non-hostile vendors, brief speech boost for next major persuasion check. Temple of Zenithar recognition (trade discounts, merchant-class dialogue). |
| **Arkay** | *Death-covenant observed.* Undead deal 20% less damage. After completing a death-rite quest, next rest restores full health. Hall of the Dead priests treat you with recognition privilege (special dialogue, cleansing access). Necromantic Raise Dead used near you has a higher failure rate (passive disturbance, not a player power). |
| **Stendarr** | *Mercy as armor.* After sparing a surrendering enemy, brief damage resist (15%) for remainder of fight. Vigilants of Stendarr treat you as a peer (quest access, recognition dialogue). Against Daedra and undead, bonus damage when your recent record shows restraint. The Champion who earned Stendarr's recognition while at Open Defiant ConcordatStanding is a specific type — mercy in defiance rather than mercy in compliance. |
| **Julianos** | *Wisdom applied.* Spell cost -8% all schools. After reaching a new magic skill rank, next cast of that school is free. College of Winterhold recognition privilege. Legal and judicial quest content generates strong piety. |
| **Dibella** | *Beauty as civic grace.* After a major persuasion or performance success, next equivalent social check succeeds automatically (once per day). Temple of Dibella recognition (reduced costs, quest access). Bards' College gives special dialogue at this tier. |

---

## Signature Friction

**The Concordat is always running.** An Imperial player cannot be religiously neutral — their ConcordatStanding is accumulating or decaying from every major political choice they make. The friction isn't imposed by the mod directly; it's inherent in Skyrim's civil war and Thalmor systems. Every time the Thalmor approach, every time a Talos worshipper needs help, every time the civil war questline asks for allegiance — there's a theological decision inside the gameplay choice.

**Specific friction surfaces:**
- **The Talos commitment gate:** Wanting to be a Talos Champion while sitting at Public Compliant or Concordat Enforcer is normally blocked. A fresh costly-defiance rupture can open the door, but the mod still forces you to live with the cost of your political positioning.
- **Imperial vampire rupture:** Vampirism breaks Imperial civic theology completely (see Curse States). There's no hedging around this — the Nine Divines path simply halts. Cure and re-entry matters, but the floor drops.
- **Mass grave theology:** An Imperial who sided hard with the Legion and enabled the worst aspects of the war finds Arkay and Stendarr costing them piety at extreme Enforcer states. The civic religion judges its own failures.

---

## Neglect Texture

Imperial neglect should feel like **civic hollowness** — the institutional religion becomes mere performance.

- **Arkay neglect:** In a war-torn province full of improper dead, letting burial obligations slide means the death-rites feel perfunctory. Shrines feel like architecture.
- **Stendarr neglect:** Choosing persecution over mercy repeatedly doesn't generate Stendarr piety at all, and eventually mercy-adjacent opportunities feel like they've dried up.
- **Talos neglect:** If you let the relationship with the old faith go cold while at Private Defiant, it doesn't punish — but the shouts become purely technical again, and the hidden shrines stop generating that small surge of meaning.
- **General neglect:** The Nine Divines are a system. When you stop feeding the system — no quests completed for the temples, no death rites observed, no civic acts — it becomes bureaucratic in texture. The gods are still there, but they feel like institutions rather than relationships.

---

## Signal Examples

| Action | God(s) | Cadence | Notes |
|--------|--------|---------|-------|
| Complete a Hall of the Dead quest | Arkay | Per quest (one per hold) | One of the cleanest signals in the game |
| Defeat a necromancer and clear their operation | Arkay | Per operation, cooldown | Strong one-time per site |
| Choose mercy in a dialogue (let enemy go, pay bounty, etc.) | Stendarr | Per act, daily cap | Filter high-stakes from trivial — "let enemy flee" vs "pay 10 gold" |
| Help an NPC family or community restore itself | Mara | Per quest beat | Marriage generates one-time major + smaller ongoing |
| Donate to a temple | Any matching god | Daily cap | Anti-farm: diminishing returns after first donation/day |
| Complete a major crafting order or project | Zenithar | Daily cap | Quality filter needed — not every iron dagger |
| Read *The Talos Mistake* | Public Talos | One-time | Concordat-aligned text as conscience-under-pressure signal; notification: `PDV_Notif_Imperial_FavorNoted_TalosPressure_BookRead_TalosMistake` |
| Win a major persuasion check (not trivial) | Dibella, Julianos | Per check, cooldown | Threshold: only "hard" or above check difficulty |
| Activate hidden Talos shrine | Talos + ConcordatStanding -15 | Per shrine (one-time each) | Strong signal; rare enough to not need daily cap |
| Help Talos worshipper escape Thalmor | Talos + ConcordatStanding -15 | Per event | Quest-driven; naturally limited |
| Report Talos worshipper | ConcordatStanding +15 | Per event | The other side of the track |
| Side with Imperial Legion (quest stages) | Akatosh, ConcordatStanding +10 | Per major beat | Heavy one-time weight |
| Dragon kill (with intent, not trivial) | Akatosh | Per kill, cooldown | Main quest and dragon encounter content |
| Observe sunrise or major Akatosh-adjacent ritual | Akatosh | Daily cap | Viable via shrine interaction at dawn |

---

## Implementation Notes

**Vanilla hook surface:** Strong. Nine Divines have shrines throughout Skyrim, Hall of the Dead quests exist in every major hold, and the Civil War / Thalmor faction systems are well-defined for signal extraction.

**Complexity flags:**
- **ConcordatStanding track:** Architecturally ready — uses the same `PDV_ReputationTrack` pattern proven for the Breton Altmer tracks. Key complexity is in the action table: make sure every major political quest beat hits the track correctly, and that the Thalmor hostility layer doesn't conflict with vanilla Thalmor faction state.
- **Talos primary commitment gate:** Requires reading ConcordatStanding at the time the offer fires. If player is in Public Compliant or Enforcer without a fresh costly-defiance rupture signal, the offer simply doesn't appear for Talos. Important: the offer system should fail gracefully — the player shouldn't notice "I should have gotten a Talos offer but didn't" — it should feel like Talos hasn't noticed them yet rather than "the mod blocked me."
- **Extreme-state secondary modifiers (Arkay/Stendarr):** Minor complexity but easy to get wrong. These are modifier-adjustments in the dawn pipeline, not new event systems. Well-documented in the architecture reference.
- **Imperial vampire rupture:** The halt (not just reduction) of Divine devotion on vampirism requires a clean state-check in ProcessDawn. The cure re-entry (lowered floor, not full restoration) needs one-time state tracking.

**Cost class profile:**
- Hall of the Dead / burial / death-rite quests: Cost Class A (quest completion events)
- Mercy/restraint dialogue choices: Cost Class B (requires dialogue condition filtering)
- ConcordatStanding track updates: Cost Class A (curated signal points on specific actions)
- Talos commitment gate: Cost Class B (dawn-slot offer evaluation with standing check)

---

## Curse State Summary

**Vampire:**
- Imperial Divine devotion halts entirely — not reduced, stopped
- ConcordatStanding no longer matters religiously while active
- Molag Bal or a "civic-shadow" survival reading becomes the only viable theological substitute
- On cure: Divine devotion resumes at a lowered starting floor; no automatic restoration of prior tier
- Lore rationale: Imperial religion is civic infrastructure. Vampirism ejects the player from that frame completely rather than creating a damaged-but-functional version.

**Werewolf:**
- Nine Divines devotion continues at reduced effectiveness (not halted)
- No native Imperial Hircine path opens
- Civic-facing devotion weights reduce significantly
- The player becomes theologically homeless rather than newly integrated
- Lore rationale: Source material frames the Imperial werewolf as isolated and framework-less; Hircine is an intrusion into Imperial life, not an accepted alternative religious home.
