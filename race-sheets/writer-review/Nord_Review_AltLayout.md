# Nord -- Writer Review (alternative layout: by deity -> surface)

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 10 (Nord (full pilot))
**Layout:** Grouped by deity first, then by surface (Passive / MessageBox / HUD / Dialogue). Rows that are deity-agnostic (Survey, accept/refuse, posture transitions, contextual favor) live in a final `Shared (no single deity)` section.
**Rows:** 92 drafted -- same content as `Nord_Review.md`, regrouped.

> **How this differs from the default layout.** The default groups by in-game moment ("First blessing", "Deepening blessing", "Champion recognition", etc.) so a writer reviewing tier 1 prose for all 13 deities sees them in one block. This alternative groups by deity so a writer focused on, say, getting Talos's voice consistent sees every Talos line -- T1/T2/T3 blessing + champion + offer + neglect + ambient -- in one block, but has to jump between sections to compare deities at the same tier.

## Kyne (Old Ways)

**Tone:** Cold, clear, weather-imagery; spare lines; the storm in the sentence; addresses the hunter, not the citizen.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Kyne_T1` | T1 | 50 / 200 |  | Kyne has noticed your steps. Cold resistance +10%. |  |
| `PDV_Bless_Nord_Kyne_T2` | T2 | 126 / 200 |  | Kyne shelters the hunter who sleeps under her sky. Outdoor rest restores stamina fully. Wild animals stay calm until provoked. |  |
| `PDV_Bless_Nord_Kyne_T3` | T3 | 133 / 200 |  | The storm-mother answers your weather. In wind and rain, shouts and arrows carry farther; power attack stamina cost -10% in the open. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Kyne_ChampionEntry` | One-time on first Kyne Devoted. | 123 / 500 |  | Body: "You sleep where the storm sleeps. You walk where the wind walks. Kyne names her hunter." Title: "Kyne's Recognition" |  |
| `PDV_Msg_Nord_Kyne_Offer` | Dawn-fire; per-deity cooldown. | 17+106 / 40+500 |  | Title: "Kyne Reaches Back"   Body: "You sleep where I am. You hunt where I watch. Will you carry my name now, or will you stay among the many?" |  |

### HUD notification (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Kyne_ChampionAmbient_Storm` | Kyne Devoted + outdoor + storm; one per day. | 27 / 80 |  | The wind is going your way. |  |
| `PDV_Notif_Nord_Kyne_ChampionAmbient_OutdoorRest` | Kyne Devoted + outdoor sleep complete; one per rest. | 17 / 80 |  | You wake settled. |  |
| `PDV_Notif_Nord_Kyne_NeglectTexture` | One per lapse-band crossing per deity. | 29 / 80 |  | The wind passes you by today. |  |

### Dialogue

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Dlog_Nord_KynePriest_Recognition` | Kyne Devoted; one priest archetype. | 52 / 120 |  | "I sleep where Kyne sleeps. I hunt where she hunts." |  |

## Talos / Ysmir (Old Ways)

**Tone:** Defiant, terse, archaic; cadence short; mead-hall plainness with a king's weight; never apologetic.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Talos_T1` | T1 | 62 / 200 |  | Talos has caught the breath of your Voice. Shout recharge +5%. |  |
| `PDV_Bless_Nord_Talos_T2` | T2 | 108 / 200 |  | The old breath gathers behind your Thu'um. Shout recharge +10%. Defying the Talos ban is counted as worship. |  |
| `PDV_Bless_Nord_Talos_T3` | T3 | 132 / 200 |  | Talos marks the open defier. Shout recharge +15%. Stormcloak ground and Thalmor defiance return a short surge of stamina and health. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Talos_ChampionEntry` | One-time on first Talos Devoted. | 122 / 500 |  | Body: "You did not let me die. The old breath is yours to carry. Speak, and Tamriel hears Talos." Title: "Talos Names You" |  |
| `PDV_Msg_Nord_Talos_Offer` | Dawn-fire; per-deity cooldown. | 22+152 / 40+500 |  | Title: "Talos Marks the Defier"   Body: "You would not let them silence me. Carry the old breath openly, and Tamriel will hear Talos through you. Or hold the secret and walk the broad road yet." |  |
| `PDV_Msg_Nord_FavorMarked_TalosDefiance` | High-cost defiance (Old Ways framing). | 20+68 / 40+500 |  | Title: "Talos Notes the Risk"   Body: "You stood between them and me. Carry the old breath a little longer." |  |
| `PDV_Msg_Nord_FavorMarked_NineTalosOpenDefiance` | High-cost defiance (Nine framing). | 21+72 / 40+500 |  | Title: "Talos Inside the Nine"   Body: "You carried both my name and theirs, and would not put me down. Walk on." |  |

### HUD notification (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Talos_NeglectTexture` | One per lapse-band crossing per deity. | 45 / 80 |  | Your Voice feels like skill again, not faith. |  |
| `PDV_Notif_Nord_FavorNoted_OldWays_TalosDefiance` | After-act; costly-faithful only (Old Ways). | 41 / 80 |  | A small thing kept hidden. Talos answers. |  |
| `PDV_Notif_Nord_FavorNoted_NineDivines_TalosPressure` | After-act; costly-faithful only (Nine). | 47 / 80 |  | The contradiction holds. Talos hears even here. |  |

### Dialogue

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Dlog_Nord_TalosShrine_Recognition` | Talos Devoted, hidden shrine context. | 58 / 120 |  | "The old breath is mine to carry. Tell me what is needed." |  |

## Shor (Old Ways)

**Tone:** Martial, blunt, Sovngarde-coded; speaks of seats earned and feasts kept; never sentimental.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Shor_T1` | T1 | 93 / 200 |  | Shor's hall has noted your sword. When outnumbered in melee, stamina returns a little faster. |  |
| `PDV_Bless_Nord_Shor_T2` | T2 | 121 / 200 |  | Honor in the fight earns Shor's small mercy. A fair kill restores a small share of health. Companions work weighs double. |  |
| `PDV_Bless_Nord_Shor_T3` | T3 | 133 / 200 |  | Shor watches your bridge approach. Honorable kills restore health by the foe's strength; near death, a brief steadiness holds you up. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Shor_Offer` | Dawn-fire; per-deity cooldown. | 14+122 / 40+500 |  | Title: "Shor Calls You"   Body: "Your sword is honest. Your dead are counted by Tsun. Take a seat I am keeping for you, or wait and prove the road further." |  |

### HUD notification (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Shor_NeglectTexture` | One per lapse-band crossing per deity. | 36 / 80 |  | The hard fight is only a hard fight. |  |

## Tsun (Old Ways)

**Tone:** Shield-thane formality; measured, witness-toned; speaks of trial and crossing.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Tsun_T1` | T1 | 63 / 200 |  | Tsun marks the bearer of weight. Power attack stamina cost -5%. |  |
| `PDV_Bless_Nord_Tsun_T2` | T2 | 114 / 200 |  | The shield-thane sees the fight you should have lost. Surviving against severe odds returns a short stamina burst. |  |
| `PDV_Bless_Nord_Tsun_T3` | T3 | 149 / 200 |  | Tsun's weighing holds. After a trial against three or more foes, stamina holds at twenty percent for one day. Trial-and-challenge work counts double. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Tsun_Offer` | Dawn-fire; per-deity cooldown. | 15+106 / 40+500 |  | Title: "Tsun Weighs You"   Body: "You have stood the bad odds. Will you take the shield-thane's mark, or come at the bridge again unweighed?" |  |

## Stuhn (Old Ways)

**Tone:** Even-handed, mercy-without-softness; speaks of ransom kept, prisoners freed, fair fights.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Stuhn_T1` | T1 | 106 / 200 |  | Stuhn turns his eye to those who fight for allies. Bonus damage against foes who struck your allies first. |  |
| `PDV_Bless_Nord_Stuhn_T2` | T2 | 87 / 200 |  | A ransom kept, a prisoner freed: Stuhn answers in the next fight with a steadier guard. |  |
| `PDV_Bless_Nord_Stuhn_T3` | T3 | 132 / 200 |  | Stuhn names the merciful sword. Sparing a beaten foe raises your armor sharply for the next fight. Hostage-takers take heavier hits. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Stuhn_Offer` | Dawn-fire; per-deity cooldown. | 24+114 / 40+500 |  | Title: "Stuhn Sees the Open Hand"   Body: "You have spared what you might have struck. Will you carry the ransom-keeper's name, or wait to be tested further?" |  |

## Mara (Hearth, Old Ways)

**Tone:** Warm, household, intimate; speaks of doors, fires, returns; the kindest of the Nord voices.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Mara_T1` | T1 | 115 / 200 |  | Mara has counted your kindness. Healing magic is five percent more effective. Vendors offer slightly better prices. |  |
| `PDV_Bless_Nord_Mara_T2` | T2 | 125 / 200 |  | The hearth-mother holds your household. Marriage and home work earn extra devotion. Restoring a community is felt as worship. |  |
| `PDV_Bless_Nord_Mara_T3` | T3 | 124 / 200 |  | Mara warms your door. Helping a family restores full health on next rest. Temples of Mara grant you healing at reduced cost. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Mara_Offer` | Dawn-fire; per-deity cooldown. | 19+106 / 40+500 |  | Title: "Mara Opens the Door"   Body: "You have made a hearth where there was none. Will you let me hold it with you, or stay welcome among many?" |  |

### HUD notification (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Mara_NeglectTexture` | One per lapse-band crossing per deity. | 43 / 80 |  | The hearth feels colder when you come home. |  |

## Akatosh (Nine Divines)

**Tone:** Slow, even, time-measured; speaks of streak and continuance; austere rather than warm.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Akatosh_T1` | T1 | 96 / 200 |  | Akatosh holds your hour a little longer. Time-pressure skill checks are slightly more forgiving. |  |
| `PDV_Bless_Nord_Akatosh_T2` | T2 | 94 / 200 |  | Long devotion does not go unmeasured. Streaks of seven steady days return bonus piety at dawn. |  |
| `PDV_Bless_Nord_Akatosh_T3` | T3 | 149 / 200 |  | Akatosh keeps your continuance. Unbroken devotion of fourteen days returns cumulative skill experience. Amulet of Akatosh doubles its vanilla effect. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Akatosh_Offer` | Dawn-fire; per-deity cooldown. | 22+105 / 40+500 |  | Title: "Akatosh Marks the Hour"   Body: "Your days have stayed steady. Take the dragon's keeping, or measure your hours further before you choose." |  |

## Kynareth (Nine Divines)

**Tone:** Same weather imagery as Kyne but framed by temple grace; slightly steadier and less wild.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Kynareth_T1` | T1 | 62 / 200 |  | Kynareth's road shelters your traveling. Cold resistance +10%. |  |
| `PDV_Bless_Nord_Kynareth_T2` | T2 | 111 / 200 |  | Kynareth steadies the open way. Outdoor rest fully restores stamina; hawks circle before ambushes as a warning. |  |
| `PDV_Bless_Nord_Kynareth_T3` | T3 | 116 / 200 |  | Kynareth's grace answers your steps. In wind and rain, shouts and arrows carry farther; outdoor sleep restores more. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Kynareth_ChampionEntry` | One-time on first Kynareth Devoted. | 119 / 500 |  | Body: "You walked the long road in my sky. Kynareth's grace stays with you in wind and rain." Title: "Kynareth's Grace" |  |
| `PDV_Msg_Nord_Kynareth_Offer` | Dawn-fire; per-deity cooldown. | 27+107 / 40+500 |  | Title: "Kynareth Calls the Traveler"   Body: "The road has been good to you because I am good to the road. Carry my name, or hold to the broad reverence." |  |

### HUD notification (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Kynareth_ChampionAmbient_Storm` | Kynareth Devoted + outdoor + storm; one per day. | 20 / 80 |  | The road feels held. |  |

## Arkay (Nine Divines)

**Tone:** Quiet, ceremonial, death-respecting; speaks of rest, the cycle, what the dead are owed.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Arkay_T1` | T1 | 93 / 200 |  | Arkay marks the keeper of rites. Disease resistance +10%. Undead deal five percent less harm. |  |
| `PDV_Bless_Nord_Arkay_T2` | T2 | 86 / 200 |  | A burial done well is owed. Completing a death-rite restores full health on next rest. |  |
| `PDV_Bless_Nord_Arkay_T3` | T3 | 124 / 200 |  | Arkay's covenant holds. Undead deal twenty percent less harm. Hall of the Dead priests speak to you with priest-recognition. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Arkay_Offer` | Dawn-fire; per-deity cooldown. | 16+95 / 40+500 |  | Title: "Arkay's Covenant"   Body: "You have kept the rites. Will you walk as keeper of the cycle, or come to the door again later?" |  |

### Dialogue

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Dlog_Nord_ArkayHall_Recognition` | Arkay Devoted at any Hall of the Dead. | 47 / 120 |  | "I keep the rites. What is owed the dead here?" |  |

## Stendarr (Nine Divines)

**Tone:** Restraint, mercy under pressure; speaks of staying the hand, of the surrendering enemy.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Stendarr_T1` | T1 | 97 / 200 |  | Stendarr counts the spared hand. Brawl damage +5%. Vigilants of Stendarr stay neutral by default. |  |
| `PDV_Bless_Nord_Stendarr_T2` | T2 | 103 / 200 |  | Mercy chosen is mercy kept. After sparing a foe in dialogue, the next fight grants a small armor boost. |  |
| `PDV_Bless_Nord_Stendarr_T3` | T3 | 135 / 200 |  | Stendarr's restraint becomes your armor. Sparing a surrendering foe grants fifteen percent damage resistance for the rest of the fight. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Stendarr_Offer` | Dawn-fire; per-deity cooldown. | 23+98 / 40+500 |  | Title: "Stendarr Stays the Hand"   Body: "You have stayed the killing blow. Will you take my mercy as your armor, or hold the question open?" |  |

## Zenithar (Nine Divines)

**Tone:** Plainspoken, honest-trade voice; speaks of the day's work, fair weight, quality.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Zenithar_T1` | T1 | 53 / 200 |  | Zenithar weighs honest work. Crafting experience +5%. |  |
| `PDV_Bless_Nord_Zenithar_T2` | T2 | 122 / 200 |  | The honest hand makes a finer thing. Smithing improvement quality climbs a little. Honest commerce returns small devotion. |  |
| `PDV_Bless_Nord_Zenithar_T3` | T3 | 153 / 200 |  | Zenithar names the master's work. A crafted item may rise one quality step beyond your perk rank. After an honest sale, your next persuasion has a boost. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Zenithar_Offer` | Dawn-fire; per-deity cooldown. | 30+100 / 40+500 |  | Title: "Zenithar Names the Honest Hand"   Body: "Your work is steady, your weight true. Will you carry the trade-god's name, or stay among the broad?" |  |

## Julianos (Nine Divines)

**Tone:** Studied, careful, library-toned; speaks of pages read, schools learned, patience.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Julianos_T1` | T1 | 80 / 200 |  | Julianos reads your study. Novice and Apprentice spells cost three percent less. |  |
| `PDV_Bless_Nord_Julianos_T2` | T2 | 83 / 200 |  | Pages turned are devotion paid. Skill books return piety; College work earns extra. |  |
| `PDV_Bless_Nord_Julianos_T3` | T3 | 119 / 200 |  | Julianos sharpens your study. All spell costs -8%. Reaching a new magic skill rank grants one free cast of that school. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Julianos_Offer` | Dawn-fire; per-deity cooldown. | 18+98 / 40+500 |  | Title: "Julianos Reads You"   Body: "You have studied with patience. Will you carry the schools' name, or read further before you bind?" |  |

## Dibella (Nine Divines)

**Tone:** Warm, refined, performance-knowing; speaks of beauty made, the right word at the right moment.

### Passive blessing description

| Slot ID | Tier | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Bless_Nord_Dibella_T1` | T1 | 75 / 200 |  | Dibella notes the well-said word. Speech +5%. First impressions are warmer. |  |
| `PDV_Bless_Nord_Dibella_T2` | T2 | 105 / 200 |  | The right word at the right moment carries. After a strong persuasion, the next social check is steadier. |  |
| `PDV_Bless_Nord_Dibella_T3` | T3 | 172 / 200 |  | Dibella crowns the well-made hour. After a major persuasion or performance, the next equivalent check nearly succeeds on its own. Bards' College work earns strong devotion. |  |

### MessageBox (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Dibella_Offer` | Dawn-fire; per-deity cooldown. | 21+86 / 40+500 |  | Title: "Dibella's Recognition"   Body: "You make beauty where you go. Will you carry my craft openly, or stay among the loved?" |  |

## Shared (no single deity)

Cross-deity prose that doesn't belong under any one god: the player's reply menu, posture-transition notifications, broad-worship survey lines, environmental favor buckets, and curse hooks routed through Sovngarde/Shor's bridge.

### MessageBox -- player reply

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_OfferResponse_Accept` | Reused across Nord offers and as template for other races. | 16 / 40 |  | Accept the bond. |  |
| `PDV_Msg_Nord_OfferResponse_NotYet` | Sets per-deity cooldown only; no piety loss. | 8 / 40 |  | Not yet. |  |
| `PDV_Msg_Nord_OfferResponse_Refuse` | Repeated decline doubles cooldown to fourteen days. | 17 / 40 |  | Refuse the offer. |  |

### MessageBox -- Survey Devotion (narrator)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_Survey_BroadOldWays` | Shown via Survey Devotion and on posture transitions. | 93 / 240 |  | You honor the Old Ways broadly. The pantheon has noted you. Standing: %s. The road is steady. |  |
| `PDV_Msg_Nord_Survey_BroadNineDivines` | Shown via Survey Devotion and on posture transitions. | 115 / 240 |  | You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath. Standing: %s. |  |
| `PDV_Msg_Nord_Survey_Focused` | Shown via Survey Devotion and on posture transitions. | 45 / 240 |  | %s1 names you. Standing: %s2. The bond holds. |  |
| `PDV_Msg_Nord_Survey_FocusedSlipping` | Shown via Survey Devotion and on posture transitions. | 61 / 240 |  | %s1 still names you, but the bond is thinning. Standing: %s2. |  |

### MessageBox -- curse onset / cure (god-voice)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Msg_Nord_CurseState_WerewolfOnset` | Once on first transformation as Nord. | 14+126 / 40+500 |  | Title: "Hircine's Pull"   Body: "The beast is in the Companions' gift, but it stands against Shor's hall. Your seat on the bridge weakens while the hunt holds." |  |
| `PDV_Msg_Nord_CurseState_VampireOnset` | Once on becoming vampire. | 16+145 / 40+500 |  | Title: "Sovngarde Closes"   Body: "Molag Bal's shadow has fallen across you. Sovngarde will not name you while you carry his thirst. Cure the curse, and even then the scar remains." |  |
| `PDV_Msg_Nord_CurseState_VampireCured` | Once on cure completion. | 20+117 / 40+500 |  | Title: "The Door Stands Ajar"   Body: "The thirst is gone. The bridge is open again. But Tsun has seen what walked into the dark, and that is not forgotten." |  |

### HUD notification -- posture transitions (narrator)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_Observant_Entry` | One per deity per save. | 45 / 80 |  | %s has begun to notice your deeds. Observant. |  |
| `PDV_Notif_Nord_Faithful_Entry` | One per deity per save; suppress-if-offer-same-dawn. | 46 / 80 |  | Your standing with %s is steady now. Faithful. |  |
| `PDV_Notif_Nord_Devoted_Entry` | One per save; the patron's name. | 23 / 80 |  | %s claims you. Devoted. |  |
| `PDV_Notif_Nord_Observant_Lapse` | One per deity per direction per save. | 46 / 80 |  | Your standing with %s has slipped to Wavering. |  |
| `PDV_Notif_Nord_Faithful_Lapse` | One per deity per direction per save. | 39 / 80 |  | The favor of %s is thinning. Observant. |  |
| `PDV_Notif_Nord_Devoted_Lapse` | One per save per patron loss. | 55 / 80 |  | The bond with %s loosens. The Devoted bond is not held. |  |
| `PDV_Notif_Nord_General_AncestorsQuiet` | One per lapse into the general broad-worship neglect band per save. | 24 / 80 |  | The ancestors are quiet. |  |

### HUD notification -- contextual favor buckets (player-2nd)

| Slot ID | Trigger | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|
| `PDV_Notif_Nord_FavorNoted_OldWays_SkyRoad` | Environmental; one per outdoor sleep day. | 53 / 80 |  | The cold sits lighter on you. Kyne and Shor are near. |  |
| `PDV_Notif_Nord_FavorNoted_OldWays_HearthDefense` | After-act; one per defended hold/family event. | 21 / 80 |  | The hearth remembers. |  |
| `PDV_Notif_Nord_FavorNoted_OldWays_DeathRite` | After-act; one per Hall-of-the-Dead or burial quest. | 40 / 80 |  | The dead are owed and the dead are paid. |  |
| `PDV_Notif_Nord_FavorNoted_NineDivines_RoadGrace` | Environmental; one per outdoor sleep day. | 37 / 80 |  | Kynareth's road is good to you today. |  |
| `PDV_Notif_Nord_FavorNoted_NineDivines_HouseholdMercy` | After-act; one per qualifying event. | 45 / 80 |  | Mara and Stendarr have noted what you spared. |  |
| `PDV_Notif_Nord_FavorNoted_NineDivines_ProperDeath` | After-act; one per Hall-of-the-Dead or anti-necromancy beat. | 30 / 80 |  | The order of the dead is kept. |  |
