# PDV Phase 4 Matrix Scaffold

Status: Living working reference for the Phase 4 matrix pass
Last revised: 2026-05-13

## Purpose

This scaffold defines the working conventions for the three Phase 4 matrices:

- `PDV_RaceSignalMatrix.csv`
- `PDV_StanceMatrix.csv`
- `PDV_DaedricRacePrinceMatrix.csv`

The goal is to translate the locked theology and system contract in
`references/PDV_RaceArchitecture_DesignReference.md` into implementation-ready
design data without flattening race-specific religious structure.

## Source Priority

When sources disagree, use this order:

1. `references/PDV_RaceArchitecture_DesignReference.md`
2. `PDV_Architecture_v2.md`
3. `AGENTS.md`
4. Supporting local lore references under `references/tamriel-*.html`
5. `references/skyrim-deity-reference.jsx`

`PDV_Architecture_v2.md` Sections 10-12 remain useful architecture draft
material, but the race architecture reference is the current source of truth
where the two diverge.

## Matrix Scope

These matrices are intentionally first-release scoped.

- They prefer high-confidence Skyrim-detectable hooks.
- They prioritize signals that are architecturally important for Phase 4.
- They do not try to fully enumerate every possible ambient action in lore.
- They do include enough deity, path, and pressure coverage to support:
  - Phase 4 origin + stance + rivalry implementation planning
  - Kyne proof-slice stance seeding
  - Talos second-deity planning
  - Daedric architecture cross-checking

## Normalization Rules

### Signal matrix

Each row represents one implementation-significant signal family, not every
micro-event variant. A row can point at a compound detection route when the
architecture already treats the signal family as one thing.

Examples:

- `Talos-ban defiance` can cover shrine concealment, worshipper protection, and
  anti-Thalmor resistance when the file already treats those as one theological
  lane.
- `Moon observance` can cover dawn/dusk/night sky practice because the Khajiit
  file treats that as one substrate family.

### Stance matrix

The stance matrix uses the Phase 4 implementation taxonomy:

- `NATIVE`
- `FOREIGN`
- `TABOO`
- `HOSTILE`

Notes:

- `TABOO` is used where the path is intelligible but spiritually or socially
  suspect.
- `HOSTILE` is reserved for cases that should plausibly fire rivalry logic or
  represent categorical opposition.
- Some race layers are not normal patron-choice paths. They still appear when
  they are architecturally load-bearing (`Hist`, `Sithis`, `Riddle'Thar`,
  `ancestor layer`, etc.).

### Daedric matrix

The Daedric matrix keeps global Prince data in shared columns and uses compact
per-race response cells to avoid a 160-row sheet that would be harder to read.

Each race-response cell uses this grammar:

`<State>; <Stigma/Friction>; <Exit>`

Where `State` is one of:

- `Native`
- `Legible`
- `Tolerated`
- `Taboo`
- `Hostile`
- `Curse`

## Working Resolutions For Known Logic Friction

These are matrix-pass resolutions, not final implementation law unless later
promoted into the canonical architecture docs.

### Lorkhan-family handling

Do not force a single merged gameplay row for `Shor`, `Sep`, `Lorkhaj`, and
other Lorkhan-family names during this pass.

- Keep culturally specific rows where they materially differ.
- Use notes to flag family resemblance instead of collapsing them early.
- This avoids pre-committing the implementation to a single equivalence model.

### Hircine for Bosmer

Treat `Hircine` as an external but legible Bosmer pressure, not a normal core
Bosmer path.

- Bosmer core progression stays with `The Old Contract`, `The Living Story`,
  `The Exchange`, and `The Bandit Road`.
- Hircine appears in stance and Daedric matrices as intelligible pressure with
  curse/Wild-Hunt adjacency, not as baseline Bosmer orthodoxy.

### Trinimac for Orcs

Treat `Trinimac` as pressure, memory, or rare ideological exception only.

- Not a standard player-selectable Orc core lane
- Not needed as a normal first-release signal matrix path
- Still worth tracking in stance notes because it shapes `Boethiah` and Orc
  identity conflict

## Cross-Validation Rules

The final pass must satisfy all of the following:

1. Every race signal row must map to a real locked path, mode, or layer.
2. No stance row may contradict the locked race architecture reference without
   a note explaining why the matrix pass narrowed or normalized it.
3. No Daedric response may replace a race's locked substrate layer.
4. Strong quest signals must outweigh ambient drift where the race file says
   they should.
5. Any repeatable signal must carry an anti-farm rule.
6. Any expensive or ambiguous signal must be marked with elevated risk or
   custom-work pressure.
7. Stance and Daedric response should agree in direction even when their
   vocabularies differ.

## Output Mirror

The tracked source files live in this docs workspace. Mirrored copies for live
mod-folder reference should be published under:

`D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\`
