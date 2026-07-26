# PDV Dislike Consequence Design Reference

Status: V2 implementation authority, created 2026-07-07.

Scope: this packet adds a short, mild, felt disfavor sting to deity likes/dislikes rows with negative deltas. It does not change piety deltas, likes/dislikes dispatch, daily caps, cooldowns, Book of Days surfacing, Prisma toasts, neglect, rivalry, decay, Prince prices, or Daedric path deepening.

Proof boundary: D1/D2 are design and record authority. D3/D4 are compile/readback proof only. In-game felt proof remains the V2 play pass recorded in `PDV_DislikeConsequence_TestLedger.json`.

## Locked Architecture

Dislike consequences use a shared domain-keyed overlay, not bespoke per-deity debuffs. A negative likes/dislikes row expresses that a god withholds grace in its own domain for a short time. This avoids a murder or necromancy act stacking eight different god-specific penalties at once.

Papyrus cannot apply a different magnitude when adding a spell, so the implementation mints two spells per domain:

- Light: CSV `abs(baseDelta) > 0.5 && <= 1.0`, 2 in-game hours.
- Sharp: CSV `abs(baseDelta) > 1.0`, 4 in-game hours.

Rows with `abs(baseDelta) <= 0.5` remain piety-loss and surfacing only. This keeps incidental play such as trespass, inn sleep, common crafting, and mild theft from applying a felt debuff.

## Runtime Rules

- Standing gate: sting only if the player has piety `>= 25` with the offended deity, or that deity is the current active patron.
- Source gate: sting only from a generated deity likes/dislikes dispatch, identified by the current `eventType` around `ScoreAction`; no sting from decay, neglect, rivalry, Prince prices, shrine prayer, commitment carryover, or scripted penalties.
- Band gate: the source CSV row's base delta controls the band. Runtime multipliers do not upgrade or downgrade the sting.
- Refresh-not-stack: the same domain replaces/refreshes its active sting. It does not add a second instance.
- Simultaneous cap: at most three domains may be active. If a fourth different domain would fire, it is suppressed.
- Anti-repeat: a per-deity/per-domain/per-event day key prevents repeat stings from the same transgression on the same devotion day.
- Expiry: the manager owns expiry by StorageUtil game-time keys and removes the ability when it expires.
- Timed-ability invariant: all fourteen disfavor MGEFs carry `NoDuration`, and
  every parent Ability effect has `Duration = 0`. The manager-owned expiry is
  the only timer; a non-zero record duration can display in Active Effects
  without applying its ActorValue modifier.

## Domain Records

| Domain | ActorValue | Light | Sharp | Player meaning |
|---|---:|---:|---:|---|
| SkyStormHunt | ResistFrost | -2 | -4 | Weather, road, wind, hunt, and exposed travel turn cold. |
| DeathAncestors | ResistDisease | -2 | -4 | Rest, burial duty, soul passage, and ancestral order grow uneasy. |
| MercyProtection | ResistMagic | -2 | -4 | Mercy, wards, compassion, and protection thin. |
| WarHonor | OneHanded | -3 | -5 | Honor, trials, battle-virtue, and open strength falter. |
| OrderTradeLore | Speechcraft | -3 | -5 | Law, trade, study, contract, and ordered exchange sour. |
| MoonLuckShadow | Sneak | -3 | -5 | Fortune, shadow, road luck, and moonlit timing slip. |
| VoidSecrets | Magicka | -5 | -10 | Secrets, void, sap-memory, and hidden change leave a quiet unease. |

All records are detrimental, self-targeted, flat value modifiers. Regen-rate penalties are deliberately excluded because they are Requiem-fragile and belong to other lanes.

Record serialization: `Detrimental` supplies the penalty behavior, so every
disfavor spell stores the table's absolute magnitude as a positive number. The
negative signs in the table and player-facing text describe the gameplay delta.

## Deity Domain Map

| Deity actor | Domain | Sting notes |
|---|---|---|
| akatosh | OrderTradeLore | Time and lawful order withhold social/ordered steadiness. |
| alkosh | MoonLuckShadow | Khajiiti dragon-order is kept in the moon/luck cluster for this shared overlay. |
| Arkay | DeathAncestors | Life-death cycle and burial duty. |
| auri-el | OrderTradeLore | Ascension, discipline, and ancestor-order. |
| azurah | MoonLuckShadow | Dawn/dusk, prophecy, and fate. |
| Baan Dar | MoonLuckShadow | Road luck, exile wit, and trickster shadow. |
| Boethiah | VoidSecrets | Cultural Dunmer deity lane; current negative rows are sub-0.5 and do not sting. |
| Dibella | MercyProtection | Love, beauty, and restorative grace. |
| HoonDing | SkyStormHunt | The road and way-making domain. |
| Julianos | OrderTradeLore | Law, reason, and disciplined study. |
| khenarthi | SkyStormHunt | Wind, road, and soul passage. |
| Kynareth | SkyStormHunt | Sky, nature, and open-air protection. |
| kyne | SkyStormHunt | Weather, hunt, and clean battle under the sky. |
| Leki | WarHonor | Duel, sword discipline, and martial honor. |
| magnus | DeathAncestors | Soul/magicka design and anti-necromantic order. |
| Malacath | WarHonor | Strength, outcast code, and open proof. |
| Mara | MercyProtection | Compassion, household, and love. |
| Mephala | VoidSecrets | Cultural Dunmer deity lane; current negative rows are <= 0.5 and do not sting. |
| rajhin | MoonLuckShadow | Theft, prowling, and luck. |
| Shor | WarHonor | Sovngarde honor and valor. |
| sithis | VoidSecrets | Void, unmaking, and anti-permanence. |
| Stendarr | MercyProtection | Mercy, justice, and restraint. |
| Stuhn | MercyProtection | Ransom, just spoils, and warding mercy in war. |
| Talos | WarHonor | Defiance, governance, and conqueror's valor. |
| The Hist | VoidSecrets | Sap-memory, root communion, and soul return. |
| trinimac | WarHonor | Virtue, strength, and anti-Daedric martial honor. |
| Tsun | WarHonor | Trials, bridge-guarding, and worthy ordeal. |
| Tu'whacca | DeathAncestors | Soul passage and Far Shores death duty. |
| xarxes | DeathAncestors | Lineage, scribe-record, and ancestral memory. |
| Y'ffre | OrderTradeLore | First story, Green Pact law, and natural order. |
| Z'en | OrderTradeLore | Debt, labor, and fair exchange. |
| Zenithar | OrderTradeLore | Honest work, commerce, and lawful wealth. |

## Test Plan

Run one V2 in-game pass per domain, not per deity:

1. Positive: with standing, trigger a sharp-band transgression and confirm the sharp sting appears in Active Effects at the expected magnitude.
2. Standing negative: repeat without piety/patron standing and confirm piety surfacing happens but no sting appears.
3. Band negative: trigger an `abs(baseDelta) <= 0.5` disliked act and confirm no sting.
4. Anti-stack: trigger more than three domains and confirm no fourth domain pileup.
5. Requiem felt: confirm the flat penalty moves the relevant bar/stat under Requiem.
6. Refresh: repeat the same domain after expiry or with a higher band and confirm refresh/replacement, not stacking.
