# Reward / Boon / Price Description Clarity - Review (task #16)

**Generated:** 2026-06-09 by `tools/pdv_reward_desc_audit.mjs` (re-run to refresh).
**Status:** REVIEW-READY copy. Not yet authored into records.

Each row keeps the existing thematic `playerFacingText` and appends a literal
mechanical clause so boon/price/reward descriptions reach deity-parity clarity.
All effects are constant (passive ability) -- the clause states the standing
magnitude, not a duration. Approve the wording, then re-author the MGEF/SPEL
`Description` from the `Proposed` column on the Windows box (author tools read
`playerFacingText`; update the spec text there so re-authoring is idempotent).

**Coverage:** 258 records across 12 spec files - **107 need a magnitude clause (ADD)**, 151 already state it (clear).

`ADD` = the description does not state the magnitude and should get the clause.
`clear` = the magnitude already appears in the text (shown for audit; no change needed).

## Worklist - records needing a magnitude clause (ADD)

| EditorID | Effect clause | Proposed description |
| --- | --- | --- |
| `PDV_Bless_Argonian_Substrate_High` | +9% Health Regen (near water), +15% Disease Resistance, +15% Poison Resistance | You are deeply attuned to the Hist even far from the marsh. Near water your health mends quickly, and disease and poison find little purchase. (Effect: +9% Health Regen (near water), +15% Disease Resistance, +15% Poison Resistance.) |
| `PDV_Bless_Daedric_Azura_Champion` | +12% Magicka Regen | Azura names you her seer. Foresight holds through the dim hours; what is fated to harm you announces itself, and her star shelters your passage. (Effect: +12% Magicka Regen.) |
| `PDV_Bless_Daedric_Azura_Devoted` | +8% Magicka Regen | Azura's twilight is yours. Crossing thresholds -- doorways, dawns, deaths narrowly escaped -- grants a span of clearer sight and warded steps. (Effect: +8% Magicka Regen.) |
| `PDV_Bless_Daedric_Azura_Seeker` | +5% Magic Resistance | Azura opens the threshold a little. At dawn and dusk your sight sharpens -- a brief foresight that reads danger before it strikes. (Effect: +5% Magic Resistance.) |
| `PDV_Bless_Daedric_Boethiah_Champion` | +12% Armor Rating | Boethiah names you proven. In sustained combat a winning edge builds and holds; overthrowing the strong returns the Prince's full favor. (Effect: +12% Armor Rating.) |
| `PDV_Bless_Daedric_Boethiah_Devoted` | +8% Armor Rating | Boethiah's trial momentum is yours. Felling a significant enemy grants a day of heavier carry weight and stronger power attacks. (Effect: +8% Armor Rating.) |
| `PDV_Bless_Daedric_Boethiah_Seeker` | +5 One-Handed | Boethiah marks the seeker of trials. A kill against a worthy foe sharpens your hand: a brief weapon-damage edge after a hard-won fight. (Effect: +5 One-Handed.) |
| `PDV_Bless_Daedric_Dagon_Champion` | +12 One-Handed | Dagon names you his ruin made walking. What stands is enemy; what is entrenched is target. You are the end that cannot be stopped. (Effect: +12 One-Handed.) |
| `PDV_Bless_Daedric_Dagon_Devoted` | +8 One-Handed | Dagon's ruin deepens in you. Barriers fall faster, fortifications yield, and the things built to last crack first. (Effect: +8 One-Handed.) |
| `PDV_Bless_Daedric_Dagon_Seeker` | +5 Destruction | Dagon's edge settles in you. Your blow against what is entrenched carries extra weight; the wall that should hold breaks first. (Effect: +5 Destruction.) |
| `PDV_Bless_Daedric_Hircine_Champion` | +12 Sneak | You see the whole arc of the hunt -- target, approach, kill, clean territory. Hircine's Champion reads it without effort. (Effect: +12 Sneak.) |
| `PDV_Bless_Daedric_Hircine_Devoted` | +8 Sneak | The hunt runs deeper now. Hircine's predator-edge extends into stamina, and the prey does not slip away. (Effect: +8 Sneak.) |
| `PDV_Bless_Daedric_Hircine_Seeker` | +5% Stamina Regen | Hircine's hunt-sense is in you. Prey announces itself; the predator reads the terrain with new clarity. (Effect: +5% Stamina Regen.) |
| `PDV_Bless_Daedric_Malacath_Champion` | +12 Two-Handed | Malacath names you of the spurned-and-strong. You stand where others fall, your oath is iron, and vengeance for a broken word comes due through your hand. (Effect: +12 Two-Handed.) |
| `PDV_Bless_Daedric_Malacath_Devoted` | +8 Two-Handed | Malacath's endurance is yours. Pain moves you less, and those who break their oath to you, or strike you first, take the cost back doubled. (Effect: +8 Two-Handed.) |
| `PDV_Bless_Daedric_Malacath_Seeker` | +5% Armor Rating | Malacath hardens the outcast. You endure a little more before you break, and a blow struck against you is answered the harder. (Effect: +5% Armor Rating.) |
| `PDV_Bless_Daedric_Mephala_Champion` | +12 Pickpocket | Mephala names you of the web. The network is yours -- leverage over the connected, passage through the closed, and the quiet knowledge of who owes whom. (Effect: +12 Pickpocket.) |
| `PDV_Bless_Daedric_Mephala_Devoted` | +8 Pickpocket | Mephala's web is yours to read. Hidden loyalties and unseen routes reveal themselves; what is whispered in one room reaches you in another. (Effect: +8 Pickpocket.) |
| `PDV_Bless_Daedric_Mephala_Seeker` | +5 Sneak | Mephala spins you a first thread. Secrets find their way to you, and a hidden path opens where others see only wall. (Effect: +5 Sneak.) |
| `PDV_Bless_Daedric_Meridia_Champion` | +12% Disease Resistance | Meridia names you her cleansing blade. You scourge the undead, and the radiance turns corruption aside before it can take hold. (Effect: +12% Disease Resistance.) |
| `PDV_Bless_Daedric_Meridia_Devoted` | +8% Disease Resistance | Meridia's radiance is yours in full. The undead burn before you, and the creeping rot of enchanted corruption struggles against your skin. (Effect: +8% Disease Resistance.) |
| `PDV_Bless_Daedric_Meridia_Seeker` | +5 Restoration | Meridia's light stirs in you. Undead recoil a little more sharply, and corruption finds you harder to take. (Effect: +5 Restoration.) |
| `PDV_Bless_Daedric_Molag_Champion` | +12 Illusion | You carry the full weight of Molag Bal's domination. The hierarchy bends; resistance buckles; the leverage is yours. (Effect: +12 Illusion.) |
| `PDV_Bless_Daedric_Molag_Devoted` | +8 Illusion | The grip deepens. Molag Bal's vampiric authority extends your reach -- the dominated stay dominated. (Effect: +8 Illusion.) |
| `PDV_Bless_Daedric_Molag_Seeker` | +5 Speech | Molag Bal's domination-edge settles in you. Coercive leverage comes more easily; hierarchy bends in your direction. (Effect: +5 Speech.) |
| `PDV_Bless_Daedric_Mora_Champion` | +12% Magicka Regen | Mora names you archivist. Secrets yield; forbidden knowledge is yours; what drives lesser scholars to ruin is a tool in your hands. (Effect: +12% Magicka Regen.) |
| `PDV_Bless_Daedric_Mora_Devoted` | +8% Magicka Regen | Mora's collection deepens in you. Spell insight comes faster, and dangerous texts open their secrets to your study without the usual cost. (Effect: +8% Magicka Regen.) |
| `PDV_Bless_Daedric_Mora_Seeker` | +5 Alteration | Mora's archive opens a corner. You retain more of what you study; knowledge surfaces from texts that should give less. (Effect: +5 Alteration.) |
| `PDV_Bless_Daedric_Namira_Champion` | +12% Health Regen | Namira names you of the outcast faithful. You are the hunger the respectable pretend does not exist; what they revile sustains you. (Effect: +12% Health Regen.) |
| `PDV_Bless_Daedric_Namira_Devoted` | +8% Health Regen | Namira's outcast fellowship deepens. The resilience of one who has nothing to lose is yours; the places that repel others are your domain. (Effect: +8% Health Regen.) |
| `PDV_Bless_Daedric_Namira_Seeker` | +5 Sneak | Namira's darkness settles around you. Revulsion that breaks others steels you; you endure the forgotten places without flinching. (Effect: +5 Sneak.) |
| `PDV_Bless_Daedric_Nocturnal_Champion` | +12 Lockpicking | Nocturnal's debt runs in your favor. Fortune tilts for you in the dark; shadows are allies, and your concealment in them is absolute. (Effect: +12 Lockpicking.) |
| `PDV_Bless_Daedric_Nocturnal_Devoted` | +8 Lockpicking | Nocturnal's shade deepens. Luck favors you more reliably, and in shadows you move as though they expect you. (Effect: +8 Lockpicking.) |
| `PDV_Bless_Daedric_Nocturnal_Seeker` | +5 Sneak | Shadow luck covers you. Small fortunate turns come more often; the unseen paths open a little wider. (Effect: +5 Sneak.) |
| `PDV_Bless_Daedric_Peryite_Champion` | +12% Health Regen | Peryite names you keeper of the lowest order. Affliction barely touches you; the unwanted tasks run efficiently through your hands. (Effect: +12% Health Regen.) |
| `PDV_Bless_Daedric_Peryite_Devoted` | +8% Health Regen | Peryite's imposed order deepens. Disease weakens you less; the tasks you are assigned, however low, run efficiently. (Effect: +8% Health Regen.) |
| `PDV_Bless_Daedric_Peryite_Seeker` | +5% Disease Resistance | Peryite's resilience settles in you. Affliction finds you harder to bring down, and the unpleasant tasks others refuse are simply tasks. (Effect: +5% Disease Resistance.) |
| `PDV_Bless_Daedric_Sanguine_Champion` | +12 Speech | Sanguine names you his own. Excess is your element; the revelry that should end simply continues. (Effect: +12 Speech.) |
| `PDV_Bless_Daedric_Sanguine_Devoted` | +8 Speech | Sanguine's indulgence deepens. You endure revelry where others wilt; temptation has a familiar, comfortable face. (Effect: +8 Speech.) |
| `PDV_Bless_Daedric_Sanguine_Seeker` | +5% Stamina Regen | Sanguine's ease settles in you. Revelry lands lighter; you navigate excess with more grace than before. (Effect: +5% Stamina Regen.) |
| `PDV_Bless_Daedric_Sheo_Champion` | +12% Magicka Regen | Sheogorath names you the Madgod's own. Unpredictability is your ally; the stable is always about to become otherwise. (Effect: +12% Magicka Regen.) |
| `PDV_Bless_Daedric_Sheo_Devoted` | +8% Magicka Regen | Sheogorath's disruption deepens. Chaotic outcomes bend your way; the problem that should not break breaks, the wall that should hold falls. (Effect: +8% Magicka Regen.) |
| `PDV_Bless_Daedric_Sheo_Seeker` | +5 Illusion | Sheogorath's absurdity opens a crack. Where the direct approach fails, something sideways succeeds; solutions arrive from the wrong angle. (Effect: +5 Illusion.) |
| `PDV_Bless_Daedric_Vaermina_Champion` | +12 Sneak | Vaermina names you her nightmare-walker. Sleep is your domain; you read fear with precision, and what haunts others gives you advantage. (Effect: +12 Sneak.) |
| `PDV_Bless_Daedric_Vaermina_Devoted` | +8 Sneak | Vaermina's nightmare deepens. Dream insight comes readily; the fear of others is legible, and you press it where it matters. (Effect: +8 Sneak.) |
| `PDV_Bless_Daedric_Vaermina_Seeker` | +5 Illusion | Vaermina's touch opens the dream-path. Sleep reveals more than it hides; you read fear in others before they know you are reading it. (Effect: +5 Illusion.) |
| `PDV_Bless_Daedric_Vile_Champion` | +12 Carry Weight | Vile names you his preferred client. Favorable terms become your default; loopholes open before you, and the deals bend your direction. (Effect: +12 Carry Weight.) |
| `PDV_Bless_Daedric_Vile_Devoted` | +8 Carry Weight | Vile's contract deepens. Favorable turns come more reliably; the bargain you should not win goes your way. (Effect: +8 Carry Weight.) |
| `PDV_Bless_Daedric_Vile_Seeker` | +5 Speech | Vile's transactional edge is yours. Favorable terms come a little more often; the deal that should fall through somehow does not. (Effect: +5 Speech.) |
| `PDV_Bless_Dunmer_Substrate_High` | +9% Magicka Regen (at home or a shrine), +12% Magic Resistance, +5% Health Regen (at home or a shrine) | The ancestors are deeply with you even far from the ash. At home or shrine your magicka and health mend faster, and magic finds little purchase on you. (Effect: +9% Magicka Regen (at home or a shrine), +12% Magic Resistance, +5% Health Regen (at home or a shrine).) |
| `PDV_Bless_Khajiit_Khenarthi_T3` | +10% Stamina Regen, +50 Carry Weight, +3% Movement Speed | Khenarthi's wind is at your back. Stamina +10%, carry +50, and you move a little faster. (Effect: +10% Stamina Regen, +50 Carry Weight, +3% Movement Speed.) |
| `PDV_Bless_Khajiit_Substrate_High` | +8% Stamina Regen (at night), +15% Disease Resistance (at night), +5% Magicka Regen (at night) | You are deeply attuned to the Lunar Lattice. At night your stamina and magicka regenerate faster and disease finds little purchase. (Effect: +8% Stamina Regen (at night), +15% Disease Resistance (at night), +5% Magicka Regen (at night).) |
| `PDV_Bless_Redguard_AncestorSpine_T1` | +3% Attack Speed | The ancestor spine steadies your sect path without making every compromise clean. (Effect: +3% Attack Speed.) |
| `PDV_Bless_Redguard_HoonDing_T2` | +8 One-Handed, +3% Movement Speed | The Make-Way God clears the road ahead of you. One-Handed +8 and you move a little faster. (Effect: +8 One-Handed, +3% Movement Speed.) |
| `PDV_Bless_Redguard_HoonDing_T3` | +12 One-Handed, +3% Movement Speed | Against impossible odds the Make-Way God is with you and the way is made. One-Handed +12 and you move a little faster. (Effect: +12 One-Handed, +3% Movement Speed.) |
| `PDV_Price_Daedric_Azura_Champion` | -8% Stamina Regen | The full price: you are bound to the prophecy. The sight that protects you also commits you; you serve the pattern Azura reveals, whether or not it serves you. (Effect: -8% Stamina Regen.) |
| `PDV_Price_Daedric_Azura_Devoted` | -5% Stamina Regen | The price deepens: fate obligates. Azura's sight comes with her demands, and the path she shows is not always the one you would choose. (Effect: -5% Stamina Regen.) |
| `PDV_Price_Daedric_Azura_Seeker` | -3% Stamina Regen | The price of foresight: the burden of knowing. Visions intrude unbidden, and what you have seen cannot be unseen. (Effect: -3% Stamina Regen.) |
| `PDV_Price_Daedric_Boethiah_Champion` | -8 Speech | The full price: you are a standing trial. Bonds of loyalty strain hardest now, and few alliances outlast the proving Boethiah demands of all who stand near you. (Effect: -8 Speech.) |
| `PDV_Price_Daedric_Boethiah_Devoted` | -5 Speech | The price deepens: trust frays. Followers and allies are harder to keep, and the world meets your strength with sharper resistance. (Effect: -5 Speech.) |
| `PDV_Price_Daedric_Boethiah_Seeker` | -3 Speech | The price of the pact: conflict gathers around you. Hostile encounters escalate more readily while Boethiah's edge is held. (Effect: -3 Speech.) |
| `PDV_Price_Daedric_Dagon_Champion` | -8% Armor Rating | The full price: you are the principle. Dagon's ruin does not stop when you stop pointing it; you have become the revolution, no off state. (Effect: -8% Armor Rating.) |
| `PDV_Price_Daedric_Dagon_Devoted` | -5% Armor Rating | The price deepens: civic rupture. The communities that held you are part of the order Dagon destroys; the world around you empties. (Effect: -5% Armor Rating.) |
| `PDV_Price_Daedric_Dagon_Seeker` | -3% Armor Rating | The price of the ruin path: escalation. Dagon does not distinguish your order from the enemy's; the destruction begins to include you. (Effect: -3% Armor Rating.) |
| `PDV_Price_Daedric_Hircine_Champion` | -8% Health Regen | The full price: the Huntsman's isolation. The civilian world is an afterthought to the hunt, and the hunt does not make friends. (Effect: -8% Health Regen.) |
| `PDV_Price_Daedric_Hircine_Devoted` | -5% Health Regen | The price deepens: the beast shapes the social register. Others read Hircine's claim and do not find it comfortable. (Effect: -5% Health Regen.) |
| `PDV_Price_Daedric_Hircine_Seeker` | -3% Health Regen | The price of the hunt-path: the predator register. The civilized world senses the beast in you and keeps its distance. (Effect: -3% Health Regen.) |
| `PDV_Price_Daedric_Malacath_Champion` | -8% Movement Speed | The full price: you are the code, and it is merciless. Every oath binds you absolutely; every mercy you would give, Malacath counts as weakness, and the exile he grants is permanent. (Effect: -8% Movement Speed.) |
| `PDV_Price_Daedric_Malacath_Devoted` | -5% Movement Speed | The price deepens: the code burdens. You cannot bend a sworn word without loss, and the world treats the pariah-god's follower as the outsider he is. (Effect: -5% Movement Speed.) |
| `PDV_Price_Daedric_Malacath_Seeker` | -3% Movement Speed | The price of the code: harsh judgment. Malacath holds you to the oath as hard as your enemies, and weakness in yourself is not forgiven. (Effect: -3% Movement Speed.) |
| `PDV_Price_Daedric_Mephala_Champion` | -8 Speech | The full price: you are a knot in the web, not its master. Every bond you hold holds you; the corruption you spread runs back along the threads to you. (Effect: -8 Speech.) |
| `PDV_Price_Daedric_Mephala_Devoted` | -5 Speech | The price deepens: the web demands feeding. Hidden violence and quiet betrayal are its currency, and Mephala's advantage dims if the threads go slack. (Effect: -5 Speech.) |
| `PDV_Price_Daedric_Mephala_Seeker` | -3 Speech | The price of the web: corruption seeps in. The secrets you gather stain the gathering; trust given to you frays a little for the knowing. (Effect: -3 Speech.) |
| `PDV_Price_Daedric_Meridia_Champion` | -8 Illusion | The full price: the mandate is absolute. The undead are enemy, corruption is enemy. Meridia does not negotiate with what must be burned. (Effect: -8 Illusion.) |
| `PDV_Price_Daedric_Meridia_Devoted` | -5 Illusion | The price deepens: intolerance is yours. Meridia presses the war outward; hesitation against the risen finds her regard cooling. (Effect: -5 Illusion.) |
| `PDV_Price_Daedric_Meridia_Seeker` | -3 Illusion | The price of the radiance: purity demanded. Meridia will not tolerate compromise, and her follower acts before rot spreads. (Effect: -3 Illusion.) |
| `PDV_Price_Daedric_Molag_Champion` | -8% Health Regen | The full price: everything mediated through dominance. Molag Bal's Champion relates to others through leverage, and leverage corrodes. (Effect: -8% Health Regen.) |
| `PDV_Price_Daedric_Molag_Devoted` | -5% Health Regen | The price deepens: isolation of the predator. Those who sense Molag Bal's claim keep their distance or their silence. (Effect: -5% Health Regen.) |
| `PDV_Price_Daedric_Molag_Seeker` | -3% Health Regen | The price of the domination-path: the cruelty it asks of you will return. Those you bend do not forget. (Effect: -3% Health Regen.) |
| `PDV_Price_Daedric_Mora_Champion` | -8% Stamina Regen | The full price: the archive owns you. Mora holds what you have learned, and you are catalogued alongside the things you studied. Agency is a recorded entry, not a living condition. (Effect: -8% Stamina Regen.) |
| `PDV_Price_Daedric_Mora_Devoted` | -5% Stamina Regen | The price deepens: agency erodes. Mora's archive pulls; curiosity becomes compulsion, and the questions grow larger than the questioner. (Effect: -5% Stamina Regen.) |
| `PDV_Price_Daedric_Mora_Seeker` | -3% Stamina Regen | The price of the archive: knowledge corrupts. What you learn through Mora changes how you think, and some cannot be unlearned. (Effect: -3% Stamina Regen.) |
| `PDV_Price_Daedric_Namira_Champion` | -8 Speech | The full price: revulsion is your medium. The respectable do not welcome Namira's Champion, and she does not ask them to. (Effect: -8 Speech.) |
| `PDV_Price_Daedric_Namira_Devoted` | -5 Speech | The price deepens: consumption taboo. The hunger Namira feeds takes a shape others find unacceptable, and hiding it grows harder. (Effect: -5 Speech.) |
| `PDV_Price_Daedric_Namira_Seeker` | -3 Speech | The price of the outcast path: social revulsion. Those who accept Namira's follower are few, and they are not the respectable. (Effect: -3 Speech.) |
| `PDV_Price_Daedric_Nocturnal_Champion` | -8 Restoration | The full price: the oath is you now. Nocturnal is patient. She takes her due when the circumstances are right, and the sworn servant always finds it was implied in the terms they accepted. (Effect: -8 Restoration.) |
| `PDV_Price_Daedric_Nocturnal_Devoted` | -5 Restoration | The price deepens: the debt has weight. Luck does not withdraw, but the oath tightens; Nocturnal does not forget, and the shadow does not either. (Effect: -5 Restoration.) |
| `PDV_Price_Daedric_Nocturnal_Seeker` | -3 Restoration | The price of the shadow: the oath binds. What you owe Nocturnal has no stated invoice, only the certainty that it comes due eventually. (Effect: -3 Restoration.) |
| `PDV_Price_Daedric_Peryite_Champion` | -8% Stamina Regen | The full price: you are the lowest-order mechanism. Peryite assigns; you execute; the nature of the assignment is not yours to question. (Effect: -8% Stamina Regen.) |
| `PDV_Price_Daedric_Peryite_Devoted` | -5% Stamina Regen | The price deepens: task-order submission. Peryite assigns; the devotee's judgment yields to it, not ahead of it. (Effect: -5% Stamina Regen.) |
| `PDV_Price_Daedric_Peryite_Seeker` | -3% Stamina Regen | The price of the affliction path: you carry what Peryite assigns, and some assignments are diseases. (Effect: -3% Stamina Regen.) |
| `PDV_Price_Daedric_Sanguine_Champion` | -8% Magicka Regen | The full price: restraint is gone. Sanguine does not ask for it back; indulgence is always the more pressing call now. (Effect: -8% Magicka Regen.) |
| `PDV_Price_Daedric_Sanguine_Devoted` | -5% Magicka Regen | The price deepens: unreliability. The devotee's word runs alongside the evening's plans; sober commitments dissolve. (Effect: -5% Magicka Regen.) |
| `PDV_Price_Daedric_Sanguine_Seeker` | -3% Magicka Regen | The price of the indulgence path: overindulgence. Sanguine does not enforce the limit, and without the limit the morning arrives harder. (Effect: -3% Magicka Regen.) |
| `PDV_Price_Daedric_Sheo_Champion` | -8 Restoration | The full price: you cannot put it down. Sheogorath does not give back stability; the one who carries his full mark has become the disruption they chose, and it moves with them now. (Effect: -8 Restoration.) |
| `PDV_Price_Daedric_Sheo_Devoted` | -5 Restoration | The price deepens: control erodes. The Madgod's touch does not stop at useful chaos; the devotee's own certainties grow unreliable. (Effect: -5 Restoration.) |
| `PDV_Price_Daedric_Sheo_Seeker` | -3 Restoration | The price of the madness path: unpredictability cuts both ways. The disruption does not promise to hit only the targets you choose. (Effect: -3 Restoration.) |
| `PDV_Price_Daedric_Vaermina_Champion` | -8% Health Regen | The full price: fear and memory are hers. You wield fear outward, but Vaermina's access to yours is absolute; nothing you dream is private. (Effect: -8% Health Regen.) |
| `PDV_Price_Daedric_Vaermina_Devoted` | -5% Health Regen | The price deepens: memory instability. Time in Vaermina's nightmare blurs the boundary between what happened and what was shown. (Effect: -5% Health Regen.) |
| `PDV_Price_Daedric_Vaermina_Seeker` | -3% Health Regen | The price of the dream-path: sleep corrupts. Vaermina does not only give you the dream; she leaves herself in it when you sleep. (Effect: -3% Health Regen.) |
| `PDV_Price_Daedric_Vile_Champion` | -8% Magicka Regen | The full price: you are the preferred client, which means Vile takes interest in what you do with the terms. The favors are real. The dependencies they create are also real. (Effect: -8% Magicka Regen.) |
| `PDV_Price_Daedric_Vile_Devoted` | -5% Magicka Regen | The price deepens: exploitative terms. Vile's contracts tighten; the backlash when a deal turns arrives harder than it should. (Effect: -5% Magicka Regen.) |
| `PDV_Price_Daedric_Vile_Seeker` | -3% Magicka Regen | The price of the bargain: Vile's terms have fine print. What you get is real; what it costs is also real, and the invoice arrives later. (Effect: -3% Magicka Regen.) |
| `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` | -8% Stamina Regen, -8 Restoration | You turned from the covenant. The wild no longer keeps you as it did. (Effect: -8% Stamina Regen, -8 Restoration.) |
| `PDV_SPEL_CreedLoss_Breton_Excommunication` | -8% Health Regen | The tradition has cast you out. Its keeping is withdrawn until you earn your way back. (Effect: -8% Health Regen.) |
| `PDV_SPEL_CreedLoss_Breton_ExposureRupture` | -8 Conjuration, -8 Illusion | Your cover is blown. The hidden art turns against you until the rupture is answered. (Effect: -8 Conjuration, -8 Illusion.) |
| `PDV_SPEL_CreedLoss_Breton_VowIntegrity` | -5 Block, -5 Restoration | You broke the vow. Block and Restoration falter until the vow is repaired. (Effect: -5 Block, -5 Restoration.) |

## Audit - already-clear records (no change needed), by file

### PDV_AltmerRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Altmer_AuriEl_T1` | +5% Magicka Regen | The Dawn steadies you. Magicka regenerates 5% faster. |
| `PDV_Bless_Altmer_AuriEl_T2` | +8% Magicka Regen, +6% Magic Resistance | The ancestor-light wards your mind. Magicka regenerates 8% faster and magic resistance rises 6%. |
| `PDV_Bless_Altmer_AuriEl_T3` | +12% Magicka Regen, +10% Magic Resistance | You walk the path of return Auri-El first walked. Magicka regenerates 12% faster and magic resistance rises 10%. |
| `PDV_Bless_Altmer_Magnus_T1` | +5 Alteration | The architect of magic favors disciplined study. Alteration +5. |
| `PDV_Bless_Altmer_Magnus_T2` | +8 Alteration, +6% Magicka Regen | The structure of the arts opens to you. Alteration +8 and magicka regenerates 6% faster. |
| `PDV_Bless_Altmer_Magnus_T3` | +12 Alteration, +9% Magicka Regen | You see through the aperture Magnus left in the world. Alteration +12 and magicka regenerates 9% faster. |
| `PDV_Bless_Altmer_Orthodox_T1` | +4% Magicka Regen | You keep to the ancestral order. Magicka regenerates 4% faster. |
| `PDV_Bless_Altmer_Orthodox_T2` | +7% Magicka Regen, +5% Magic Resistance | Your coherence holds against a divided world. Magicka regenerates 7% faster and magic resistance rises 5%. |
| `PDV_Bless_Altmer_Xarxes_T1` | +5 Restoration | The keeper of records steadies your hand at preservation. Restoration +5. |
| `PDV_Bless_Altmer_Xarxes_T2` | +8 Restoration, +6% Magicka Regen | What is kept is what endures. Restoration +8 and magicka regenerates 6% faster. |
| `PDV_Bless_Altmer_Xarxes_T3` | +12 Restoration, +9% Magicka Regen | Your name and works are written into the long ledger. Restoration +12 and magicka regenerates 9% faster. |
| `PDV_SPEL_Neglect_Altmer` | -4% Magicka Regen | You have let coherence lapse. Your magicka regenerates 4% more slowly until you return to dawn practice and the ancestral order. |

### PDV_ArgonianRewardRecords.spec.json (11)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Argonian_Hist_Signature` | +10% Health Regen, +10% Poison Resistance | You carry the marsh within you. Health regenerates 10% faster and your resistance to poison rises 10%. |
| `PDV_Bless_Argonian_Hist_T1` | +5% Health Regen | The Hist keeps a steadying hand on you. Health regenerates 5% faster. |
| `PDV_Bless_Argonian_Hist_T2` | +8% Health Regen, +8% Disease Resistance | The Hist holds you close even in exile. Health regenerates 8% faster and disease resistance rises 8%. |
| `PDV_Bless_Argonian_People_T1` | +5% Disease Resistance | The people you chose look out for you. Disease resistance rises 5%. |
| `PDV_Bless_Argonian_People_T2` | +8% Disease Resistance, +5% Health Regen | Your chosen family steadies you. Disease resistance rises 8% and health regenerates 5% faster. |
| `PDV_Bless_Argonian_People_T3` | +12% Disease Resistance, +8% Health Regen | You are a pillar of the people you gathered. Disease resistance rises 12% and health regenerates 8% faster. |
| `PDV_Bless_Argonian_Sithis_T1` | +4 Sneak | Having faced the Void, you move a little quieter. Sneak +4. |
| `PDV_Bless_Argonian_Sithis_T2` | +6 Sneak, +5% Poison Resistance, +10 Unarmed Damage | The Void has marked your passing. Sneak +6, poison resistance rises 5%, and your bare strikes carry the Void's weight (+10 unarmed). |
| `PDV_Bless_Argonian_Substrate_Always` | +5% Disease Resistance | The Hist remembers you across the distance. Your resistance to disease rises by 5%. |
| `PDV_Bless_Argonian_Substrate_Mid` | +6% Health Regen (near water), +10% Poison Resistance | The Hist reaches a little closer. Near water or at rest your health regenerates 6% faster, and your resistance to poison rises by 10%. |
| `PDV_SPEL_Neglect_ArgonianHist` | -5% Health Regen (in the matching posture) | The Hist has grown distant and cannot reach you. Your health regenerates 5% more slowly until the connection is restored. |

### PDV_BosmerRewardRecords.spec.json (15)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Bosmer_BanditRoad_T1` | +5% Armor Rating | The road toughens the pariah. Armor rating rises by 5. |
| `PDV_Bless_Bosmer_BanditRoad_T2` | +10% Armor Rating, +10% Health Regen | The outsider survives what should have ended them. Armor +10 and health regenerates 10% faster. |
| `PDV_Bless_Bosmer_BanditRoad_T3` | +12% Armor Rating, +15% Health Regen, +10 Sneak | Baan Dar's luck holds when the odds say it should not. Armor +12, health regenerates 15% faster, and Sneak +10. |
| `PDV_Bless_Bosmer_Exchange_T1` | +5 Speech | Z'en steadies fair dealing after a debt is settled. Speech +5. |
| `PDV_Bless_Bosmer_Exchange_T2` | +13 Speech, +30 Carry Weight | Z'en weighs what is owed and what is carried. Speech +13, Carry Weight +30. |
| `PDV_Bless_Bosmer_Exchange_T3` | +12 Speech, +50 Carry Weight, +8% Armor Rating | Z'en keeps the ledger of toil and redress with you. Speech +12, carry +50, and armor +8. |
| `PDV_Bless_Bosmer_LivingStory_T1` | +5 Speech | The story you carry opens doors. Speech +5. |
| `PDV_Bless_Bosmer_LivingStory_T2` | +8 Speech, +10% Health Regen | Community and memory keep you whole. Speech +8 and health regenerates 10% faster. |
| `PDV_Bless_Bosmer_LivingStory_T3` | +12 Speech, +15% Health Regen, +5% Magicka Regen | You are a story Y'ffre still tells. Speech +12, health regenerates 15% faster, and magicka +5%. |
| `PDV_Bless_Bosmer_OldContract_T1` | +5 Archery | The proper hunt sharpens your eye. Archery +5. |
| `PDV_Bless_Bosmer_OldContract_T2` | +8 Archery, +10 Sneak | Forest-kept and proper, you pass unseen and strike true. Archery +8 and Sneak +10. |
| `PDV_Bless_Bosmer_OldContract_T3` | +12 Archery, +12 Sneak, +10% Poison Resistance | You keep the Old Contract as the first Bosmer kept it. Archery +12, Sneak +12, and poison finds little purchase (+10%). |
| `PDV_Bless_Bosmer_Yffre_T1` | +4% Stamina Regen | The forest's story carries you a little. Stamina regenerates 4% faster. |
| `PDV_Bless_Bosmer_Yffre_T2` | +6% Stamina Regen, +8 Sneak | You move with the forest's grain. Stamina regenerates 6% faster and Sneak +8. |
| `PDV_SPEL_Neglect_Bosmer` | -5% Stamina Regen | Your path no longer answers. Stamina regenerates 5% more slowly until you walk it again. |

### PDV_BretonRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Breton_GreenWay_T1` | +4% Stamina Regen | The rites keep you close to the land. Stamina regenerates 4% faster. |
| `PDV_Bless_Breton_GreenWay_T2` | +7% Stamina Regen, +8 Restoration | The standing stones and outdoor rites answer you. Stamina regenerates 7% faster and Restoration +8. |
| `PDV_Bless_Breton_GreenWay_T3` | +10% Stamina Regen, +10 Restoration, +10% Health Regen | The covenant of the wild is kept in you. Stamina +10%, Restoration +10, and health regenerates 10% faster. |
| `PDV_Bless_Breton_HiddenArt_T1` | +6 Conjuration | The cover holds and the art answers. Conjuration +6. |
| `PDV_Bless_Breton_HiddenArt_T2` | +9 Conjuration, +9 Illusion | The occult work runs deeper. Conjuration +9 and Illusion +9. |
| `PDV_Bless_Breton_HiddenArt_T3` | +12 Conjuration, +12 Illusion, +8% Magicka Regen | The art is yours, and the cover is your burden. Conjuration +12, Illusion +12, and magicka regenerates 8% faster. |
| `PDV_Bless_Breton_KnightsRoad_T1` | +5 Block | The vow steadies your guard. Block +5. |
| `PDV_Bless_Breton_KnightsRoad_T2` | +8 Block, +8 Restoration | You stand between the weak and harm. Block +8 and Restoration +8. |
| `PDV_Bless_Breton_KnightsRoad_T3` | +12 Block, +10 Restoration, +10% Armor Rating | The vow is your bulwark. Block +12, Restoration +10, and armor rating +10. |
| `PDV_Bless_Breton_Tradition_T1` | +4% Health Regen | Your chosen tradition steadies you. Health regenerates 4% faster. |
| `PDV_Bless_Breton_Tradition_T2` | +6% Health Regen, +5% Magic Resistance | A Breton kept by tradition is well-warded. Health regenerates 6% faster and magic resistance rises 5%. (Signature: steadier through hardship; broad lane stops here, below focused tradition rewards.) |
| `PDV_SPEL_Neglect_Breton` | -5% Health Regen | You have let your chosen tradition lapse. Your health regenerates 5% more slowly until you return to it. |

### PDV_DunmerRewardRecords.spec.json (14)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Dunmer_Azura_T1` | +4% Magicka Regen | Twilight sharpens your sight. Magicka regenerates 4% faster. |
| `PDV_Bless_Dunmer_Azura_T2` | +7% Magicka Regen, +5% Magic Resistance | Azura's foresight wards your mind. Magicka regenerates 7% faster and magic resistance rises 5%. |
| `PDV_Bless_Dunmer_Azura_T3` | +10% Magicka Regen, +10% Magic Resistance | You see by the twilight Azura keeps. Magicka regenerates 10% faster and magic resistance rises 10%. |
| `PDV_Bless_Dunmer_Boethiah_T1` | +5 One-Handed | Struggle tempers your arm. One-handed +5. |
| `PDV_Bless_Dunmer_Boethiah_T2` | +8 One-Handed, +10% Armor Rating | The strong prevail by Boethiah's measure. One-handed +8 and armor rating +10. |
| `PDV_Bless_Dunmer_Boethiah_T3` | +12 One-Handed, +15% Armor Rating | You have proven your strength to the Prince of Plots. One-handed +12 and armor rating +15. |
| `PDV_Bless_Dunmer_Mephala_T1` | +5 Sneak | You learn to move along the unseen threads. Sneak +5. |
| `PDV_Bless_Dunmer_Mephala_T2` | +8 Sneak, +10 Illusion | Secrets and shadow answer to you. Sneak +8 and Illusion +10. |
| `PDV_Bless_Dunmer_Mephala_T3` | +12 Sneak, +15 Illusion | The Webspinner's whisper guides your hand. Sneak +12 and Illusion +15. |
| `PDV_Bless_Dunmer_Reclamation_T1` | +5% Magic Resistance | The Reclamations keep a steadying ward on you. Magic resistance rises 5%. |
| `PDV_Bless_Dunmer_Reclamation_T2` | +8% Magic Resistance, +5% Magicka Regen | The Reclamations hold you close even in exile. Magic resistance rises 8% and magicka regenerates 5% faster. |
| `PDV_Bless_Dunmer_Substrate_Always` | +3% Magic Resistance | The ancestors keep their hand on you across the diaspora. Your resistance to magic rises by 3%. |
| `PDV_Bless_Dunmer_Substrate_Mid` | +6% Magicka Regen (at home or a shrine), +6% Magic Resistance | The ancestors gather closer at hearth and ash. At home or at a shrine your magicka regenerates 6% faster, and your resistance to magic rises by 6%. |
| `PDV_SPEL_Neglect_Dunmer` | -5% Magicka Regen (in the matching posture) | The ancestors have fallen silent and cannot reach you. Your magicka regenerates 5% more slowly until the connection is restored. |

### PDV_ImperialRewardRecords.spec.json (30)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Imperial_Akatosh_T1` | +4% Magicka Regen | The Dragon God steadies the line of time within you. Magicka regenerates 4% faster. |
| `PDV_Bless_Imperial_Akatosh_T2` | +7% Magicka Regen, +5% Magic Resistance | The Covenant holds. Magicka regenerates 7% faster and magic resistance rises 5%. |
| `PDV_Bless_Imperial_Akatosh_T3` | +10% Magicka Regen, +10% Magic Resistance | You endure as the first Covenant endures. Magicka regenerates 10% faster and magic resistance rises 10%. |
| `PDV_Bless_Imperial_Arkay_T1` | +5% Disease Resistance | The keeper of the cycle wards your flesh. Disease resistance +5%. |
| `PDV_Bless_Imperial_Arkay_T2` | +10% Disease Resistance, +7% Health Regen | You keep the vigil between life and death. Disease resistance +10% and health regenerates 7% faster. |
| `PDV_Bless_Imperial_Arkay_T3` | +12% Disease Resistance, +10% Health Regen | Arkay's ward stands between you and the grave. Disease resistance +12% and health regenerates 10% faster. |
| `PDV_Bless_Imperial_Civic_T1` | +4% Health Regen | The Nine note your civic faith. Health regenerates 4% faster. |
| `PDV_Bless_Imperial_Civic_T2` | +7% Health Regen, +10% Disease Resistance | A faithful citizen of the Empire is well-kept. Health regenerates 7% faster and disease resistance rises 10%. (Signature: steadier through hardship.) |
| `PDV_Bless_Imperial_Dibella_T1` | +5 Speech | Grace touches your words. Speechcraft +5. |
| `PDV_Bless_Imperial_Dibella_T2` | +8 Speech, +5% Magicka Regen | Beauty and persuasion answer you. Speechcraft +8 and magicka regenerates 5% faster. |
| `PDV_Bless_Imperial_Dibella_T3` | +12 Speech, +8% Magicka Regen | Dibella's inspiration moves through your words. Speechcraft +12 and magicka regenerates 8% faster. |
| `PDV_Bless_Imperial_Julianos_T1` | +4% Magicka Regen | Wisdom and logic sharpen the mind. Magicka regenerates 4% faster. |
| `PDV_Bless_Imperial_Julianos_T2` | +7% Magicka Regen, +5% Magic Resistance | The God of Wisdom and Logic wards the disciplined mind. Magicka regenerates 7% faster and magic resistance +5%. |
| `PDV_Bless_Imperial_Julianos_T3` | +10% Magicka Regen, +10% Magic Resistance | Julianos grants the insight of law and lore. Magicka regenerates 10% faster and magic resistance +10%. |
| `PDV_Bless_Imperial_Kynareth_T1` | +4% Stamina Regen | The open air fills your lungs. Stamina regenerates 4% faster. |
| `PDV_Bless_Imperial_Kynareth_T2` | +7% Stamina Regen, +5% Magic Resistance | The Lady of the heavens sustains you. Stamina regenerates 7% faster and magic resistance +5%. |
| `PDV_Bless_Imperial_Kynareth_T3` | +10% Stamina Regen, +8% Magic Resistance | Kynareth's sky is open to you. Stamina regenerates 10% faster and magic resistance +8%. |
| `PDV_Bless_Imperial_Mara_T1` | +5 Restoration | Mercy comes more readily to your hands. Restoration +5. |
| `PDV_Bless_Imperial_Mara_T2` | +8 Restoration, +7% Health Regen | The Mother's mercy mends. Restoration +8 and health regenerates 7% faster. |
| `PDV_Bless_Imperial_Mara_T3` | +10 Restoration, +12% Health Regen | Mara's compassion works through you. Restoration +10 and health regenerates 12% faster. |
| `PDV_Bless_Imperial_Stendarr_T1` | +5 Block | The God of Mercy steadies your guard. Block +5. |
| `PDV_Bless_Imperial_Stendarr_T2` | +8 Block, +10% Armor Rating | You stand between the weak and harm. Block +8 and armor rating +10. |
| `PDV_Bless_Imperial_Stendarr_T3` | +12 Block, +15% Armor Rating | Stendarr's bulwark is yours to hold. Block +12 and armor rating +15. |
| `PDV_Bless_Imperial_Talos_T1` | +5% Armor Rating | Defiance held in secret hardens you. Armor rating +5. |
| `PDV_Bless_Imperial_Talos_T2` | +10% Armor Rating, +8 One-Handed | Open faith in the Ninth steels your arm. Armor rating +10 and One-Handed +8. |
| `PDV_Bless_Imperial_Talos_T3` | +12% Armor Rating, +12 One-Handed | The Hero-God of Man stands with the faithful. Armor rating +12 and One-Handed +12. |
| `PDV_Bless_Imperial_Zenithar_T1` | +25 Carry Weight | Honest labor lightens your load. Carry weight +25. |
| `PDV_Bless_Imperial_Zenithar_T2` | +40 Carry Weight, +8 Speech | The God of Work and Commerce favors fair dealing. Carry weight +40 and Speechcraft +8. |
| `PDV_Bless_Imperial_Zenithar_T3` | +55 Carry Weight, +12 Speech | Prosperity follows honest work. Carry weight +55 and Speechcraft +12. |
| `PDV_SPEL_Neglect_Imperial` | -5% Health Regen | You have let civic faith lapse. Your health regenerates 5% more slowly until you return to public service and the Divines. The real bite comes only at rupture or curse. |

### PDV_KhajiitRewardRecords.spec.json (17)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Khajiit_Alkosh_T1` | +5% Fire Resistance | The Dragon King's order steadies you. Fire resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T2` | +8% Fire Resistance, +5% Magic Resistance | You keep the line against chaos. Fire resistance +8% and magic resistance +5%. |
| `PDV_Bless_Khajiit_Alkosh_T3` | +12% Fire Resistance, +15% Magic Resistance | Alkosh's roar is in your blood. Fire resistance +12% and magic resistance +15%. |
| `PDV_Bless_Khajiit_Azurah_T1` | +4% Magicka Regen | Twilight feeds the mind. Magicka regenerates 4% faster. |
| `PDV_Bless_Khajiit_Azurah_T2` | +7% Magicka Regen, +5% Magic Resistance | The twilight wards you. Magicka regenerates 7% faster and magic resistance rises 5%. |
| `PDV_Bless_Khajiit_Azurah_T3` | +10% Magicka Regen, +10% Magic Resistance | You see by the twilight Azurah keeps. Magicka +10% and magic resistance +10%. |
| `PDV_Bless_Khajiit_BaanDar_T1` | +5% Armor Rating | The outsider endures. Your armor rating rises by 5. |
| `PDV_Bless_Khajiit_BaanDar_T2` | +10% Armor Rating, +10% Health Regen | The survivor mends quickly. Armor +10 and health regenerates 10% faster. |
| `PDV_Bless_Khajiit_BaanDar_T3` | +15% Armor Rating, +15% Health Regen, +10 Unarmed Damage | Baan Dar's luck is with you when the odds are not. Armor +15, health regenerates 15% faster, and your claws strike harder (+10 unarmed). |
| `PDV_Bless_Khajiit_Khenarthi_T1` | +4% Stamina Regen | The open road is kinder to you. Stamina regenerates 4% faster. |
| `PDV_Bless_Khajiit_Khenarthi_T2` | +7% Stamina Regen, +30 Carry Weight | The road-walker bears more and tires less. Stamina regenerates 7% faster and you carry 30 more. |
| `PDV_Bless_Khajiit_Lunar_T1` | +5% Stamina Regen (at night), +10% Disease Resistance (at night) | The moons have noticed how you move. At night, your stamina regenerates 5% faster and your resistance to disease rises by 10%. |
| `PDV_Bless_Khajiit_Rajhin_T1` | +5 Sneak | You move as the Purring Liar taught. Sneak +5. |
| `PDV_Bless_Khajiit_Rajhin_T2` | +8 Sneak, +10 Lockpicking | Shadow and lock yield to you. Sneak +8 and Lockpicking +10. |
| `PDV_Bless_Khajiit_Rajhin_T3` | +12 Sneak, +15 Lockpicking, +15 Pickpocket, +10 Unarmed Damage | The legend works through your hands. Sneak +12, Lockpicking +15, Pickpocket +15, and clawed strikes +10 unarmed. |
| `PDV_Bless_Khajiit_Substrate_Always` | +5% Disease Resistance | The moons keep you hardy. Your resistance to disease rises by 5%. |
| `PDV_SPEL_Neglect_KhajiitLunar` | -5% Stamina Regen (at night) | You have not kept the moons. At night your stamina regenerates 5% more slowly until you return to the road and the lattice. |

### PDV_NordRewardRecords.spec.json (18)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Nord_Kyne_T1` | +5% Stamina Regen | The storm-mother has noticed how you live. Stamina regenerates 5% faster. |
| `PDV_Bless_Nord_Kyne_T2` | +8% Stamina Regen, +10% Frost Resistance | The open sky steadies you against the cold. Stamina regenerates 8% faster and frost resistance rises 10%. |
| `PDV_Bless_Nord_Kyne_T3` | +10% Stamina Regen, +15% Frost Resistance | Kyne's breath is in the wind at your back. Stamina regenerates 10% faster and frost resistance rises 15%. |
| `PDV_Bless_Nord_OldWays_T1` | +4% Stamina Regen | The old roads and weather are companionable to you. Stamina regenerates 4% faster. |
| `PDV_Bless_Nord_OldWays_T2` | +6% Stamina Regen, +10% Frost Resistance | Skyrim itself looks after the faithful. Stamina regenerates 6% faster and frost resistance rises 10%. |
| `PDV_Bless_Nord_Shor_T1` | +5% Health Regen | The hero-god of Sovngarde marks your valor. Health regenerates 5% faster. |
| `PDV_Bless_Nord_Shor_T2` | +10% Health Regen, +8 One-Handed | Shor's hall remembers the brave. Health regenerates 10% faster and One-Handed +8. |
| `PDV_Bless_Nord_Shor_T3` | +12% Health Regen, +10 One-Handed, +10 Two-Handed | Sovngarde looks back on you. Health regenerates 12% faster, One-Handed +10, and Two-Handed +10. |
| `PDV_Bless_Nord_Stuhn_T1` | +5% Armor Rating | The shield-thane of just spoils guards you. Armor rating rises by 5. |
| `PDV_Bless_Nord_Stuhn_T2` | +10% Armor Rating, +8 Block | Honored bonds shield you. Armor rating rises by 10 and Block +8. |
| `PDV_Bless_Nord_Stuhn_T3` | +12% Armor Rating, +10 Block, +8 One-Handed | Stuhn holds the line for the honorable. Armor rating rises by 12, Block +10, and One-Handed +8. |
| `PDV_Bless_Nord_Talos_T1` | +5% Armor Rating | Defiance held in secret hardens you. Armor rating rises by 5. |
| `PDV_Bless_Nord_Talos_T2` | +10% Armor Rating, +8 One-Handed | The old faith steels your arm. Armor rating rises by 10 and One-Handed +8. |
| `PDV_Bless_Nord_Talos_T3` | +12% Armor Rating, +12 One-Handed | The Hero-God of Man stands with the faithful. Armor rating rises by 12 and One-Handed +12. |
| `PDV_Bless_Nord_Tsun_T1` | +5% Stamina Regen | The shield-thane of Shor weighs your trials. Stamina regenerates 5% faster. |
| `PDV_Bless_Nord_Tsun_T2` | +8% Stamina Regen, +10 Block | You stand the trials Tsun sets. Stamina regenerates 8% faster and Block +10. |
| `PDV_Bless_Nord_Tsun_T3` | +10% Stamina Regen, +12 Block, +10% Armor Rating | Tsun guards the bridge at your back. Stamina regenerates 10% faster, Block +12, and armor rating rises by 10. |
| `PDV_SPEL_Neglect_Kyne` | -5% Stamina Regen | The weather no longer feels on your side. At night your stamina regenerates 5% more slowly until you return to the open sky. |

### PDV_OrcRewardRecords.spec.json (12)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Orc_City_T1` | +5 Restoration | You keep the code where no stronghold can see it. Restoration +5. |
| `PDV_Bless_Orc_City_T2` | +8 Restoration, +8 Speech | Dignity held under pressure is its own kind of strength. Restoration +8 and Speech +8. |
| `PDV_Bless_Orc_City_T3` | +10 Restoration, +12 Speech, +5 Block | You built belonging outside the hold and kept the code doing it. Restoration +10, Speech +12, and Block +5. |
| `PDV_Bless_Orc_LegionExile_T1` | +5 One-Handed | Discipline carries the code where no kin can. One-Handed +5. |
| `PDV_Bless_Orc_LegionExile_T2` | +8 One-Handed, +8 Block | Service under pressure tempers the arm and the shield. One-Handed +8 and Block +8. |
| `PDV_Bless_Orc_LegionExile_T3` | +10 One-Handed, +12 Block, +5% Stamina Regen | You carried the burden of service and exile and came back unbroken. One-Handed +10, Block +12, and stamina regenerates 5% faster. |
| `PDV_Bless_Orc_Malacath_T1` | +4% Armor Rating | Malacath regards the strong who keep his code. Your armor rating rises by 4. |
| `PDV_Bless_Orc_Malacath_T2` | +6% Armor Rating, +8% Health Regen | The Code-Keeper steadies the faithful. Armor rating rises by 6 and health regenerates 8% faster. |
| `PDV_Bless_Orc_Stronghold_T1` | +5 Smithing | The forge knows your hands keep the code. Smithing +5. |
| `PDV_Bless_Orc_Stronghold_T2` | +8 Smithing, +8 Heavy Armor | Worthy work and worthy war-gear. Smithing +8 and Heavy Armor +8. |
| `PDV_Bless_Orc_Stronghold_T3` | +10 Smithing, +12 Heavy Armor, +5% Armor Rating | The stronghold counts you blood-kin and the forge answers. Smithing +10, Heavy Armor +12, and armor rating +5. |
| `PDV_SPEL_Neglect_Orc` | -5% Armor Rating | You have not kept Malacath's code. Your guard feels thin; your armor rating drops by 5 until you return to worthy work, service, or kin. |

### PDV_RedguardRewardRecords.spec.json (10)

| EditorID | Effect clause | Current description |
| --- | --- | --- |
| `PDV_Bless_Redguard_AncestorSpine_T2` | +5% Magic Resistance, +8% Armor Rating | The line of ancestors steadies you on the road. Your resistance to magic rises 5% and your armor rating rises by 8. |
| `PDV_Bless_Redguard_FarShoresToken` | +5% Magic Resistance | You keep a token of the Far Shores close, and pray as Tu'whacca's people do. Your Magic Resistance rises by 5%. |
| `PDV_Bless_Redguard_HoonDing_T1` | +5 One-Handed | When the way must be made, the Make-Way God moves through you. One-Handed +5. |
| `PDV_Bless_Redguard_Leki_T1` | +5 One-Handed | The Lady of Swords steadies your form. One-Handed +5. |
| `PDV_Bless_Redguard_Leki_T2` | +8 One-Handed, +5% Critical Chance | Leki's ataxia lives in your blade. One-Handed +8 and your critical chance rises 5%. |
| `PDV_Bless_Redguard_Leki_T3` | +12 One-Handed, +8% Critical Chance | The Spirit Sword sings through your hand. One-Handed +12 and your critical chance rises 8%. |
| `PDV_Bless_Redguard_Tuwhacca_T1` | +5% Magic Resistance | The Tricky God watches over the dead and the living alike. Your resistance to magic rises by 5%. |
| `PDV_Bless_Redguard_Tuwhacca_T2` | +8% Magic Resistance, +10% Health Regen | Tu'whacca steadies the soul against death's edge. Your resistance to magic rises 8% and your health regenerates 10% faster. |
| `PDV_Bless_Redguard_Tuwhacca_T3` | +10% Magic Resistance, +15% Health Regen | Tu'whacca keeps the way to the Far Shores open for you and yours. Your resistance to magic rises 10% and your health regenerates 15% faster. |
| `PDV_SPEL_Neglect_Redguard` | -3% Magic Resistance | The ancestors feel distant and the road is colder. Your resistance to magic falls 3% until you keep the sect and the death duty again. |

