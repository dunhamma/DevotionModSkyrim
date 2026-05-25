# PDV Race Design — Nord
**Last updated:** 2026-05-19
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.1)

---

## Religious Identity

Nords in 4E 201 carry two overlapping pantheons simultaneously — the Old Ways (Shor, Kyne, Tsun, Stuhn, Mara, Talos/Ysmir) and the Nine Divines (Akatosh, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella, Talos). In practice, most Nords blend them without theological anxiety. The primary tension of the era is the Talos ban: Ulfric's war is explicitly a religious war, and every Nord in Skyrim has already taken a position on it even if they'd claim otherwise.

**Core design intent:** Nord devotion should feel like your deeds reveal which god noticed you — not like you spawned with a passive religious package. The broad-to-primary transition arc is the Nord's defining mechanic.

---

## Worship Structure

```
Step 1: Choose pantheon baseline at setup
  → Old Ways:     Shor, Kyne, Tsun, Stuhn, Mara, Talos/Ysmir
  → Nine Divines: All Nine

Step 2: Broad worship accumulates across your chosen pantheon
  → Cap at Tier 2 (Faithful) — most Nords blend gods; this is lore-accurate
  → Broad worship is its own devotional lane with blended contextual favors
  → Blended favors are softer than primary-patron favors and do not unlock Tier 3
  → Multiple offers possible if your playstyle spans domains

Step 3: A god's offer fires based on your actual playstyle
  → Sustained domain-aligned piety triggers the offer — no shrine pilgrimage required
  → You can decline ("Not yet") — offer cooldown applies, broad worship continues
  → 70% piety carry-over when you commit

Step 4: Primary patron committed → Tier 3 (Devoted) becomes reachable
```

**Non-worshippable gods (excluded):** Alduin (World-Eater, feared not worshipped), Orkey (enemy-god, propitiated not loved), Jhunal (forgotten by 4E 201 Nords, absorbed into Julianos).

**Implementation split (LOCKED):** Nord pantheon baseline and commitment state are separate. `PDV_State_NordPantheonBaseline` stores setup framing only: `OldWays = 0`, `NineDivines = 1`. Commitment depth uses the shared patron state model (`PDV_GLO_PatronState` for broad worship vs active patron, `PDV_GLO_PatronDeity` for the committed god). Do not implement `Broad` and `Primary` as Nord baseline states.

**Primary-offer gate (LOCKED):** Nord primary offers are evaluated only during `ProcessDawn()`. A god becomes offer-eligible when the god belongs to the chosen pantheon baseline, current piety meets the Faithful / Tier 2 offer threshold (`50` persistent piety by default), that god has qualifying signal activity on at least two separate in-game days within the last seven days, and no offer cooldown blocks it. If multiple gods qualify, offer the highest recent signal-strength god first. Major sacred events can count as one qualifying day, but do not bypass the sustained-pattern requirement or piety threshold alone.

**Offer-decline rule (LOCKED):** Choosing "Not yet" never lowers piety. It sets a per-deity offer cooldown only: seven in-game days after the first decline, fourteen after the second or later decline. Broad worship continues, and other qualifying gods may still offer on later dawns. If one god is cooling down, the next highest qualifying god can offer instead. This preserves player agency: a god can notice the character without forcing commitment.

**Acceptance / no-switching rule (LOCKED):** Accepting a primary offer sets the shared patron state to active primary, stores the accepted deity in `PDV_GLO_PatronDeity`, clears pending Nord offer candidates, and applies the standard 70% piety carry-over. Other deity ledgers remain intact but background-only. No competing primary offers fire in 1.0 while active primary is set. If devotion later decays below Tier 3, the relationship weakens but does not automatically clear.

**Offer-candidate storage rule (LOCKED):** Do not persist a real pending-offer queue for Nord. Each dawn recomputes candidates from current piety, pantheon baseline, recent signal-day evidence, and per-deity cooldowns, then fires at most one offer for the highest recent signal-strength candidate. Store cooldowns, recent signal evidence, and optional debug last-offered data only.

---

## Tier Rewards

### Tier 1 — Observant
*The god has noticed you exist. A small sign of alignment.*

| God | Tier 1 Blessing |
|-----|----------------|
| Kyne / Kynareth | Minor cold and storm resistance (10%) |
| Talos / Ysmir | Shout recharge speed +5% |
| Shor | Minor stamina regen when outnumbered in melee |
| Tsun | Stamina cost of power attacks -5% |
| Stuhn | Bonus damage against enemies who have attacked your allies first |
| Mara | Healing spells 5% more effective; vendor prices slightly better |
| Akatosh | Time-pressure skill checks (persuasion, lockpicking) marginally more forgiving |
| Zenithar | Crafting XP gains +5% |
| Arkay | Resist disease 10%; undead deal 5% less damage |
| Stendarr | Brawl damage +5%; Vigilants of Stendarr are neutral by default |
| Julianos | Spell cost -3% (Novice/Apprentice only) |
| Dibella | Speech +5%; favorable first impressions with new NPCs |

*Lore rationale: Tier 1 is sincere alignment, not divine favor. The god noticed your deeds are pointed in their direction. Nothing dramatic — a sign.*

### Tier 2 — Faithful
*The relationship is stable. The god's domain actively supports you.*

| God | Tier 2 Blessing (adds to Tier 1) |
|-----|----------------------------------|
| Kyne / Kynareth | Outdoor sleep restores stamina fully; animals are neutral unless attacked; hawks occasionally circle before ambushes (cosmetic warning) |
| Talos / Ysmir | Shout recharge +10% total; Thu'um use in civil war content scores piety; hostile Thalmor encounters generate devotion |
| Shor | Honorable kills (no sneak attack, fair fight to the end) restore small health; Companions quest content scores double |
| Tsun | After surviving a fight you were losing badly, brief stamina burst; trial-by-combat quest content scores strongly |
| Stuhn | After freeing prisoners or honoring a ransom, brief ally-defense bonus for rest of combat |
| Mara | Marriage + household content generates devotion; community restoration quests score strongly |
| Akatosh | Long unbroken devotion streaks (no gods neglected for 7+ days) give bonus piety; time-adjacent quest content scores |
| Zenithar | Crafting quality higher (extra smithing improvement chance); honest commerce generates modest piety |
| Arkay | Death-rite quests (Hall of the Dead, burial, anti-necromancer) give next rest a full health restore |
| Stendarr | After choosing mercy/restraint in dialogue, next combat has minor armor rating boost |
| Julianos | Skill book reading generates piety; College-adjacent content scores |
| Dibella | After succeeding in persuasion or performance, brief confidence boost to next social check |

*Lore rationale: Most Nords live here. Faithful is the natural ceiling for broad worship — devout, acknowledged by the gods, beloved by none specifically. Tier 2 is where Nord daily religious life actually lives.*

**Broad worship contextual favors:** A Nord who stays whole-pantheon should feel culturally complete, not unfinished. Broad Old Ways and Broad Nine Divines each get a small blended favor set rather than inheriting every individual god's patron set. Examples: honorable fight outdoors (Shor + Kyne steadiness), defending home/hold/family (Mara + Stuhn protection), death-rite acts (Arkay + ancestor quiet), hidden Talos reverence with public restraint (muted defiant resolve), and varied worship across several domains (rare pantheon-harmony after-act favor).

## Contextual Favor Pilot Table

**Status:** Pilot cleared for broad-lane table shape (2026-05-18 cross-pilot pass). Phase 12 runtime lock adds one focused contrast lane: `Kyne`.

**Pilot scope:** Phase 12 implements one focused patron lane plus both broad Nord lanes:
- focused `Kyne`
- `Broad Old Ways`
- `Broad Nine Divines`

**User-experience proof:** Nord broad worship should feel like a hold-born mythic life where weather, ancestors, household duty, honorable combat, and Talos pressure occasionally rhyme together. It is deed-led and mythic, not Imperial civic infrastructure and not Redguard sect duty.

**Nine Divines Nord rule:** Broad Nine Divines Nords mostly use the same deed/world hook surface as Broad Old Ways Nords. The names and moral framing shift toward Kynareth, Arkay, Stendarr, Zenithar, and the temple-readable Divines, but the play texture remains Nord: holds, weather, family, death, honor, and Talos pressure rather than Imperial civic/institutional religion.

**Talos pressure rule:** Talos pressure belongs in both broad Nord lanes. In Broad Old Ways it presents as ancestral identity defiance; in Broad Nine Divines it presents as carrying a contradiction inside a public Divine frame. In both cases, only costly faithful signals should trigger favor, not generic anti-Thalmor violence or ordinary Civil War preference. Default surfacing is `Noted`; escalate to `Marked` only for high-cost events like hiding a worshipper, protecting a shrine, or defying Thalmor pressure face-to-face.

**In-game hook cross-check:** Nord is buildable for 1.0 if launch scope favors already-proven event surfaces and curated quest rows. Strong hooks: the existing Kill Actor route for direct-player combat, player alias sleep/load registration, location keywords for wilderness and Nordic ruins, Civil War / Thalmor / Talos quest stages, marriage/home/hold service milestones, Hall of the Dead and anti-necromancy content, Word Wall / Thu'um milestones, and Companions quest stages. Medium hooks: honorable combat, outdoor hardship, and honest craft need conservative filters and caps. Rejected launch hooks: generic anti-Thalmor violence, ordinary travel, raw crafting counts, and faction membership without a concrete religiously meaningful act.

**Build-facing hook table (working lock):**

| Experience target | 1.0 hook candidate | Confidence | Implementation posture |
|---|---|---|---|
| Sky-road endurance | Player alias sleep events, wilderness/outdoor location keywords, weather or Survival Mode cold state where available, long on-foot travel evidence | Medium | Environmental favor or recent-signal strength only; reject fast travel and ordinary walking loops |
| Honorable ordeal | Kill Actor route, direct-player attribution, no sneak opener where detectable, no follower assist where detectable, boss/outnumbered/higher-level context | Medium | Shared helper candidate with Redguard Crown/Leki; use conservative checks rather than pretending perfect honor detection |
| Hearth and hold defense | Rescue/defense quest stages, prisoner release, thane/hold aid, marriage/home investment milestones | Strong | Curated one-shot or capped rows; no generic radiant chore scoring without whitelist |
| Death-right and ancestor quiet | Hall of the Dead / Arkay quest stages, draugr/undead boss defeat, necromancer operation completion, Nordic ruin clear | Strong | Per quest/site; avoid rewarding every minor undead or repeat tomb visits |
| Hidden Talos defiance | Hidden Talos shrine activation, help/refuse-to-report worshipper choices, Thalmor/Talos quest stages, Civil War religious beats | Medium-strong | Costly faithful signal only; generic Thalmor kills and ordinary faction preference do not trigger favor |
| Honest work and learned craft | Meaningful craft result, value/quality threshold, merchant/trade quest stages, skill book read, College-adjacent learning beats | Medium | Daily caps and quality/value filters; raw craft-count grinding is rejected |

### Broad Old Ways

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Broad Old Ways | Sky-road endurance | Outdoor sleep event; wilderness location keywords; weather or Survival Mode cold state; long on-foot travel check | Environmental | Noted | Kyne plus Shor texture. The world feels briefly companionable after choosing the hard road, but this stays softer than focused Kyne. |
| Broad Old Ways | Honorable ordeal | Story Manager kill event; no sneak opener where detectable; no follower assist where detectable; outnumbered or stronger-enemy check | Momentary combat | Quiet | Shor, Tsun, and Stuhn overlap. Medium hook risk; use conservative checks rather than pretending perfect honor detection. |
| Broad Old Ways | Hearth and hold defense | Rescue/defense quest stages; freeing prisoners; marriage or home investment milestones; thane/hold aid stages | After-act | Noted | Mara plus Stuhn protection. Fires from meaningful community defense, not generic radiant chores. |
| Broad Old Ways | Death-right and ancestor quiet | Hall of the Dead quests; burial-adjacent quest stages; draugr boss or necromancer operation completion | After-act | Noted | Arkay plus Shor/ancestor quiet. Per quest/site; avoids repeat farming the same tomb. |
| Broad Old Ways | Hidden Talos defiance with restraint | Hidden Talos shrine activation; helping a Talos worshipper; Thalmor/Talos quest stages; Civil War religious beats | After-act | Noted / Marked if high-cost | Costly-faithful signal. Must be authored as religious defiance or protection, not generic Thalmor violence. |

### Broad Nine Divines

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Broad Nine Divines | Kynareth's road grace | Outdoor sleep event; wilderness location keywords; weather or Survival Mode cold state; long on-foot travel check | Environmental | Noted | Similar hook family to Old Ways sky-road endurance, but framed as Kynareth's steadier road blessing rather than old mythic wildness. |
| Broad Nine Divines | Household and mercy duty | Marriage/home milestones; family aid quest stages; mercy/restraint dialogue outcomes; prisoner rescue quest stages | After-act | Noted | Mara plus Stendarr. More temple-readable and moral than the Old Ways hold-duty version. |
| Broad Nine Divines | Proper death and anti-necromancy | Hall of the Dead quests; Arkay shrine or priest interactions; necromancer operation completion; undead boss completion | After-act | Noted | Arkay plus Stendarr. A Nord in the Divines frame treats death order as proper religious maintenance. |
| Broad Nine Divines | Honest work and learned craft | Meaningful crafting completion; merchant/trade quest stages; skill book read; College-adjacent learning beats | After-act | Quiet | Zenithar plus Julianos/Dibella. Must require meaningful quality or curated quest beats, not raw craft-count grinding. |
| Broad Nine Divines | Talos pressure inside the Nine | Hidden Talos shrine activation; Thalmor/Talos quest stages; public restraint/private reverence state; Civil War religious beats | After-act | Noted / Marked if high-cost | The Nine frame makes Talos pressure a contradiction to carry. Mark only costly faithful moments, not ordinary political preference. |

### Focused Kyne

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Focused Kyne | Open-sky rest recovery | Outdoor sleep event; wilderness/outdoor location keywords; player alias sleep registration | Environmental | Noted | The simplest first live Kyne proof. Must come from genuine outdoor rest, not indoor beds or menu abuse. |
| Focused Kyne | Storm-road grace | Wilderness travel evidence; weather or cold-state context where available; mountain or road journey beats | Environmental | Noted | The road feels lighter under Kyne. Keep it conservative; ordinary walking loops and fast travel do not count. |
| Focused Kyne | Guided hunt | Direct-player animal kill; no follower assist where detectable; no sneak-opener farming where detectable | Momentary combat | Quiet | The hunt should feel guided, not like generic wildlife slaughter. Use real hunt posture and anti-farm discipline. |
| Focused Kyne | Wind-marked passage | Shout/Thu'um route; Word Wall or mountain pilgrimage beats; outdoor sky-facing travel context | After-act | Noted | The wind answers back. This is the Phase 12 shout-facing contrast to the broader Nord weather/travel rows. |

**Focused contrast note:** Focused patron design should later sharpen one voice. Focused Kyne makes the outdoors actively responsive; focused Talos makes defiance personal and dangerous; focused Shor makes honorable ordeal feel like Sovngarde looking back. Broad Nord worship remains blended, softer, culturally normal, and capped at Faithful.

### Tier 3 — Devoted (primary patron only)
*This god knows your name. The relationship is personal.*

**The offer is part of the experience.** Reaching Tier 3 requires committing to a primary patron when the god's offer fires. How that moment is surfaced — diegetically, clearly, with weight — matters as much as the mechanical reward.

| God | Champion Moment + Tier 3 Blessing |
|-----|-----------------------------------|
| **Kyne / Kynareth** | *The storm-mother recognizes you.* Outdoors in combat: storm and rain weather gives power attack stamina cost -10%. Sleep outdoors in any weather without exposure penalty (Survival Mode compatibility). Animals never aggro you unless you attack first. Kyne's Breath — in windy outdoor areas, your arrows and shouts have slightly extended effective range. |
| **Talos / Ysmir** | *The old faith marks you.* Shout recharge +15% total. In Stormcloak-allied areas or after Thalmor defiance acts, brief stamina/health regen surge. Thalmor Justiciars who encounter you at this tier have a chance to recognize you as a known defier (dialogue flag, not a guaranteed hostility trigger). Defiant worship acts generate extra piety at this tier. |
| **Shor** | *Sovngarde is closer than the map suggests.* Honorable kills restore health proportional to enemy strength. Near-death situations (below 20% health) in honorable combat trigger a brief stamina restoration. Sovngarde-adjacent content (final main quest stages, Tsun's bridge) gives special recognition dialogue. |
| **Tsun** | *The shield-thane has weighed you.* After surviving a fight at severe disadvantage (3+ enemies, or significantly overleveled enemy), 24-hour combat endurance bonus (stamina doesn't drop below 20%). Trial-and-challenge content (arena-type fights, proving grounds quests) gives double piety. |
| **Stuhn** | *Fair fighting made manifest.* After sparing or ransoming a defeated enemy (letting a surrendering enemy go, freeing a prisoner rather than leaving them), next combat has significant armor rating boost. Against enemies who hold hostages or use prisoners as leverage, bonus damage. |
| **Mara** | *The hearth-mother's warmth is real.* Marriage, household, and community content gives significant piety. After helping a family (reuniting, protecting, restoring), next rest heals to full regardless of conditions. Temples of Mara treat you with recognition privilege (special dialogue, healing discount). |
| **Akatosh** | *Time-order is your foundation.* Unbroken long devotion streaks (no lapsed days for 14+) give a cumulative bonus (caps at +15% skill XP for entire period). Amulet of Akatosh grants double its vanilla effect. Dragon-order content (Blades, dragonslaying) scores especially strongly at this tier. |
| **Zenithar** | *Honest work made holy.* Crafted items you make have a small chance to produce exceptional quality (one step above your current perk level). Commerce acts with honest NPCs generate piety. After selling goods honestly (not stolen, not from exploits), brief speech boost for next major persuasion check. |
| **Arkay** | *The death-cycle is your covenant.* Undead deal 20% less damage to you. After completing a death-rite quest, next rest restores health to full. Hall of the Dead priests treat you with recognition privilege. Raise Dead and similar necromantic spells used near you fail at higher rate (not a player power, a passive disturbance effect). |
| **Stendarr** | *Mercy is its own armor.* When you spare a surrendering enemy in combat, brief damage resist (15%) for remainder of fight. Vigilants of Stendarr treat you as a peer (recognition privilege, quest access). Against Daedra and undead, bonus damage when you've maintained KnightlyVow-equivalent moral record recently. |
| **Julianos** | *Wisdom made practical.* Spell cost -8% across all schools at this tier. After reading a skill book or reaching a new magic skill rank, next cast of that school is free. College of Winterhold recognition privilege. |
| **Dibella** | *Beauty honored is beauty returned.* After succeeding at a major persuasion or performance check, next social encounter has near-automatic success on equivalent difficulty. Temple of Dibella recognition (special dialogue, reduced prices, quest access). Bards' College content generates strong piety. |

---

## Signature Friction

**Patience and identity, not compliance.** Unlike Bosmer (Green Pact) or Altmer (Lorkhan penalty), Nord friction isn't a hard rule imposed on you — it's that the broad-to-primary transition is entirely driven by what you actually do. You cannot pick which god finds you. You can only live and see who shows up.

**Practical friction surfaces:**

- A player who fights, hunts, and stays outside will see Kyne's offer. A player who fights for the Stormcloaks and defies the ban will see Talos/Ysmir's offer. A player who helps everyone and builds a home will see Mara's offer. A player who does all of these moderately may wait a very long time before any single offer fires.
- **Declining an offer** is a real choice with a cooldown consequence. A Nord who refuses Kyne's first approach and then shifts to more crafting-focused play might see Zenithar appear instead. The mod should not punish this — the Nord theology of broad reverence supports it.
- **Maintaining the primary relationship** once committed: the god that claimed you needs to see continued alignment. A Kyne Champion who moves to a city and stops hunting, stops going outside, never sleeps under the sky — that relationship will decay below Tier 3 back to Tier 2. The commitment isn't permanent; it's a living relationship.

---

## Neglect Texture

Nord neglect should feel like **absence and distance**, not punishment.

- **Kyne neglect:** The weather stops cooperating. It's still weather, not actively hostile — but you used to feel like the outdoors was on your side. Birds don't circle. Animals don't settle when you approach. You're just another person in the cold.
- **Talos/Ysmir neglect:** The shouts feel more like technique than spirituality. Thu'um use doesn't carry the same theological weight. The defiance that used to feel like faith starts to feel like politics.
- **Shor neglect:** Combat feels random again. The near-death moments that used to feel like tests now just feel like almost dying.
- **Mara neglect:** The small warmths dry up — companion healing feels less reliable, vendor prices creep back up, the sense of being looked after disappears.
- **General broad-worship neglect:** The ancestors go quiet. No specific punishment, but the small graces that felt like Sovngarde paying attention stop arriving.

**Decay mechanics:** The daily consolidation system handles this — neglecting devotion signals means `PDV.PietyToday` trends negative, tier thresholds slip. For Nord, there's no harsh penalization — just gentle drift. A player who stops living like their patron expected them to live will slowly find the relationship has become formal rather than real.

---

## Signal Examples

| Action | God(s) | Cadence | Notes |
|--------|--------|---------|-------|
| Sleep outdoors (not in inn or house) | Kyne | Daily cap | Survival Mode overlap high |
| Hunt and kill an animal (no sneak attack) | Kyne, Shor | Daily cap | Must be a genuine hunt, not random wildlife |
| Learn or use a Thu'um | Kyne, Talos/Ysmir | Per milestone | Level of Word Known / Wall unlocked |
| Kill a Thalmor agent unprovoked | Talos/Ysmir | Cooldown | Strong piety spike; anti-farm by rarity of encounters |
| Activate a hidden Talos shrine | Talos/Ysmir | Per shrine (one-time each) | One of the strongest Nord signals |
| Win an honorable duel (no sneak, no follower assist) | Shor, Tsun, Stuhn | Daily cap | Hard to detect perfectly; use Story Manager kill filter |
| Free a prisoner | Stuhn, Stendarr | Per event | Quest-locked prisoners only; farmable via reset? Flag for anti-farm |
| Get married / invest in a home | Mara | One-time major, then maintenance | Ongoing household content generates smaller repeating signals |
| Complete a Hall of the Dead / burial quest | Arkay | Per quest | Strong one-time; variants in each hold |
| Successfully persuade in a high-stakes dialogue | Dibella, Julianos | Per check | Hard to filter high-stakes from trivial; needs threshold |
| Complete a crafting project (smithing, alchemy, enchanting) | Zenithar | Daily cap | Must produce item of meaningful quality |
| Defy the Talos ban (help worshipper, hide shrine) | Talos/Ysmir | Per act, cooldown | ConcordatStanding equivalent for Old Ways Nords |
| Side with Stormcloaks (major quest beats) | Talos/Ysmir, Shor | One-time per beat | Civil War questline carries heavy weight |
| Complete Companions quest arc stages | Shor, Stuhn | Per beat | Werewolf state shifts interpretation — see Curse States |
| Visit Sovngarde / cross Tsun's bridge | Shor, Tsun | One-time | Maximum weight; these are threshold events |

---

## Implementation Notes

**Vanilla hook surface:** Excellent. Nords have the most hook-dense content in Skyrim. Story Manager kill events, sleep events, shrine interactions, civil war quest stages, Companions quest stages, Greybeards milestones, marriage — all are reliable and well-tested signals.

**Complexity flags:**
- **The offer system** is the most novel Nord mechanic and needs careful implementation. It fires on sustained domain-aligned piety above a threshold — exact values TBD in balancing. Should feel organic, not like a pop-up the moment you hit 50 Kyne piety.
- **Honorable kill detection** is the hardest individual signal to implement cleanly. Story Manager kill events give you kill data; distinguishing "fair fight" from sneak attacks requires checking approach state. Flag as medium complexity — worth doing because it's central to Shor and Tsun, but needs anti-farm and edge-case design.
- **Talos ban defiance** in the Old Ways frame: there's no ConcordatStanding track for Nord (that's Imperial), but similar logic is needed. Nord Talos devotion through defiance acts is curated signals rather than a reputation track.
- **Pantheon baseline choice** (Old Ways vs Nine Divines) affects which god names and thresholds apply, but the underlying mechanics are shared. Implementation can share scoring logic and vary the deity roster and theological framing.

**Cost class profile:**
- Most Nord signals: Cost Class A (event-driven, cheap)
- Outdoor sleep, food, rest: Cost Class A-B (state or event)
- Honorable kill detection: Cost Class B-C (needs careful filtering)
- Offer system threshold detection: Cost Class B (dawn-slot evaluation)

**Verification targets:** Same Kyne proof slice already in game. Talos hostile-path already proven. Extend from that baseline.

---

## Curse State Summary

**Werewolf:**
- Hircine pulls against Shor/Sovngarde — combat signals shift toward hunt interpretation
- Shor/Tsun/Stuhn piety gain reduced while transformed or in active Companions werewolf arc
- Kyne has complex relationship with beasts — not penalized, but signals shift toward hunt/nature rather than storm
- No native Hircine Nord path opens, but the hunting/predatory signal interpretation creates a natural drift toward Hircine devotion if the player engages with that content

**Vampire:**
- Severs Sovngarde afterlife claim — Shor/Tsun path weight significantly reduced
- Molag Bal becomes available as an opposing pressure
- Kyne, Mara, Arkay all weakened while active vampirism persists
- Cure restores access but Sovngarde path carries a permanent scar (reduced ceiling) reflecting the theological rupture
