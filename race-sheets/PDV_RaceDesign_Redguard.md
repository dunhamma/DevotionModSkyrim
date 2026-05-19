# PDV Race Design — Redguard
**Last updated:** 2026-05-19
**Status:** Working draft — targets and proposals, not locked specs
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.8)

---

**Implementation status:** LOCKED (state, offer, sect-switch, and launch hook posture)

## Religious Identity

Redguard theology in 4E 201 is a survival narrative — and it just won. The Alik'r held against the Aldmeri Dominion when the Empire could not. That military fact is theologically real: HoonDing, the Make Way God, the Walker-Who-Makes-Way, proved himself again. The Far Shores are worth fighting for. The ancestors who died in that victory are watching from Tu'whacca's realm with something that is not regret.

Redguards in Skyrim carry this confidence alongside something harder: they're not in Hammerfell. The sands aren't here. The swords that learned their art from Leki's patient instruction are wielded in a province that doesn't know what Onsi means. And the dead here — the draugr, the restless spirits, the improperly buried — are an offense to Tu'whacca's order that a Redguard in good standing cannot simply ignore.

**Core design intent:** Redguard should feel sect-shaped and duty-shaped, with ancestry always present but not dominant in every moment. Every death encounter is a theological moment. The Ash'abah path's burden — carrying what others won't touch — should feel real, costly, and quietly honored by the gods who care.

---

## Worship Structure

```
Step 1: Choose sect at setup
  → Crown:    orthodoxy, bearing, sacred martial inheritance
  → Forebear: adaptation, public life, pragmatic survival
  → Ash'abah: funerary duty, undead-cleansing, impurity borne for others

All three remain part of the same Yokudan religious universe
They differ by current-era emphasis and social burden, not by theology

Step 2: Ancestor reverence layer is always active for all Redguards
  Strong for Crown, moderate for Forebear, very strong for Ash'abah

Step 3: Broad worship within sect-shaped Yokudan pantheon (Tier 2 cap)

Step 4: Focused primary deity commitment → Tier 3 unlocked
```

**Broad worship lane:** Crown, Forebear, and Ash'abah each count as separate broad-worship devotional lanes for contextual favors. They share Satakal/Tu'whacca/Yokudan ancestry as a spine, but their trigger families and favor texture stay sect-shaped.

**Shared 4E 201 Yokudan spine:** Satakal (the Worldskin) and Tu'whacca (Far Shores guide) are universally central across all three sects.

**Forebear interpretive overlap (LOCKED):** Forebear Redguards may recognize Arkay, Akatosh, Zenithar, Stendarr, Dibella, Julianos as interpretive parallels for Yokudan gods — but Yokudan names remain primary in gameplay. Imperial-parallel scoring flows through the Yokudan framework.

**Implementation locks (LOCKED):** `PDV_State_RedguardSect` uses `Crown = 0`, `Forebear = 1`, `AshAbah = 2`. First-run setup requires a sect choice. If sect state is unset or corrupt, fall back to `Forebear`, the broadest Skyrim bridge position. Sect state is separate from broad/focused commitment; formal deity offers use shared patron state and the global offer gate. The ancestor layer is a light origin-gated modifier/recognition layer, not a selectable path or full second blessing family.

**Sect switching locks (LOCKED):** Crown <-> Forebear switching requires two sect-coded signals on separate in-game days within seven, evaluated at dawn, unless a major curated sect-defining quest beat proves the destination immediately. Ash'abah entry requires a major death, undead, tomb, funerary, or impurity-bearing burden signal; casual undead fighting is not enough. Leaving Ash'abah requires a clear Crown or Forebear reorientation signal plus the same two-day destination proof. Do not drift out of Ash'abah because the player had a quiet week.

**Focused deity gate (LOCKED):** Redguard broad sect worship uses the global formal-offer rule: Faithful / `50` persistent piety, two qualifying signal-days within seven, dawn-only offer evaluation, per-deity cooldowns, no persistent offer queue, and stable accepted primary for 1.0. Sect filters deity priority and presentation, but does not replace shared patron-state machinery.

**In-game hook cross-check:** Redguard is buildable for 1.0 if launch scope favors death-duty, curated sect moments, and a small amount of PDV-authored Redguard devotional content. Strong hooks: Kill Actor Story Manager with undead classification, `LocTypeDraugrCrypt`, `LocTypeClearable`, Nordic ruin locations, dungeon-cleared state, Hall of the Dead / Arkay quest stages, a PDV-authored Tu'whacca devotional surface, and curated quest-stage rows for burial, necromancy, and tomb outcomes. Medium hooks: Forebear contracts/service/trade through curated quest stages; road passage through location-change plus no-fast-travel validation; Crown/Leki honorable combat through kill event plus one-handed/no-sneak/context filters. Rare hooks: HoonDing make-way through major quest milestones, dragons/named bosses, or tightly proven outnumbered/outleveled combat resolution. Authored 1.0 hooks: Ash'abah social stigma and Yokudan form in foreign spaces can ship only as light custom content, not as broad vanilla social simulation.

**Tu'whacca devotional surface (LOCKED FOR 1.0):** Tu'whacca should not present as simply Arkay under another name. Redguard uses the same broad implementation pattern as the locked Dunmer portable/private shrine: a permanent portable devotional item, usable anywhere, with a bonus when used in player-owned property or an authored private shrine context. The Redguard version is a portable Far Shores token rather than an ash-shrine. Lore support points toward private or portable Redguard practice in Skyrim: no public Redguard temples, Alik'r warriors maintaining portable shrines, and the sword itself functioning as a sacred object. Arkay shrines remain usable only as a fallback death-infrastructure proxy, especially for Hall of the Dead service or Forebear interpretive overlap. Player-facing copy should say the Redguard is using Skyrim's death institution while addressing Tu'whacca, not worshipping Arkay directly.

**Build-facing hook table (working lock):**

| Experience target | 1.0 hook candidate | Confidence | Implementation posture |
|---|---|---|---|
| Tu'whacca / ancestor death-duty | Existing Kill Actor route plus undead classification (`ActorTypeUndead`, draugr/skeleton/ghost/vampire filters) | Strong | Score cautiously with daily caps; stronger weight when paired with tomb, Hall of the Dead, or quest context |
| Draugr tomb obligation | `LocTypeDraugrCrypt`, `LocTypeClearable`, `LocSetNordicRuin`, dungeon-cleared state, boss death | Strong | Per-location or per-clear marker; do not reward repeat visits or every minor undead |
| Hall of the Dead duty | Curated Hall of the Dead / Arkay quest stages, Hall locations, Arkay priest/service content | Strong | One-shot per local quest or authored service; good for Ash'abah and all-sect ancestor layer |
| Tu'whacca devotional surface | Dunmer portable/private shrine pattern copied for Redguard: permanent portable Far Shores token, with private/home bonus; optional sword-tending rite; Arkay shrine only as fallback death-infrastructure proxy | Strong | Primary Redguard surface should be Yokudan. Arkay is a bridge surface, not the god being worshipped. |
| Necromancer operation opposed | Warlock/necromancer lair classification plus curated quest stages or boss defeat | Medium-strong | Prefer curated operation completion; avoid judging all magic users by location name |
| Forebear road passage | Player alias `OnLocationChange`, travel distance/time, reject `OnPlayerFastTravelEnd` as a positive trigger | Medium | Environmental favor or recent-signal strength only; avoid chore-loop travel scoring |
| Forebear contract/service | Curated bounty, delivery, mercenary, faction-service, or payment-completion quest stages | Medium | One-shot quest-stage rows; no generic gold-making or radiant spam without whitelist |
| Crown/Leki honorable combat | Kill Actor route plus one-handed weapon, no sneak opener where detectable, no follower assist where detectable, boss/duel context | Medium | Conservative filters; likely shared helper with Nord honorable-combat work |
| HoonDing make-way | Major quest milestones, dragons/named bosses, final boss clears, optional outnumbered/outleveled combat resolution | Medium for milestones, risky for combat odds | Include curated milestone and named-boss HoonDing in 1.0. Combat-odds trigger may ship only if proof-tested, weekly capped, and resistant to farming. |
| Alik'r / Hammerfell diaspora choice | `MS08` (`In My Time Of Need`) QUST `Skyrim.esm:01CF25`; stage `200` = helped Saadia, stage `201` = delivered Saadia to Kematu/Alik'r | Verified hook, locked sect split | One-time sect signal: stage `201` is Crown / Hammerfell justice / ancestor-duty positive; stage `200` is Forebear / exile-protection / anti-Alik'r positive. |
| Ash'abah social stigma | Light PDV-authored Redguard reaction lines and status text conditioned on Ash'abah state | Weak vanilla, feasible custom | 1.0 may include light stigma if custom dialogue/content is in scope. Do not use service penalties for launch and do not promise broad dynamic social simulation. |
| Yokudan form in foreign spaces | Custom ritual/proxy options, Redguard dignity dialogue, authored sect choices | Weak vanilla, feasible custom | 1.0 can support this through the Tu'whacca object/ritual and curated quest outcomes; do not infer from generic shrine avoidance. |

---

## Contextual Favor Pilot Table

**Status:** Pilot cleared (2026-05-18 cross-pilot pass)

**Pilot scope:** Broad-worship lanes only. Focused primary-deity tables wait until the broad-lane pilot clears review.

**User-experience proof:** Redguard broad worship should feel like sect-shaped Yokudan duty in exile: the Far Shores, the dead, martial bearing, road survival, and social burden all matter, but Crown, Forebear, and Ash'abah do not answer the same situations in the same way. It is sect duty and ancestor nearness, not Nord mythic breadth or Imperial civic institution.

**Shared spine rule:** Satakal, Tu'whacca, and ancestor reverence are present in all three lanes, but their trigger families must stay sect-shaped. Shared death and ancestor hooks should not erase the difference between Crown inheritance, Forebear adaptation, and Ash'abah burden.

**Crown make-way rule:** Crown may receive rare make-way favor, but only as Ruptga/HoonDing-adjacent sacred survival through honorable adversity. It is not Forebear improvisation, road pragmatism, or social adaptation.

**Ash'abah marking rule:** Routine undead-cleansing and burial duty should usually be `Noted`. Escalate to `Marked` only when the player bears a real burden others avoid: major tombs, major necromancer operations, costly impurity choices, or later custom social-stigma content.

### Crown Broad Worship

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Crown broad worship | Sacred martial bearing | Story Manager kill event; one-handed weapon check; no sneak opener where detectable; no follower assist where detectable; duel or boss-combat quest stages | Momentary combat | Quiet | Leki/Onsi/Satakal texture. Same hook challenge as Nord honorable combat; use conservative checks. |
| Crown broad worship | Tomb respect and ancestor presence | Major draugr tomb entry or clear event; Hall of the Dead quest completion; Tu'whacca devotional surface or fallback Arkay death-infrastructure proxy | Environmental / After-act | Noted | Ancestors feel close because orthodoxy is being carried in exile. Per site/quest, not repeat visits. |
| Crown broad worship | Yokudan form maintained in foreign spaces | Avoiding casual Divines convenience where an authored Yokudan/proxy option exists; Alik'r/Hammerfell diaspora quest choices; Redguard dignity dialogue outcomes | After-act | Noted | This is about keeping form, not rejecting all Imperial space. Needs curated hooks; some rows may stay post-1.0. |
| Crown broad worship | Make-way through honorable adversity | Outnumbered or overleveled combat win; major impossible-odds quest beat; Alik'r-aligned victory | Rare major | Marked | Ruptga/HoonDing-adjacent sacred survival through honorable adversity. Not Forebear improvisation. Should be scarce and not farmable. |

### Forebear Broad Worship

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Forebear broad worship | Road passage and adaptation | Long on-foot travel check; major location transition without fast travel; survival/weather travel state; caravan/road quest beats | Environmental | Noted | Tava leads. Must reject fast travel and short local movement. |
| Forebear broad worship | Honored contract and mixed-society work | Mercenary/contract quest completion; bounty or delivery quest with honest completion; merchant/trade quest stages; payment accepted without betrayal | After-act | Quiet / Noted | Zeht/Tava/HoonDing texture. Reward pragmatic honor, not generic gold-making. |
| Forebear broad worship | Make-way under pressure | Outnumbered or overleveled combat win; difficult escape/survival quest beat; hard negotiated success in foreign society | Momentary combat / Rare major | Quiet / Marked if major | HoonDing can flicker here even before focused commitment. Major make-way events stay rare. |
| Forebear broad worship | Respectful bridge without surrender | Forebear-appropriate Imperial-parallel shrine/proxy use; mixed-culture aid quests; Redguard dignity dialogue choices that preserve identity while cooperating | After-act | Noted | Imperial parallels are interpretive background only; Yokudan names remain primary. |

### Ash'abah Broad Worship

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Ash'abah broad worship | Undead-cleansing obligation | Draugr dungeon clear flag; necromancer operation completion; undead boss kill; location keyword plus boss death | After-act | Noted | Tu'whacca leads. Strongest first-release Ash'abah hook family; per site/boss, not repeat farm. |
| Ash'abah broad worship | Hall and burial duty | Hall of the Dead quest completion; Tu'whacca devotional surface after death content; fallback Arkay death-infrastructure proxy; burial-adjacent quest stages | After-act | Noted | The burden becomes bearable because it is acknowledged. Per hold/quest. |
| Ash'abah broad worship | Impurity borne for others | Clearing death content no one else will handle; protecting graveyards; accepting socially uncomfortable death-duty outcomes | After-act / Rare major | Noted / Marked if costly | Custom/post-1.0 dialogue may be needed for full social stigma. Mark only costly burden moments. |
| Ash'abah broad worship | Hard passage through the unclean | Major draugr tomb clear under difficult conditions; lich/named undead boss defeat; outnumbered undead fight win | Rare major | Marked | HoonDing applies as making a way through ritual uncleanness, not generic heroism. Naturally scarce. |

**Focused contrast note:** Focused Redguard devotion should later sharpen one theological center: focused Leki turns Crown martial bearing into blade discipline made personal; focused Tava or HoonDing turns Forebear adaptation into guided passage or impossible-odds recognition; focused Tu'whacca turns Ash'abah burden into direct Far Shores acknowledgment. Broad Redguard worship remains sect-shaped, shared-spine, and capped at Faithful.

---

## Ancestor Reverence Layer (Always Active)

All Redguards maintain this layer. It doesn't replace sect scoring — it modulates it.

**The layer is strongest at:**
- Death, tombs, and funerary contexts
- Encounters with the undead (draugr, skeletons, ghosts, vampires, necromancers)
- Proper burial and death-rite quest content
- Tu'whacca and Satakal devotion acts

**Strength by sect:**
- Crown: Strong — ancestors are the living proof of the orthodoxy's worth
- Forebear: Moderate — ancestors are honored but not the primary daily religious frame
- Ash'abah: Very strong — the entire Ash'abah path is an extension of funerary obligation

**What the layer generates:** Small, consistent piety from death-adjacent content across all sects. An anti-undead quality that accumulates over time. Recognition privilege at Hall of the Dead and equivalent spaces.

---

## Tier Rewards

### Tier 1 — Observant (all sects)
*Satakal's cycle acknowledged. Tu'whacca's guidance sought.*

- Resist disease 10% (the ancestors' resilience)
- One-handed damage +3% (Leki's martial inheritance — the sword is always present)
- After defeating an undead enemy, minor health regen (Tu'whacca's approval)
- Resist poison 5%

### Tier 2 — Faithful (sect-shaped)
*The Yokudan gods recognize your conduct. The ancestors are watching and approving.*

**Crown:**
- After honorable combat (no sneak attack, fought through to conclusion), +5% one-handed weapon damage for 60 seconds
- Visiting tomb sites in Skyrim generates ancestor layer piety (the obligation to honor the dead doesn't stop at Hammerfell's border)
- Visiting Hall of the Dead gives Tu'whacca recognition: next undead fight has bonus damage
- Crown martial discipline: Leki and Onsi piety from sword discipline acts (one-handed weapon focus, duel conduct)

**Forebear:**
- After surviving an outnumbered situation or long journey under difficulty, brief stamina regen (HoonDing acknowledges the way-making)
- Traveling between major areas or completing significant mercenary/contract work generates Tava piety (Tava is the bird-god of good passage)
- Trade and fair exchange with various cultures generates modest Zeht/Zenithar piety (Forebear pragmatic syncretism in action)
- Mercenary and contract completion generates piety when the contract was honored even under pressure

**Ash'abah:**
- After cleansing a draugr dungeon or defeating a necromancer operation, Tu'whacca's blessing: next rest restores full health
- Undead deal 15% less damage (Tu'whacca's protection for those who do the work)
- Hall of the Dead quests generate very strong piety (the most direct Ash'abah signal surface in vanilla Skyrim)
- Handling the dead with respect (burial-adjacent choices, protecting graveyards, opposing necromancy) always generates piety

### Tier 3 — Devoted (focused primary deity committed)
*The gods of the Far Shores know your name. Your ancestors speak of you.*

**Crown — Satakal / Tu'whacca / Ruptga / Leki:**

- *Satakal Champion:* The Worldskin is always shedding. After completing a quest with cosmic or generational stakes, the shedding is acknowledged: 24-hour resist fear + health regen bonus. Satakal's cycle doesn't mean death is bad — it means death is correct when it comes at the right time and after the right life.
- *Tu'whacca Champion:* Sacred Inheritance — the Far Shores draw nearer. After completing a death-rites quest or defeating a draugr boss, 24-hour undead damage resist 20%. Visiting tomb sites gives Tu'whacca's recognition: ancestors feel present (flavor privilege + modest health boost). Hall of the Dead priests treat you with maximum recognition privilege.
- *Leki Champion:* Blade discipline made holy. One-handed damage +8% cumulative (Tier 1 + Devoted bonus). After sword-discipline combat (one-handed, no heavy exploitation of range or crowd control), brief power-attack stamina recovery. Martial-honor quest choices generate extra piety.
- *Ruptga Champion (Tall Papa):* The first to find the Far Shores — achievement and survival as devotional acts. After completing a quest where you made a way through something that should have been impossible (thematically — HoonDing and Ruptga share this quality), 24-hour minor stat bonus across disciplines.

**Forebear — Tava / HoonDing / Leki:**

- *Tava Champion:* Wind-rider's grace. Open road travel has near-zero weather penalty (Survival Mode). After arriving at a new location from a significant journey, brief health and stamina restore (Tava brought you). Sprint stamina drain -15% (wind at your back). Storms outdoors no longer penalize — Tava's wind knows where you are.
- *HoonDing Champion:* *Champion moment:* Once per in-game week, after winning a battle that was genuinely impossible-odds (severely outnumbered or outleveled), HoonDing's brief acknowledgment fires: 24-hour bonus pulse of minor combat stats. This is the make-way moment — the Forebear who survived Skyrim by making a way when there wasn't one. The god who helped the Redguard hold against the Dominion is noticing similar quality in your struggles.
- *Leki Champion:* Same as Crown Leki, different framing — Forebear Leki devotion is less orthodox and more lived. The blade discipline is the same; the context is pragmatic survival rather than sacred martial inheritance.

**Ash'abah — Tu'whacca / Satakal:**

- *Champion moment:* Tu'whacca's Champion: Burden-Bearer's Grace. After defeating a draugr boss, completing a Hall of the Dead quest, or clearing an active necromancer operation, 48-hour Tu'whacca blessing fires: +5 health/stamina/magicka regeneration per hour (modest, meaningful over time). This is the emotional peak of the Ash'abah path — Tu'whacca's personal acknowledgment of the work you've done that your own people would not thank you for. The god of the Far Shores is grateful.
- *Additional payoff:* Tomb sites give Tu'whacca's presence (flavor privilege — brief ancestor-presence notification when entering major draugr tombs). Hall of the Dead NPCs treat you with recognition privilege (special dialogue, free services). Ash'abah Champion at full commitment: undead deal 25% less damage cumulative.
- *HoonDing (Ash'abah):* The Ash'abah who makes a way through the ritual uncleanness — HoonDing applies here too. After completing a particularly difficult Ash'abah-duty quest (clearing a major draugr tomb, defeating a lich), HoonDing's brief acknowledgment fires.

---

## Signature Friction

**Every death encounter is a theological moment.** Draugr are not just dungeon enemies for a Redguard — they are restless dead, and restless dead are Tu'whacca's domain and Ash'abah's obligation. Every necromancer operation is a religious affront. Every improperly handled grave is a failure of duty. These aren't imposed frictions — they're the natural consequence of what Redguard theology believes about death.

**Sect-specific frictions:**
- **Crown:** Maintaining orthodox Yokudan practice in a province built around Nine Divines infrastructure requires intentional choices about how you engage with Imperial religious spaces. A Crown Redguard who worships casually at Divines shrines isn't failing their religion — but they're not honoring it either. The distinction between Yokudan practice and Nine Divines convenience should feel like a real choice.
- **Forebear:** The HoonDing signals require genuinely difficult situations. You can't manufacture the make-way moment — it has to happen in actual play. A Forebear player who avoids difficult fights or always plays it safe will see fewer HoonDing signals. That's the correct friction.
- **Ash'abah:** Social stigma. The Ash'abah bear impurity for others — their own people are uncomfortable around them. This is content to develop in later phases (Redguard NPC dialogue), but the burden should feel present even at 1.0 through the specific narrowness of Ash'abah's scoring surface. They get strong rewards from death-adjacent content and less from everything else.

---

## Neglect Texture

- **Ancestor layer neglect:** Ignoring the Alik'r, ignoring Redguard dignity moments, handling the dead carelessly — the layer quiets. Not angry, just distant. The Far Shores seem further away.
- **Crown neglect:** Letting Yokudan practice slide into Nine Divines convenience without intention. The honorable combat requirements stop being honored. The ancestors who are watching stop feeling like they're watching approvingly.
- **Forebear neglect:** Taking the easy road — always fast-traveling, never taking contracts, not making any ways through anything. HoonDing doesn't notice people who avoid hard situations. The sense of pragmatic grace that comes from making your way through a foreign province fades.
- **Ash'abah neglect:** Ignoring the undead obligation. Skipping Hall of the Dead quests, leaving draugr tombs untouched when you could act, avoiding necromancer operations. The burden goes unmet, and the acknowledgment that made it bearable disappears. Tu'whacca is still there — but you're not doing the work he needs done.

**Vampire recovery note:** Redguard vampire cure flows through Tu'whacca first — "proper mortality, ancestor order, right re-entry into the cycle" — before any specific primary deity devotion can resume. This means the re-entry arc is itself a meaningful devotional sequence, not just waiting for a timer.

---

## Signal Examples

| Sect | Action | Cadence | Notes |
|------|--------|---------|-------|
| All | Defeat an undead enemy (draugr, skeleton, ghost) | Ancestor layer / Tu'whacca | Daily cap; quality over quantity |
| All | Complete Hall of the Dead quest | Tu'whacca | Per hold (one each); high weight |
| All | Defeat a necromancer and clear their operation | Tu'whacca | Per site; moderate weight |
| Crown | Win honorable single combat (no sneak, no follower assist) | Leki / Satakal | Daily cap; hard to detect cleanly |
| Crown | Visit a significant tomb site (major draugr dungeon) | Ancestor layer | Per site, not per visit |
| Crown / Forebear | Resolve `MS08` / `In My Time Of Need` | Ancestor / sect identity | One-time; stage `201` is Crown / Hammerfell justice / ancestor-duty positive, stage `200` is Forebear / exile-protection / anti-Alik'r positive |
| Forebear | Travel between areas on foot (not fast travel) | Tava | Daily cap; long-distance only |
| Forebear | Complete a mercenary or contract quest | HoonDing / Tava | Per quest; must be completed honestly |
| Forebear | Win fight vs superior odds (outleveled or outnumbered 3+) | HoonDing | Per event, weekly cap |
| Ash'abah | Clear draugr dungeon (all enemies defeated, boss included) | Tu'whacca | Per dungeon, one-time each |
| Ash'abah | Complete Hall of the Dead quest | Tu'whacca | Per hold; maximum weight for Ash'abah |
| Ash'abah | Defeat a lich or named undead boss | Tu'whacca | Per enemy; naturally scarce |
| All | Sword discipline in honorable combat | Leki | Daily cap; one-handed weapon only |
| All | Observe Yokudan devotional practice through portable shrine, Far Shores token, sword-tending rite, or fallback death-infrastructure proxy | Tu'whacca / Satakal / Leki by context | Daily cap; Arkay shrine is fallback infrastructure only, not the primary Redguard surface |

---

## Implementation Notes

**Vanilla hook surface:** Good for death-adjacent content (Hall of the Dead quests in each hold, draugr dungeons throughout Skyrim, necromancer operations). Moderate for sect-specific signals (HoonDing make-way moments, Crown honorable combat). Sparse for Ash'abah social burden without custom content; 1.0 can include a light authored stigma layer, but not full social simulation.

**Complexity flags:**
- **Tu'whacca / Satakal devotional surface:** Copy the Dunmer portable/private shrine pattern for Redguard: permanent inventory Far Shores token, prayer/ritual usable anywhere, and bonus in player-owned property or authored private shrine context. Redguard lore supports private camp or household shrines, Alik'r portable practice, and the sword as a sacred object. Arkay shrine use is fallback death infrastructure only.
- **HoonDing make-way detection:** "Genuinely difficult situation" is hard to define mechanically. 1.0 should include curated major milestones, dragons, and named-boss victories. Optional combat-odds detection uses outnumbered threshold (3+ enemies) or enemy-level-above-player threshold (5+ levels), combined with a win, but only after proof testing and with weekly caps.
- **Honorable combat for Crown:** Same detection challenge as Nord's Shor signal. Use Story Manager kill events with an approach-state check. Recommend same implementation strategy as Nord honorable kill, shared where possible.
- **Ash'abah dungeon clearance:** Detecting "all undead defeated in a dungeon" requires either a custom dungeon-cleared flag (most major dungeons have one via Quest stage) or a location-keyword check with enemy-alive count. The vanilla dungeon-cleared notification provides a reasonable hook.
- **Ash'abah social stigma:** Vanilla does not give enough general Redguard social reactivity to infer stigma safely. 1.0 can carry a light authored version through custom Redguard reaction lines and status text. Do not add service penalties for launch. Full dynamic social treatment remains post-1.0.
- **Alik'r questline:** `MS08` / `In My Time Of Need` is verified in Skyrim.esm as QUST `Skyrim.esm:01CF25`. Stage `200` completes the Saadia-helped route; stage `201` completes the Kematu/Alik'r-delivery route. Use these as one-time sect/ancestor signals: stage `201` is Crown / Hammerfell justice / ancestor-duty positive; stage `200` is Forebear / exile-protection / anti-Alik'r positive. Do not call this "A Good Warrior."
- **Forebear travel signal:** Same implementation concern as Khajiit road-travel — must not fire on fast travel. Location-change time tracking or explicit travel event.

**Cost class profile:**
- Hall of the Dead / burial quests: Cost Class A (quest completion events)
- Draugr dungeon clearance: Cost Class B (dungeon-cleared flag + undead kill filter)
- Honorable combat: Cost Class B-C (approach-state check on Story Manager kill events)
- HoonDing odds-detection: Cost Class B (enemy count + level threshold at combat resolution)
- Tu'whacca devotional surface: Cost Class A-B (custom object/ritual activation; optional fallback shrine FormID list)

---

## Curse State Summary

**Vampire:**
- Near-total collapse of normal Redguard devotion across all three sects
- No meaningful positive Yokudan substitute path
- Far Shores destiny is broken while the curse remains active
- Sect identity persists as memory and grief, not active religious function
- **On cure:** Redemption is possible. Restoration happens first through Tu'whacca — proper mortality, ancestor order, right re-entry into the cycle. Only after this re-entry sequence may the player re-dedicate to a specific primary god.
- Lore rationale: Tu'whacca guides souls to the Far Shores. Vampirism breaks that guidance entirely — the player has left the cycle Tu'whacca manages. Cure is a return to the cycle, which Tu'whacca must acknowledge before anyone else does.

**Werewolf:**
- Sect and god structure remain accessible — not collapsed, strained
- Favor and interpretation are strained but not severed
- No true Hircine-integrated Redguard path opens
- The condition remains theologically homeless rather than positively integrated
- Lore rationale: The curse source material supports strain and conflict, but not the total collapse seen in vampirism. Hircine is an intrusion into Redguard life, not a theological alternative.
