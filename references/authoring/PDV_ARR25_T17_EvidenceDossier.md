# ARR 2.5 T17 evidence dossier

## Scope and evidence boundary

Two bounded Terra readers used direct `housecarl_read_plugin_file` calls against
absolute ARR 2.5 plugin paths for `LegacyoftheDragonborn.esm`, `BSHeartland.esm`,
and `Wyrmstooth.esp`. The active Anvil instance was never switched. Every read
was reported out-of-load-order, so this dossier proves source-file records only;
it does not prove ARR winners, runtime delivery, player surfaces, or support.

## Authored direct evidence

| plugin | record and stages | direct evidence |
|---|---|---|
| Legacy of the Dragonborn | `2702EE` `DBM_Excavation03A|350` | Trial completion defeats Tulrin Deathweaver, prevents his planned surface war, and secures Neb-Crescen. |
| Legacy of the Dragonborn | `4E0D3F` `DBM_EchosOfMadness|100` | Completion removes the curse and restores the Eye of Camlorn, ending its influence. |
| Legacy of the Dragonborn | `5C7E75` `DBM_MuchAdoAboutSnowElves|398` | Event log says the player brought peace to a hostile Snow Elf ghost. The row retains `RUNTIME-VERIFY` because stage finality and single-fire behavior require organic observation. |
| Beyond Skyrim - Bruma | `003A58` `CYRBrumaMS01|30/50/150` | Direct alternatives return contraband to Alammu, report her for arrest, or open the parcel and keep its skooma. |
| Beyond Skyrim - Bruma | `067841` `CYRBrumaMS04|100/160/170` | Direct alternatives lead Renod into a fatal ambush, return his lute for payment, or refuse payment because Reln-Tei needs it more. |
| Beyond Skyrim - Bruma | `0CE0F1` `CYRFortPalePassMS01New|600` | Completion frees Stormcloak prisoner Bjarni after a jailbreak that ends in Legate Varro's death. |
| Beyond Skyrim - Bruma | `086207` `CYRBrumaMS07|120` | Completion recovers stolen Akaviri artifacts and helps Adius arrest the thief. |
| Wyrmstooth | `C651DA` `WTTheNakedNord|50/56/75/76/77/78/79` | Direct logs distinguish selling the pants, lying about them, the full cure-and-return result, mixed cure/theft results, and the remaining cure branches. |
| Wyrmstooth | `2F1A74` `WTUberEncounter|50` | Completion reveals and destroys the ancient lich Vulom. |
| Wyrmstooth | `B5DA18` `WTSignyFavor|30` | Objectives explicitly require stealing Erikur's debt ledger; completion hands it to Signy to remain hidden. |
| Wyrmstooth | `3A1469` `WTDaenlitFavor|30` | Stage 20 steals Erikur's enchanted necklace and stage 30 completes after delivery to Daenlit. |
| Wyrmstooth | `3943A0` `WTKillThalmor|30` | The task requests dispatch of Thalmor spies and completion says they were dealt with; runtime must confirm a single one-shot route. |

## Reviewed exclusions and deferrals

- LOTD's `DBM_ShatteredLegacy|36/38` contains meaningful Ezra alternatives,
  but each stage has multiple conditioned log variants driven by aliases, items,
  journal state, and other stages. It is `DEFER` until a stable runtime branch
  discriminator exists.
- LOTD `DBM_Excavation03Prelude` and `DBM_SpearofthSnowPrinceQuest` are linear
  setup/relic routes. The spear's meaningful placement is already within the
  Trial quest; neither receives an independent row.
- LOTD donation/refusal stages 100/101 in Much Ado only buy or refuse archive
  access. They are not treated as charity or scholarship devotion.
- Bruma's Frostcrag Synod/College endings are faction choices without a proved
  theological or moral distinction. Generic bandit clearing, Ugly Love's
  unresolved endpoints, and the wolf disposition choice are deferred or no-row.
- Wyrmstooth's `WTShargamFavor` kill-for-debt lacks enough context to classify
  the killing. The wolf disposition, miners/spriggans branch, textless rebuild,
  player-home purchase, and generic fetch/cache favors remain unrowed.
- `WTTheNakedNord|254` asks the player to kill Gjalrunn but does not prove that
  the player did so. It requires an exact dialogue/result hook before authoring.
- T13 already owns `WTBarrowOfTheWyrm|260`; T17 extends that existing channel
  rather than creating a second Wyrmstooth option.
