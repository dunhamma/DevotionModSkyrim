# PDV Daedric Section 11 Contract Cells (Batch B)

**Status:** DRAFT (no-deploy prep)
**Created:** 2026-06-19
**Provenance:** Compiled by reading `references/phase4/PDV_DaedricRacePrinceMatrix.csv`, `references/PDV_RaceArchitecture_DesignReference.md` Section 11, `PDV_Architecture_v3.md` Sections 11.1-11.6 and 25.9 (Section 11 contract-field rule at line 2386), `references/authoring/PDV_Daedric_DecisionPacket_CAT4.md` (D-15..D-18), `references/authoring/PDV_DaedricBoonPriceReviewSheet.md`, `references/authoring/PDV_DaedricPactRedesign.md`, `references/authoring/PDV_DaedricPrinceRecordContracts.json` (cited as implementation source of truth), and `race-sheets/PDV_DaedricContent_Manifest.md` Sections 7.5, 7.6, 7.8, 7.9, 7.11-7.14. Nothing in this file deploys or changes the live build.

---

## 1. Purpose and scope

`PDV_Architecture_v3.md` Section 25.9 (line ~2386) requires that, before any Daedric slice is coded or CK-authored, the compressed per-race cells from `PDV_DaedricRacePrinceMatrix.csv` be expanded into the Section 11 contract fields. `PDV_RaceArchitecture_DesignReference.md` Section 11.11 names the required field set; this document is the Batch B expansion for eight Princes:

Sheogorath, Namira, Sanguine, Clavicus Vile, Hermaeus Mora, Nocturnal, Peryite, Hircine.

Per the prompt, the eleven contract fields per Prince are: surface type, response state, boon, price, stigma, faith friction, vanilla hook priority, buildability, exit route, residue, required feedback. Each Prince block fills all eleven, or marks a field `UNSPEC -- needs ruling` and forwards it to Section 4 (open questions). Each block also names the vanilla quest hook (the DA-code/stage equivalent) the Prince routes from.

This is a content/architecture handoff artifact. It does not carry runtime proof, world placement, or ESP/readback evidence -- those remain on the code track per D-18.

## 2. Field-to-source crosswalk (locked authorities)

Every field below maps to a locked source. Where two sources disagree, the cited authority wins and the divergence is raised in Section 4.

| Contract field | Authority used here | Notes |
|---|---|---|
| Surface type | matrix `PrincePathType` + design-ref Section 11.7 | Sheogorath = `Madness-disruption-instability`, etc. Maps to the locked Prince path identity. |
| Response state | record-contracts JSON `stateByRace` (implementation source of truth per its own `sourceOfTruth` field) | Six-state vocabulary: Native / Legible / Tolerated / Taboo / Hostile / Curse (design-ref Section 11.5). The matrix CSV prose carries the per-race exit/friction narrative. |
| Boon | record-contracts JSON `boons[*].effects` + review sheet | Exact AV + magnitude per tier. NOT invented. |
| Price | record-contracts JSON `prices[*].effects` + review sheet | Exact AV + magnitude per tier. Single primary price per design-ref Section 11.3. |
| Stigma | D-15 weight class (record-contracts `stigmaClass`) + four-band `WitchcraftExposure` model | Bands: Latent 0-25 (no notif), Suspected 26-50, Known 51-75, Notorious 76-100. |
| Faith friction | matrix per-race cells + design-ref Section 11.9 | Which native substrate/patron layer each commitment strains. |
| Vanilla hook priority | matrix `VanillaHookPriority` / record-contracts `hookSource` + design-ref Section 11.8 | The DA-code/stage route, in priority order. |
| Buildability | matrix `BuildabilityTag` | All eight are `Vanilla Hook`. |
| Exit route | manifest exit row + matrix per-race cell + D-13 mixed-recovery default | Renounce vs cure (curse-access) per D-16. |
| Residue | D-15.3 (`WasChampion` one-way flag; stigma decays fully to Latent at 1/day) | The only permanent residue is the dialogue flag; mechanical stigma clears. |
| Required feedback | design-ref Section 11.11 player-feedback rule + manifest authored slots | Taboo/Hostile/Curse commitments MUST surface explicit feedback, not silent piety math. |

### 2.1 Tier vocabulary (shared)

Daedric tiers are `Seeker` / `Devoted` / `Champion` (design-ref Section 11.2 labels them `Touched` / `Bound` / `Claimed`; the shipped/authored copy uses Seeker/Devoted/Champion). Piety thresholds reuse the Aedric spine: Seeker 25 / Devoted 50 / Champion 85.

### 2.2 Magnitude model note

Two magnitude sources exist. `PDV_DaedricPactRedesign.md` (2026-06-11) describes a high-stakes ~2x band scheme (skill +10/+18/+25, rate/resist +15/+25/+35). The later V2 balance pass in `PDV_DaedricBoonPriceReviewSheet.md` and the generated `PDV_DaedricPrinceRecordContracts.json` (generated 2026-06-12) carry per-Prince final values on a lower band (skill +10/+15/+20, rate/resist +10/+15/+20, etc.). This document cites the record-contracts JSON / review-sheet values as the current per-Prince authority. The scheme-level reconciliation is raised in Section 4.

### 2.3 Response-state source note

The record-contracts JSON `stateByRace` is the implementation array consumed by `PDV_DaedricPathBase.StateByRace`. In a few cells it diverges from the matrix CSV prose (e.g. Hircine Altmer, Hircine Bosmer). Per the MEMORY CAT-6 lesson (verify which side is authoritative before "fixing"), this document treats the JSON array as the implementation source of truth for the response-state field and flags the prose/JSON divergences in Section 4 rather than silently reconciling them.

---

## 3. Per-Prince contract blocks

Race-order for response-state and exit-difficulty arrays is the canonical 10-race order: Nord, Imperial, Breton, Dunmer, Altmer, Khajiit, Bosmer, Redguard, Orc, Argonian. Exit difficulty: 0=easy, 1=normal, 2=hard, 3=structurally hard.

### 3.1 Sheogorath

- **Vanilla quest hook (route from):** `The Mind of Madness` (Pelagius quest) > `Wabbajack` artifact use > repeated instability/unstable-bargain choices. Design-ref Section 11.8 anchor: `The Mind of Madness`, Wabbajack, reality-disrupting outcomes.
- **Surface type:** `Madness-disruption-instability` (matrix PrincePathType). Standard external pact. Must stay distinct from Sanguine (indulgence) and Rajhin-style trickster cunning.
- **Response state:** Taboo for nine races; Tolerated only for Redguard. Per JSON `stateByRace`: Nord/Imperial/Breton/Dunmer/Altmer/Khajiit/Bosmer/Orc/Argonian = Taboo, Redguard = Tolerated. (Matrix CSV prose reads Redguard as Taboo; see Section 4.) Khajiit cell acknowledges Sheggorath as lattice dark-pressure, not devotion.
- **Boon:** Magicka regeneration (MagickaRateMult) +10% / +15% / +20% (Seeker/Devoted/Champion). Chaotic magical throughput; "solutions arrive from the wrong angle."
- **Price:** Restoration -8 / -12 / -15. Skill/social price band; control erodes as the Madgod's touch spreads.
- **Stigma:** Weight class `Standard` (1.0x base accrual), then scaled by StigmaModByRace. Four-band model; three authored crossing notifications (Suspected/Known/Notorious). Slot prefix `PDV_Notif_Daedric_Sheo_Stigma_*`.
- **Faith friction:** Strains oath-stability and kin-bonds (Nord); the rule-of-law / civic frame (Imperial); disciplined Apotheosis (Altmer); the House-of-Troubles resistance-not-devotion test (Dunmer); honor and duty (Redguard); the plain spoken code (Orc); the lunar substrate held at its dark edge (Khajiit, Sheggorath).
- **Vanilla hook priority:** Buildable. Quest outcome > artifact use > domain-aligned instability choices.
- **Buildability:** `Vanilla Hook` (matrix BuildabilityTag).
- **Exit route:** Renounce / abandonment (D-13 mixed recovery default; rites or authored beats may accelerate). Manifest `PDV_Msg_Daedric_Sheo_Exit` ("Sheogorath's Indifference") -- the disruption drains out slowly; residue persists.
- **Residue:** Stigma decays fully to Latent at 1/day (D-15.3). The only permanent residue is the one-way `PDV.Daedric.Sheogorath.WasChampion` dialogue flag set on first Champion entry. No live mechanical penalty after exit.
- **Required feedback:** Taboo path -- explicit feedback mandatory (design-ref 11.11). Provided by authored commitment MessageBox, Champion-entry MessageBox, per-race Response MessageBox, stigma band notifications, neglect texture, and exit MessageBox; boon/price passive SPEL descriptions carry the standing texture.

### 3.2 Namira

- **Vanilla quest hook (route from):** `The Taste of Death` (Namira cannibal quest) > `Ring of Namira` artifact > corpse-taboo / chosen-outcast-solidarity acts.
- **Surface type:** `Revulsion-decay-outcast-hunger` (matrix PrincePathType). Standard external pact. Strong social and ancestor friction.
- **Response state:** Per JSON `stateByRace`: Nord=Taboo, Imperial=Taboo, Breton=Legible, Dunmer=Taboo, Altmer=Taboo, Khajiit=Tolerated, Bosmer=Legible, Redguard=Tolerated, Orc=Tolerated, Argonian=Taboo. (Manifest prose text reads Bosmer/Redguard as Taboo and Khajiit as Legible -- see Section 4 for the JSON-vs-prose divergence.)
- **Boon:** Health regeneration (HealRateMult) +10% / +15% / +20%. Outcast sustenance -- "what they revile sustains you."
- **Price:** Speech (Speechcraft) -8 / -12 / -15. Social-revulsion cost made explicit.
- **Stigma:** Weight class `Standard` (1.0x). Four-band model; crossings `PDV_Notif_Daedric_Namira_Stigma_*` (filth-path readability).
- **Faith friction:** Strains hearth/honor and the honored dead (Nord); the civic-and-religious community frame (Imperial); ancestor-and-social law (Redguard); the Green Pact continuity-and-covenant (Bosmer); the Reclamations/ancestor center (Dunmer); the Apotheosis purity project (Altmer); the lattice dark-pressure of Namiira (Khajiit). Breton outcast-witchcraft heritage makes it legible, not rooted.
- **Vanilla hook priority:** Quest outcome (`The Taste of Death`) > artifact (`Ring of Namira`) > corpse-taboo acts.
- **Buildability:** `Vanilla Hook`.
- **Exit route:** Renounce / cleansing (D-13). Manifest `PDV_Msg_Daedric_Namira_Exit` ("Namira's Release") -- hunger fades, revulsion becomes ordinary; residue persists.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3).
- **Required feedback:** Mostly Taboo -- explicit feedback mandatory; provided by the authored commitment/Champion/response/stigma/neglect/exit slots. Legible cells (Breton/Bosmer) may use lighter feedback but still need the exposed commitment/pressure state.

### 3.3 Sanguine

- **Vanilla quest hook (route from):** `A Night to Remember` (Sanguine quest) > `Sanguine Rose` artifact > explicit excess/temptation threshold. NOT generic tavern-sleep -- commitment requires a genuine excess threshold (matrix note).
- **Surface type:** `Excess-temptation-indulgence` (matrix PrincePathType). Standard external pact, intentionally light-touch / unreliable. Distinct from Nocturnal (oath) and Clavicus Vile (contract).
- **Response state:** Per JSON `stateByRace`: Nord=Taboo, Imperial=Taboo, Breton=Tolerated, Dunmer=Taboo, Altmer=Tolerated, Khajiit=Tolerated, Bosmer=Legible, Redguard=Tolerated, Orc=Tolerated, Argonian=Tolerated. (Manifest prose summary phrases Breton/Altmer slightly differently; see Section 4.)
- **Boon:** Speech (Speechcraft) +10 / +15 / +20. Socially powerful -- "excess easy to carry into the room."
- **Price:** Magicka regeneration (MagickaRateMult) -5% / -10% / -15%. Survival/resource band; disciplined focus dulls.
- **Stigma:** Weight class `Standard` (1.0x). Four-band crossings `PDV_Notif_Daedric_Sanguine_Stigma_*`.
- **Faith friction:** Strains discipline-and-honor (Nord); civic self-discipline (Imperial); disciplined Apotheosis (Altmer); the disciplined warrior / kept oath (Redguard); Malacath's endurance code (Orc); ancestor-duty / Reclamations (Dunmer); the Sangiin dark-pressure edge of the lunar lattice (Khajiit). Breton/Bosmer read it socially but not as a core theological lane.
- **Vanilla hook priority:** Quest outcome > artifact (`Sanguine Rose`) > genuine excess contexts. Anti-farm: the excess threshold gate is load-bearing so the path is not "go to tavern, gain devotion."
- **Buildability:** `Vanilla Hook`.
- **Exit route:** Renounce / abandonment (D-13). Manifest `PDV_Msg_Daedric_Sanguine_Exit` ("Sanguine's Shrug") -- ease lifts, "the door is not locked"; residue persists.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3).
- **Required feedback:** Taboo cells require explicit feedback; Tolerated/Legible cells may use lighter feedback but still need the exposed commitment/pressure state because a boon/price exists. All authored slots present.

### 3.4 Clavicus Vile

- **Vanilla quest hook (route from):** `A Daedra's Best Friend` (Barbas quest) > `Masque of Clavicus Vile` / `Rueful Axe` choice > explicit wish-at-cost / deal logic.
- **Surface type:** `Bargain-wish-contract` (matrix PrincePathType). Standard external pact. Matrix note: keep the bargain price visible in the price descriptions; distinct from Sanguine and Nocturnal despite temptation overlap.
- **Response state:** Per JSON `stateByRace`: Nord=Taboo, Imperial=Taboo, Breton=Legible, Dunmer=Taboo, Altmer=Tolerated, Khajiit=Tolerated, Bosmer=Tolerated, Redguard=Tolerated, Orc=Tolerated, Argonian=Tolerated. (Manifest prose summary reads Altmer as Taboo and several Tolerated as Foreign; see Section 4.)
- **Boon:** Carry Weight (CarryWeight) +25 / +50 / +75. Separate carry-weight scale so the bargain is competitive; "more than you should carry."
- **Price:** Magicka regeneration (MagickaRateMult) -5% / -10% / -15%. Fine print taxes reserves; backlash/exploitative terms arrive later. (Bargain-visibility requirement satisfied by the price description prose.)
- **Stigma:** Weight class `Standard` (1.0x). Four-band crossings `PDV_Notif_Daedric_Vile_Stigma_*`.
- **Faith friction:** Strains straightforward earned-honor (Nord); civic virtue / the honest contract (Imperial); disciplined Apotheosis (Altmer); the kept covenant / honest agreement (Redguard); the plain spoken oath of Malacath's code (Orc); House-duty / ancestor-debt (Dunmer). Breton contract-magic heritage makes it legible; Khajiit/Bosmer surface-overlap with Rajhin/Baan Dar cunning but no native root.
- **Vanilla hook priority:** Quest outcome (`A Daedra's Best Friend`) > artifact choice (Masque vs Rueful Axe) > deal logic.
- **Buildability:** `Vanilla Hook`.
- **Exit route:** Renounce / abandonment (D-13). Manifest `PDV_Msg_Daedric_Vile_Exit` ("Vile's Discard") -- outstanding obligations resolve "slightly worse than you would prefer"; residue persists. Redguard/Orc cells require restoring or renouncing the terms of any deal Vile arranged.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3).
- **Required feedback:** Taboo cells mandatory explicit feedback; Tolerated/Legible cells lighter but still exposed. All authored slots present.

### 3.5 Hermaeus Mora

- **Vanilla quest hook (route from):** `Discerning the Transmundane` > `Oghma Infinium` > `Black Book` acceptance (Apocrypha, Dragonborn DLC). Strong on Solstheim.
- **Surface type:** `Forbidden-knowledge-artifact` (matrix PrincePathType). Standard external pact. Khajiit Hermorah is legible but not lunar-replacing; Bosmer Herma-Mora is kept explicitly separate and is NOT this path (design-ref 11.6 correction).
- **Response state:** Per JSON `stateByRace`: Nord=Taboo, Imperial=Taboo, Breton=Legible, Dunmer=Taboo, Altmer=Tolerated, Khajiit=Tolerated, Bosmer=Legible, Redguard=Tolerated, Orc=Taboo, Argonian=Tolerated. (Matrix CSV prose reads Altmer as Taboo, Bosmer/Redguard/Argonian as Foreign; the JSON maps Foreign to its nearest implemented bucket -- see Section 4.)
- **Boon:** Alteration +10 / +15 / +20. Forbidden study of form -- "the shape beneath the spell"; spell insight and dangerous-text access.
- **Price:** Stamina regeneration (StaminaRateMult) -5% / -10% / -15%. Survival/resource band; "thought pulled away from the body" -- agency erosion / knowledge corruption.
- **Stigma:** Weight class `Standard` (1.0x). Four-band crossings `PDV_Notif_Daedric_Mora_Stigma_*`. EditorID note: `Mora` token; some suffixed IDs exceed 32 chars (flagged for Phase 19 abbreviation review, not renamed now).
- **Faith friction:** Strains the Nord mythic frame (no Apocrypha wing in Sovngarde); civic public trust (Imperial); the Apotheosis purity project, where study is misread as worship (Altmer); ancestor/Reclamation faith (Dunmer); Malacath's endurance code (Orc); the lunar substrate (Khajiit, Hermorah legible-not-rooted); the Green Pact distance from Herma-Mora the story (Bosmer). Breton intellectual/conjuration inheritance makes it legible.
- **Vanilla hook priority:** Quest outcome (`Discerning the Transmundane`) > artifact (`Oghma Infinium`) > Black Book acceptance.
- **Buildability:** `Vanilla Hook`.
- **Exit route:** Renounce / withdrawal (D-13). Manifest `PDV_Msg_Daedric_Mora_Exit` ("Mora's Release") -- direct archive access withdraws, learned knowledge remains; residue persists.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3).
- **Required feedback:** Taboo cells mandatory explicit feedback; Legible/Tolerated cells lighter but still exposed. All authored slots present.

### 3.6 Nocturnal

- **Vanilla quest hook (route from):** Thieves Guild questline > Nightingale oath (`Trinity Restored`) > `Skeleton Key` threshold. NOTE: faction-oath surface, not a standalone Daedric quest (design-ref 11.7); the Skeleton Key does NOT count toward vanilla Oblivion Walker.
- **Surface type:** `Shadow-oath-luck-debt` (matrix PrincePathType). FactionOathSurface expansion type (design-ref 11.11), NOT StandaloneDaedricQuest. Keep Rajhin (Khajiit) and Baan Dar (Bosmer) distinct from Nocturnal.
- **Response state:** Per JSON `stateByRace`: Nord=Taboo, Imperial=Taboo, Breton=Legible, Dunmer=Taboo, Altmer=Legible, Khajiit=Taboo, Bosmer=Taboo, Redguard=Tolerated, Orc=Taboo, Argonian=Taboo. (Matrix CSV prose reads Altmer as Taboo and Argonian as Foreign; see Section 4.)
- **Boon:** Lockpicking +10 / +15 / +20. Shadow access -- "opens what should stay closed."
- **Price:** Carry Weight (CarryWeight) -15 / -25 / -35. The shadow-debt takes a cut of what you can carry out; deliberately lighter than Vile's carry-weight boon scale (review-sheet note).
- **Stigma:** Weight class `Standard` (1.0x). Four-band crossings `PDV_Notif_Daedric_Nocturnal_Stigma_*` (shadow-residue readability).
- **Faith friction:** Strains open mead-hall honor (Nord); the legal-and-divine civic order (Imperial); Aldmeri sanctioned order (Altmer); the open name / kept word (Redguard); the plain oath of Malacath's code (Orc); the Reclamation hidden-web that Nocturnal only resembles (Dunmer); Rajhin's native trickster lane (Khajiit); Baan Dar's native trickster core (Bosmer); the Hist community bond (Argonian). Breton secret-society/craft margin makes it legible.
- **Vanilla hook priority:** Faction/oath state (Thieves Guild) > Nightingale covenant > Skeleton Key. Oath/faction membership is the primary signal, not a quest reward equip.
- **Buildability:** `Vanilla Hook` (matrix BuildabilityTag), via the faction-oath surface.
- **Exit route:** Oath release / renounce (D-13). Manifest `PDV_Msg_Daedric_Nocturnal_Exit` ("Nocturnal's Release") -- the Evergloam lists the debt "settled"; residue persists. Several races (Nord/Imperial/Khajiit/Bosmer/Orc) gate cleanest exit on formal oath release.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3). Lore-flavored as the Evergloam keeping the record even after settlement, but no live mechanical penalty.
- **Required feedback:** Taboo cells mandatory explicit feedback; Legible cells lighter but still exposed. All authored slots present.

### 3.7 Peryite

- **Vanilla quest hook (route from):** `The Only Cure` (Peryite quest) > `Spellbreaker` artifact > disease/affliction contexts and unpleasant-duty acceptance. Matrix note: likely kept narrow and quest-anchored.
- **Surface type:** `Plague-order-lowest-task` (matrix PrincePathType). Standard external pact but narrow; defensive/affliction fantasy.
- **Response state:** Per JSON `stateByRace`: Nord/Imperial/Breton/Altmer/Khajiit/Bosmer/Redguard/Orc/Argonian = Tolerated; Dunmer = Taboo. (Matrix CSV prose reads most races as Foreign and only Altmer as Taboo; the implementation maps to Tolerated for the affliction-utility lane -- see Section 4.)
- **Boon:** Disease resistance (ResistDisease) +25% / +50% / +75%. Unique higher disease-resist scale (review-sheet rationale) -- "affliction easier to endure."
- **Price:** Stamina regeneration (StaminaRateMult) -5% / -10% / -15%. "Tasks grind down the body's urgency."
- **Stigma:** Weight class `Tolerated` (about 0.5x base accrual, per D-15.2 -- Meridia/Peryite). Author Suspected/Known crossings; Notorious is rare-edge only. Slots `PDV_Notif_Daedric_Peryite_Stigma_*`.
- **Faith friction:** Strains the kin-and-oath duty frame, which has no disease-cult lane (Nord); civic/divine-framed duty (Imperial); the Apotheosis purity project, the one Taboo cell (Altmer); ancestor-duty / Reclamations / House structure (Dunmer); the lunar lattice (Khajiit); the Green Pact (Bosmer); the disciplined-warrior frame (Redguard); Malacath's code, which has its own harsh assignments but a different master (Orc); the Hist community (Argonian). Breton craftworker "worst-task-done-well" strand reads it at the margin.
- **Vanilla hook priority:** Quest outcome (`The Only Cure`) > artifact (`Spellbreaker`) > disease/affliction contexts.
- **Buildability:** `Vanilla Hook`.
- **Exit route:** Renounce / reassignment (D-13). Manifest `PDV_Msg_Daedric_Peryite_Exit` ("Peryite's Reassignment") -- "the work continues without you"; residue persists.
- **Residue:** Stigma to Latent at 1/day; one-way `WasChampion` flag (D-15.3).
- **Required feedback:** Mostly Tolerated -- lighter feedback permitted (design-ref 11.11) but the commitment/pressure state must still be exposed because a boon/price exists; the Altmer Taboo cell requires explicit rupture feedback. All authored slots present.

### 3.8 Hircine

- **Vanilla quest hook (route from):** `Ill Met by Moonlight` > active werewolf (lycanthropy) state > Companions / Hunting Grounds threshold. Curse-access entry, not a chosen pact.
- **Surface type:** `Hunt-lycanthropy-predator` (matrix PrincePathType). CURSE-ACCESS Prince (D-16). The `_Commitment` slot is reframed as a curse-onset embrace: Hircine speaks when the player commits while carrying lycanthropy; gate = three Hircine-aligned signals with the wolf in play. `existingScript: true` -- Phase 13/15 mechanics are already runtime-proven, so CAT-4 Hircine is a content-surface pass only (D-16.3).
- **Response state:** Per JSON `stateByRace`: Nord=Curse, Imperial=Curse, Breton=Legible, Dunmer=Hostile, Altmer=Legible, Khajiit=Tolerated, Bosmer=Curse, Redguard=Curse, Orc=Curse, Argonian=Curse. (Matrix CSV prose reads Altmer as Hostile and Bosmer as Legible; the JSON differs on those two cells -- see Section 4 for the divergence to adjudicate.)
- **Boon:** Stamina regeneration (StaminaRateMult) +10% / +15% / +20%. The hunt read as stamina -- "hunt-sense drives the chase." Authors normally (D-16: boon/price/tier/response standard).
- **Price:** Speech (Speechcraft) -8 / -12 / -15. The predator mark unsettles civilized company -- social unease carries the price.
- **Stigma:** CURSE-STATE-DRIVEN (Model B / D-16), NOT an independent per-act Daedric counter. Social readability keys off the Phase 15 curse-state overlay (known-werewolf visibility). No standalone Hircine stigma notifications fire in V1; the per-tier price descriptions carry the social-register texture, and the race `*_CurseState_*` rows own the actual NPC reaction. The three drafted independent-stigma lines are parked in `references/authoring/PDV_V2_Backlog.md` for a future witnessed-kill notoriety enhancement. Coordination rule (D-16.2): no slot collision between `PDV_Msg_Daedric_Hircine_*` and the race `*_CurseState_*` rows.
- **Faith friction:** Strains the Sovngarde hall-soul bridge (Nord); the civic-faith frame the curse overrides (Imperial); the Apotheosis project (Altmer -- beast regression as its literal reversal); the Reclamations / ash-clean ancestor frame (Dunmer, Hostile); the moon-given Lattice form (Khajiit); the Old Contract / covenant standing (Bosmer); the Far-Shores/Tu'whacca order, with no Yokudan Hircine home (Redguard); Malacath's code, conditionally readable through disciplined strength (Orc); the Hist relation, strained but not severed (Argonian). Breton druidic/Glenmoril wild-hunt strand makes it legible at the margin.
- **Vanilla hook priority:** Curse state (active lycanthropy) is the primary gate > `Ill Met by Moonlight` quest > Companions membership. Per design-ref 11.8, curse state ranks above crime/kill signals here.
- **Buildability:** `Vanilla Hook`.
- **Exit route:** CURE path (D-16, not the renounce verb). Cure starts recovery; rites/authored beats complete it (D-13 mixed recovery). Manifest `PDV_Msg_Daedric_Hircine_Exit` ("Hircine's Release") -- Hircine's favor withdraws but "the curse remains if you carry it." Race exit copy: Nord/Imperial/Dunmer/Redguard require cure first, then rededication/restoration; Altmer cure-only; Orc gates on proving discipline; Khajiit/Argonian cure or controlled distancing.
- **Residue:** Stigma is curse-state-driven, so its "residue" is the lingering curse and its CureState recovery rather than a decaying Daedric stigma line. The one-way `WasChampion` flag (D-15.3) still applies as the permanent dialogue residue. Nord exit copy notes "the scar on the bridge remains" (Sovngarde) as authored flavor, not a live mechanical penalty.
- **Required feedback:** Curse commitment MUST surface explicit feedback (design-ref 11.11). Provided by the reframed curse-onset commitment MessageBox, Champion entry, per-race Response MessageBoxes, neglect texture, and exit MessageBox; the price descriptions carry the social register. Coordinates with (does not duplicate) the race `*_CurseState_*` surfacing.

---

## 4. Open questions (UNSPEC and to-adjudicate)

These items could not be resolved from the locked docs and need a ruling before this batch is treated as implementation-ready. No values were invented to close them.

1. Magnitude scheme reconciliation: `PDV_DaedricPactRedesign.md` (2026-06-11) specifies a high-stakes ~2x band (skill +10/+18/+25, rate/resist +15/+25/+35), but `PDV_DaedricBoonPriceReviewSheet.md` and `PDV_DaedricPrinceRecordContracts.json` (2026-06-12 V2 pass) carry lower per-Prince values (skill +10/+15/+20, rate/resist +10/+15/+20). This doc cites the later JSON/review-sheet values. Confirm the JSON is the live authority and that the redesign doc is superseded (or reconcile the two).

2. Response-state JSON-vs-prose divergences. The record-contracts JSON `stateByRace` differs from the matrix CSV / manifest prose in several cells. Adjudicate which is authoritative per Prince/race: Hircine Altmer (JSON Legible vs matrix prose Hostile) and Hircine Bosmer (JSON Curse vs prose Legible); Sheogorath Redguard (JSON Tolerated vs CSV Taboo); Hermaeus Mora Altmer (JSON Tolerated vs CSV Taboo); Nocturnal Altmer (JSON Legible vs CSV Taboo); Peryite (JSON Tolerated for nine races vs CSV Foreign for most). The "Foreign" CSV label has no direct slot in the six-state implementation enum (Native/Legible/Tolerated/Taboo/Hostile/Curse) -- confirm the intended Foreign->bucket mapping.

3. Per-Prince `StigmaModByRace` numeric arrays were read from the JSON for Boethiah only in this pass; the eight Batch B Princes' exact per-race stigma multipliers should be dumped and pinned into the contract cells before authoring rather than left to the weight-class default. UNSPEC at the per-race-multiplier grain pending that dump.

4. Residue specifics beyond the `WasChampion` flag. D-15.3 locks the one-way flag and full stigma decay, but the design-ref 11.4 also lists "lowered starting floor" and "renewed temptation pressure" as permissible residue forms. Confirm whether any Batch B Prince should carry a lowered-floor or temptation residue, or whether all eight are flag-only. UNSPEC -- needs ruling.

5. Hircine "scar on the bridge" (Nord Sovngarde) and similar authored exit-flavor lines: confirm these are narrative-only with no mechanical floor/penalty, consistent with "residue must not permanently ruin future roleplay" (design-ref 11.4).

6. Nocturnal exit gating: several race cells require "formal oath release" for the cleanest exit. Confirm whether a vanilla oath-release signal exists/is detectable, or whether the renounce verb is the fallback when no oath-release hook is available (buildability of the formal-release path).

7. EditorID length: Hermaeus Mora (`Mora`), Sheogorath (`Sheo`), Clavicus Vile (`Vile`), Sanguine, Peryite, Nocturnal, and Hircine all have suffixed slot IDs exceeding 32 chars, flagged for Phase 19 abbreviation review in the manifest. Confirm the abbreviation pass before CK authoring so slot IDs are stable.
