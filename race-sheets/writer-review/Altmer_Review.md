# Altmer -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 13 (Altmer (full draft))
**Regenerated:** 2026-05-31 via `node tools/pdv_writer_review.mjs`
**Rows:** 61 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Altmer_Pantheon_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 109 / 200 |  | Auri-El is acknowledged at dawn. Spells in all schools cost 3% less and your resistance to magic rises by 5%. |  |

## Deepening blessing (Tier 2)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Altmer_Pantheon_T2` | Passive blessing description; visible whenever the player views active effects. | Narrator | 164 / 200 |  | The pantheon relationship is stable and coherent. At dawn, a spell-cost reduction holds until noon. Advancing a magic skill makes the next cast of that school free. |  |

## Devoted blessing (Tier 3)

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Altmer_AuriEl_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 115 / 200 |  | Auri-El watches your return. Magic regenerates 25% faster out of combat; from dawn to midday, spells cost 15% less. |  |
| Magnus: Precise, scholarly, escape-coded; the architect who got out; speaks of the Elder Way and of the arts as the road. | `PDV_Bless_Altmer_Magnus_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 121 / 200 |  | Magnus marks the scholar's discipline. Alteration and Illusion cost 10% less; magic regenerates 20% faster out of combat. |  |
| Trinimac: Stern, militant, civilizational; speaks of the project defended by force and orthodoxy held; the martial ancestor. | `PDV_Bless_Altmer_Trinimac_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 168 / 200 |  | Trinimac blesses the project defended by force. Your one-handed attacks strike 5% harder, and an enforcement act under high orthodoxy raises your armor by 15 for a day. |  |
| Xarxes: Dry, archival, lineage-keeping; speaks of what is written, the genealogy, the quiet truth that outlasts enforcement. | `PDV_Bless_Altmer_Xarxes_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 134 / 200 |  | Xarxes keeps your lineage. Your Lockpicking and Alteration improve by 5%, and a quest of real ancestry returns a day of cheaper magic. |  |
| Syrabane: Gentle, guardian-toned, warding; the apprentices' protector; speaks of the magic that shields the one still on the path. | `PDV_Bless_Altmer_Syrabane_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 99 / 200 |  | Syrabane shields the apprentice. Magic-using foes deal 15% less damage; your wards absorb 15% more. |  |

## Champion recognition (MessageBox)

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_AuriEl_ChampionEntry` | MessageBox. One-time on first Auri-El Devoted. | God-voice | 14+168 / 40+500 |  | Title: "Auri-El's Dawn"   Body: "You held the path through a world built to make you forget it. The return is not a doctrine to you; it is a daily practice. Keep walking toward the dawn. I am the dawn." |  |
| Magnus: Precise, scholarly, escape-coded; the architect who got out; speaks of the Elder Way and of the arts as the road. | `PDV_Msg_Altmer_Magnus_ChampionEntry` | MessageBox. One-time on first Magnus Devoted. | God-voice | 13+156 / 40+500 |  | Title: "The Elder Way"   Body: "I did not break the trap with force. I studied until the wall became a door. You have studied as I studied. The arts are the road, and you are far along it." |  |
| Trinimac: Stern, militant, civilizational; speaks of the project defended by force and orthodoxy held; the martial ancestor. | `PDV_Msg_Altmer_Trinimac_ChampionEntry` | MessageBox. One-time on first Trinimac Devoted; Entry-only. | God-voice | 16+195 / 40+500 |  | Title: "Trinimac's Sword"   Body: "The project does not defend itself. You have defended it -- by force, by orthodoxy held without flinching. The Lorkhan world strikes hardest at those who strike hardest for me. You did not yield." |  |
| Xarxes: Dry, archival, lineage-keeping; speaks of what is written, the genealogy, the quiet truth that outlasts enforcement. | `PDV_Msg_Altmer_Xarxes_ChampionEntry` | MessageBox. One-time on first Xarxes Devoted; Entry-only. | God-voice | 14+153 / 40+500 |  | Title: "Xarxes' Record"   Body: "Enforcement forgets. The record does not. You have kept faith with the lineage and the written truth. Your name is set down where it cannot be unwritten." |  |
| Syrabane: Gentle, guardian-toned, warding; the apprentices' protector; speaks of the magic that shields the one still on the path. | `PDV_Msg_Altmer_Syrabane_ChampionEntry` | MessageBox. One-time on first Syrabane Devoted; Entry-only. | God-voice | 15+148 / 40+500 |  | Title: "Syrabane's Ward"   Body: "The path is long and the one who walks it can fall. I have shielded apprentices since the first of them. I shield you now. Walk on, and walk warded." |  |

## Champion ambient line

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn` | HUD corner notification. Auri-El Devoted + dawn observance; one per in-game day. | Player-2nd | 48 / 80 |  | The dawn answers you, and the return feels near. |  |
| Magnus: Precise, scholarly, escape-coded; the architect who got out; speaks of the Elder Way and of the arts as the road. | `PDV_Notif_Altmer_Magnus_ChampionAmbient_Milestone` | HUD corner notification. Magnus Devoted + magic skill milestone; per milestone. | Player-2nd | 55 / 80 |  | A school mastered further. Magnus marks the discipline. |  |

## Drifting away (neglect)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_NeglectTexture_OrthodoxyDrift` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 67 / 80 |  | Your acts no longer match your stated theology. You feel undefined. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_NeglectTexture_CultivationFading` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 79 / 80 |  | You have stopped cultivating yourself. The discipline that set you apart fades. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_NeglectTexture_AuriElDistant` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 57 / 80 |  | The dawn is only the dawn now. The return feels far away. |  |

## Commitment offer (the god asks)

_5 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_AuriEl_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 14+159 / 40+500 |  | Title: "Auri-El's Path"   Body: "You have kept the dawn through every temptation to forget it. Make the return your focus, and the foundation becomes the whole of your faith. Will you name me?" |  |
| Magnus: Precise, scholarly, escape-coded; the architect who got out; speaks of the Elder Way and of the arts as the road. | `PDV_Msg_Altmer_Magnus_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 24+118 / 40+500 |  | Title: "Magnus and the Elder Way"   Body: "You study as escape, not as utility. That is my path. Name me your focus, and the arts become the road back. Will you?" |  |
| Trinimac: Stern, militant, civilizational; speaks of the project defended by force and orthodoxy held; the martial ancestor. | `PDV_Msg_Altmer_Trinimac_Offer` | MessageBox. Dawn-fire; per-deity cooldown; requires ThalmorAlignment 70+. | God-voice | 15+186 / 40+500 |  | Title: "Trinimac's Call"   Body: "You have defended the project with the sword, not only the prayer. The orthodox path is the hardest, and the Lorkhan world will strike you hardest for it. Name me, and carry that weight." |  |
| Xarxes: Dry, archival, lineage-keeping; speaks of what is written, the genealogy, the quiet truth that outlasts enforcement. | `PDV_Msg_Altmer_Xarxes_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 21+136 / 40+500 |  | Title: "Xarxes and the Record"   Body: "You trust what is written over what is enforced. Name me your focus, and the lineage and the quiet truth become your devotion. Will you?" |  |
| Syrabane: Gentle, guardian-toned, warding; the apprentices' protector; speaks of the magic that shields the one still on the path. | `PDV_Msg_Altmer_Syrabane_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 16+124 / 40+500 |  | Title: "Syrabane's Guard"   Body: "You cast to shield, not only to strike. Name me your focus, and the warding arts become your path. Will you walk it guarded?" |  |

## Commitment reply (player answers)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_OfferResponse_Accept` | MessageBox. Shared across Altmer offers. | Player-2nd | 16 / 40 |  | Name this focus. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_OfferResponse_NotYet` | MessageBox. Sets per-deity cooldown only. | Player-2nd | 8 / 40 |  | Not yet. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_OfferResponse_Refuse` | MessageBox. Broad coherent worship continues. | Player-2nd | 23 / 40 |  | Keep to the foundation. |  |

## Survey Devotion (player checks status)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_Survey_ThalmorOrthodox` | Shown via Survey Devotion and on posture transitions. | Narrator | 144 / 240 |  | You hold the orthodox path: enforcement as faith, the project defended by force. Standing: %s. The Lorkhan world costs you most, and you pay it. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_Survey_DivineBody` | Shown via Survey Devotion and on posture transitions. | Narrator | 118 / 240 |  | You hold the Divine Body path: balanced cultural practice, the return pursued without rigid enforcement. Standing: %s. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_Survey_Psijic` | Shown via Survey Devotion and on posture transitions. | Narrator | 131 / 240 |  | You hold the Psijic path: the Old Ways, private meditation, heterodox scholarship. Standing: %s. The Lorkhan world costs you least. |  |

## Contextual favor (small, Noted)

_6 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_ThalmorOrthodox_Enforcement` | HUD corner notification. After-act; one per enforcement act, daily cap. | Player-2nd | 70 / 80 |  | Heresy named and answered. The orthodoxy marks the hand that enforces. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_ThalmorOrthodox_OrthodoxRite` | HUD corner notification. Environmental; dawn rite at an orthodox shrine, daily cap. | Player-2nd | 64 / 80 |  | The dawn kept by the strict rite. Doctrine is served as written. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_DivineBody_Cultivation` | HUD corner notification. After-act; mastery milestone, daily cap. | Player-2nd | 67 / 80 |  | Mastery earned and refined. You raise yourself as the project asks. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance` | HUD corner notification. Environmental; unforced dawn observance, daily cap. | Player-2nd | 66 / 80 |  | You greet the dawn unforced. The return is honored, not compelled. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Psijic_OldWaysMeditation` | HUD corner notification. Environmental; private meditation, daily cap. | Player-2nd | 61 / 80 |  | The Old Ways kept in private. The quiet path costs you least. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Psijic_ForbiddenLore` | HUD corner notification. After-act; heterodox lore recovered, daily cap. | Player-2nd | 70 / 80 |  | Hidden knowledge recovered. What is written outlasts what is enforced. |  |

## Contextual favor (large, Marked)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended` | MessageBox. Rare major; a costly act defending orthodoxy by the sword. | God-voice | 23+207 / 40+500 |  | Title: "Auri-El Marks the Sword"   Body: "You did not only pray for the project; you bled for it. The hardest path is the one that answers Lorkhan's world with steel, and you walked into the cost with open eyes. The dawn knows what it took from you." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_FavorMarked_DivineBody_ReturnAffirmed` | MessageBox. Rare major; affirming the return without enforcement. | God-voice | 24+200 / 40+500 |  | Title: "Auri-El Marks the Return"   Body: "You turned toward the dawn when the mortal world offered every reason to forget it, and you did it without a whip at anyone's back. This is the return as it was meant: chosen, not enforced. I keep it." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_FavorMarked_Psijic_UnseenStep` | MessageBox. Rare major; a lonely, unrewarded Old Ways moment. | God-voice | 28+183 / 40+500 |  | Title: "Auri-El Marks the Quiet Path"   Body: "You kept the Old Ways where no one could see and no one could reward you. The heterodox road is lonely and easy to abandon, and you did not abandon it. The foundation holds you still." |  |

## Curse onset / cure

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_CurseState_VampireOnset` | MessageBox. Once on becoming vampire; terminal -- no restoration arc. | God-voice | 14+215 / 40+500 |  | Title: "Auri-El Closes"   Body: "You flee the sun now, and the sun is the god of return. There is no path back from where you stand. The records will not hold your name. This is not a punishment. It is what shrinking from the dawn has always meant." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_CurseState_WerewolfHardHalt` | MessageBox. Once on first transformation; devotion halts entirely. | God-voice | 20+190 / 40+500 |  | Title: "The Project Inverted"   Body: "The whole of Altmer faith is to become spirit again. You have become a beast. There is no doctrine for this, no heresy small enough to hold it, no path in any direction. Devotion stops here." |  |

## Shrine and privilege dialogue

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Dlog_Altmer_AuriElDevotee_Recognition` | Dialogue topic; Auri-El Devoted. | Player-2nd | 57 / 120 |  | "I keep the dawn and the path back. Speak of the return." |  |
| _(no tone match)_ | `PDV_Dlog_Altmer_CollegeMage_Recognition` | Dialogue topic; Magnus or Syrabane focus; College context. | Player-2nd | 66 / 120 |  | "The arts are my devotion. Show me what the College keeps closed." |  |
| _(no tone match)_ | `PDV_Dlog_Altmer_ThalmorOfficer_Recognition` | Dialogue topic; Trinimac Devoted; ThalmorAlignment 70+. | Player-2nd | 65 / 120 |  | "I defend the project by the sword. The orthodoxy knows my name." |  |

## Track / posture transition (Altmer Lorkhan)

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_LorkhanPressure_T1` | HUD corner notification. One-time per major source; long cooldown on repeatable worship sources. | Player-2nd | 74 / 80 |  | You have touched the thing that broke your people. The dissonance is deep. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_LorkhanPressure_T2` | HUD corner notification. One-time per source or milestone; no repeat spam. | Player-2nd | 70 / 80 |  | This act belongs to Shor's framework, not yours. It stings to be here. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_LorkhanPressure_T3` | HUD corner notification. At most once per in-game day; surfaces the interpretation on first instance. | Player-2nd | 71 / 80 |  | You feel the old dissonance: this honors the mortal world Lorkhan made. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanInterp_FirstTime` | MessageBox. One-time, first Lorkhan pressure of any tier. | Narrator | 18+268 / 40+500 |  | Title: "The Old Dissonance"   Body: "Lorkhan made the mortal world, the trap your ancestors fell into. Acts that honor, strengthen, or celebrate his creation press against your faith -- not because a god disapproves, but because you have touched the thing that broke your people. You will feel this again." |  |

## Track / posture transition (Altmer Thalmor)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_ThalmorAlignment_Heterodox` | HUD corner notification. One per band entry. | Narrator | 76 / 80 |  | Alignment: Heterodox. Self-cultivation is favored; enforcement rings hollow. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_ThalmorAlignment_OrthodoxModerate` | HUD corner notification. One per band entry. | Narrator | 69 / 80 |  | Alignment: Orthodox Moderate. The whole pantheon stands equally open. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_ThalmorAlignment_ThalmorDevout` | HUD corner notification. One per band entry; unlocks Trinimac focus eligibility. | Narrator | 73 / 80 |  | Alignment: Thalmor Devout. Enforcement is worship; Trinimac's path opens. |  |

## Other

_12 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_Pantheon_ObservantEntry` | HUD corner notification. One per save. | Narrator | 58 / 80 |  | The dawn is acknowledged and the path is begun. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_Pantheon_FaithfulEntry` | HUD corner notification. One per save; suppress-if-offer-same-dawn. | Narrator | 44 / 80 |  | Your theology holds its coherence. Faithful. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_Focus_DevotedEntry` | HUD corner notification. One per save; %s is the focus deity. | Narrator | 38 / 80 |  | %s recognizes your coherence. Devoted. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_Pantheon_ObservantLapse` | HUD corner notification. One per direction per save. | Narrator | 51 / 80 |  | The path is acknowledged less surely now. Wavering. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_Pantheon_FaithfulLapse` | HUD corner notification. One per direction per save. | Narrator | 38 / 80 |  | Your coherence is slipping. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_Focus_DevotedLapse` | HUD corner notification. One per save per focus loss. | Narrator | 55 / 80 |  | The bond with %s loosens. The Devoted bond is not held. |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_DragonbornDeclaration` | MessageBox. One-time on being named Dragonborn. | Narrator | 26+267 / 40+500 |  | Title: "Named for the Mortal World"   Body: "They call you Dragonborn -- a mortal soul carrying the dragon's, blessed by the world Lorkhan made and the people who live in it. The gift is real. So is the dissonance: the thing that honors you is the thing your ancestors died trying to escape. You will carry both." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_SovngardeBeat` | MessageBox. One-time on the Sovngarde beat. | Narrator | 27+260 / 40+500 |  | Title: "The Hall That Should Not Be"   Body: "Sovngarde is real -- a hall of mortal dead who feast and do not dissolve, who chose to stay in the world rather than return beyond it. To an Altmer this is the trap made beautiful. You have seen it now, and you cannot unsee that the mortal world keeps its own." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_MarriageBeat` | MessageBox. One-time on taking a spouse. | Narrator | 18+251 / 40+500 |  | Title: "Bound to the World"   Body: "You have taken a spouse, a door, a hearth -- ties to the mortal world Lorkhan built. The Psijics would call it attachment; the orthodox would call it descent. It may be the truest thing you have done, or the deepest forgetting. Only you can say which." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_CompanionsFork` | MessageBox. One-time at the Companions beast-blood fork. | Narrator | 26+275 / 40+500 |  | Title: "The Beast at the Threshold"   Body: "The Companions offer you the blood of the beast -- to become, by choice, the furthest thing from spirit an Altmer can be. The whole of your faith is to rise out of flesh, not deeper into it. Refuse, and you keep the project. Accept, and there is no doctrine left to hold you." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_VampireExiledPath_Entry` | MessageBox. One-time after vampire onset, if the Exiled path is enabled. | Narrator | 16+245 / 40+500 |  | Title: "The Exile's Road"   Body: "Auri-El has closed, and the records will not hold your name. What remains is not devotion but exile -- a long walk outside the return, among others the dawn has let go. There is no path back. There is only how you carry the dark you have become." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_VampireExiledPath_Recognition` | MessageBox. On reaching the Exiled-path recognition beat. | Narrator | 22+284 / 40+500 |  | Title: "Known Among the Exiled"   Body: "The others outside the dawn know you now -- the cast-out Altmer, the ones the return forgot. It is not a congregation and it is not grace. It is recognition, of a kind, among those who share the same closed door. You are not alone in the exile, even if you stand alone before the god." |  |
