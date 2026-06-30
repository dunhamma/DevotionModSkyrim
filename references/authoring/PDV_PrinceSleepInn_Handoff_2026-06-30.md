# Extend Inn-Only Sleep Drain to the Daedric Princes (Codex Handoff, 2026-06-30)

## Context
Commit `ea8bf570` made the ascetic "sleeping easy" penalty **inn-only** for the 5 main-table
gods (Sithis, Rajhin, Boethiah, Malacath, HoonDing): their `sleep-in-bed` (-0.25) dislike moved
from event **314** (any interior sleep) to the new event **315** (`sleep-in-inn`), which
`PDV_PlayerEvents.psc` emits only when the player's `GetCurrentLocation()` has `LocTypeInn`
(Skyrim.esm `0x0001CB87`). Positive sleep rows (Mara/Tu'whacca/Hist) stayed on 314.

The **7 Daedric Princes** that dislike sleep were intentionally LEFT on 314 that build, because
the Prince LD loader has **no clear-superset** (unlike the main table's `ClearRowsForDeity`), so
naively moving their rows would orphan a stale `PDV.PLD.314 = -0.25` on existing saves. This
handoff does it safely: add a Prince-table clear, then migrate the 7 negative rows to 315.

The **emit side is already done** — `EVT_SLEEP_IN_INN = 315` is emitted in `PDV_PlayerEvents.psc`
and fans out to open paths via `RouteActionToOpenPaths` (event 315 -> `ScorePrinceAction(315)` ->
`PDV.PLD.315.D`). No `PDV_PlayerEvents.psc` change is needed.

## Scope of change
All in `live-source/Scripts/Source/PDV__ManagerQuest.psc`, `tools/pdv_verify.mjs`, and
`references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv`. No ESP, no PlayerEvents, no main
deity-table change.

## Step 1 - Add a Prince-table clear-superset (the load-bearing fix)
Mirror the main table's pattern (`ClearRowsForDeity` + `GetLikesDislikesEventTypes`).
1. Add `Int[] Function GetPrinceEventTypes()` returning every event id used in
   `LoadPrinceRowsForPath` **plus 315**. Derive the full set from the CSV:
   `cut -d, -f2 references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv | tail -n +2 | sort -un`
   then ensure **both 314 and 315** are in the list (314 stays for the positive princes; 315 is new).
2. Add `Function ClearPrinceRowsForPath(PDV_DaedricPathBase path)` that, for each event id in
   `GetPrinceEventTypes()`, unsets `PDV.PLD.<evt>.D` (Float), `.C` (Int), `.O` (Float) on the path
   form. (Same shape as `ClearRowsForDeity` but on `PDV.PLD.` keys / path forms, no origin overlay.)
3. In `LoadPrinceLikesDislikesTable()` (~line 8304), call `ClearPrinceRowsForPath(pldPath)` **before**
   `LoadPrinceRowsForPath(pldPath)` inside the loop — exactly like `LoadLikesDislikesTable` does
   `ClearRowsForDeity` then `LoadRowsForDeity`.

## Step 2 - Migrate the 7 negative sleep rows 314 -> 315 in the Princes CSV
In `PDV_DeityLikesDislikes_Princes_V2.csv`, change `,314,sleep-in-bed,` -> `,315,sleep-in-inn,`
for these 7 (sentiment `-`, -0.25, dailyCap 3, stanceGate `PathOpen`):
`Daedric:Sanguine`, `Daedric:Sheogorath`, `Daedric:Hircine`, `Daedric:Mehrunes Dagon`,
`Daedric:Molag Bal`, `Daedric:Namira`, `Daedric:Hermaeus Mora`.
**Do NOT touch** the 3 POSITIVE sleep rows — they stay on event 314 `sleep-in-bed`:
`Daedric:Vaermina` (+0.5), `Daedric:Peryite` (+0.25), `Daedric:Azura` (+0.25).
(Sanity: after this, no `Daedric:*` row has `,314,...,-,` ; positives keep 314.)

## Step 3 - Regenerate `LoadPrinceRowsForPath` from the CSV
`node tools/pdv_princeld_gen.mjs` emits the function; splice it over the existing
`Function LoadPrinceRowsForPath(...) ... EndFunction` in the manager (same splice you'd do for
`LoadRowsForDeity`). Verify the generator output == the spliced function (header-anchored diff).
The only line changes should be the 7 `WritePLD(path, 314, -0.25, 3, 0.0)` -> `WritePLD(path, 315, -0.25, 3, 0.0)`.

## Step 4 - Version bumps (so existing saves reload the Prince table)
- `PDV__ManagerQuest.psc`: `Int Property PRINCE_LD_VERSION = 3` -> `= 4`.
- `tools/pdv_verify.mjs`: `const EXPECTED_PRINCE_LD_VERSION = 3;` -> `= 4;` (lockstep mirror; this
  toolchain file genuinely needs the bump or verify stays red — same as the LIKES_DISLIKES mirror).

## Why a Prince clear is required (do not skip Step 1)
`LoadPrinceLikesDislikesTable` currently only re-`WritePLD`s; it never unsets. Bumping
`PRINCE_LD_VERSION` reloads, but without a clear the removed 314 rows for the 7 princes keep their
stale `-0.25`, so a committed Sanguine worshipper would STILL drain on home sleep (the exact bug
this change is meant to fix). The clear-superset also future-proofs any later Prince row removal.

## Sync + Verify
- Sync the edited `PDV__ManagerQuest.psc` to the MO2 build copy
  (`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\`) before compiling — `pdv_compile`/
  `pdv_verify` read the MO2 copy, not `live-source/`.
- `node tools/pdv_compile.mjs --script PDV__ManagerQuest` -> 0/0.
- `node tools/pdv_verify.mjs` -> FAIL=0 (the version mirror must match or it fails).
- Generator parity: `pdv_princeld_gen` output == live `LoadPrinceRowsForPath`.
- Spot-check intent: a committed Sanguine/Sheogorath/etc. pact drains -0.25 only on inn sleep;
  Vaermina/Peryite/Azura still credit any bed.

## Parallel/serialize
**Serialize** against any other in-flight `PDV__ManagerQuest.psc` edit (shared file, and this adds
two functions + edits the prince loader + a property). Otherwise low-risk and self-contained:
no ESP, no PlayerEvents, no main deity-table, no CK wiring. The 315 emit already ships.

## Note
This is the follow-up flagged in the `ea8bf570` commit ("Princes left as-is - committed-only;
their loader has no clear-superset"). After this, the inn-only sleep rule is consistent across the
main pantheon AND the Princes.
