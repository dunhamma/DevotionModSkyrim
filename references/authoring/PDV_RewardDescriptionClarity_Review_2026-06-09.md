# Reward / Boon / Price Description Clarity - Review (task #16)

**Generated:** 2026-06-09 by `tools/pdv_reward_desc_audit.mjs` (re-run to refresh).
**Status:** REVIEW-READY copy. Not yet authored into records.

Each row keeps the existing thematic `playerFacingText` and appends a literal
mechanical clause so boon/price/reward descriptions reach deity-parity clarity.
All effects are constant (passive ability) -- the clause states the standing
magnitude, not a duration. Approve the wording, then re-author the MGEF/SPEL
`Description` from the `Proposed` column on the Windows box (author tools read
`playerFacingText`; update the spec text there so re-authoring is idempotent).

**Coverage:** 258 records across 12 spec files - **1 need a magnitude clause (ADD)**, 257 already state it (clear).

`ADD` = the description does not state the magnitude and should get the clause.
`clear` = the magnitude already appears in the text (shown for audit; no change needed).

## Worklist - records needing a magnitude clause (ADD)

| EditorID | Effect clause | Proposed description |
| --- | --- | --- |
| `PDV_Bless_Redguard_AncestorSpine_T1` | +3% Attack Speed | The ancestor spine steadies your sect path without making every compromise clean. (Effect: +3% Attack Speed.) |

## Audit - already-clear records (no change needed), by file

### PDV_AltmerRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Altmer_AuriEl_T1` | +5% Magicka Regen | The Dawn steadies you. Magicka Regeneration +5%. |
| `PDV_Bless_Altmer_AuriEl_T2` | +13% Magicka Regen, +6% Magic Resistance | The ancestor-light wards your mind. Magicka Regeneration +13%, Magic Resistance +6%. |
| `PDV_Bless_Altmer_AuriEl_T3` | +25% Magicka Regen, +16% Magic Resistance | You walk the path of return Auri-El first walked. Magicka Regeneration +25%, Magic Resistance +16%. |
| `PDV_Bless_Altmer_Magnus_T1` | +5 Alteration | The architect of magic favors disciplined study. Alteration +5. |
| `PDV_Bless_Altmer_Magnus_T2` | +13 Alteration, +6% Magicka Regen | The structure of the arts opens to you. Alteration +13, Magicka Regeneration +6%. |
| `PDV_Bless_Altmer_Magnus_T3` | +25 Alteration, +15% Magicka Regen | You see through the aperture Magnus left in the world. Alteration +25, Magicka Regeneration +15%. |
| `PDV_Bless_Altmer_Orthodox_T1` | +4% Magicka Regen | You keep to the ancestral order. Magicka Regeneration +4%. |
| `PDV_Bless_Altmer_Orthodox_T2` | +7% Magicka Regen, +5% Magic Resistance | Your coherence holds against a divided world. Magicka Regeneration +7%, Magic Resistance +5%. |
| `PDV_Bless_Altmer_Xarxes_T1` | +5 Restoration | The keeper of records steadies your hand at preservation. Restoration +5. |
| `PDV_Bless_Altmer_Xarxes_T2` | +13 Restoration, +6% Magicka Regen | What is kept is what endures. Restoration +13, Magicka Regeneration +6%. |
| `PDV_Bless_Altmer_Xarxes_T3` | +25 Restoration, +15% Magicka Regen | Your name and works are written into the long ledger. Restoration +25, Magicka Regeneration +15%. |
| `PDV_SPEL_Neglect_Altmer` | -4% Magicka Regen | You have let coherence lapse. Your magicka regenerates 4% more slowly until you return to dawn practice and the ancestral order. |

### PDV_ArgonianRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Argonian_Hist_Signature` | +23% Health Regen, +10% Stamina Regen, +10% Poison Resistance | You carry the marsh within you. Health regenerates 23% faster, stamina returns 10% faster, and your resistance to poison rises 10%. |
| `PDV_Bless_Argonian_Hist_T1` | +5% Health Regen | The Hist keeps a steadying hand on you. Health regenerates 5% faster. |
| `PDV_Bless_Argonian_Hist_T2` | +13% Health Regen, +10% Stamina Regen | The Hist holds you close even in exile. Health regenerates 13% faster and stamina returns 10% faster. |
| `PDV_Bless_Argonian_People_T1` | +25 Carry Weight | The people you chose look out for you. You can carry 25 more weight. |
| `PDV_Bless_Argonian_People_T2` | +25 Carry Weight, +8% Poison Resistance, +5% Health Regen | Your chosen family steadies you. You carry 25 more weight, poison resistance rises 8%, and health regenerates 5% faster. |
| `PDV_Bless_Argonian_People_T3` | +50 Carry Weight, +8% Poison Resistance, +13% Health Regen, +5% Magic Resistance | You are a pillar of the people you gathered. You carry 50 more weight, poison resistance rises 8%, health regenerates 13% faster, and magic finds less purchase (5%). |
| `PDV_Bless_Argonian_Sithis_T1` | +4 Sneak | Having faced the Void, you move a little quieter. Sneak +4. |
| `PDV_Bless_Argonian_Sithis_T2` | +10 Sneak, +5% Poison Resistance, +10 Unarmed Damage | The Void has marked your passing. Sneak +10, poison resistance rises 5%, and your bare strikes carry the Void's weight (+10 unarmed). |
| `PDV_Bless_Argonian_Substrate_Always` | +5% Magic Resistance | The Hist remembers you across the distance. Your resistance to magic rises by 5%. |
| `PDV_Bless_Argonian_Substrate_High` | +5% Magic Resistance, +15% Health Regen (near water), +22% Poison Resistance, +12 Unarmed Damage | You are deeply attuned to the Hist even far from the marsh. Magic finds little purchase (5%), your health mends quickly (15%), poison fails (22%), and your claws carry the marsh's strength (+12 unarmed). |
| `PDV_Bless_Argonian_Substrate_Mid` | +5% Magic Resistance, +6% Health Regen (near water), +10% Poison Resistance | The Hist reaches a little closer. Magic finds less purchase (5%), your health regenerates 6% faster, and your resistance to poison rises 10%. |
| `PDV_SPEL_Neglect_ArgonianHist` | -5% Health Regen (in the matching posture) | The Hist has grown distant and cannot reach you. Your health regenerates 5% more slowly until the connection is restored. |

### PDV_BosmerRewardRecords.spec.json (15)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Bosmer_BanditRoad_T1` | +5% Armor Rating | The road toughens the pariah. Armor +5. |
| `PDV_Bless_Bosmer_BanditRoad_T2` | +15% Armor Rating, +10% Health Regen | The outsider survives what should have ended them. Armor +15, Health Regeneration +10%. |
| `PDV_Bless_Bosmer_BanditRoad_T3` | +27% Armor Rating, +25% Health Regen, +10 Sneak | Baan Dar's luck holds when the odds say it should not. Armor +27, Health Regeneration +25%, Sneak +10. |
| `PDV_Bless_Bosmer_Exchange_T1` | +5 Speech | Z'en steadies fair dealing after a debt is settled. Speech +5. |
| `PDV_Bless_Bosmer_Exchange_T2` | +13 Speech, +30 Carry Weight | Z'en weighs what is owed and what is carried. Speech +13, Carry Weight +30. |
| `PDV_Bless_Bosmer_Exchange_T3` | +25 Speech, +80 Carry Weight, +8% Armor Rating | Z'en keeps the ledger of toil and redress with you. Speech +25, Carry Weight +80, Armor +8. |
| `PDV_Bless_Bosmer_LivingStory_T1` | +5 Speech | The story you carry opens doors. Speech +5. |
| `PDV_Bless_Bosmer_LivingStory_T2` | +13 Speech, +10% Health Regen | Community and memory keep you whole. Speech +13, Health Regeneration +10%. |
| `PDV_Bless_Bosmer_LivingStory_T3` | +25 Speech, +25% Health Regen, +5% Magicka Regen | You are a story Y'ffre still tells. Speech +25, Health Regeneration +25%, Magicka Regeneration +5%. |
| `PDV_Bless_Bosmer_OldContract_T1` | +5 Archery | The proper hunt sharpens your eye. Archery +5. |
| `PDV_Bless_Bosmer_OldContract_T2` | +13 Archery, +10 Sneak | Forest-kept and proper, you pass unseen and strike true. Archery +13, Sneak +10. |
| `PDV_Bless_Bosmer_OldContract_T3` | +25 Archery, +22 Sneak, +10% Poison Resistance | You keep the Old Contract as the first Bosmer kept it. Archery +25, Sneak +22, Poison Resistance +10%. |
| `PDV_Bless_Bosmer_Yffre_T1` | +4% Stamina Regen | The forest's story carries you a little. Stamina Regeneration +4%. |
| `PDV_Bless_Bosmer_Yffre_T2` | +6% Stamina Regen, +8 Sneak | You move with the forest's grain. Stamina Regeneration +6%, Sneak +8. |
| `PDV_SPEL_Neglect_Bosmer` | -5% Stamina Regen | Your path no longer answers. Stamina regenerates 5% more slowly until you walk it again. |

### PDV_BretonRewardRecords.spec.json (16)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Breton_GreenWay_T1` | +4% Stamina Regen | The rites keep you close to the land. Stamina Regeneration +4%. |
| `PDV_Bless_Breton_GreenWay_T2` | +11% Stamina Regen, +8 Restoration | The standing stones and outdoor rites answer you. Stamina Regeneration +11%, Restoration +8. |
| `PDV_Bless_Breton_GreenWay_T3` | +21% Stamina Regen, +18 Restoration, +10% Health Regen | The covenant of the wild is kept in you. Stamina Regeneration +21%, Restoration +18, Health Regeneration +10%. |
| `PDV_Bless_Breton_HiddenArt_T1` | +6 Conjuration | The cover holds and the art answers. Conjuration +6. |
| `PDV_Bless_Breton_HiddenArt_T2` | +15 Conjuration, +9 Illusion | The occult work runs deeper. Conjuration +15, Illusion +9. |
| `PDV_Bless_Breton_HiddenArt_T3` | +27 Conjuration, +21 Illusion, +8% Magicka Regen | The art is yours, and the cover is your burden. Conjuration +27, Illusion +21, Magicka Regeneration +8%. |
| `PDV_Bless_Breton_KnightsRoad_T1` | +5 Block | The vow steadies your guard. Block +5. |
| `PDV_Bless_Breton_KnightsRoad_T2` | +13 Block, +8 Restoration | You stand between the weak and harm. Block +13, Restoration +8. |
| `PDV_Bless_Breton_KnightsRoad_T3` | +25 Block, +18 Restoration, +10% Armor Rating | The vow is your bulwark. Block +25, Restoration +18, Armor +10. |
| `PDV_Bless_Breton_Tradition_T1` | +4% Health Regen | Your chosen tradition steadies you. Health Regeneration +4%. |
| `PDV_Bless_Breton_Tradition_T2` | +6% Health Regen, +5% Magic Resistance | A Breton kept by tradition is well-warded. Health Regeneration +6%, Magic Resistance +5%. |
| `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` | -8% Stamina Regen, -8 Restoration | You turned from the covenant. The wild no longer keeps you as it did. Stamina Regeneration -8%, Restoration -8. |
| `PDV_SPEL_CreedLoss_Breton_Excommunication` | -8% Health Regen | The tradition has cast you out. Its keeping is withdrawn until you earn your way back. Health Regeneration -8%. |
| `PDV_SPEL_CreedLoss_Breton_ExposureRupture` | -8 Conjuration, -8 Illusion | Your cover is blown. The hidden art turns against you until the rupture is answered. Conjuration -8, Illusion -8. |
| `PDV_SPEL_CreedLoss_Breton_VowIntegrity` | -5 Block, -5 Restoration | You broke the vow. Block and Restoration falter until the vow is repaired. Block -5, Restoration -5. |
| `PDV_SPEL_Neglect_Breton` | -5% Health Regen | You have let your chosen tradition lapse. Your health regenerates 5% more slowly until you return to it. |

### PDV_DaedricPrinceRecordContracts.json (96)

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
| `PDV_Bless_Daedric_Hircine_Champion` | +20% Stamina Regen | Hircine's hunt-sense drives the chase. Boon: Stamina regeneration +20%. |
| `PDV_Bless_Daedric_Hircine_Devoted` | +15% Stamina Regen | Hircine's hunt-sense drives the chase. Boon: Stamina regeneration +15%. |
| `PDV_Bless_Daedric_Hircine_Seeker` | +10% Stamina Regen | Hircine's hunt-sense drives the chase. Boon: Stamina regeneration +10%. |
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
| `PDV_Bless_Daedric_Mora_Champion` | +20 Alteration | Mora's archive teaches the shape beneath the spell. Boon: Alteration +20. |
| `PDV_Bless_Daedric_Mora_Devoted` | +15 Alteration | Mora's archive teaches the shape beneath the spell. Boon: Alteration +15. |
| `PDV_Bless_Daedric_Mora_Seeker` | +10 Alteration | Mora's archive teaches the shape beneath the spell. Boon: Alteration +10. |
| `PDV_Bless_Daedric_Namira_Champion` | +20% Health Regen | Namira's reviled hunger sustains you. Boon: Health regeneration +20%. |
| `PDV_Bless_Daedric_Namira_Devoted` | +15% Health Regen | Namira's reviled hunger sustains you. Boon: Health regeneration +15%. |
| `PDV_Bless_Daedric_Namira_Seeker` | +10% Health Regen | Namira's reviled hunger sustains you. Boon: Health regeneration +10%. |
| `PDV_Bless_Daedric_Nocturnal_Champion` | +20 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +20. |
| `PDV_Bless_Daedric_Nocturnal_Devoted` | +15 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +15. |
| `PDV_Bless_Daedric_Nocturnal_Seeker` | +10 Lockpicking | Nocturnal's shadow opens what should stay closed. Boon: Lockpicking +10. |
| `PDV_Bless_Daedric_Peryite_Champion` | +75% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +75%. |
| `PDV_Bless_Daedric_Peryite_Devoted` | +50% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +50%. |
| `PDV_Bless_Daedric_Peryite_Seeker` | +25% Disease Resistance | Peryite's low order makes affliction easier to endure. Boon: Disease resistance +25%. |
| `PDV_Bless_Daedric_Sanguine_Champion` | +20 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +20. |
| `PDV_Bless_Daedric_Sanguine_Devoted` | +15 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +15. |
| `PDV_Bless_Daedric_Sanguine_Seeker` | +10 Speech | Sanguine makes excess easy to carry into the room. Boon: Speech +10. |
| `PDV_Bless_Daedric_Sheo_Champion` | +20% Magicka Regen | Sheogorath's wrong angle feeds the impossible. Boon: Magicka regeneration +20%. |
| `PDV_Bless_Daedric_Sheo_Devoted` | +15% Magicka Regen | Sheogorath's wrong angle feeds the impossible. Boon: Magicka regeneration +15%. |
| `PDV_Bless_Daedric_Sheo_Seeker` | +10% Magicka Regen | Sheogorath's wrong angle feeds the impossible. Boon: Magicka regeneration +10%. |
| `PDV_Bless_Daedric_Vaermina_Champion` | +20 Illusion | Vaermina opens the dream-path. Boon: Illusion +20. |
| `PDV_Bless_Daedric_Vaermina_Devoted` | +15 Illusion | Vaermina opens the dream-path. Boon: Illusion +15. |
| `PDV_Bless_Daedric_Vaermina_Seeker` | +10 Illusion | Vaermina opens the dream-path. Boon: Illusion +10. |
| `PDV_Bless_Daedric_Vile_Champion` | +75 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +75. |
| `PDV_Bless_Daedric_Vile_Devoted` | +50 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +50. |
| `PDV_Bless_Daedric_Vile_Seeker` | +25 Carry Weight | Vile's bargains leave you with more than you should carry. Boon: Carry Weight +25. |
| `PDV_Price_Daedric_Azura_Champion` | -15% Stamina Regen | Azura's foresight leaves the body tired. Price: Stamina regeneration -15%. |
| `PDV_Price_Daedric_Azura_Devoted` | -10% Stamina Regen | Azura's foresight leaves the body tired. Price: Stamina regeneration -10%. |
| `PDV_Price_Daedric_Azura_Seeker` | -5% Stamina Regen | Azura's foresight leaves the body tired. Price: Stamina regeneration -5%. |
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
| `PDV_Price_Daedric_Mora_Champion` | -15% Stamina Regen | Mora's archive pulls thought away from the body. Price: Stamina regeneration -15%. |
| `PDV_Price_Daedric_Mora_Devoted` | -10% Stamina Regen | Mora's archive pulls thought away from the body. Price: Stamina regeneration -10%. |
| `PDV_Price_Daedric_Mora_Seeker` | -5% Stamina Regen | Mora's archive pulls thought away from the body. Price: Stamina regeneration -5%. |
| `PDV_Price_Daedric_Namira_Champion` | -15 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -15. |
| `PDV_Price_Daedric_Namira_Devoted` | -12 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -12. |
| `PDV_Price_Daedric_Namira_Seeker` | -8 Speech | Namira's fellowship marks you as repellent to the respectable. Price: Speech -8. |
| `PDV_Price_Daedric_Nocturnal_Champion` | -35 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -35. |
| `PDV_Price_Daedric_Nocturnal_Devoted` | -25 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -25. |
| `PDV_Price_Daedric_Nocturnal_Seeker` | -15 Carry Weight | Nocturnal's oath keeps its own shadowed debt. Price: Carry Weight -15. |
| `PDV_Price_Daedric_Peryite_Champion` | -15% Stamina Regen | Peryite's tasks grind down the body's urgency. Price: Stamina regeneration -15%. |
| `PDV_Price_Daedric_Peryite_Devoted` | -10% Stamina Regen | Peryite's tasks grind down the body's urgency. Price: Stamina regeneration -10%. |
| `PDV_Price_Daedric_Peryite_Seeker` | -5% Stamina Regen | Peryite's tasks grind down the body's urgency. Price: Stamina regeneration -5%. |
| `PDV_Price_Daedric_Sanguine_Champion` | -15% Magicka Regen | Sanguine's revelry dulls disciplined focus. Price: Magicka regeneration -15%. |
| `PDV_Price_Daedric_Sanguine_Devoted` | -10% Magicka Regen | Sanguine's revelry dulls disciplined focus. Price: Magicka regeneration -10%. |
| `PDV_Price_Daedric_Sanguine_Seeker` | -5% Magicka Regen | Sanguine's revelry dulls disciplined focus. Price: Magicka regeneration -5%. |
| `PDV_Price_Daedric_Sheo_Champion` | -15 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -15. |
| `PDV_Price_Daedric_Sheo_Devoted` | -12 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -12. |
| `PDV_Price_Daedric_Sheo_Seeker` | -8 Restoration | Sheogorath's disruption makes restoration unreliable. Price: Restoration -8. |
| `PDV_Price_Daedric_Vaermina_Champion` | -15% Health Regen | Vaermina leaves unrest inside sleep. Price: Health regeneration -15%. |
| `PDV_Price_Daedric_Vaermina_Devoted` | -10% Health Regen | Vaermina leaves unrest inside sleep. Price: Health regeneration -10%. |
| `PDV_Price_Daedric_Vaermina_Seeker` | -5% Health Regen | Vaermina leaves unrest inside sleep. Price: Health regeneration -5%. |
| `PDV_Price_Daedric_Vile_Champion` | -15% Magicka Regen | Vile's fine print taxes your reserves. Price: Magicka regeneration -15%. |
| `PDV_Price_Daedric_Vile_Devoted` | -10% Magicka Regen | Vile's fine print taxes your reserves. Price: Magicka regeneration -10%. |
| `PDV_Price_Daedric_Vile_Seeker` | -5% Magicka Regen | Vile's fine print taxes your reserves. Price: Magicka regeneration -5%. |

### PDV_DunmerRewardRecords.spec.json (15)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Dunmer_Azura_T1` | +4% Magicka Regen | Twilight sharpens your sight. Magicka Regeneration +4%. |
| `PDV_Bless_Dunmer_Azura_T2` | +11% Magicka Regen, +5% Magic Resistance | Azura's foresight wards your mind. Magicka Regeneration +11%, Magic Resistance +5%. |
| `PDV_Bless_Dunmer_Azura_T3` | +21% Magicka Regen, +15% Magic Resistance | You see by the twilight Azura keeps. Magicka Regeneration +21%, Magic Resistance +15%. |
| `PDV_Bless_Dunmer_Boethiah_T1` | +5 One-Handed | Struggle tempers your arm. One-Handed +5. |
| `PDV_Bless_Dunmer_Boethiah_T2` | +13 One-Handed, +10% Armor Rating | The strong prevail by Boethiah's measure. One-Handed +13, Armor +10. |
| `PDV_Bless_Dunmer_Boethiah_T3` | +25 One-Handed, +25% Armor Rating | You have proven your strength to the Prince of Plots. One-Handed +25, Armor +25. |
| `PDV_Bless_Dunmer_Mephala_T1` | +5 Sneak | You learn to move along the unseen threads. Sneak +5. |
| `PDV_Bless_Dunmer_Mephala_T2` | +13 Sneak, +10 Illusion | Secrets and shadow answer to you. Sneak +13, Illusion +10. |
| `PDV_Bless_Dunmer_Mephala_T3` | +25 Sneak, +25 Illusion | The Webspinner's whisper guides your hand. Sneak +25, Illusion +25. |
| `PDV_Bless_Dunmer_Reclamation_T1` | +5% Magic Resistance | The Reclamations keep a steadying ward on you. Magic Resistance +5%. |
| `PDV_Bless_Dunmer_Reclamation_T2` | +8% Magic Resistance, +5% Magicka Regen | The Reclamations hold you close even in exile. Magic Resistance +8%, Magicka Regeneration +5%. |
| `PDV_Bless_Dunmer_Substrate_Always` | +3% Magic Resistance | The ancestors keep their hand on you across the diaspora. Magic Resistance +3%. |
| `PDV_Bless_Dunmer_Substrate_High` | +21% Magic Resistance, +15% Magicka Regen (at home or a shrine), +5% Health Regen (at home or a shrine) | The ancestors are deeply with you even far from the ash. At home or shrine your magicka and health mend faster, and magic finds little purchase on you. Magic Resistance +21%, Magicka Regeneration +15%, Health Regeneration +5%. |
| `PDV_Bless_Dunmer_Substrate_Mid` | +9% Magic Resistance, +6% Magicka Regen (at home or a shrine) | The ancestors gather closer at hearth and ash. Magic Resistance +9%, Magicka Regeneration +6%. |
| `PDV_SPEL_Neglect_Dunmer` | -5% Magicka Regen (in the matching posture) | The ancestors have fallen silent and cannot reach you. Your magicka regenerates 5% more slowly until the connection is restored. |

### PDV_ImperialRewardRecords.spec.json (30)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Imperial_Akatosh_T1` | +4% Magicka Regen | The Dragon God steadies the line of time within you. Magicka Regeneration +4%. |
| `PDV_Bless_Imperial_Akatosh_T2` | +11% Magicka Regen, +5% Magic Resistance | The Covenant holds. Magicka Regeneration +11%, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Akatosh_T3` | +21% Magicka Regen, +15% Magic Resistance | You endure as the first Covenant endures. Magicka Regeneration +21%, Magic Resistance +15%. |
| `PDV_Bless_Imperial_Arkay_T1` | +5% Disease Resistance | The keeper of the cycle wards your flesh. Disease Resistance +5%. |
| `PDV_Bless_Imperial_Arkay_T2` | +15% Disease Resistance, +7% Health Regen | You keep the vigil between life and death. Disease Resistance +15%, Health Regeneration +7%. |
| `PDV_Bless_Imperial_Arkay_T3` | +27% Disease Resistance, +17% Health Regen | Arkay's ward stands between you and the grave. Disease Resistance +27%, Health Regeneration +17%. |
| `PDV_Bless_Imperial_Civic_T1` | +4% Health Regen | The Nine note your civic faith. Health Regeneration +4%. |
| `PDV_Bless_Imperial_Civic_T2` | +7% Health Regen, +10% Disease Resistance | A faithful citizen of the Empire is well-kept. Health Regeneration +7%, Disease Resistance +10%. |
| `PDV_Bless_Imperial_Dibella_T1` | +5 Speech | Grace touches your words. Speech +5. |
| `PDV_Bless_Imperial_Dibella_T2` | +13 Speech, +5% Magicka Regen | Beauty and persuasion answer you. Speech +13, Magicka Regeneration +5%. |
| `PDV_Bless_Imperial_Dibella_T3` | +25 Speech, +13% Magicka Regen | Dibella's inspiration moves through your words. Speech +25, Magicka Regeneration +13%. |
| `PDV_Bless_Imperial_Julianos_T1` | +4% Magicka Regen | Wisdom and logic sharpen the mind. Magicka Regeneration +4%. |
| `PDV_Bless_Imperial_Julianos_T2` | +11% Magicka Regen, +5% Magic Resistance | The God of Wisdom and Logic wards the disciplined mind. Magicka Regeneration +11%, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Julianos_T3` | +21% Magicka Regen, +15% Magic Resistance | Julianos grants the insight of law and lore. Magicka Regeneration +21%, Magic Resistance +15%. |
| `PDV_Bless_Imperial_Kynareth_T1` | +4% Stamina Regen | The open air fills your lungs. Stamina Regeneration +4%. |
| `PDV_Bless_Imperial_Kynareth_T2` | +11% Stamina Regen, +5% Magic Resistance | The Lady of the heavens sustains you. Stamina Regeneration +11%, Magic Resistance +5%. |
| `PDV_Bless_Imperial_Kynareth_T3` | +21% Stamina Regen, +13% Magic Resistance | Kynareth's sky is open to you. Stamina Regeneration +21%, Magic Resistance +13%. |
| `PDV_Bless_Imperial_Mara_T1` | +5 Restoration | Mercy comes more readily to your hands. Restoration +5. |
| `PDV_Bless_Imperial_Mara_T2` | +13 Restoration, +7% Health Regen | The Mother's mercy mends. Restoration +13, Health Regeneration +7%. |
| `PDV_Bless_Imperial_Mara_T3` | +23 Restoration, +19% Health Regen | Mara's compassion works through you. Restoration +23, Health Regeneration +19%. |
| `PDV_Bless_Imperial_Stendarr_T1` | +5 Block | The God of Mercy steadies your guard. Block +5. |
| `PDV_Bless_Imperial_Stendarr_T2` | +13 Block, +10% Armor Rating | You stand between the weak and harm. Block +13, Armor +10. |
| `PDV_Bless_Imperial_Stendarr_T3` | +25 Block, +25% Armor Rating | Stendarr's bulwark is yours to hold. Block +25, Armor +25. |
| `PDV_Bless_Imperial_Talos_T1` | +5% Armor Rating | Defiance held in secret hardens you. Armor +5. |
| `PDV_Bless_Imperial_Talos_T2` | +15% Armor Rating, +8 One-Handed | Open faith in the Ninth steels your arm. Armor +15, One-Handed +8. |
| `PDV_Bless_Imperial_Talos_T3` | +27% Armor Rating, +20 One-Handed | The Hero-God of Man stands with the faithful. Armor +27, One-Handed +20. |
| `PDV_Bless_Imperial_Zenithar_T1` | +25 Carry Weight | Honest labor lightens your load. Carry Weight +25. |
| `PDV_Bless_Imperial_Zenithar_T2` | +65 Carry Weight, +8 Speech | The God of Work and Commerce favors fair dealing. Carry Weight +65, Speech +8. |
| `PDV_Bless_Imperial_Zenithar_T3` | +120 Carry Weight, +20 Speech | Prosperity follows honest work. Carry Weight +120, Speech +20. |
| `PDV_SPEL_Neglect_Imperial` | -5% Health Regen | You have let civic faith lapse. Your health regenerates 5% more slowly until you return to public service and the Divines. The real bite comes only at rupture or curse. |

### PDV_KhajiitRewardRecords.spec.json (19)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Khajiit_Alkosh_T1` | +5% Fire Resistance | The Dragon King's order steadies you. Fire Resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T2` | +13% Fire Resistance, +5% Magic Resistance | You keep the line against chaos. Fire Resistance +13%, Magic Resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T3` | +25% Fire Resistance, +20% Magic Resistance | Alkosh's roar is in your blood. Fire Resistance +25%, Magic Resistance +20%. |
| `PDV_Bless_Khajiit_Azurah_T1` | +4% Magicka Regen | Twilight feeds the mind. Magicka Regeneration +4%. |
| `PDV_Bless_Khajiit_Azurah_T2` | +11% Magicka Regen, +5% Magic Resistance | The twilight wards you. Magicka Regeneration +11%, Magic Resistance +5%. |
| `PDV_Bless_Khajiit_Azurah_T3` | +21% Magicka Regen, +15% Magic Resistance | You see by the twilight Azurah keeps. Magicka Regeneration +21%, Magic Resistance +15%. |
| `PDV_Bless_Khajiit_BaanDar_T1` | +5% Armor Rating | The outsider endures. Armor +5. |
| `PDV_Bless_Khajiit_BaanDar_T2` | +15% Armor Rating, +10% Health Regen | The survivor mends quickly. Armor +15, Health Regeneration +10%. |
| `PDV_Bless_Khajiit_BaanDar_T3` | +30% Armor Rating, +25% Health Regen, +10 Unarmed Damage | Baan Dar's luck is with you when the odds are not. Armor +30, Health Regeneration +25%, Unarmed Damage +10. |
| `PDV_Bless_Khajiit_Khenarthi_T1` | +4% Stamina Regen | The open road is kinder to you. Stamina Regeneration +4%. |
| `PDV_Bless_Khajiit_Khenarthi_T2` | +11% Stamina Regen, +30 Carry Weight | The road-walker bears more and tires less. Stamina Regeneration +11%, Carry Weight +30. |
| `PDV_Bless_Khajiit_Khenarthi_T3` | +21% Stamina Regen, +80 Carry Weight, +3% Movement Speed | Khenarthi's wind is at your back. Stamina Regeneration +21%, Carry Weight +80, Movement Speed +3%. |
| `PDV_Bless_Khajiit_Lunar_T1` | +5% Stamina Regen (at night), +15% Disease Resistance (at night) | The moons have noticed how you move. Stamina Regeneration +5% (at night), Disease Resistance +15% (at night). |
| `PDV_Bless_Khajiit_Rajhin_T1` | +5 Sneak | You move as the Purring Liar taught. Sneak +5. |
| `PDV_Bless_Khajiit_Rajhin_T2` | +13 Sneak, +10 Lockpicking | Shadow and lock yield to you. Sneak +13, Lockpicking +10. |
| `PDV_Bless_Khajiit_Rajhin_T3` | +25 Sneak, +25 Lockpicking, +15 Pickpocket, +10 Unarmed Damage | The legend works through your hands. Sneak +25, Lockpicking +25, Pickpocket +15, Unarmed Damage +10. |
| `PDV_Bless_Khajiit_Substrate_Always` | +5% Disease Resistance | The moons keep you hardy. Disease Resistance +5%. |
| `PDV_Bless_Khajiit_Substrate_High` | +13% Stamina Regen (at night), +30% Disease Resistance (at night), +5% Magicka Regen (at night) | You are deeply attuned to the Lunar Lattice. At night your stamina and magicka regenerate faster and disease finds little purchase. Stamina Regeneration +13% (at night), Disease Resistance +30% (at night), Magicka Regeneration +5% (at night). |
| `PDV_SPEL_Neglect_KhajiitLunar` | -5% Stamina Regen (at night) | You have not kept the moons. At night your stamina regenerates 5% more slowly until you return to the road and the lattice. |

### PDV_NordRewardRecords.spec.json (18)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Nord_Kyne_T1` | +5% Stamina Regen | The storm-mother has noticed how you live. Stamina Regeneration +5%. |
| `PDV_Bless_Nord_Kyne_T2` | +13% Stamina Regen, +10% Frost Resistance | The open sky steadies you against the cold. Stamina Regeneration +13%, Frost Resistance +10%. |
| `PDV_Bless_Nord_Kyne_T3` | +23% Stamina Regen, +25% Frost Resistance | Kyne's breath is in the wind at your back. Stamina Regeneration +23%, Frost Resistance +25%. |
| `PDV_Bless_Nord_OldWays_T1` | +4% Stamina Regen | The old roads and weather are companionable to you. Stamina Regeneration +4%. |
| `PDV_Bless_Nord_OldWays_T2` | +6% Stamina Regen, +10% Frost Resistance | Skyrim itself looks after the faithful. Stamina Regeneration +6%, Frost Resistance +10%. |
| `PDV_Bless_Nord_Shor_T1` | +5% Health Regen | The hero-god of Sovngarde marks your valor. Health Regeneration +5%. |
| `PDV_Bless_Nord_Shor_T2` | +15% Health Regen, +8 One-Handed | Shor's hall remembers the brave. Health Regeneration +15%, One-Handed +8. |
| `PDV_Bless_Nord_Shor_T3` | +27% Health Regen, +18 One-Handed, +10 Two-Handed | Sovngarde looks back on you. Health Regeneration +27%, One-Handed +18, Two-Handed +10. |
| `PDV_Bless_Nord_Stuhn_T1` | +5% Armor Rating | The shield-thane of just spoils guards you. Armor +5. |
| `PDV_Bless_Nord_Stuhn_T2` | +15% Armor Rating, +8 Block | Honored bonds shield you. Armor +15, Block +8. |
| `PDV_Bless_Nord_Stuhn_T3` | +27% Armor Rating, +18 Block, +8 One-Handed | Stuhn holds the line for the honorable. Armor +27, Block +18, One-Handed +8. |
| `PDV_Bless_Nord_Talos_T1` | +5% Armor Rating | Defiance held in secret hardens you. Armor +5. |
| `PDV_Bless_Nord_Talos_T2` | +15% Armor Rating, +8 One-Handed | The old faith steels your arm. Armor +15, One-Handed +8. |
| `PDV_Bless_Nord_Talos_T3` | +27% Armor Rating, +20 One-Handed | The Hero-God of Man stands with the faithful. Armor +27, One-Handed +20. |
| `PDV_Bless_Nord_Tsun_T1` | +5% Stamina Regen | The shield-thane of Shor weighs your trials. Stamina Regeneration +5%. |
| `PDV_Bless_Nord_Tsun_T2` | +13% Stamina Regen, +10 Block | You stand the trials Tsun sets. Stamina Regeneration +13%, Block +10. |
| `PDV_Bless_Nord_Tsun_T3` | +23% Stamina Regen, +22 Block, +10% Armor Rating | Tsun guards the bridge at your back. Stamina Regeneration +23%, Block +22, Armor +10. |
| `PDV_SPEL_Neglect_Kyne` | -5% Stamina Regen | The weather no longer feels on your side. At night your stamina regenerates 5% more slowly until you return to the open sky. |

### PDV_OrcRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Orc_City_T1` | +5 Restoration | You keep the code where no stronghold can see it. Restoration +5. |
| `PDV_Bless_Orc_City_T2` | +13 Restoration, +8 Speech | Dignity held under pressure is its own kind of strength. Restoration +13, Speech +8. |
| `PDV_Bless_Orc_City_T3` | +23 Restoration, +20 Speech, +5 Block | You built belonging outside the hold and kept the code doing it. Restoration +23, Speech +20, Block +5. |
| `PDV_Bless_Orc_LegionExile_T1` | +5 One-Handed | Discipline carries the code where no kin can. One-Handed +5. |
| `PDV_Bless_Orc_LegionExile_T2` | +13 One-Handed, +8 Block | Service under pressure tempers the arm and the shield. One-Handed +13, Block +8. |
| `PDV_Bless_Orc_LegionExile_T3` | +23 One-Handed, +20 Block, +5% Stamina Regen | You carried the burden of service and exile and came back unbroken. One-Handed +23, Block +20, Stamina Regeneration +5%. |
| `PDV_Bless_Orc_Malacath_T1` | +4% Armor Rating | Malacath regards the strong who keep his code. Armor +4. |
| `PDV_Bless_Orc_Malacath_T2` | +6% Armor Rating, +8% Health Regen | The Code-Keeper steadies the faithful. Armor +6, Health Regeneration +8%. |
| `PDV_Bless_Orc_Stronghold_T1` | +5 Smithing | The forge knows your hands keep the code. Smithing +5. |
| `PDV_Bless_Orc_Stronghold_T2` | +13 Smithing, +8 Heavy Armor | Worthy work and worthy war-gear. Smithing +13, Heavy Armor +8. |
| `PDV_Bless_Orc_Stronghold_T3` | +23 Smithing, +20 Heavy Armor, +5% Armor Rating | The stronghold counts you blood-kin and the forge answers. Smithing +23, Heavy Armor +20, Armor +5. |
| `PDV_SPEL_Neglect_Orc` | -5% Armor Rating | You have not kept Malacath's code. Your guard feels thin; your armor rating drops by 5 until you return to worthy work, service, or kin. |

### PDV_RedguardRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Redguard_AncestorSpine_T2` | +5% Magic Resistance, +8% Armor Rating | The line of ancestors steadies you on the road. Magic Resistance +5%, Armor +8. |
| `PDV_Bless_Redguard_FarShoresToken` | +5% Magic Resistance | You keep a token of the Far Shores close, and pray as Tu'whacca's people do. Your Magic Resistance rises by 5%. |
| `PDV_Bless_Redguard_HoonDing_T1` | +5 One-Handed | When the way must be made, the Make-Way God moves through you. One-Handed +5. |
| `PDV_Bless_Redguard_HoonDing_T2` | +13 One-Handed, +3% Movement Speed | The Make-Way God clears the road ahead of you. One-Handed +13, Movement Speed +3%. |
| `PDV_Bless_Redguard_HoonDing_T3` | +25 One-Handed, +6% Movement Speed | Against impossible odds the Make-Way God is with you and the way is made. One-Handed +25, Movement Speed +6%. |
| `PDV_Bless_Redguard_Leki_T1` | +5 One-Handed | The Lady of Swords steadies your form. One-Handed +5. |
| `PDV_Bless_Redguard_Leki_T2` | +13 One-Handed, +5% Critical Chance | Leki's ataxia lives in your blade. One-Handed +13, Critical Chance +5%. |
| `PDV_Bless_Redguard_Leki_T3` | +25 One-Handed, +13% Critical Chance | The Spirit Sword sings through your hand. One-Handed +25, Critical Chance +13%. |
| `PDV_Bless_Redguard_Tuwhacca_T1` | +5% Magic Resistance | The Tricky God watches over the dead and the living alike. Magic Resistance +5%. |
| `PDV_Bless_Redguard_Tuwhacca_T2` | +13% Magic Resistance, +10% Health Regen | Tu'whacca steadies the soul against death's edge. Magic Resistance +13%, Health Regeneration +10%. |
| `PDV_Bless_Redguard_Tuwhacca_T3` | +23% Magic Resistance, +25% Health Regen | Tu'whacca keeps the way to the Far Shores open for you and yours. Magic Resistance +23%, Health Regeneration +25%. |
| `PDV_SPEL_Neglect_Redguard` | -3% Magic Resistance | The ancestors feel distant and the road is colder. Your resistance to magic falls 3% until you keep the sect and the death duty again. |

