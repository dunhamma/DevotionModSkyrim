# PDV Race Design — Orc (Orsimer)
**Last updated:** 2026-06-12
**Status:** Implementation locked for 1.0 experience shape; final hook-costing and reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.9)

---

## Religious Identity

Malacath is not petitioned. He is not thanked. He doesn't receive prayers in the way Mara receives them or Akatosh expects them. He *observes*. He watches whether his people are strong, whether they hold their oaths, whether they provide for their community, whether their craft is worthy. Malacath's favor is not earned through ritual — it is earned through conduct, and withheld when conduct fails.

This is the most demanding theological framework in the mod: there are no shortcuts. You cannot donate to a temple and call it done. You cannot visit a shrine and feel like you've done something. The only thing Malacath acknowledges is the life you're actually living — the quality of what you make, the weight of the oaths you keep, the strength you prove in the moments that test it.

**Core design intent:** Orc should feel like the question is how Malacath's code is carried in this life-mode, not which god is selected. The mode ceiling — Stronghold Orc having the highest ceiling, City and Legion-exile having lower ones — is the central design tension. Reaching Champion as a City Orc is arguably harder than reaching it as a Stronghold Orc, because you're doing it without the structure that makes it possible.

---

## Worship Structure

```
No multiple primary gods — Malacath always
No separate focused-primary deity layer — deepening comes from mode-specific excellence
Player implies or chooses a life-mode, not a different theology

Three life-modes:
  Stronghold Orc  — full expression; forge, community, oath, proven strength
  City Orc        — private fidelity under public compromise; quality labor, dignity
  Legion/Exile    — honor under foreign discipline; contract, endurance, private code

Setup: mode implied by starting choices or chosen explicitly via MCM
Mode progression: limited switching; no casual fluid swapping
Mode ceilings: Stronghold highest; City and Legion lower but with broader flexibility
```

**Trinimac (LOCKED as non-standard):** Important historically and politically. Not a normal player-selectable Orc path in 4E 201 Skyrim. May be available as a rare exceptional ideological pressure or fringe alternative — not a core lane.

**Blood-Kin rule:** Blood-Kin status and stronghold acceptance are the primary gateway into Stronghold Orc standing. Achieving Blood-Kin is the main route into or back to Stronghold mode.

**Contextual favor lane rule (LOCKED):** Orc contextual favor is authored through the current Malacath life-mode, not through one generic Malacath lane. `Stronghold Orc`, `City Orc`, and `Legion/Exile Orc` each count as separate devotional lanes for contextual-favor authoring.

**Feasibility rule (LOCKED):** Stronghold mode may use robust vanilla anchors such as stronghold locations, Blood-Kin, `The Cursed Tribe`, Orc community factions, forge/labor hooks, and proven-strength events. City and Legion/Exile dignity, oath, and service content must use curated high-confidence hooks only: quest stages, faction ranks, favor/disposition proxies, explicit service milestones, or PDV-authored sacred-place/community state. Do not attempt broad simulation of public disrespect, contract honor, or generic oath-breaking unless an implementation pass proves a concrete hook.

**Life-mode selection rule (LOCKED):** `City Orc` is the default bridge state for an Orc who is not currently proven inside a stronghold or bound into a service/exile pattern. `Stronghold Orc` requires Blood-Kin or equivalent stronghold acceptance plus active stronghold conduct; location alone is not enough. `Legion/Exile Orc` requires explicit service/exile commitment or a completed pressure-bearing service milestone; faction membership alone can make the lane eligible but does not switch the favor lane or trigger favor. Mode changes happen at major gates or dawn consolidation after sustained evidence, not from one stray quest, one city visit, or one dungeon. The player may declare a mode during setup/MCM, but the world can challenge or confirm it through high-confidence signals.

**Life-mode implementation rule (LOCKED):** Implement Orc mode as one active state track, `PDV_State_OrcLifeMode`, with exactly one active scoring/favor lane at a time: `City = 0`, `Stronghold = 1`, `LegionExile = 2`. The active state is what modifies Malacath piety rate, contextual-favor eligibility, and any CK-readable mode conditions. Player setup/MCM records intent, not entitlement. If the declared mode is not currently eligible, the active lane remains or returns to `City` until the world confirms it.

Mode switch gates:
- `City` is the fallback/default whenever no other mode is currently confirmed.
- `Stronghold` may switch immediately on a major gate that already proves conduct, such as Blood-Kin gained through stronghold aid or `The Cursed Tribe` resolved in a pro-stronghold way. Otherwise it requires eligibility plus two qualifying stronghold signals on separate in-game days within a seven-day window.
- `LegionExile` may switch immediately on completed pressure-bearing service or explicit exile/service commitment. Mere faction membership grants eligibility only. Soft switching requires two qualifying service/exile signals on separate in-game days within a seven-day window.
- Soft mode switches are evaluated at dawn consolidation. Major gates may switch immediately.
- After a mode switch, automatic soft switching is locked for three in-game days unless a major gate fires.
- Leaving `Stronghold` requires contradiction or sustained confirmed life elsewhere; travel time alone never demotes the player. Leaving `LegionExile` requires completed service resolution plus community reinvestment, or a new stronghold gate; quitting a faction is not enough.

---

## Mode Philosophies

**Stronghold Orc:** The code is fully expressed here. The forge serves the community. The community supports the forge. The chief enforces the code. The shaman interprets Malacath's will. Challenge is how strength is proven. Provision is how belonging is demonstrated. Oath-keeping is how Malacath knows you're serious. Every act of strength, craft, and communal provision feeds the devotion directly.

**City Orc:** The same code, applied without the structure that makes it easy. You still hold your oaths — but your employer doesn't understand what that means. You still do quality work — but the forge guild doesn't care about its spiritual dimension. You still maintain Orc dignity — but you're doing it alone, without a chief or shaman to confirm you're on the right path. Lower ceiling. More resilience required.

**Legion/Exile Orc:** Honor under foreign discipline. The contract IS the oath here. Endurance IS the strength demonstration. Carrying Malacath privately, internalizing his code when there's no community structure to hold it externally, is the faith. The burden is the highest; the devotion ceiling is the lowest. Its compensation is that it's the mode most Orc characters in Skyrim actually live in, and it should feel like a complete devotional life, not a diminished one.

---

## Tier Rewards

### Tier 1 — Observant (all modes)
*Malacath has noted that you exist and that your conduct is pointed in the right direction.*

- Smithing XP +5% (the forge is always the first signal; craft is the primary Orc devotional language)
- Armor rating +5 when wearing Orcish-crafted armor (what you made is part of your faith)
- Resist disease 10%
- Brawl damage +5% (strength is noticed even in informal contest)

### Tier 2 — Faithful (mode-differentiated)
*Malacath has seen enough to confirm the pattern. The code is being carried.*

**Stronghold Orc:**
- Forge excellence: items you craft have improved quality (armor and weapons get one extra tempering improvement chance compared to your perk level baseline)
- After proving strength against a challenging enemy (5+ levels above player), +10 health/sec for 60 seconds post-combat
- Communal provision acts (helping Orc stronghold NPCs, Blood-Kin quests, community support choices) generate strong piety
- Oath-keeping: completing a contract or quest you committed to generates piety proportional to the difficulty of keeping it
- Stronghold recognition: Orc stronghold NPCs treat you with appropriate respect (Blood-Kin-level dialogue, access to merchant/smith services)

**City Orc:**
- Quality labor: completing crafting orders or high-quality work generates piety (doesn't require Orcish-specific; quality is the signal)
- Dignity under pressure: succeeding in a persuasion check against an NPC who is openly hostile or dismissive gives +15% persuasion chance on the next social check (you held the code without being disrespected into abandoning it)
- Orc identity maintenance in mixed society: helping other Orcs anywhere in Skyrim generates piety; not exploiting vulnerable Orcs generates implicit positive weight
- City Orc ceiling: max Tier 2 requires more consistent conduct than Stronghold because there's no community structure confirming the pattern — Malacath has to see it himself

**Legion/Exile Orc:**
- Contract and oath: completing hired or factional work generates piety when the contract was honored under pressure (not when it was easy)
- Endurance: surviving extended difficult quests or dungeon runs (long session with few rests and many enemies) generates piety — Malacath notices the endurance
- Orc dignity in service: maintaining Orc identity and code conduct while serving non-Orc institutions generates modest piety; specifically NOT self-erasure
- Legion Orc ceiling: the lowest, because the foreign discipline context is the farthest from what Malacath designed — but the genuine conduct still scores

### Tier 3 — Devoted
*Malacath saw everything. The code was carried fully. He witnessed it.*

**Mode ceilings apply here:** The actual tier threshold for Champion is the same number across modes, but the piety-per-day rate is lower for City and Legion-exile Orc. Reaching Champion in those modes takes longer and requires more consistent sustained conduct. That's the design — it's harder, and it's supposed to be.

**Stronghold Orc Champion:**
- *Champion moment:* The forge sings. Malacath's witness is complete. Forge-crafted weapons you use deal 5% more damage in your hands — not in anyone else's, only yours (you made them, they know you). Once per day, in a fight where your health drops below 15%, a brief combat fury fires: stamina restored to full, -25% power attack stamina cost for 30 seconds (Malacath's recognition of a genuine test met). Stronghold NPCs treat you as fully recognized — beyond Blood-Kin, into something that carries weight.
- *Specific payoff:* Quality of your best crafting output improves (effective bonus tempering steps). Stronghold challenges (chief tests, communal crises) generate strong piety. The shaman's voice feels present — flavor notifications at stronghold sites at this tier.

**City Orc Champion:**
- *Champion moment:* Quieter than Stronghold, and that's correct. Malacath saw you hold the code in a world that didn't reward it, didn't enforce it, didn't even know what it was. At Devoted tier: quality work always hits the maximum achievable at your current smithing skill (no RNG on the tempering bonus — you always hit the ceiling). Brief resolve bonus when you are insulted, dismissed, or humiliated but respond with dignity rather than capitulation. Malacath's private acknowledgment: no shaman, no stronghold, just the sense that the observation was real.
- *Specific payoff:* Your crafted items are the best you can currently make, consistently. After maintaining dignity in a difficult social encounter (hostile NPC, discrimination, dismissal), next combat has +5 health/sec for its full duration — the internal coherence of not having broken translates into physical steadiness.
- *Lore rationale:* Malacath's test isn't just for people who have the right community. The City Orc who maintains the code without structural support is, arguably, demonstrating something harder than the Stronghold Orc who has a whole community confirming their choices every day.

**Legion/Exile Orc Champion:**
- *Champion moment:* Honor under discipline, fully embodied. At Devoted tier: after completing a significant contract or faction service quest under genuinely difficult conditions, brief combat resolve fires — +5 health/sec for the full duration of the next combat encounter. The endurance is the faith; Malacath acknowledged the endurance. The exile who carried the code alone, in a foreign army, in a foreign province, through years of displacement — that's a Champion.
- *Specific payoff:* In service to a faction (Companions, Dawnguard, Legion, hold guard hired work), brief combat resolve fires after particularly difficult completions. Carry weight +15 (endurance is physical too — Malacath's exiles carry more). After a contract completed with full honesty and full difficulty, brief rest quality improvement.
- *Lore rationale:* Malacath is the god of the spurned, the outcast, the people who were abandoned. Legion and exile Orcs are living his most direct theological statement. At Champion, that statement is complete.

---

## Contextual Favor Table

**Status:** Review-cleared for user-experience shape; implementation hook feasibility added; final hook-costing still pending

**User-experience proof:** Orc contextual favor should feel like Malacath observed the code being carried in the player's actual life condition. Stronghold favor is witnessed by forge, shrine, chief, and community; City favor is private recognition under compromise; Legion/Exile favor is endurance under foreign discipline. None of these should feel like a generic warrior combat package.

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Stronghold Orc | Forge excellence serving the hold | `CraftItem` / PO3 `ItemCrafted`, tempering result, Orcish/quality item families, stronghold or mine location context | After-act / environmental | Noted | No raw crafting counts. Require quality/value/context and daily caps; strongest when work is tied to stronghold provision. |
| Stronghold Orc | Blood-Kin and crisis answered | Blood-Kin state, `The Cursed Tribe` / Largashbur stages, stronghold aid milestones, Malacath shrine / Volendrung context | After-act / rare major | Noted / Marked | Main gateway into Stronghold mode. Marked only for major crisis resolution or re-entry into stronghold standing. |
| Stronghold Orc | Communal provision and oath kept | Orc community factions, favor/disposition proxy, stronghold NPC aid, protect/provide/advice milestones, curated oath-completion stages | After-act | Noted | Use curated stronghold hooks. Do not attempt universal oath tracking. |
| Stronghold Orc | Worthy challenge witnessed | Direct-player hostile kill, boss/higher-level enemy, brawl/challenge content, giant/crisis combat in stronghold context | Momentary combat / after-act | Quiet / Noted | Quiet by default. Noted only for stronghold crisis, boss, trial, or Malacath-significant fight. Requires meaningful challenge, direct attribution, and cooldown. |
| City Orc | Quality labor without recognition | `CraftItem` / PO3 `ItemCrafted`, named craft/service commission, smith/vendor/workplace faction proxy, quality/value threshold | After-act | Quiet / Noted | The city forge does not understand the rite, but Malacath can. No self-directed craft spam. |
| City Orc | Dignity under mixed-society pressure | Curated dialogue/favor/disposition stage, hostile/dismissive NPC quest outcome, successful non-capitulating resolution | After-act | Noted | Curated hooks only. Do not simulate every insult or persuasion check. |
| City Orc | Orc solidarity outside the hold | Help named Orc NPC, OrcFriend/Orc community faction proxy, city Orc service/merchant/favor state, rescue/protection beat | After-act | Noted | This is not generic charity; it is maintaining Orc identity where the stronghold structure is absent. |
| City Orc | Self-made community maintained | `PDV_SacredPlace` Orc community state, location/faction/relationship hooks, faction-favor proxy, chosen forge/home/inn/workplace, repeated returns plus investment events | Environmental / after-act | Noted | Buildable only as authored PDV state or faction-favor proxy. City presentation is belonging built in mixed society. Repeated visits alone do not qualify without investment. |
| Legion / Service / Exile Orc | Contract completed under pressure | Civil War/faction quest stage, Companions/Dawnguard/hold-service milestone, curated service completion with difficulty/context | After-act | Noted | Service must be meaningful, completed, and pressure-bearing. Faction membership alone does not trigger favor. |
| Legion / Service / Exile Orc | Endurance carried privately | Long quest/dungeon run, no-sleep stretch, survival after difficult service, hostile territory completion | Environmental / after-act | Quiet / Noted | Endurance is context, not piety by itself. Use caps and clear thresholds to avoid ordinary travel loops; overextension may receive only tiny flavor or funny debuff at most. |
| Legion / Service / Exile Orc | Discipline without self-erasure | Curated military/service dialogue or quest outcome, refusal to abandon Orc code under foreign command, non-cruel honorable resolution | After-act | Noted | Authored milestones only. The hook must prove the code was carried, not just that the player joined a faction. |
| Legion / Service / Exile Orc | Exile's burden answered | `PDV_SacredPlace` self-made community state, return from service to invested place, aid to rejected/outcast Orc or ally, faction-favor proxy tied to chosen place | After-act / rare major | Noted / Marked | Same community substrate as City, different presentation: burden returned from rather than belonging built. Marked only for major return, restoration, or community-established moments. |

**In-game hook cross-check:** Orc is buildable for 1.0 if the first slice treats Stronghold as the cleanest vanilla lane and treats City / Legion-Exile as curated or PDV-authored lanes. Strong hooks: Blood-Kin, `The Cursed Tribe`, stronghold aid milestones, Malacath shrine/Volendrung context, smithing/tempering events, and direct-player boss/challenge kills. Medium hooks: quality labor, named Orc solidarity, service completion, endurance, and stronghold/community provision through quest stages or faction/favor proxies. Custom-heavy hooks: dignity under mixed-society pressure, self-made community, discipline without self-erasure, and exile's burden answered. Rejected launch hooks: broad insult simulation, generic faction membership, raw craft counts, ordinary travel, and universal oath-breaking without a concrete quest failure/abandonment surface.

**Build-facing hook table (feasibility pass):**

| Experience target | 1.0 hook candidate | Confidence | Implementation posture |
|---|---|---|---|
| Stronghold acceptance | Blood-Kin state, `The Cursed Tribe` / Largashbur stages, stronghold aid milestones, Malacath shrine / Volendrung context | Strong | Primary Stronghold gate; Marked only for major crisis resolution or re-entry into recognized standing |
| Forge excellence | CraftItem / PO3 ItemCrafted where available, tempering result, Orcish/quality/value item families, stronghold or workplace context | Medium-strong | Require quality, value, or context; raw crafting count never triggers favor |
| Communal provision and oath kept | Stronghold NPC aid, Orc community faction/favor proxy, curated provision/protection/contract stages | Medium | Bundle for launch unless clean separate hooks appear; no universal oath simulation yet |
| Worthy challenge witnessed | Kill Actor route, direct-player attribution, boss/higher-level enemy, brawl/challenge content, giant/crisis combat in stronghold context | Medium | Quiet by default; Noted only for crisis, boss, trial, or Malacath-significant fight |
| City dignity and quality labor | Named craft/service commission, smith/vendor/workplace proxy, curated hostile/dismissive dialogue outcome, named Orc aid | Medium for labor/solidarity, weak vanilla for dignity | Use curated rows and PDV-authored content; no ambient disrespect parser |
| City self-made community | `PDV_SacredPlace`, chosen forge/home/inn/workplace, relationship/faction-favor proxy, repeated returns plus investment events | Custom strong if built | Requires investment, not repeated visits alone; presentation is belonging built outside the hold |
| Legion/Exile service | Civil War/faction quest stage, Companions/Dawnguard/hold-service milestone, completed pressure-bearing contract | Medium | Faction membership grants eligibility only; completed difficult service triggers favor |
| Legion/Exile endurance and return | Long quest/dungeon run with no sleep, survival after difficult service, return to `PDV_SacredPlace`, aid to outcast Orc/ally | Medium-risk / custom | Endurance is context, not piety alone; return/restoration moments may be Noted or Marked if authored |

**Launch-scope rule:** Stronghold rows are the safest first implementation slice. City and Legion/Exile rows are valid user-experience targets, but their launch implementation should prefer curated quest/faction/community hooks and PDV-authored state over broad inference.

**Table review locks (2026-05-19):**
- Launch table stays at four trigger families per life-mode; do not force a fifth row unless implementation discovers a strong hook.
- Forge favor requires quality, value, or context; raw crafting count never triggers favor.
- Blood-Kin and `The Cursed Tribe` are the main Marked Stronghold moments.
- City Orc dignity is curated-hook only; generic persuasion, intimidation, or ambient disrespect does not trigger favor.
- Legion/Exile service favor requires completed pressure-bearing service; faction membership alone is context, not a trigger.
- Stronghold worthy-challenge favor is Quiet by default; Noted is reserved for stronghold crisis, boss, trial, or Malacath-significant fight.
- Self-made community is shared by City and Legion/Exile, but must use `PDV_SacredPlace` or faction-favor proxy hooks. City presentation is belonging built; Legion/Exile presentation is burden returned from.
- Legion/Exile endurance is context, not piety by itself. Overextension may receive only tiny flavor or funny debuff at most.
- Communal provision and oath kept stay bundled for launch unless implementation discovers clean separate hooks.
- Orc contextual favor is review-cleared for user-experience shape; implementation-costing remains before build, and life-mode selection is locked by the default/eligibility/gate rule above.

---

## Signature Friction

**Malacath doesn't petition — he observes.** This is the central friction and it's inherent to the theology rather than mechanically imposed. You cannot pray harder. You cannot donate more. You cannot visit a shrine and feel like you've done the spiritual work. The only way to generate Malacath piety is to actually do the things Malacath values — forge, oath, community, strength — and the game has to detect that you did them.

**Mode ceiling friction:** Knowing that City Orc has a lower ceiling than Stronghold is an in-universe choice with theological weight. A City Orc who wants to reach Champion can try — it's harder and takes longer. A City Orc who wants the Stronghold ceiling needs to pursue Blood-Kin status and actually integrate into stronghold life. That's not an arbitrary rule — it's the theological reality that Malacath's full expression requires the right context.

**Mode switching friction:** Switching modes is limited and consequential. A Stronghold Orc who sells out and moves to the city is making a choice that Malacath notices. Getting back into Stronghold standing isn't easy. The code judges transitions as well as states.

---

## Neglect Texture

**Emptiness at the forge.** Malacath's neglect doesn't feel like punishment — it feels like the work stopped being sacred.

- **Stronghold neglect:** Drifting away from stronghold life — spending all time in cities, not engaging with Orc community content, not crafting, not challenging — Malacath simply stops watching. The forge tempering bonus disappears. The near-death fury doesn't fire. The stronghold NPCs gradually lose their recognition quality. Not hostile — just distant. The elder doesn't ask how the forge has been.
- **City Orc neglect:** Letting quality slide — doing the minimum work, not maintaining dignity, exploiting other Orcs or letting yourself be erased into the mix. Malacath stops registering the conduct because there's nothing distinctly Orc about it anymore. The quality consistency bonus fades. The dignity-under-pressure moment doesn't fire.
- **Legion/Exile neglect:** Breaking contracts. Not completing service to its completion. Self-erasing to fit in — abandoning Orc identity entirely rather than carrying it privately. The endurance bonus disappears. The resolve moment doesn't fire. Malacath is watching someone who forgot what they were.
- **Oath-breaking:** A specific neglect signal across all modes. Breaking a commitment you made (abandoning a quest you accepted, failing to honor an in-game promise, betraying an employer who trusted you) generates explicit negative piety. Not large — Malacath doesn't over-punish a single failure. But sustained oath-breaking accumulates in a way that feels different from just not scoring signals.

---

## Signal Examples

| Mode | Action | Cadence | Notes |
|------|--------|---------|-------|
| All | Craft a weapon or armor item (smithing) | Daily cap | Quality threshold: must produce something beyond base-level |
| All | Win a fight against a challenging enemy (5+ levels above) | Per fight, cooldown | Strength proved; not farmable via difficulty-scaling exploits |
| Stronghold | Complete a Blood-Kin-adjacent or stronghold support quest | Per quest | "The Cursed Tribe" / Largashbur as primary |
| Stronghold | Help a stronghold NPC (protect, provide, advise) | Per event, cooldown | Natural rarity limits farming |
| Stronghold | Accept and win a challenge (chief challenge, trial combat) | Per challenge | Rare by nature; very strong signal |
| City | Complete a crafting commission (smithing, alchemy, cooking) | Per commission | Must be a named quest commission, not self-directed |
| City | Maintain dignity in hostile NPC encounter (succeed in persuasion vs. hostile) | Per encounter, cooldown | Hostile: NPC must be explicitly dismissive or hostile to Orcs |
| City | Help another Orc NPC anywhere in Skyrim | Per event, cooldown | Any named or quest-adjacent Orc |
| Legion/Exile | Complete a faction service quest (Companions job, hold-guard contract) | Per quest | Must be completed fully, not abandoned |
| Legion/Exile | Honor a commitment under pressure (near failure, could have abandoned it) | Per event | Hard to detect generically; focus on quest-completion events |
| Legion/Exile | Long dungeon or quest run without resting (endurance signal) | Session-based, daily cap | Defined as N+ hours of quest-active time without sleep event |
| All | Oath-breaking (abandoning a committed quest) | Negative piety | Per event; sustained oath-breaking accumulates |
| All | Malacath shrine interaction | +piety | Rare in Skyrim (strongholds); Daedric shrine at Shrine to Malacath |

---

## Implementation Notes

**Vanilla hook surface:** Good for crafting (smithing events), moderate for combat-strength signals, limited for community/stronghold signals (relatively few Orc-specific quest events). The stronghold content (Blood-Kin, Cursed Tribe) is well-defined. City and Legion-exile signals rely more on behavioral patterns.

**Complexity flags:**
- **Mode detection and switching:** `PDV_State_OrcLifeMode` is the active scoring state. Use `PDV_GLO_State_OrcLifeMode` for CK-readable current state and StorageUtil keys for intent, eligibility, last switch time, lock-in, and recent mode evidence. Recommended keys: `PDV.Track.OrcLifeMode.Intent`, `PDV.Track.OrcLifeMode.LastSwitch`, `PDV.Track.OrcLifeMode.LockInUntil`, `PDV.Track.OrcLifeMode.EligibleStronghold`, and `PDV.Track.OrcLifeMode.EligibleLegionExile`. Mode transition helpers should be `SetOrcLifeMode(mode, reason)`, `RecordOrcModeSignal(mode, strength, reason)`, and `EvaluateOrcLifeModeAtDawn()`.
- **Mode ceiling implementation (LOCKED):** The ceiling difference isn't implemented as a hard cap on piety — it's a lower piety-per-day accumulation rate applied in ProcessDawn as a multiplier on the **already-clamped** daily gain (after the dawn clamp — applying it before a fixed clamp would not scale the ceiling; see `PDV_BalancingImplementationHandoff.md` Task 2). The multipliers are locked at **Stronghold ×1.00, City ×0.75, Legion/Exile ×0.60** of the base rate (`ORC_RATE_MULT_STRONGHOLD/CITY/LEGIONEXILE`). Against the locked 3.3/day base and 4.3/day ceiling (`PDV_PietyPaceBalancingTable.md`), this yields the calendars in `PDV_SignalDensityAudit.md`: Stronghold 8/15/26, City 10/20/34, Legion/Exile 13/25/43 in-game days to Observant/Faithful/Devoted. The multiplier scales the per-deity daily gain only; thresholds (25/50/85) are identical across modes. **Passive decay is not mode-scaled** — it stays at the universal 0.5/day for all Orc modes (`PDV_DecayAudit.md`): the multiplier is a gain-generation compensation, and an exile Orc holding the code alone should not decay slower than a community-reinforced Stronghold Orc.
- **Quality crafting signal:** Requires knowing when a crafted item is "quality" — above base level, or at maximum tempering for perk level. The smithing event fires on item creation; tempering fires on tempering interaction. Both are hookable. Quality threshold needs definition: recommend "any tempering that produces Fine or better" as the minimum bar.
- **Strength-proved signal:** Enemy-level-above-player at kill time requires reading the ActorLevel property on the killed actor. Accessible via Story Manager kill events. 5+ levels above player is the recommended threshold; this naturally rate-limits farming since it requires actively seeking difficult fights.
- **Oath-breaking detection:** The most novel and hardest signal. Recommended approach: track quest acceptance events and log them; if a quest is abandoned (failed stage fires without a completion stage) after acceptance, generate negative piety. This catches deliberate abandonment without punishing quests the player couldn't complete. Edge cases (quest blocked by bug, etc.) need grace handling.
- **Stronghold NPC recognition:** Requires CK condition work on relevant stronghold NPCs. Blood-Kin flag provides the base condition; PDV Tier 3 global provides the enhanced condition. Two-tier dialogue system on stronghold merchants, smith, and chief.

**Cost class profile:**
- Smithing events: Cost Class A (item creation and tempering events)
- Strength-proved combat: Cost Class B (level check on Story Manager kill data)
- Blood-Kin quest: Cost Class A (quest stage completion)
- Mode state transitions: Cost Class B (persistent state management)
- Oath-breaking detection: Cost Class C (quest tracking + abandonment detection)
- Mode ceiling in ProcessDawn: Cost Class A (simple daily-rate multiplier)

---

## Variety Tranche — "Witnessed" (DESIGN-LOCKED 2026-06-12)

Roadmap source: `references/authoring/PDV_RaceVarietyTranche_Roadmap.md`.
Purpose: close the City / Legion-Exile felt-content gap without violating the
feasibility lock (curated hooks or PDV-authored state only — no broad social
simulation). Magnitudes are tunable; shapes, gates, caps, and fade rules are
locked. Effect families remain blocked behind the race row in
`PDV_RaceEffectReviewLedger.md` before any record authoring.

**The Watcher's regard (all modes).** Not dreams — Malacath observes, he
does not visit. Rare top-left observation lines after qualifying mode-coded
conduct ("The work was true. It was seen."), keyed to
`PDV_State_OrcLifeMode`, cap 1/dawn. Silence remains the neglect texture, so
lines stay rare by design.

**Self-made community (City + Legion/Exile modes).** This implements the
locked `PDV_SacredPlace` self-made-community row on the proven Argonian
cell-keyed declaration mechanic. Declaration of a chosen forge/home/
workplace cell ("This place is mine to keep"), prompted at sleep-stop;
declining re-prompts after 3 in-game days. An invested return = sleeping
there after a day containing a qualifying quality-craft or completed-service
act; repeated visits alone never qualify (locked). At 3 invested returns the
wake grants `Hearth-Held` (small health-regen pulse, 10 min). Presentation
is mode-split per the locked phrasing: City = belonging built; Legion/Exile
= burden returned from. Forward note: if a true `PDV_SacredPlace` system is
later built, this mechanic migrates into it (recorded in the roadmap and to
be carried in the Orc record-batch manifest, Hist-fold style).

**The Code Holds (signature, all modes, once/day).** Surviving a fight
after dropping below 20% health without leaving the cell grants a brief
post-combat survival restore (a flat Health restore in the live build, not a
rate-regen pulse -- Requiem-proof). Quiet surfacing in City/Legion modes, Noted in
stronghold context. Deliberately small and all-tier — distinct from the
Stronghold Champion fury, which stays a Champion moment.

**The Four Holds of the Code (pilgrimage).** One-shot first-arrival pulse at
each of the four strongholds — Dushnikh Yal, Mor Khazgur, Narzulbur,
Largashbur — all four = milestone MessageBox. For a City or Exile Orc this
is belonging-across-distance. The arrival pulse fires on the location, not
on friendly entry (Largashbur is hostile pre-`The Cursed Tribe`). One-shot
forever, anti-farm by design.

**Trial of Iron (rite).** At a forge inside the declared community place or
any stronghold, 7-day cooldown, "Not yet" does not spend the cooldown.
One-active discipline: Hammer (+5 smithing), Shield (+5 armor rating), Tusk
(+5 unarmed), Yoke (+15 carry weight); choosing again swaps
(clear-before-add). Fades at dawn if mode standing collapses (e.g. sustained
oath-breaking); returns automatically at dawn on recovery. Forge-sited so
the rite stays inside Malacath's devotional language: conduct, not prayer.

---

## Curse State Summary

**Vampire:**
- Near-total collapse of normal Orc belonging
- Exile from stronghold acceptance (vampires are not Malacath's test; they are outside it)
- Malacath devotion becomes hollow or nonfunctional — the code requires a living Orc, and the player is no longer fully that
- No real positive Orc theological replacement
- Lore rationale: Vampirism is dependency and contradiction of everything Malacath values — strength through discipline, not undead parasitism.

**Werewolf:**
- Conditional acceptance depending on proven strength and control
- Possible tolerance in some stronghold contexts (if the beast-form is disciplined and strength is clearly primary)
- Still readable through Malacath's code: the beast is tested by the same criteria as the Orc — is it strong? Does it endure? Does it serve the community or destroy it?
- Not a free positive buff; a demanding test that Malacath watches
- Lore rationale: Matches tamriel-cursed-worship-4e201.html — vampirism becomes dependency and contradiction; werewolfism remains conditionally defensible if strength and discipline are demonstrated. Malacath judges the wolf by the same standards as the smith.
