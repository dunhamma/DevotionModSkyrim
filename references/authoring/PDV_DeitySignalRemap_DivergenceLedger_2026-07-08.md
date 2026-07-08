# PDV Deity Signal Remap Divergence Ledger - 2026-07-08

**Status:** audit snapshot; owner-lock pending.
**Input handoff:** `references/authoring/PDV_SessionHandoff_DeitySignalRemap_2026-07-08.md`.
**Purpose:** reconcile the 10-race deity signal remap against current guides,
architecture, CSV/script signal surfaces, quest-matrix surfaces, and machine gates
before implementation planning.

This file is an audit and walk-through ledger. It does not authorize ESP, CSV,
Papyrus, or player-guide edits by itself.

## Owner Lock Log

| Decision | Status | Locked interpretation |
|---|---|---|
| First-class roster | LOCKED 2026-07-08 | `Syrabane` is no longer a Breton actor candidate; it is an Altmer first-class focus. Altmer `Phynaster` stays roster/flavor-only for V1: no live deity record, formal offer, or reward family. Breton Hidden Art uses the existing Breton-cultural `Magnus` lane as the benign magic deity, existing `Mara` as hearth/home/cover deity, and Hermaeus Mora/Hircine/Namira/Nocturnal as core Daedric Hidden Art patrons through the global Daedric system. Breton `Phynaster` is kept as a Breton elven-heritage/longevity candidate, proof-gated and cuttable if the implementation loop stays too thin. `Orkey` stays Arkay-backed Old Ways presentation/display framing, not a separate `PDV_Deity_Orkey` scoring script. `Onsi`, `Ruptga`, `Tava`, `Satakal`, and `Zeht` remain flavor/deferred/background unless owner-reopened later. |
| Breton Hidden Art cultural anchors | LOCKED 2026-07-08 | Hidden Art is not only Daedric. It has two Breton-cultural benign anchors: `Magnus` for sorcery, hidden magical practice, and formal arcane study; `Mara` for hearth, home, family, cover, and domestic continuity. Mara uses the existing shared `PDV_Deity_Mara` record with Breton Hidden Art lane-specific rows, not a new actor. Hermaeus Mora, Hircine, Namira, and Nocturnal remain core Hidden Art Daedric patrons through the global Daedric system. In good Hidden Art standing, they do not add a second global Daedric stigma/price layer; the Breton price is WitchcraftExposure, cover, Vigilant pressure, and rupture risk. |
| Quest capture rule | LOCKED 2026-07-08 | Questline/deity hookup is matrix-first and multi-deity by value tag. Add or retune quest-matrix rows for deity opinions; add bespoke Papyrus/FormList code only for missing source detection, exact-stage fill, or genuinely special mechanics. |
| Same-god reuse | LOCKED 2026-07-08 | Reuse only when it is the same worship target. Aspect-parallels, proxy institutions, and native theological variants do not collapse into one scoring lane: they either keep distinct records, route proxy credit to the native god, or use presentation-only aliasing when explicitly locked. |
| Akatosh fulfillment cap | LOCKED 2026-07-08 | Akatosh gets explicit quest-matrix rows for real oath/order/covenant outcomes. The existing `meta_akatosh_wheel` lane remains a medium background pulse every tenth watched quest fulfillment, tuned by `value.meta.wheel = 2.0`, framed as continuance/time/order rather than generic oath-keeping; `metaSkip.Akatosh` prevents double credit when the quest already has an Akatosh cell. |
| Shrine prayer cap | LOCKED 2026-07-08 | Generic shrine prayer grants at most one piety credit per resolved deity per day. The cap belongs inside `AwardShrinePrayerToDeityName`, so one click can still credit multiple mapped deity aliases once, but repeat clicks cannot farm the same deity that day. Larger shrine-like rites remain separate curated race-specific surfaces. |
| Formal offers vs reorientation | LOCKED 2026-07-08 | Formal deity offers stay patron-only and use the generic patron commitment surface. State/path changes are allowed where the race architecture owns them, but only through explicit race-owned reorientation systems, not the generic formal-offer queue. Breton is reopened as active-tradition offer eligible; add Altmer `Syrabane` offer eligibility behind protection/apprentice proof; keep Altmer `Trinimac` offer-gated behind high orthodoxy; keep Bosmer/Khajiit/Argonian no-formal-offer for V1. |
| Guide validation timing | LOCKED 2026-07-08 | Player guides remain current-live/proof-gated. After each race is design-locked, create a guide-shaped design-validation draft marked not-live to test player coherence, missing hooks, and overpromises before implementation planning. Publish/update player-facing race guides only after implementation/readback proof for that race lands. |

## Architecture Check - Same-God Reuse Radials

Authority checked: `references/authoring/PDV_Phase2_DeityRoster_and_ArchitectureRulings.md`
R4/R5, `references/PDV_RaceArchitecture_DesignReference.md`,
`PDV_Architecture_v3.md`, and `references/phase4/PDV_StanceMatrix.csv`.

Architectural rule: reuse a deity record only when it is the same worship target.
When the source material treats a related name/aspect as a different religious
lane, keep a distinct record or keep it as flavor/proxy only.

| Pattern | Architectural handling | Examples |
|---|---|---|
| Same worship target across cultures | One deity record with per-race stance/access/presentation. | Akatosh/Mara/Arkay/Stendarr/Zenithar/Dibella/Julianos/Kynareth across Imperial/Nord/Breton where those races actually use the Imperial Divine; Baan Dar across Khajiit/Bosmer; Azura/Azurah across Khajiit/Dunmer native surfaces. |
| Aspect-parallel but distinct worship target | Distinct record; do not collapse just because domains overlap. | Auri-El != Akatosh; Kyne != Kynareth; Khenarthi != Kynareth; Alkosh != Akatosh/Auri-El; Tu'whacca != Arkay; Z'en != Zenithar; Tava != Kynareth/Khenarthi. |
| Institutional proxy | Source can use another culture's place/tool, but piety routes to the native god. | Redguard Hall-of-the-Dead / Arkay-shrine infrastructure should credit Tu'whacca/ancestor duty, not Arkay devotion; Bosmer Kynareth shrines can proxy Y'ffre offering without making Kynareth the Old Contract god; Breton Green Way Kynareth/sky-wild sources route to Y'ffre rather than making Kynareth a Green Way offer deity. |
| Display alias / reframing | Keep the existing scoring record but alter presentation. | Owner lock: Orkey stays Arkay-backed Old Ways presentation/display framing, not separate `PDV_Deity_Orkey`. |
| Path-state interpretation | Same deity ledger; path state changes exclusivity, penalties, and weighting. | Bosmer Old Contract and Living Story share `Y'ffre`; `OldContract` adds PactBound/GPC/forced reckoning, but does not create a second Y'ffre. |
| Native-integrated Daedric exception | Same Prince can have native-integrated handling for one culture and ordinary Daedric-path handling elsewhere. | Azura/Azurah, Boethiah/Boethra, Mephala/Mafala, Malacath/Mauloch; stigma/exit rules branch by race rather than forcing one universal label. |
| Background/broad-only pantheon member | No deity record unless made focusable later. | Onsi, Ruptga, Tava, Satakal, Zeht under the current remap lock; Ruptga can flavor HoonDing but does not become HoonDing. Altmer Phynaster remains in this bucket for V1. Breton Phynaster is no longer in this bucket, but remains proof-gated. |
| Same name, doctrine split | One record can remain, but source rows must be doctrine-aware. | Argonian Sithis is change/void doctrine with a threshold gate; Dark Brotherhood Sithis is the dark-end ladder, not a generic Argonian everyday signal. |

## Proof Boundary

| Bucket | Proven now | Boundary |
|---|---|---|
| authority | The remap handoff is a complete target design; current race sheets, architecture, player guides, signal ledgers, and quest-matrix docs exist. | Several remap items reverse or extend locked docs, so they need owner ratification before implementation. |
| readback | Current live build gates are broadly green: verifier, content verify, formal-offer readback, dislike-consequence readback, deity-chain readback, quest-matrix compile, signal-floor ledger. | These gates prove the current build, not the new remap. |
| runtime-route | Existing route surfaces and quest-reaction machinery are live; current quest matrix compiles to 832 cells across 90 watched quests. | New/remapped signals have no runtime proof until implemented and smoked. |
| manual | Existing manual/race proof remains separate. | This audit does not prove player feel, Surfacing, Book of Days readability, or final-world placement. |
| claim | Safe claim: "current remap has been audited into a divergence/build ledger for owner walk-through." | Unsafe claim: "remap is locked", "implementation-ready", or "quest/deity wiring is complete." |

## Machine Audits Run

| Gate | Result | Notes |
|---|---|---|
| `node .\tools\pdv_signal_floor_audit.mjs` | PASS: 51/51 paths, 0 under-floor | Proves current path breadth only. Refreshed `PDV_SignalFloorLedger.md`. |
| `node .\tools\pdv_antifarm_sweep_audit.mjs` | FINDINGS | 127 piety-awarding handlers; 117 capped; 1 uncapped positive gain: `HandleShrinePrayer`; 9 uncapped penalty-only review items. |
| `node .\tools\pdv_deity_chain_audit.mjs` | PASS | 1786 ESP records scanned; 99 reward spells and 32 offer MESGs resolve; 6 active-patron-gated races checked. |
| `node .\tools\pdv_content_verify.mjs --json` | PASS | 1081 PASS, 4 INFO. |
| `node .\tools\pdv_verify.mjs --json` | PASS | 3546 PASS, 68 INFO, 1 WARN. WARN is medallion glyph fallback for pending gods. |
| `node .\tools\pdv_formal_offer_check.mjs --json` | PASS | 197 PASS; confirms current formal-offer coverage and current exclusions. |
| `node .\tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json` | PASS | 32 PASS; all 32 current likes/dislikes actors mapped to disfavor domains. |
| `node .\tools\pdv_quest_matrix_compile.mjs --check --json` | PASS | 832 quest cells, 118 quest keys, 90 watched quests, 24 faucet acts. |
| `node .\tools\pdv_completeness_audit.mjs --json` | PASS with open review | Contract rows 768; PASS 361, NEEDS-MANUAL 293, GAP-REVIEW 53, FUTURE 59, WAIVED 2. |
| `node .\tools\pdv_ledger_coverage_audit.mjs --json` | CLEAN | 142 tracked earn sites, 0 untracked, 22 lifecycle. |
| `node .\tools\pdv_specced_minus_audit.mjs --json` | CLEAN | 16 specced minus signals, all wired. |
| `node .\tools\pdv_likesdislikes_gen.mjs` | generated output only | Current runtime body has 32 deities and 313 rows. |

## System Findings

1. The current build is healthy, but the new remap is not implemented. The green
   gates are a baseline, not remap proof.
2. Quest deity coverage should mostly be implemented through the quest-reaction
   matrix and deity values profiles. A quest outcome already fans out to every
   matching deity through act-tags, with stance modulation. Use bespoke route code
   only when the source event itself needs a concrete detector or FormList.
3. The likes/dislikes layer is code-generated. CSV edits alone are inert until
   `pdv_likesdislikes_gen` output is folded into the manager, old rows are cleared,
   and `LIKES_DISLIKES_VERSION` is bumped.
4. The scoring-surface absence inventory is real, but it is not a proposed
   new-actor list. These names currently have 0 likes/dislikes rows and 0
   quest-reaction cells: `Syrabane`, `Phynaster`, `Onsi`, `Ruptga`, `Tava`,
   `Satakal`, `Zeht`, `Orkey`. Owner review corrected the Breton handoff:
   `Syrabane` is not a Breton cultural deity and must not be added to Breton
   Hidden Art. Breton Hidden Art's benign magic deity is `Magnus`, and its
   hearth/home/cover deity is `Mara`. `Syrabane` is an Altmer first-class
   focus; `Phynaster` is kept as a Breton
   candidate, extrapolated from elven/Direnni longevity and disciplined-life lore
   with an explicit cut gate if hook design stays too thin; `Onsi` is deferred;
   `Ruptga` is folded into HoonDing flavor;
   `Satakal` / `Tava` / `Zeht` stay background unless owner-reopened; and
   `Orkey` remains the Arkay mirror/display-alias case unless explicitly
   reversed.
5. `HandleShrinePrayer` is currently the only uncapped positive piety handler in
   the anti-farm audit. Any remap plan that keeps shrine prayer as a shared signal
   needs a consume key or equivalent cap.
6. Player guides dated 2026-07-08 already include many wired-vs-stub warnings.
   They should be reconciled after owner lock, not blindly overwritten now.

## Current Signal Baseline

### Likes/dislikes

Current `PDV_DeityLikesDislikes.csv` has 32 actors and 313 rows. It is medium
density by count, but still uses many shared generic event IDs. Thin or fragile
by count does not always mean wrong; the remap changes identity and meaning, not
just row counts.

Lowest current row counts among launch actors:

| Actor | Rows | Comment |
|---|---:|---|
| `magnus` | 7 | Signal-poor relative to new Altmer/Breton expectations. |
| `Stuhn` | 7 | Needs mercy/war-captive/bounty density if Nord rebuild locks. |
| `Arkay` | 8 | Old Ways Orkey display/replacement decision affects this surface. |
| `khenarthi` | 8 | Needs psychopomp, courier, hospitality, and storm/travel specificity if locked. |
| `Leki` | 8 | Needs blade-gated open-combat discipline if locked. |
| `rajhin` | 8 | Needs artful theft/nonviolent escape rather than generic theft spam. |
| `Talos` | 8 | Needs defiance/costly-conscience density beyond generic combat. |

### Quest matrix

Current `PDV_QuestReactionMatrix_Full.csv` has 832 cells across 90 watched quests.
This is already the right architecture for "many gods weigh in on the same quest."
Examples from the current matrix include MQ/Civil War/Daedric quest stages fanning
out to many deities. The plan should enrich the act-tag profile and tranche rows,
not hand-wire each deity to each quest.

Current low quest-cell counts among race deities:

| Deity | Cells | Comment |
|---|---:|---|
| `The Hist` | 2 | Design may tolerate low quest matrix if Hist is carried by water/ritual/community, but People-layer quests need review. |
| `Y'ffre` | 4 | Bosmer/Breton nature quest coverage is still thin; current guides already flag location-hook stubs. |
| `Magnus` | 9 | College line exists, but Breton Hidden Art now depends on Magnus as the benign magic deity. |
| `Zenithar` | 10 | Z'en/Zenithar reuse and civic/trade quest tagging need review. |
| `Sithis` | 11 | DB-scoped may be acceptable; Argonian activation gate still needs care. |
| `Trinimac` | 12 | Count exists, but Altmer parity override and offer eligibility are not locked into current formal-offer coverage. |

Quest meta-faucets are already built and verified for seven shared lanes
(`meta.zen`, `meta.nocturnal`, `meta.azura`, `meta.akatosh`, `meta.xarxes`,
`meta.khenarthi`, `meta.julianos`). Open follow-ups from the July 5 handoff:
`EVT_STEAL_ITEM` (362) is declared but not dispatched, meta reason tokens need
humanized Ledger copy, Daedric path names lack the same runtime repair net as
launch deities, and stance multipliers apply to meta lanes.

## Implementation Surfaces To Use

| Surface | Use for | Cautions |
|---|---|---|
| `PDV_DeityLikesDislikes.csv` + `pdv_likesdislikes_gen` | Day-to-day repeatable likes/dislikes shared by same-god reuse. | Must regenerate manager body, clear old rows, and bump version. |
| `PDV_QuestReactionMatrix_*.csv` + `pdv_quest_matrix_compile` | Quest outcomes, shared act-tags, cross-deity fanout, meta-faucets. | Do not promote scan-only quest stages without exact readback. |
| Direct deity scripts `PDV_Deity_*.psc` | Bespoke signal constants/deltas for signals not expressible as generic event rows. | New first-class gods need scripts, records, properties, offer/roster support, and readback. |
| `PDV_PlayerEvents` / `PDV_EventBus` / `PDV_ActionRouter` | New detector families or missing dispatchers. | Keep caps at source or sink; avoid hot-path ownership checks unless explicitly chosen. |
| P2 receiver FormLists | Book, quest-stage, spell-learned, harvest/weather/source-fill routes. | Approved fill ledger remains authority; stage gates must be exact. |
| Player guides and race sheets | Player-facing and architecture ratification after owner lock. | Do not promise dev-only or unhooked signals. |

## Race Walk-Through Ledger

### Bosmer

**Walk:** Old Contract/Y'ffre, Living Story/Y'ffre, Exchange/Z'en, Bandit Road/Baan Dar,
then background Arkay/Xarxes/Mara/Stendarr status.

| Class | Items |
|---|---|
| MATCHES | Four-path architecture and path-switch cost shape broadly match. Current guides already flag proper hunt and forest-kept as stub/dev-only. |
| GUIDE-UPDATE | The quick-reference still names proper hunting/keeping the forest as top earns even though the guide notes say they are not organic. Update after deciding wire-vs-cut. |
| ARCH-RATIFY | Living Story drops food policing and GPC; Y'ffre becomes one shared signal set with path gates; oath-keeping replaces "courage"; smith-item is cut. |
| ARCH-RATIFY | Old Contract and Living Story use the same internal `PDV_Deity_Yffre` record and deity ledger. Split path gates, weights, penalties, reward copy, and presentation only; do not fork storage or create separate Old Contract/Living Story Y'ffre records. |
| BUILD | Wire or cut clean/proper hunt; remove dev-only forest-kept promises; add/verify Nettlebane/Eldergleam loss/restoration as Y'ffre/Bosmer rows; add false-story/deceit, oath, Daedric-serving, soul-binding/enchanting, assault, and Green Pact-specific plant/wood/flora/brewing gates. |

### Nord

**Walk:** Old Ways Kyne/Shor/Tsun/Stuhn/Mara/Talos/Orkey, then Nine Divines Akatosh/Mara/Arkay/Stendarr/Zenithar/Dibella/Julianos/Kynareth/Talos.

| Class | Items |
|---|---|
| MATCHES | Broad-to-primary dawn offer architecture matches current docs. Main quest rows already exist in the quest matrix for MQ104/MQ105/MQ304 and fan out to many gods. |
| GUIDE-UPDATE | Current guide still says Orkey is off the table. Update it to say Orkey visibly replaces Arkay only inside the Old Ways baseline, while the internal deity/storage/scoring record remains `PDV_Deity_Arkay`. |
| ARCH-RATIFY | Handoff reverses old Orkey exclusion. Akatosh becomes oath/covenant rather than generic discipline. Kynareth/Kyne regular-play floor shifts to wild-creature kills, shrine prayer, shouts/exploration, with survival as bonus only. |
| ARCH-RATIFY | Orkey is an Old Ways display/offer/neglect framing for Arkay's death-cycle surface, not a separate scoring actor. Do not create `PDV_Deity_Orkey`; route Orkey-facing Old Ways signals, offers, rewards, cooldowns, and neglect through `PDV_Deity_Arkay` / `PDV_Arkay`, while Nine Divines presentation remains Arkay. |
| BUILD | Add mercy triad distinctions, honorable-combat broad echoes and context bonuses, Talos defiance sources, Orkey/Arkay display rules, and capped quest-completion-as-kept-oath behavior. |

### Imperial

**Walk:** civic-duty axis, 8 Divines, Talos/ConcordatStanding.

| Class | Items |
|---|---|
| MATCHES | Civic framing exists in architecture and guide; formal-offer gate passes for current Imperial gods; quest matrix already contains Civil War and Empire/order cells. |
| GUIDE-UPDATE | Keep civic vs Talos bind explicit. Current guide already warns that many Concordat organic callers are missing. |
| ARCH-RATIFY | Handoff sharpens civic duty into its own secular/privilege axis rather than treating all civic acts as merely Divine piety. |
| ARCH-RATIFY | Civic duty is already decided as a real Imperial broad civic standing surface, not merely an Akatosh/Zenithar amplifier. It may carry broad Civic T1/T2, Survey/Book texture, neglect, and future privilege/recognition hooks, while deity families still receive weighted piety from concrete civic acts. It must not become a third always-on reward family beyond broad civic faith plus one active focused patron. |
| BUILD | Add organic Concordat callers for Civil War, Thalmor, worshipper protection/betrayal, public/private observance, and Legion/rebellion choices. Ensure civic axis can award standing/privileges without duplicating Divine patron logic. |

### Orc

**Walk:** Malacath across Stronghold, City, Legion/Exile; Trinimac as non-standard pressure only.

| Class | Items |
|---|---|
| MATCHES | No-offer, pure-deed Malacath architecture matches current sheet. Witness axis is already present: clan witnessed, hostile audience, no-one-watching. |
| GUIDE-UPDATE | Keep Trinimac as rare pressure, not an Orc worship lane. |
| ARCH-RATIFY | Handoff reinforces no prayer/shrine floor and makes oath-breaking the heaviest lasting mark. |
| BUILD | Add lasting oathbreaker mark/workoff, "softness/easy path" loss where detectable, vampire collapse, werewolf tolerated-if-disciplined, and mode multipliers tuned around deed density. |
| SOURCE-HUNT | "Begging/charity/easy path" loss is not an owner-decision blocker. Promote only exact vanilla quest/stage/outcome sources where the Orc chooses dependency, dishonor, oath-breaking, or refused earned strength; do not punish reasonable City Orc integration, paid work, accepted help during normal play, or mercy that still honors the Code. |

### Khajiit

**Walk:** lunar substrate, Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh.

| Class | Items |
|---|---|
| MATCHES | Silent no-offer emergence and focused-emphasis model match current architecture. Baan Dar reuse with Bosmer is consistent with cross-race deity reuse. |
| GUIDE-UPDATE | Remove or keep cut weak hooks only after lock: Azurah night-skill-learning, Alkosh punctuality/cowardice/chaos-magic, Rajhin ring-artifact. |
| ARCH-RATIFY | New emphasis: Azurah anti-shadow/undead, Khenarthi psychopomp/funeral, Rajhin artful theft, Alkosh settlement defense, community harm as substrate plus god echo. |
| BUILD | Add soul-trap-Khajiit loss, owned-grave/necromancy distinctions, Rajhin poor/brutal/betrayal losses, Alkosh chaos/temple losses, caravan/community harm echoes, and fix the `EVT_STEAL_ITEM` dispatch gap if theft art matters. |
| SOURCE-HUNT | Alkosh settlement-defense is accepted design but not a current owner-decision blocker. Current launch-proof Alkosh sources remain named-dragon / Dragonborn-order / word-drip routes; settlement-defense requires exact modlist/source readback or a future custom/content patch before live source-fill. |

### Dunmer

**Walk:** ancestor substrate, Azura, Boethiah, Mephala, House of Troubles wards.

| Class | Items |
|---|---|
| MATCHES | Good Daedra foregrounding and ancestor layer broadly match current architecture. Quest matrix already covers DA01/DA02 and several deviation paths. |
| GUIDE-UPDATE | House of Troubles must be described as act-based wards if locked, not only stigma pressure. |
| ARCH-RATIFY | Handoff adds House of Troubles wards on existing Prince ledgers and stance; no passive drips and no new system. Ancestor posture/vampire silence remains a known gap-review surface. |
| ARCH-RATIFY | House of Troubles wards use existing sinks: ward acts credit ancestor/Reclamation standing and the relevant Good Daedra where the act has a clear target. They may counterbalance House-of-Troubles pressure only through existing Daedric price/stigma/stance machinery; do not create a separate ward score or passive stigma-reduction track. |
| BUILD | Add wards for refusing Mace/Razor/Wabbajack, curing vampirism, destroying vampires/Dagon servants, restoring sanity, rebuild-not-destroy, and shielding the weak. Add sharper ancestor taboos for Dunmer dead/crypt/grave goods. |

### Redguard

**Walk:** sect choice Crown/Forebear/Ash'abah, ancestor layer, Tu'whacca, Leki, HoonDing; background Satakal/Ruptga/Tava/Onsi/Zeht status.

| Class | Items |
|---|---|
| MATCHES | Current guide and reward spec treat Tu'whacca/HoonDing/Leki as focusable live deities and background Yokudan gods as flavor/no records. |
| GUIDE-UPDATE | Keep "Tava blesses passage" language from implying a Tava scoring actor unless owner reopens background deity records. |
| ARCH-RATIFY | Handoff narrows: Onsi deferred, Ruptga folded into HoonDing flavor, Sep rejected. This conflicts with older RaceContent manifest rows that list Satakal/Ruptga/Tava T3 rewards/offers. |
| ARCH-RATIFY | Satakal, Ruptga, Tava, Onsi, and Zeht are broad-only/background/flavor for Redguard 1.0 unless owner-reopened later. Do not create focus records, offer rows, or T3 reward families for them in the current implementation plan. Ruptga can flavor HoonDing make-way, and Tava/Zeht/Onsi/Satakal can flavor sect-shaped broad rows without owning reward storage. |
| BUILD | Add vampire earn-halt, Leki blade-gated open-combat discipline, HoonDing communal make-way doctrine, Tu'whacca anti-vampire/death-duty rows, sect witness multipliers, and exact oppression/free-the-enslaved quest rows. |

### Breton

**Walk:** Knight's Road, Hidden Art, Green Way; then Stendarr/Akatosh/Mara/Arkay/Julianos/Zenithar/Kynareth/Dibella, Magnus as Hidden Art magic deity, Mara as Hidden Art hearth/home/cover deity, Hermaeus Mora/Hircine/Namira/Nocturnal as core Daedric Hidden Art patrons, and Green Way Y'ffre plus Phynaster as a proof-gated elven-heritage/longevity candidate.

| Class | Items |
|---|---|
| MATCHES | Explicit tradition choice, stable 1.0 tradition, KnightlyVowIntegrity, WitchcraftExposure, and Green Way posture match current architecture. |
| GUIDE-UPDATE | Hidden Art roster must be corrected from current-live Julianos and handoff Syrabane drift to `Magnus` plus `Mara` plus the four core Daedric Hidden Art patrons: Hermaeus Mora, Hircine, Namira, and Nocturnal. Green Way should present Y'ffre plus proof-gated Phynaster. Kynareth must be removed from Green Way offer/reward ownership; current Kynareth proxy items in the Green Way lane should route to Y'ffre. |
| ARCH-RATIFY | Owner correction: `Magnus`, not `Syrabane`, is the Breton-cultural benign magic deity for Hidden Art. `Mara` is added as the Hidden Art hearth/home/cover deity. `Phynaster` stays in Breton design as an elven-heritage/longevity candidate, extrapolated from Direnni/Altmeri lore and explicitly cuttable if implementation proof fails. `Syrabane` is Altmer, not Breton. Hermaeus Mora, Hircine, Namira, and Nocturnal are Hidden Art offer candidates through the global Daedric system, but are not Breton cultural deities. |
| ARCH-RATIFY | Breton pressure model is locked as pressure-driven posture, not pressure-driven switching. `PDV_State_BretonTradition` stays the explicit stable identity spine for 1.0. `KnightlyVowIntegrity`, `WitchcraftExposure`, and `DruidicStanding` reshape gain, access, rupture, repair, debuffs, Survey text, and Book of Days texture inside the chosen tradition; they do not silently move the player into another tradition and do not create extra reward families. Pressure affects both piety gain and reward/debuff access: gain weighting makes pressure matter before failure, while access loss, rupture, or creed-loss spells make severe pressure mechanically legible. |
| ARCH-RATIFY | Breton focused reward tier is tradition-driven, not single-deity-driven. Each tradition owns one tier score/pool; multiple culturally valid deities and global Daedric paths can feed that pool through weighted evidence rows. The chosen tradition selects the reward family, the tradition score determines T1/T2/T3, and deity-specific rows still feed individual deity piety/ledger where appropriate. This replaces the current stale implementation shape where Hidden Art reads `PDV_Julianos` tier and Green Way reads `PDV_Kynareth` tier. |
| ARCH-RATIFY | Shared Breton neglect stays one spell for all traditions, but is tuned above the old Health-only floor: `PDV_SPEL_Neglect_Breton` should become Maximum Health -10 plus Magic Resistance -5%. This mirrors the Breton broad tradition's steadiness/warding loss, stays below creed-loss severity, avoids Requiem-swallowed negative regen, and keeps per-tradition texture in Survey/Book/notification copy rather than separate deity-specific neglect stacks. |
| ARCH-RATIFY | Breton focused reward stat identities stay stable except Knight's Road swaps Block to Speech. Knight's Road becomes Speech / Restoration / Armor, emphasizing vow-speech, courtly credibility, mercy, advocacy, and protective reputation rather than shield technique. The KnightlyVowIntegrity creed-loss mirrors the swap: Speech -5 plus Restoration -5 instead of Block -5 plus Restoration -5. Hidden Art keeps Conjuration / Illusion / Magicka Regeneration. Green Way keeps Stamina Regeneration / Restoration / Health. |
| ARCH-RATIFY | Knight's Road uses the full Eight Divines as weighted contributors, not only one or two patrons. Stendarr, Akatosh, Mara, and Arkay are the heavier chivalric core; Julianos, Zenithar, Kynareth, and Dibella are lower/contextual contributors through law, craft, mercy, beauty, public conduct, and honorable social obligations. This widens Knight's Road evidence without turning every Divine into an equal reward owner. |
| ARCH-RATIFY | Kynareth is removed from Breton Green Way offer/reward ownership. She remains available as a Knight's Road Divine contributor under the full-Eight model, but all Green Way Kynareth proxy/current wiring items should route to Y'ffre instead. Green Way covenant ownership belongs to Y'ffre; Kynareth cannot become the Skyrim-facing replacement for him. |
| ARCH-RATIFY | Phynaster remains in Breton Green Way only if he receives a concrete fill-out package before implementation lock: offer flavor, likes/dislikes, quest/source candidates, reward presentation, dislikes/neglect texture, and proof that the hooks are more than abstract elven-lore color. His locked hook spine is pilgrimage/endurance plus elven heritage/longevity: long road, short stride, disciplined life, Direnni memory, and old practice. If the fill-out pass cannot produce enough concrete, non-generic hooks, demote Phynaster to Green Way flavor/support and keep Y'ffre as the only Green Way offer owner. |
| ARCH-RATIFY | Phynaster's acceptance bar is locked. Before he becomes Breton offer-eligible or receives a `PDV_Deity_Phynaster` record, the implementation plan must produce at least three concrete positive source families, at least one concrete dislike/failure family, distinct offer/reward copy, and a no-overlap rule proving he is not taking Y'ffre's nature covenant, standing-stone, hunt, shrine-proxy, or Green Way reward identity. If this bar fails, Phynaster remains non-selectable flavor/support for Breton V1. |
| ARCH-RATIFY | Phynaster fill-out is deferred to the Breton implementation plan. Do not stop the race/lane walkthrough for a Phynaster source-fill pass now; carry him as a hard promotion gate and continue the remap audit. |
| ARCH-RATIFY | Magnus is Hidden Art offer-eligible only. Green Way may keep thin old-magic support rows where the source genuinely reads as druidic/earthbones/old magic, but Magnus is not Green Way offer-eligible and does not own Green Way reward tiers. This keeps Green Way centered on Y'ffre plus proof-gated Phynaster rather than becoming a second magic lane. |
| ARCH-RATIFY | Breton becomes formal-offer eligible by active tradition. Tradition score drives the Breton reward family; accepted deity commitment remains the personal patron/Devoted/Champion surface. Candidate deities are constrained by the active tradition roster rather than letting off-tradition piety silently override the tradition. Bosmer, Khajiit, and Argonian stay no-formal-offer for V1 because their designs lean on path mix, posture, and layered relation rather than single-patron offer queues. |
| ARCH-RATIFY | Hidden Art formal offers include Magnus, Mara, Hermaeus Mora, Hircine, Namira, and Nocturnal. The four Princes remain global Daedric records, but a Breton walking Hidden Art in good standing does not pay an additional global Daedric price/stigma on top of the Breton Hidden Art pressure model. Their cost is carried by WitchcraftExposure, cover management, Vigilant pressure, neglect, and rupture. If Hidden Art standing is neglected or ruptured, the normal Daedric price/stigma layer can reassert itself. |
| ARCH-RATIFY | Hidden Art `Magnus` and `Mara` use the same base formal-offer and patron commitment mechanics as other offer-eligible deities. They are not special mechanical exceptions: Magnus gets Breton Hidden Art arcane-discipline flavor, and Mara gets hearth/home/cover flavor, while the acceptance, Devoted/Champion, refusal, and patron-state machinery stays shared. |
| ARCH-RATIFY | "Good enough Hidden Art standing" for Daedric price/stigma suppression means active Hidden Art tradition, not tradition-neglected, and no Hidden Art rupture/creed-loss state. WitchcraftExposure band alone does not disqualify the player: Hidden/Suspected and Notorious are both valid Hidden Art end states, while Known is unstable and riskier but not automatic failure. Exposure becomes failure only when it crosses into rupture/creed-loss handling. |
| BUILD | Repoint Breton Hidden Art source routes, reward text, guide draft, likes/dislikes, quest-matrix rows, and any current Julianos/Syrabane planning language to `Magnus` where the source is benign magic, sorcery, formal study, or hidden magical practice. Add Mara rows for hearth, family, home, protective cover, concealment-with-responsibility, and domestic continuity; avoid laundering major occult exposure through shrine/home spam. Keep Hermaeus Mora, Hircine, Namira, and Nocturnal in the global Daedric system while making them Breton Hidden Art offer candidates whose extra global price/stigma is suppressed only while Hidden Art standing remains healthy. Draft Phynaster rows around pilgrimage/endurance, elven heritage, disciplined longevity, Direnni memory, and long practice; cut or demote to flavor if these cannot become concrete, non-generic hooks. Fix Green Way nature-site/standing-stone/location stubs or rewrite them. Rewire current Green Way Kynareth source/payout ownership to Y'ffre, including `HandleBretonGreenWayStanding`, current `PDV_Kynareth.SIGNAL_OPEN_SKY` award use, Green Way reward/spec references, and player-guide/source-fill language. Implement pressure posture weighting: Knight's Road integrity throttles Road gains and can apply vow/excommunication losses; Hidden Art exposure prices, suppresses, or empowers occult/Daedric gains by band without canceling social cost; Green Way standing/fork gates Y'ffre warmth and betrayal losses without becoming a boon track. Replace single-deity tier reads with tradition-score tier reads for Breton reward families. Add Breton to the formal-offer eligibility/message routing with active-tradition candidate filters. Retune `PDV_BretonRewardRecords.spec.json`, live ESP/MGEF readback, `pdv_requiem_penalty_audit.mjs`, felt-effect registry, and tester docs for Breton neglect Health -10 plus Magic Resistance -5%. Retune Knight's Road reward SPEL/MGEF records and copy from Block to Speech while preserving Restoration and Armor; retune vow-integrity loss from Block -5 to Speech -5 while preserving Restoration -5. |
| BUILD | Remove Magnus from Green Way offer/reward ownership in the final Breton implementation plan. If any Green Way source uses Magnus, treat it as support-only old-magic weighting that cannot produce a formal offer or Green Way reward tier by itself. |

#### Breton lane cultural-deity audit

Authority: `references/phase4/PDV_StanceMatrix.csv`,
`references/phase4/PDV_DaedricRacePrinceMatrix.csv`,
`references/PDV_RaceArchitecture_DesignReference.md`, `race-sheets/Race_Breton.md`,
and the owner correction in this walk-through.

| Lane | Option | Breton cultural deity? | Locked handling |
|---|---|---|---|
| Knight's Road | Stendarr | Yes | Keep as core Knight's Road focus. |
| Knight's Road | Akatosh | Yes | Keep as core Knight's Road focus; oath/order rows remain explicit and capped. |
| Knight's Road | Mara | Yes | Keep as core Knight's Road focus. |
| Knight's Road | Arkay | Yes | Keep as Knight's Road death/life-cycle focus. |
| Knight's Road | Julianos | Yes | Keep only in the Divine/Knight's Road study-law frame; remove from Hidden Art patron role. |
| Knight's Road | Zenithar | Yes | Keep as Knight's Road work/commerce/labor focus. |
| Knight's Road | Kynareth | Yes | Keep as Divine/Knight's Road contributor under the full-Eight model only. Do not use her as Green Way offer/reward owner. |
| Knight's Road | Dibella | Yes | Keep as Divine/Knight's Road social/art/beauty focus if the lane remains full-Eight. |
| Hidden Art | Magnus | Yes | Owner-locked replacement for Syrabane/Julianos as benign magic deity; offer-eligible on the shared formal-offer base with Breton Hidden Art arcane-discipline flavor. |
| Hidden Art | Mara | Yes | Owner-locked hearth/home/cover deity for Hidden Art; offer-eligible on the shared formal-offer base with hearth/home/cover flavor, rewarding family protection, domestic continuity, and responsible concealment without erasing WitchcraftExposure. |
| Hidden Art | Hircine | No; Breton-legible Daedric patron | Keep through global Daedric system as Hidden Art offer-eligible; suppress extra global price/stigma while Hidden Art standing is healthy. Green Way werewolf fork remains separate. |
| Hidden Art | Hermaeus Mora | No; Breton-legible Daedric patron | Keep through global Daedric system as Hidden Art offer-eligible for forbidden knowledge/Black Book routes; suppress extra global price/stigma while Hidden Art standing is healthy. |
| Hidden Art | Namira | No; Breton-legible Daedric patron | Keep through global Daedric system as Hidden Art offer-eligible for outcast/corpse-taboo routes; suppress extra global price/stigma while Hidden Art standing is healthy. |
| Hidden Art | Nocturnal | No; Breton-legible Daedric patron | Keep through global Daedric system as Hidden Art offer-eligible for Nightingale/shadow-oath routes; suppress extra global price/stigma while Hidden Art standing is healthy. Oath debt still shapes her content. |
| Green Way | Y'ffre | Yes | Keep as Green Way primary and owner of all former Green Way Kynareth proxy/source/payout items. |
| Green Way | Phynaster | Yes, but thin/heritage | Keep as proof-gated pilgrimage/endurance plus elven-heritage/longevity candidate. Promotion requires at least three positive source families, one dislike/failure family, distinct copy, and no-overlap proof against Y'ffre. Cut/demote if hooks stay too abstract. |
| Green Way | Magnus | Yes, but support-only | Remove from Green Way offer/reward ownership. Keep only thin old-magic support rows where the source genuinely belongs to Green Way's old druidic magic rather than formal arcane Hidden Art. |
| Removed Green Way proxy | Kynareth | Yes as Divine, no as Green Way owner | Remove from Green Way offer/reward ownership. Any Kynareth shrine/sky/wild/nature proxy source in the Green Way lane routes to Y'ffre. |
| Excluded cultural deity | Sheor | Yes, negative/Bad Man | Do not add as a worship lane; usable only as friction/background if needed. |
| Excluded current-drift deity | Syrabane | No for Breton | Remove from Breton plan; Altmer-only focus. |
| Excluded by handoff | Talos | PDV stance says Breton-readable, but not in Breton Varieties Eight and handoff says no Talos lane | Do not add to Breton lanes for this remap. |

### Altmer

**Walk:** Auri-El, Magnus, Xarxes, Trinimac, Syrabane; Phynaster as roster/flavor-only.

| Class | Items |
|---|---|
| MATCHES | Race sheet already has Auri-El, Magnus, Trinimac, Xarxes, and Syrabane in the locked focus design. Crisis machinery and Lorkhan adjacency exist in current docs. |
| GUIDE-UPDATE | Current Altmer player guide quick reference names only Auri-El/Magnus/Xarxes and treats Trinimac as pressure; it is missing Trinimac and Syrabane as now-locked focus paths. |
| ARCH-RATIFY | Trinimac parity overrides older "sparse by design" language. Sunlit-places are cut. Syrabane becomes an Altmer-only first-class focus unless a later non-Breton pass reopens sharing. |
| ARCH-RATIFY | Trinimac is a true Altmer focused path, not pressure-only. He reuses the shared Orc-owned `PDV_Deity_Trinimac` record, but Altmer treats him as native/focusable behind a hard orthodoxy gate: `ThalmorAlignment >= 70`, plus meaningful civilization-defense, enforcement, or martial-protection signals. `ThalmorAlignment` gates access and modulates Trinimac gain/offer weight after access; it does not become a third boon track. |
| ARCH-RATIFY | Syrabane is a true Altmer focused path. The launch lane starts narrow: warding, magical protection, apprentice/College aid, curse/disease warding, and anti-mage survival. If the narrow source set is too thin during implementation, breadth can be reopened through authored defensive texts or institution-protection beats, not through generic magic advancement, every ward cast, generic College membership, or raw magic-resistance farming. |
| ARCH-RATIFY | Altmer Phynaster remains roster/flavor-only for V1. Do not create `PDV_Deity_Phynaster`, Altmer Phynaster rewards, or a formal offer in the Altmer implementation plan. His longevity/pilgrimage space is not removed from lore, but it is not a sixth focus while Altmer already has Auri-El, Magnus, Trinimac, Xarxes, and Syrabane. |
| BUILD | Add Syrabane first-class actor support, reward family, and Altmer_Syrabane formal offer behind protection/apprentice proof; add Altmer_Trinimac formal offer/reward support under the high-orthodoxy gate; currently formal-offer check excludes both. Keep Altmer Phynaster as non-selectable roster/flavor only. Add Chantry/Auriel's Bow/dawn/coherence quest rows and Lorkhan-adjacent main quest crisis rows without creating permanent punitive drift. |

### Argonian

**Walk:** Hist, People/home/community, Sithis change-doctrine.

| Class | Items |
|---|---|
| MATCHES | Handoff preserves current three-layer/substrate architecture and no-offer posture. |
| GUIDE-UPDATE | Keep quest language careful: Hist has only 2 current quest matrix cells, and some Hist quest rows are echo/review rather than strong organic proof. |
| ARCH-RATIFY | Bed of Choice becomes one chosen home anchor with rolling cadence; community buffers low Hist; Hist relation is a cross-layer modifier. |
| ARCH-RATIFY | People-layer launch promotion is exact-source only: `Argonian Ceremony`, Histcarp/shared-food continuity, and Derkeethus rescue completion are the initial promoted community sources. Windhelm Assemblage remains a heavy People-lane target, but generic Windhelm/Riften presence and generic Argonian contact are rejected. Jaree-Ra betrayal may become a negative People loss only after exact quest/outcome readback. Future Argonian quests can be extrapolated into the candidate queue, but they do not become live source-fill until exact quest/stage/outcome metadata and rejected-context rules are approved. |
| ARCH-RATIFY | Sithis activation keeps the three-significant-signal threshold. Dark Brotherhood initiation and end-state milestones count as significant signals, but one DB join or one murder never fully activates Void scoring by itself. More death/void/change quests should be added over time, but they must enter through the exact-readback candidate queue with approved quest/stage/outcome metadata and explicit generic-murder/stealth rejection rules. |
| BUILD | Add/verify one-home Bed of Choice cadence, community buffer math, Windhelm Assemblage heavy People lane, Jaree-Ra betrayal loss, water/wetland/wading/near-water meditation and combat gates, and Sithis 3-signal quarter-piety gate. |
| BUILD | Promote the three People-layer launch sources only, keep Windhelm Assemblage and Jaree-Ra in reviewed-candidate state until exact readback, maintain future Argonian quest candidate queues for extrapolated People-layer and Sithis/death/void sources, and ensure each promoted Sithis source contributes one significant signal rather than bypassing the three-signal gate. |

## Cross-Race Shared Decisions To Lock First

1. **First-class roster:** confirm the intended split, not an expansion list.
   `Syrabane` is no longer a Breton actor candidate; it is an Altmer-only
   first-class focus. Breton Hidden Art uses `Magnus`,
   `Mara`, and the four core Daedric Hidden Art patrons: Hermaeus Mora,
   Hircine, Namira, and Nocturnal. `Phynaster` stays as a proof-gated Breton candidate.
   `Onsi`, `Ruptga`,
   `Tava`, `Satakal`, and `Zeht` should stay no-record/flavor/deferred unless
   owner-reopened. `Orkey` should stay the Arkay mirror/display-alias case
   unless owner explicitly wants a true separate scoring actor.
2. **Quest capture rule:** default to quest matrix/profile rows. Bespoke quest
   route code is only for exact stage source-fill, source detection, or cases the
   matrix cannot model.
3. **Same-god reuse:** same deity uses the same LD/QR signal set across races;
   race stance/frame changes the rate, presentation, and access gate.
4. **Generic completion as oath:** if Akatosh gets capped quest-completion-as-kept-
   oath, define the cap and whether it is meta-faucet, quest profile row, or both.
5. **Shrine prayer cap:** fix or explicitly defer the uncapped `HandleShrinePrayer`
   finding before claiming the remap's shared shrine layer is implementation-safe.
6. **Formal offers:** Breton is reopened and locked as active-tradition offer
   eligible. Bosmer, Khajiit, and Argonian remain no-formal-offer for V1 because
   their designs lean on path mix, posture, or layered relation. Current helper
   still excludes Breton, Orc, Altmer Trinimac, and Altmer Syrabane, so these
   now-locked patron offers are build work.
7. **Guide rewrite timing:** update player guides only after each race is locked,
   because current guides intentionally document today's live/stub state.

## Suggested Walk-Through Order

1. Shared rules: roster, quest-matrix rule, same-god reuse, cap policy, offer policy.
2. Breton and Altmer together for Magnus/Syrabane boundary implications.
3. Nord and Imperial together for shared Divines, Orkey/Arkay, civic duty, and Talos.
4. Redguard for roster contraction versus older Satakal/Ruptga/Tava reward rows.
5. Bosmer for Y'ffre path-gating and current stub cleanup.
6. Khajiit for five-focus enrichment and theft/soul/grave edge cases.
7. Dunmer for House of Troubles wards and ancestor posture.
8. Argonian for People/home/Hist/Sithis exact sources.
9. Orc for Malacath witness/oath/curses after the cross-race roster is settled.
