# PDV Daedric Boon/Price Review Sheet

**Status:** V2 balance pass implemented in `PDV_DaedricPrinceRecordContracts.json`; Daedric pact tiers now use a replacement model, so only the current tier's boon and price should be active. ESP/readback proof is required after authoring. Runtime/manual feel remains separate evidence.

> **SUPERSEDED 2026-07-13 (Requiem M/S->Fortify conversion):** every regeneration-rate magnitude in the tables below is stale. `MagickaRateMult`/`StaminaRateMult` boons -> flat **Fortify Magicka/Stamina pool +25 / +40 / +50** (Seeker/Devoted/Champion); `HealRateMult` boons -> Fortify Health; regen PRICES -> mild negative Fortify pool (**-10 / -20 / -30**, health **-8 / -15 / -20**). Resist/skill cells (Magic Resistance, Illusion, Speech, Alteration, Restoration, Carry Weight, Disease Resistance) are UNCHANGED. Magnitudes provisional. Authority: `PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`. Cells updated inline below.

## Tier Model

Daedric pact rewards are replacement-only. Seeker gets the Seeker boon and price; Devoted replaces those with Devoted; Champion replaces those with Champion. Lower-tier Daedric pact effects should not remain active at higher tiers.

## Budget Bands

| Band | V2 Rule | Reason |
|---|---|---|
| Skill boon | +10 / +15 / +20 | Keeps Daedric pacts stronger than texture but below broad build-breaking bonuses. |
| Raw-damage boon | +5% / +8% / +12% | Direct damage is broad and combat-central, so it uses the lower combat ceiling. |
| Resist boon | +10% / +15% / +20% | Removes the old +35% ceiling from common power stats. (2026-07-13: Magicka/Stamina/Health-regen boons are no longer rate buffs -- they are flat Fortify max-pool at the Daedric scale +25 / +40 / +50.) |
| Carry-weight boon | +25 / +50 / +75 | Carry weight needs its own scale to compete with combat or regen. |
| Disease-resist boon | +25% / +50% / +75% | Disease resistance is narrow, so Peryite gets a higher but still thematic scale. |
| Skill/social price | -8 / -12 / -15 | Felt in dialogue/build expression without deleting the character. |
| Survival/resource price | -5% / -10% / -15% | Health, magicka, stamina, and armor prices are capped lower than soft prices. (2026-07-13: health/magicka/stamina-regen prices are now mild negative Fortify max-pool -- pool -10 / -20 / -30, health -8 / -15 / -20 -- not regen-rate penalties.) |
| Carry-weight price | -15 / -25 / -35 | Nocturnal's debt should matter to thieves without mirroring Vile's much larger carry-weight boon scale. |
| Movement price | -3% / -5% / -8% | Movement penalties must stay low to avoid making the game feel broken. |

## Implemented V2 Table

| Prince | Boon Seeker / Devoted / Champion | Price Seeker / Devoted / Champion | Review Rationale |
|---|---|---|---|
| Boethiah | One-Handed +10 / One-Handed +15 / One-Handed +20 | Speech -8 / Speech -12 / Speech -15 | Makes the pact a direct-combat proving path and keeps the cost social instead of build-breaking. |
| Azura | Magic resistance +10% / Magic resistance +15% / Magic resistance +20% | Fortify Stamina -10 / -20 / -30 (Maximum Stamina) | Moves Azura away from the repeated magicka-regen shell and into a clearer warded-foresight identity. |
| Vaermina | Illusion +10 / Illusion +15 / Illusion +20 | Fortify Health -8 / -15 / -20 (Maximum Health) | Keeps dream manipulation central while reducing the old health-regen penalty from punitive to felt. |
| Meridia | Restoration +10 / Restoration +15 / Restoration +20 | Illusion -8 / Illusion -12 / Illusion -15 | Replaces narrow disease resistance with a broader anti-corruption Restoration lane. |
| Molag Bal | Illusion +10 / Illusion +15 / Illusion +20 | Restoration -8 / Restoration -12 / Restoration -15 | Keeps domination as control magic and changes the price to a fair skill-for-skill loss instead of universal health-regeneration damage. |
| Mephala | Sneak +10 / Sneak +15 / Sneak +20 | Speech -8 / Speech -12 / Speech -15 | Makes the web broadly useful as stealth while the price remains social trust and honest speech. |
| Malacath | Armor rating +10 / Armor rating +15 / Armor rating +20 | Movement Speed -3% / Movement Speed -5% / Movement Speed -8% | Keeps the outcast-endurance fantasy while capping movement loss so it does not make play feel broken. |
| Mehrunes Dagon | Attack damage +5% / Attack damage +8% / Attack damage +12% | Armor rating -5 / Armor rating -10 / Armor rating -15 | Uses record-proven raw attack damage for the Prince of Destruction, paid for with lower defenses. |
| Sheogorath | Fortify Magicka +25 / +40 / +50 (Maximum Magicka) | Restoration -8 / Restoration -12 / Restoration -15 | Keeps chaotic magical throughput, but pulls it down from the old +35 ceiling. |
| Namira | Fortify Health +25 / +40 / +50 (Maximum Health) | Speech -8 / Speech -12 / Speech -15 | Preserves outcast sustenance while making the social disgust cost explicit. |
| Sanguine | Speech +10 / Speech +15 / Speech +20 | Fortify Magicka -10 / -20 / -30 (Maximum Magicka) | Makes Sanguine socially powerful and mentally costly rather than a stamina-to-speech identity swap. |
| Clavicus Vile | Carry Weight +25 / Carry Weight +50 / Carry Weight +75 | Fortify Magicka -10 / -20 / -30 (Maximum Magicka) | Uses a separate carry-weight scale so Vile's bargain is actually competitive. |
| Hermaeus Mora | Alteration +10 / Alteration +15 / Alteration +20 | Fortify Stamina -10 / -20 / -30 (Maximum Stamina) | Moves Mora away from the repeated magicka-regen shell and into forbidden study of form. |
| Nocturnal | Lockpicking +10 / Lockpicking +15 / Lockpicking +20 | Carry Weight -15 / Carry Weight -25 / Carry Weight -35 | Makes the shadow pact about access and debt: Nocturnal opens locks, then takes a cut of what you can carry out. |
| Peryite | Disease resistance +25% / Disease resistance +50% / Disease resistance +75% | Fortify Stamina -10 / -20 / -30 (Maximum Stamina) | Keeps disease resistance because it is the unique Peryite identity, but gives it a higher utility scale. |
| Hircine | Fortify Stamina +25 / +40 / +50 (Maximum Stamina) | Speech -8 / Speech -12 / Speech -15 | Makes the hunt mechanically readable as stamina, with the price carried by social unease instead of slow healing. |

## Open Review Notes

- Peryite keeps disease resistance as the unique identity, but this should be playtested because even +75% may still feel narrow.
- Vaermina and Molag Bal both use Illusion boons, but their prices now split: Vaermina pays bodily unrest while Molag Bal pays loss of Restoration/mercy. Revisit if they still feel too close in play.
- Speech remains the most common social price. That is acceptable for stigma-heavy Princes, but future design could move some prices into faction/service consequences instead of actor values.
- Nocturnal's carry-weight price is deliberately lighter than Vile's carry-weight boon scale because Lockpicking is narrower than Vile's general bargain utility.
- This sheet is a balance review artifact, not runtime proof. Active Effects, save/load, stack legibility, and manual feel need fresh in-game evidence after the ESP authoring pass.
