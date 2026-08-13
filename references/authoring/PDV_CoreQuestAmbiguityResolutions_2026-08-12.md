# Official Core Quest Ambiguity Resolutions

**Date:** 2026-08-12
**Status:** LIVING owner-decision authority; authored in the repository for the next package after v1.5.0d

The complete official-content audit covers 2,274 canonical base-game/DLC QUST
records plus 60 Creation Club records. All 18 records held for focused review
now have final owner decisions. The canonical tagged authority is
`generated/core-rows/Official_Ambiguity_Resolutions_2026-08-12.tagged.csv`; the
runtime source is `PDV_QuestReactionMatrix_Tranche14_CoreRetrospective.csv`.

| Quest | Final recognized route |
|---|---|
| `CW03` | s210 `serve_empire_order,civic_service,keep_oath`; s240 `defy_tyranny_talos,keep_oath`; s255 and old intermediate rows remain inert. |
| `BYOHHouseBanditAttack` | s100 `defend_kin_home`. |
| `BYOHHouseGiantAttack` | s10 `defend_kin_home`. |
| `BYOHHouseWolfAttack` | s10 `defend_kin_home`. |
| `BYOHHouseSkeeverInfestation` | s20 `defend_kin_home`. |
| `dunRagnvaldQST` | s30 `slay_undead,prove_by_struggle`; no funerary or duplicate combat tag. |
| `dunMossMotherQST` | s20 `heal_comfort,protect_the_weak`; s100 `friendship`; Valdr owns the burial act. |
| `DBTortureTreasureMiscObjective1` | s10 `coercion_extortion`; no separate retrieval row because the goods are surrendered under duress. |
| `DBTortureTreasureMiscObjective2` | s10 `coercion_extortion`; s200 `theft_burglary` for the unsurrendered dowry. |
| `DBTortureTreasureMiscObjective3` | s10 `coercion_extortion`; s200 `theft_burglary` for the unsurrendered cache. |
| `FreeformRiften02` | Physical s200 plus `pFFRiften02LynlyFriend`: value 0 -> synthetic s201 `expose_betray_secret`; value 1 -> synthetic s202 `deceit,protect_the_weak,keep_secret`. |
| `FreeformRiften03` | Physical s200 plus `pFFRiften03Arrested`: synthetic s201 stolen-mead delivery; synthetic s202 report to Indaryn. |
| `dunMidden01QST` | s80 `bargain_with_daedric_threat`; unique-base direct-player kill -> s100 `destroy_daedric_threat`. |
| `WE24` | Unique-base direct-player kill -> synthetic s100 `honorable_duel,prove_by_struggle`; generic combat owns the kill tag. |
| `RelationshipMarriage` | `DUPLICATE-OWNED`; `RelationshipMarriageWedding` s100 remains the sole ceremony scorer. |
| `DLC2RR03Intro` | s20 honest return `honest_labor_trade`; s25 agreed lie `deceit,theft_burglary`. |
| `DLC2SkaalVillageFreeform1` | s20 grave rite `honor_the_dead,marriage_family`; s200 return `friendship,civic_service`. |
| `ccBGSSSE025_StaadaQuest` | Item-aware physical s300 -> synthetic s301 amber/Sheogorath service or s302 sword/aid servant; s310 `resist_extortion`. |

Every positional or synthetic route carries `RUNTIME-VERIFY`. Generic combat
continues to own attributed kills, preventing quest-stage double scoring. Major
milestones in long main/faction chains may repeat commitment tags when the act
is evidenced; the daily devotion cap owns repetition control.

## Closure proof

- Tagged outcomes: 28.
- Cross-generated cells: 184, with zero approval/disapproval conflicts.
- Official checkpoint: 2,334/2,334 complete; zero `UNREVIEWED`.
- Core matrix: 4,108 cells across 354 quest EditorIDs; runtime compiler watches
  353 resolved quests.
- Release boundary: these post-v1.5.0d changes are authored and gated but are
  not part of the already-published v1.5.0d archive until the next package is
  built and released.

## Owner-approved tag/profile corrections

The review also closed the previously identified vocabulary/profile gaps. These
are runtime assignments, not documentation-only labels:

| Corrected concept | Canonical routing |
|---|---|
| Faction-home restoration | `restore_faction_home:blades` is approved by Akatosh and Talos; `restore_faction_home:dark_brotherhood` is approved by Sithis. |
| Religious persecution | `persecute_religious_worship:talos` is disapproved by Talos, Stendarr, Mara, and Stuhn. |
| Atonement/restitution | Approved by Stendarr, Mara, Zenithar, and Z'en. |
| Cultural-relic restoration | Approved by Xarxes. |
| Stolen divine relic | `recover_stolen_divine_relic:nocturnal` is approved by Nocturnal; the generic unparameterized form is retired. |
| Resisting extortion | Zenithar and Stuhn now join the existing approving profiles. |
| Coercion/extortion | Molag Bal approves it; Stendarr, Zenithar, and Z'en disapprove. |
| Enthralling/enslaving | Molag Bal approves it; Stendarr and Mara disapprove. |
| Vald's Debt | `settle_anothers_debt,recover_lost_keepsake,civic_service`; `atonement_restitution` was removed because the player is resolving Vald's debt, not atoning for their own wrong. |
