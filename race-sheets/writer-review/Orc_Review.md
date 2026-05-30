# Orc -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 11 (Orc (full draft))
**Regenerated:** 2026-05-30 via `node tools/pdv_writer_review.mjs`
**Rows:** 50 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 136 / 200 |  | Malacath has noted your conduct. Smithing experience +5%; Orcish armor you wear adds 5 armor; disease resistance +10%; brawl damage +5%. |  |

## Champion ambient line

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_ChampionAmbient_ForgeWork` | HUD corner notification. Stronghold Devoted + forge use; one per in-game day. | Player-2nd | 42 / 80 |  | The forge work feels like prayer answered. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_ChampionAmbient_StrongholdAccept` | HUD corner notification. Stronghold Devoted + at a stronghold; one per stronghold visit. | Player-2nd | 57 / 80 |  | At the stronghold, the shaman's words seem meant for you. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_ChampionAmbient_PrivateOath` | HUD corner notification. City Devoted + dignity-under-scorn beat; per qualifying event. | Player-2nd | 48 / 80 |  | Scorned, and unbroken. Malacath's witness holds. |  |

## Drifting away (neglect)

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_NeglectTexture_Forge` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 71 / 80 |  | The forge is only iron and heat now. The work has stopped being prayer. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_NeglectTexture_CityQuality` | HUD corner notification. One per lapse-band crossing; City mode. | Player-2nd | 67 / 80 |  | The work is just work now. There is nothing of the code left in it. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_NeglectTexture_LegionErasure` | HUD corner notification. One per lapse-band crossing; LegionExile mode. | Player-2nd | 63 / 80 |  | Folded away to fit in, you have left Malacath nothing to watch. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_NeglectTexture_OathBroken` | HUD corner notification. One per oath-break event; sustained breaking accrues separately. | Player-2nd | 54 / 80 |  | An oath set down is an oath Malacath saw you set down. |  |

## Survey Devotion (player checks status)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Orc_Survey_Stronghold` | Shown via Survey Devotion and on posture transitions. | Narrator | 130 / 240 |  | You carry Malacath's code inside the stronghold, where forge, kin, and oath hold it with you. Standing: %s. The witness continues. |  |
| _(no tone match)_ | `PDV_Msg_Orc_Survey_City` | Shown via Survey Devotion and on posture transitions. | Narrator | 133 / 240 |  | You carry Malacath's code in the city, alone, with no stronghold to confirm it. Standing: %s. Malacath watches what no one else does. |  |
| _(no tone match)_ | `PDV_Msg_Orc_Survey_LegionExile` | Shown via Survey Devotion and on posture transitions. | Narrator | 122 / 240 |  | You carry Malacath's code under foreign discipline. The contract is the oath; the endurance is the strength. Standing: %s. |  |

## Contextual favor (small, Noted)

_12 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_Stronghold_ForgeExcellence` | HUD corner notification. After-act; quality/value/context required; daily cap. | Player-2nd | 51 / 80 |  | The work serves the hold. Malacath marks the maker. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_Stronghold_BloodKinCrisis` | HUD corner notification. After-act; ordinary stronghold aid. | Player-2nd | 54 / 80 |  | The stronghold stands a little surer for what you did. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_Stronghold_CommunalProvision` | HUD corner notification. After-act; curated provision/oath stages. | Player-2nd | 45 / 80 |  | Provision given, oath kept. The kin are held. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_Stronghold_WorthyChallenge` | HUD corner notification. Noted only for stronghold crisis, boss, trial, or Malacath-significant fight; else Quiet. | Player-2nd | 48 / 80 |  | A true test met. Malacath was watching that one. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_City_QualityLabor` | HUD corner notification. After-act; named commission or quality threshold. | Player-2nd | 58 / 80 |  | The city does not know the work was a rite. Malacath does. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_City_Dignity` | HUD corner notification. After-act; curated hostile/dismissive outcome only. | Player-2nd | 48 / 80 |  | Met with scorn, you did not bend. The code held. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_City_OrcSolidarity` | HUD corner notification. After-act; named Orc aid; cooldown. | Player-2nd | 57 / 80 |  | You stood by your own where no stronghold would. Counted. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_City_SelfMadeCommunity` | HUD corner notification. Environmental/after-act; `PDV_SacredPlace` investment required. | Player-2nd | 38 / 80 |  | The place you built has witnesses now. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_LegionExile_ContractPressure` | HUD corner notification. After-act; completed pressure-bearing service only. | Player-2nd | 62 / 80 |  | The contract held under weight. Malacath counts the hard ones. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_LegionExile_Endurance` | HUD corner notification. Environmental/after-act; caps; endurance is context. | Player-2nd | 59 / 80 |  | The long road did not break you. Endurance is the strength. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_LegionExile_Discipline` | HUD corner notification. After-act; authored milestone proving the code was carried. | Player-2nd | 74 / 80 |  | You served without erasing yourself. The code crossed the border with you. |  |
| _(no tone match)_ | `PDV_Notif_Orc_FavorNoted_LegionExile_ExileBurden` | HUD corner notification. After-act; ordinary return to invested place. | Player-2nd | 73 / 80 |  | Returned from service to the place you made. The burden set down a while. |  |

## Contextual favor (large, Marked)

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Orc_FavorMarked_Stronghold_BloodKinCrisis` | MessageBox. Major crisis resolution or stronghold re-entry only; per-event. | God-voice | 9+89 / 40+500 |  | Title: "Blood-Kin"   Body: "You answered the stronghold's worst hour. The kin will not forget it, and neither will I." |  |
| _(no tone match)_ | `PDV_Msg_Orc_FavorMarked_LegionExile_ExileBurden` | MessageBox. Major return, restoration, or community-established moment only; per-event. | God-voice | 19+148 / 40+500 |  | Title: "The Burden Returned"   Body: "You went out under another's banner and came back to the place you made. The exile who returns carrying the code is the word I am proudest to speak." |  |

## Curse onset / cure

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Orc_CurseState_WerewolfOnset` | MessageBox. Once on first transformation as Orc. | God-voice | 16+182 / 40+500 |  | Title: "The Beast Tested"   Body: "The wolf is in you. I do not turn away from it. But the beast is judged by my code as the smith is: is it strong, does it endure, does it serve the kin or break them? Prove the wolf." |  |
| _(no tone match)_ | `PDV_Msg_Orc_CurseState_WerewolfCured` | MessageBox. Once on werewolf cure completion. | God-voice | 18+206 / 40+500 |  | Title: "The Wolf Set Aside"   Body: "You have put the beast down. It was never outside my code; it was a thing to master, and you mastered it by ending it. You are an Orc still, and still tested. The kin will weigh the wolf longer than I will." |  |
| _(no tone match)_ | `PDV_Msg_Orc_CurseState_VampireOnset` | MessageBox. Once on becoming vampire. | God-voice | 16+170 / 40+500 |  | Title: "Outside the Test"   Body: "You feed on the living now. That is dependency, and dependency is the thing my code exists to refuse. You stand outside the test. Cure this, or I have nothing to witness." |  |
| _(no tone match)_ | `PDV_Msg_Orc_CurseState_VampireCured` | MessageBox. Once on cure completion. | God-voice | 17+145 / 40+500 |  | Title: "Back Within Reach"   Body: "The thirst is gone. You are a living Orc again, and a living Orc can be tested. Begin. The kin will remember the lapse longer than the code does." |  |

## Shrine and privilege dialogue

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Dlog_Orc_Chief_Recognition` | Dialogue topic; Stronghold Devoted or Blood-Kin. | Player-2nd | 54 / 120 |  | "I carry the code. Tell me what the stronghold needs." |  |
| _(no tone match)_ | `PDV_Dlog_Orc_Shaman_Recognition` | Dialogue topic; Stronghold mode, any tier. | Player-2nd | 40 / 120 |  | "Speak Malacath's will. I will hear it." |  |
| _(no tone match)_ | `PDV_Dlog_Orc_LegionOfficer_Recognition` | Dialogue topic; LegionExile Devoted. | Player-2nd | 62 / 120 |  | "I serve under your command, and I serve the code. Both hold." |  |

## Life-mode shift (Orc)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Orc_LifeMode_Stronghold_Entry` | HUD corner notification. Fires on confirmed switch into Stronghold. | Narrator | 45 / 80 |  | You live inside the code now. Stronghold Orc. |  |
| _(no tone match)_ | `PDV_Notif_Orc_LifeMode_City_Entry` | HUD corner notification. Fires on confirmed switch into City. | Narrator | 45 / 80 |  | You carry the code in the city now. City Orc. |  |
| _(no tone match)_ | `PDV_Notif_Orc_LifeMode_LegionExile_Entry` | HUD corner notification. Fires on confirmed switch into LegionExile. | Narrator | 52 / 80 |  | You carry the code in service now. Legion and exile. |  |

## Other

_15 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T2_Stronghold` | Passive blessing description; visible whenever the player views active effects. | Narrator | 143 / 200 |  | Malacath watches the code carried in full. Your forge work tempers higher. Proving strength against a hard foe restores health after the fight. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T2_City` | Passive blessing description; visible whenever the player views active effects. | Narrator | 148 / 200 |  | Malacath sees the code held with no stronghold to hold it for you. Quality work earns his eye. Standing firm against scorn steadies your next words. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T2_LegionExile` | Passive blessing description; visible whenever the player views active effects. | Narrator | 146 / 200 |  | Malacath weighs the code carried under foreign command. A contract honored under pressure is counted. Endurance through the long march is counted. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T3_Stronghold` | Passive blessing description; visible whenever the player views active effects. | Narrator | 163 / 200 |  | Malacath's witness is complete. Weapons you forged strike 5% harder in your hands alone. Near death, once a day, his fury restores stamina and lightens your blows. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T3_City` | Passive blessing description; visible whenever the player views active effects. | Narrator | 155 / 200 |  | Malacath saw you hold the code where nothing rewarded it. Your craft always reaches its ceiling. Met with scorn and unbroken, your next fight steadies you. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Bless_Orc_Malacath_T3_LegionExile` | Passive blessing description; visible whenever the player views active effects. | Narrator | 139 / 200 |  | Malacath acknowledged the endurance. A hard service completed steadies the next fight. You carry 15 more weight; the exile's back is broad. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_ObservantEntry` | HUD corner notification. One per save. | Narrator | 52 / 80 |  | Malacath has begun to watch your conduct. Observant. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_FaithfulEntry` | HUD corner notification. One per save. | Narrator | 57 / 80 |  | Malacath sees the pattern. The code is carried. Faithful. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_DevotedEntry` | HUD corner notification. One per save; precedes the per-mode Champion entry. | Narrator | 40 / 80 |  | Malacath's witness is complete. Devoted. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_ObservantLapse` | HUD corner notification. One per direction per save. | Narrator | 46 / 80 |  | Malacath's eye has drifted from you. Wavering. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_FaithfulLapse` | HUD corner notification. One per direction per save. | Narrator | 47 / 80 |  | The code shows thin to Malacath now. Observant. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Notif_Orc_Malacath_DevotedLapse` | HUD corner notification. One per save per Devoted loss. | Narrator | 45 / 80 |  | Malacath no longer holds the Devoted witness. |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Msg_Orc_Malacath_ChampionEntry_Stronghold` | MessageBox. One-time on first Stronghold Devoted. | God-voice | 15+158 / 40+500 |  | Title: "The Forge Sings"   Body: "I do not bless. I witness. The forge, the oath, the strength, the kin -- you carried all four. The stronghold is yours, and the work you make knows your hand." |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Msg_Orc_Malacath_ChampionEntry_City` | MessageBox. One-time on first City Devoted. | God-voice | 15+154 / 40+500 |  | Title: "Witnessed Alone"   Body: "No chief confirmed you. No shaman named you. No stronghold held the code for you. I did. You held it where nothing made you, and that is the harder thing." |  |
| Malacath: Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. | `PDV_Msg_Orc_Malacath_ChampionEntry_LegionExile` | MessageBox. One-time on first LegionExile Devoted; Entry-only Champion. | God-voice | 18+160 / 40+500 |  | Title: "The Burden Carried"   Body: "You carried my code through a foreign army, a foreign province, years that wanted you smaller. You did not get smaller. The exile who endures is my truest word." |  |
