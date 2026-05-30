# Dunmer -- Writer Review

**Source:** `race-sheets/PDV_RaceContent_Manifest.md` section 12 (Dunmer (full draft))
**Regenerated:** 2026-05-30 via `node tools/pdv_writer_review.mjs`
**Rows:** 66 drafted

Edit the `Edit` column in place. Accepted edits are merged back into the manifest by hand. Char count is current vs hard cap; over-budget rows are flagged in the `!` column.

## First blessing (Tier 1)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Dunmer_GoodDaedra_T1` | Passive blessing description; visible whenever the player views active effects. | Narrator | 103 / 200 |  | The ash-prayer is kept and the Good Daedra are acknowledged. Fire resistance +5%; magic resistance +5%. |  |

## Deepening blessing (Tier 2)

_1 row._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Bless_Dunmer_GoodDaedra_T2` | Passive blessing description; visible whenever the player views active effects. | Narrator | 168 / 200 |  | The Reclamations hold steady around your exile. From dawn to midday, fire resistance +10% and magic resistance +5%. A power-attack kill on a strong foe returns stamina. |  |

## Devoted blessing (Tier 3)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Azura: Twilight-voiced, prophetic, tender about painful truth; speaks of thresholds and of becoming truer, not merely stronger; warns rather than commands. | `PDV_Bless_Dunmer_Azura_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 123 / 200 |  | Azura watches your thresholds. From dawn to noon, fire and magic resistance climb together; by night, magic costs 10% less. |  |
| Boethiah: Trial-voiced, sharp, strength-testing; speaks of the unworthy cut away and the self authored through struggle; combative, never cruel. | `PDV_Bless_Dunmer_Boethiah_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 152 / 200 |  | Boethiah marks proven strength. After felling a significant foe, carry weight +25 and lighter power attacks for a day. The ancestors record the victory. |  |
| Mephala: Soft, conspiratorial, web-voiced; speaks of the hidden people, the secret kept, the web drawn close; intimate rather than loud. | `PDV_Bless_Dunmer_Mephala_T3` | Passive blessing description; visible whenever the player views active effects. | Narrator | 134 / 200 |  | Mephala draws the web close. Poison resistance +20%; the hidden network returns 5% more gold. Discretion opens doors others never see. |  |

## Champion recognition (MessageBox)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Azura: Twilight-voiced, prophetic, tender about painful truth; speaks of thresholds and of becoming truer, not merely stronger; warns rather than commands. | `PDV_Msg_Dunmer_Azura_ChampionEntry` | MessageBox. One-time on first Azura Devoted. | God-voice | 22+143 / 40+500 |  | Title: "Azura at the Threshold"   Body: "I marked your people once, at the worst crossing they ever made. I mark you now. Stand at the thresholds, and you will not stand at them blind." |  |
| Boethiah: Trial-voiced, sharp, strength-testing; speaks of the unworthy cut away and the self authored through struggle; combative, never cruel. | `PDV_Msg_Dunmer_Boethiah_ChampionEntry` | MessageBox. One-time on first Boethiah Devoted. | God-voice | 15+148 / 40+500 |  | Title: "Boethiah's Mark"   Body: "You did not survive. You overcame. The unworthy fell, and you stood where they stood. Author yourself further -- I am watching, and so are the dead." |  |
| Mephala: Soft, conspiratorial, web-voiced; speaks of the hidden people, the secret kept, the web drawn close; intimate rather than loud. | `PDV_Msg_Dunmer_Mephala_ChampionEntry` | MessageBox. One-time on first Mephala Devoted. | God-voice | 13+145 / 40+500 |  | Title: "Mephala's Web"   Body: "The hidden people survive because someone holds the threads. You hold them now. The web knows your hand, and it will not let you fall through it." |  |

## Champion ambient line

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Azura: Twilight-voiced, prophetic, tender about painful truth; speaks of thresholds and of becoming truer, not merely stronger; warns rather than commands. | `PDV_Notif_Dunmer_Azura_ChampionAmbient_Threshold` | HUD corner notification. Azura Devoted + threshold beat; one per in-game day. | Player-2nd | 50 / 80 |  | At the threshold, Azura's voice goes ahead of you. |  |
| Boethiah: Trial-voiced, sharp, strength-testing; speaks of the unworthy cut away and the self authored through struggle; combative, never cruel. | `PDV_Notif_Dunmer_Boethiah_ChampionAmbient_Trial` | HUD corner notification. Boethiah Devoted + rival-strength kill; cooldown. | Player-2nd | 43 / 80 |  | A worthy foe down. The ancestors have seen. |  |
| Mephala: Soft, conspiratorial, web-voiced; speaks of the hidden people, the secret kept, the web drawn close; intimate rather than loud. | `PDV_Notif_Dunmer_Mephala_ChampionAmbient_HiddenObligation` | HUD corner notification. Mephala Devoted + hidden-community beat; per qualifying event. | Player-2nd | 41 / 80 |  | The web tightens, quietly, in your favor. |  |

## Commitment offer (the god asks)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| Azura: Twilight-voiced, prophetic, tender about painful truth; speaks of thresholds and of becoming truer, not merely stronger; warns rather than commands. | `PDV_Msg_Dunmer_Azura_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 16+197 / 40+500 |  | Title: "Azura's Twilight"   Body: "You have lived toward me without naming it -- the thresholds kept, the hard truths faced. This is not leaving the ancestors. It is the ash-prayer deepening toward dawn. Will you name me your focus?" |  |
| Boethiah: Trial-voiced, sharp, strength-testing; speaks of the unworthy cut away and the self authored through struggle; combative, never cruel. | `PDV_Msg_Dunmer_Boethiah_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 16+204 / 40+500 |  | Title: "Boethiah's Trial"   Body: "You have proven yourself against the unworthy again and again. The ancestors witnessed it; now I ask for it by name. This deepens the Reclamation; it does not replace the ash. Will you name me your focus?" |  |
| Mephala: Soft, conspiratorial, web-voiced; speaks of the hidden people, the secret kept, the web drawn close; intimate rather than loud. | `PDV_Msg_Dunmer_Mephala_Offer` | MessageBox. Dawn-fire; per-deity cooldown. | God-voice | 17+196 / 40+500 |  | Title: "Mephala's Whisper"   Body: "You have kept the web whole without being asked. The hidden people are safer for you. Name me your focus, and the ash-prayer deepens into the web -- nothing of the ancestors is set down. Will you?" |  |

## Commitment reply (player answers)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Dunmer_OfferResponse_Accept` | MessageBox. Shared across Dunmer offers. | Player-2nd | 31 / 40 |  | Deepen toward this Reclamation. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_OfferResponse_NotYet` | MessageBox. Sets per-deity cooldown only. | Player-2nd | 8 / 40 |  | Not yet. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_OfferResponse_Refuse` | MessageBox. Broad shared worship continues. | Player-2nd | 34 / 40 |  | Stay with the shared Reclamations. |  |

## Survey Devotion (player checks status)

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Dunmer_Survey_NoFocus` | Shown via Survey Devotion and on posture transitions. | Narrator | 118 / 240 |  | The ash-prayer holds and the three Good Daedra answer together. Standing: %s. No single Reclamation has your name yet. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_Survey_Azura` | Shown via Survey Devotion and on posture transitions. | Narrator | 101 / 240 |  | Azura holds your focus; the ash-prayer carries beneath her. Standing: %s. The thresholds are watched. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_Survey_Boethiah` | Shown via Survey Devotion and on posture transitions. | Narrator | 104 / 240 |  | Boethiah holds your focus; the ash-prayer carries beneath. Standing: %s. The dead record your victories. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_Survey_Mephala` | Shown via Survey Devotion and on posture transitions. | Narrator | 107 / 240 |  | Mephala holds your focus; the ash-prayer carries beneath. Standing: %s. The web holds you, and you hold it. |  |

## Substrate posture readout

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Dunmer_AncestorPosture_Normal` | Shown via Survey Devotion and on posture transitions. | Narrator | 91 / 240 |  | The ash-prayer carries. The ancestors are present, and they answer the life you are living. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_AncestorPosture_Strained` | Shown via Survey Devotion and on posture transitions. | Narrator | 117 / 240 |  | The ash-prayer carries, but thinly. Something in you sits uneasy with the ancestors -- the beast, or an unclean rite. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_AncestorPosture_Silent` | Shown via Survey Devotion and on posture transitions. | Narrator | 132 / 240 |  | The ash-prayer meets no answer. The ancestors do not speak to the undead. The silence is not punishment; it is what you have become. |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_AncestorPosture_RestoredScarred` | Shown via Survey Devotion and on posture transitions. | Narrator | 99 / 240 |  | The ash-prayer carries again. The ancestors answer -- but they remember the silence, and so do you. |  |

## Contextual favor (small, Noted)

_17 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Shared_AshPrayer` | HUD corner notification. Environmental/after-act; home improves but is not required. | Player-2nd | 58 / 80 |  | The ash-prayer carries, even here. The ancestors are near. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Shared_DiasporaSolidarity` | HUD corner notification. After-act; curated Dunmer-aid hooks. | Player-2nd | 55 / 80 |  | You stood by your own in exile. The ancestors count it. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Shared_ReclamationAck` | HUD corner notification. After-act; stays blended pre-focus. | Player-2nd | 50 / 80 |  | The Reclamations stir. All three are with you yet. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Shared_DeadObligations` | HUD corner notification. After-act; buildable proxies only, no penalty for impossible rites. | Player-2nd | 52 / 80 |  | The dead are tended as the ash allows. It is enough. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Azura_ThresholdKept` | HUD corner notification. Environmental/after-act; real threshold required, not decorative twilight. | Player-2nd | 59 / 80 |  | You crossed knowing it was a crossing. Azura goes with you. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Azura_PainfulTruth` | HUD corner notification. After-act; truth without cost stays Noted. | Player-2nd | 61 / 80 |  | You chose the hard truth over the useful lie. Azura marks it. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Azura_ExileEndured` | HUD corner notification. After-act/environmental; continuity across distance. | Player-2nd | 61 / 80 |  | Far from home, the practice held. Exile did not dissolve you. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Azura_StarRite` | HUD corner notification. Environmental/after-act; shrine and artifact signals. | Player-2nd | 52 / 80 |  | The Star and the twilight answer you personally now. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Boethiah_TrialSurvived` | HUD corner notification. Momentary/after-act; real pressure required, not every kill. | Player-2nd | 52 / 80 |  | Pressed hard, you proved strong. Boethiah counts it. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Boethiah_FalseAuthority` | HUD corner notification. After-act; ordinary overthrow stays Noted. | Player-2nd | 51 / 80 |  | An unworthy power pulled down. Boethiah is pleased. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Boethiah_BetrayalTest` | HUD corner notification. After-act; for surviving the test, never casual cruelty. | Player-2nd | 61 / 80 |  | Betrayed, and you answered with strength. The test is passed. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Boethiah_ChimericSelf` | HUD corner notification. After-act; generic Altmer kills do not qualify. | Player-2nd | 58 / 80 |  | You chose a Dunmer destiny over an order imposed. Counted. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Boethiah_Conspiracy` | HUD corner notification. Quiet/Noted; recognizes decisive covert action. | Player-2nd | 61 / 80 |  | The strike landed clean and unseen. Boethiah favors the plot. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Mephala_HiddenCommunity` | HUD corner notification. After-act; keeping the hidden people intact, not generic charity. | Player-2nd | 53 / 80 |  | The hidden people are whole because you kept them so. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Mephala_SecretKept` | HUD corner notification. Quiet/Noted; only when the secret preserves an obligation. | Player-2nd | 56 / 80 |  | A secret held, and an obligation with it. The web holds. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Mephala_ObligationWeb` | HUD corner notification. Quiet/Noted; the web tightening helpfully. | Player-2nd | 63 / 80 |  | A favor passed along an unseen thread. The web tightens kindly. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_FavorNoted_Mephala_NecessaryLie` | HUD corner notification. After-act; the survival lie, curated hooks, not broad fraud. | Player-2nd | 56 / 80 |  | The lie protected the web. Mephala knows the difference. |  |

## Contextual favor (large, Marked)

_4 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Dunmer_FavorMarked_Azura_PainfulTruth` | MessageBox. Marked only when the truth costs safety, power, or belonging. | God-voice | 12+116 / 40+500 |  | Title: "Azura's Star"   Body: "The truth cost you safety, and you took it anyway. That is the becoming I watch for. Walk on, clearer than you were." |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_FavorMarked_Azura_ChangedBody` | MessageBox. Rare major; curse-state confrontation or major cleansing only. | God-voice | 11+158 / 40+500 |  | Title: "Azura Knows"   Body: "Your body has changed, and I did not look away. What you are now is not simple, and I will not pretend it is. But you are still becoming, and I am still here." |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_FavorMarked_Boethiah_FalseAuthority` | MessageBox. Marked for major quest outcomes only. | God-voice | 18+142 / 40+500 |  | Title: "Boethiah's Calling"   Body: "You cut away an order that did not deserve to stand. This is the trial: not destruction, but the worthier thing put in its place. Stand there." |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_FavorMarked_Mephala_LethalSecret` | MessageBox. Marked only for major Mephala quest/artifact moments. | God-voice | 19+114 / 40+500 |  | Title: "The Whispering Door"   Body: "A blade in the dark, drawn for the web and not for yourself. The hidden people will never know it was you. I will." |  |

## Curse onset / cure

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Msg_Dunmer_CurseState_VampireOnset_AshSilenced` | MessageBox. Once on becoming vampire; sets posture Silent; voice deviation justified above. | Narrator | 23+175 / 40+500 |  | Title: "The Ash-Prayer Silenced"   Body: "You set the ash and speak the prayer, and for the first time in your life nothing answers. The ancestors do not speak to the undead. The silence is total, and it is yours now." |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_CurseState_VampireCured_Scarred` | MessageBox. Once on cure; sets posture RestoredScarred. | God-voice | 20+141 / 40+500 |  | Title: "The Ancestors Answer"   Body: "The ash-prayer carries again. We hear you. But we heard the silence too, and it does not leave us, or you. Return -- scarred, and still ours." |  |
| _(no tone match)_ | `PDV_Msg_Dunmer_CurseState_WerewolfOnset` | MessageBox. Once on first transformation; sets posture Strained. | God-voice | 16+161 / 40+500 |  | Title: "Ritually Unclean"   Body: "The beast in you has no place in the ash or the Reclamations. The ancestors do not turn away, but they answer thinly now. Hircine offers nothing to fill the gap." |  |

## Shrine and privilege dialogue

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Dlog_Dunmer_GreyQuarterElder_Recognition` | Dialogue topic; Faithful or above. | Player-2nd | 77 / 120 |  | "I carry the ash-prayer in exile, as you do. Tell me what the quarter needs." |  |
| _(no tone match)_ | `PDV_Dlog_Dunmer_ReclamationsDevotee_Recognition` | Dialogue topic; Focused on any Reclamation. | Player-2nd | 55 / 120 |  | "The Good Daedra answer me. Speak of the Reclamations." |  |
| _(no tone match)_ | `PDV_Dlog_Dunmer_DunmerKin_Recognition` | Dialogue topic; Any tier. | Player-2nd | 68 / 120 |  | "We are far from Morrowind, kin. The ancestors still watch us both." |  |

## Tribunal Memory (Dunmer)

_3 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Dunmer_TribunalMemory_Vivec` | HUD corner notification. Curated trigger pool; cosmetic, no scoring; rare cadence. | Narrator | 60 / 80 |  | For a breath, you think of Vivec, and the city that is gone. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_TribunalMemory_SothaSil` | HUD corner notification. Curated trigger pool; cosmetic, no scoring; rare cadence. | Narrator | 61 / 80 |  | Sotha Sil's clockwork silence crosses your mind, then passes. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_TribunalMemory_Almalexia` | HUD corner notification. Curated trigger pool; cosmetic, no scoring; rare cadence. | Narrator | 62 / 80 |  | Almalexia's name surfaces, bright and bitter, and sinks again. |  |

## Other

_11 rows._

| Deity / tone | Slot ID | Trigger | Voice | Chars / cap | ! | Draft prose | Edit |
|---|---|---|---|---|---|---|---|
| _(no tone match)_ | `PDV_Notif_Dunmer_GoodDaedra_ObservantEntry` | HUD corner notification. One per save. | Narrator | 59 / 80 |  | The ash-prayer holds and the Good Daedra answer. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_GoodDaedra_FaithfulEntry` | HUD corner notification. One per save; suppress-if-offer-same-dawn. | Narrator | 52 / 80 |  | The Reclamations are steady in your exile. Faithful. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_Focus_DevotedEntry` | HUD corner notification. One per save; %s is the focus deity. | Narrator | 32 / 80 |  | %s knows your name now. Devoted. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_GoodDaedra_ObservantLapse` | HUD corner notification. One per direction per save. | Narrator | 50 / 80 |  | The Good Daedra answer more faintly now. Wavering. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_GoodDaedra_FaithfulLapse` | HUD corner notification. One per direction per save. | Narrator | 56 / 80 |  | The Reclamations are thinning toward silence. Observant. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_Focus_DevotedLapse` | HUD corner notification. One per save per focus loss. | Narrator | 55 / 80 |  | The bond with %s loosens. The Devoted bond is not held. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_Layer1_AshPrayerQuiet` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 79 / 80 |  | The ash-prayer goes out, and nothing comes back. The ancestors have gone quiet. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_Layer2_GoodDaedraThin` | HUD corner notification. One per lapse-band crossing. | Player-2nd | 70 / 80 |  | The Good Daedra feel far off. The dawn no longer warms the way it did. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_Layer3_FocusFading` | HUD corner notification. One per lapse-band crossing; %s is the focus deity. | Player-2nd | 60 / 80 |  | %s no longer waits at your thresholds. The bond is thinning. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_PortableShrine_Activate` | HUD corner notification. Per ash-prayer use; daily cap on the favor it feeds. | Player-2nd | 54 / 80 |  | You set the ash and pray. The portable shrine answers. |  |
| _(no tone match)_ | `PDV_Notif_Dunmer_PortableShrine_PrivateContext` | HUD corner notification. Player-owned home bonus context. | Player-2nd | 61 / 80 |  | Prayed within your own walls, the ash-prayer carries further. |  |
