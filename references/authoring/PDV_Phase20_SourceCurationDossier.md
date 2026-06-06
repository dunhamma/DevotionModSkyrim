# PDV Phase 20 Source Curation Dossier

**Created:** 2026-06-03
**Status:** Readback dossier plus P2 book-fill approval tranche
**Companion inventory:** `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv`
**Fill approval ledger:** `references/authoring/PDV_Phase20_SourceFillApprovalLedger.json`

## Boundary

This dossier continues the all-race exact-source curation pass from
`PDV_Phase20_NextReadbackHook.md`.

The original readback pass did not approve any ESP write, FormList fill, CK
mutation, or runtime-proof claim. The follow-on P2 safe-fill tranche now
approves a small book-read-only `sourceFillEntries` packet in
`PDV_Phase20_P2ImmersiveReceivers.manifest.json`. That approval is not a
runtime-proof claim and does not authorize quest-stage or non-P2 fills.

Local quest-stage readback is now available for all 763 scan-table quest
candidates. That readback proves record identity, stage indices, completion
flags, failure flags, fragments, objectives, and aliases. It does not by itself
prove theology, player-facing meaning, or receiver safety.

## Status Model

Use both fields. Do not collapse semantic quality into fill permission.

| Field | Values | Meaning |
|---|---|---|
| `semanticVerdict` | `strong`, `plausible`, `weak`, `no-route`, `needs-lore-review` | Whether the local readback plus UESP / Imperial Library / PDV design authority supports the race-route meaning. |
| `implementationStatus` | `approved-for-fill`, `receiver-needed`, `needs-stage-readback`, `manual-only`, `rejected` | Whether current implementation can safely consume the source. |

`approved-for-fill` is reserved for a source that has exact record/stage
readback, a compatible existing receiver, a duplicate guard, and a rejected
generic-nearby case. Most rows below are intentionally not fill-ready.

## High-Value Candidate Decisions

| Race | Route family | Source | Exact stage / outcome readback | semanticVerdict | implementationStatus | Accepted context | Rejected context | Duplicate / anti-farm guard | Citation |
|---|---|---|---|---|---|---|---|---|---|
| Redguard | Sect / ancestor-duty | `Skyrim.esm:01CF25` / `MS08` | Direct smoke readback: stages `200` and `201` are completion stages; stage `300` fails. | `strong` | `receiver-needed` | Stage `201` can support Crown / Hammerfell justice / ancestor-duty; stage `200` can support Forebear / exile-protection. | Generic Redguard play, bounty play, or unsplit `MS08` progress. | One-shot mutually exclusive sect marker; never score both outcomes. | UESP: [In My Time Of Need](https://en.uesp.net/wiki/Skyrim:In_My_Time_Of_Need); Imperial Library: Redguard / Yokuda / HoonDing searches. |
| Imperial | Concordat / civic compliance | `Skyrim.esm:0D517A` / `CW01A` | Inventory readback: completion `200`, fail `999`; objective row includes Legion proof path. | `strong` | `manual-only` | Legion oath / concrete public civic alignment. | Generic faction attendance, rank alone, ordinary anti-bandit violence. | One-shot oath marker; no faction-rank faucet. | UESP: [Joining the Legion](https://en.uesp.net/wiki/Skyrim:Joining_the_Legion); Imperial Library: Talos Mistake / Great War searches. |
| Nord / Imperial | Talos defiance / public pressure | `Skyrim.esm:0E2D29` / `CW01B` | Inventory readback: completion `200`, fail `999`; objective row includes Stormcloak proof path. | `strong` | `manual-only` | Stormcloak oath as public Talos / Nord identity pressure. | Generic anti-Thalmor violence, faction rank alone, ordinary Civil War progress. | One-shot oath marker; no second Talos award. | UESP: [Joining the Stormcloaks](https://en.uesp.net/wiki/Skyrim:Joining_the_Stormcloaks); Imperial Library: Talos / Great War searches. |
| Altmer / Khajiit / Nord | Dragonborn crisis / Alkosh / Kyne-Talos | `Skyrim.esm:02610C` / `MQ104` | Inventory readback: completion `160`; stages `85-160` record dragon soul absorption and Jarl reward. | `strong` | `receiver-needed` | First public Dragonborn proof, dragon soul absorption, and Whiterun recognition. | Repeated Dragonborn identity, generic dragon kills, dragon combat spam. | One-shot main-quest milestone; do not combine with generic dragon routes. | UESP: [Dragon Rising](https://en.uesp.net/wiki/Skyrim:Dragon_Rising); Imperial Library: Talos / Dragonborn / Alkosh searches. |
| Nord | Voice discipline | `Skyrim.esm:0242BA` / `MQ105` | Inventory readback: completion `160`; stages `10-160` record Greybeard summons, recognition, and Voice training. | `strong` | `receiver-needed` | Greybeard recognition and disciplined Voice learning. | Every shout use, shout cooldown loops, generic mountain travel. | Milestone only; shout-use receivers own later repeat-gated context. | UESP: [The Way of the Voice](https://en.uesp.net/wiki/Skyrim:The_Way_of_the_Voice); Imperial Library: Kyne / Talos / Thu'um searches. |
| Altmer / Nord | Sovngarde / Shor pressure | `Skyrim.esm:046EF1` / `MQ304` | Inventory readback: completion `200`; stage log names Sovngarde, Nord heroes, and Shor permission. | `strong` | `receiver-needed` | Sovngarde / Shor reality as major theological pressure. | Generic main-quest progress, Aetherius travel without race-route context. | One-shot terminal/source-marked milestone only. | UESP: [Sovngarde](https://en.uesp.net/wiki/Skyrim:Sovngarde_%28quest%29); Imperial Library: Shor / Shezarr / Wulfharth searches. |
| Altmer / Nord | Companions / Hircine pressure | `Skyrim.esm:01CEF4` / `C03` | Inventory readback: completion `200`; stage `25` records werewolf blood and Circle ascension. | `strong` | `receiver-needed` | Beast-blood transition, Circle entry, Hircine pressure. | Companions membership, warrior society alone, Silver Hand combat. | Transition marker only; curse-state route must not double-score. | UESP: [The Silver Hand](https://en.uesp.net/wiki/Skyrim:The_Silver_Hand); Imperial Library: Hircine / Companions / Shor searches. |
| Nord | Arkay / Hircine cure edge | `Skyrim.esm:01CEF6` / `C06` | Inventory readback: completion `200`; stages `30-200` record Kodlak cleansing and Sovngarde resolution. | `strong` | `receiver-needed` | Kodlak cure / death-order restoration / Sovngarde honor. | Generic tomb clear, undead kills, Companions rank. | One-shot cure/restoration marker; no generic tomb faucet. | UESP: [Glory of the Dead](https://en.uesp.net/wiki/Skyrim:Glory_of_the_Dead); Imperial Library: Arkay / Hircine / Tsun searches. |
| Altmer / Breton | Magnus / magic stewardship | `Skyrim.esm:01F258` / `MG08` | Inventory readback: completion `200`; stage `200` records Psijic removal of the Eye and Arch-Mage appointment. | `plausible` | `receiver-needed` | Eye of Magnus crisis stewardship and Psijic-adjacent restraint. | College membership, generic spellcasting, ordinary mage progression. | One-shot finale only. | UESP: [The Eye of Magnus](https://en.uesp.net/wiki/Skyrim:The_Eye_of_Magnus); Imperial Library: Magnus / Syrabane / Psijic searches. |
| Dunmer | Azura / Reclamation or deviation | `Skyrim.esm:028AD6` / `DA01` | Inventory readback: completions `100` and `110`, fail `250`; stage `100` cleanses Azura's Star, stage `110` completes Black Star. | `strong` | `receiver-needed` | Stage `100` as Azura restoration; stage `110` as deviation / corruption pressure. | Generic Daedric artifact ownership or unsplit quest progress. | Mutually exclusive one-shot marker. | UESP: [The Black Star](https://en.uesp.net/wiki/Skyrim:The_Black_Star); Imperial Library: Azura / Reclamations searches. |
| Dunmer / Orc | Boethiah focus or taboo pressure | `Skyrim.esm:04D8D6` / `DA02` | Inventory readback: completions `50` and `100`; stages `10-40` record sacrifice, Boethiah task, champion proof. | `strong` | `receiver-needed` | Boethiah initiation, sacrifice, champion proof, false-authority overthrow if route-specific. | Any follower death, generic cruelty, random betrayal, violence spam. | One-shot plus validated sacrifice/quest-stage context. | UESP: [Boethiah's Calling](https://en.uesp.net/wiki/Skyrim:Boethiah%27s_Calling); Imperial Library: Boethiah / Changed Ones searches. |
| Nord / Bosmer | Hircine hunt law | `Skyrim.esm:02A49A` / `DA05` | Inventory readback: completions `100` and `105`, fail `205`; stage `100` kills Sinding, stage `105` defends Sinding. | `strong` | `receiver-needed` | Mutually exclusive Hircine hunt-law outcome. | Generic animal kills, generic werewolf state, ordinary Falkreath travel. | One-shot final choice; no kill-loop source. | UESP: [Ill Met By Moonlight](https://en.uesp.net/wiki/Skyrim:Ill_Met_By_Moonlight); Imperial Library: Hircine searches. |
| Argonian / Imperial | Void / Sithis or civic rejection | `Skyrim.esm:01EA50` / `DB01`; `Skyrim.esm:01EA59` / `DB11` | `DB01` completion `200`; `DB11` completion `200`. | `plausible` | `receiver-needed` | Dark Brotherhood threshold or terminal assassination as Sithis / civic rupture evidence. | Generic murder, stealth, assassination contracts, ordinary crime. | Threshold markers only; no murder faucet. | UESP: [With Friends Like These...](https://en.uesp.net/wiki/Skyrim:With_Friends_Like_These...), [Hail Sithis!](https://en.uesp.net/wiki/Skyrim:Hail_Sithis%21); Imperial Library: Sithis / Night Mother searches. |
| Dunmer / Imperial / Khajiit | Nocturnal debt / theft institution | `Skyrim.esm:021554` / `TG08B`; `Skyrim.esm:021555` / `TG09` | Both complete at `200`; `TG08B` recovers Skeleton Key, `TG09` returns it and grants Nightingale status. | `plausible` | `receiver-needed` | Nightingale oath, Nocturnal debt, Skeleton Key restoration. | Generic theft, Thieves Guild membership, ordinary crime loops. | One-shot commitment/debt marker; one owner between quest-stage and item/source receiver. | UESP: [Blindsighted](https://en.uesp.net/wiki/Skyrim:Blindsighted), [Darkness Returns](https://en.uesp.net/wiki/Skyrim:Darkness_Returns); Imperial Library: Nocturnal / Nightingales searches. |
| Breton | Knight's Road / Stendarr-Arkay protection | `Dawnguard.esm:002F65` / `DLC1VQ02` | Inventory readback: completions `180`, `190`, `200`; exact branch meaning still needs side-specific review. | `strong` | `needs-stage-readback` | Refusing Harkon's gift and committing to Dawnguard protection if branch is isolated. | Rumor/startup, generic vampire kills, radiant hunter jobs. | One faction-choice marker; side branch must be explicit. | UESP: [Bloodline](https://en.uesp.net/wiki/Skyrim:Bloodline), [A New Order](https://en.uesp.net/wiki/Skyrim:A_New_Order); Imperial Library: Stendarr / Arkay searches. |
| Breton / Dunmer / Nord | Witchcraft / Volkihar deviation / curse rupture | `Dawnguard.esm:002F65` / `DLC1VQ02` | Same readback as above; branch stages need side-specific confirmation. | `strong` | `needs-stage-readback` | Accepting Harkon's gift / Volkihar commitment if exact branch is isolated. | Ordinary vampirism, generic vampire powers, generic vampire kills. | One faction-choice marker plus curse transition; curse-state route must not double-score. | UESP: [Bloodline](https://en.uesp.net/wiki/Skyrim:Bloodline), [Vampire Lord](https://en.uesp.net/wiki/Skyrim:Vampire_Lord); Imperial Library: Molag Bal / vampires searches. |
| Nord / Redguard / Argonian | Arkay / Far Shores / Void threshold | `Dawnguard.esm:00284F` / `DLC1VQ04` | Inventory readback: completion `200`; stage indices include Soul Cairn entry path. | `plausible` | `needs-stage-readback` | Explicit Soul Cairn entry fork: Vampire Lord or partial soul trap. | Castle Volkihar exploration, repeated Soul Cairn loads, generic undead kills. | One-shot entry milestone; not every worldspace load. | UESP: [Chasing Echoes](https://en.uesp.net/wiki/Skyrim:Chasing_Echoes), [Soul Cairn](https://en.uesp.net/wiki/Skyrim:Soul_Cairn); Imperial Library: Arkay / Ideal Masters searches. |
| Altmer | Auri-El relic / solar theology | `Dawnguard.esm:002853` / `DLC1VQ07` | Inventory readback: completion `200`; stage details are present but need branch text/lore review. | `strong` | `needs-stage-readback` | Acquiring Auriel's Bow through Touching the Sky. | Forgotten Vale travel, Falmer kills, Falmer-text reading. | One artifact milestone; item acquisition receiver may be better owner. | UESP: [Touching the Sky](https://en.uesp.net/wiki/Skyrim:Touching_the_Sky), [Auriel's Bow](https://en.uesp.net/wiki/Skyrim:Auriel%27s_Bow); Imperial Library: Auri-El searches. |
| Altmer / Breton / Imperial / Nord | Auri-El versus Molag Bal final outcome | `Dawnguard.esm:007C25` / `DLC1VQ08` | Inventory readback: completion `200`; side/outcome safety still needs exact review. | `strong` | `needs-stage-readback` | Harkon defeated in final confrontation. | Generic vampire kills, eclipse attacks, radiant Dawnguard/Volkihar combat. | One final marker; side/outcome readback required. | UESP: [Kindred Judgment](https://en.uesp.net/wiki/Skyrim:Kindred_Judgment); Imperial Library: Auri-El / Molag Bal searches. |
| Altmer | Lorkhan Tier 3 mortal-continuity | `HearthFires.esm:0042B4` / `BYOHRelationshipAdoption` | Inventory readback: stages `0`, `10`; no completion flag. | `plausible` | `receiver-needed` | Completed adoption as mortal-continuity dissonance if a narrower receiver proves the outcome. | Adoptable availability, orphanage scheduler, courier, child AI packages. | Once per adoption; Altmer Tier 3 daily cap. | UESP: [Adoption](https://en.uesp.net/wiki/Skyrim:Adoption); Imperial Library: Altmer / Lorkhan searches. |
| Altmer | Lorkhan Tier 3 homestead | `HearthFires.esm:00305D` / `BYOHHouseBuilding` | Inventory readback: stages `1`, `2`, `3`, `10`, `100`, `110`, `120`, `150`; no completion flag. | `plausible` | `receiver-needed` | Player-legible homestead build/ownership milestone after exact milestone selection. | Lumber buying, raw crafting, steward offer, housecarl dialogue. | Once per homestead milestone; Altmer Tier 3 daily cap. | UESP: [Build Your Own Home](https://en.uesp.net/wiki/Skyrim:Build_Your_Own_Home), [Construction](https://en.uesp.net/wiki/Skyrim:Construction); Imperial Library: Altmer / Lorkhan searches. |
| Dunmer | Mora / deviation pressure | `Dragonborn.esm:017F8F` / `DLC2MQ02` | Inventory readback: completion `200`. | `strong` | `needs-stage-readback` | First Apocrypha / Miraak identity-theft threshold after stage meaning is pinned. | Generic Temple progress, combat, worldspace load. | One-shot major threshold; avoid Black Book double-score. | UESP: [The Temple of Miraak](https://en.uesp.net/wiki/Skyrim:The_Temple_of_Miraak); Imperial Library: Hermaeus Mora / Black Books searches. |
| Dunmer | Mora / forbidden knowledge | `Dragonborn.esm:016E1F` / `DLC2MQ04` | Inventory readback: completion `550`. | `strong` | `needs-stage-readback` | Protected Black Book retrieval/opening and Neloth/Mora pressure. | Generic Dwemer exploration, Tel Mithryn travel, Nchardak traversal. | One-shot source marker; choose quest-stage or BookRead owner. | UESP: [The Path of Knowledge](https://en.uesp.net/wiki/Skyrim:The_Path_of_Knowledge); Imperial Library: Hermaeus Mora / Black Books searches. |
| Dunmer | Mora / community-cost deviation | `Dragonborn.esm:0179DE` / `DLC2MQ05` | Inventory readback: completion `1000`. | `strong` | `needs-stage-readback` | Storn / Skaal secrets bargain once exact stage meaning is confirmed. | Generic main-quest progress, Neloth dialogue, Mora dialogue without outcome. | One-shot outcome; no repeat from Apocrypha travel. | UESP: [The Gardener of Men](https://en.uesp.net/wiki/Skyrim:The_Gardener_of_Men); Imperial Library: Skaal / All-Maker / Hermaeus Mora searches. |
| Dunmer | Solstheim liberation / Mora resolution | `Dragonborn.esm:0179D7` / `DLC2MQ06` | Inventory readback: completion `550`. | `plausible` | `needs-stage-readback` | Final Miraak defeat / liberation if route mapping is accepted. | Chapter traversal, dragon riding, generic Apocrypha combat. | Terminal one-shot only. | UESP: [At the Summit of Apocrypha](https://en.uesp.net/wiki/Skyrim:At_the_Summit_of_Apocrypha); Imperial Library: Hermaeus Mora / Miraak searches. |
| Dunmer | Raven Rock / ancestor-community | `Dragonborn.esm:018B13` / `DLC2RR01`; `018B14` / `DLC2RR02`; `018B15` / `DLC2RR03` | Inventory readback: all complete at `200`. | `plausible` | `manual-only` | Raven Rock defense, mine truth/restoration, or Redoran protection as future community hooks. | Generic ash spawn combat, dungeon clear, local politics, favor loops. | One-shot terminal only; needs route decision. | UESP: [March of the Dead](https://en.uesp.net/wiki/Skyrim:March_of_the_Dead), [The Final Descent](https://en.uesp.net/wiki/Skyrim:The_Final_Descent), [Served Cold](https://en.uesp.net/wiki/Skyrim:Served_Cold); Imperial Library: Dunmer / Redoran searches. |

## Semantic Audit Queue

These are semantically interesting but not ready for source-fill:

- Dragonborn Black Book controller quests: likely better owned by BookRead than
  quest-stage to avoid double-scoring.
- Dawnguard Soul Cairn and Serana cure paths: strong Arkay / death-order
  themes, but need branch-safe stage review and likely curse-state or
  shrine/effect ownership decisions.
- HearthFires adoption and homestead rows: strong Altmer Tier 3
  mortal-continuity themes, but current quest-stage readback lacks a clean
  terminal completion flag.
- Dragonborn Raven Rock / Skaal rows: useful for future Solstheim community or
  All-Maker work, but not current Dunmer Reclamation fill.
- `Update.esm` duplicate rows: use only if the Update record materially changes
  the winning stage or fragment evidence. Otherwise treat as duplicate evidence.

## Current Fill Verdict

The Phase 20 safe receiver tranche authorizes only the P2 book-read entries
listed in `PDV_Phase20_SourceFillApprovalLedger.json` and mirrored in
`PDV_Phase20_P2ImmersiveReceivers.manifest.json`.

Approved live-fill shape:

- `PDV_FLST_P2_BretonHiddenArtSources`: hagraven / Reach occult / Anise note
  book sources.
- `PDV_FLST_P2_DunmerAzuraSources`: Azura-specific devotional/lore books.
- `PDV_FLST_P2_DunmerBoethiahSources`: Boethiah-specific book sources.
- `PDV_FLST_P2_ImperialPublicTalosSources`: `The Talos Mistake`.
- `PDV_FLST_P2_NordOldWaysSources`: Nord identity and Sovngarde books.
- `PDV_FLST_P2_NordHircineArkaySources`: one non-duplicate Totems of Hircine
  book source.

Still blocked from live fill:

- Quest-stage sources until exact-stage receiver gating exists.
- Non-P2 sources until matching receiver/FormList support exists.
- Duplicate abbreviated books, shrine blessings, spell effects, generic faction
  records, and broad lore-only records.
