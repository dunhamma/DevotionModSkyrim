# PDV Voice-Conformance -- Record-Bound Copy (for the ESP build)

Generated 2026-06-14 from the voice-pass drafting workflow. The SURVEY copy is already deployed in PDV__ManagerQuest.psc; THIS file holds the copy that becomes ESP RECORDS (commitment offers + conformed curse/champion/neglect/favor MESG/NOTI). First-wave record copy was consumed by the 2026-06-14 consolidated build pass through `references/authoring/PDV_ConsolidatedBuildPass_RecordWave.spec.json` and the Nord offer rows folded into `race-sheets/PDV_RaceContent_Manifest.md`. Keep the remaining per-race sections as source copy for later full conformance/promotions.

## Nord

### New commitment-offer records (God-voice, 500/280 + 40 title)

**Shor** -- title: Shor Calls You

> Your sword has stayed honest to the last blow, and Tsun has counted every fall. I am keeping a seat at my table for you. Take the name of Shor now and walk to my hall as one who is awaited, or hold to the broad road and prove it further.

accept: `Take the seat.`  decline: `Not yet.`

**Tsun** -- title: Tsun Weighs You

> I have watched you stand where lesser men would have run, against odds that should have ended you. The weighing is nearly done. Take the shield-thane's mark now and be known at the crossing, or come to Shor's bridge unweighed and let the trials decide.

accept: `Take the mark.`  decline: `Not yet.`

**Stuhn** -- title: Stuhn Sees the Open Hand

> You have spared the beaten and freed the bound when cruelty would have been the easier road. The open hand can be your banner. Carry the ransom-keeper's name now, or wait, and let me test the mercy in you further.

accept: `Carry the name.`  decline: `Not yet.`

**Akatosh** -- title: Akatosh Marks the Hour

> Day upon day, unbroken, you have kept faith while others let theirs fray. The line does not slip in your hands. Take the dragon's keeping now and let time hold what you hold, or measure your hours further before you choose.

accept: `Take the keeping.`  decline: `Not yet.`

**Mara** -- title: Mara Opens the Door

> You have made a hearth where there was none and held families that were breaking. The warmth you gave can be a door that is always open to you. Let me hold that hearth with you now, or stay welcome among the many a while longer.

accept: `Come home.`  decline: `Not yet.`

**Arkay** -- title: Arkay's Covenant

> You have given the dead their rites when the living would not, and turned back what should not walk. The cycle holds because you hold it. Walk now as keeper of the covenant, or come to the door again when you are ready.

accept: `Keep the cycle.`  decline: `Not yet.`

**Stendarr** -- title: Stendarr Stays the Hand

> You have stayed the killing blow again and again, where wrath was the easy road. Mercy chosen so often becomes a wall no blade passes lightly. Take my mercy as your armor now, or hold the question open and be tested further.

accept: `Take the mercy.`  decline: `Not yet.`

**Zenithar** -- title: Zenithar Names the Honest Hand

> Every weight you kept true, every trade you made fair, has been counted. The honest hand makes holy work. Carry the trade-god's name now and let your craft mean more than its making, or stay among the broad a while.

accept: `Carry the name.`  decline: `Not yet.`

**Julianos** -- title: Julianos Reads You

> You have studied with a patience few keep, until the arts answered as a friend answers. Wisdom in you is used, not stored. Carry the name of the schools now, or read further before you bind yourself to them.

accept: `Carry the name.`  decline: `Not yet.`

**Dibella** -- title: Dibella's Recognition

> You have made beauty where you walked and spoken the word that lands. What you give to the world, the world gives back. Carry my craft openly now, or stay among the loved a while longer.

accept: `Carry the craft.`  decline: `Not yet.`

**Talos** -- title: Talos Marks the Defier

> You would not let them silence me. Carry the old breath openly now, and Tamriel will hear Talos through you. Or hold the secret close and walk the broad road yet, until you are ready to be marked.

accept: `Carry the breath.`  decline: `Not yet.`

**Kynareth** -- title: Kynareth Calls the Traveler

> The road has been good to you because I am good to the road. The open sky already steadies your step. Carry my name now, traveler, and let the wind go with you, or hold to the broad reverence a while longer.

accept: `Carry the name.`  decline: `Not yet.`

**SHARED OfferResponse (PDV_Msg_Nord_OfferResponse_*) -- player-2nd, 40/30; reused across all Nord offers. Per-offer accept verbs above are flavor variants; these are the canonical shared three.** -- title: Shared Accept / Decline

> Accept (PDV_Msg_Nord_OfferResponse_Accept): "Accept the bond." | Not Yet (PDV_Msg_Nord_OfferResponse_NotYet): "Not yet." | Refuse (PDV_Msg_Nord_OfferResponse_Refuse): "Refuse the offer."

accept: `Accept the bond.`  decline: `Not yet. / Refuse the offer.`

### Conformed surface copy

- **Curse-state: PDV_Msg_Nord_CurseState_VampireOnset (MessageBox body 500/280 + 40 title)** [God-voice]: Title: "Sovngarde Closes" Body: "Molag Bal's shadow has fallen across you. Sovngarde will not name you while you carry his thirst. Cure the curse, and even then the scar remains."
  - _note:_ RECONCILE: the live .psc VampireSuppressed fallback is the terse 'Sovngarde is closed while the thirst remains. Cure the curse to reopen the road.' This is the fuller manifest god-voice body that the onset MessageBox should carry. Keep the terse line ONLY as the Survey base variant; the one-time onset MESG uses this fuller body.
- **Curse-state: PDV_Msg_Nord_CurseState_VampireCured (MessageBox body 500/280 + 40 title)** [God-voice]: Title: "The Door Stands Ajar" Body: "The thirst is gone. The bridge is open again. But Tsun has seen what walked into the dark, and that is not forgotten."
  - _note:_ PORTED unchanged from manifest 10.9; ASCII-clean. Pairs with the cured-vampire-scar Survey component above (which is the persistent readout after this one-time message fires).
- **Curse-state: PDV_Msg_Nord_CurseState_WerewolfOnset (MessageBox body 500/280 + 40 title)** [God-voice]: Title: "Hircine's Pull" Body: "The beast is in the Companions' gift, but it stands against Shor's hall. Your seat on the bridge weakens while the hunt holds."
  - _note:_ PORTED from manifest 10.9; pairs with the HircineEdge Survey base variant. Confirms the Hircine-edge branch is a real, surfaced state and not dead code.
- **Curse-state: PDV_Msg_Nord_CurseState_WerewolfCured (MessageBox body 500/280 + 40 title)** [God-voice]: Title: "The Bridge Holds Again" Body: "The hunt is set down. Hircine's hold is broken, and your seat on the bridge holds firm once more. Shor's hall will name you when the day comes. Tsun marks that you ran with the beast, and does not forget."
  - _note:_ PORTED from manifest 10.9; ASCII-clean.
- **Neglect texture: shared general fallback at the neglect drop site (replaces the bare Debug.Notification added 2026-06-13)** [Player-2nd]: The ancestors are quiet.
  - _note:_ PORT of PDV_Notif_Nord_General_AncestorsQuiet; offered as the generic Nord neglect fallback so the drop-site notification carries race voice instead of a system string. Per-deity neglect rows in 10.5 remain the specific surfacings.
- **Favor-Noted readout (player MCM favor line + Survey component, when a Nord lane is suppressed by vampire curse)** [Player-2nd]: Favor is silent while the thirst holds you.
  - _note:_ REWORD of the live GetPlayerMcmFavorLine fallback 'Suppressed by vampire curse' (dev-token phrasing). Same meaning, player voice.
- **Champion ambient: PDV_Notif_Nord_Kyne_ChampionAmbient_Storm (HUD notification 80/60)** [Player-2nd]: The wind is blowing your way.
  - _note:_ PORTED unchanged from manifest 10.4; ASCII-clean, already player-2nd. Listed to confirm the champion-ambient surface conforms (no standing token needed; it is texture, not a status block).
- **Champion entry: PDV_Msg_Nord_Kyne_ChampionEntry (MessageBox 500/280 + 40 title)** [God-voice]: Title: "Kyne's Recognition" Body: "You sleep where the storm sleeps. You walk where the wind walks. Kyne has named her hunter."
  - _note:_ PORTED from manifest 10.4 as the god-voice model for the new non-Kyne offer bodies; included here because champion-entry shares the god-voice register with the offers and anchors Kyne's voice for review.

## Orc

### Conformed surface copy

- **Curse-state transition: PDV_Msg_Orc_CurseState_WerewolfOnset (MessageBox; manifest 11.9). Title kept: "The Beast Tested".** [God-voice (Malacath)]: The wolf is in you. I do not turn away from it. But the beast is judged by my code as the smith is judged: is it strong, does it endure, does it serve the kin or break them? Prove the wolf.
  - _note:_ PORT, near-verbatim from manifest. Only fix: manifest reads "judged by my code as the smith is:" -- the trailing colon reads awkward; reworded to "as the smith is judged:". No standing token, no dev language. Within 280 target.
- **Curse-state transition: PDV_Msg_Orc_CurseState_WerewolfCured (MessageBox; manifest 11.9). Title kept: "The Wolf Set Aside".** [God-voice (Malacath)]: You have put the beast down. It was never outside my code; it was a thing to master, and you mastered it by ending it. You are an Orc still, and still tested. The kin will weigh the wolf longer than I will.
  - _note:_ PORT verbatim -- already conformant (god-voice, no standing token, no dev language). Listed so the implementer confirms it ships unchanged alongside the reworded onset.
- **Curse-state transition: PDV_Msg_Orc_CurseState_VampireOnset (MessageBox; manifest 11.9). Title kept: "Outside the Test".** [God-voice (Malacath)]: You feed on the living now. That is dependency, and dependency is the thing my code exists to refuse. You stand outside the test. Cure this, or I have nothing to witness.
  - _note:_ PORT verbatim -- already conformant. Pairs with the Survey vampire component line ("The thirst sets you outside the test...").
- **Curse-state transition: PDV_Msg_Orc_CurseState_VampireCured (MessageBox; manifest 11.9). Title kept: "Back Within Reach".** [God-voice (Malacath)]: The thirst is gone. You are a living Orc again, and a living Orc can be tested. Begin. The kin will remember the lapse longer than the code does.
  - _note:_ PORT verbatim -- already conformant.
- **Neglect texture: PDV_Notif_Orc_Malacath_NeglectTexture_Forge (HUD notification; manifest 11.5)** [Player-2nd]: The forge is only iron and heat now. The work has stopped being prayer.
  - _note:_ PORT verbatim -- conformant player-2nd, no dev language, no standing token.
- **Neglect texture: PDV_Notif_Orc_Malacath_NeglectTexture_CityQuality (HUD notification; manifest 11.5; City mode)** [Player-2nd]: The work is just work now. Nothing of the code is left in it.
  - _note:_ PORT with a trim: manifest reads "There is nothing of the code left in it." -- tightened to "Nothing of the code is left in it." to sit under the 60 target. Meaning unchanged.
- **Neglect texture: PDV_Notif_Orc_Malacath_NeglectTexture_LegionErasure (HUD notification; manifest 11.5; LegionExile mode)** [Player-2nd]: Folded away to fit in, you have left Malacath nothing to watch.
  - _note:_ PORT verbatim -- conformant.
- **Neglect texture: PDV_Notif_Orc_Malacath_NeglectTexture_OathBroken (HUD notification; manifest 11.5)** [Player-2nd]: An oath set down is an oath Malacath saw you set down.
  - _note:_ PORT verbatim -- conformant. The repetition is deliberate (the witness motif), not a counter leak.
- **Tier-lapse notifications: PDV_Notif_Orc_Malacath_ObservantLapse / FaithfulLapse / DevotedLapse (HUD; manifest 11.3). These embed standing WORDS, not a token.** [Narrator (per matrix; see open_questions re: god-voice alternative)]: ObservantLapse: "Malacath's eye has drifted from you. Standing: Distant." | FaithfulLapse: "The code shows thin to Malacath now. Standing: Observant." | DevotedLapse: "Malacath no longer holds you as Devoted."
  - _note:_ CONFORM only: manifest used "Wavering"/"Observant"/"no longer holds the Devoted witness" as bare labels. Re-stated on the public bands with the "Standing: <band>." frame so the lapse destination matches the Survey vocabulary. "Wavering" is not one of the four public bands -- mapped to the band the lapse lands in (Observant->Distant, Faithful->Observant, Devoted->loss-of-Devoted). Confirm the band each lapse actually transitions TO before shipping.
- **Favor (Noted), representative: PDV_Notif_Orc_FavorNoted_City_Dignity (HUD; manifest 11.7)** [Player-2nd]: Met with scorn, you did not bend. The code held.
  - _note:_ PORT verbatim -- conformant. The full 11.7 Noted set (13 rows) is already player-2nd with no standing token or dev language; they port as-is. Sampled one to confirm voice; no conformance edits needed across the Noted favor block.
- **Favor (Marked): PDV_Msg_Orc_FavorMarked_Stronghold_BloodKinCrisis (MessageBox; manifest 11.7). Title kept: "Blood-Kin".** [God-voice (Malacath)]: You answered the stronghold's worst hour. The kin will not forget it, and neither will I.
  - _note:_ PORT verbatim -- conformant god-voice. Paired Marked moment PDV_Msg_Orc_FavorMarked_LegionExile_ExileBurden ("The Burden Returned") is likewise already conformant; no edits.
- **Champion entry: PDV_Msg_Orc_Malacath_ChampionEntry_City (MessageBox; manifest 11.4). Title kept: "Witnessed Alone".** [God-voice (Malacath)]: No chief confirmed you. No shaman named you. No stronghold held the code for you. I did. You held it where nothing made you, and that is the harder thing.
  - _note:_ PORT verbatim -- the three Champion entries (Stronghold "The Forge Sings", City "Witnessed Alone", Legion/Exile "The Burden Carried") are all conformant god-voice with no standing token or dev language. Sampled the City one; ship all three as drafted.
- **Champion ambient: PDV_Notif_Orc_Malacath_ChampionAmbient_PrivateOath (HUD; manifest 11.4)** [Player-2nd]: Scorned, and unbroken. Malacath's witness holds.
  - _note:_ PORT verbatim -- conformant player-2nd. ForgeWork and StrongholdAccept ambients likewise conformant; no edits.

## Dunmer

### Conformed surface copy

- **Curse-state god-voice / ancestor-silence under vampire (PDV_Msg_Dunmer_AncestorPosture_Silent, posture enum Silent = 2, active vampirism; fires on transition). The brief asks the ancestors to speak directly rather than narrate.** [God-voice (the ancestors / ash speaking to the player)]: You set the ash, and we do not come. We have not turned from you -- you have turned into something we cannot reach. The silence is not punishment. It is what you are now, until you are not.
  - _note:_ GOD-VOICE recast of manifest 12.2 PDV_Msg_Dunmer_AncestorPosture_Silent (narrator: "The ash-prayer meets no answer. The ancestors do not speak to the undead. The silence is not punishment; it is what you have become."). Budget 240/180. Keeps the locked "silence, not punishment" beat.
- **Curse-state god-voice / strained under werewolf or unclean rite (PDV_Msg_Dunmer_AncestorPosture_Strained, posture enum Strained = 1; fires on transition).** [God-voice (the ancestors speaking)]: We still hear you, but faintly. Something rides with you the ancestors do not trust -- the beast, or a rite left unclean. Set it right, and the ash will carry true again.
  - _note:_ GOD-VOICE recast of manifest 12.2 PDV_Msg_Dunmer_AncestorPosture_Strained (narrator). Budget 240/180.
- **Curse-state god-voice / restored after cure (PDV_Msg_Dunmer_AncestorPosture_RestoredScarred, posture enum 3; post-cure return).** [God-voice (the ancestors speaking)]: You set the ash, and we answer. We remember the quiet that was between us -- carry that with you. The prayer is whole again, but it is not unmarked, and neither are you.
  - _note:_ GOD-VOICE recast of manifest 12.2 PDV_Msg_Dunmer_AncestorPosture_RestoredScarred (narrator). Budget 240/180. NOTE: manifest assigns this surface NARRATOR; brief asks god-voice for the curse-state line. Recast offered; see open_questions. Posture-Normal readout stays narrator and is not recast here.
- **Neglect texture, Layer 1 ancestor silence (PDV_Notif_Dunmer_Layer1_AshPrayerQuiet; fires first day of a meaningful lapse).** [Player-2nd]: The ash-prayer goes out, and nothing comes back. The ancestors have gone quiet.
  - _note:_ PORT as-is from manifest 12.7 -- already conforms (player-2nd, no banned tokens, ASCII-clean). Budget 80/60. Included to confirm no change needed; do not re-voice.
- **Neglect texture, Layer 2 Good Daedra thinning (PDV_Notif_Dunmer_Layer2_GoodDaedraThin).** [Player-2nd]: The Good Daedra feel far off. The dawn no longer warms the way it did.
  - _note:_ PORT as-is from manifest 12.7 -- already conforms. Budget 80/60. No change needed.
- **Neglect texture, Layer 3 focus fading (PDV_Notif_Dunmer_Layer3_FocusFading; %s is the focus deity name).** [Player-2nd]: %s no longer waits at your thresholds. The bond is thinning.
  - _note:_ PORT as-is from manifest 12.7 -- already conforms. Budget 80/60. %s binds focus deity.
- **Favor-Noted, shared ash-prayer (PDV_Notif_Dunmer_FavorNoted_Shared_AshPrayer).** [Player-2nd]: The ash-prayer carries, even here. The ancestors are near.
  - _note:_ PORT as-is from manifest 12.9 -- already conforms (player-2nd per agreed voice for favor-Noted). Representative of the shared favor lane; the full Noted favor pool (Shared/Azura/Boethiah/Mephala, ~17 lines) is already in-voice in the manifest and needs only a port, no re-voicing.
- **Champion entry, Azura (PDV_Msg_Dunmer_Azura_ChampionEntry; one-time on first Azura Devoted).** [God-voice]: Title: Azura at the Threshold | Body: I marked your people once, at the worst crossing they ever made. I mark you now. Stand at the thresholds, and you will not stand at them blind.
  - _note:_ PORT as-is from manifest 12.5 -- already god-voice, ASCII-clean, no banned tokens. Budget 500/280. Boethiah and Mephala champion-entry bodies in 12.5 likewise conform and only need a port; ambient champion notifs are player-2nd per spec and also conform.

## Altmer

### Conformed surface copy

- **Survey base sentence prefix (GetAltmerSurveyText opening line)** [Narrator]: REPLACE the former Auri-El-foundation opening and old standing prefix with the alignment-path base variants above. The Auri-El-foundation idea is preserved by the always-active Layer-1 framing; if the author wants to retain an Auri-El anchor in the base, prepend 'Auri-El is the foundation underneath. ' to the chosen path variant, but the path line is the primary identity per the locked axis decision.
  - _note:_ Conforms the standing token (use GetPublicTierBand -> Distant/Observant/Faithful/Devoted, embedded as 'Standing: <band>.') and removes the old standing prefix plus the internal Seeker/Champion words. The live function now uses the public band path after the 2026-06-14 consolidated pass.
- **Curse-state onset -- Vampire (PDV_Msg_Altmer_CurseState_VampireOnset, 13.10)** [God-voice (Auri-El)]: Title: Auri-El Closes  Body: You flee the sun now, and the sun is the god of return. There is no path back from where you stand. The records will not hold your name. This is not a punishment. It is what shrinking from the dawn has always meant.
  - _note:_ PORT as-is from manifest 13.10; already clean god-voice, ASCII-safe, no dev language. Included so the curse SURVEY component line above stays consistent in tone with the onset box the player already saw.
- **Curse-state onset -- Werewolf (PDV_Msg_Altmer_CurseState_WerewolfHardHalt, 13.10)** [God-voice (Auri-El)]: Title: The Project Inverted  Body: The whole of Altmer faith is to become spirit again. You have become a beast. There is no doctrine for this, no heresy small enough to hold it, no path in any direction. Devotion stops here.
  - _note:_ PORT as-is from manifest 13.10; clean. Confirms the 'Werewolf halt' survey component line ('The beast has stopped your devotion...') is consistent with the onset box.
- **Neglect texture (PDV_Notif_Altmer_NeglectTexture_*, 13.5)** [Player-2nd]: OrthodoxyDrift: Your acts no longer match your stated theology. You feel undefined.  ||  CultivationFading: You have stopped cultivating yourself. The discipline that set you apart fades.  ||  AuriElDistant: The dawn is only the dawn now. The return feels far away.
  - _note:_ PORT as-is from manifest 13.5; all three are conforming player-2nd, ASCII-safe, no dev language. No change needed -- listed for completeness since neglect is a divergent surface.
- **Contextual favor -- Noted recap routing (manifest 13.13 FavorNoted rows)** [Player-2nd]: Use the manifest FavorNoted prose at the toast site, e.g. DivineBody/DawnObservance: 'You greet the dawn unforced. The return is honored, not compelled.' and ThalmorOrthodox/Enforcement: 'Heresy named and answered. The orthodoxy marks the hand that enforces.'
  - _note:_ RECOMMENDATION: the favor-FAMILY label (GetContextualFavorFamilyLabel) returns dev taxonomy -- 'Orthodox costly enforcement', 'Dawn steadiness', and a fallback 'Unknown' -- and must NOT reach the player. Restrict that label to dev/MCM/trace and drop the survey 'Last favor: <label>.' line; let the existing FavorNoted notifications (already clean, player-2nd) carry the favor moment. The survey's optional last-favor recap, if kept, should use the neutral component line above ('A recent act of yours was noted on your path.').
- **Lorkhan first-interpretation teaching box (PDV_Msg_Altmer_LorkhanInterp_FirstTime, 13.11)** [Narrator]: Title: The Old Dissonance  Body: Lorkhan made the mortal world, the trap your ancestors fell into. Acts that honor, strengthen, or celebrate his creation press against your faith -- not because a god disapproves, but because you have touched the thing that broke your people. You will feel this again.
  - _note:_ PORT as-is from manifest 13.11; clean. This is the narrator teaching that the survey 'Lorkhan pressure' component line ('You have felt the old dissonance more than once...') echoes -- the survey line deliberately reuses 'the old dissonance' phrasing so the player connects the two.
- **Champion entry -- Auri-El (PDV_Msg_Altmer_AuriEl_ChampionEntry, 13.4)** [God-voice (Auri-El)]: Title: Auri-El's Dawn  Body: You held the path through a world built to make you forget it. The return is not a doctrine to you; it is a daily practice. Keep walking toward the dawn. I am the dawn.
  - _note:_ PORT as-is from manifest 13.4; clean god-voice, ASCII-safe. No change. Listed because champion-entry is a divergent god-voice surface in the voice spec.

## Khajiit

### Conformed surface copy

- **Prisma overlay toast title -- lunar posture shift (PDV_PrismaToast lunar; title arg of SendPrismaShiftToast at line 3640, sourced from GetKhajiitLunarPostureLabelAt)** [Symbol-led, minimal]: Strained -> Lattice strained | Corrupted -> Lattice thinned | ShadowDrift -> Drifting to shadow | Normal -> Lattice clear
  - _note:_ RECONCILES the PascalCase leak: GetKhajiitLunarPostureLabelAt returns raw enum tokens ("Strained", "Corrupted", "ShadowDrift", "Normal") which are passed straight into the toast TITLE. "ShadowDrift" especially reads as a dev token. These are player-facing phrase replacements for the title only; the existing GetKhajiitLunarPostureReadout body text is already clean and stays as the toast body. The enum-token function can keep returning raw tokens for code/MCM/logging -- add a separate display-label path for the toast title.
- **Curse-state VampireOnset (PDV_Msg_Khajiit_CurseState_VampireOnset)** [God-voice (Azurah)]: Title: "The Lattice Corrupted" Body: "The thirst has taken you, little moon. The Lattice does not cast you out -- the moons do not disown their own -- but the caravans will fear you, and rightly. I will not look away. Few of the others can say the same."
  - _note:_ PORT as-is from manifest 14.11. Already conforming god-voice, ASCII-clean, no public-band token needed (curse state, not standing). No change.
- **Curse-state ShadowDriftEntry (PDV_Msg_Khajiit_CurseState_ShadowDriftEntry)** [Narrator (voice deviation -- no god present to speak the Lattice loosening)]: Title: "The Shadow Between Stars" Body: "You have lived too long in the shadow -- night-only, predatory, drawn to the dark between the moons. The Lattice loosens its hold. Khenarthi's road and Azurah's twilight both feel far away now."
  - _note:_ PORT as-is from manifest 14.11. The narrator-voice deviation is documented and correct (Lattice has no voice of its own). No change.
- **Neglect texture -- SubstrateThinning (PDV_Notif_Khajiit_NeglectTexture_SubstrateThinning)** [Player-2nd]: Too long indoors and walled in. The Lattice holds you more thinly.
  - _note:_ PORT as-is from manifest 14.7. Player-2nd, ASCII-clean, no standing token. No change.
- **Neglect texture -- PatronFading (PDV_Notif_Khajiit_NeglectTexture_PatronFading)** [Player-2nd]: <deity> sends less than you had grown used to. The lean is fading.
  - _note:_ PORT from manifest 14.7; %s -> <deity> token for the focus deity. No change to prose.
- **Neglect texture -- CaravanForgotten (PDV_Notif_Khajiit_NeglectTexture_CaravanForgotten)** [Player-2nd]: The caravans do not know your face. You have not been where they go.
  - _note:_ PORT as-is from manifest 14.7. No change.
- **Tier-up / band lapse notifications (PDV_Notif_Khajiit_Lunar_* entries and lapses, manifest 14.4)** [Player-2nd (matrix); manifest authored Narrator -- see open question]: ObservantEntry: "The moons have noticed how you move. Observant." | FaithfulEntry: "The Lattice holds you steady now. Faithful." | ObservantLapse: "The moons mark you less surely now. Distant." | FaithfulLapse: "The Lattice holds you more thinly. Observant."
  - _note:_ PORT from manifest 14.4 with ONE band-token conformance fix: original ObservantLapse ended "Wavering." which is NOT a public band (only Distant/Observant/Faithful/Devoted are allowed). Proposed "Distant." to name the landed band. Entry lines and the FaithfulLapse landing already use clean band words. Author should confirm the lapse trailing word names where you LAND -- flagged in open_questions.
- **Favor Noted -- Substrate/Road (PDV_Notif_Khajiit_FavorNoted_Substrate_RoadLife)** [Player-2nd]: The road carries you kindly tonight. The moons are near.
  - _note:_ PORT as-is from manifest 14.9. Player-2nd, clean. No change.
- **Favor Noted -- Caravan kinship (PDV_Notif_Khajiit_FavorNoted_Substrate_CaravanKinship)** [Player-2nd]: The caravan knows you and is glad of it. Kinship counts.
  - _note:_ PORT as-is from manifest 14.9. No change.
- **Favor Marked -- Baan Dar Reversal (PDV_Msg_Khajiit_FavorMarked_BaanDar_Reversal)** [God-voice (Baan Dar)]: Title: "Pariah's Fortune" Body: "That was not survivable, and you survived it. The god of pariahs wrote you a way out, because once, someone should have done the same for him."
  - _note:_ PORT as-is from manifest 14.9. God-voice Marked favor, clean. No change.
- **Champion entry -- Khenarthi (PDV_Msg_Khajiit_Khenarthi_ChampionEntry)** [God-voice (Khenarthi)]: Title: "Khenarthi's Road" Body: "The wind has carried you so long it has learned your name. Walk, and the road walks with you. The open sky was always your temple roof."
  - _note:_ PORT as-is from manifest 14.6. God-voice champion entry; recognition delivered, not an offer. No standing token. No change.
- **Champion entry -- Azurah (PDV_Msg_Khajiit_Azurah_ChampionEntry)** [God-voice (Azurah)]: Title: "Azurah's Twilight" Body: "I shaped the Khajiit at the first dusk. I have watched you stand at every threshold since. You feel the world's hinges now. Cross well."
  - _note:_ PORT as-is from manifest 14.6. No change.
- **Champion ambient -- Khenarthi road (PDV_Notif_Khajiit_Khenarthi_ChampionAmbient_Road)** [Player-2nd]: The road runs easy under you. Khenarthi's wind is at your back.
  - _note:_ PORT as-is from manifest 14.6. Player-2nd ambient, clean. No change.
- **Road-home acknowledgment (PDV_Notif_Khajiit_RoadHome_*, manifest 14.10 -- backs the survey 'road-home cadence' component line)** [Player-2nd]: Designate: "You have made this a road home. The circuit has an anchor here." | Return: "Back at a road home, the circuit holding. The Lattice steadies." | MissedCadence: "You have not walked the circuit in too long. The anchors grow cold."
  - _note:_ PORT as-is from manifest 14.10. Player-2nd, clean. No change; included for traceability since the survey component line 'The road-home cadence has begun to carry weight' is driven by the same RoadHomeCount state.

## Imperial

### Conformed surface copy

- **Curse-state transition -- VampireOnset (15.10, MessageBox, title "The Civic Faith Halts")** [Narrator (agreed deviation -- NOT god-voice; see note)]: Title: "The Civic Faith Halts" Body: "You are undead now, and the Nine Divines are a religion of the living community. The civic faith does not bend to accommodate this. It stops. The Concordat no longer touches your soul, only your safety."
  - _note:_ PORT as-is from manifest 15.10. The brief flags 15.10 curse-state as intentionally NARRATOR, not a divergence -- institutional voice, no single god speaks. Already ASCII-clean and on-spec; no conform needed. Listed here so the reviewer sees the curse SURFACE copy alongside the curse-posture SUFFIX above (the suffix is a separate Survey component, not this MessageBox).
- **Curse-state transition -- VampireCured (15.10, title "Re-Entry From a Lower Floor")** [Narrator (agreed deviation)]: Title: "Re-Entry From a Lower Floor" Body: "The undeath is lifted. The Nine Divines are open to you again -- but the civic faith resumes from a lowered floor, not your old standing. The community religion remembers the absence."
  - _note:_ PORT as-is. On-spec narrator; ASCII-clean. The Survey curse-posture "scarred" suffix above pairs with this state.
- **Curse-state transition -- WerewolfOnset (15.10, title "Homeless Within the Faith")** [Narrator (agreed deviation)]: Title: "Homeless Within the Faith" Body: "The beast is in you, and the Nine Divines have no place for it. Your devotion continues, weaker, its civic-facing parts thinned. Hircine offers an Imperial nothing. You are isolated within your own faith."
  - _note:_ PORT as-is. Pairs with the Survey "strained" curse-posture suffix.
- **Curse-state transition -- WerewolfCured (15.10, title "Homecoming Within the Faith")** [Narrator (agreed deviation)]: Title: "Homecoming Within the Faith" Body: "The beast is set aside. The Nine Divines make room again, and the civic-facing devotion thickens back toward what it was. The community religion notes the absence, as it always does, and resumes from a lowered floor."
  - _note:_ PORT as-is.
- **Neglect texture -- Talos (15.6, PDV_Notif_Imperial_Talos_NeglectTexture)** [Player-2nd]: The hidden shrines are cold stone now. The risk meant something once.
  - _note:_ PORT as-is from manifest 15.6 -- already player-2nd and ASCII-clean. Included because it is the player-2nd counterpart to the Survey Talos components above; no conform needed.
- **Neglect texture -- CivicScaffoldingHollow (15.6, general lapse)** [Player-2nd]: The Divines feel like institutions now, not presences.
  - _note:_ PORT as-is. On-spec; ASCII-clean.
- **Contextual favor (Noted) -- TalosPressure (15.9, PDV_Notif_Imperial_FavorNoted_TalosPressure)** [Player-2nd]: A faith kept hidden, at real cost. Talos hears it.
  - _note:_ PORT as-is. On-spec player-2nd favor-Noted; pairs with the Survey PrivateTalosPressure component.
- **Contextual favor (Marked) -- TalosDefiance (15.9, god-voice MessageBox)** [God-voice]: Title: "Talos Notes the Risk" Body: "You stood between the Thalmor and one of mine, in the Empire that outlawed me. That is worship. Carry the old breath a little longer."
  - _note:_ PORT as-is. On-spec god-voice; ASCII-clean. Confirms the god-voice register the Talos Survey tilt fragments observe FROM the outside (narrator), so the two surfaces stay distinct.
- **Champion entry -- Talos (15.5, PDV_Msg_Imperial_Talos_ChampionEntry)** [God-voice]: Title: "Faith Against the Law" Body: "You kept me when keeping me was a crime -- not in a free province, but in the Empire that signed me away. That is the faith I remember. Speak, and the old breath answers."
  - _note:_ PORT as-is from manifest 15.5. On-spec god-voice champion-entry; ASCII-clean. Listed as the god-voice anchor the Survey/neglect Talos copy must stay subordinate to (the deity speaks here; the Survey only observes).

## Redguard

### Conformed surface copy

- **Survey base -- standing token conformance (all three sect lines, 16.8 / live GetRedguardSurveySectText)** [Narrator]: Embed Standing as one of: Distant / Observant / Faithful / Devoted. Replace the live GetCurrentStandingLabel() feed (Seeker/Devoted/Champion/Unproven) with GetPublicTierBand() so the survey reads e.g. "Standing: Faithful." rather than "Standing: Seeker."
  - _note:_ PORT note, not new prose. The manifest 16.8 rows already say "Standing: %s"; the conformance is purely the value bound to %s. Live code currently passes the internal-vocabulary label -- this is the one substantive bug in the Redguard survey. GetPublicTierBand already exists in the same script (line 5002).
- **Curse-state: Vampire onset (PDV_Msg_Redguard_CurseState_VampireOnset, 16.11)** [God-voice (Tu'whacca)]: Title: Outside the Cycle Body: You are undead now, and undeath is a soul that has stepped out of the cycle I guide. The Far Shores cannot receive you while the curse holds, so devotion across all three sects falls quiet. Cure this, and return to me first.
  - _note:_ PORT of manifest 16.11 verbatim. Already conforming: god-voice, no dev language, no standing token to fix. Listed only to confirm no change needed.
- **Curse-state: Vampire cured / Tu'whacca re-entry (PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry, 16.11)** [God-voice (Tu'whacca)]: Title: Right Re-Entry Body: The curse is lifted. Come back through me before any other god -- proper mortality, ancestor order, the right return to the cycle. When that is done the Far Shores are open, and your sect may have you again.
  - _note:_ PORT of manifest 16.11 verbatim. Conforming as-is.
- **Curse-state: Werewolf onset (PDV_Msg_Redguard_CurseState_WerewolfOnset, 16.11)** [God-voice (the ancestors / Yokudan gods)]: Title: Strained, Not Severed Body: The beast is in you. The Yokudan gods and your sect stay within reach, but strained -- Hircine is an intrusion, not a home. The ancestors do not turn away. They only watch the closer.
  - _note:_ PORT of manifest 16.11; trimmed "watch more closely" to "watch the closer" to match the survey werewolf component line's phrasing for cross-surface consistency. Voice unchanged.
- **Curse-state: Werewolf cured (PDV_Msg_Redguard_CurseState_WerewolfCured, 16.11)** [God-voice (the ancestors / Yokudan gods)]: Title: The Strain Lifts Body: The beast is set down. The strain eases, and the Yokudan gods and your sect come back into full reach. Hircine's intrusion is ended. The ancestors, who only watched the closer, ease their gaze. Wholly theirs again.
  - _note:_ PORT of manifest 16.11. Same "watch the closer" alignment as onset.
- **Neglect texture: Ancestor layer (PDV_Notif_Redguard_AncestorLayer_NeglectTexture, 16.6)** [Player-2nd]: You have handled the dead without care, and the Far Shores feel further off.
  - _note:_ HUMANIZED rewrite of "You have handled the dead carelessly. The Far Shores seem further away." One flowing sentence; warmer cadence; same beat. Within 80-char budget.
- **Neglect texture: Crown (PDV_Notif_Redguard_Crown_NeglectTexture, 16.6)** [Player-2nd]: You have let Yokudan practice slide toward Divines convenience, and the old orthodoxy thins.
  - _note:_ HUMANIZED rewrite of "Yokudan practice has slid into Divines convenience. The orthodoxy thins." Reframed to second-person agency; reads as quieting, not a system report. 92 chars -- over the 80 hard budget; see open_questions for the tighter alt.
- **Neglect texture: Forebear (PDV_Notif_Redguard_Forebear_NeglectTexture, 16.6)** [Player-2nd]: You have taken only the easy road of late. HoonDing pays the safe passage no mind.
  - _note:_ HUMANIZED rewrite of "You have taken only the easy road. HoonDing does not notice the safe." 81 chars -- 1 over hard; tighter alt in open_questions.
- **Neglect texture: Ash'abah (PDV_Notif_Redguard_AshAbah_NeglectTexture, 16.6)** [Player-2nd]: The undead duty goes unmet, and the burden is only weight now, unhonored.
  - _note:_ HUMANIZED rewrite of "The undead duty goes unmet. The burden is just weight now, unhonored." One sentence; "just" -> "only" for tone. 72 chars, within budget.
- **Contextual favor (Marked): Forebear make-way (PDV_Msg_Redguard_FavorMarked_Forebear_MakeWay, 16.9)** [God-voice (HoonDing)]: Title: The Way Forced Body: Severely outmatched, and still you made a way through. That is my whole nature. The god who held the Dominion back is in your step.
  - _note:_ PORT of manifest 16.9 verbatim. God-voice, conforming. Representative of the favor surface; no fix needed.
- **Far Shores token activate (PDV_Notif_Redguard_FarShoresToken_Activate, 16.10)** [Player-2nd]: You tend the Far Shores token and speak to Tu'whacca.
  - _note:_ PORT of manifest 16.10 verbatim. Conforming. Note this is the activation notice; the survey component line (FarShoresToken > 0) is a separate readout I drafted new.
- **Champion entry: Crown (PDV_Msg_Redguard_ChampionEntry_Crown, 16.5)** [God-voice (the ancestors)]: Title: The Inheritance Kept Body: You carried the old way into exile and did not let it thin -- the blade, the bearing, the rites, all intact. The ancestors who died holding Hammerfell see their orthodoxy alive in you.
  - _note:_ PORT of manifest 16.5 verbatim. The live code currently shows a generic narrator fallback ("The Crown way has become more than memory..."); the rich god-voice body is the manifest-authored record this should bind to.

## Bosmer

### Conformed surface copy

- **Survey -- live favor clause (DEAD CODE: recommend deleting)** [Narrator]: (remove) A recent path favor is still remembered.
  - _note:_ Live GetBosmerSurveyText appends this when StorageUtil PDV.Bosmer.Favor.LastFamily > 0, but that key is NEVER written anywhere in PDV__ManagerQuest.psc (the favor recorder writes .SignalCount, .LastSignalTime, and per-key .Count, not .LastFamily). So the clause is unreachable. Recommend dropping the branch entirely rather than rewording it. Flagged in open_questions. If a 'recent favor' surface IS wanted, drive it off the real PDV.Bosmer.Favor.SignalCount / per-key .Count instead and re-draft.
- **CurseState VampireOnset (PDV_Msg_Bosmer_CurseState_VampireOnset)** [God-voice]: Title: "The Covenant and the Undead"  Body: "You are undead now, and the living covenant does not reach the unliving. On the Old Contract the Pact breaks at once; on the other paths the bond strains to a thread but holds. I am the Now, and you have stepped outside it."
  - _note:_ Ported from manifest 17.11 row; conformed to ASCII straight quotes and tightened the god-voice 'Y'ffre is the Now' to first-person 'I am the Now' since the deity is speaking. One body covers all four paths per the manifest's per-path-in-one-body note. Replaces any generic curse fallback for Bosmer.
- **CurseState VampireCured (PDV_Msg_Bosmer_CurseState_VampireCured)** [God-voice]: Title: "Back Within the Now"  Body: "The undeath is lifted. You stand within the living world again, and your path is open -- though the Old Contract, broken this way, must be retaken like any lapse."
  - _note:_ Ported from manifest 17.11. ASCII double-hyphen for the dash; straight quotes. No wording change needed beyond punctuation conform.
- **CurseState WerewolfOnset (PDV_Msg_Bosmer_CurseState_WerewolfOnset)** [God-voice]: Title: "The Hunt Without Sanction"  Body: "The beast is in you. It echoes the Wild Hunt, so our theology can read it -- but it is not my sanction. On the Old Contract this is a serious violation; on the other paths, contested strain. The shape is understood. It is not approved."
  - _note:_ Ported from manifest 17.11; ASCII-conformed and shifted to first-person god-voice ('not my sanction'). Swapped 'Bosmer theology' to 'our theology' to keep the deity speaking; 'intelligible' downgraded to 'understood' to kill the faintly clinical register.
- **CurseState WerewolfCured (PDV_Msg_Bosmer_CurseState_WerewolfCured)** [God-voice]: Title: "The Hunt Set Down"  Body: "The beast is set down. The unsanctioned shape leaves you, and you stand within my Now again. On the Old Contract the violation must be retaken like any lapse; on the other paths the strain simply eases. The Now holds."
  - _note:_ Ported from manifest 17.11; ASCII-conformed, first-person ('my Now').
- **Neglect texture -- Old Contract (PDV_Notif_Bosmer_OldContract_NeglectTexture)** [Player-2nd]: The Pact is slipping, and you can feel the reckoning coming.
  - _note:_ Ported verbatim from manifest 17.8 -- already clean player-2nd, ASCII-safe, no dev language. No change.
- **Neglect texture -- Living Story (PDV_Notif_Bosmer_LivingStory_NeglectTexture)** [Player-2nd]: The telling dries up. You have stopped carrying the Story.
  - _note:_ Manifest 17.8 reads 'The oral tradition dries up.' -- 'oral tradition' is faintly academic for player-2nd; softened to 'The telling' to match the in-game 'Story' diction. Optional; the manifest line is acceptable if the author prefers verbatim.
- **Neglect texture -- Exchange (PDV_Notif_Bosmer_Exchange_NeglectTexture)** [Player-2nd]: Debts go unpaid and unnoticed. The world's balance ignores you.
  - _note:_ Ported verbatim from manifest 17.8. Clean. No change.
- **Neglect texture -- Bandit Road (PDV_Notif_Bosmer_BanditRoad_NeglectTexture)** [Player-2nd]: Baan Dar's luck has gone dormant. The road is just hardship now.
  - _note:_ Ported verbatim from manifest 17.8. Clean. No change.
- **Favor (Marked) -- Bandit Road reversal (PDV_Msg_Bosmer_FavorMarked_BanditRoad_Reversal)** [God-voice]: Title: "Baan Dar's Luck"  Body: "You should not have walked away from that. You did. That is the story they will tell about you in the dark, around the fire. I gave you the ending."
  - _note:_ Ported from manifest 17.10; ASCII-safe already. The live runtime currently surfaces only a flat Debug.Notification 'Baan Dar opens the gap. Run.' at the Gap signal site -- this Marked MessageBox is the weekly-capped rare-major-favor beat that should sit above it.
- **Champion entry -- Old Contract (PDV_Msg_Bosmer_ChampionEntry_OldContract)** [God-voice]: Title: "Y'ffre's Mark"  Body: "You kept the Pact in exile, where no warden watched and no forest enforced it. You kept it because it is true, not because it is law. The covenant is fully yours, and the wild knows you for its own."
  - _note:_ Ported verbatim from manifest 17.4; ASCII-clean. God-voice; one-time on first Old Contract Devoted. Carries the Standing band implicitly (Devoted) without printing the token, so no conform needed.
- **Champion entry -- Living Story (PDV_Msg_Bosmer_ChampionEntry_LivingStory)** [God-voice]: Title: "The Story Carried"  Body: "The forest could not follow you here, so you carried the Story instead -- in memory, in community, in the telling. I am the Now held by narrative, and you hold a piece of it."
  - _note:_ Ported from manifest 17.4; ASCII double-hyphen; shifted the closing 'Y'ffre is the Now held by narrative' to first-person 'I am the Now' since Y'ffre is speaking in god-voice. Otherwise verbatim.
- **Champion entry -- Exchange (PDV_Msg_Bosmer_ChampionEntry_Exchange)** [God-voice]: Title: "The Account Clean"  Body: "Debt by debt, wrong by wrong, you have kept the world even. Nothing free, nothing owed, nothing left unpaid. My balance runs through you now."
  - _note:_ Ported from manifest 17.4; conformed 'Z'en's balance' to first-person 'My balance' (Z'en is the speaker). ASCII-clean.
- **Champion entry -- Bandit Road (PDV_Msg_Bosmer_ChampionEntry_BanditRoad)** [God-voice]: Title: "The Story by the Fire"  Body: "You are the one who should not have made it -- and did, and again, and again. That is the story exiles tell in the dark. I write those stories, and you are in my book."
  - _note:_ Ported from manifest 17.4; ASCII double-hyphen; conformed 'Baan Dar writes those stories' to first-person 'I write those stories'. Otherwise verbatim.
- **Dream / ambient -- GetBosmerDreamText (live runtime lines, voice review only)** [Player-2nd / Narrator-vision]: OldContract (compliant): "You dream the old green, ordered and exact, and you know your place in it."  |  OldContract (compliance <20): "You dream of green going grey, and a voice that has stopped expecting you to answer."  |  Exchange: "You dream of a ledger no one keeps but you, and every line balancing at last."  |  BanditRoad: "You dream of a fire on the road, and faces that owe you nothing and share anyway."  |  LivingStory/default: "You dream the Story still telling itself, and you are a line in it that has not ended."
  - _note:_ Live lines from GetBosmerDreamText. All five are voice-clean: second-person, no dev language, ASCII-safe. No rewrite recommended -- captured here so the voice review covers them. These are the strongest existing Bosmer prose and are a good tonal anchor for the rest of the pass.
- **Variety-tranche ambient -- Tale Carried (Living Story hearth return)** [Player-2nd]: "You told the tale, and the telling settled."
  - _note:_ Live Debug.Notification in TryBosmerHearthSleep. Clean player-2nd, ASCII-safe. No change. (Hearth-declare line at the same site -- 'This hearth is where your stories come home now.' -- is also clean.)
- **Variety-tranche ambient -- green-song award + milestone (AwardBosmerSong)** [Narrator-vision]: Per-site: "This green place still holds one of Y'ffre's old tellings. For a breath the Story leans close, and names you a part of it."  |  All-six milestone: "Every green song has known you now. Wherever the road runs, the Story runs with you."
  - _note:_ Live Debug.MessageBox lines. Voice-clean, ASCII-safe, on-theme. No rewrite. Note these are MessageBox (modal) not notification -- consistent with their milestone weight.
- **Variety-tranche ambient -- Scales at Rest (Exchange signature)** [Player-2nd]: "The account is even. The bargains fall your way for a while."
  - _note:_ Live Debug.Notification in TryBosmerScalesAtRest. Clean, ASCII-safe. No change.
- **Variety-tranche ambient -- Baan Dar Opens the Gap (Bandit Road signature)** [Player-2nd]: "Baan Dar opens the gap. Run."
  - _note:_ Live Debug.Notification in TryBosmerBaanDarGap. Punchy and clean. Voice-OK. Judgment call: this terse line is the EVERYDAY once-per-day signal; the manifest's PDV_Msg_Bosmer_FavorMarked_BanditRoad_Reversal god-voice box is the rare weekly beat above it. Keep both, distinct cadence. ASCII-safe.

## Breton

### Conformed surface copy

- **Survey base -- vampire-suppressed Knight's Road / Green Way short-circuit (parallel to GetNordSurveyBaseText's vampire guard; narrator)** [NARRATOR]: The undeath has closed your tradition's road. Standing: <band>. Cure the curse to reopen it.
  - _note:_ NEW. Optional restructuring aid: if author wants a single clean readout when curse posture is active rupture and the tradition fully breaks, this replaces stacking the base line plus the rupture component. Mirrors the Nord pattern. Author decides whether to short-circuit or keep base + component.
- **Curse-state: Vampire Onset (PDV_Msg_Breton_CurseState_VampireOnset, 18.12)** [GOD-VOICE]: Title: "The Curse and the Tradition" Body: "You are undead now, and each tradition answers in its own way. The Knight's Road breaks under you -- the oaths and the Divines are lost. The Green Way casts you out, and Y'ffre closes. Only the Hidden Art keeps a partial home for you, in the Volkihar court and the witch-mother's welcome."
  - _note:_ PORT. Manifest copy is already god-voice and clean; tightened cadence, no band/standing token (transition MESG, not a status block).
- **Curse-state: Vampire Cured (PDV_Msg_Breton_CurseState_VampireCured, 18.12)** [GOD-VOICE]: Title: "Re-Entry" Body: "The undeath is lifted. The Knight's Road can be rebuilt as your integrity is restored. The Green Way still holds you under suspicion, and a fuller homecoming there is a road not yet open."
  - _note:_ PORT + DE-DEV. Replaces "until an authored re-entry exists; richer restoration is deferred" -- roadmap language leaking into player copy. Reworded to in-world "a road not yet open."
- **Curse-state: Werewolf Onset -- Knight's Road (PDV_Msg_Breton_CurseState_WerewolfOnset_KnightsRoad, 18.12)** [GOD-VOICE]: Title: "Homeless in the Vow" Body: "The beast is in you, and the Knight's Road has no place for it. There is no home for the wolf in the vow. Your integrity wears down with each change, and the knightly orders will never understand what you have become."
  - _note:_ PORT. Minor tightening; manifest copy already clean god-voice.
- **Curse-state: Werewolf Onset -- Hidden Art (PDV_Msg_Breton_CurseState_WerewolfOnset_HiddenArt, 18.12)** [GOD-VOICE]: Title: "The Beast Belongs" Body: "The beast is in you, and the Hidden Art already keeps Hircine close. Glenmoril is family here. Nothing ruptures -- the wolf settles into the occult frame as though it were always meant for you."
  - _note:_ PORT. Clean as-is; light cadence pass only.
- **Curse-state: Werewolf Cured (PDV_Msg_Breton_CurseState_WerewolfCured, 18.12)** [GOD-VOICE]: Title: "The Beast Set Down" Body: "The wolf is set down. On the Knight's Road your integrity can be rebuilt now, the changes ended, though the orders remember. In the Hidden Art the beast that belonged is given up by choice -- Glenmoril marks the loss, and the occult frame keeps an empty place where it stood."
  - _note:_ PORT. Clean as-is; light cadence pass only.
- **Curse-posture (narrator, Survey-embedded) -- replaces the dev label "Curse posture: active rupture / restoration needed"** [NARRATOR]: restoration needed -> "A curse sits on you, and your tradition will not hold until it is restored."  |  active rupture -> "A curse has ruptured your tradition, and its road is closed until you are cured."
  - _note:_ NEW. The live GetBretonCursePostureLabel returns bare enum-ish phrases ("active rupture", "restoration needed") appended after "Curse posture:". These are the humanized narrator components (also in survey_component_lines). Empty when RestorationState == 0; do not append.
- **Neglect texture -- Knight's Road (PDV_Notif_Breton_KnightsRoad_NeglectTexture, 18.9)** [PLAYER-2ND]: The vow feels hollow lately. Your patron is disappointed in you, not yet distant.
  - _note:_ PORT. Player-2nd, clean. Minor cadence tweak only.
- **Neglect texture -- Hidden Art (PDV_Notif_Breton_HiddenArt_NeglectTexture, 18.9)** [PLAYER-2ND]: You went notorious, then let it lapse. The cost still stands; the reward is gone.
  - _note:_ PORT. Lowercased "Notorious" so no raw band token leaks; otherwise clean.
- **Neglect texture -- Green Way (PDV_Notif_Breton_GreenWay_NeglectTexture, 18.9)** [PLAYER-2ND]: The forest has stopped noticing you. Nature is only scenery now.
  - _note:_ PORT. Clean; "background" -> "scenery" for warmth. Player-2nd.
- **Favor-Noted -- Knight's Road, mercy/justice (PDV_Notif_Breton_FavorNoted_KnightsRoad_MercyJustice, 18.11)** [PLAYER-2ND]: Mercy chosen, justice kept. The vow holds, and Stendarr sees it.
  - _note:_ PORT. Clean player-2nd. No change beyond confirming voice.
- **Favor-Noted -- Knight's Road, protected other (18.11)** [PLAYER-2ND]: You stood between the weak and the blade. The shield is real.
  - _note:_ PORT. Clean.
- **Favor-Noted -- Knight's Road, unrewarded aid (18.11)** [PLAYER-2ND]: Help given, no reward asked. The Knight's Road counts it.
  - _note:_ PORT. Clean; tightened.
- **Favor-Noted -- Hidden Art, occult work (18.11)** [PLAYER-2ND]: The hidden practice deepens. Your patron is pleased, and quiet about it.
  - _note:_ PORT. Clean.
- **Favor-Noted -- Hidden Art, Daedric rite (18.11)** [PLAYER-2ND]: A Daedric rite is done. The patron's reward runs strong through you.
  - _note:_ PORT. Clean.
- **Favor-Marked -- Hidden Art, Notorious rupture (PDV_Msg_Breton_FavorMarked_HiddenArt_NotoriousRupture, 18.11)** [GOD-VOICE]: Title: "Notorious" Body: "You have stopped hiding. Society recoils, and there is no taking it back -- but I no longer have to whisper to you. The art is loud now, and it is wholly yours."
  - _note:_ PORT. Clean god-voice; "fully" -> "wholly" for cadence. One-time Marked moment.
- **Favor-Noted -- Green Way, standing stone (18.11)** [PLAYER-2ND]: At the standing stone, the old covenant answers you.
  - _note:_ PORT. Clean.
- **Favor-Noted -- Green Way, outdoor life (18.11)** [PLAYER-2ND]: The wild keeps you. Y'ffre's covenant holds steady.
  - _note:_ PORT. Clean.
- **Favor-Noted -- Green Way, nature restraint (18.11)** [PLAYER-2ND]: You spared the living world where you could. Counted.
  - _note:_ PORT. Clean.
- **Champion entry -- Knight's Road (PDV_Msg_Breton_ChampionEntry_KnightsRoad, 18.6). Champion-entry = GOD-VOICE per voice spec.** [GOD-VOICE]: Title: "The Vow Unbroken" Body: "Skyrim offered you the Guild, the Brotherhood, every easy shortcut -- and you kept the vow through all of it. That is the hardest road in this province. The shield you carry for others is real now."
  - _note:_ PORT. Already god-voice; clean. No standing token (this is the Devoted-crossing moment itself).
- **Champion entry -- Hidden Art (PDV_Msg_Breton_ChampionEntry_HiddenArt, 18.6)** [GOD-VOICE]: Title: "The Double Life Resolved" Body: "You chose -- the practice hidden completely, or declared and notorious. You did not linger in the safe middle. Your patron rewards the one who commits, whichever way you went. The art is fully yours."
  - _note:_ PORT. Lowercased "Notorious" so it reads as state-feel, not a raw band token.
- **Champion entry -- Green Way (PDV_Msg_Breton_ChampionEntry_GreenWay, 18.6)** [GOD-VOICE]: Title: "The Forest Knows You" Body: "Skyrim's woods are cold, and they do not welcome easily. They welcome you. The animals settle, the hunt is guided, the standing stones answer. The old covenant is kept, quietly and completely."
  - _note:_ PORT. Clean god-voice.
- **Tradition setup choice (PDV_Msg_Breton_TraditionChoice_Setup, 18.4). Breton's setup stands in for a commitment offer; narrator per manifest.** [NARRATOR]: Title: "Which Tradition" Body: "Breton faith is the tradition you walk; the gods give it shape after. Choose: the Knight's Road of vow and mercy, the Hidden Art of occult practice, or the Green Way of the old druidic covenant."
  - _note:_ PORT (not a god-voice offer). Listed here because the brief notes Breton has tradition SETUP, not a commitment offer; new_offer_copy is intentionally empty. Clean as-is.
- **Label builders -- humanized return strings for the 6 Breton builders** [NARRATOR]: GetBretonTraditionLabel: Knight's Road / Hidden Art / Green Way / "no tradition yet" (was "Unchosen").  GetBretonKnightlyVowLabel: intact / strained / broken (keep).  GetBretonWitchcraftExposureLabel: hidden / suspected / known / notorious (keep, lowercase).  GetBretonDruidicStandingLabel: open / acknowledged / fraying (was "frayed").  GetBretonDruidicForkLabel: "serving the Green" / "gone to the wolf" / "counted a betrayer" / "" (was Druidic/Werewolf/Betrayed/None).  GetBretonCursePostureLabel: "restoration needed" / "a ruptured tradition" (was "restoration needed"/"active rupture").
  - _note:_ DRAFT. These are the bare adjectives the survey composes. If the author keeps the componentized full-sentence lines above, several builders become unused inside Survey; flagged in open_questions. Bare humanized forms provided in case the author keeps the inline "<track>: <label>" shape for some axes.

## Argonian

### Conformed surface copy

- **Survey wrapper -- composition note (not a string)** [Narrator]: COMPOSE ORDER: base-identity line (Hist-posture variant + 'Standing: <band>.') then append, only when each is live: the three layer-strength lines (Hist, then People, then Void), then the Sithis active/edge precedence line, then the bed-of-choice line, then the Hist-source tail. One clean sentence per line; whole composite <= ~6 lines, so when many sub-states are live, prefer the layer lines + Sithis line + at most one of bed/source. <band> binds GetPublicTierBand(): Distant / Observant / Faithful / Devoted. This replaces the single PDV_Msg_Argonian_Survey_Layered template, which omitted the Standing token and could not model the state-space.
- **Curse-state VampireOnset (19.13)** [Narrator (manifest voice-deviation: the Hist reaches, it does not speak; ported intact, encoding-safe)]: Title: "The Hist Falls Silent"  Body: "You are undead now. The Hist gives Saxhleel souls and receives them at death -- and yours is no longer going where it was meant to go. The Hist falls silent. The People cannot safely hold you. Only the void stays near. This is the deepest grief."
  - _note:_ PORTED from manifest 19.13. Hyphen/quotes already ASCII-safe. No 'Current standing:' present. Sets posture Silenced/Corrupted.
- **Curse-state VampireCured (19.13)** [Narrator (voice-deviation per manifest)]: Title: "The Hist Reaches Again"  Body: "The undeath is lifted. The Hist's silence breaks slowly -- it must learn to reach you again across both the distance and the memory of what you were. The People can hold you once more. It will take time. It can be done."
  - _note:_ PORTED from manifest 19.13, ASCII-clean.
- **Curse-state WerewolfOnset (19.13)** [Narrator (voice-deviation per manifest)]: Title: "A Changed Shape"  Body: "The beast is in you. The Hist is accustomed to Saxhleel who change -- the shape strains the relation but does not sever it. The People can still recognize you. This is serious, but it is not the silence. It can be carried."
  - _note:_ PORTED from manifest 19.13. Sets posture Strained.
- **Curse-state WerewolfCured (19.13)** [Narrator (voice-deviation per manifest)]: Title: "The Shape Settles"  Body: "The beast is set down. The strain on the Hist relation eases, and the People recognize you without reservation again. The shape that pulled at the bond is gone. What was carried is set aside; the Hist reaches you clean."
  - _note:_ PORTED from manifest 19.13, ASCII-clean. Clears posture Strained.
- **Champion entry -- Hist (19.5)** [Narrator (voice-deviation per manifest: no Hist voice to speak)]: Title: "Hist-Touched"  Body: "Across all the miles from Black Marsh, in the wetlands and waters of this cold province, the Hist has found a way to reach you. It does not speak. It does not need to. You are Saxhleel, wholly, even here."
  - _note:_ PORTED from manifest 19.5, ASCII-clean.
- **Champion entry -- Community (19.5)** [God-voice (the People's collective voice, per manifest)]: Title: "The Saxhleel Bond"  Body: "You kept the exile community alive when the Hist could not hold us. The Assemblage, the docks, every Saxhleel you stood beside -- we know you. You are the family we chose, as we are yours."
  - _note:_ PORTED from manifest 19.5, ASCII-clean.
- **Champion entry -- Sithis (19.5)** [God-voice (Sithis-voice, per manifest)]: Title: "Void-Held"  Body: "You looked into the dark that precedes and surrounds all things, and you did not flinch. Sithis does not comfort. But Sithis catches what has truly accepted the void. You have. Walk on, unafraid of the ending."
  - _note:_ PORTED from manifest 19.5, ASCII-clean.
- **Champion ambient -- Hist near water (19.5)** [Player-2nd]: Near the water, the Hist is almost here. You can feel it.
  - _note:_ PORTED from manifest 19.5; player-2nd, matches matrix.
- **Champion ambient -- Community kin present (19.5)** [Player-2nd]: A Saxhleel beside you. The exile community holds.
  - _note:_ PORTED from manifest 19.5.
- **Neglect texture -- Hist thinning (19.9)** [Player-2nd]: The Hist is thinning. You feel less Saxhleel than you did.
  - _note:_ PORTED from manifest 19.9.
- **Neglect texture -- People isolation (19.9)** [Player-2nd]: Alone too long, no Saxhleel near. Isolation deepens the distance.
  - _note:_ PORTED from manifest 19.9.
- **Neglect texture -- Void dormancy (19.9)** [Player-2nd]: Sithis lies dormant. The void is there, but you have not faced it.
  - _note:_ PORTED from manifest 19.9. (Wording matches the Survey Void-dormant component line by design.)
- **Tier-up notification -- Observant_Lapse (19.4)** [Player-2nd (neglect texture per matrix)]: The layers are thinning. Your standing has slipped to Observant.
  - _note:_ CONFORMED from manifest 19.4, which read 'slipped to Wavering.' 'Wavering' is NOT one of the agreed public bands (Distant/Observant/Faithful/Devoted). A lapse out of Observant drops to Distant; a lapse out of Faithful drops to Observant. See open_questions -- author should confirm which band this row names; drafted here as Observant assuming it is the Faithful->Observant step, but flag.
- **Tier-up notification -- Faithful_Lapse (19.4)** [Player-2nd]: The exile identity is fraying. Standing: Observant.
  - _note:_ PORTED from manifest 19.4, conformed to 'Standing:' embed form.
- **Tier-up notification -- Devoted_Lapse (19.4)** [Player-2nd]: The deepest connection loosens. The Devoted bond is not held.
  - _note:_ PORTED from manifest 19.4, ASCII-clean.
- **Tier-up notification -- Observant_Entry / Faithful_Entry / Devoted_Entry (19.4)** [Player-2nd]: Observant: The Hist reaches you, and the People know you. | Faithful: All three layers hold under exile. | Devoted: The Hist knows you still, across all that distance.
  - _note:_ PORTED from manifest 19.4; bands already conform. Listed for completeness -- entry rows need no change.
- **Bed of choice -- Designate (live notif 'This is your place of rest now...' / manifest 19.7 Designate)** [Player-2nd]: This is your place of rest now -- the family you chose. The root will remember it.
  - _note:_ RECONCILED: merges the live runtime line 'This is your place of rest now. The root will remember it.' with manifest 19.7 Designate 'You have chosen this bed: the family you chose. The exile has an anchor.' Keeps the runtime's stronger first clause + the manifest's 'family you chose' framing so the voice pass does not regress the shipped line.
- **Bed of choice -- Return rooted-rest wake (live 'You wake rooted.' / manifest 19.7 Return)** [Player-2nd]: You wake rooted. Back at the bed you chose, the People hold you a little closer.
  - _note:_ RECONCILED: the live wake line is the bare 'You wake rooted.' (fires only at >= 12 sleeps when the Rooted Rest spell casts); manifest 19.7 Return is 'Back at the bed you chose. The People hold you a little closer.' Combined so the rooted-rest cast keeps its distinct 'You wake rooted' beat without losing the manifest texture. If kept as two separate notifications, use 'You wake rooted.' for the spell-cast and the second sentence for the qualifying-sleep return.
- **Bed of choice -- MissedCadence (19.7, no live runtime line yet)** [Player-2nd]: You have not returned to your chosen bed in too long. The anchor weakens.
  - _note:_ PORTED from manifest 19.7; ASCII-clean. No conflicting runtime line.
- **Sithis activation -- FirstSignal / FullActivation (19.8)** [Narrator]: FirstSignal: Sithis stirs at the edge of you -- change, death, the void acknowledged. | FullActivation: Sithis is fully awake in you now, a third way to make meaning in exile.
  - _note:_ PORTED from manifest 19.8, ASCII-clean. The FullActivation line intentionally echoes the Survey 'Sithis is awake' component for continuity.
- **Posture dream textures -- GetDreamTextForPosture (live at D0, 5 postures x 3 variants; richest Argonian flavor)** [Player-2nd (ambient sleep flavor; no piety, pure texture)]: NORMAL: (1) You dream of warm sap and slow rivers. The root remembers your name. (2) In sleep the marsh breathes with you. The Hist hums, content. (3) You dream of home: reeds, rain, and the long memory of trees. || DISTANT: (1) The dream is far away, a green light beyond cold water. (2) You hear the Hist as if through deep mud. The song is faint. (3) The root reaches for you and falls short. You wake reaching back. || STRAINED: (1) The dream tangles. Roots grip too tight, and the sap runs thin. (2) Something pulls between you and the trees. The song frays. (3) You dream of a storm bending the great trees. They call your name once. || SILENCED: (1) You dream of still black water. No root, no song, no name. (2) The marsh is empty in your sleep. Even the rain has stopped. (3) You call into the dream and nothing answers. The silence is total. || CORRUPTED: (1) The dream is wrong. The trees watch you with eyes that are not theirs. (2) Sap runs black in your sleep. The song plays backward. (3) Something else dreams through the root tonight. It knows your name.
  - _note:_ CAPTURED VERBATIM from PDV_Substrate_ArgonianHist.GetDreamTextForPosture (all 15 already ASCII-clean and in-voice). No rewrite needed -- recorded so the voice pass does not regress them. These are the strongest Argonian flavor and align cleanly with the posture vocabulary used in the Survey base variants.
