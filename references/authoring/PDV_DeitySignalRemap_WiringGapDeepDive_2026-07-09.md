# PDV Deity Signal Remap Wiring Gap Deep Dive - 2026-07-09

## Scope

This note explains how to close the post-remap wiring gaps without changing the locked architecture. It focuses on two different surfaces that were easy to conflate:

- Runtime/display reachability: a live deity can receive rewards/offers but still be invisible or skipped if `IsDashboardDeityInOriginRoster` and the medallion/Prisma display tables do not know about it.
- Quest matrix breadth: a deity can be live and reachable but still have too few quest-reaction rows to feel present in normal play.

Proof boundary: this is source/readback planning plus the narrow Syrabane display fix. It is not in-game display proof until the smoke run confirms Active Effects, Book of Days, Survey/status, Prisma/notification text, and save/load stack behavior.

## Current Matrix Counts

Source: `references/authoring/PDV_QuestReactionMatrix_Full.csv`, counted by `deity`.

Total rows: 876.

Low or missing rows:

| Deity | Current quest rows | Current interpretation |
| --- | ---: | --- |
| Syrabane | 0 | True wiring gap. He is now a live Altmer focus, but the matrix has no quest rows. |
| The Hist | 2 | Thin by vanilla-quest availability. Should lean on Argonian P2/non-quest sources and only add exact quest rows where the branch genuinely fits. |
| Namira | 2 | Probably acceptable for V1 if Daedric quest/faucet paths carry the Prince. Add only exact Namira outcomes. |
| Sanguine | 2 | Probably acceptable for V1 if Daedric quest/faucet paths carry the Prince. Add only exact revel/excess outcomes. |
| Vaermina | 4 | Thin but not necessarily wrong; Waking Nightmare carries the core branch. |
| Peryite | 6 | Thin but acceptable if The Only Cure plus disease/pestilence rows are exact. |
| Y'ffre | 7 | Needs a targeted Green Way/Y'ffre breadth pass, not generic nature spam. |
| Sheogorath | 8 | Low but Prince-specific enough for V1. |
| Zenithar | 10 | Needs civic/work/trade fanout review, especially Imperial/Breton/Divine rows. |

Altmer focus comparison:

| Altmer focus | Current quest rows |
| --- | ---: |
| Auri-El | 21 |
| Magnus | 12 |
| Xarxes | 18 |
| Trinimac | 15 |
| Syrabane | 0 |

## Syrabane Display Gap

Syrabane already had live implementation pieces from the remap tranche:

- `PDV_Syrabane` manager property.
- `PDV_Bless_Altmer_Syrabane_T1/T2/T3` reward spell properties.
- `PDV_Msg_Altmer_Syrabane_Offer` formal offer property.
- Altmer formal-offer eligibility includes `PDV_Syrabane`.
- `SyncAltmerRewards` includes the Syrabane reward family.

The missing pieces were the display/reachability layer:

- `IsDashboardDeityInOriginRoster` omitted `PDV_Syrabane` from `ORIGIN_ALTMER`.
- `GetAltmerMedallionEntriesJson` still emitted `PendingMedallionEntry("syrabane", ...)`.
- `GetPrismaSymbolForDeity` had no Syrabane branch.
- Prisma `app.js` had no `syrabane` display-name or glyph spec.
- `PDV_MedallionRoster.manifest.json` still described Syrabane as awaiting a live record.

Resolution applied in this pass:

- Added `PDV_Syrabane` to Altmer origin-roster reachability.
- Converted Altmer medallion Syrabane from pending to `RosterMedallionEntry`.
- Added the `syrabane` symbol resolver in manager source.
- Added a Syrabane display label and glyph to repo and live Prisma `app.js`.
- Updated the medallion manifest to point at `PDV_Deity_Syrabane`.
- Added adversary checks so Syrabane cannot silently regress to pending/invisible.

Why this matters for quest rows: `ApplyDeityReaction` checks origin reachability for ordinary non-Daedric deities. Before this fix, even correctly authored future Syrabane matrix rows could be suppressed as unreachable for Altmer display/scoring.

## Syrabane Quest-Wiring Strategy

Locked identity from the divergence ledger: Syrabane is Altmer-only first-class focus. The launch lane is narrow: warding, magical protection, apprentice/College aid, curse/disease warding, and anti-mage survival. It must not become generic magic advancement, every ward cast, raw magic-resistance farming, or generic College membership.

Use matrix-first rows for quest outcomes. Add exact-stage source fills only if the route needs concrete detector support beyond the matrix and the vanilla stage readback proves the stage.

### Implementation Closeout - Broad 8 Row Tranche

Status 2026-07-09: implemented at matrix/readback level in
`PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv`, regenerated into
`PDV_QuestReactionMatrix_Full.csv`, and compiled to the live StorageUtil JSON.

Approved Syrabane rows:

| Quest | Stage | Valence | Weight | Implementation note |
| --- | ---: | --- | --- | --- |
| `MG01` First Lessons | `200` | `+` | `S/small` | Ward lesson plus College apprentice expedition. |
| `MG03` Hitting the Books | `55` | `+` | `S/small` | Freed Orthorn, former College apprentice. |
| `MG05` Containment | `200` | `+` | `S/small` | Secured Winterhold from Eye-spawned magical anomalies. |
| `MG08` The Eye of Magnus | `200` | `+` | `m/echo` | Protective institution/apprentice echo; Magnus still owns the Eye arc. |
| `DA01` The Black Star | `110` | `-` | `m/echo` | Corrupt mortal-soul binding / Black Star branch. |
| `DA04` Discerning the Transmundane | `100` | `-` | `m/echo` | Reckless Daedric blood exploitation, not a dislike of scholarship itself. |
| `DA13` The Only Cure QE | `102` | `+` | `m/echo` | Custom QE altar-destroy branch; plague/disease warding angle. |
| `DA16` Waking Nightmare | `200` | `+` | `m/echo` | Destroyed the Skull of Corruption and warded Dawnstar from hostile dream magic. |

Explicit exclusion: `FreeformWinterholdCollegeB` / The Missing Apprentices remains
unwired despite being thematically ideal. It is unfinished content with empty
stages and no reliable playable hook, so it stays candidate-only unless a future
implementation adds a real route.

Proof moved in this pass: authority/source rows, generated matrix, StorageUtil
JSON generation, static adversary checks, default verifier, and formal-offer
coverage. Runtime-route and manual in-game behavior remain open until an Altmer
smoke run proves quest-stage reaction, Book of Days/Survey/Prisma surfacing, and
save/load stack behavior.

Candidate positive source families:

| Family | Candidate exact rows | Why it fits | Caution |
| --- | --- | --- | --- |
| Apprentice warding | `MG01` stage `200` | The completion text explicitly says the player learned wards from Tolfdir and is accompanying apprentices. | Do not credit merely joining the College before the ward/apprentice beat. |
| Apprentice aid | `MG03` stage `55` | Freeing Orthorn is an exact apprentice-aid/protection branch already readable in the stage text. | Keep it a small or echo row; do not make every book retrieval a Syrabane row. |
| Magical containment | `MG05` stage `200` | Winterhold is secured after the Eye releases dangerous magical energy. | This is protection from magic, not academic progress. |
| College crisis resolution | `MG08` stage `200` | Ancano is defeated, the Eye is removed, and the magical crisis is contained. | Magnus should still own the main Eye/Magnus arc; Syrabane should be secondary protection/apprentice framing. |
| Disease/curse warding | `DA13` accepted anti-Peryite branch candidates | Peryite's disease/pestilence frame can support Syrabane if the player rejects or cleanses the threat. | Requires exact branch route already accepted by the matrix/compiler surface; avoid generic disease curing. |
| Dream/curse protection | `DA16` stage `200` | Destroying the Skull and protecting Dawnstar from nightmares can read as warding people from hostile dream magic. | Vaermina/Mara/Stendarr already own the core branch; Syrabane should be an echo only if added. |

Candidate dislike/failure families:

| Family | Candidate exact rows | Why it fits | Caution |
| --- | --- | --- | --- |
| Corrupt soul-magic | `DA01` stage `110` | The Black Star path creates an infinite black soul gem and already carries necromancy penalties for death/purity gods. | Needs design approval because it overlaps Auri-El/Meridia/Arkay anti-necromancy space. |
| Reckless Daedric knowledge | `DA04` stage `100` | Oghma/Hermaeus completion can be read as knowledge without warding responsibility. | Magnus and Julianos currently like disciplined/forbidden study; only penalize Syrabane if the row is about Daedric recklessness, not learning. |
| Magical harm to institutions/apprentices | Future exact College/Thalmor/mage branch only | This is the cleanest negative identity if a concrete branch exists. | Do not invent a penalty from non-terminal quest progress or generic mage combat. |

Recommended first Syrabane quest tranche:

1. Add `MG01 200` as a small positive Syrabane row using existing `disciplined_study` plus protection/apprentice citation text.
2. Add `MG03 55` as a small/echo positive Syrabane row using `protect_the_weak` or a supported apprentice-protection tag.
3. Add `MG05 200` as a small positive Syrabane row using `protect_the_weak`.
4. Add `MG08 200` as an echo positive Syrabane row, explicitly secondary to Magnus.
5. Pick exactly one negative row for V1, preferably `DA01 110` or `DA04 100`, after owner review.

If a new act tag like `protect_apprentice` is desired, add it through the stance/tag matrix and compiler checks first. Otherwise use existing supported tags and make the Syrabane-specific meaning live in citation/rejected-context text.

## Other Wiring Gaps

### Hist

The Hist has two quest rows, both from `T03` nature restoration/defilement. That is thin, but vanilla Skyrim has limited exact Hist-facing quest content. The safer resolution is:

- Keep exact quest rows only when the branch genuinely maps to root, sap, memory, people, or communal survival.
- Prefer Argonian P2/non-quest sources for live feel.
- Do not promote generic swamp/nature/restoration rows as Hist proof.

### Y'ffre

Y'ffre has seven quest rows, mostly nature/hunt/Green Pact adjacent. This needs breadth, but not through generic wilderness presence.

Resolution:

- Keep `T03` and hunt rows where exact.
- Add Green Way rows only where the branch is covenant/story/nature-law, not generic hunting.
- Make sure Green Way Kynareth proxy rows keep routing to Y'ffre after the remap.

### Thin Daedric Princes

Namira, Sanguine, Vaermina, and Peryite are low-cell, but low count is not automatically wrong. They can be V1-acceptable when their own Daedric quest plus artifact/faucet rows cover the core identity.

Resolution:

- Add exact rows only for their own Daedric quest branches or clearly tagged cross-quest outcomes.
- Do not balance Prince counts numerically by adding weak generic rows.
- Keep taboo/hostile reactions going through stigma/penalty where stance says they should.

### Phynaster

No display/reward/offer promotion should happen until the locked hard gate is met:

- At least three concrete positive source families.
- At least one concrete dislike/failure family.
- Distinct offer/reward copy.
- No overlap with Y'ffre's Green Way nature covenant, standing-stone, hunt, shrine-proxy, or reward identity.

Until then, Phynaster remains roster/flavor support.

## Implementation Order

1. Keep the Syrabane display fix and adversary check as P0 because it protects route reachability.
2. Run the first Syrabane quest-row tranche as a small, reviewable matrix patch.
3. Recompile the quest matrix and regenerate StorageUtil JSON.
4. Run `pdv_quest_matrix_compile --check --json`, the remap adversary check, default verifier, formal-offer check, and eligibility/reward coverage.
5. Do not claim runtime completion until the smoke route proves Syrabane can appear in Survey/status or medallion payload, accept an offer, grant the correct Active Effect, and survive save/load without duplicate stacks.

## Rejected Generic Contexts

Do not count these as Syrabane proof:

- Generic College membership.
- Generic spell learning.
- Generic magic skill milestone.
- Every ward cast.
- Generic magic-resistance gain.
- Generic anti-mage combat.
- Generic book reading.
- Non-terminal College quest progress.
- Generic shrine proximity.
