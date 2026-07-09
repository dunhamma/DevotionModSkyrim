# PDV Quest-Reaction Matrix

**Created:** 2026-06-08
**Purpose:** Drive piety GAIN/LOSS for a race's deities + the Daedric Princes from
the player's choices in vanilla+DLC quests. A quest outcome is judged by tagging
it with **act-tags** (from its journal text) and matching against each deity's
**values profile** (approve/disapprove). Same act always reads the same way for
the same god -> consistent, auditable, balanceable.

**Data foundation (locked):**
- Candidate universe: `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv`
  (real stage/journal data; ~147 named player quests, ~108 morally salient).
- Coverage proof: `tools/pdv_quest_reaction_pilot.mjs` (deterministic; confirmed
  the method widens each deity's pool from ~1-2 flagship quests to ~18-46).
- Scope: vanilla + DLC only. Mod quests -> optional patches later.

**Model discipline:** authored on Opus 4.8 / high reasoning. Valence calls are
lore-judgments, not keyword hits; every cell cites the journal line (+ UESP when a
branch's meaning is ambiguous).

---

## Part A — Locked act-tag vocabulary

Controlled set of moral/theological primitives. Both quest outcomes and deity
profiles are expressed ONLY in these tags. Magnitude (`small` vs `milestone`) is
assigned separately (see Part C), not encoded in the tag.

### Violence, death, the hunt
| Tag | Meaning (player did this) |
|---|---|
| `kill_honorable_combat` | Defeated a worthy/armed foe in open battle. |
| `murder_treacherous` | Killed by betrayal, ambush of the trusting, or cold blood. |
| `ritual_sacrifice` | Offered a life (often the trusting) to a Daedra/dark rite. |
| `kill_the_helpless` | Slew a yielding, bound, fleeing, or defenseless victim. |
| `assassination_contract` | Killed for a guild/coin (Dark Brotherhood work). |
| `mercy_spare` | Spared, ransomed, or released a foe you could have killed. |
| `slay_undead` | Destroyed draugr/vampires/skeletons/the risen dead. |
| `the_hunt` | Killed beasts/predators as a hunt; pursued worthy prey. |
| `cannibalism` | Ate the flesh of the dead / revelled in the foul. |

### Oaths, honor, protection
| Tag | Meaning |
|---|---|
| `keep_oath` | Honored a sworn vow, pact, or duty to kin/lord/guild. |
| `break_oath_betray` | Broke a vow, deserted, or betrayed those who trusted you. |
| `prove_by_struggle` | Won by enduring hardship / overcoming a stronger foe. |
| `honorable_duel` | Met a challenge one-on-one; trial of arms. |
| `protect_the_weak` | Defended/rescued the vulnerable; shielded the innocent. |
| `defend_kin_home` | Defended your people, stronghold, or homeland. |
| `cowardice` | Fled a duty, abandoned a charge, took the craven path. |

### Law, order, defiance, chaos
| Tag | Meaning |
|---|---|
| `uphold_law_justice` | Brought a wrongdoer to lawful justice; upheld order. |
| `civic_service` | Served the community/empire/hold concretely. |
| `defy_tyranny_talos` | Defied the Thalmor/Concordat; bore the Talos/Nord cause. |
| `serve_empire_order` | Upheld Imperial/lawful authority and its institutions. |
| `sow_chaos_madness` | Spread madness, disorder, or wanton ruin. |

### The dead, necromancy, the cycle
| Tag | Meaning |
|---|---|
| `honor_the_dead` | Tended graves, gave rites, respected tombs and the fallen. |
| `desecrate_the_dead` | Robbed/defiled the dead or sacred tombs. |
| `necromancy` | Raised/bound the dead; trafficked in undeath. |
| `cure_undeath` | Cured/restored one from lycanthropy/vampirism/undeath. |

### Daedra, the forbidden
| Tag | Meaning |
|---|---|
| `serve_a_daedra:<prince>` | Did a Prince's bidding / took its bargain (named). |
| `acquire_daedric_artifact:<prince>` | Claimed a Prince's artifact. |
| `destroy_reject_daedra:<prince>` | Refused/destroyed a Daedric bargain or artifact. |
| `forbidden_knowledge` | Sought proscribed lore (Black Books, Apocrypha). |

### Theft, secrecy, cunning
| Tag | Meaning |
|---|---|
| `theft_burglary` | Stole, robbed, picked locks/pockets for gain. |
| `deceit` | Lied, tricked, framed, blackmailed, manipulated. |
| `keep_secret` | Guarded a secret/conspiracy; wove hidden influence. |
| `expose_betray_secret` | Clumsily exposed or sold out a kept secret. |

### Mercy, love, the hearth
| Tag | Meaning |
|---|---|
| `charity` | Gave to the poor, the orphaned, the begging. |
| `heal_comfort` | Healed/cured the sick; comforted grief. |
| `marriage_family` | Wed, adopted, reconciled, kept the hearth. |
| `aesthetic_devotion` | Created/performed/adorned beauty; honored art, music, the sublime. *(added 2026-06-08 for Dibella; previously no primitive for her domain)* |

### Work, craft, trade
| Tag | Meaning |
|---|---|
| `honest_labor_trade` | Did honest work/commerce; fair dealing. |
| `master_craft_forge` | Forged/crafted worthy work; mastery of the craft. |
| `exploit_cheat` | Cheated, extorted, or profited by exploitation. |

### Nature, wild, sky
| Tag | Meaning |
|---|---|
| `honor_the_wild` | Tended groves/standing stones; revered the open sky. |
| `green_pact` | Kept (or broke) the Bosmer Green Pact. |
| `defile_nature` | Wantonly despoiled the living world. |

### Knowledge, magic
| Tag | Meaning |
|---|---|
| `disciplined_study` | Pursued lore/magic with restraint and rigor. |
| `reckless_magic` | Used the arts for spectacle, ruin, or careless harm. |

### Indulgence, excess, disease
| Tag | Meaning |
|---|---|
| `revel_indulge` | Feasted, drank, gave in to pleasure/excess. |
| `embrace_lycanthropy` | Took the beast-blood (Hircine's gift / curse). |
| `embrace_vampirism` | Took the blood (Molag Bal's gift / curse). |
| `spread_order_pestilence` | Served plague/decay-as-order (Peryite). |

> Magnitude is NOT a tag. A `completion`/terminal stage = candidate **milestone**;
> an intermediate meaningful stage = **small**; scaled by how central the tag is to
> the deity (Part C).

---

## Part B — Values-profile matrix

Per deity: `approve` (gain) and `disapprove` (loss) tag sets, each with an
intensity weight — **C** (core domain, milestone-capable), **S** (strong),
**m** (mild/peripheral) — plus indifferent domains and a lore anchor. A god only
reacts to tags in its profile; everything else is silence (most quests are neutral
to most gods).

> Intensity governs magnitude + whether a god reacts at all to a peripheral act
> (fixes the pilot's over-broad "every god hates every murder"). E.g. Dibella gets
> NO `murder_treacherous` line — she is indifferent to most killing.

### Aedric / Divines (shared: Imperial owns; Nord & Breton reuse)

**Akatosh** — time, covenant, lawful order, dragons.
- approve: `serve_empire_order`(S), `keep_oath`(S), `uphold_law_justice`(m), `disciplined_study`(m)
- disapprove: `break_oath_betray`(S), `sow_chaos_madness`(S), `serve_a_daedra:*`(m)
- indifferent: theft, the hunt, craft, romance.
- anchor: Chief of the Nine; the Covenant; Dragon of Time. (UESP: Akatosh)

**Stendarr** — mercy, righteous justice, the weak, vigil vs Daedra/undead.
- approve: `mercy_spare`(C), `protect_the_weak`(C), `slay_undead`(S), `destroy_reject_daedra:*`(S), `uphold_law_justice`(S), `charity`(m)
- disapprove: `kill_the_helpless`(C), `murder_treacherous`(S), `serve_a_daedra:*`(S), `ritual_sacrifice`(S)
- anchor: God of Mercy; the Vigilants. (UESP: Stendarr)

**Mara** — love, compassion, charity, the hearth, mercy.
- approve: `heal_comfort`(C), `charity`(C), `marriage_family`(C), `mercy_spare`(S), `protect_the_weak`(m)
- disapprove: `murder_treacherous`(m), `ritual_sacrifice`(S), `kill_the_helpless`(m)
- indifferent: theft, law, craft, the hunt.
- anchor: Mother-Goddess; Amulet of Mara. (UESP: Mara)

**Arkay** — life/death cycle, burial, the vigil against undeath.
- approve: `honor_the_dead`(C), `slay_undead`(C), `cure_undeath`(S)
- disapprove: `necromancy`(C), `desecrate_the_dead`(C), `embrace_vampirism`(S), `ritual_sacrifice`(m)
- indifferent: trade, romance, law, the hunt.
- anchor: Keeper of the cycle; Halls of the Dead. (UESP: Arkay)

**Zenithar** — honest work, commerce, craft, fair dealing.
- approve: `honest_labor_trade`(C), `master_craft_forge`(S), `uphold_law_justice`(m)
- disapprove: `theft_burglary`(S), `exploit_cheat`(C)
- indifferent: killing, the dead, magic, the wild.
- anchor: God of Work and Commerce. (UESP: Zenithar)

**Dibella** — beauty, love, art, the sublime.
- approve: `aesthetic_devotion`(C), `heal_comfort`(S), `charity`(m), `marriage_family`(m)
- disapprove: `kill_the_helpless`(m)  *(she recoils from cruelty to the innocent, not from war)*
- indifferent: MOST killing, theft, law, the dead, craft.
- anchor: Goddess of Beauty and Love. (UESP: Dibella). NOTE: thin on QUESTS by design
  (vanilla rarely scores beauty/art) -> her core `aesthetic_devotion`(C) is carried by
  the faucet/adornment + shrine + Agent-of-Dibella layers (Part D), not the quest table.

**Julianos** — wisdom, logic, law, lore, disciplined magic.
- approve: `disciplined_study`(C), `uphold_law_justice`(S), `forbidden_knowledge`(m, *pursuit of truth, double-edged*)
- disapprove: `sow_chaos_madness`(S), `reckless_magic`(S)
- indifferent: the hunt, romance, trade, the dead.
- anchor: God of Wisdom and Logic. (UESP: Julianos)

**Kynareth** — sky, wind, nature, the traveler, life.
- approve: `honor_the_wild`(C), `protect_the_weak`(m), `heal_comfort`(m)
- disapprove: `defile_nature`(C), `necromancy`(m)
- indifferent: trade, law, theft, the dead.
- anchor: Goddess of the Heavens/Nature; the Gildergreen. (UESP: Kynareth)

**Talos** — heroism, defiance of the Thalmor, the Nord/Imperial cause, the Voice.
- approve: `defy_tyranny_talos`(C), `kill_honorable_combat`(S), `prove_by_struggle`(S), `protect_the_weak`(m), `honorable_duel`(m)
- disapprove: `cowardice`(S), `murder_treacherous`(S), `kill_the_helpless`(m), `assassination_contract`(m) *(compliance/submission to the Concordat scores nothing; never a gain. Treachery/assassination added 2026-07-09 — the Hero-god of Man reviles cold-blood murder and regicide, mirroring Shor's disapprove.)*
- indifferent: theft, the dead, craft, romance.
- anchor: Hero-god of Man; the Talos ban. (UESP: Talos). FILTERED for Imperials by
  ConcordatStanding; faithful defiance only.

### Nord Old Ways (Sovngarde martial virtue)

**Kyne** — the storm-mother, the sacred hunt, the Voice, widow of Shor.
- approve: `the_hunt`(C, *the respectful hunt; the Sacred Trials*), `honor_the_wild`(S), `kill_honorable_combat`(S, *dragons and worthy foes under her sky*), `prove_by_struggle`(S, *the Voice is Kyne's gift*), `defend_kin_home`(m), `mercy_spare`(m, *mercy to the hunted*)
- disapprove: `defile_nature`(C), `kill_the_helpless`(m)
- indifferent: trade, law, theft, the dead, magic.
- anchor: Nordic storm-widow of Shor, Mother of Men; breathed the Voice onto
  mortals (Paarthurnax: the Voice as Kyne's gift); Kyne's Sacred Trials
  (dunHunterQST). Distinct record from Kynareth (Phase 2 R4: Nord may focus
  either). (UESP: Kyne / Kyne's Sacred Trials)
  *(Profile added 2026-06-10 — paired-deity equity fix; Kyne was the only
  record deity missing from Part B, which is why every tranche pass skipped
  her. Gate: tools/pdv_paired_equity_audit.mjs check 5.)*

**Shor** — the warrior-king, honored battle, Sovngarde.
- approve: `kill_honorable_combat`(C), `prove_by_struggle`(S), `honor_the_dead`(m, *honored fallen warriors*), `defend_kin_home`(S)
- disapprove: `cowardice`(C), `murder_treacherous`(S), `kill_the_helpless`(m)
- anchor: Hero-god/King of Sovngarde. (UESP/Imperial Library: Shor/Lorkhan)

**Tsun** — trials, endurance, the shield-thane at the whalebone bridge.
- approve: `prove_by_struggle`(C), `kill_honorable_combat`(S), `protect_the_weak`(m, *shield the weaker*)
- disapprove: `cowardice`(C), `murder_treacherous`(S), `kill_the_helpless`(m), `assassination_contract`(m)
- anchor: Shield-Thane of Shor; god of trials. (Imperial Library: Tsun) *(Treachery/assassination added 2026-07-09 — the shield-gate keeper judges assassination the antithesis of honorable combat, matching his king Shor.)*

**Stuhn** — mercy to the yielding, ransom, just spoils, the honored bond.
- approve: `mercy_spare`(C), `keep_oath`(S), `protect_the_weak`(S), `uphold_law_justice`(m)
- disapprove: `kill_the_helpless`(C), `break_oath_betray`(S)
- anchor: Shield-Thane; god of ransom/justice. (Imperial Library: Stuhn)

### Altmer

**Auri-El** — the soul-god, Elven ancestry, the ascendant order.
- approve: `disciplined_study`(S), `honor_the_dead`(m, *ancestry*), `prove_by_struggle`(m), `uphold_law_justice`(m)
- disapprove: `serve_a_daedra:*`(S), `sow_chaos_madness`(m)
- anchor: Elven Akatosh; the Chantry of Auri-El. (UESP: Auriel)

**Magnus** — the architect of magic, disciplined arcane mastery.
- approve: `disciplined_study`(C), `forbidden_knowledge`(m, *recovered, not abused*)
- disapprove: `reckless_magic`(C), `sow_chaos_madness`(m)
- indifferent: killing, the dead, trade, romance.
- anchor: God of magic/sky; the Eye of Magnus. (UESP: Magnus)

**Xarxes** — the scribe, ancestry, the long ledger of deeds.
- approve: `disciplined_study`(S), `honor_the_dead`(C, *ancestry/record*), `keep_secret`(m, *preserved knowledge*)
- disapprove: `desecrate_the_dead`(S), `sow_chaos_madness`(m)
- anchor: Aedric scribe of Auri-El. (Imperial Library: Xarxes)

**Trinimac** — orthodox elven strength, the fallen god (pressure/rare).
- approve: `kill_honorable_combat`(S), `keep_oath`(S), `defend_kin_home`(m)
- disapprove: `serve_a_daedra:boethiah`(C), `break_oath_betray`(S)
- anchor: Once-greatest Elven god; devoured by Boethiah. (UESP: Trinimac)

### Bosmer

**Y'ffre** — the Storyteller, the Green Pact, the forest's law.
- approve: `green_pact`(C), `honor_the_wild`(S), `the_hunt`(S, *within the Pact*), `defend_kin_home`(m), `slay_undead`(m, *bone-law kept: the walking dead are matter outside its fixed story; mirrors his shipped kill-undead day-to-day like. Added 2026-07-09.*), `aesthetic_devotion`(S, *the Storyteller: song, saga, and the first story preserved — bardic arts are his domain. Added 2026-07-09.*)
- disapprove: `defile_nature`(C), `green_pact`(C, *as violation — branch-dependent*), `necromancy`(S, *dead matter bound and animated against the fixed forms the first story set — a fundamental bone-law violation. Added 2026-07-09.*)
- anchor: Bosmeri forest-god; the Green Pact. (UESP: Y'ffre)

**Z'en** — the trader-god, debt, balance, proportionate redress.
- approve: `honest_labor_trade`(C), `uphold_law_justice`(S, *proportionate redress*), `keep_oath`(m)
- disapprove: `exploit_cheat`(S), `break_oath_betray`(m)
- anchor: God of toil/payment. (Imperial Library: Z'en)

**Baan Dar** — the Bandit God, trickster, the road, reversal of fortune.
- approve: `deceit`(C, *clever, not cruel*), `theft_burglary`(S, *from the strong/unjust*), `prove_by_struggle`(m, *survival/reversal*)
- disapprove: `kill_the_helpless`(m)
- anchor: Pariah/Bandit God (Khajiit + Bosmer). (UESP: Baan Dar)

### Khajiit (focus deities; Azurah shared w/ Dunmer Azura record)

**Azurah / Azura** — dawn & dusk, prophecy, the threshold, the moons.
- approve: `disciplined_study`(m, *prophecy/fate*), `destroy_reject_daedra:molagbal`(S, *light vs domination*), `honor_the_dead`(m), `cure_undeath`(m, *mercy to the cursed made whole; 2026-07-04 enrichment, mirrors her shipped heal-or-cure day-to-day like*), `slay_undead`(m, *the dawn drives back undeath; mirrors her shipped kill-undead like*)
- disapprove: `desecrate_the_dead`(m), `serve_a_daedra:molagbal`(S)
- anchor: Good Daedra / Mother of the Rose. (UESP: Azura)

**Khenarthi** — the wind, the road, the traveler, mercy on the road, the soul-ferry.
- approve: `protect_the_weak`(S, *aid the stranded*), `honor_the_wild`(m), `honor_the_dead`(m, *bears worthy dead on the winds to the Sands Behind the Stars*)
- disapprove: `kill_the_helpless`(m)
- anchor: Khajiit wind/sky goddess and death-guide (Kynareth-adjacent; ferries
  the worthy dead). (Imperial Library). *(honor_the_dead added 2026-06-10 —
  paired-deity equity: her death-guide aspect was lore-real but unprofiled.)*

**Rajhin** — the master thief, elegant theft, the legend.
- approve: `theft_burglary`(C, *artful, notable target*), `deceit`(S)
- disapprove: `kill_the_helpless`(m, *botched/clumsy crime that harms innocents*)
- anchor: Khajiit thief-god. (UESP: Rajhin)

**Alkosh** — the Dragon King of Cats, cosmic order, time, named dragons.
- approve: `kill_honorable_combat`(S, *named dragons / order-keeping*), `serve_empire_order`(m, *cosmic order*), `uphold_law_justice`(m)
- disapprove: `sow_chaos_madness`(C)
- anchor: Khajiit Akatosh-aspect; First Cat. (UESP: Alkosh)

### Orc

**Malacath** — the Spurned, oaths, the code, strength, the forge, the stronghold.
- approve: `keep_oath`(C), `master_craft_forge`(S), `kill_honorable_combat`(S), `defend_kin_home`(S), `prove_by_struggle`(m)
- disapprove: `break_oath_betray`(C), `cowardice`(S), `deceit`(m, *dishonorable trickery*)
- anchor: God of the Orsimer; the Code; Volendrung. (UESP: Malacath)

### Redguard (Yokudan)

**Tu'whacca** — the keeper of souls, the Far Shores, the death-duty.
- approve: `honor_the_dead`(C), `slay_undead`(S), `cure_undeath`(m)
- disapprove: `necromancy`(C), `desecrate_the_dead`(S)
- anchor: Yokudan god of souls (Arkay-adjacent, NOT Arkay). (Imperial Library: Tu'whacca)

**HoonDing** — the Make Way God, the spirit of perseverance against impossible odds.
- approve: `prove_by_struggle`(C, *impossible odds, make way*), `defend_kin_home`(S), `kill_honorable_combat`(m)
- disapprove: `cowardice`(S), `murder_treacherous`(m), `kill_the_helpless`(m)
- anchor: Yokudan avatar of "making way." (UESP: HoonDing). Thin -> rare/milestone. *(Treachery/helpless-kill added 2026-07-09 — stealth-murder is the cowardly opposite of making way head-on against impossible odds.)*

**Leki** — Saint of the Spirit Sword, sword-singing, honorable single combat.
- approve: `honorable_duel`(C), `kill_honorable_combat`(S)
- disapprove: `murder_treacherous`(S), `cowardice`(m)
- anchor: Yokudan goddess of the duel. (Imperial Library: Leki). Thin -> acts.

### Argonian

**Hist** — the trees, the People, memory, the marsh, communion. (substrate)
- approve: `defend_kin_home`(C, *the People*), `honor_the_wild`(S), `honor_the_dead`(m)
- disapprove: `defile_nature`(S), `break_oath_betray`(m, *abandon the People*)
- anchor: The Hist; Argonian collective. (UESP: Hist)

**Sithis** — the Void, the original night, death-as-change, the Brotherhood.
- approve: `assassination_contract`(C), `murder_treacherous`(S), `embrace... void`(m)
- disapprove: (Sithis judges little; emptiness) — `cowardice`(m, *failed the contract*), `break_oath_betray`(C, *destroying/betraying the Night Mother's family is the one act the Void does not forgive. Added 2026-07-09.*)
- anchor: The Void; Sithis/Padomay. (UESP: Sithis). High-threshold tertiary.

### Daedric Princes (Part B-2)

Each Prince also implicitly approves its **own** `serve_a_daedra:<self>` and
`acquire_daedric_artifact:<self>` (doing its quest/taking its artifact pleases it).
Azura, Boethiah, Mephala, Malacath share their record with the race-deity profiles
above (cross-referenced, not duplicated).

**Azura** — (see Azurah/Azura above). Prince context: dawn/dusk, prophecy, foe of Molag Bal.

**Boethiah** — deceit, proving by struggle, murder of the unworthy, overthrow.
- approve: `prove_by_struggle`(C), `murder_treacherous`(S, *of the unworthy, by cunning*), `deceit`(S), `honorable_duel`(S), `ritual_sacrifice`(S), `break_oath_betray`(m, *of false authority*)
- disapprove: `cowardice`(C)
- anchor: Prince of Plots/Deceit; Boethiah's Calling. (UESP: Boethiah)

**Mephala** — secrets, webs, assassination, manipulation, the hidden hand.
- approve: `deceit`(C), `keep_secret`(C), `assassination_contract`(S), `theft_burglary`(S), `murder_treacherous`(S, *by stealth*)
- disapprove: `expose_betray_secret`(S)
- anchor: Webspinner; the Ebony Blade. (UESP: Mephala)

**Malacath** — (see Orc above). Prince context: the Spurned, oaths, the curse of the strong.

**Meridia** — light, living energy; hatred of undeath and necromancy.
- approve: `slay_undead`(C), `cure_undeath`(S), `destroy_reject_daedra:molagbal`(m)
- disapprove: `necromancy`(C), `desecrate_the_dead`(S), `embrace_vampirism`(S)
- anchor: Lady of Infinite Energies; The Break of Dawn. (UESP: Meridia)

**Hircine** — the Hunt, the beast-blood, worthy prey. (curse-access)
- approve: `the_hunt`(C), `embrace_lycanthropy`(C), `kill_honorable_combat`(S, *worthy prey*), `honor_the_wild`(m)
- disapprove: `cure_undeath`(S, *curing lycanthropy spurns his gift*)
- anchor: Huntsman of the Princes; Ill Met By Moonlight. (UESP: Hircine)

**Molag Bal** — domination, cruelty, vampirism, breaking the proud. (curse-access)
- approve: `embrace_vampirism`(C), `kill_the_helpless`(C), `murder_treacherous`(S), `ritual_sacrifice`(S)
- disapprove: `mercy_spare`(S), `protect_the_weak`(m)
- anchor: King of Rape/Domination; The House of Horrors. (UESP: Molag Bal)

**Nocturnal** — shadow, luck, theft, the unseen, the Nightingale debt.
- approve: `theft_burglary`(C), `keep_secret`(S), `deceit`(m)
- disapprove: `expose_betray_secret`(m)
- anchor: Mistress of Shadow; the Nightingales. (UESP: Nocturnal)

**Hermaeus Mora** — forbidden knowledge, secrets of fate, the price of knowing.
- approve: `forbidden_knowledge`(C), `disciplined_study`(S), `keep_secret`(m)
- disapprove: (none meaningful — Mora wants knowledge by any path)
- anchor: Gardener of Men; Black Books/Apocrypha. (UESP: Hermaeus Mora)

**Mehrunes Dagon** — destruction, cataclysmic change, ambition, razing.
- approve: `sow_chaos_madness`(C, *destruction/revolution*), `kill_honorable_combat`(m, *conquest*), `murder_treacherous`(m)
- disapprove: `serve_empire_order`(S), `keep_oath`(m, *to a standing order*)
- anchor: Prince of Destruction; the Razor. (UESP: Mehrunes Dagon)

**Sheogorath** — madness, whimsy, chaos, the unpredictable.
- approve: `sow_chaos_madness`(C), `reckless_magic`(m), `revel_indulge`(m)
- disapprove: `serve_empire_order`(m), `uphold_law_justice`(m)
- anchor: Madgod; the Wabbajack; the Mind of Madness. (UESP: Sheogorath)

**Namira** — cannibalism, the repulsive, the spurned, decay. (very narrow)
- approve: `cannibalism`(C), `desecrate_the_dead`(S)
- disapprove: (none meaningful)
- anchor: Lady of Decay; The Taste of Death. (UESP: Namira). THIN -> Part D.

**Sanguine** — indulgence, revelry, debauchery, temptation.
- approve: `revel_indulge`(C)
- disapprove: (asceticism — rare)
- anchor: Prince of Debauchery; A Night To Remember. (UESP: Sanguine). THIN -> Part D.

**Clavicus Vile** — bargains, wishes, the price of desire.
- approve: `serve_a_daedra:clavicus`(C, *striking the bargain*), `deceit`(S, *clever deals*)
- disapprove: (none meaningful)
- anchor: Prince of Bargains; the Rueful Axe / Masque. (UESP: Clavicus Vile)

**Peryite** — order through pestilence; the natural hierarchy of decay; the lowly.
- approve: `spread_order_pestilence`(C), `serve_empire_order`(m, *order/hierarchy*)
- disapprove: `sow_chaos_madness`(S, *true chaos affronts his order*)
- anchor: Taskmaster; The Only Cure. (UESP: Peryite). THIN -> Part D.

**Vaermina** — nightmares, dreams, terror, stolen memory.
- approve: `forbidden_knowledge`(m, *dream/memory secrets*), `murder_treacherous`(m, *terror*), `serve_a_daedra:vaermina`(C)
- disapprove: (none meaningful)
- anchor: Mistress of Dreams; Waking Nightmare. (UESP: Vaermina). THIN -> Part D.

---

## Part C — Magnitude + the race-stance modulation

### C1. Magnitude (how big the gain/loss is)

**Event-scale model (2026-07-09 recalibration).** Signal weight follows the SCALE
of the event, not just tag centrality. A quest is the completion of an arc / a big
thematic beat, so quests sit at the TOP; single in-game incidents sit at the bottom;
a location/crypt cleared sits in between.

| Event scale | Surface | Magnitude tier | Piety (C/S/m) |
| --- | --- | --- | --- |
| Quest = arc completion | quest-reaction matrix | **milestone** (core arcs) / **small** (peripheral) | 18/12/8 · 6/4/2 |
| Location / crypt cleared | location-cleared signal (Ash'abah pattern, generalized) | **small** | 6/4/2 |
| Single incident (kill undead in the wild, etc.) | day-to-day faucet | day-to-day | ~0.25-0.5, daily-capped |

Per `(quest-outcome x deity)`:
- **milestone** if the matched tag is **C** (core) for that deity AND the stage is a
  `completion`/terminal outcome. Big one-time piety swing (the deity's primary/thematic quests).
- **small** for everything else: S/m tags, intermediate stages, and the former
  cross-generation fan-out breadth cells.
- **echo tier RETIRED 2026-07-09.** It formerly paid 1-3 (half of small) to keep
  ~40-quest-per-deity fan-out from distorting pacing. Per the event-scale decision,
  a quest completion should never pay a trivial 1-3; all 533 echo rows were promoted
  to small (2-6). `value.echo.*` remains in the compile value table but is now unused.
- Final delta = base(magnitude) x intensity(C/S/m). Quest swings are one-shot and
  NOT anti-farm-gated (uncapped straight to AwardPiety), so milestone quests move the
  needle hard toward the 85-Champion budget (see [[piety-pacing-model]]) — completing a
  deity's core questline is intended to carry a focused player toward Champion.

### C2. Race-stance modulation (CRITICAL — the "matrix" dimension)
A deity's profile is **universal** (what the god likes/dislikes). The piety effect
for a given PLAYER is the profile valence **modulated by that player's race-stance**
toward the deity, read from the EXISTING `references/phase4/PDV_StanceMatrix.csv`
(Aedra/race) and `PDV_DaedricRacePrinceMatrix.csv` (Princes):
- **NATIVE** -> full gain/loss as profiled (your god, your values).
- **FOREIGN / TOLERATED** -> dampened (you notice, but it's not your covenant).
- **TABOO / HOSTILE** -> an approving act becomes **stigma/penalty**, not reward
  (an Orc who pleases Boethiah is shamed, not blessed). Disapproving acts may be
  neutral or even mild relief.
- **CURSE-ACCESS** (Hircine=lycanthropy, Molag Bal=vampirism) -> the approving act
  is the curse itself; handled by the curse layer, not normal piety gain.

So one quest choice (e.g. DA02 sacrifice) fans out: **Boethiah + (native Dunmer)**,
**Stendarr/Mara/Arkay - (their disapprove)**, **Orc -> Boethiah stigma (taboo)**,
**Mephala + (deceit)** — exactly the multi-god matrix you described. The reacting
SET per player = their race's deity roster + the 16 Princes.

---

## Part D — Additional methods for thin gods (the Namira-class supplement)

The pilot showed only a few hyper-narrow gods come up short on quests
(Namira=1; Sanguine/Peryite/Vaermina/Dibella/Clavicus likely also thin). For these,
quests are supplemented (NOT replaced) by:
1. **Artifact-acquisition hooks** — claiming the Prince's artifact = strong one-shot
   (Ring of Namira, Sanguine Rose, Spellbreaker/Peryite, Skull of Corruption/Vaermina,
   Masque/Clavicus). Tag `acquire_daedric_artifact:<self>`.
2. **Perk/ability + repeatable-act hooks** — the daily-faucet layer carries these
   (Namira cannibalism via the Ring/feast; Sanguine via drink/feast; Dibella via art/
   speech). These are the repeatable acts, not quests.
3. **Faction-join hooks** — joining a guild = one-shot for the patron(s)
   (Dark Brotherhood -> Sithis +, Arkay/Stendarr -; Thieves Guild -> Nocturnal/Rajhin +).
4. **Generic moral-category fallback** — for a near-empty god, allow its core tag to
   fire on ANY quest carrying it, even peripheral (lower the intensity gate), so the
   pool is never zero.

Thin gods are flagged in the per-quest pass; their supplement list is finite and
named, not a redesign.

---

## Part D-2 — Thin-god proof-of-concept (read-and-judge, cited)
Validated 2026-06-08: every thin god has keyword-invisible reactions readable from
the CSV journal text. Branching Daedric quests yield BOTH a Prince gain and an
opposing-god loss (the rich matrix). Line refs = `vanilla-quest-stage-readback.csv`.
- **Namira** — DA11 *The Taste of Death* (line 531): s100 feast on Verulus →
  `cannibalism`(C) **+milestone** + Ring of Namira; opposing branch s250/500 (kill
  Eola / kill Verulus outside shrine) → Namira **loss** + **Stendarr/Mara/Arkay +**.
- **Sanguine** — DA14 *A Night To Remember* (line 545): whole arc `revel_indulge`(C);
  s200 reveal + Sanguine Rose → `serve_a_daedra:sanguine`+artifact **+milestone**.
- **Peryite** — DA13 *The Only Cure* (line 543): s40/s75 kill Orchendor for Peryite →
  `serve_a_daedra:peryite`(C) **+milestone** + Spellbreaker. (Journal says "kill", not
  "plague" — keyword-invisible.)
- **Vaermina** — DA16 *Waking Nightmare* (line 554): explicit branch s197 — take Skull
  /murder Erandur → Vaermina **+milestone** + Mara/Stendarr **−**; destroy Skull →
  Vaermina **−** + Mara/Stendarr **+**.
- **Clavicus** — DA03 *A Daedra's Best Friend* (line 508): s155 kill Barbas+keep Rueful
  Axe vs s200 reunite+Masque → `serve_a_daedra:clavicus`+artifact; killing loyal Barbas
  → Mara/Stendarr **−**.
- **Dibella** — her quest *The Heart of Dibella* (`T01`/`023B6C:Skyrim.esm`; NOTE: the
  earlier handoff mislabeled this as `t02`/`0211D5`, which is actually *The Book of Love*
  /Mara) was **NOT in the candidate CSV** (filed Temple/Favor, not moral-choice).
  **RESOLVED 2026-06-08:** the Temple/Favor sweep (Tranche3) pulled the narrow-Aedra
  temple quests into scope (Dibella/Mara/Zenithar/Kynareth). Dibella stays quest-thin
  by design (Heart of Dibella is mechanically a `protect_the_weak` rescue = Stendarr's
  domain); she is carried by the `aesthetic_devotion` faucet + Agent-of-Dibella + shrine
  layers (Part D-3). + DA14 opens in the Temple of Dibella (mild restitution read).
Each thin god reaches ~a dozen via: own Daedric quest (1-3 branch cells) + artifact
acquisition + repeatable perk/faucet acts (Part D) + opposing-branch losses from other
gods' quests.

## Part D-3 — Authored thin-god faucet acts (Method 2, 2026-06-08)
The repeatable daily-faucet hooks (Part D method 2) are authored in
`PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` for the six thin gods + Hermaeus
Mora (Namira, Sanguine, Peryite, Vaermina, Clavicus, Dibella, +Mora). These are the
**small day-to-day** signals; the **milestone** one-shots (method 1, artifact
acquisition) are already in Tranche1 (DA01-DA16), and faction-join one-shots
(method 3) are in the quest tranches (DB->Sithis, TG->Nocturnal/Rajhin). Every
faucet pulse is anti-farm-capped (1/dawn, or 1/ever for marriage, 1/book for Black
Books) per [[anti-farm-cap-requirement]].

**Findings / flags from authoring (Dibella gap RESOLVED 2026-06-08 by user):**
- **Dibella vocabulary gap — RESOLVED, both (a)+(b):** (a) added the
  `aesthetic_devotion`(C) tag to Part A and to Dibella's profile as her core domain;
  (b) she also still leans on the Agent-of-Dibella perk + shrine layer. Faucet now
  carries her core tag via **adornment** (OnObjectEquipped of fine apparel/circlet/
  jewelry, GOOD); **perform music/create art** is DEFERRED (no vanilla repeatable —
  reserved for modded content + the custom-content-flagging pass).
- **Buildability flags resolved/narrowed:**
  - Dibella "alms to a beggar" upgraded HARD->GOOD: hook the vanilla **"The Gift of
    Charity"** MGEF (give a beggar 1+ gold; vanilla self-gates to once/4 in-game hr).
  - Clavicus "favorable bargain" upgraded HARD->MEDIUM (hand-authored): hook the
    specific **quest persuade/intimidate-success INFOs** that net a concession
    (curated per-quest dialogue fragments, not a generic event). Masque-wear stays
    the always-on fallback.
- **Black Book owner-coordination:** the Mora "read a Black Book" faucet must not
  double-fire with any BookRead receiver (per the exclusion audit's pick-one-owner
  rule).
- **Method 4 (generic moral fallback) = a WIRING rule, not data:** for a still-thin
  god, lower the intensity gate so its core tag fires on ANY quest carrying it
  (even peripheral), so the reaction pool is never zero. Applied at wiring time.

## Part E — Per-quest classification pass (read-and-judge; validated method)
**Primary source = the CSV `stage_log_summary`** (it already carries branch-resolved
journal text, both outcomes per cell). houseCARL = record/editorId/load-order-winner
confirmation only (it collapses stages to counts). UESP via **WebSearch** (WebFetch is
403-blocked) only to disambiguate a terse branch.

**Procedure (per quest):** (1) pull the CSV row by `editor_id`; read
`stage_log_summary`+`objective_summary`+`completion_stages`/`fail_stages`. (2) identify
the meaningful moral outcome(s) — terminal/branch stages where the player DID something
judgeable (spare/kill, cleanse/corrupt, feast/refuse, bargain/reject). Only pure
travel/fetch/monitor stages with no player act are ignored. **A questline's
progression beats DO count where a deity has a relevant read — a quest is the
completion of an arc and "it's a middle beat" is NOT grounds to skip it (doctrine
2026-07-09).** The main questline especially should be covered end-to-end for the
appropriate deity: the lore beats (Alduin's Wall, Elder Knowledge, the Throat of the
World) are disciplined-study / ancient-record / forbidden-knowledge for
Julianos/Xarxes/Mora; the covenant runs Akatosh through the whole arc; Season Unending
is peace for Mara/Stendarr; and so on. (3) tag each outcome with Part A act-tags BY READING. (4) for each
god whose Part B/B-2 profile contains a matched tag, emit a cell: valence from
approve/disapprove, magnitude from intensity(C/S/m) × stage type (completion=milestone,
intermediate=small). (5) cite the journal line (or UESP/WebSearch if ambiguous).
(6) race-stance modulation (Part C2) applied at WIRING time, not in the judge cell.

**Output schema (one row per quest-outcome × reacting deity):**
`editor_id | quest_name | outcome_stage | outcome_text(branch) | act_tags | deity |
valence(+/-) | intensity(C/S/m) | magnitude(milestone/small) | citation`

**Rules:** judge may emit ONLY Part A tags (vocabulary is the law); valence is LOOKED UP
from Part B/B-2 (not invented); for any quest with `fail_stages` or multiple
`completion_stages`, emit a cell for EACH mutually-exclusive branch (DA11/DA16/DA03 are
the template) or note "single outcome". Keep `tools/pdv_quest_reaction_pilot.mjs` as a
**regression/disagreement detector** — quests the keyword pass tags that the read pass
drops (or vice versa) are flagged for human audit, not silently trusted.

**Build order (Opus/high, one-time curated artifact, frozen as a checked-in table):**
1. Pull Temple/Favor quests into scope for the narrow Aedra (Dibella `t02` etc.).
2. Thin-god + branching-Daedric tranche first (~16 quests, highest value — use Part D-2
   as the template).
3. Sweep the remaining single-outcome salient quests.
