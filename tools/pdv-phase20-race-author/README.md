# pdv-phase20-race-author

Generalized Mutagen record-authoring tool for PlayerDevotion (PDV) Phase 20
reward records. Authors **any** race's reward records from a per-race spec
JSON. This is the generalization of `tools/pdv-phase20-khajiit-author`, which
is left untouched as the regression baseline.

## Build

```
dotnet build tools/pdv-phase20-race-author/PdvPhase20RaceAuthor.csproj -c Release
```

net8.0; same Mutagen reference DLLs as the Khajiit tool (Anvil mutagen-bridge).

## Modes

| Mode | Purpose |
|------|---------|
| `--author-rewards` | Create/wire SPEL/MGEF/QUST records from `--rewards-spec`, add deities to `PDV_FLST_AllDeities`, wire manager + substrate properties. |
| `--reconcile-shared-deity` | For each deity entry with a non-empty `shared` field: copy SGE `Flags`/`Priority` from the reference deity and set the named stance field(s) (+ optional `eligibleStateTrackOriginRace`). Generalizes the Khajiit tool's `--fix-baandar`. |

## Flags

| Flag | Notes |
|------|-------|
| `--rewards-spec <path>` | **Required.** Per-race reward spec JSON. No default. |
| `--esp <path>` | Framework ESP. Defaults to the Anvil deploy path. |
| `--reference-deity <edid>` | Reference deity QUST for SGE flag/priority copy and shared reconciliation. Default `PDV_Deity_Kyne`. |
| `--dry-run` | Parse + resolve records only; never writes the ESP. |

## Spec schema

Backward-compatible superset of `pdv-khajiit-records.v1`
(`references/authoring/PDV_KhajiitRewardRecords.spec.json` parses unchanged).

`deityQuests[]` entry fields (additions over v1 in **bold**):

- `editorId`, `script`, `deityName` — as v1.
- `deityIndex`: `"next-available"` (string) **or an explicit int**.
  `"next-available"` allocates the next free index by **scanning every
  existing deity QUST's `DeityIndex` script property in the ESP** (no hardcoded
  map). Reward-deity indices are allocated at 40+. If the QUST already exists
  with a `DeityIndex`, that value is preserved (idempotent).
- `addToFormList` — informational; membership in `PDV_FLST_AllDeities` is
  always ensured idempotently.
- `shared`: `["RaceName ..."]` — cross-race ownership marker; drives
  `--reconcile-shared-deity`.
- **`create`: `true|false`** — `false` reuses an existing QUST owned by another
  race; the tool will **not** create it or allocate a `DeityIndex`, only
  reconcile stance. Default `true`.
- **`stance`: `{ "field": "Stance_Imperial", "value": 0 }`** — generalized
  stance descriptor.
- **`stances`: `[ {field,value}, ... ]`** — set **multiple** stance fields on a
  single (shared) deity quest.
- `stanceKhajiit`: `"NATIVE"|"FOREIGN"|"HOSTILE"|<int>` — **legacy** v1 field,
  still honored; maps to the top-level `stanceField` (default `Stance_Khajiit`)
  with NATIVE=0/FOREIGN=1/HOSTILE=2.
- **`eligibleStateTrackOriginRace`: `<int>`** — reconciliation extra; sets the
  alt-path eligibility-gate origin race.

Top-level (additions in **bold**):

- `managerDeityProperties[]`, `neglect`, `emphasisRewards[]` — as v1. Manager
  property names come entirely from these (no hardcoded names). Emphasis
  rewards wire under `spellProperty` if present, else `spellEditorId` (v1
  behavior).
- `substrateBoons` — fully spec-driven via `wireTo`/`slots`. **If omitted
  entirely, substrate wiring is skipped** (state-track races have no
  substrate).
- **`stanceField`** — default stance field for entries that supply only a
  numeric stance value (falls back to `Stance_Khajiit`).

## How to invoke per race (Phase C)

Author one race at a time from its spec, e.g. for Imperial:

```
dotnet run --project tools/pdv-phase20-race-author/PdvPhase20RaceAuthor.csproj -c Release -- \
  --author-rewards \
  --rewards-spec references/authoring/PDV_ImperialRewardRecords.spec.json \
  --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
```

Run `--dry-run` first to confirm parsing and record resolution, then drop
`--dry-run` for the single backed-up framework-ESP write (a timestamped
`.bak` lands under `<esp-dir>\Backups\phase20-race-rewards\`). If the race
shares a deity already owned by another race (`"create": false` and/or a
non-empty `shared`), run a second pass with `--reconcile-shared-deity` to copy
the SGE flag and set this race's stance on that shared QUST, then refresh the
SEQ (`pdv_refresh_seq`). Both modes are idempotent and safe to re-run.
