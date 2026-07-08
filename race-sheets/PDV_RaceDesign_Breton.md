# PDV Race Design — Breton
**Last updated:** 2026-05-19
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.3)

---

## Religious Identity

Bretons are defined by a productive contradiction: they are half-elven people who built an identity as the most human of the human races, and they carry both the logic of the Divines and the logic of the old Aldmeri magical traditions simultaneously. Pragmatic syncretism isn't a flaw in Breton religion — it *is* Breton religion. A Breton can hold a knight's vow and consult a witch in the same week, and find both theologically coherent.

In Skyrim, Breton religious life revolves around *which tradition you walk*. The gods are a secondary layer — they give the tradition shape, but the tradition comes first.

**Core design intent:** Breton should feel reputation-sensitive and double-lived, with more identity in risk and status than in passive power. The three tracks should pull against each other. Playing a Breton should require managing your public face alongside your actual practices.

---

## Worship Structure

```
Step 1: Choose primary tradition at setup
  → The Knight's Road: civic honor, protective justice, selfless service
  → The Hidden Art:    occult practice, Daedric dealings, double lives
  → The Green Way:     druidic covenant, standing stones, nature rites

Step 2: Practice tradition breadth (Tier 2 cap)
  → Each tradition has its own deity pool and scoring logic
  → Cross-tradition acts create pressure — they're not blocked, but they cost

Step 3: Focused deity commitment within tradition → Tier 3 unlocked
```

Breton does **not** use the generic broad-worship lane. "Tradition breadth" means the player can live the chosen Breton tradition broadly before a focused patron emerges. Normal patron offers come only from the chosen tradition unless a major authored fork explicitly opens another route.

`PDV_State_BretonTradition` values: `KnightsRoad = 0`, `HiddenArt = 1`, `GreenWay = 2`. The setup choice must be explicit; there is no silent fallback tradition.

**Three unique mechanics run in parallel:**
- **KnightlyVowIntegrity** (stored for all Bretons; presented for Knight's Road): degrades on unjust acts and broken oaths; severe dishonor is remembered if the player later tries to walk the Knight's Road
- **WitchcraftExposure** (global for all Bretons): visibility of occult and Daedric practice, whether or not Hidden Art is the chosen tradition
- **DruidicStanding** (stored for all Bretons; presented for Green Way or Green forks): numeric Y'ffre covenant track paired with the DruidicFork state; starts at 50 and does not punish non-Green Bretons for ordinary non-druidic life

Normal Breton tradition switching is not available in 1.0. The setup choice is stable. Major authored forks can rupture or redirect a path, such as the Green Way werewolf trial opening Hircine, but casual mid-game reorientation is a future explicit feature.

**Cross-lane pressure rule:** The tracks pull asymmetrically. Hidden Art acts can strongly damage KnightlyVowIntegrity and raise WitchcraftExposure. Knightly public cover can slowly lower WitchcraftExposure, but it does not erase severe occult commitments by itself. Knight's Road and Green Way can overlap gently through mercy, protection, nature restraint, and Y'ffre-adjacent conduct; Skyrim-facing Kynareth places/tools can act only as proxy sources routed to Y'ffre, not as Green Way patron ownership. Hidden Art and Green Way overlap mainly through Hircine and old magic, but that overlap creates fork pressure rather than a free hybrid.

---

## The Knight's Road

### Available deities: Stendarr, Akatosh, Mara, Arkay, Julianos, Zenithar, Kynareth, Dibella

### KnightlyVowIntegrity Track (0-100, starts at 100 for Knight's Road)

KnightlyVowIntegrity belongs to the whole Knight's Road tradition. Stendarr and Akatosh read it most strongly, but low Integrity should suppress all Knight's Road gains before it becomes a two-god-specific penalty.

**Broken by:**
- Joining Thieves Guild (-30)
- Joining Dark Brotherhood (-40)
- Unprovoked killing of innocents (-15 per event)
- Abandoning an NPC in need mid-quest (-10)

**Restored by:**
- Acts of mercy and justice (+5 per significant act)
- Visiting Stendarr shrine with clean hands (+10; can restore collapse but cannot raise Integrity above 75)
- Completing a quest to help an NPC without reward (+5)

Integrity above 75 requires lived conduct: curated mercy, justice, protection, or reparation acts. Shrine visits can help a fallen knight stand back up, but they cannot by themselves make the player honorable.

**Effects of low Integrity:**
- Below 50: all Knight's Road daily shift x0.75; Stendarr daily shift x0.5; Akatosh x0.75
- Below 25: all Knight's Road daily shift x0.5; Stendarr daily shift x0.25; Akatosh x0.5
- At 0: all Knight's Road relationship progress halts until Integrity is restored above 25; Stendarr and Akatosh recognition is fully withdrawn

### Tier Rewards — Knight's Road

**Tier 1 — Observant:** Resist magic 5% (Breton baseline amplified by faith); +20 max health for 2 hours after successfully defending an NPC in combat.

**Tier 2 — Faithful:**
- After helping NPCs without reward or choosing mercy, next combat has +8 armor rating
- KnightlyVowIntegrity above 75: block +5
- Temple of Stendarr / Divine shrines give recognition (favorable NPC reactions, 5% discounts from associated merchants)
- Akatosh devotion: unbroken devotion streaks of 7+ days give +5% skill XP gain; 14+ days gives +10% skill XP gain (cumulative, resets if Integrity drops below 75)

**Tier 3 — Devoted:**
- *Stendarr Champion:* Knight's Aegis — when actively protecting someone (follower alive and nearby, combat against their attacker), damage resist 15% for duration. Vigilants of Stendarr treat you as a peer (quest access, recognition dialogue). Against Daedra and undead with clean Integrity: bonus damage.
- *Akatosh Champion:* Order-keeper's resolve — unbroken devotion streaks (14+ days with Integrity above 75) give +15% skill XP. Dragon-order content (Blades, dragonslaying, main quest) generates strong piety. Amulet of Akatosh double effect.
- *Mara Champion:* Community-held — after helping a family or restoring a community, next rest heals to full. Temple of Mara maximum recognition. Companion healing bonus.

**Champion moment for Knight's Road:** The hardest Champions in Skyrim to earn — because the game actively offers you the Thieves Guild, the Dark Brotherhood, and expedience at every turn. Maintaining Integrity through a full Skyrim playthrough while pursuing a faith Champion is a statement about character. The payoff should feel proportional — protection when defending others, not just a passive stat.

---

## The Hidden Art

### Available deities (Daedric): Hircine, Hermaeus Mora, Namira, Nocturnal (via Daedric system)

Hircine is Breton-legible but not Breton-native. He should not appear as a normal Breton baseline deity. He opens through Hidden Art commitment signals or through the Green Way werewolf fork, not through ordinary Breton tradition practice.

### WitchcraftExposure Track (0-100, starts at 0)

These bands and modifiers are locked for 1.0. The `Notorious` x1.25 modifier applies only to Daedric / Hidden Art commitment, not to all Breton religion.

```
Hidden   (0-24):   Private practice -- fully functional, socially invisible
Suspected (25-49): Vigilants may take notice through authored/contextual reactions; some Bretons uncomfortable; daily shift x0.9
Known    (50-74):  Vigilants become a credible danger when occult state is manifest or PDV-authored pressure fires; most Bretons distance; daily shift x0.75
Notorious (75-100): Full social rupture; Daedric prince rewards full commitment; daily shift x1.25
```

**What raises Exposure:**
- Completing Daedric quests publicly (+15)
- Caught by Vigilants of Stendarr (+20)
- Reaching Tier 2 devotion to Daedric patron (+10)
- Killing a Vigilant of Stendarr (+25)

**What lowers Exposure:**
- Time passing without visible acts (slow passive decay -1/day; visible exposure can return to 0, but one-shot major-act markers remain in history)
- Maintaining public Imperial Divines worship as cover (-5 per sustained period; requires no major occult signal for 3 in-game days and is capped once per 7 days)
- Avoiding Daedric-associated locations (passive)

### Tier Rewards — Hidden Art

**Tier 1 — Observant:** Novice/Apprentice spell cost -5%; minor magic regen bonus at night (Daedric favor tends toward darkness).

**Tier 2 — Faithful:**
- WitchcraftExposure Suspected: patron gives +5% spell damage and -5% magicka cost in relevant scenarios (combat near Daedric shrines, during Daedric quests, and for one hour after completing a Daedric ritual)
- Daedric shrine access generates piety (Hidden Art players get piety from what others are punished for)
- WitchcraftExposure Notorious: daily shift x1.25 kicks in — the prince rewards full commitment
- Daedric quest completion generates very strong piety (these are the main scoring events)

**Tier 3 — Devoted:**
- *Hermaeus Mora Champion:* Scholar's Price — skill XP gain +10% in relevant schools (Alteration, Conjuration, Illusion) while WitchcraftExposure is Hidden or Suspected. At Notorious, the prince's direct attention: +20% in those schools but any valid Vigilant confrontation is treated as lethal-priority.
- *Hircine Champion:* Beast-bond — beast form (if Werewolf) extended; hunting acts generate stronger piety. Transformation is less disorienting (smoother state transition).
- *Nocturnal Champion:* Shadow's mark — sneak attack damage +15%; after a successful theft from a notable target, brief near-invisibility window.
- *Namira Champion:* Corruption manifest — difficult to describe cleanly in-game, but: survival in degraded conditions is easier, hunger penalties (Survival Mode) are lower, and... Namira notices when you do the things people don't discuss.

**Champion moment for Hidden Art:** You've either hidden your practice completely (Hidden band) or gone fully public (Notorious) — neither is wrong, both are different expressions of the same Champion arc. The payoff at Notorious is specifically designed to reward committing fully rather than staying in the middle. The double life either becomes fully concealed or fully declared.

---

## The Green Way

### Available deities: Y'ffre (primary), Phynaster (proof-gated)

Phynaster's Green Way spine is pilgrimage/endurance plus elven heritage/longevity: long road, short stride, disciplined life, Direnni memory, and old practice. He is not a second nature god. Y'ffre still owns the nature covenant and the Green Way reward identity; Phynaster can become a focused Green Way offer only if the implementation pass finds concrete, non-generic hooks.

Phynaster promotion gate: before he becomes offer-eligible or gets a live deity record, the implementation plan must produce at least three positive source families, at least one dislike/failure family, distinct offer/reward copy, and a no-overlap rule with Y'ffre. If that fails, Phynaster stays flavor/support for Breton V1.

This gate is deferred to implementation planning; do not treat the race walkthrough as approval to create Phynaster records or offer hooks.

Magnus can contribute only thin old-magic support rows where the source is genuinely druidic or earthbones-adjacent. He is not Green Way offer-eligible and does not own Green Way reward tiers.

### DruidicStanding (Y'ffre's ongoing covenant)

The Green Way uses `PDV_RepTrack_DruidicStanding` as a numeric 0-100 covenant track, paired with `PDV_State_BretonDruidicFork`. The player-facing readout can feel like a relationship state, but the implementation should use the same reputation-track substrate as the other Breton tension mechanics.

`PDV_State_BretonDruidicFork` values: `None = 0`, `Druidic = 1`, `Werewolf = 2`, `Betrayed = 3`.

`DruidicStanding` starts at `50`, representing an open but unproven covenant. In standard play, DruidicStanding is maintained through outdoor lifestyle signals and degraded by acts antithetical to Y'ffre's covenant. The four-state DruidicFork is the hard gate: `Druidic` permits the Green Way reward family, `Werewolf` routes the unresolved beast fork, and `Betrayed` applies creed-loss pressure.

The Old Contract (strict Bosmer Green Pact) gives the full hard-compliance mechanic. The Green Way for Bretons is the **softer analog** — it doesn't require Pact-strict food compliance, but it does require a genuine outdoor lifestyle and nature-aligned conduct.

### Tier Rewards — Green Way

**Tier 1 — Observant:** Resist poison 10%; foraging (picking plants) gives an extra harvest item (Y'ffre knows what grows where, even for Bretons who hear that old knowledge).

**Tier 2 — Faithful:**
- Outdoor sleep fully restores stamina and restores 50% of missing health (in addition to normal sleep benefits)
- Animals rarely aggro unless genuinely threatened
- Standing stone interactions generate piety (Breton druids use stones as focal points)
- Kynareth shrine interactions can generate modest Y'ffre-adjacent piety only as explicit proxy sources routed to Y'ffre; they do not make Kynareth a Green Way patron

**Tier 3 — Devoted:**
- *Y'ffre Champion:* Voice of the Living Story — in forested outdoor areas, armor rating +10. Hunting shots (bow, first hit on an animal not attacked first) have bonus damage. Nature-site quests (anything set in forests, groves, standing stone areas) give double piety. Werewolf fork: if "beast serves the Green" was chosen, beast form gains nature-aligned bonus (animals don't attack you in beast form).
- *Old-magic support:* Magnus-adjacent sources can lightly support the Green Way only when they read as druidic old magic, earthbones memory, or nature-rite scholarship. Formal arcane study belongs to Hidden Art.
- *Phynaster Champion:* Longevity's gift: resist magic 15% cumulative (Breton race base + Tier 1 + Devoted bonus stacks here intentionally). Pilgrimage/endurance and elven-heritage acts (appreciation of elven craftsmanship, engagement with Altmer/Bosmer cultural content, long-practice discipline) generate modest piety.

**Champion moment for Green Way:** The forest in Skyrim is cold and often hostile. A Green Way Champion should feel like the forest has been taught to recognize them — animals settling when you approach, hunting feeling guided, the outdoors cooperating rather than merely enduring. This is quiet power, appropriate for a tradition about covenant rather than conquest.

---

## Signature Friction

**Three distinct frictions for three traditions:**

- **Knight's Road:** KnightlyVowIntegrity degrades every time Skyrim offers you an expedient choice. This is the most passive but persistent friction — the game is constantly testing your Integrity by making corruption available. Maintaining 75+ through a full playthrough requires intentional character choice at every major guild junction.

- **Hidden Art:** WitchcraftExposure creates a genuine decision point: hide forever (slower gains, safer) or go Notorious (faster gains, dangerous). Neither is wrong, but you can't stay in the middle forever — high exposure makes Vigilant/anti-occult pressure increasingly valid, even if full hunter encounters require authored PDV support. The social rupture is the friction.

- **Green Way:** The Druidic Trial after first werewolf transformation is the signature friction moment for this path — a one-time explicit theological choice that permanently shapes the rest of the playthrough. Outside of that: living an outdoor lifestyle in Skyrim is its own quiet friction, because Skyrim's content constantly pulls you into cities, dungeons, and guild buildings.

---

## Neglect Texture

- **Knight's Road neglect:** Integrity collapses through unjust choices, and Stendarr's daily shift halves. It feels like your patron is *disappointed* rather than distant. The armor rating boosts stop. The Vigilant recognition disappears. You're still technically a Knight but the shield feels hollow.
- **Hidden Art neglect:** If you go Notorious and then stop doing Daedric acts, the prince's reward (x1.25) disappears while the social rupture remains. You've paid the cost without the benefit — a particular kind of failure.
- **Green Way neglect:** The forest stopped noticing you. DruidicStanding quietly degrades when you spend too much time in cities and dungeons. Animals start treating you like any other traveler. The outdoor sleep bonus disappears. Nature becomes background rather than a relationship.

---

## Signal Examples

| Action | Tradition | Cadence | Notes |
|--------|-----------|---------|-------|
| Help NPC without reward | Knight's Road | Per act, daily cap | "Without reward" requires intent-detection — flag as medium complexity |
| Choose mercy in dialogue | Knight's Road | Per choice, cooldown | Filter trivial vs. meaningful mercy |
| Join Thieves Guild | Knight's Road | One-time | -30 Integrity; irreversible without restoration arc |
| Join Dark Brotherhood | Knight's Road | One-time | -40 Integrity; hardest recovery |
| Complete a Daedric quest | Hidden Art | Per quest | Strong piety spike; naturally rate-limited |
| Reach Tier 2 devotion to Daedric patron | Hidden Art | One-time per patron | +10 WitchcraftExposure |
| Kill a Vigilant of Stendarr | Hidden Art | Per kill | +25 Exposure; hard floor on consequences |
| Sleep outdoors (not inn or house) | Green Way | Daily cap | Survival Mode overlap |
| Visit a standing stone | Green Way | Per stone (first visit) | Limited finite pool; rich early-game |
| Hunt an animal (curated/contextual) | Green Way | Cautious cap | Secondary 1.0 hook only; ordinary animal kills do not count |
| Werewolf first transformation | Green Way | One-time | Fires Druidic Trial dialogue choice |
| Read Hidden Art texts (*Herbane's Bestiary: Hagravens*; *The Madmen of the Reach*; *Anise's Letter*) | Hidden Art | Per book, one-time | Approved occult/witchcraft sources; notifications: `PDV_Notif_Breton_FavorNoted_HiddenArt_BookRead_*` |
| Stendarr shrine visit with clean hands | Knight's Road | Daily cap | Integrity restoration trigger |

### 1.0 Hook Evidence and Launch Posture

**Global gameplay rules:**
- Use curated quest, faction, state, location, shrine, and activator hooks. Do not infer Breton virtue, witchcraft, or druidic life from generic behavior alone.
- Routine score movement stays silent. Surface only tradition choice, patron offer, track threshold changes, curse/fork choices, restoration state changes, and Champion moments.
- Dawn order: event deltas -> curse/fork state -> cross-lane drag -> devotion modifiers -> piety consolidation.

**Knight's Road: strong 1.0 hooks**
- `ThievesGuildFaction` (`Skyrim.esm:029DA9`) and `CrimeFactionThievesGuild` (`Skyrim.esm:10A794`) are clean faction/civic signals for vow pressure.
- `DarkBrotherhoodFaction` (`Skyrim.esm:01BDB3`) and `DB10SanctuaryFamilyFaction` (`Skyrim.esm:04135B`) are clean faction signals for severe vow pressure.
- `DLC1HunterFaction` (`Dawnguard.esm:003375`) is a strong Dawnguard / anti-vampire protection signal and explicitly opposes `DLC1VampireFaction`.
- `VigilantOfStendarrFaction` (`Skyrim.esm:0B3292`) is a clean Stendarr/Vigilant signal and is hostile to vampire, daedra, undead, necromancer, hagraven, and werewolf-adjacent factions.
- `StendarrsBeaconLocation` (`Skyrim.esm:108A5A`) and `HalloftheVigilantLocation` (`Skyrim.esm:0C342D`) are usable Stendarr/Vigilant location context.
- `ShrineofStendarr` (`Skyrim.esm:0D987D`), `ShrineofAkatosh` (`Skyrim.esm:0D9883`), `ShrineofMara` (`Skyrim.esm:0D9887`), and the other Divine shrine activators are available as curated restoration/prayer hooks with cooldowns.
- Quest crosswalk supports `Destroy Brotherhood`, `Paarthurnax choice`, `Book of Love completion`, `Join Dawnguard`, and `Meridia beacon / Kilkreath cleanse` as one-shot moral/justice signals.

**Knight's Road: weak or curated-only hooks**
- `Help without reward` is not safe as generic intent detection. For 1.0 it must be a curated quest-stage/outcome list only.
- `Protecting someone` should use curated follower/NPC-under-attack or quest defense situations where possible, not ambient combat inference.

**Hidden Art: strong 1.0 hooks**
- Daedric quest outcomes are the main launch surface: Azura's Star, Boethiah sacrifice, Hircine/Sinding choice, Mehrunes Razor, Meridia, Molag Bal, Namira feast, Vaermina Skull, and similar curated rows from the quest crosswalk.
- `ShrineOfNocturnal` (`Skyrim.esm:10E8B0`), `DA01ShrineofAzura` (`Skyrim.esm:092492`), `AltarOfMolagBal01` (`Skyrim.esm:0C7B72`), `DA11NamiraShrineRoomTrigger` (`Skyrim.esm:08796D`), and Dragonborn Daedric shrine activators support explicit occult/devotional context.
- Thieves Guild `Nightingale oath`, `Return Skeleton Key`, and `TG08ANightingaleArmorActivator` (`Skyrim.esm:0FCC17`) are strong Nocturnal compact signals.
- Dragonborn `Black Book read`, `Temple of Miraak / first Apocrypha contact`, and `Choose Skaal secrets outcome` are strong Hermaeus Mora / forbidden knowledge signals.
- `VigilantOfStendarrFaction` hostility gives clean anti-Vigilant consequence hooks, but killing Vigilants should be treated as major exposure only, not repeatable farming.
- `DLC1PlayerVampireLordFaction` (`Dawnguard.esm:0071D3`), `DLC1VampireFaction` (`Dawnguard.esm:003376`), and `VampirePCFaction` (`Skyrim.esm:0C4DE0`) are useful curse/occult state surfaces.
- Vanilla supports real Vigilant hostility in specific cases: Vigilants oppose vampire/Daedra/undead/necromancer/hagraven/werewolf factions, world interactions place Vigilants against abominations, and Vigilants attack Barbas during `A Daedra's Best Friend`. However, normal Skyrim does not appear to run a general "known Daedra worshipper" reputation hunt. UESP notes an unused Daedric-artifact confrontation that is set to never happen in-game. For 1.0, use existing hostility/world-interaction surfaces and authored PDV pressure, not an assumed vanilla exposure-hunter system.
- Optional extension candidate: build a light Vigilant pressure encounter inspired by the disabled Daedric-artifact confrontation. Prefer a PDV-authored road/letter/encounter pattern over actual crime-gold bounty mechanics. Crime bounty is hold-scoped reported lawbreaking, while WitchcraftExposure is religious/social stigma. If built, gate it behind `Known` or `Notorious`, require a recent major occult signal, use long cooldowns, and keep it to rare one-shot pressure rather than constant hunter spawns.

**Hidden Art: weak or excluded hooks**
- Generic spellcasting, artifact ownership alone, ordinary stealth, ordinary theft, or visiting a spooky place does not raise WitchcraftExposure.
- Daedric artifact acquisition should score only when tied to a quest outcome, oath, ritual, or explicit commitment signal.

**Green Way: strong 1.0 hooks**
- Standing stone activators are a clean finite surface: `DoomstoneApprentice` (`Skyrim.esm:0D2331`), `DoomstoneAtronach` (`Skyrim.esm:0D2334`), `DoomstoneLady` (`Skyrim.esm:0D2330`), `DoomstoneLord` (`Skyrim.esm:0D2336`), `DoomstoneLover` (`Skyrim.esm:0D2332`), `DoomstoneMage` (`Skyrim.esm:0D232E`), `DoomstoneRitual` (`Skyrim.esm:0D2337`), `DoomstoneSerpent` (`Skyrim.esm:0D2339`), `DoomstoneShadow` (`Skyrim.esm:0D2335`), `DoomstoneSteed` (`Skyrim.esm:0D2333`), `DoomstoneThief` (`Skyrim.esm:0D232F`), `DoomstoneTower` (`Skyrim.esm:0D2338`), and `DoomstoneWarrior` (`Skyrim.esm:0D232D`).
- Solstheim standing stones add optional later support through `dlc2StandingStoneBeastACT`, `dlc2StandingStoneEarthACT`, `dlc2StandingStoneSunACT`, `dlc2StandingStoneTreeACT`, `dlc2StandingStoneWaterACT`, and `dlc2StandingStoneWindACT`.
- `LocTypeSprigganGrove` (`Skyrim.esm:0130EA`) is a strong nature-site tag with exactly three extracted vanilla examples: `MossMotherCavernLocation` (`Skyrim.esm:01927E`), `RoadsideRuinsLocation` (`Skyrim.esm:04787B`), and `ShadowgreenCavernLocation` (`Skyrim.esm:01929C`).
- `ShrineOfKynareth` (`Skyrim.esm:0D987F`) and `WhiterunTempleofKynarethLocation` (`Skyrim.esm:01F87D`) can provide modest Y'ffre-adjacent proxy support if explicitly routed to Y'ffre, not Kynareth worship or full replacement worship.
- `PlayerWerewolfFaction` (`Skyrim.esm:091822`) and Companions beast-blood quest signals support the one-time Green Way Druidic Trial.

**Green Way: weak or cautious hooks**
- Hunting should not be the primary launch hook. Animal-kill morality requires hostility, context, and anti-farm filtering; use only curated hunts or very conservative daily-capped validation.
- Outdoor sleep is viable through the player alias sleep surface, but must remain cadence-based and not become a daily chore.

---

## Implementation Notes

**Vanilla hook surface:** Moderate. Breton content in Skyrim is thinner than Nord or Imperial — few Breton-specific quests. Heavy reliance on cross-faction quest events (Daedric quests, Thieves Guild, Dark Brotherhood) and behavioral patterns (outdoor sleep, standing stone visits, mercy choices).

**Complexity flags:**
- **Three parallel tracks (Integrity + Exposure + Druidic Standing):** Each uses the same `PDV_ReputationTrack` architecture as Imperial ConcordatStanding. The Breton sheet needs all three initialized correctly at setup depending on tradition choice. Priority: Knight's Road activates Integrity, WitchcraftExposure is global for all Bretons, and Green Way activates DruidicStanding plus the DruidicFork state.
- **Druidic Trial:** One-time dialogue choice after first werewolf transformation. Requires a trigger on werewolf-curse acquisition specific to Green Way Bretons. The choice branches into permanent diverging states ("beast serves the Green" vs. Hircine fork). This is custom work but it's a single pivot event, not ongoing complexity.
- **"Without reward" detection for Knight's Road:** This is the hardest signal to implement cleanly. Suggested approach: track quest-helper acts that have a zero-gold reward variant chosen. Don't try to detect intent generally — use specific quest flag variants.
- **WitchcraftExposure at Notorious:** The x1.25 gain modifier in ProcessDawn is simple. Vanilla provides specific Vigilant hostility/world-interaction surfaces, but not a general Daedra-worshipper reputation hunt. Any exposure-driven hunter encounter layer requires authored PDV support or CK condition work on relevant NPCs. A light Vigilant pressure extension is desirable but should remain optional/post-lock unless the encounter pattern proves cheap.
- **Vampire curse interaction:** Three-tradition result matrix is complex — see Curse States. Knight's Road vampire vs. Hidden Art vampire vs. Green Way vampire produce completely different outcomes.

**Cost class profile:**
- Daedric quest completion: Cost Class A (quest events)
- KnightlyVowIntegrity updates: Cost Class A (specific quest events, not ambient)
- Mercy/intent detection: Cost Class B-C (dialogue filtering)
- Druidic Trial fork: Cost Class C (custom one-time dialogue event)

**Approved 1.0 lock additions (2026-05-19):**
- Knight's Road positive scoring is curated-only for launch; broad "good person" inference is out.
- WitchcraftExposure is major-act only; no generic spellcast, stealth, artifact-ownership, or place-visit scoring.
- Witchcraft-to-Knight drag is major-act based: Thieves Guild / Dark Brotherhood commitment, Nightingale oath, Daedric quest commitment, Namira feast, Molag Bal domination, and killing Vigilants can damage Integrity. Ordinary magic, College membership, private curiosity, and shrine visits do not.
- Green Way is location/rite-first for launch; hunting is secondary/cautious.
- Dawn processing order is event deltas, curse/fork state, cross-lane drag, devotion modifiers, then piety consolidation.
- Player-facing notifications are threshold-only.
- WitchcraftExposure visible decay can return to `Hidden`, but major act history remains for debug, offer context, and future authored pressure.
- Public Divine cover is not shrine-spam laundering: no major occult signal for 3 days, `-5` at most once per 7 days.
- KnightlyVowIntegrity shrine restoration is capped at `75`; returning above `75` requires curated mercy, justice, protection, or reparation.
- DruidicStanding is pressure-only; it does not pay a boon family by itself.
- The 1.0 DruidicFork implementation is the four-state enum `None/Druidic/Werewolf/Betrayed`; richer vampire restoration states are deferred.
- All three Breton tracks exist for every Breton. `WitchcraftExposure` is always active; `KnightlyVowIntegrity` and `DruidicStanding` can stay dormant until their tradition matters, but major authored events may write them so later path pressure has memory.
- Normal Breton tradition switching is unavailable in 1.0. Only major authored forks, such as Green Way -> Hircine through the Druidic Trial, can redirect the active religious frame.
- Contextual favors are authored per tradition lane for launch: Knight's Road, Hidden Art, and Green Way each use `3-5` trigger families. Focused deity flavor may tune presentation, but it does not require separate launch favor tables.
- Hidden Art has two valid intentional end states: careful cover in Hidden/Suspected and open Notorious rupture. Notorious is stronger but socially costly, not a pure upgrade.
- Breton is implementation-locked for 1.0 experience shape. Remaining reward values and exact effect magnitudes are balancing work, not open architecture.

### Implementation acceptance criteria (content review, 2026-06-01)

Derived from the LOCKED rules above; these are pass/fail checks for when the Papyrus layer is authored.

- **Tradition onboarding is explicit with no fallback.** `PDV_State_BretonTradition` setup must require an explicit choice and must **not** auto-assign a default. Because there is no silent fallback tradition, the setup prompt must re-present until answered — it cannot be dismissed into a tradition-less state. (Note the deliberate contrast with Bosmer, which *does* fall back to `LivingStory`.) (Source: `PDV_State_BretonTradition` lock.)
- **Hidden Art layers on the global Daedric system — no double-count.** Hidden Art deities (Hircine, Hermaeus Mora, Namira, Nocturnal) are reached *via the global Daedric system*, not a Breton-private fork. For Bretons, the global Daedric punitive "Taboo/stigma" response must **not** fire on top of Hidden Art scoring: the matrix `Legible` stance applies (confirmed `Legible` for Hircine, Nocturnal, Hermaeus Mora, Namira in `PDV_DaedricRacePrinceMatrix.csv`), so Daedric acts yield **piety**, not punishment. The Breton-specific social cost is carried **solely** by `WitchcraftExposure` (global, always active) plus authored Vigilant pressure — never a second stigma penalty stacked on the Daedric bond. (Source: "Available deities (Daedric)… via Daedric system"; "Hidden Art players get piety from what others are punished for"; `WitchcraftExposure` global lock; Daedric race/prince matrix.)

---

## Curse State Summary

| | Knight's Road | Green Way (Y'ffre) | Hidden Art |
|--|---------------|--------------------|------------|
| **Vampire** | Horror — Nine Divines lost, knightly oaths broken; no positive substitute | Betrayal-pressure state: Y'ffre devotion halts until an authored re-entry exists; richer restoration is deferred | Partial home in Volkihar court; witch-mother acceptance; Daedric patron (Molag Bal adjacent) may remain accessible |
| **Werewolf** | Theologically homeless — no framework, social/knightly cost, Integrity degrades on transformation | CONTESTED — Druidic Trial fires immediately; player chooses: "beast serves the Green" (full devotion resumes) or "Hircine's gift" (Y'ffre closes, Hircine path begins, WitchcraftExposure rises) | Natural fit — Glenmoril is family, Hircine already in the Hidden Art frame; no negative consequence |

**Druidic Trial details (Green Way + Werewolf only):**
```
→ "The beast serves the Green"
   Druidic tradition accepts the shape as deepened beast-kinship
   Y'ffre devotion resumes at full rate
   Hircine devotion path unavailable (loyalty declared)

→ "Hircine's gift is mine"
   Druidic tradition rejects; the fork moves toward Werewolf or Betrayed
   Y'ffre closes, Hircine drift begins
   WitchcraftExposure increases (beast-pact is visible)
```
Lore rationale: Druidic circles are canonically split on werewolfism. This fork gives the player the theological choice the Druids themselves have — the only race/curse combination that offers a genuine theological decision rather than just a penalty.
