# Argonian -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 19 (Argonian (full draft))
**Regenerated:** 2026-05-30 via `node tools/pdv_writer_review.mjs`
**Rows:** 49 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Argonian_Layered_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 150 / 200 |  | The Hist is distant but present; the People know you. Water breathing deepens; swimming +10%; near water, +2 health a second; disease resistance +15%. |  |

## Deepening blessing (Tier 2)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Argonian_Layered_T2` | Passive blessing description; visible whenever the player views active effects. | Narrator | 163 / 200 |  | All three layers are maintained under exile. Near water, +5 health a second; rest near water restores health and stamina fully; helping a Saxhleel returns stamina. |  |

## Devoted blessing (Tier 3)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Argonian_Hist_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 155 / 200 |  | The Hist reaches you where water reaches. In wetland and water, damage resistance +10%, sneak +15, attack speed +3%. The swamp gives what dry stone cannot. |  |
| _(no tone match)_ | `PDV_Bless_Argonian_Community_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 138 / 200 |  | The People are your armor. Helping Saxhleel returns strong piety; a friendly Argonian nearby grants +8 armor; the exile network knows you. |  |
| Sithis: The primordial void -- change, death, the dark before and around all things; acknowledged, never worshipped; speaks rarely, and never to comfort. | `PDV_Bless_Argonian_Sithis_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 157 / 200 |  | Sithis holds those who faced the void unflinching. Near death, a burst of stamina regeneration; a Dark Brotherhood contract sharpens speed and stealth after. |  |

## Champion ambient line

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_Hist_ChampionAmbient_Water` | HUD corner notification. Hist-layer Devoted + near water; one per in-game day. | Player-2nd | 57 / 80 |  | Near the water, the Hist is almost here. You can feel it. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Community_ChampionAmbient_KinPresent` | HUD corner notification. Community-layer Devoted + Argonian ally present; per qualifying event. | Player-2nd | 49 / 80 |  | A Saxhleel beside you. The exile community holds. |  |

## Drifting away (neglect)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_HistThinning_NeglectTexture` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 58 / 80 |  | The Hist is thinning. You feel less Saxhleel than you did. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_PeopleIsolation_NeglectTexture` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 65 / 80 |  | Alone too long, no Saxhleel near. Isolation deepens the distance. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_VoidDormancy_NeglectTexture` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 66 / 80 |  | Sithis lies dormant. The void is there, but you have not faced it. |  |

## Survey Devotion (player checks status)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Argonian_Survey_Layered` | Shown via Survey Devotion and on posture transitions. | Narrator | 113 / 240 |  | You carry the Saxhleel exile, far from Black Marsh. Standing: %s1. The Hist is %s2, the People %s3, the void %s4. |  |

## Substrate posture readout

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Argonian_HistPosture_Normal` | Shown via Survey Devotion and on posture transitions. | Narrator | 87 / 240 |  | The Hist is distant, as it always is in Skyrim, but it still reaches you. You are held. |  |
| _(no tone match)_ | `PDV_Msg_Argonian_HistPosture_Distant` | Shown via Survey Devotion and on posture transitions. | Narrator | 82 / 240 |  | The Hist has thinned to almost nothing. You feel like a stranger in your own skin. |  |
| _(no tone match)_ | `PDV_Msg_Argonian_HistPosture_Strained` | Shown via Survey Devotion and on posture transitions. | Narrator | 104 / 240 |  | The Hist relation is strained. The beast-shape sits between you and the trees, but they have not let go. |  |
| _(no tone match)_ | `PDV_Msg_Argonian_HistPosture_Silenced` | Shown via Survey Devotion and on posture transitions. | Narrator | 88 / 240 |  | The Hist has gone silent. It does not speak to its own undead. The cycle is interrupted. |  |
| _(no tone match)_ | `PDV_Msg_Argonian_HistPosture_Corrupted` | Shown via Survey Devotion and on posture transitions. | Narrator | 94 / 240 |  | The Hist relation is corrupted. Undeath and domination have fouled the connection at its root. |  |

## Contextual favor (small, Noted)

_8 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Hist_NearWater` | HUD corner notification. Environmental; daily cap. | Player-2nd | 74 / 80 |  | Near the water, the Hist relation steadies. The distance shrinks a little. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Hist_Reflection` | HUD corner notification. After-act; solitary reflection in a wild place. | Player-2nd | 59 / 80 |  | A still moment in a wild place. The Hist reaches toward it. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Community_SaxhleelAid` | HUD corner notification. After-act; cooldown per Argonian NPC. | Player-2nd | 54 / 80 |  | You helped one of your own. The exile community holds. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Community_AssemblageKept` | HUD corner notification. After-act; Windhelm Assemblage extra weight. | Player-2nd | 59 / 80 |  | The Windhelm Assemblage is surer for what you did. Kinship. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Void_DeathFaced` | HUD corner notification. After-act; curated death-facing choice. | Player-2nd | 60 / 80 |  | You faced a death without flinching. Sithis acknowledges it. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Void_BrotherhoodContract` | HUD corner notification. After-act; per Dark Brotherhood contract. | Player-2nd | 59 / 80 |  | A contract completed for the Brotherhood. The void answers. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Hist_SapMeditation` | HUD corner notification. After-act; designated Hist contemplation site; daily cap; MECHANICS-BLOCKED: requires Hist-sap vessel feature from Phase 21 custom content. | Player-2nd | 73 / 80 |  | Sap taken. The distance closes a little; the Hist hears across the marsh. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_FavorNoted_Community_SettlementKept` | HUD corner notification. After-act; defending Argonian settlement or Assemblage from direct threat; cooldown per event. | Player-2nd | 67 / 80 |  | You kept the People from harm. The exile community is safer for it. |  |

## Curse onset / cure

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Argonian_CurseState_VampireOnset` | MessageBox. Once on becoming vampire. | Narrator | 21+245 / 40+500 |  | Title: "The Hist Falls Silent"   Body: "You are undead now. The Hist gives Saxhleel souls and receives them at death -- and yours is no longer going where it was meant to go. The Hist falls silent. The People cannot safely hold you. Only the void stays near. This is the deepest grief." |  |
| _(no tone match)_ | `PDV_Msg_Argonian_CurseState_VampireCured` | MessageBox. Once on cure. | Narrator | 22+219 / 40+500 |  | Title: "The Hist Reaches Again"   Body: "The undeath is lifted. The Hist's silence breaks slowly -- it must learn to reach you again across both the distance and the memory of what you were. The People can hold you once more. It will take time. It can be done." |  |
| _(no tone match)_ | `PDV_Msg_Argonian_CurseState_WerewolfOnset` | MessageBox. Once on first transformation. | Narrator | 15+222 / 40+500 |  | Title: "A Changed Shape"   Body: "The beast is in you. The Hist is accustomed to Saxhleel who change -- the shape strains the relation but does not sever it. The People can still recognize you. This is serious, but it is not the silence. It can be carried." |  |
| _(no tone match)_ | `PDV_Msg_Argonian_CurseState_WerewolfCured` | MessageBox. Once on werewolf cure; clears posture Strained. | Narrator | 17+219 / 40+500 |  | Title: "The Shape Settles"   Body: "The beast is set down. The strain on the Hist relation eases, and the People recognize you without reservation again. The shape that pulled at the bond is gone. What was carried is set aside; the Hist reaches you clean." |  |

## Shrine and privilege dialogue

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Dlog_Argonian_WindhelmAssemblage_Recognition` | Dialogue topic; Faithful or above. | Player-2nd | 71 / 120 |  | "I keep faith with our people in exile. What does the Assemblage need?" |  |
| _(no tone match)_ | `PDV_Dlog_Argonian_RiftenDocks_Recognition` | Dialogue topic; Faithful or above. | Player-2nd | 73 / 120 |  | "We hold each other where the Hist cannot reach. Tell me what is needed." |  |
| _(no tone match)_ | `PDV_Dlog_Argonian_HistKeeper_Recognition` | Dialogue topic; Hist-layer Devoted. | Player-2nd | 66 / 120 |  | "The Hist still reaches me, faintly. Speak of the old connection." |  |

## Track / posture transition

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_HistPosture_Distant_Entry` | HUD corner notification. On transition to Distant. | Narrator | 73 / 80 |  | The Hist has grown distant. You are becoming a stranger in your own skin. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_HistPosture_Strained_Entry` | HUD corner notification. On transition to Strained (lycanthropy). | Narrator | 78 / 80 |  | The Hist relation is strained. The beast-shape sits between you and the trees. |  |

## Hist sap meditation (Argonian)

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_HistSapMeditation_Activate` | HUD corner notification. Per meditation use; daily cap on the Hist gain. | Player-2nd | 67 / 80 |  | You take the Hist sap and go still. The trees feel a little nearer. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_HistSapMeditation_Effect` | HUD corner notification. Felt effect; quiet. | Player-2nd | 74 / 80 |  | The meditation steadies you. The Hist relation holds against the distance. |  |

## Bed of choice (Argonian)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_BedOfChoice_Designate` | HUD corner notification. On designating the single anchor. | Player-2nd | 72 / 80 |  | You have chosen this bed: the family you chose. The exile has an anchor. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_BedOfChoice_Return` | HUD corner notification. On a qualifying sleep at the chosen bed. | Player-2nd | 63 / 80 |  | Back at the bed you chose. The People hold you a little closer. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_BedOfChoice_MissedCadence` | HUD corner notification. On cadence lapse; light People decay, place bonus removed. | Player-2nd | 73 / 80 |  | You have not returned to your chosen bed in too long. The anchor weakens. |  |

## Sithis activation (Argonian)

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_SithisActivation_FirstSignal` | HUD corner notification. On the first significant Sithis signal. | Narrator | 72 / 80 |  | Sithis stirs at the edge of you -- change, death, the void acknowledged. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_SithisActivation_FullActivation` | HUD corner notification. On reaching the three-signal activation threshold. | Narrator | 71 / 80 |  | Sithis is fully awake in you now, a third way to make meaning in exile. |  |

## Other

_9 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Argonian_Observant_Entry` | HUD corner notification. One per save. | Narrator | 57 / 80 |  | The Hist reaches you, and the People know you. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Faithful_Entry` | HUD corner notification. One per save. | Narrator | 44 / 80 |  | All three layers hold under exile. Faithful. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Devoted_Entry` | HUD corner notification. One per save. | Narrator | 60 / 80 |  | The Hist knows you still, across all that distance. Devoted. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Observant_Lapse` | HUD corner notification. One per direction per save. | Narrator | 63 / 80 |  | The layers are thinning. Your standing has slipped to Wavering. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Faithful_Lapse` | HUD corner notification. One per direction per save. | Narrator | 41 / 80 |  | The exile identity is fraying. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Argonian_Devoted_Lapse` | HUD corner notification. One per save per Devoted loss. | Narrator | 61 / 80 |  | The deepest connection loosens. The Devoted bond is not held. |  |
| _(no tone match)_ | `PDV_Msg_Argonian_ChampionEntry_Hist` | MessageBox. One-time on first Hist-layer Devoted. | Narrator | 12+204 / 40+500 |  | Title: "Hist-Touched"   Body: "Across all the miles from Black Marsh, in the wetlands and waters of this cold province, the Hist has found a way to reach you. It does not speak. It does not need to. You are Saxhleel, wholly, even here." |  |
| _(no tone match)_ | `PDV_Msg_Argonian_ChampionEntry_Community` | MessageBox. One-time on first Community-layer Devoted; the People's voice. | God-voice | 17+188 / 40+500 |  | Title: "The Saxhleel Bond"   Body: "You kept the exile community alive when the Hist could not hold us. The Assemblage, the docks, every Saxhleel you stood beside -- we know you. You are the family we chose, as we are yours." |  |
| _(no tone match)_ | `PDV_Msg_Argonian_ChampionEntry_Sithis` | MessageBox. One-time on first Sithis-layer Devoted; Entry-only. | God-voice | 9+209 / 40+500 |  | Title: "Void-Held"   Body: "You looked into the dark that precedes and surrounds all things, and you did not flinch. Sithis does not comfort. But Sithis catches what has truly accepted the void. You have. Walk on, unafraid of the ending." |  |
