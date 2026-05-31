# Khajiit -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 14 (Khajiit (full draft))
**Regenerated:** 2026-05-31 via `node tools/pdv_writer_review.mjs`
**Rows:** 52 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Khajiit_Lunar_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 130 / 200 |  | The moons have noticed how you move. At night, your stamina regenerates 5% faster and your resistance to disease rises by 10%. |  |

## Deepening blessing (Tier 2)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Khajiit_Lunar_T2` | Passive blessing description; visible whenever the player views active effects. | Narrator | 137 / 200 |  | The Lattice holds you steady. Outdoor night travel carries more; cold and storms press lighter; full moons strengthen the day's devotion. |  |

## Devoted blessing (Tier 3)

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Khenarthi: Wind-voiced, road-knowing, merciful; speaks of passage, of arriving when needed, of the open sky; always moving. | `PDV_Bless_Khajiit_Khenarthi_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 152 / 200 |  | Khenarthi names you to the road. Sprinting outdoors drains 15% less stamina; storms no longer chill you; outdoor sleep restores health and stamina both. |  |
| Azurah: Twilight-voiced, threshold-knowing; the mother who shaped the Khajiit; speaks of fate and the hinges of the world; tender and certain. | `PDV_Bless_Khajiit_Azurah_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 138 / 200 |  | Azurah watches your thresholds. Spells cost 10% less at night and 15% less at dawn and dusk. The hinges of the world turn where you stand. |  |
| _(no tone match)_ | `PDV_Bless_Khajiit_BaanDar_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 143 / 200 |  | Baan Dar walks with the pariah. Once a week, a near-fatal escape returns a day-long pulse of fortune. Acts beyond the city walls weigh heavier. |  |
| Rajhin: A performer's voice, delighted, legend-making; speaks of theft as art and of the story worth telling; never petty. | `PDV_Bless_Khajiit_Rajhin_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 130 / 200 |  | Rajhin marks the artful thief. A theft from a notable target opens a brief unseen window; the first strike of a fight cuts deeper. |  |
| Alkosh: Rare, immense, order-keeping; the dragon-lord; speaks of cosmic chaos held back and the line that must not break. | `PDV_Bless_Khajiit_Alkosh_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 130 / 200 |  | Alkosh keeps the cosmic line. Your resistance to fire rises by 15%, and felling a named dragon grants a two-day blessing of order. |  |

## Focus emergence (silent)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Khajiit_FocusEmergence` | HUD corner notification. Fires once at dawn when emphasis shifts None to a deity; %s is the emerging deity. | Narrator | 65 / 80 |  | Your devotion has been leaning toward %s. The moons already knew. |  |

## Champion recognition (MessageBox)

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Khenarthi: Wind-voiced, road-knowing, merciful; speaks of passage, of arriving when needed, of the open sky; always moving. | `PDV_Msg_Khajiit_Khenarthi_ChampionEntry` | MessageBox. One-time on first Khenarthi Devoted. | God-voice | 16+135 / 40+500 |  | Title: "Khenarthi's Road"   Body: "The wind has carried you so long it has learned your name. Walk, and the road walks with you. The open sky was always your temple roof." |  |
| Azurah: Twilight-voiced, threshold-knowing; the mother who shaped the Khajiit; speaks of fate and the hinges of the world; tender and certain. | `PDV_Msg_Khajiit_Azurah_ChampionEntry` | MessageBox. One-time on first Azurah Devoted. | God-voice | 17+135 / 40+500 |  | Title: "Azurah's Twilight"   Body: "I shaped the Khajiit at the first dusk. I have watched you stand at every threshold since. You feel the world's hinges now. Cross well." |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_BaanDar_ChampionEntry` | MessageBox. One-time on first Baan Dar Devoted. | God-voice | 16+156 / 40+500 |  | Title: "Baan Dar's Favor"   Body: "The world offered you nothing, exile, and you made a life of it anyway. That is my whole gospel. When the reversal should have killed you, look for my hand." |  |
| Rajhin: A performer's voice, delighted, legend-making; speaks of theft as art and of the story worth telling; never petty. | `PDV_Msg_Khajiit_Rajhin_ChampionEntry` | MessageBox. One-time on first Rajhin Devoted; Entry-only. | God-voice | 14+133 / 40+500 |  | Title: "Rajhin's Touch"   Body: "The Footpad himself stole from an Emperor and wore Mephala's ring. You steal as though a story is being told. It is. I am telling it." |  |
| Alkosh: Rare, immense, order-keeping; the dragon-lord; speaks of cosmic chaos held back and the line that must not break. | `PDV_Msg_Khajiit_Alkosh_ChampionEntry` | MessageBox. One-time on first Alkosh Devoted; Entry-only. | God-voice | 13+144 / 40+500 |  | Title: "Alkosh's Line"   Body: "Lorkhaj's chaos gnaws at the seams of the world. Few are asked to hold the line against it. You were. You held. The dragon-lord knows your face." |  |

## Champion ambient line

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Khenarthi: Wind-voiced, road-knowing, merciful; speaks of passage, of arriving when needed, of the open sky; always moving. | `PDV_Notif_Khajiit_Khenarthi_ChampionAmbient_Road` | HUD corner notification. Khenarthi Devoted + open-road travel; one per in-game day. | Player-2nd | 63 / 80 |  | The road runs easy under you. Khenarthi's wind is at your back. |  |
| Azurah: Twilight-voiced, threshold-knowing; the mother who shaped the Khajiit; speaks of fate and the hinges of the world; tender and certain. | `PDV_Notif_Khajiit_Azurah_ChampionAmbient_Threshold` | HUD corner notification. Azurah Devoted + threshold beat; one per in-game day. | Player-2nd | 53 / 80 |  | A threshold ahead. Azurah's twilight goes before you. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_BaanDar_ChampionAmbient_Reversal` | HUD corner notification. Baan Dar Devoted + improbable survival; weekly cap. | Player-2nd | 59 / 80 |  | You should not have walked away from that. Baan Dar's hand. |  |

## Drifting away (neglect)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Khajiit_NeglectTexture_SubstrateThinning` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 66 / 80 |  | Too long indoors and walled in. The Lattice holds you more thinly. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_NeglectTexture_PatronFading` | HUD corner notification. One per lapse-band crossing; %s is the focus deity. | Player-2nd | 61 / 80 |  | %s sends less than you had grown used to. The lean is fading. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_NeglectTexture_CaravanForgotten` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 68 / 80 |  | The caravans do not know your face. You have not been where they go. |  |

## Survey Devotion (player checks status)

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Khajiit_Survey_Broad` | Shown via Survey Devotion and on posture transitions. | Narrator | 138 / 240 |  | You walk inside the Lunar Lattice, broad and unfocused, held by the moons and the road. Standing: %s. No god leads yet, and that is whole. |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_Survey_Focused` | Shown via Survey Devotion and on posture transitions. | Narrator | 114 / 240 |  | The Lattice holds you, and %s1 leads your devotion now. Standing: %s2. You did not choose it; you were walking it. |  |

## Contextual favor (small, Noted)

_7 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Substrate_RoadLife` | HUD corner notification. Environmental; daily cap; no fast-travel. | Player-2nd | 56 / 80 |  | The road carries you kindly tonight. The moons are near. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Substrate_CaravanKinship` | HUD corner notification. After-act; cooldown per caravan encounter. | Player-2nd | 56 / 80 |  | The caravan knows you and is glad of it. Kinship counts. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Khenarthi_RoadGrace` | HUD corner notification. Environmental; Khenarthi emphasis. | Player-2nd | 50 / 80 |  | Khenarthi's wind finds your back on the open road. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Azurah_Threshold` | HUD corner notification. After-act; real threshold required. | Player-2nd | 49 / 80 |  | A crossing made well. Azurah's twilight marks it. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_BaanDar_Outnumbered` | HUD corner notification. Momentary combat; adversity filter; cooldown. | Player-2nd | 62 / 80 |  | Outnumbered and still standing. Baan Dar favors the long odds. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Rajhin_ElegantTheft` | HUD corner notification. After-act; notable target; no petty-theft spam. | Player-2nd | 43 / 80 |  | A theft worth a story. Rajhin is delighted. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_FavorNoted_Alkosh_DragonOrder` | HUD corner notification. After-act; named dragon or order-keeping beat. | Player-2nd | 58 / 80 |  | A dragon down, the line held. Alkosh marks the order kept. |  |

## Contextual favor (large, Marked)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Khajiit_FavorMarked_BaanDar_Reversal` | MessageBox. Weekly cap; near-fatal escape only. | God-voice | 16+142 / 40+500 |  | Title: "Pariah's Fortune"   Body: "That was not survivable, and you survived it. The god of pariahs wrote you a way out, because once, someone should have done the same for him." |  |

## Curse onset / cure

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Khajiit_CurseState_VampireOnset` | MessageBox. Once on becoming vampire. | God-voice | 21+215 / 40+500 |  | Title: "The Lattice Corrupted"   Body: "The thirst has taken you, little moon. The Lattice does not cast you out -- the moons do not disown their own -- but the caravans will fear you, and rightly. I will not look away. Few of the others can say the same." |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_CurseState_VampireCured` | MessageBox. Once on cure; clears posture toward Normal. | God-voice | 18+155 / 40+500 |  | Title: "The Lattice Clears"   Body: "The thirst is gone. The corruption lifts from the Lattice, and the caravans may learn your face again. Walk back into the moonlight. It was always waiting." |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_CurseState_WerewolfOnset` | MessageBox. Once on first transformation. | God-voice | 17+206 / 40+500 |  | Title: "A Competing Shape"   Body: "Hircine has given you another shape. The moons are about form, and you carry one too many now. You are still Khajiit -- strained, watched, but not erased. The community will fear the wolf. Hold to the road." |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_CurseState_WerewolfCured` | MessageBox. Once on werewolf cure; clears posture toward Normal. | God-voice | 15+200 / 40+500 |  | Title: "One Shape Again"   Body: "The wolf is set down, little moon. The Lattice holds a single shape once more, and the extra form no longer pulls against the moons. The caravans will lose their fear in time. The road is yours again." |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_CurseState_ShadowDriftEntry` | MessageBox. Once on entering ShadowDrift; voice deviation justified above. | Narrator | 24+193 / 40+500 |  | Title: "The Shadow Between Stars"   Body: "You have lived too long in the shadow -- night-only, predatory, drawn to the dark between the moons. The Lattice loosens its hold. Khenarthi's road and Azurah's twilight both feel far away now." |  |

## Shrine and privilege dialogue

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Dlog_Khajiit_Caravaneer_Recognition` | Dialogue topic; Faithful or above. | Player-2nd | 73 / 120 |  | "I walk the road and the moons walk with me. What does the caravan need?" |  |
| _(no tone match)_ | `PDV_Dlog_Khajiit_MoonPriest_Recognition` | Dialogue topic; Any tier. | Player-2nd | 63 / 120 |  | "The Lattice holds me. Speak of the moons, and of Riddle'Thar." |  |

## Lunar phase flavor (Khajiit)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Khajiit_LunarPhase_FullMoons` | HUD corner notification. Curated pool; cosmetic; per phase shift. | Narrator | 67 / 80 |  | Masser and Secunda are both full. The night's devotion runs strong. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_LunarPhase_Crossed` | HUD corner notification. Curated pool; cosmetic; per phase shift. | Narrator | 67 / 80 |  | The moons cross overhead. You feel the Lattice tighten in the bone. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_LunarPhase_Waning` | HUD corner notification. Curated pool; cosmetic; per phase shift. | Narrator | 64 / 80 |  | The moons wane. The road asks for a quieter, steadier faith now. |  |

## Road home acknowledgment (Khajiit)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Khajiit_RoadHome_Designate` | HUD corner notification. On designating an anchor (max 2-3). | Player-2nd | 63 / 80 |  | You have made this a road home. The circuit has an anchor here. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_RoadHome_Return` | HUD corner notification. On returning to an anchor after cycling; not repeat-camping. | Player-2nd | 63 / 80 |  | Back at a road home, the circuit holding. The Lattice steadies. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_RoadHome_MissedCadence` | HUD corner notification. On cadence lapse. | Player-2nd | 67 / 80 |  | You have not walked the circuit in too long. The anchors grow cold. |  |

## Other

_10 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Khajiit_LunarPosture_Normal` | Shown via Survey Devotion and on posture transitions. | Narrator | 92 / 240 |  | The Lunar Lattice holds you cleanly. The moons know your form, and the road knows your step. |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_LunarPosture_Strained` | Shown via Survey Devotion and on posture transitions. | Narrator | 111 / 240 |  | The Lattice holds you, but strained. The beast-shape is a competing form, and the caravans keep their distance. |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_LunarPosture_Corrupted` | Shown via Survey Devotion and on posture transitions. | Narrator | 111 / 240 |  | The Lattice still holds you, corrupted and thinned. The moons do not disown the undead, but the community does. |  |
| _(no tone match)_ | `PDV_Msg_Khajiit_LunarPosture_ShadowDrift` | Shown via Survey Devotion and on posture transitions. | Narrator | 108 / 240 |  | You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars. |  |
| _(no tone match)_ | `PDV_Bless_Khajiit_Lunar_Substrate` | Passive blessing description; visible whenever the player views active effects. | Narrator | 124 / 200 |  | The Lunar Lattice holds you. Night vision is keener after dark; outdoor night life and caravan kinship are felt as devotion. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_Lunar_ObservantEntry` | HUD corner notification. One per save. | Narrator | 47 / 80 |  | The moons have noticed how you move. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_Lunar_FaithfulEntry` | HUD corner notification. One per save. | Narrator | 43 / 80 |  | The Lattice holds you steady now. Faithful. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_Lunar_ObservantLapse` | HUD corner notification. One per direction per save. | Narrator | 45 / 80 |  | The moons mark you less surely now. Wavering. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_Lunar_FaithfulLapse` | HUD corner notification. One per direction per save. | Narrator | 45 / 80 |  | The Lattice holds you more thinly. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Khajiit_Focus_DevotedLapse` | HUD corner notification. One per save per focus loss; %s is the focus deity. | Narrator | 55 / 80 |  | The lean toward %s fades. The Devoted bond is not held. |  |
