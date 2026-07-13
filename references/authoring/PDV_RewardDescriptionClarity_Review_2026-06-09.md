# Reward / Boon / Price Description Clarity - Review (task #16)

**Generated:** 2026-06-09 by `tools/pdv_reward_desc_audit.mjs` (re-run to refresh).
**Status:** REVIEW-READY copy. Not yet authored into records.

Each row keeps the existing thematic `playerFacingText` and appends a literal
mechanical clause so boon/price/reward descriptions reach deity-parity clarity.
All effects are constant (passive ability) -- the clause states the standing
magnitude, not a duration. Approve the wording, then re-author the MGEF/SPEL
`Description` from the `Proposed` column on the Windows box (author tools read
`playerFacingText`; update the spec text there so re-authoring is idempotent).

**Coverage:** 282 records across 12 spec files - **6 need a magnitude clause (ADD)**, 276 already state it (clear).

`ADD` = the description does not state the magnitude and should get the clause.
`clear` = the magnitude already appears in the text (shown for audit; no change needed).

## Worklist - records needing a magnitude clause (ADD)

| EditorID | Effect clause | Proposed description |
| --- | --- | --- |
| `PDV_Bless_Daedric_Namira_Champion` | +0% Health Regen | Namira's reviled hunger sustains you. Feeding on the dead restores Health and Stamina. (Effect: +0% Health Regen.) |
| `PDV_Bless_Daedric_Namira_Devoted` | +0% Health Regen | Namira's reviled hunger sustains you. Feeding on the dead restores Health and Stamina. (Effect: +0% Health Regen.) |
| `PDV_Bless_Daedric_Namira_Seeker` | +0% Health Regen | Namira's reviled hunger sustains you. Feeding on the dead restores Health and Stamina. (Effect: +0% Health Regen.) |
| `PDV_SPEL_OrcCodeHolds` | +40 Health | You dropped near death and held the code. Health floods back. (Effect: +40 Health.) |
| `PDV_SPEL_OrcCodeHolds_Devoted` | +60 Health, +30 Stamina | You dropped near death and held the code. Health and stamina come back. (Effect: +60 Health, +30 Stamina.) |
| `PDV_SPEL_OrcHearthHeld` | +5% Stamina Regen | You return to a place made yours by work and oath. Stamina returns faster for a while. (Effect: +5% Stamina Regen.) |

## Audit - already-clear records (no change needed), by file

### PDV_AltmerRewardRecords.spec.json (18)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Altmer_AuriEl_T1` | +15 Magicka | The Dawn steadies you. Fortify Magicka +15. |
| `PDV_Bless_Altmer_AuriEl_T2` | +25 Magicka, +6% Magic Resistance | The ancestor-light wards your mind. Fortify Magicka +25, Magic Resistance +6%. |
| `PDV_Bless_Altmer_AuriEl_T3` | +40 Magicka, +16% Magic Resistance | You walk the path of return Auri-El first walked. Fortify Magicka +40, Magic Resistance +16%. |
| `PDV_Bless_Altmer_Magnus_T1` | +5 Alteration | The architect of magic favors disciplined study. Alteration +5. |
| `PDV_Bless_Altmer_Magnus_T2` | +13 Alteration, +25 Magicka | The structure of the arts opens to you. Alteration +13, Fortify Magicka +25. |
| `PDV_Bless_Altmer_Magnus_T3` | +25 Alteration, +40 Magicka | You see through the aperture Magnus left in the world. Alteration +25, Fortify Magicka +40. |
| `PDV_Bless_Altmer_Orthodox_T1` | +15 Magicka | You keep to the ancestral order. Fortify Magicka +15. |
| `PDV_Bless_Altmer_Orthodox_T2` | +25 Magicka, +5% Magic Resistance | Your coherence holds against a divided world. Fortify Magicka +25, Magic Resistance +5%. |
| `PDV_Bless_Altmer_Syrabane_T1` | +5 Restoration | The apprentice's god steadies your protective art. Restoration +5. |
| `PDV_Bless_Altmer_Syrabane_T2` | +13 Restoration, +8% Magic Resistance | The ward holds around the one still learning. Restoration +13, Magic Resistance +8%. |
| `PDV_Bless_Altmer_Syrabane_T3` | +25 Restoration, +20% Magic Resistance | You protect the path for yourself and the vulnerable mage. Restoration +25, Magic Resistance +20%. |
| `PDV_Bless_Altmer_Trinimac_T1` | +5 One-Handed | Civilization is defended by your hand. One-Handed +5. |
| `PDV_Bless_Altmer_Trinimac_T2` | +13 One-Handed, +15% Armor Rating | The martial ancestor steadies the orthodox arm. One-Handed +13, Armor +15. |
| `PDV_Bless_Altmer_Trinimac_T3` | +25 One-Handed, +50% Armor Rating | You defend the project by force and discipline. One-Handed +25, Armor +50. |
| `PDV_Bless_Altmer_Xarxes_T1` | +5 Restoration | The keeper of records steadies your hand at preservation. Restoration +5. |
| `PDV_Bless_Altmer_Xarxes_T2` | +13 Restoration, +25 Magicka | What is kept is what endures. Restoration +13, Fortify Magicka +25. |
| `PDV_Bless_Altmer_Xarxes_T3` | +25 Restoration, +40 Magicka | Your name and works are written into the long ledger. Restoration +25, Fortify Magicka +40. |
| `PDV_SPEL_Neglect_Altmer` | -10 Magicka | You have let coherence lapse. Your Maximum Magicka is reduced by 10 until you return to dawn practice and the ancestral order. |

### PDV_ArgonianRewardRecords.spec.json (14)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Argonian_Hist_Signature` | +30 Health (near water), +25 Stamina, +10% Poison Resistance | You carry the marsh within you. Your Maximum Stamina rises +25 and your resistance to poison rises 10%; near water your Maximum Health rises +30. |
| `PDV_Bless_Argonian_Hist_T1` | +10 Health (near water) | The Hist keeps a steadying hand on you near water. Maximum Health +10 when you are in or near water. |
| `PDV_Bless_Argonian_Hist_T2` | +20 Health (near water), +25 Stamina | The Hist holds you close even in exile. Your Maximum Stamina rises +25; near water your Maximum Health rises +20. |
| `PDV_Bless_Argonian_People_T1` | +25 Carry Weight | The people you chose look out for you. You can carry 25 more weight. |
| `PDV_Bless_Argonian_People_T2` | +25 Carry Weight, +8% Poison Resistance, +10 Health | Your chosen family steadies you. You carry 25 more weight, poison resistance rises 8%, and Maximum Health +10. |
| `PDV_Bless_Argonian_People_T3` | +50 Carry Weight, +8% Poison Resistance, +20 Health, +5% Magic Resistance | You are a pillar of the people you gathered. You carry 50 more weight, poison resistance rises 8%, Maximum Health +20, and magic finds less purchase (5%). |
| `PDV_Bless_Argonian_Sithis_T1` | +4 Sneak | Having faced the Void, you move a little quieter. Sneak +4. |
| `PDV_Bless_Argonian_Sithis_T2` | +10 Sneak, +5% Poison Resistance, +10 Unarmed Damage | The Void has marked your passing. Sneak +10, poison resistance rises 5%, and your bare strikes carry the Void's weight (+10 unarmed). |
| `PDV_Bless_Argonian_Sithis_T3` | +25 Stamina, +12 Unarmed Damage | Sithis holds those who faced the Void unflinching. Your Maximum Stamina rises +25, your bare strikes carry the Void's weight (+12 unarmed), and near death the Void can lend a brief surge. |
| `PDV_Bless_Argonian_Substrate_Always` | +5% Magic Resistance | The Hist remembers you across the distance. Your resistance to magic rises by 5%. |
| `PDV_Bless_Argonian_Substrate_High` | +5% Magic Resistance, +30 Health (near water), +22% Poison Resistance | You are deeply attuned to the Hist even far from the marsh. Magic finds little purchase (5%) and poison fails (22%). Near water, the Hist fortifies you, raising your Maximum Health +30. |
| `PDV_Bless_Argonian_Substrate_Mid` | +5% Magic Resistance, +20 Health (near water), +10% Poison Resistance | The Hist reaches a little closer. Magic finds less purchase (5%) and your resistance to poison rises 10%. Near water, the Hist steadies you, raising your Maximum Health +20. |
| `PDV_SPEL_ArgonianSithisNearDeathBurst` | +50% Stamina Regen | Near death, the Void lends a brief surge. Stamina returns 50% faster for 10 seconds. |
| `PDV_SPEL_Neglect_ArgonianHist` | -10 Health (in the matching posture) | The Hist has grown distant and cannot reach you. Maximum Health -10 until the connection is restored. |

### PDV_BosmerRewardRecords.spec.json (15)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Bosmer_BanditRoad_T1` | +15% Armor Rating | The road toughens the pariah. Armor +15. |
| `PDV_Bless_Bosmer_BanditRoad_T2` | +30% Armor Rating, +20 Health | The outsider survives what should have ended them. Armor +30, Maximum Health +20. |
| `PDV_Bless_Bosmer_BanditRoad_T3` | +50% Armor Rating, +30 Health, +10 Sneak | Baan Dar's luck holds when the odds say it should not. Armor +50, Maximum Health +30, Sneak +10. |
| `PDV_Bless_Bosmer_Exchange_T1` | +5 Speech | Z'en steadies fair dealing after a debt is settled. Speech +5. |
| `PDV_Bless_Bosmer_Exchange_T2` | +13 Speech, +30 Carry Weight | Z'en weighs what is owed and what is carried. Speech +13, Carry Weight +30. |
| `PDV_Bless_Bosmer_Exchange_T3` | +25 Speech, +80 Carry Weight, +50% Armor Rating | Z'en keeps the ledger of toil and redress with you. Speech +25, Carry Weight +80, Armor +50. |
| `PDV_Bless_Bosmer_LivingStory_T1` | +5 Speech | The story you carry opens doors. Speech +5. |
| `PDV_Bless_Bosmer_LivingStory_T2` | +13 Speech, +20 Health | Community and memory keep you whole. Speech +13, Maximum Health +20. |
| `PDV_Bless_Bosmer_LivingStory_T3` | +25 Speech, +30 Health, +15 Magicka | You are a story Y'ffre still tells. Speech +25, Maximum Health +30, Fortify Magicka +15. |
| `PDV_Bless_Bosmer_OldContract_T1` | +5 Archery | The proper hunt sharpens your eye. Archery +5. |
| `PDV_Bless_Bosmer_OldContract_T2` | +13 Archery, +10 Sneak | Forest-kept and proper, you pass unseen and strike true. Archery +13, Sneak +10. |
| `PDV_Bless_Bosmer_OldContract_T3` | +25 Archery, +22 Sneak, +10% Poison Resistance | You keep the Old Contract as the first Bosmer kept it. Archery +25, Sneak +22, Poison Resistance +10%. |
| `PDV_Bless_Bosmer_Yffre_T1` | +15 Stamina | The forest's story carries you a little. Fortify Stamina +15. |
| `PDV_Bless_Bosmer_Yffre_T2` | +25 Stamina, +8 Sneak | You move with the forest's grain. Fortify Stamina +25, Sneak +8. |
| `PDV_SPEL_Neglect_Bosmer` | -10 Stamina | Your path no longer answers. Your Maximum Stamina is reduced by 10 until you walk it again. |

### PDV_BretonRewardRecords.spec.json (25)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Breton_Champion_Akatosh` | +40 Magicka, +15% Magic Resistance | Akatosh's endurance steadies your magicka and turns hostile magic. Fortify Magicka +40, Magic Resistance +15%. |
| `PDV_Bless_Breton_Champion_Arkay` | +27% Disease Resistance, +30 Health | Arkay wards the cycle in you against rot and undeath. Disease Resistance +27%, Health +30. |
| `PDV_Bless_Breton_Champion_Dibella` | +25 Speech, +40 Magicka | Dibella's inspiration graces your voice and your art. Speech +25, Fortify Magicka +40. |
| `PDV_Bless_Breton_Champion_Julianos` | +40 Magicka, +15% Magic Resistance | Julianos's insight sharpens your recovery and your wards. Fortify Magicka +40, Magic Resistance +15%. |
| `PDV_Bless_Breton_Champion_Kynareth` | +40 Stamina, +13% Magic Resistance | Kynareth's sky fills your breath and shields you. Fortify Stamina +40, Magic Resistance +13%. |
| `PDV_Bless_Breton_Champion_Magnus` | +25 Alteration, +40 Magicka | You see through the aperture Magnus left in the world. Alteration +25, Fortify Magicka +40. |
| `PDV_Bless_Breton_Champion_Mara` | +23 Restoration, +15% Magic Resistance | Mara's compassion works through you, mending and warding. Restoration +23, Resist Magic +15%. |
| `PDV_Bless_Breton_Champion_Talos` | +50% Armor Rating, +20 One-Handed | Talos's triumph hardens your guard and your sword-arm. Armor +50, One-Handed +20. |
| `PDV_Bless_Breton_Champion_Zenithar` | +120 Carry Weight, +20 Speech | Zenithar's prosperity rewards honest labor and fair trade. Carry Weight +120, Speech +20. |
| `PDV_Bless_Breton_GreenWay_T1` | +15 Stamina | The rites keep you close to the land. Fortify Stamina +15. |
| `PDV_Bless_Breton_GreenWay_T2` | +25 Stamina, +8 Restoration | The standing stones and outdoor rites answer you. Fortify Stamina +25, Restoration +8. |
| `PDV_Bless_Breton_GreenWay_T3` | +40 Stamina, +18 Restoration, +20 Health | The covenant of the wild is kept in you. Fortify Stamina +40, Restoration +18, Maximum Health +20. |
| `PDV_Bless_Breton_HiddenArt_T1` | +6 Conjuration | The cover holds and the art answers. Conjuration +6. |
| `PDV_Bless_Breton_HiddenArt_T2` | +15 Conjuration, +9 Illusion | The occult work runs deeper. Conjuration +15, Illusion +9. |
| `PDV_Bless_Breton_HiddenArt_T3` | +27 Conjuration, +21 Illusion, +25 Magicka | The art is yours, and the cover is your burden. Conjuration +27, Illusion +21, Fortify Magicka +25. |
| `PDV_Bless_Breton_KnightsRoad_T1` | +5 Block | The vow steadies your guard. Block +5. |
| `PDV_Bless_Breton_KnightsRoad_T2` | +13 Block, +8% Magic Resistance | You stand between the weak and harm. Block +13, Magic Resistance +8%. |
| `PDV_Bless_Breton_KnightsRoad_T3` | +25 Block, +18% Magic Resistance, +50% Armor Rating | The vow is your bulwark. Block +25, Magic Resistance +18%, Armor +50. |
| `PDV_Bless_Breton_Tradition_T1` | +10 Health | Your chosen tradition steadies you. Maximum Health +10. |
| `PDV_Bless_Breton_Tradition_T2` | +20 Health, +5% Magic Resistance | A Breton kept by tradition is well-warded. Maximum Health +20, Magic Resistance +5%. |
| `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` | -15 Stamina, -8 Restoration | You turned from the covenant. The wild no longer keeps you as it did. Maximum Stamina -15, Restoration -8. |
| `PDV_SPEL_CreedLoss_Breton_Excommunication` | -15 Health | The tradition has cast you out. Its keeping is withdrawn until you earn your way back. Maximum Health -15. |
| `PDV_SPEL_CreedLoss_Breton_ExposureRupture` | -8 Conjuration, -8 Illusion | Your cover is blown. The hidden art turns against you until the rupture is answered. Conjuration -8, Illusion -8. |
| `PDV_SPEL_CreedLoss_Breton_VowIntegrity` | -5 Speech, -5 Restoration | You broke the vow. Speech and Restoration falter until the vow is repaired. Speech -5, Restoration -5. |
| `PDV_SPEL_Neglect_Breton` | -10 Health, -5% Magic Resistance | You have let your chosen tradition lapse. Maximum Health -10, Magic Resistance -5% until you return to it. |

### PDV_DaedricPrinceRecordContracts.json (93)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Daedric_Azura_Champion` | +20% Magic Resistance | Azura's twilight wards your steps. Boon: Magic resistance +20%. |
| `PDV_Bless_Daedric_Azura_Devoted` | +15% Magic Resistance | Azura's twilight wards your steps. Boon: Magic resistance +15%. |
| `PDV_Bless_Daedric_Azura_Seeker` | +10% Magic Resistance | Azura's twilight wards your steps. Boon: Magic resistance +10%. |
| `PDV_Bless_Daedric_Boethiah_Champion` | +20 One-Handed | Boethiah rewards open challenge. Boon: One-Handed +20. |
| `PDV_Bless_Daedric_Boethiah_Devoted` | +15 One-Handed | Boethiah rewards open challenge. Boon: One-Handed +15. |
| `PDV_Bless_Daedric_Boethiah_Seeker` | +10 One-Handed | Boethiah rewards open challenge. Boon: One-Handed +10. |
| `PDV_Bless_Daedric_Dagon_Champion` | +12 AttackDamageMult | Dagon's ruin makes every strike hit harder. Boon: Attack damage +12%. |
| `PDV_Bless_Daedric_Dagon_Devoted` | +8 AttackDamageMult | Dagon's ruin makes every strike hit harder. Boon: Attack damage +8%. |
| `PDV_Bless_Daedric_Dagon_Seeker` | +5 AttackDamageMult | Dagon's ruin makes every strike hit harder. Boon: Attack damage +5%. |
| `PDV_Bless_Daedric_Hircine_Champion` | +50 Stamina | Hircine's hunt-sense drives the chase. Boon: Fortify Stamina +50. |
| `PDV_Bless_Daedric_Hircine_Devoted` | +40 Stamina | Hircine's hunt-sense drives the chase. Boon: Fortify Stamina +40. |
| `PDV_Bless_Daedric_Hircine_Seeker` | +25 Stamina | Hircine's hunt-sense drives the chase. Boon: Fortify Stamina +25. |
| `PDV_Bless_Daedric_Malacath_Champion` | +20% Armor Rating | Malacath hardens the outcast against the blow. Boon: Armor rating +20. |
| `PDV_Bless_Daedric_Malacath_Devoted` | +15% Armor Rating | Malacath hardens the outcast against the blow. Boon: Armor rating +15. |
| `PDV_Bless_Daedric_Malacath_Seeker` | +10% Armor Rating | Malacath hardens the outcast against the blow. Boon: Armor rating +10. |
| `PDV_Bless_Daedric_Mephala_Champion` | +20 Sneak | Mephala spins hidden paths through the web. Boon: Sneak +20. |
| `PDV_Bless_Daedric_Mephala_Devoted` | +15 Sneak | Mephala spins hidden paths through the web. Boon: Sneak +15. |
| `PDV_Bless_Daedric_Mephala_Seeker` | +10 Sneak | Mephala spins hidden paths through the web. Boon: Sneak +10. |
| `PDV_Bless_Daedric_Meridia_Champion` | +20 Restoration | Meridia's light steadies your hand against corruption. Boon: Restoration +20. |
| `PDV_Bless_Daedric_Meridia_Devoted` | +15 Restoration | Meridia's light steadies your hand against corruption. Boon: Restoration +15. |
| `PDV_Bless_Daedric_Meridia_Seeker` | +10 Restoration | Meridia's light steadies your hand against corruption. Boon: Restoration +10. |
| `PDV_Bless_Daedric_Molag_Champion` | +20 Illusion | Molag Bal's domination settles into your will. Boon: Illusion +20. |
| `PDV_Bless_Daedric_Molag_Devoted` | +15 Illusion | Molag Bal's domination settles into your will. Boon: Illusion +15. |
| `PDV_Bless_Daedric_Molag_Seeker` | +10 Illusion | Molag Bal's domination settles into your will. Boon: Illusion +10. |
| `PDV_Bless_Daedric_Mora_Champion` | +20 Alteration; +20 Magicka | Mora's archive teaches the shape beneath the spell. Boon: Alteration +20, Fortify Magicka +20. |
| `PDV_Bless_Daedric_Mora_Devoted` | +15 Alteration | Mora's archive teaches the shape beneath the spell. Boon: Alteration +15. |
| `PDV_Bless_Daedric_Mora_Seeker` | +10 Alteration | Mora's archive teaches the shape beneath the spell. Boon: Alteration +10. |
| `PDV_Bless_Daedric_Nocturnal_Champion` | +20 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +20. |
| `PDV_Bless_Daedric_Nocturnal_Devoted` | +15 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +15. |
| `PDV_Bless_Daedric_Nocturnal_Seeker` | +10 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +10. |
| `PDV_Bless_Daedric_Peryite_Champion` | +75% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +75%. |
| `PDV_Bless_Daedric_Peryite_Devoted` | +50% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +50%. |
| `PDV_Bless_Daedric_Peryite_Seeker` | +25% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +25%. |
| `PDV_Bless_Daedric_Sanguine_Champion` | +20 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +20. |
| `PDV_Bless_Daedric_Sanguine_Devoted` | +15 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +15. |
| `PDV_Bless_Daedric_Sanguine_Seeker` | +10 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +10. |
| `PDV_Bless_Daedric_Sheo_Champion` | +50 Magicka | Sheogorath's wrong angle feeds the impossible. Boon: Fortify Magicka +50. |
| `PDV_Bless_Daedric_Sheo_Devoted` | +40 Magicka | Sheogorath's wrong angle feeds the impossible. Boon: Fortify Magicka +40. |
| `PDV_Bless_Daedric_Sheo_Seeker` | +25 Magicka | Sheogorath's wrong angle feeds the impossible. Boon: Fortify Magicka +25. |
| `PDV_Bless_Daedric_Vaermina_Champion` | +20 Illusion | Vaermina opens the dream-path. Boon: Illusion +20. |
| `PDV_Bless_Daedric_Vaermina_Devoted` | +15 Illusion | Vaermina opens the dream-path. Boon: Illusion +15. |
| `PDV_Bless_Daedric_Vaermina_Seeker` | +10 Illusion | Vaermina opens the dream-path. Boon: Illusion +10. |
| `PDV_Bless_Daedric_Vile_Champion` | +75 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +75. |
| `PDV_Bless_Daedric_Vile_Devoted` | +50 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +50. |
| `PDV_Bless_Daedric_Vile_Seeker` | +25 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +25. |
| `PDV_Price_Daedric_Azura_Champion` | -30 Stamina | Azura's foresight leaves the body tired. Price: Fortify Stamina -30. |
| `PDV_Price_Daedric_Azura_Devoted` | -20 Stamina | Azura's foresight leaves the body tired. Price: Fortify Stamina -20. |
| `PDV_Price_Daedric_Azura_Seeker` | -10 Stamina | Azura's foresight leaves the body tired. Price: Fortify Stamina -10. |
| `PDV_Price_Daedric_Boethiah_Champion` | -15 Speech | Boethiah's trials make trust brittle. Price: Speech -15. |
| `PDV_Price_Daedric_Boethiah_Devoted` | -12 Speech | Boethiah's trials make trust brittle. Price: Speech -12. |
| `PDV_Price_Daedric_Boethiah_Seeker` | -8 Speech | Boethiah's trials make trust brittle. Price: Speech -8. |
| `PDV_Price_Daedric_Dagon_Champion` | -15% Armor Rating | Dagon's ruin does not spare your defenses. Price: Armor rating -15. |
| `PDV_Price_Daedric_Dagon_Devoted` | -10% Armor Rating | Dagon's ruin does not spare your defenses. Price: Armor rating -10. |
| `PDV_Price_Daedric_Dagon_Seeker` | -5% Armor Rating | Dagon's ruin does not spare your defenses. Price: Armor rating -5. |
| `PDV_Price_Daedric_Hircine_Champion` | -15 Speech | Hircine's predator mark unsettles civilized company. Price: Speech -15. |
| `PDV_Price_Daedric_Hircine_Devoted` | -12 Speech | Hircine's predator mark unsettles civilized company. Price: Speech -12. |
| `PDV_Price_Daedric_Hircine_Seeker` | -8 Speech | Hircine's predator mark unsettles civilized company. Price: Speech -8. |
| `PDV_Price_Daedric_Malacath_Champion` | -8% Movement Speed | Malacath's code is heavy and absolute. Price: Movement Speed -8%. |
| `PDV_Price_Daedric_Malacath_Devoted` | -5% Movement Speed | Malacath's code is heavy and absolute. Price: Movement Speed -5%. |
| `PDV_Price_Daedric_Malacath_Seeker` | -3% Movement Speed | Malacath's code is heavy and absolute. Price: Movement Speed -3%. |
| `PDV_Price_Daedric_Mephala_Champion` | -15 Speech | Mephala's web stains every honest bond. Price: Speech -15. |
| `PDV_Price_Daedric_Mephala_Devoted` | -12 Speech | Mephala's web stains every honest bond. Price: Speech -12. |
| `PDV_Price_Daedric_Mephala_Seeker` | -8 Speech | Mephala's web stains every honest bond. Price: Speech -8. |
| `PDV_Price_Daedric_Meridia_Champion` | -15 Illusion | Meridia's radiance rejects concealment and compromise. Price: Illusion -15. |
| `PDV_Price_Daedric_Meridia_Devoted` | -12 Illusion | Meridia's radiance rejects concealment and compromise. Price: Illusion -12. |
| `PDV_Price_Daedric_Meridia_Seeker` | -8 Illusion | Meridia's radiance rejects concealment and compromise. Price: Illusion -8. |
| `PDV_Price_Daedric_Molag_Champion` | -15 Restoration | Molag Bal's domination leaves mercy and restoration behind. Price: Restoration -15. |
| `PDV_Price_Daedric_Molag_Devoted` | -12 Restoration | Molag Bal's domination leaves mercy and restoration behind. Price: Restoration -12. |
| `PDV_Price_Daedric_Molag_Seeker` | -8 Restoration | Molag Bal's domination leaves mercy and restoration behind. Price: Restoration -8. |
| `PDV_Price_Daedric_Mora_Champion` | -30 Stamina | Mora's archive pulls thought away from the body. Price: Fortify Stamina -30. |
| `PDV_Price_Daedric_Mora_Devoted` | -20 Stamina | Mora's archive pulls thought away from the body. Price: Fortify Stamina -20. |
| `PDV_Price_Daedric_Mora_Seeker` | -10 Stamina | Mora's archive pulls thought away from the body. Price: Fortify Stamina -10. |
| `PDV_Price_Daedric_Namira_Champion` | -15 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -15. |
| `PDV_Price_Daedric_Namira_Devoted` | -12 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -12. |
| `PDV_Price_Daedric_Namira_Seeker` | -8 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -8. |
| `PDV_Price_Daedric_Nocturnal_Champion` | -35 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -35. |
| `PDV_Price_Daedric_Nocturnal_Devoted` | -25 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -25. |
| `PDV_Price_Daedric_Nocturnal_Seeker` | -15 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -15. |
| `PDV_Price_Daedric_Peryite_Champion` | -30 Stamina | Peryite's tasks grind down the body's urgency. Price: Fortify Stamina -30. |
| `PDV_Price_Daedric_Peryite_Devoted` | -20 Stamina | Peryite's tasks grind down the body's urgency. Price: Fortify Stamina -20. |
| `PDV_Price_Daedric_Peryite_Seeker` | -10 Stamina | Peryite's tasks grind down the body's urgency. Price: Fortify Stamina -10. |
| `PDV_Price_Daedric_Sanguine_Champion` | -30 Magicka | Sanguine's revelry dulls disciplined focus. Price: Fortify Magicka -30. |
| `PDV_Price_Daedric_Sanguine_Devoted` | -20 Magicka | Sanguine's revelry dulls disciplined focus. Price: Fortify Magicka -20. |
| `PDV_Price_Daedric_Sanguine_Seeker` | -10 Magicka | Sanguine's revelry dulls disciplined focus. Price: Fortify Magicka -10. |
| `PDV_Price_Daedric_Sheo_Champion` | -15 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -15. |
| `PDV_Price_Daedric_Sheo_Devoted` | -12 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -12. |
| `PDV_Price_Daedric_Sheo_Seeker` | -8 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -8. |
| `PDV_Price_Daedric_Vaermina_Champion` | -20 Health | Vaermina leaves unrest inside sleep. Price: Fortify Health -20. |
| `PDV_Price_Daedric_Vaermina_Devoted` | -15 Health | Vaermina leaves unrest inside sleep. Price: Fortify Health -15. |
| `PDV_Price_Daedric_Vaermina_Seeker` | -8 Health | Vaermina leaves unrest inside sleep. Price: Fortify Health -8. |
| `PDV_Price_Daedric_Vile_Champion` | -30 Magicka | Vile's fine print taxes your reserves. Price: Fortify Magicka -30. |
| `PDV_Price_Daedric_Vile_Devoted` | -20 Magicka | Vile's fine print taxes your reserves. Price: Fortify Magicka -20. |
| `PDV_Price_Daedric_Vile_Seeker` | -10 Magicka | Vile's fine print taxes your reserves. Price: Fortify Magicka -10. |

### PDV_DunmerRewardRecords.spec.json (15)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Dunmer_Azura_T1` | +15 Magicka | Twilight sharpens your sight. Fortify Magicka +15. |
| `PDV_Bless_Dunmer_Azura_T2` | +25 Magicka, +10 Destruction | Azura's foresight guides your destruction to its mark. Fortify Magicka +25, Destruction +10. |
| `PDV_Bless_Dunmer_Azura_T3` | +40 Magicka, +25 Destruction | You see by the twilight Azura keeps, and your destruction strikes true. Fortify Magicka +40, Destruction +25. |
| `PDV_Bless_Dunmer_Boethiah_T1` | +5 One-Handed | Struggle tempers your arm. One-Handed +5. |
| `PDV_Bless_Dunmer_Boethiah_T2` | +13 One-Handed, +30% Armor Rating | The strong prevail by Boethiah's measure. One-Handed +13, Armor +30. |
| `PDV_Bless_Dunmer_Boethiah_T3` | +25 One-Handed, +50% Armor Rating | You have proven your strength to the Prince of Plots. One-Handed +25, Armor +50. |
| `PDV_Bless_Dunmer_Mephala_T1` | +5 Sneak | You learn to move along the unseen threads. Sneak +5. |
| `PDV_Bless_Dunmer_Mephala_T2` | +13 Sneak, +10 Illusion | Secrets and shadow answer to you. Sneak +13, Illusion +10. |
| `PDV_Bless_Dunmer_Mephala_T3` | +25 Sneak, +25 Illusion | The Webspinner's whisper guides your hand. Sneak +25, Illusion +25. |
| `PDV_Bless_Dunmer_Reclamation_T1` | +5% Magic Resistance | The Reclamations keep a steadying ward on you. Magic Resistance +5%. |
| `PDV_Bless_Dunmer_Reclamation_T2` | +8% Magic Resistance, +15 Magicka | The Reclamations hold you close even in exile. Magic Resistance +8%, Fortify Magicka +15. |
| `PDV_Bless_Dunmer_Substrate_Always` | +3% Magic Resistance | The ancestors keep their hand on you across the diaspora. Magic Resistance +3%. |
| `PDV_Bless_Dunmer_Substrate_High` | +20% Magic Resistance | The ancestors are deeply with you even far from the ash. Magic Resistance +20%. |
| `PDV_Bless_Dunmer_Substrate_Mid` | +9% Magic Resistance | The ancestors gather closer at hearth and ash. Magic Resistance +9%. |
| `PDV_SPEL_Neglect_Dunmer` | -10 Magicka (in the matching posture) | The ancestors have fallen silent and cannot reach you. Your Maximum Magicka is reduced by 10 until the connection is restored. |

### PDV_ImperialRewardRecords.spec.json (30)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Imperial_Akatosh_T1` | +15 Magicka | The Dragon God steadies the line of time within you. Fortify Magicka +15. |
| `PDV_Bless_Imperial_Akatosh_T2` | +25 Magicka, +5% Magic Resistance | The Covenant holds. Fortify Magicka +25, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Akatosh_T3` | +40 Magicka, +15% Magic Resistance | You endure as the first Covenant endures. Fortify Magicka +40, Magic Resistance +15%. |
| `PDV_Bless_Imperial_Arkay_T1` | +5% Disease Resistance | The keeper of the cycle wards your flesh. Disease Resistance +5%. |
| `PDV_Bless_Imperial_Arkay_T2` | +15% Disease Resistance, +20 Health | You keep the vigil between life and death. Disease Resistance +15%, Maximum Health +20. |
| `PDV_Bless_Imperial_Arkay_T3` | +27% Disease Resistance, +30 Health | Arkay's ward stands between you and the grave. Disease Resistance +27%, Maximum Health +30. |
| `PDV_Bless_Imperial_Civic_T1` | +10 Health | The Divines regard your shared devotion. Maximum Health +10. |
| `PDV_Bless_Imperial_Civic_T2` | +20 Health, +10% Disease Resistance | The Divines deepen their regard for your shared devotion. Maximum Health +20, Disease Resistance +10%. |
| `PDV_Bless_Imperial_Dibella_T1` | +5 Speech | Grace touches your words. Speech +5. |
| `PDV_Bless_Imperial_Dibella_T2` | +13 Speech, +15 Magicka | Beauty and persuasion answer you. Speech +13, Fortify Magicka +15. |
| `PDV_Bless_Imperial_Dibella_T3` | +25 Speech, +40 Magicka | Dibella's inspiration moves through your words. Speech +25, Fortify Magicka +40. |
| `PDV_Bless_Imperial_Julianos_T1` | +15 Magicka | Wisdom and logic sharpen the mind. Fortify Magicka +15. |
| `PDV_Bless_Imperial_Julianos_T2` | +25 Magicka, +5% Magic Resistance | The God of Wisdom and Logic wards the disciplined mind. Fortify Magicka +25, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Julianos_T3` | +40 Magicka, +15% Magic Resistance | Julianos grants the insight of law and lore. Fortify Magicka +40, Magic Resistance +15%. |
| `PDV_Bless_Imperial_Kynareth_T1` | +15 Stamina | The open air fills your lungs. Fortify Stamina +15. |
| `PDV_Bless_Imperial_Kynareth_T2` | +25 Stamina, +5% Magic Resistance | The Lady of the heavens sustains you. Fortify Stamina +25, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Kynareth_T3` | +40 Stamina, +13% Magic Resistance | Kynareth's sky is open to you. Fortify Stamina +40, Magic Resistance +13%. |
| `PDV_Bless_Imperial_Mara_T1` | +5 Restoration | Mercy comes more readily to your hands. Restoration +5. |
| `PDV_Bless_Imperial_Mara_T2` | +13 Restoration, +5% Magic Resistance | The Mother's mercy mends, and her love wards. Restoration +13, Resist Magic +5%. |
| `PDV_Bless_Imperial_Mara_T3` | +23 Restoration, +15% Magic Resistance | Mara's compassion works through you, mending and warding. Restoration +23, Resist Magic +15%. |
| `PDV_Bless_Imperial_Stendarr_T1` | +5 Block | The God of Mercy steadies your guard. Block +5. |
| `PDV_Bless_Imperial_Stendarr_T2` | +13 Block, +30% Armor Rating | You stand between the weak and harm. Block +13, Armor +30. |
| `PDV_Bless_Imperial_Stendarr_T3` | +25 Block, +50% Armor Rating | Stendarr's bulwark is yours to hold. Block +25, Armor +50. |
| `PDV_Bless_Imperial_Talos_T1` | +15% Armor Rating | Defiance held in secret hardens you. Armor +15. |
| `PDV_Bless_Imperial_Talos_T2` | +30% Armor Rating, +8 One-Handed | Open faith in the Ninth steels your arm. Armor +30, One-Handed +8. |
| `PDV_Bless_Imperial_Talos_T3` | +50% Armor Rating, +20 One-Handed | The Hero-God of Man stands with the faithful. Armor +50, One-Handed +20. |
| `PDV_Bless_Imperial_Zenithar_T1` | +25 Carry Weight | Honest labor lightens your load. Carry Weight +25. |
| `PDV_Bless_Imperial_Zenithar_T2` | +65 Carry Weight, +8 Speech | The God of Work and Commerce favors fair dealing. Carry Weight +65, Speech +8. |
| `PDV_Bless_Imperial_Zenithar_T3` | +120 Carry Weight, +20 Speech | Prosperity follows honest work. Carry Weight +120, Speech +20. |
| `PDV_SPEL_Neglect_Imperial` | -5% Disease Resistance | You have let civic faith lapse. The Divines' ward against sickness thins -- Disease Resistance -5% until you return to public service. The real bite comes only at rupture or curse. |

### PDV_KhajiitRewardRecords.spec.json (19)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Khajiit_Alkosh_T1` | +5% Fire Resistance | The Dragon King's order steadies you. Fire Resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T2` | +13% Fire Resistance, +5% Magic Resistance | You keep the line against chaos. Fire Resistance +13%, Magic Resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T3` | +25% Fire Resistance, +20% Magic Resistance | Alkosh's roar is in your blood. Fire Resistance +25%, Magic Resistance +20%. |
| `PDV_Bless_Khajiit_Azurah_T1` | +15 Magicka | Twilight feeds the mind. Fortify Magicka +15. |
| `PDV_Bless_Khajiit_Azurah_T2` | +25 Magicka, +5% Magic Resistance | The twilight wards you. Fortify Magicka +25, Magic Resistance +5%. |
| `PDV_Bless_Khajiit_Azurah_T3` | +40 Magicka, +15% Magic Resistance | You see by the twilight Azurah keeps. Fortify Magicka +40, Magic Resistance +15%. |
| `PDV_Bless_Khajiit_BaanDar_T1` | +15% Armor Rating | The outsider endures. Armor +15. |
| `PDV_Bless_Khajiit_BaanDar_T2` | +30% Armor Rating, +20 Health | The survivor mends quickly. Armor +30, Maximum Health +20. |
| `PDV_Bless_Khajiit_BaanDar_T3` | +50% Armor Rating, +30 Health, +10 Unarmed Damage | Baan Dar's luck is with you when the odds are not. Armor +50, Maximum Health +30, Unarmed Damage +10. |
| `PDV_Bless_Khajiit_Khenarthi_T1` | +15 Stamina | The open road is kinder to you. Fortify Stamina +15. |
| `PDV_Bless_Khajiit_Khenarthi_T2` | +25 Stamina, +30 Carry Weight | The road-walker bears more and tires less. Fortify Stamina +25, Carry Weight +30. |
| `PDV_Bless_Khajiit_Khenarthi_T3` | +40 Stamina, +80 Carry Weight, +3% Movement Speed | Khenarthi's wind is at your back. Fortify Stamina +40, Carry Weight +80, Movement Speed +3%. |
| `PDV_Bless_Khajiit_Lunar_T1` | +15 Stamina, +15% Disease Resistance | The moons have noticed how you move. Fortify Stamina +15, Disease Resistance +15%. |
| `PDV_Bless_Khajiit_Rajhin_T1` | +5 Sneak | You move as the Purring Liar taught. Sneak +5. |
| `PDV_Bless_Khajiit_Rajhin_T2` | +13 Sneak, +10 Lockpicking | Shadow and lock yield to you. Sneak +13, Lockpicking +10. |
| `PDV_Bless_Khajiit_Rajhin_T3` | +25 Sneak, +25 Lockpicking, +15 Pickpocket, +10 Unarmed Damage | The legend works through your hands. Sneak +25, Lockpicking +25, Pickpocket +15, Unarmed Damage +10. |
| `PDV_Bless_Khajiit_Substrate_Always` | +5% Disease Resistance | The moons keep you hardy. Disease Resistance +5%. |
| `PDV_Bless_Khajiit_Substrate_High` | +25 Stamina, +30% Disease Resistance, +15 Magicka | You are deeply attuned to the Lunar Lattice. Your stamina runs deep, your magicka wells full, and disease finds little purchase. Fortify Stamina +25, Disease Resistance +30%, Fortify Magicka +15. |
| `PDV_SPEL_Neglect_KhajiitLunar` | -10 Stamina (at night) | You have not kept the moons. Your Maximum Stamina is reduced by 10 until you return to the road and the lattice. |

### PDV_NordRewardRecords.spec.json (18)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Nord_Kyne_T1` | +15 Stamina | The storm-mother has noticed how you live. Fortify Stamina +15. |
| `PDV_Bless_Nord_Kyne_T2` | +25 Stamina, +10% Frost Resistance | The open sky steadies you against the cold. Fortify Stamina +25, Frost Resistance +10%. |
| `PDV_Bless_Nord_Kyne_T3` | +40 Stamina, +25% Frost Resistance | Kyne's breath is in the wind at your back. Fortify Stamina +40, Frost Resistance +25%. |
| `PDV_Bless_Nord_OldWays_T1` | +15 Stamina | The old roads and weather are companionable to you. Fortify Stamina +15. |
| `PDV_Bless_Nord_OldWays_T2` | +25 Stamina, +10% Frost Resistance | Skyrim itself looks after the faithful. Fortify Stamina +25, Frost Resistance +10%. |
| `PDV_Bless_Nord_Shor_T1` | +10 Health | The hero-god of Sovngarde marks your valor. Maximum Health +10. |
| `PDV_Bless_Nord_Shor_T2` | +20 Health, +8 One-Handed | Shor's hall remembers the brave. Maximum Health +20, One-Handed +8. |
| `PDV_Bless_Nord_Shor_T3` | +30 Health, +18 One-Handed, +10 Two-Handed | Sovngarde looks back on you. Maximum Health +30, One-Handed +18, Two-Handed +10. Once per day, Shor pulls you back from the edge. |
| `PDV_Bless_Nord_Stuhn_T1` | +15% Armor Rating | The shield-thane of just spoils guards you. Armor +15. |
| `PDV_Bless_Nord_Stuhn_T2` | +30% Armor Rating, +8 Block | Honored bonds shield you. Armor +30, Block +8. |
| `PDV_Bless_Nord_Stuhn_T3` | +50% Armor Rating, +18 Block, +8 One-Handed | Stuhn holds the line for the honorable. Armor +50, Block +18, One-Handed +8. |
| `PDV_Bless_Nord_Talos_T1` | +15% Armor Rating | Defiance held in secret hardens you. Armor +15. |
| `PDV_Bless_Nord_Talos_T2` | +30% Armor Rating, +8 One-Handed | The old faith steels your arm. Armor +30, One-Handed +8. |
| `PDV_Bless_Nord_Talos_T3` | +50% Armor Rating, +20 One-Handed | The Hero-God of Man stands with the faithful. Armor +50, One-Handed +20. |
| `PDV_Bless_Nord_Tsun_T1` | +15 Stamina | The shield-thane of Shor weighs your trials. Fortify Stamina +15. |
| `PDV_Bless_Nord_Tsun_T2` | +25 Stamina, +10 Block | You stand the trials Tsun sets. Fortify Stamina +25, Block +10. |
| `PDV_Bless_Nord_Tsun_T3` | +40 Stamina, +22 Block, +50% Armor Rating | Tsun guards the bridge at your back. Fortify Stamina +40, Block +22, Armor +50. |
| `PDV_SPEL_Neglect_Kyne` | -8% Frost Resistance | The weather no longer feels on your side and the cold bites deeper. Frost Resistance -8% until you return to the open sky and keep Kyne's regard. |

### PDV_OrcRewardRecords.spec.json (16)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Orc_City_T1` | +5 Restoration | You keep the code where no stronghold can see it. Restoration +5. |
| `PDV_Bless_Orc_City_T2` | +13 Restoration, +8 Speech | Dignity held under pressure is its own kind of strength. Restoration +13, Speech +8. |
| `PDV_Bless_Orc_City_T3` | +23 Restoration, +20 Speech, +5 Block, +50% Armor Rating | You built belonging outside the hold and kept the code doing it. Restoration +23, Speech +20, Block +5, Armor +50. |
| `PDV_Bless_Orc_LegionExile_T1` | +5 One-Handed | Discipline carries the code where no kin can. One-Handed +5. |
| `PDV_Bless_Orc_LegionExile_T2` | +13 One-Handed, +8 Block | Service under pressure tempers the arm and the shield. One-Handed +13, Block +8. |
| `PDV_Bless_Orc_LegionExile_T3` | +23 One-Handed, +20 Block, +15 Stamina, +50% Armor Rating | You carried the burden of service and exile and came back unbroken. One-Handed +23, Block +20, Fortify Stamina +15, Armor +50. |
| `PDV_Bless_Orc_Malacath_T1` | +15% Armor Rating | Malacath regards the strong who keep his code. Armor +15. |
| `PDV_Bless_Orc_Malacath_T2` | +30% Armor Rating, +20 Health | The Code-Keeper steadies the faithful. Armor +30, Maximum Health +20. |
| `PDV_Bless_Orc_Stronghold_T1` | +5 Smithing | The forge knows your hands keep the code. Smithing +5. |
| `PDV_Bless_Orc_Stronghold_T2` | +13 Smithing, +8 Heavy Armor | Worthy work and worthy war-gear. Smithing +13, Heavy Armor +8. |
| `PDV_Bless_Orc_Stronghold_T3` | +23 Smithing, +20 Heavy Armor, +50% Armor Rating | The stronghold counts you blood-kin and the forge answers. Smithing +23, Heavy Armor +20, Armor +50. |
| `PDV_SPEL_Neglect_Orc` | -5% Armor Rating | You have not kept Malacath's code. Your guard feels thin; your armor rating drops by 5 until you return to worthy work, service, or kin. |
| `PDV_SPEL_Orc_TrialOfIron_Hammer` | +5 Smithing | You chose the hammer in the Trial of Iron. Smithing rises by 5. |
| `PDV_SPEL_Orc_TrialOfIron_Shield` | +5% Armor Rating | You chose the shield in the Trial of Iron. Armor rises by 5. |
| `PDV_SPEL_Orc_TrialOfIron_Tusk` | +5 Unarmed Damage | You chose the tusk in the Trial of Iron. Unarmed damage rises by 5. |
| `PDV_SPEL_Orc_TrialOfIron_Yoke` | +15 Carry Weight | You chose the yoke in the Trial of Iron. Carry weight rises by 15. |

### PDV_Phase20_RewardRecordContracts.json (1)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Redguard_AncestorSpine_T1` | +3% Magic Resistance | The ancestors keep their hand on your spine across the road. Magic Resistance +3%. |

### PDV_RedguardRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Redguard_AncestorSpine_T2` | +5% Magic Resistance, +30% Armor Rating | The line of ancestors steadies you on the road. Magic Resistance +5%, Armor +30. |
| `PDV_Bless_Redguard_FarShoresToken` | +5% Magic Resistance | You keep a token of the Far Shores close, and pray as Tu'whacca's people do. Your Magic Resistance rises by 5%. |
| `PDV_Bless_Redguard_HoonDing_T1` | +5 One-Handed | When the way must be made, the Make-Way God moves through you. One-Handed +5. |
| `PDV_Bless_Redguard_HoonDing_T2` | +13 One-Handed, +3% Movement Speed | The Make-Way God clears the road ahead of you. One-Handed +13, Movement Speed +3%. |
| `PDV_Bless_Redguard_HoonDing_T3` | +25 One-Handed, +6% Movement Speed | The Make-Way God opens the road. One-Handed +25, Movement Speed +6%. Once per day, HoonDing pulls you back from the edge. |
| `PDV_Bless_Redguard_Leki_T1` | +5 One-Handed | The Lady of Swords steadies your form. One-Handed +5. |
| `PDV_Bless_Redguard_Leki_T2` | +13 One-Handed, +5% Critical Chance | Leki's ataxia lives in your blade. One-Handed +13, Critical Chance +5%. |
| `PDV_Bless_Redguard_Leki_T3` | +25 One-Handed, +13% Critical Chance | The Spirit Sword sings through your hand. One-Handed +25, Critical Chance +13%. |
| `PDV_Bless_Redguard_Tuwhacca_T1` | +5% Magic Resistance | The Tricky God watches over the dead and the living alike. Magic Resistance +5%. |
| `PDV_Bless_Redguard_Tuwhacca_T2` | +10% Magic Resistance | Tu'whacca steadies the soul against death's edge. Magic Resistance +10%, and the kept death-rite restores your health (event-driven, flat restore -- felt under Requiem). |
| `PDV_Bless_Redguard_Tuwhacca_T3` | +20% Magic Resistance | Tu'whacca keeps the way to the Far Shores open for you and yours. Magic Resistance +20%, and the kept death-rite restores your health in full measure (event-driven, flat restore -- felt under Requiem). |
| `PDV_SPEL_Neglect_Redguard` | -3% Magic Resistance | The ancestors feel distant and the road is colder. Your resistance to magic falls 3% until you keep the sect and the death duty again. |
