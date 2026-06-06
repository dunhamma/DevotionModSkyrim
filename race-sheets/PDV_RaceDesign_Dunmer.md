# PDV Race Design — Dunmer
**Last updated:** 2026-05-19
**Implementation status:** LOCKED (ancestor substrate, focus gate, curse posture, and Daedric deviation option map)
**Status:** Implementation locked for 1.0 experience shape; launch content weighting remains tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.4)

---

## Religious Identity

Dunmer religion in 4E 201 is a religion of displacement. The Tribunal is dead. Morrowind was destroyed. The ancestral tombs are unreachable. What remains is a faith carried in the body — the morning ash-prayer that doesn't require a shrine, the ancestor-consultation that doesn't require a tomb, the Good Daedra acknowledgment that predated the Tribunal and survives its fall. Dunmer in Skyrim aren't practicing a diminished version of their faith. They're practicing the core of it, stripped of everything that wasn't essential.

Playing a Dunmer should feel **cumulative and internally coherent**, never like competing mutually exclusive gods. The ancestor layer is always present. The Good Daedra deepen it. Choosing a primary focus deepens it further. Nothing replaces anything.

**Core design intent:** Dunmer devotion should feel like layering, not choosing. The infrastructure ceiling (no proper tombs, no household shrine in Skyrim) should be felt but not punishing. Absence is honest; it doesn't need to be inflicted on the player mechanically.

---

## Worship Structure

```
No setup choice needed — Dunmer worship is layered, not path-based

Layer 1 — ALWAYS ACTIVE: Ancestor ash-prayer
  Every Dunmer maintains this regardless of everything else
  Cannot be opted out of — it's constitutive, not optional
  Foundation that all other layers sit on

Layer 2 — STANDARD FOR DEVOUT: Good Daedra acknowledgment
  Azura, Boethiah, Mephala alongside ancestor practice
  Not a separate choice — natural deepening of Layer 1
  Re-emerging as dominant public Dunmer faith in 4E 201
  Broad worship cap: Tier 2 (Faithful) across Layer 1 + 2 combined

Layer 3 — OPTIONAL DEPTH: Primary Good Daedra focus
  Player commits to ONE of the three Good Daedra
  Triggered by sustained piety/signal threshold (offer system, same as poly races)
  Ancestor practice (Layer 1) remains at FULL weight always
  Other two Good Daedra remain at x0.75 after Layer 3 commitment

Daedric deviation - OPTIONAL RUPTURE / PACT: other Daedric Princes
  Uses the global Daedric path system, not a Dunmer path enum
  Presents as deviation, trial, pact, taboo, or foreign pressure
  Ancestor substrate remains present unless curse/posture state interrupts it
```

**Critical distinction:** Choosing a primary Good Daedra never competes with ancestor devotion. They are theologically the same tradition at different depths — Azura being your primary focus doesn't reduce your ancestor relationship, it adds weight on top.

**Implementation split (LOCKED):** Do not implement `PDV_State_DunmerPath` as a path/focus enum. Dunmer has no selectable worship path. Native focus uses the shared patron state model: `PDV_GLO_PatronState` for broad/shared vs active primary commitment and `PDV_GLO_PatronDeity` for the accepted focus. Dunmer-specific state is reserved for the ancestor substrate posture, not for Azura/Boethiah/Mephala choice.

**Ancestor substrate implementation (LOCKED):** The always-active ancestor layer is origin-gated through `PDV_Substrate_DunmerAncestor`. Existing substrate keys use the `PDV.Substrate.DunmerAncestor.*` prefix, including `Metric`, `Tier`, `LastEvent`, `PrayerCount`, and `HomeCount`. Add posture as `PDV.Substrate.DunmerAncestor.Posture` if a StorageUtil key is needed, with optional CK-readable mirror `PDV_GLO_State_DunmerAncestorPosture`.

**Ancestor posture enum (LOCKED):** `PDV_State_DunmerAncestorPosture` uses `Normal = 0`, `Strained = 1`, `Silent = 2`, and `RestoredScarred = 3`. `Normal` is the launch default for living Dunmer. `Strained` covers werewolf/ritual-unclean states. `Silent` covers active vampirism, where ancestor responses are inert. `RestoredScarred` covers post-cure return: the ash-prayer works again, but the substrate remembers the silence.

**Focus gate (LOCKED):** Native Dunmer focus uses the global formal-offer gate: Faithful / `50` persistent piety by default, qualifying signal activity on at least two separate in-game days within seven, dawn-only offer evaluation, per-deity cooldowns, no persistent offer queue, and stable accepted patron for 1.0. The offer language should present the moment as a Reclamation deepening through the life already being lived, not as the player abandoning ancestors or choosing a replacement religion.

**Daedric deviation rule (LOCKED):** Dunmer focused commitment is not limited to Azura, Boethiah, and Mephala forever. Native 1.0 Dunmer focus is the three Reclamations; non-Reclamation commitments may qualify only through the global Daedric path system and should present as deviation, trial, pact, taboo, curse pressure, or foreign bargain. Aedric patron commitment is not a Dunmer 1.0 path.

**Contextual favor rule (LOCKED):** The shared Layer 1 + Layer 2 state can trigger contextual favors before a primary Good Daedra focus. This is not broad pantheon worship; it is the ancestor ash-prayer and the Reclamations answering the same life. Shared favors stay mostly Quiet or Noted. Marked moments usually wait for primary focus, vampire cure/restoration, major diaspora burden, or major Good Daedra quest recognition.

**Infrastructure ceiling (LOCKED):** No passive devotion decay — portable shrine assumed maintained. Proper burial rites, ancestral tomb visits, and full House shrine maintenance are impossible in Skyrim and are never surfaced as events. This naturally reflects diaspora reality without punishing the player for something they cannot do.

**Tribunal Memory (LOCKED):** All Dunmer carry the weight of the Tribunal's fall. This is flavour only — no mechanical weight. Manifest as occasional notification text referencing Vivec/Sotha Sil/Almalexia on certain devotional acts. Not a separate path, not a scoring system.

---

## Focus Options, Tags, And Hooks

These options use the shared patron/Daedric machinery. The table marks what is native, what is a Daedric deviation, and what hook surface makes the option buildable. Class appeal is a design balance check: every common playstyle should see at least one attractive Dunmer-shaped route without flattening all Princes into generic class perks.

| Option | Dunmer tag | Path / signal tag | Strongest 1.0 hooks | Class appeal | Implementation posture |
|---|---|---|---|---|---|
| Azura | Native Reclamation | `Fate-dawn-dusk-prophecy`; thresholds, painful truth, transformation | `The Black Star`, Azura shrine, artifact outcome, dawn/dusk threshold acts, cure/restoration beats | Mage, pilgrim, healer/restorer, roleplay-heavy wanderer | Normal Dunmer focus. No outsider stigma. Ancestors remain full ground floor. |
| Boethiah | Native Reclamation | `Struggle-overthrow-trial`; trial, overthrow, self-authorship | `Boethiah's Calling`, sacrifice/betrayal outcome, boss or higher-level kills, false authority removed, Altmer/Thalmor rivalry beats | Warrior, spellsword, battlemage, assassin, revolutionary | Normal Dunmer focus. Avoid generic cruelty and generic violence. |
| Mephala | Native Reclamation | `Web-secret-murder-clan`; hidden obligation and survival networks | `The Whispering Door`, Ebony Blade, Thieves Guild/network stages, protected secrets, Grey Quarter hidden-community support | Thief, assassin, bard/social manipulator, merchant-network character | Normal Dunmer focus. Avoid generic crime, theft, and random murder. |
| Malacath | Taboo Daedric deviation; House of Troubles-adjacent | `Oath-exile-code-vengeance`; harsh code, exile, vengeance | `The Cursed Tribe`, Volendrung, Blood-Kin/stronghold context, rejected/outcast defense | Heavy warrior, smith, outcast, oath-bound mercenary | Daedric path only. Not a normal Dunmer lane; hard rededication on exit. |
| Mehrunes Dagon | Taboo Daedric deviation; House of Troubles | `Destruction-revolution-ruin`; catastrophic overthrow | `Pieces of the Past`, Mehrunes' Razor, destructive quest outcomes, ruin-aligned choices | Destruction mage, rebel, warlord, chaos fighter | Daedric path only. High rupture; do not reward generic destruction spam. |
| Molag Bal | Taboo Daedric deviation; House of Troubles / vampire pressure | `Domination-vampirism-enslavement`; power through violation | `The House of Horrors`, active vampirism, Mace of Molag Bal, Volkihar/domination choices | Vampire, dark knight, domination mage | Curse/rupture path only. Ancestor posture usually `Silent` during active vampirism. |
| Sheogorath | Taboo Daedric deviation; House of Troubles pressure | `Madness-disruption-instability`; warped outcomes | `The Mind of Madness`, Wabbajack, instability choices, reality-disrupting outcomes | Chaos mage, trickster, wild-card roleplayer | Daedric path only. Hard rededication; keep distinct from Sanguine revelry. |
| Meridia | Foreign / tolerated utility | `Cleansing-light-anti-undead overlay`; anti-undead zeal | `The Break of Dawn`, Dawnbreaker, undead and necromancer cleansing | Paladin, undead hunter, restoration mage, Dawnguard-style warrior | Daedric path or tolerated access. Useful, but not a Dunmer religious center. |
| Hircine | Foreign curse pressure | `Hunt-lycanthropy-predator`; beast-shape and predator logic | `Ill Met by Moonlight`, active lycanthropy, Companions werewolf state, hunt milestones | Hunter, ranger, werewolf, survival fighter | Daedric/curse pressure only. No stable Dunmer framework; cure or abandon is default. |
| Nocturnal | Taboo outsider pressure | `Shadow-oath-luck-debt`; shadow oath and luck debt | Thieves Guild, Nightingale oath, Skeleton Key | Thief, stealth archer, nightblade, luck-driven rogue | Daedric path only. Mephala is the native hidden-network option; Nocturnal is an external oath. |
| Hermaeus Mora | Foreign dangerous knowledge | `Forbidden-knowledge-artifact`; truth at cost | `Discerning the Transmundane`, Oghma Infinium, Black Books, Apocrypha | Scholar, mage, enchanter, seeker of secrets | Daedric path only. Scholars may engage, but it is not Dunmer core faith. |
| Namira | Foreign corruption / outcast hunger | `Revulsion-decay-outcast-hunger`; taboo survival | `The Taste of Death`, Ring of Namira, corpse-taboo acceptance | Outcast, cannibal/dark survivalist, horror roleplay | Daedric path only. Strong social and ancestor friction. |
| Sanguine | Foreign indulgence | `Excess-temptation-indulgence`; revelry and lost restraint | `A Night to Remember`, Sanguine Rose, revelry/excess contexts | Bard, social rogue, party character, temptation arc | Daedric path only. Appealing but intentionally unreliable. |
| Clavicus Vile | Foreign bargain | `Bargain-wish-contract`; deals and loopholes | `A Daedra's Best Friend`, Masque/Rueful Axe outcome, Barbas/deal logic | Merchant, negotiator, pact mage, social climber | Daedric path only. Bargain price must remain visible. |
| Peryite | Foreign affliction-order | `Plague-order-lowest-task`; disease, unpleasant duty, imposed order | `The Only Cure`, Spellbreaker, disease/affliction contexts | Shield user, alchemist, plague doctor, endurance build | Daedric path only. Useful defensive fantasy, not ancestor/Reclamation faith. |
| Vaermina | Foreign dream/nightmare | `Dream-nightmare-memory`; fear and sleep corruption | `Waking Nightmare`, Skull of Corruption, sleep/nightmare corruption | Illusion mage, dream/nightmare roleplay, fear caster | Daedric path only. Strong memory/sleep price; not ancestor communion. |

**Class balance check (LOCKED):** Native Dunmer focus must already cover the core class spread: Azura for mage/restoration/threshold characters, Boethiah for warrior/spellsword/revolution characters, and Mephala for stealth/social/network characters. Non-Reclamation Daedric options broaden appeal for undead hunters, scholars, hunters, vampires, outcasts, merchants, bards, tanks, and nightmare/illusion builds, but they remain Daedric deviations rather than normal Dunmer religion.

---

## Tier Rewards

### Layer 1 — Ancestor Substrate (always active, no tier gate)

The ancestor layer doesn't deliver boons in the traditional tier sense — it provides the *interpretive context* for everything else. Its active mechanical presence is the piety scoring it provides, plus a few passive expressions:

- Ancestor consultation flavor text on significant combat victories (the ancestors witnessed it)
- Dunmer solidarity acts (Grey Quarter interactions, diaspora support) score through this layer
- This layer generates the ground floor of Dunmer piety even when Layer 2 and 3 are undeveloped

### Tier 1 — Observant (Layer 1 + 2 active)
*The Good Daedra are acknowledged. The ash-prayer is maintained.*

- Resist fire 5% (Dunmer race amplified by active faith maintenance)
- Resist magic 5% (Good Daedra acknowledge the student of their ways)
- Ancestor-coded combat acts generate piety (any combat where you win without dishonor)
- Dawn and dusk signal windows generate small piety (Azura's twilight is always present in Dunmer practice)

### Tier 2 — Faithful (Layer 1 + 2 deepening)
*The Good Daedra relationship is stable. The diaspora is endured with dignity.*

- At dawn: +10% fire resistance and +5% magic resistance from dawn until midday (Azura's protection at the day's threshold)
- After defeating a rival-strength enemy: ancestor recognition — +25 stamina immediately after a power attack kill
- Dunmer solidarity acts (Grey Quarter, refugee protection, diaspora solidarity) generate significant piety
- Good Daedra shrine interactions generate full piety (Azura, Boethiah, Mephala — these are your gods)
- Relevant Daedric quest content (Azura's Star, Boethiah's Calling, Whispering Door) generates very strong piety
- Tribunal memory flavor text appears at appropriate moments (first visit to Dunmer settlements, major Good Daedra events)

### Tier 3 — Devoted (Layer 3 primary focus committed)
*This Daedric Prince knows your name. The ancestor layer confirms it.*

The detailed Tier 3 rows below are the native Reclamation commitments. Non-Reclamation Daedric commitments use the global Daedric boon/price/stigma contract, modified by the Dunmer tag table above, rather than receiving a fourth normal Dunmer Reclamation tier.

**Azura focus:**
- *Champion moment:* Painful truth and transformation have weight. Major quest completions, dungeon entries, cure arcs, exile beats, and significant choice-points give brief flavor text in Azura's voice when the character becomes something truer, not merely something stronger. Dawn-blessing is amplified — fire and magic resistance combined 20% from dawn until noon. Star-born favor: nighttime magic cost -10%.
- *Specific payoff:* Azura's Star quest gives special recognition privilege at Tier 3 — the stone itself responds differently. Truth-revealing choices, transformation/cure arcs, moonstone-adjacent locations, and twilight hours generate piety. Dawn and dusk are empowered because they are thresholds where change can be faced.
- *Lore rationale:* Azura is the protector of Dunmer through displacement and change. She warned the Chimer of betrayal, marked them into the Dunmer, and sustained them through the Tribunal era. At Champion, she watches the moments where truth hurts and becoming cannot be avoided.

**Boethiah focus:**
- *Champion moment:* Strength proved leaves a mark. After defeating a significant enemy (quest boss, named antagonist, enemy considerably higher level), 24-hour carry weight +25 and minor power attack stamina reduction (ancestors bore witness to something worth recording). Combat versus Altmer generates extra piety at this tier — the rivalry with Auri-El devotees is active.
- *Specific payoff:* Rival-strength kills generate a brief burst of ancestor-layer flavor text ("they have seen"). Overthrow and conspiracy quest content (Boethiah's Calling, any questline involving deposing a leader) gives maximum piety.
- *Lore rationale:* Boethiah tests strength and the overthrow of the unworthy. At Champion, every significant victory is being recorded by your ancestors and acknowledged by the Prince. The rivalry with Auri-El (the Altmer proof slice) is lore-grounded and should feel real.

**Mephala focus:**
- *Champion moment:* Hidden community and maintained secrets have texture. Thieves Guild membership generates strong piety (not as thieves but as members of a hidden network). Protecting Dunmer refugee communities (Grey Quarter support, Windhelm Dunmer solidarity) generates maximum Mephala piety — Mephala's web is the community that survives by not being fully visible to power.
- *Specific payoff:* Information-adjacent acts (selling stolen goods through the Guild, passing information to appropriate parties, maintaining discretion in sensitive quests) give 5% bonus gold (Mephala's web is commercially real). Poison resistance 20%. Special dialogue access in hidden or exile Dunmer communities at Tier 3.
- *Lore rationale:* Mephala's Dunmer relationship is about the hidden community, the web of trust and knowledge that survives when open practice is impossible. In Skyrim, the Dunmer diaspora IS Mephala's domain — hidden, networked, surviving in the spaces others don't look.

---

## Contextual Favor Table

**Status:** Review-cleared (2026-05-18) - implementation locked (2026-05-19); launch content weighting remains

**User-experience proof:** Dunmer contextual favor should feel cumulative and quiet: the ancestors witness, the Good Daedra give shape, and primary focus later sharpens the answer. This should not feel like Nord broad worship, Imperial civic duty, or Redguard sect obligation.

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Shared Ancestors + Good Daedra | Ash-prayer maintained in exile | Portable shrine prayer, dawn/dusk observance, player-owned home prayer bonus | Environmental / after-act | Noted | Core low-friction Dunmer rhythm. Home improves the moment but is not required. |
| Shared Ancestors + Good Daedra | Ancestors witnessed honorable victory | Story Manager kill events, rival-strength enemy, no sneak opener / no dishonorable shortcut where detectable | Momentary combat | Quiet | Should feel like steadiness after being seen, not a dramatic battle power. Anti-farm through daily/cooldown and meaningful-target filters. |
| Shared Ancestors + Good Daedra | Diaspora solidarity | Grey Quarter aid, Dunmer NPC help, refugee protection, Windhelm Dunmer support, family/diaspora quest beats | After-act | Noted | The ancestor layer reads treatment of other Dunmer as devotional conduct. Marked only if the act carries real cost or danger. |
| Shared Ancestors + Good Daedra | Reclamation acknowledgment | Azura shrine / dawn-dusk beat, Boethiah strength-proving beat, Mephala secrecy / hidden-network beat | After-act / environmental | Noted | Pre-focus recognition stays blended. It should suggest all three Good Daedra are culturally present without forcing a primary yet. |
| Shared Ancestors + Good Daedra | Dead and family obligations in exile | Hall of Dead, necromancer/undead boss, family-duty quests, burial-adjacent content where Skyrim exposes it | After-act | Noted | Proper ancestral tomb rites are not available in Skyrim, so only buildable proxies count. Do not penalize missing impossible rites. |
| Azura focus | Threshold kept | Dawn/dusk observance, entering/leaving major quest chapters, major location first entry/clear, post-crisis rest | Environmental / after-act | Noted | The threshold matters because the character is becoming, not because twilight is decorative. |
| Azura focus | Painful truth revealed | `The Black Star` / Azura's Star outcome, betrayal exposed, quest choice that rejects a useful lie, prophetic revelation beat | After-act / rare major | Noted / Marked | Marked when the truth costs safety, power, or belonging. This is Azura's core Dunmer texture. |
| Azura focus | Exile endured without dissolving | Grey Quarter continuity, Solstheim / refugee-adjacent beats, portable shrine far from home, owned-home ash-prayer after displacement | After-act / environmental | Noted | Exile is not failure. Favor should feel like continuity across distance. |
| Azura focus | Changed body witnessed | Vampire/werewolf cure, curse-state confrontation, major disease/ritual cleansing, transformation recovery arc | Rare major | Marked | Reserved for hard theological body-change moments. Azura does not ignore what the player became. |
| Azura focus | Star and twilight rite | Azura shrine, Azura's Star ownership/use, twilight magic-adjacent play, moonstone-adjacent curated locations/items | Environmental / after-act | Noted | Artifact and shrine signals should feel personal at focus, not just stronger Layer 2 shrine piety. |
| Boethiah focus | Trial survived | Rival-strength kill, outnumbered fight, boss defeat, higher-level enemy, survival after being pressed hard | Momentary combat / after-act | Quiet / Noted | Not every kill qualifies. The act must prove strength under real pressure. |
| Boethiah focus | False authority overthrown | Questline leader deposed, corrupt authority exposed/removed, rebellion against oppressive command, Boethiah's Calling | After-act / rare major | Noted / Marked | Marked for major quest outcomes. This should feel like cutting away an unworthy order. |
| Boethiah focus | Betrayal-as-test endured | Sacrifice/betrayal outcome, follower loss/betrayal beats, ambush survived, trust broken and answered with strength | After-act | Noted | Avoid rewarding casual cruelty. The favor is for surviving or resolving the test, not random treachery. |
| Boethiah focus | Chimeric self-authorship | Reject Auri-El/Altmer primacy, defeat Thalmor/Altmer rival in meaningful context, choose Dunmer destiny over imposed order | After-act | Noted | The rivalry with Auri-El should be visible but not farmable; generic Altmer kills alone are too thin. |
| Boethiah focus | Conspiracy moved cleanly | Infiltration quest success, covert overthrow, faction maneuvering, planned strike completed without public collapse | After-act | Quiet / Noted | Boethiah is plots as well as combat. Favor should recognize decisive action, not only brawling. |
| Mephala focus | Hidden community protected | Grey Quarter protection, Dunmer network aid, refugee shielded, Thieves Guild as hidden civic web, safe-house style beats | After-act | Noted | Mephala's web is social survival. This is not generic charity; it is keeping the hidden people intact. |
| Mephala focus | Secret kept with consequence | Discretion in sensitive quest, withheld identity, protected informant, avoided exposure that would harm the web | After-act | Quiet / Noted | Favor triggers only when keeping the secret preserves an obligation or community, not when it is convenient lying. |
| Mephala focus | Lethal secret answered | Ebony Blade / Whispering Door, assassination-adjacent quest, targeted killing tied to hidden loyalty or dangerous knowledge | Momentary combat / after-act | Quiet / Marked | Marked only for major Mephala quest/artifact moments. Do not turn random murder into favor. |
| Mephala focus | Obligation web maintained | Thieves Guild advancement, information handoff, fence/network use, helping contacts without public credit | After-act | Quiet / Noted | The reward should feel like the web tightening helpfully around the player. |
| Mephala focus | Necessary lie held in balance | Successful persuasion/deception where disclosure would harm the hidden community, delicate faction/social outcome | After-act | Noted | This is the survival lie, not casual fraud. Needs curated hooks to avoid rewarding broad crime spam. |

**In-game hook cross-check:** Dunmer is buildable for 1.0 if the launch slice starts with portable ash-prayer, dawn/dusk state, Good Daedra quest/shrine rows, and curated diaspora solidarity. Strong hooks: custom portable shrine activation, player-owned-home bonus, time-window checks, Azura/Boethiah/Mephala shrine and quest stages, the existing Kill Actor route for meaningful victories, and curated undead/necromancer/death-duty content. Medium hooks: Grey Quarter / Dunmer solidarity, honorable victory filters, secret-keeping, conspiracy, and painful truth outcomes depend on whitelist rows. Deferred or authored-heavy hooks: broad Tribunal memory flavor, social survival lies, hidden-community protection, and curse cure/restoration staging.

**Build-facing hook table (feasibility pass):**

| Experience target | 1.0 hook candidate | Confidence | Implementation posture |
|---|---|---|---|
| Ash-prayer maintained in exile | Dunmer portable/private shrine pattern, permanent ash-shrine token, player-owned home/private shrine bonus, dawn/dusk use | Strong custom | Build as PDV-owned activation surface; no passive decay for missing impossible tomb/house shrine infrastructure |
| Dawn/dusk observance | Game-time window checks, shrine/portable prayer, optional outdoor or home context | Medium-strong | Low-value daily/capped signal; twilight frames thresholds but does not become all of Azura |
| Ancestors witnessed honorable victory | Kill Actor route, direct-player attribution, meaningful enemy, no sneak opener where detectable, rival-strength/boss context | Medium | Conservative honor filters; daily/cooldown limits; reward steadiness, not a combat spam package |
| Diaspora solidarity | Grey Quarter / Windhelm Dunmer aid, named Dunmer NPC help, refugee/family protection, Solstheim or refugee-adjacent stages | Medium | Curated quest/NPC rows only; no generic Dunmer proximity scoring |
| Reclamation acknowledgment | Azura's Star, Boethiah's Calling, The Whispering Door/Ebony Blade, Good Daedra shrine activations, artifact ownership/use | Strong for major quests, medium for artifacts | One-shot major rows plus capped shrine/artifact use; keep shared layer blended until focus is chosen |
| Dead and family obligations in exile | Hall of the Dead / Arkay-adjacent service used as proxy, necromancer operation clears, undead boss/location clear, family-duty quests | Medium-strong | Buildable proxies only; never penalize the lack of real ancestral tomb rites in Skyrim |
| Curse cure and scar return | Vampire/werewolf state detection, cure quest/event, restoration notification, substrate re-enable marker | Planned medium | Treat as authored restoration state, not ordinary favor spam; likely belongs in implementation-lock pass |

**Primary-focus rule:** Azura, Boethiah, and Mephala each receive five trigger families because the three Good Daedra are full Dunmer religious centers, not thin patron tags. Focus rows should not repeat the whole ancestor substrate; they describe what the chosen Prince adds on top of the always-active ancestor ground floor.

**Azura favor boundary (LOCKED):** Dawn, dusk, night, and magic-adjacent play do not trigger Azura contextual favor by themselves after the basic shared-layer rhythm. A focused Azura favor requires a real threshold, painful truth, transformation, exile-continuity, artifact/shrine rite, or curated major transition. Twilight frames the moment; it is not the whole moment.

**Boethiah favor boundary (LOCKED):** Random betrayal, generic violence, casual cruelty, and ordinary faction hostility never trigger Boethiah contextual favor. A Boethiah favor requires trial, overthrow, false authority, betrayal-as-test, Chimeric self-authorship, or curated quest/artifact context.

**Mephala favor boundary (LOCKED):** Random murder, casual theft, convenient lying, and generic crime never trigger Mephala contextual favor. A Mephala favor requires hidden obligation, protected community, dangerous knowledge, targeted hidden violence, a maintained network, or curated artifact/quest context.

---

## Signature Friction

**The infrastructure ceiling** is the primary friction — and it's honest about what it is. You cannot do proper burial rites. You cannot visit ancestral tombs in the way your religion requires. The household ash-shrine you should be maintaining does not exist as a mechanic in the normal sense. These are losses built into playing a Dunmer in Skyrim, and the mod acknowledges them without pretending they're optional obstacles.

**The ancestor layer watching** is the subtler ongoing friction. The ancestors interpret everything through the lens of Dunmer honor: combat acts are witnessed (honor or shame), social choices have implications, how you treat other Dunmer matters specifically. An ash-payer who exploits the Grey Quarter residents has a disconnect between their devotional practice and their actual conduct that the ancestor layer will register.

**Specific friction surfaces:**
- Dunmer who ignore the Grey Quarter, avoid other Dunmer, and never engage with diaspora solidarity are letting Layer 1's social dimension go quiet even while they maintain combat scoring.
- Dunmer who become vampire face the hardest consequence in the mod — the ash-prayer going completely silent (see Curse States). The cure and scar arc is meaningful precisely because of this.
- The Good Daedra cannot be replaced with Nine Divines worship — a Dunmer who tries to worship Akatosh and Mara instead of Azura and Boethiah simply isn't operating within their religious frame. The mod doesn't block it, but it doesn't reward it within the Dunmer system.

---

## Neglect Texture

Dunmer neglect is **silence**, not punishment. The ancestors don't curse you for drifting — they stop responding.

- **Layer 1 neglect:** The morning ash-prayer signals stop being generated (player stops doing the acts that feed Layer 1 — no more combat acts read as witnessed, no more solidarity weighting, no dawn/dusk window scoring). The ancestor flavor text disappears. Shrines feel like stone. The texture of being held by something very old quietly fades.
- **Layer 2 neglect:** The Good Daedra acknowledgment loses its warmth. Fire and magic resistance bonuses thin. The dawn pulse stops. Nothing dramatic — just a return to what Skyrim's world already is without the mod's intervention.
- **Layer 3 neglect:** If you committed to Azura but stop doing dawn/dusk observance, threshold events, and Azura-adjacent content, the relationship at Tier 3 decays toward Tier 2. The Devoted blessings thin first, then the tier drops. Azura doesn't leave loudly — she just stops showing up at your thresholds.

**No decay on infrastructure ceiling:** The things you *can't* do (proper tomb visits, household shrine maintenance) never trigger neglect. Only what you could do and don't generates decay. This distinction is important for feel — the Dunmer is already bearing the weight of diaspora; the mod shouldn't pile on for circumstances outside the player's control.

---

## Signal Examples

| Action | Layer | Cadence | Notes |
|--------|-------|---------|-------|
| Interact with a Good Daedra shrine (Azura, Boethiah, Mephala) | Layer 2 | Daily cap | Strong, reliable, anti-farm via daily cap |
| Help another Dunmer NPC (Grey Quarter, refugee protection) | Layer 1 | Per event, cooldown | Windhelm Assemblage counts heavier |
| Win a combat without sneak attack or crowd control | Layer 1 | Daily cap | "Ancestors witnessed" frame; ancestor-honor combat |
| Complete Azura's Star quest | Azura | One-time | Maximum piety event for Azura focus |
| Complete Boethiah's Calling | Boethiah | One-time | Maximum piety event for Boethiah focus |
| Complete The Whispering Door / Mephala-adjacent quest | Mephala | One-time | Maximum piety |
| Observe dawn or dusk (time-based, outdoors or shrine) | Layer 2 / Azura | Daily cap (2x — dawn + dusk) | Low-cost vanilla hook; Survival Mode overlap |
| Defeat an Altmer in combat | Boethiah | Per event, cooldown | Rivalry signal; most enemies are not Altmer, so farmability is limited |
| Join or advance in Thieves Guild | Mephala | Per guild advance | Hidden network signal |
| Protect Dunmer from discrimination or violence | Layer 1 | Per event | Windhelm-heavy; naturally limited |
| Read Azura texts (*Invocation of Azura*; *Azura and the Box*) | Azura focus | Per book, one-time | Reclamation acknowledgment; notifications: `PDV_Notif_Dunmer_FavorNoted_Azura_BookRead_*` |
| Read Boethiah texts (*Boethiah's Glory*; *Boethiah's Proving*) | Boethiah focus | Per book, one-time | Reclamation acknowledgment; notifications: `PDV_Notif_Dunmer_FavorNoted_Boethiah_BookRead_*` |
| Survive a fight you should have lost | Boethiah / Layer 1 | Per event, cooldown | Difficulty-filtered — enemy must be significantly higher level |

---

## Implementation Notes

**Vanilla hook surface:** Moderate. Dunmer-specific content in Skyrim is sparse (Grey Quarter, Morrowind refugees, a few named Dunmer NPCs), but the Good Daedra quest content (Azura's Star, Boethiah's Calling, Whispering Door) is rich and natural to Dunmer play. Dawn/dusk time-window triggers require a simple timer check in the update loop.

**Complexity flags:**
- **Layer 1 as always-active scoring:** The ancestor layer needs to be fully functional before any Layer 2 or 3 content is built. It's the substrate everything else sits on. Start here.
- **Dawn/dusk time window:** Requires a state check in the existing dawn/dusk event triggers or a simple periodic subsystem. Low cost, medium implementation care needed to get window timing right (not instant, not too wide).
- **Azura flavor text system:** The threshold-event flavor text (prophetic voice at major quest completions, dungeon entries) requires a list of trigger events and localized notification strings. This is content work more than script work — the hook exists in the existing event system, the text needs writing.
- **Tribunal Memory flavor text:** Same pattern — content work, not new systems. A curated list of trigger events (first Grey Quarter visit, Azura quest, certain Dunmer NPC conversations) maps to cosmetic notification strings. No scoring implications.
- **Boethiah Altmer rivalry:** Piety bonus on Altmer kills requires either faction-check (Altmer faction) or race-check on the killed actor. Race-check is simpler and accurate enough — Thalmor, College Altmer, and wandering Altmer all qualify, which is correct lore-wise.

**Cost class profile:**
- Good Daedra shrine interaction: Cost Class A (activation event)
- Grey Quarter / Dunmer solidarity: Cost Class A-B (dialogue events, quest stages)
- Dawn/dusk window scoring: Cost Class B (time-state periodic or dawn/dusk trigger)
- Flavor text systems: Cost Class A (notification strings on existing events)
- Layer 1 combat scoring: Cost Class A (Story Manager kill events with race filter removed — any honorable kill)

---

## Curse State Summary

**Vampire:**
- Ash-prayer goes **SILENT** — ancestors do not respond to the undead; Layer 1 events become inert (logged but weighted at zero)
- Layer 2 Good Daedra path weight **increases**: Boethiah and Mephala fully reachable; Molag Bal becomes available as new primary god via Daedric system; Azura's relationship with Dunmer vampires is complicated (she knows, and her response is neither simple acceptance nor simple rejection — this is content to develop)
- On cure: ash-prayer functionality **restores**; permanent piety/tier scar (ancestors remember the silence); both layers resume at full weight
- Lore rationale: The ancestors are present and they noticed. The silence was real. Cure matters, but it doesn't erase what happened.

**Werewolf:**
- Most theologically homeless Dunmer curse combination — Hircine has no framework in Dunmer cosmology, not recognized by the Reclamations
- Ancestors treat werewolf as ritually unclean: Layer 1 events continue at 50% weight (strained, not silent)
- Layer 2 continues at 75% weight — Good Daedra tolerate it more than ancestors do
- No alternative path opens (unlike vampire, where Good Daedra path remains strong)
- House Telvanni exception: if player has Telvanni-associated acts in event log, werewolf penalty reduces slightly — Telvanni tolerate unusual transformations; not a full path, just a minor weight modifier
- Lore rationale: Vampire creates a viable alternative theological frame (undead, power, Molag Bal). Werewolf just makes you ritually unclean with no compensating framework.
