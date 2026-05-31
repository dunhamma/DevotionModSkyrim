# PDV Race Gameplay Balance Audit

**Created:** 2026-05-30
**Status:** Living multi-lens audit for 1.0 gameplay balance
**Scope:** All ten player races, all locked worship targets, all sixteen Skyrim-present Daedric Prince surfaces, and race-specific non-god immersion lanes.

## Purpose

This audit complements the Phase 20 roster gate. Phase 20 answers:

- Does every locked god or cultural worship target exist in the roster contract?
- Does every Skyrim-present Daedric Prince have a race-response surface?
- Do the stance and Daedric matrices cover all ten races?

This audit answers a different question:

- Does every race receive comparable gameplay wealth, class support, immersion texture, and player-facing feedback without flattening the theology?

Comparable does not mean equal mechanics. A Nord can be hook-dense and public, a Khajiit can be road-and-moon shaped, and an Argonian can be exile-and-Hist shaped. The balance target is that each race should feel equally cared for in play.

## Working Artifacts

Use these working artifacts to act on this audit:

- `references/authoring/PDV_RaceRewardBudgetLedger.md` - tracks reward wealth, always-on layer count, contextual favor budget, privileges, prices, neglect, immersion budget, and overstack/thinness risk.
- `references/authoring/PDV_RacePlaystyleCoverageLedger.md` - tracks warrior, mage, stealth/social, survival/travel, craft/labor, low-violence, and curse/Daedric support by race.
- `references/authoring/PDV_RaceImplementationCostingBacklog.md` - translates the audit into buildable records/state, hook sources, rejected-hook assertions, immersion proof, player-facing surfacing, verifier gates, and runtime proof slices.
- `references/authoring/PDV_PreBetaRaceScalingSpine.md` - owns the shared pre-beta race-scaling gate, Altmer/Khajiit/Argonian spine order, P1 packet split, P2 audit-only split, and subagent handoff template.
- `references/authoring/PDV_PreBetaRaceAcceptanceRubric.md` - defines the measurable `Pass` / `Conditional` / `Fail` bar before external playfeel testing or stronger reward tuning.
- `references/authoring/PDV_RecognitionDialogueScalePacket.md` - defines the CK-safe recognition/dialogue scaling packet before broad NPC recognition content.
- `references/authoring/PDV_CAT6PromotionPilot.md` - defines the first non-dialogue draft-to-ESP-to-handbook promotion proof before broad CAT-6 string promotion.
- `references/authoring/PDV_Phase20*ImplementationCosting.manifest.json` - child costing contracts for the first high-risk runtime slices; `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the full manifest set, including immersion proof.

Every focused race pass should update the relevant ledger and the costing backlog before it changes runtime scope, manifest prose, or verifier expectations. Reward budget updates must include the immersion budget: what the player sees, understands, and feels as religious life.

## Focused Pass Index

| Race | Reward Ledger | Playstyle Ledger | Verdict | Next Action |
|---|---|---|---|---|
| Altmer | First focused pass complete; implementation-spec closeout landed. | First focused pass complete; implementation-spec closeout landed. | `Watch`; source, record, QASmoke placement, and route runtime proof are closed for the first crisis/Lorkhan/favor packet, but Lorkhan pressure and crisis pacing cannot be judged by an external beta tester until more real gameplay surface exists. | Pre-beta scaling: build thinness/playfeel surfaces, Exiled vampire handling, rejected surfaces, and final placement before asking testers to judge punitive feel. |
| Argonian | First focused pass complete. | First focused pass complete. | `Thin/Watch`; architecture and route proof are closed, but Hist/People reward wealth needs support before Void expansion. | Pre-beta scaling: build Hist sap, water/rest maintenance, bed-of-choice feel, community recognition, Arkay death-rite reactions, and curse posture before asking testers to judge non-Sithis play. |
| Orc | First focused pass complete. | First focused pass complete. | `Watch`; route proof is closed, but Stronghold/crafting are rich and City plus Legion/Exile still need dynamic situational parity. | Pre-beta scaling: build life-mode switching, mode gates, quality forge filters, self-made community, service milestones, dignity moments, and rejected hooks. |
| Redguard | First focused pass complete. | First focused pass complete. | `Watch`; route proof is closed and content is rich, but martial/death-duty hooks can flatten sect distinction. | Pre-beta scaling: build sect state/readback, Far Shores token, Crown/Forebear/Ash'abah favor hooks, HoonDing cap, Ash'abah stigma surfacing, and rejected hooks. |
| Bosmer | First focused pass complete; non-hunter parity proof packet landed. | First focused pass complete; non-hunter parity proof packet landed. | `Watch`; path system and non-hunter route proof are closed, but Old Contract/hunter proof density still needs playfeel comparison. | Pre-beta scaling: build Living Story, Exchange, Bandit Road, and Old Contract favor feel against the Phase 9 hunter baseline and the Green Pact tag-layer gate. |
| Khajiit | First focused pass complete; moon/road/focus proof packet landed. | First focused pass complete; moon/road/focus proof packet landed. | `Watch`; lunar/road route proof is closed, but phase timing can become chores and Khenarthi/Azurah are easiest. | Pre-beta scaling: build lunar chore pressure, road-home cadence, focus split, Baan Dar/Rajhin distinction, and Alkosh rarity. |
| Breton | First focused pass complete. | First focused pass complete. | `Overstack Risk`; three strong traditions and tracks can outshine simpler races if all pay at once. | Cost tradition state, three track readbacks, per-tradition favor rows, Druidic Trial, curse split, and rejected-hook tests. |
| Dunmer | First focused pass complete. | First focused pass complete. | `Overstack Risk`; ancestor substrate plus Reclamation focus plus deviations can stack too much. | Cost ancestor substrate proof, posture states, Reclamation boundaries, marked-moment caps, deviation prices, and rejected-hook tests. |
| Imperial | First focused pass complete. | First focused pass complete. | `Watch`; Concordat identity is strong, but civic hooks must stay concrete. | Cost Concordat readback, Talos filters, civic-act whitelists, repair gates, non-combat proof hooks, and rejected faction/attendance hooks. |
| Nord | First focused pass complete. | First focused pass complete. | `Watch`; densest hook coverage and multiple proven pilots need reward ceilings. | Cost broad/focused caps, pantheon baseline readback, offer-gate proof, Kyne/Talos contrast, Hircine stack checks, and dense-hook rejected tests. |

## Implementation Order From Focused Passes

| Priority | Work | Why |
|---|---|---|
| P0 | Phase 20 route proof closeout | All six Phase 20 QASmoke proof packets are source/record/proof-placement wired and route-runtime proven. The remaining gate is pre-beta gameplay scaling for playfeel, negative hooks, anti-farm pressure, final world placement, and enough reward content that testers can judge an experience rather than missing systems. |
| P1 | Phase 20 pre-beta immersion buildout | Follow the scaling spine: Altmer first, Khajiit as first contrast, Argonian second contrast, then Orc / Redguard / Bosmer packets. These are the main parity risks: thin non-Sithis support, City/Legion parity, sect distinction, non-hunter payoff, and lunar chore pressure. QASmoke cannot judge those, and external beta should wait until normal play has real hooks, rewards, and status surfaces. |
| P2 | Breton and Dunmer stack-control gates | Both are rich enough to overpay if tracks/substrates/focuses all reward loudly at once. |
| P2 | Imperial and Nord ceiling gates | Both are hook-rich and proven enough that concrete-act filters and broad/focused caps matter more than adding content volume. |

## Evidence Snapshot

Current evidence used for this pass:

- `node .\tools\pdv_verify.mjs --strict-phase20-roster` on 2026-05-30 after the costing-manifest gate landed: `FAIL=0`, `WARN=1`, `TODO=0`, `PASS=1465`, `INFO=31`. The warning is four unnamed CK-authored `INFO` records, not a roster or balance failure.
- `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` on 2026-05-30 after Altmer curse-message record wiring: `FAIL=0`, `WARN=1`, `TODO=0`, `PASS=1549`, `INFO=30`. The warning remains the existing unnamed CK-authored `INFO` record class.
- `PDV_TargetEndStates_1.0.md` marks every race architecture-locked and implementation-spec locked after the 2026-05-30 Altmer closeout.
- `references/authoring/PDV_DeityCoverageMatrix.json` defines the Phase 20 roster authority, required races, required columns, locked worship objects, Skyrim-present Daedric Princes, Jyggalag exclusion, and Phase 20 slice gates.
- `references/phase4/PDV_StanceMatrix.csv` has 45 locked worship-object rows with all ten race columns.
- `references/phase4/PDV_DaedricRacePrinceMatrix.csv` has all sixteen Skyrim-present Prince rows with all ten race columns.
- `race-sheets/PDV_RaceContent_Manifest.md` says all ten race-facing manifest sections have full draft prose; Breton's optional Vigilant pressure encounter remains slip-able post-1.0.
- `race-sheets/PDV_DaedricContent_Manifest.md` now has draft rows for Boethiah plus the remaining fifteen Skyrim-present Princes. Those rows are content-lock inputs, not promotion approval: stigma rows remain provisional until ratified, Hircine/Molag Bal curse-access template variation remains open, and Prince authoring order still needs a locked rollout sequence.
- `references/PDV_ExperienceMode_DesignReference.md` and `references/authoring/PDV_ExperienceMode.manifest.json` are merged as planning contracts for the future Pilgrim's Path / Wayfarer's Path user-facing difficulty toggle; they are not live runtime evidence for race parity yet.
- `race-sheets/PDV_ContentDestinationMatrix.md` exposes key open review points: remaining Daedric authoring order, Bosmer Green Pact per-item feedback, Breton Vigilant pressure, and cells marked deferred.

## Audit Lenses

Use all lenses together. A race can pass one lens and still fail the audit.

| Lens | What It Checks | Current Gate |
|---|---|---|
| Theology and lore coherence | The race's gods, Princes, taboos, curse readings, and non-god lanes preserve the locked TES interpretation. | Locked in race architecture; Altmer closeout landed 2026-05-30. |
| Player fantasy and immersion | The race feels different in normal play before a spreadsheet is opened. Signature friction, ritual rhythm, place, social recognition, recovery, and neglect texture matter as much as boons. | Required in the reward-budget ledger's immersion matrix and verifier-enforced through each Phase 20 race-costing manifest's `immersionProof` block. |
| Benefit wealth parity | Each race gets comparable value across steady boons, contextual favors, privileges, recognition, prices, recovery, and neglect. | Not yet complete; reward magnitudes remain tunable for every race. |
| Class and playstyle coverage | Warrior, mage, stealth, social, survival, craft, quest-heavy, curse, and low-violence players can find race-shaped paths where appropriate. | Uneven; Dunmer/Khajiit/Breton are strongest, some sparse-hook races need review. |
| Hook reality | Claimed signals are backed by vanilla hooks, curated quest stages, CK records, or explicit custom-content scope. | Mixed; hook-rich races are safer than sparse-content races. |
| Player comprehension | The player can tell why a state changed, why a god responded, and why a taboo or price applied. | Good for status/survey surfaces; content density still unproven for full roster. |
| Writing and surfacing | Notifications, message boxes, dialogue, and status readouts stay diegetic, quiet enough, and budget-compliant. | Race and Daedric manifests are drafted; broad promotion is still gated by CAT-6 and Daedric contract decisions. |
| Technical proof | Source, CK records, verifier coverage, and runtime proof exist for the relevant lane. | Strong for pilots; not full roster. |
| Compatibility and modlist fit | The system remains vanilla-plus, patchable, and list-author friendly. | Phase 21 handles patches, but balance must avoid relying on list-specific assumptions. |

## Global Findings

### Finding 1: Roster Coverage Is Not The Same As Content Readiness

The Phase 20 roster structure is in place and verifier-covered. That is necessary, but not enough. The content matrix now shows all sixteen Skyrim-present Daedric Princes as drafted, while promotion remains blocked by the shared Daedric contract decisions above. Full 1.0 readiness still needs Prince-by-Prince promotion, per-race response verification, and runtime proof.

Audit consequence: do not mark "all gods and Princes complete" until Phase 20B and 20C have content-ready rows, not merely matrix presence.

### Finding 2: The Non-God Lanes Are Real Architecture, Not Side Flavor

The project already has non-god immersion lanes with mechanical homes:

- Nord: pantheon baseline, Talos pressure, vampire rupture/scar.
- Imperial: `ConcordatStanding`, public/private Talos logic, civic duty.
- Breton: `WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding`.
- Dunmer: ancestor substrate and ancestor posture.
- Altmer: `ThalmorAlignment`, Lorkhan pressure, crisis-of-faith lane.
- Khajiit: lunar substrate, moon cycle, road homes, silent focused emphasis, lunar posture.
- Bosmer: path choice, Old Contract, Green Pact compliance, shared Pact memory.
- Redguard: sect, ancestor duty, death-duty, Far Shores token.
- Orc: Malacath life-mode, stronghold/city/service standing.
- Argonian: Hist substrate, People/Void layers, bed of choice, Hist posture.

Audit consequence: these lanes must be balanced alongside gods and Princes. They are not optional flavor rows.

### Finding 3: Benefit Wealth Is The Main Remaining Product Risk

The locked hybrid boon policy says most races should not feel like they have more than two meaningful always-on boon families at once. That prevents runaway stacking, but it does not yet prove equal richness. Some races get strong persistent substrates, some get privileges and social state, and some get sparse custom content. The audit needs to compare total felt value, not just passive stat power.

Audit consequence: create a reward-budget pass before promoting more content to runtime.

### Finding 4: Immersion Parity Is Reward Parity

Immersion is not a separate writing polish pass. If a reward can be understood only as a stat, hidden counter, or generic quest bonus, it is under-budgeted even if the numbers are fair. The reward budget has to include the diegetic reason the race would care, the feedback that teaches the player what happened, and the ordinary-session loop that makes the race feel alive when no major quest is firing.

Audit consequence: every runtime slice needs an immersion proof alongside technical proof: trigger meaning, surfacing, rejection of generic triggers, and at least one normal-play readout or recovery loop.

### Finding 5: Class Balance Needs Its Own Pass

Dunmer explicitly calls out class appeal balance, and Khajiit/Breton naturally cover many styles. Other races may still skew hard toward one style:

- Orc can over-skew combat/crafting.
- Redguard can over-skew martial/death-duty.
- Argonian can over-skew stealth/water/Sithis if Hist and People layers are not rich enough.
- Bosmer can over-skew archery/hunting if Living Story, Exchange, and Bandit Road are not equally attractive.
- Altmer can over-skew scholar/mage/enforcer unless crisis and favor lanes support more than orthodoxy management.

Audit consequence: every race needs a class/playstyle table before final reward tuning.

## Race-by-Race Audit

| Race | Core Experience | Non-God Immersion Lanes | Current Strength | Main Balance Risk | Required Audit Action |
|---|---|---|---|---|---|
| Nord | Broad worship reveals the god that noticed how the player lived. | Pantheon baseline, Talos pressure, Hircine curse path, vampire rupture/scar. | Hook-rich and runtime-proven at pilot depth. | Nord has so many vanilla hooks that broad worship or Kyne/Talos could become richer than other races by accident. | Set a Nord reward ceiling and ensure broad Old Ways/Nine Divines stay softer than focused patron depth. |
| Imperial | Civic Divines worship under Concordat pressure. | `ConcordatStanding`, public/private Talos, institutional privilege. | Strong political and social identity; good hook support. | Can become a faction-politics tracker instead of felt religion if civic acts are too abstract. | Require concrete civic acts for favor; compare Akatosh/Stendarr/Arkay/Talos payoff against non-combat builds. |
| Breton | Explicit tradition choice: Knight's Road, Hidden Art, or Green Way. | Three always-relevant tracks: exposure, vow integrity, druidic standing. | Strongest class spread and identity spread on paper. | Too much system richness could outshine other races if tracks, patron rewards, and Daedric access all stack loudly. | Budget each tradition separately; keep Hidden Art stronger only when social rupture is actually paid. |
| Dunmer | Ancestors plus Reclamations; cumulative, layered devotion. | Ancestor substrate, ancestor posture, portable/private shrine pattern. | Excellent class spread: Azura, Boethiah, Mephala plus deviations. | Strong substrate plus primary focus plus Daedric deviations can stack into too much always-on value. | Keep ancestor substrate mostly interpretive/identity utility; tune Reclamation foreground as the louder layer. |
| Altmer | Coherence under Lorkhan pressure; Auri-El foundation plus secondary focus. | `ThalmorAlignment`, Lorkhan pressure, crisis-of-faith, Exiled vampire micro-path. | Excellent conceptual friction; implementation-spec is closed, source compiles, crisis state is record-wired, first two favor spell records are wired, four trigger proof ACTI base records are wired, and QASmoke route proof passes. | Can still feel punitive if crisis pacing fires too often or if normal Skyrim play is over-taxed. | Build rejected surfaces, one-active-favor gates, Exiled vampire cap, and main-quest + daily-life pressure playfeel before external beta. |
| Khajiit | Lunar Lattice always holds the player; focus emerges silently from lived behavior. | Lunar substrate, moon phases, road homes, lunar posture, ShadowDrift. | Highly distinctive and partly runtime-proven. | Moon phases and road homes can become chores; Khenarthi/Azurah can crowd out Baan Dar, Rajhin, and Alkosh. | Tune phase bonus small, cycle consistency meaningful, and ensure all five focus paths have attractive launch hooks. |
| Bosmer | Explicit path choice: Old Contract, Living Story, Exchange, Bandit Road. | Green Pact, path switching, shared Pact memory, forced reckoning. | Runtime-proven path system and strong identity. | Old Contract burden could dominate attention; sparse vanilla Bosmer content can weaken non-hunter paths. | Balance all four paths for equal appeal; prove non-hunter Bosmer rewards with curated hooks, not generic activity. |
| Redguard | Sect-shaped Yokudan faith with ancestor duty and death-order pressure. | Sect state, ancestor reverence, death duty, Far Shores token, Ash'abah stigma. | Strong death-duty hooks and clear sect identity. | Can over-index on warrior/undead content; Ash'abah social burden is sparse without custom support. | Ensure Crown, Forebear, and Ash'abah each have social, travel, duty, and combat reward surfaces. |
| Orc | Malacath-centered life-mode expression, not deity shopping. | Stronghold, City, and Legion/Exile life-mode standing. | Clear identity and good craft/combat hooks. | Stronghold can be much richer than City or Legion/Exile; forge rewards can become loops. | Equalize life-mode rewards; add dignity/service recognition that is not just combat or smithing. |
| Argonian | Hist-first exile identity with People and Void layers. | Hist substrate, People layer, Void/Sithis threshold, bed of choice, Hist posture. | Very distinctive; strong Sithis/DB hook support. | Sparse Argonian content and water-detection risk can make non-Sithis play feel thin. | Strengthen Hist/People non-assassin play, keep Sithis threshold high, and prove bed-of-choice is not a chore. |

## Class and Playstyle Coverage

This table is not a promise that every race supports every archetype equally. It is a check that each archetype has meaningful race-shaped paths somewhere, and that no race collapses to one obvious build.

| Archetype | Strong Current Fits | At-Risk Areas | Audit Rule |
|---|---|---|---|
| Warrior / front-line | Nord, Orc, Redguard, Boethiah Dunmer, Trinimac Altmer, Hircine paths. | Redguard and Orc can become too combat-forward. | Combat rewards must be contextual, not generic damage throughput. |
| Mage / scholar | Altmer, Azura Dunmer, Khajiit Azurah, Breton Hidden Art, Julianos lanes. | Orc, Redguard, Bosmer, Argonian need enough non-combat magic-adjacent value where lore supports it. | Mage value can be privilege, study, ritual, resistance, or recognition; not just spell-cost reduction. |
| Stealth / thief / assassin | Mephala Dunmer, Rajhin Khajiit, Nocturnal paths, Argonian Void/Sithis, Bosmer Bandit Road. | Do not reward generic theft or random murder. | Stealth value requires story-worthy targets, oath, obligation, or curated quest context. |
| Social / civic / community | Imperial, Breton Knight's Road, Bosmer Living Story, Khajiit caravan, Argonian People, Redguard Forebear. | Sparse NPC/dialogue hooks can make these feel thinner than combat. | Social rewards need recognitions, dialogue, services, or status readouts, not only hidden piety. |
| Craft / labor / trade | Orc, Zenithar/Nord/Imperial, Redguard Forebear, Baan Dar trade edges. | Craft loops are easy to farm. | Require value, quality, context, cooldown, or quest framing. |
| Survival / travel / outdoors | Nord Kyne, Khajiit Khenarthi, Bosmer Green, Argonian Hist/water, Redguard Tava. | Travel signals can become passive faucets. | Travel rewards need cadence, varied place, road-home, weather, or pilgrimage limits. |
| Curse / Daedric / rupture | Hircine, Molag Bal, Breton Hidden Art, Dunmer deviations, Khajiit ShadowDrift, Altmer crisis. | Curse paths can overwrite native race identity if too rewarding. | Curse lanes must keep price, stigma, exit, and residue visible. |
| Low-violence / mercy / restoration | Stendarr, Mara, Arkay, Breton Knight's Road, Imperial civic mercy, Argonian People. | Needs more curated hooks than kill routes. | Low-violence players should get comparable recognition even where reward frequency is lower. |

## Benefit Wealth Checklist

Before marking a race content-complete, require these checks:

1. The race has a clearly named foreground layer: patron, path, mode, or focused emphasis.
2. Any persistent substrate or light substrate has a narrow job and does not become a second main stat package.
3. The race has at least one memorable Champion moment that changes the feel of play.
4. The race has a meaningful neglect texture, not only piety decay.
5. Every active lane has 3-5 trigger families or an explicit reason it is narrower.
6. Each trigger family has a hook source, anti-farm rule, and player-facing feedback plan.
7. At least three broad playstyles have attractive race-shaped routes, unless the race intentionally excludes one for theological reasons.
8. A curse or Daedric path never silently replaces the native race architecture.
9. Survey/status readouts explain the player's current religious state in plain player-facing language.
10. The race's rewards fit the hybrid boon policy: usually no more than two meaningful always-on boon families at once.
11. Each reward lane has an immersion proof: the diegetic reason the trigger matters, the feedback surface that teaches it, and the ordinary behavior that must not count.

## Prince Content Audit

Phase 20 requires all sixteen Skyrim-present Prince surfaces for every race. Current content state is not yet equal:

| Prince Surface | Current State | Audit Risk | Next Action |
|---|---|---|---|
| Boethiah / Boethra | Drafted pilot. | Pilot can bias the template toward Dunmer/Khajiit-native treatment. | Use as structure, not as tone clone. |
| Azura / Azurah | Stub-listed. | Native Dunmer/Khajiit plus foreign/tolerated paths need careful split. | Draft native, foreign, and taboo handling distinctly. |
| Mephala / Mafala | Stub-listed. | Easy to collapse into generic murder/crime. | Require obligation, hidden community, oath, web, or curated quest context. |
| Malacath / Mauloch | Stub-listed. | Orc native path must not be treated like generic Daedric stigma. | Split Orc ancestor-god reading from external oath/exile paths. |
| Meridia | Stub-listed. | Cleansing-light can become generic paladin utility. | Keep stigma light but price/faith friction present where appropriate. |
| Hircine | Runtime-proven pilot on Nord. | Hunt/lycanthropy can overwrite native race identity. | Reuse proof pattern, but race-modify cost and exit. |
| Molag Bal | Stub-listed. | Vampire path can flatten race curse readings. | Keep vampirism as rupture first, devotional path only where authored. |
| Nocturnal | Stub-listed. | Thieves Guild/Nightingale surface can dominate stealth builds. | Preserve native stealth gods like Mephala/Rajhin/Baan Dar. |
| Hermaeus Mora | Stub-listed. | Scholar path could over-attract every mage. | Price forbidden knowledge by race, especially Altmer/Dunmer/Breton. |
| Mehrunes Dagon | Stub-listed. | Generic destruction/rebellion risk. | Require catastrophic rupture, artifact, or curated revolution context. |
| Sheogorath | Stub-listed. | Madness can become random joke content. | Keep disruption, instability, and exit residue clear. |
| Namira / Namiira | Stub-listed. | Cannibal/outcast path needs heavy stigma and ancestor friction. | Gate through explicit taboo content only. |
| Sanguine / Sangiin | Stub-listed. | Revelry can become low-cost fun bonus. | Make excess and lost restraint part of the price. |
| Clavicus Vile | Stub-listed. | Bargain path fails if price is hidden. | Every boon needs a visible deal, loophole, or residue. |
| Peryite | Stub-listed. | Narrow quest surface. | Keep narrow, durable, affliction/order themed. |
| Vaermina | Stub-listed. | Dream/nightmare path can be too abstract. | Anchor in sleep, fear, Skull of Corruption, and memory cost. |

## Priority Recommendations

### P0 - Close Before More Broad Runtime Buildout

1. **Apply the pre-beta acceptance rubric before Altmer scaling.** The wired Altmer, Argonian, Orc, Redguard, Bosmer, and Khajiit proof triggers are placed and route-runtime proven. Continue with rejected-surface tests, anti-farm tests, pre-beta gameplay scaling, and final world placement, but judge each race through `PDV_PreBetaRaceAcceptanceRubric.md` before adding more broad race content or asking external testers to judge playfeel.
2. **Use the reward-budget ledger.** For each race, keep always-on boons, temporary favors, privileges, recognition surfaces, prices, and neglect effects visible before tuning new rewards. Mark raw-stat impact separately from narrative/privilege impact.
3. **Use the immersion budget matrix.** For each race, prove the strongest reward loop feels culturally specific in ordinary play before increasing its mechanical power.
4. **Resolve the narrow Daedric expansion blockers before broad Prince cloning.** Section 11.6 now locks roster shape, mixed recovery, and reduced cross-Prince hostility, so CAT-4 should no longer treat those as open. The remaining blockers are stigma row ratification, Hircine/Molag Bal curse-access template shape, and authoring order. Boethiah is the pilot; the next passes should prioritize Princes with high race-crossing risk: Hircine, Molag Bal, Nocturnal, Hermaeus Mora, Malacath, Azura, Mephala.
5. **Prove recognition and CAT-6 promotion before scaling them.** Use `PDV_RecognitionDialogueScalePacket.md` for one CK-authored non-Nord recognition packet before broad NPC recognition, and `PDV_CAT6PromotionPilot.md` for one low-risk non-dialogue string promotion before broad ESP/handbook promotion.

### P1 - Required For Race Parity

1. **Add class/playstyle mini-tables to each race closeout.** The table should name at least warrior, mage, stealth/social, survival/travel, and low-violence/restoration viability where relevant.
2. **Run sparse-hook race passes.** Bosmer, Orc City/Legion, Argonian People/Hist, Redguard Ash'abah, and Khajiit caravan/community need special attention because vanilla support is thinner.
3. **Balance non-god lanes directly.** Do not let gods get tuned while moon phases, Hist distance, Green Pact, ConcordatStanding, ThalmorAlignment, and life-mode standing remain unbudgeted.

### P2 - Before Public 1.0 Packaging

1. **Run firing-density review across all race manifests.** Marked and Noted surfaces should stay rare enough that religion feels present, not chatty.
2. **Run compatibility sanity after reward tuning.** List patches may route signals or classify records, but must not change theology or race target end states.
3. **Playtest two contrasting builds per race.** At minimum one expected build and one edge build. Example: Khajiit road mage vs Rajhin thief; Orc stronghold smith vs city service exile; Argonian Hist community player vs Sithis-threshold assassin.

## Audit Verdict

The architecture is mostly in place. The full race audit should proceed, but it should not be framed as "do we have enough gods?" The better framing is:

> Does each race offer a comparably rich religious life, with its own costs, privileges, playstyle routes, social texture, curse reading, and memorable payoff?

Current answer:

- **Architecture agreement:** Yes; all ten races are architecture-locked and implementation-spec locked.
- **Roster structure:** Yes; strict Phase 20 roster verification passes.
- **Race-facing prose inventory:** Yes for core 1.0 race prose; Breton Vigilant pressure remains optional/slip-able.
- **Daedric full content:** Drafted for all sixteen Skyrim-present Princes, but not promotion-ready until stigma, Hircine/Molag Bal curse-access, and Prince order decisions are locked.
- **Benefit wealth parity:** Not proven yet; this is the next audit layer.
- **Immersion parity:** Now first-class in the reward budget; not runtime-proven per race yet.
- **Class/playstyle parity:** Promising but uneven; needs explicit race-by-race review.

Do the full audit, but make it a gameplay/product audit first and a technical proof audit second. The technical proof gates are already strong enough to support that work once the design choices are made.
