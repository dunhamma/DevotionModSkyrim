# Altmer -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 13 (Altmer (full draft; implementation-spec closed))
**Regenerated:** 2026-05-30 via `node tools/pdv_writer_review.mjs`
**Rows:** 62 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Altmer_Pantheon_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 85 / 200 |  | Auri-El is acknowledged at dawn. Spell cost -3% in all schools; magic resistance +5%. |  |

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
| Trinimac: Stern, militant, civilizational; speaks of the project defended by force and orthodoxy held; the martial ancestor. | `PDV_Bless_Altmer_Trinimac_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 138 / 200 |  | Trinimac blesses the project defended by force. One-handed damage +5%; an enforcement act under high orthodoxy grants armor +15 for a day. |  |
| Xarxes: Dry, archival, lineage-keeping; speaks of what is written, the genealogy, the quiet truth that outlasts enforcement. | `PDV_Bless_Altmer_Xarxes_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 115 / 200 |  | Xarxes keeps your lineage. Lockpicking and Alteration +5%; a quest of real ancestry returns a day of cheaper magic. |  |
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

_8 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Shared_DawnSteadiness` | HUD corner notification. Dawn rite after Lorkhan pressure or crisis; one per day. | Player-2nd | 47 / 80 |  | The dawn holds. The dissonance settles for now. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Shared_CoherenceHeld` | HUD corner notification. Three coherent days; no contradictory major signal. | Player-2nd | 47 / 80 |  | Your acts still make one shape. The path holds. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_DivineBody_BalancedCultivation` | HUD corner notification. Moderate alignment held through a real choice. | Player-2nd | 57 / 80 |  | Neither zeal nor collapse. The middle path remains yours. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_AuriEl_ReturnReaffirmed` | HUD corner notification. Auri-El focused crisis resolution or dawn rite. | Player-2nd | 65 / 80 |  | Auri-El's dawn does not erase the scar. It shows the way through. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Magnus_ArtsRoad` | HUD corner notification. Magic milestone, Eye/College stage, curated spell learned. | Player-2nd | 58 / 80 |  | The arts become a road again. Magnus marks the discipline. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Trinimac_CivilizationDefended` | HUD corner notification. Orthodoxy-gated threat defeated; meaningful context only. | Player-2nd | 45 / 80 |  | Trinimac notes the defense, not the violence. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Xarxes_RecordKept` | HUD corner notification. Record/lineage/truth preserved; one-shot marker. | Player-2nd | 53 / 80 |  | The record holds. Xarxes keeps what must not be lost. |  |
| _(no tone match)_ | `PDV_Notif_Altmer_FavorNoted_Syrabane_Warded` | HUD corner notification. Protection milestone, apprentice aid, anti-mage survival. | Player-2nd | 50 / 80 |  | The ward held when it mattered. Syrabane was near. |  |

## Contextual favor (large, Marked)

_2 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Altmer_FavorMarked_Orthodox_CostlyEnforcement` | MessageBox. High alignment plus costly, curated enforcement only. | Narrator | 14+141 / 40+500 |  | Title: "Orthodoxy Held"   Body: "This was not obedience for its own sake. You defended the project where compromise would have been easier. The old order recognizes the cost." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_FavorMarked_Psijic_CrisisStudy` | MessageBox. Major crisis resolved through study/self-cultivation. | Narrator | 17+165 / 40+500 |  | Title: "Doubt Given Shape"   Body: "You did not flee the contradiction. You studied it until it became a path you could walk. The old doubt quiets, not because it is gone, but because it is understood." |  |

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
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_DragonbornDeclaration` | MessageBox. One-time; starts `Dissonant`. | Narrator | 25+177 / 40+500 |  | Title: "Named By The Mortal Story"   Body: "The world has named you Dragonborn. To Skyrim, this is glory. To Altmer faith, it is a mortal story closing around you. The path is not broken, but it has become harder to hold." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_SovngardeBeat` | MessageBox. One-time; strongest crisis flavor. | Narrator | 19+176 / 40+500 |  | Title: "Shor's Hall Is Real"   Body: "You have stood where Altmer doctrine would rather not look. Shor's dead have a hall, and its bridge had a guardian. This does not answer your faith. It wounds it with evidence." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_TalosContradiction` | MessageBox. Costly Talos aid, shrine protection, or hypocrisy proof only. | Narrator | 22+191 / 40+500 |  | Title: "The Forbidden Question"   Body: "Talos should be simple. Heresy. Usurpation. A mortal lie. Yet the world keeps offering evidence that simplicity cannot hold. What you do next will decide whether this becomes doubt or repair." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_LorkhanCrisis_CompanionsFork` | MessageBox. Companions, Wuuthrad, or nearby beast pressure; curse hard halt overrides. | Narrator | 17+190 / 40+500 |  | Title: "Ysgramor's Shadow"   Body: "The old human war story has touched you. Honor, beast-blood, Wuuthrad, Shor's people -- none of it is neutral to an Altmer soul. You can pass through it, but not without naming what it cost." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_VampireExiledPath_Entry` | MessageBox. Optional enhancement after vampire onset; Tier 1 cap only. | Narrator | 19+205 / 40+500 |  | Title: "Exile From The Dawn"   Body: "Auri-El is closed while you flee the sun. Still, an Altmer does not become nothing because the records cast them out. What remains is exile: a narrow discipline, a name kept privately, never a full return." |  |
| _(no tone match)_ | `PDV_Msg_Altmer_VampireExiledPath_Recognition` | Shown via Survey Devotion and on posture transitions. | Narrator | 122 / 240 |  | You are exiled from the dawn, not restored to it. A thin discipline remains, capped low, held only by refusal to collapse. |  |
