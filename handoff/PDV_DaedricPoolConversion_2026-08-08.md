# Daedric pool/Mora conversion, gate fix, and build-lineage cleanup

Status: LIVING
Closed: 2026-08-08
Gates at close: `pdv_verify` **FAIL=0 exit 0** (PASS 4105), Daedric beta gate **exit 0**,
quest-reaction performance audit **exit 0**.

---

## What was wrong, and why the gate did not say so

The Daedric price numbers live in **`tools/pdv_generate_daedric_contract.mjs`**, not in
`race-sheets/PDV_DaedricContent_Manifest.md` or
`references/phase4/PDV_DaedricRacePrinceMatrix.csv` — both hold prose only. That matters,
because the contract JSON is a **build output** and the generator is the authority.

| | |
|---|---|
| Generator: Hircine/Molag `price:["Health"]` | `cb373658`, **2026-06-07** |
| Generator: magnitude formula `[-10,-18,-25] / [-10,-20,-30]` | `6866de5b`, **2026-06-11** |
| Generator refined again | `8042e8a3` 07-13, `3629f0c7` 07-18, `2f9574f4` 07-26 |
| **Contract JSON on the branch** | last generated **2026-06-12**, never regenerated after any of it |

So `pdv_verify` spent six weeks comparing the ESP against expectations **older than the
design**, and the 2026-07-26 "48/48 corrected pairs" repair aligned the ESP to a stale
artifact. `AGENTS.md`'s `FAIL=0` was true against the wrong expectation — pinning, not
verifying. Merging `codex/arr25-content-sweep` brought the regenerated contract and the
gap surfaced as 8 FAILs.

Checked first: regenerating the contract untouched reproduced the merged one
byte-for-byte (timestamp aside), proving it a faithful generation rather than a hand-edit.

---

## What landed

**Malacath toned down.** New `PRICE_MAGNITUDES_BY_AV` override sets SpeedMult to
`-4/-7/-10`. The generator's two-bucket model (18 skills vs "everything else") put a
**percentage multiplier** in the same band as flat resource pools, so `-30` meant 30
points off a pool for Vaermina but a **permanent 30% movement-speed cut** for Malacath.
Category error, not a tuning choice. Owner call; **the value is provisional and needs an
in-game felt-check.**

**Nine MGEF conversions, not the six the gate reported.** Molag x3 and Hircine x3
`ValueModifier` -> `PeakValueModifier/Health`, plus **Nocturnal x3 `CarryWeight` ->
`Restoration`**. Nocturnal appeared in **no FAIL** — see the gate fix below. `Recover`
survived on all nine, `Association` still null, readback confirmed per record.

**48 spell magnitudes** written from the contract (semantic negative, stored positive
absolute). Written as absolute Sets, so idempotent.

**Mora Champion: the ESP was RIGHT and the contract was WRONG.** The boon is a documented
two-effect exception, `+20 Alteration; +20 Magicka` (`AGENTS.md`, runtime-confirmed). The
generator derived a primary MGEF named `PDV_MGEF_Bless_Daedric_Mora_Champion` on
Magicka 35 — a record that does not exist, at a value contradicting the ruling — while
the ESP correctly used the `_Alteration` suffix at 20. Added `BOON_PRIMARY_BY_SPELL` so
the generator emits the authored design. **No ESP change was needed.** Trusting the FAIL
text would have corrupted a correct record. Mora-specific: the other 48 boon and 48 price
editorIds all resolve.

ESP `87B04CDF` -> `A0927032`, 649,917 bytes. Backup:
`Devotion.esp.bak-daedricpools-20260808` (packager-excluded).

---

## Gate fix: non-pool prices were never checked

The price archetype check only inspected `Health`/`Magicka`/`Stamina`. An actor-value
retune on a skill or percentage price could therefore drift between contract and ESP
**with the gate green**. Nocturnal is the proof: it was wrong for weeks and invisible.

Added a matching non-pool branch (`ValueModifier/<contract AV>` + `Recover`), comparing
against the **record-side** name — the record enum and contract name differ for a few AVs
(`Speechcraft` vs `Speech`) and a raw comparison reports drift that is not drift.

**Proved it can fail, not just pass.** Temporarily reverting the contract's Nocturnal AV
to `CarryWeight` produced `FAIL=3 exit 1` naming all three tiers; restoring it returned
`FAIL=0 exit 0`. A gate only exercised in its passing direction is not a verified gate.

---

## Build lineage - what each Devotion.esp on this machine actually is

| Location | sha256 | What it is |
|---|---|---|
| `Anvil\mods\Devotion` | `A0927032…` (was `87B04CDF…`) | **the dev build** — this branch's work |
| `Anvil\mods\Devotion-V3Dev` | `0680B51F…` | **byte-identical to shipped 1.0.4** — NOT a V3 build |
| `dist\Devotion-1.0.4-20260727.zip` | `0680B51F…` | shipped 1.0.4 |
| `ARR 2.5\mods\Devotion` | `439E1E60…` | Aug 2 variant, behind dev |
| `ARR 2.5\mods\Devotion - ARR25 Experimental Core 20260807` | `4E1CDCD5…` | Aug 6 snapshot, **now archived** |
| `JoJ\mods\Devotion` | `87B04CDF…` | the pre-conversion dev build installed 2026-08-08 |

**`Devotion-V3Dev` is misnamed** and the name is actively misleading — it reads as newer
work when it is the released build. It was NOT renamed: V3 is the owner's planned
isolated worktree and renaming it would change their setup for a cosmetic gain. This
table is the mitigation. Rename it if the confusion ever bites.

**ARR25 Experimental Core archived.** A full record-level diff across **all 22 types**
(not just MESG) found **0 records unique to it** and 0 EditorID changes on shared
FormIDs; the dev ESP has 6 records it lacks (the Hircine/Molag stigma messages,
`071708`–`07170D`). Disabled in `KoK R11 - PDV ARR25 Experiment 20260807`, the only
profile using it; folder left on disk, profile backed up. Reversible by one character.

---

## Proof boundary

Record-level readback and gate exit codes **only**. Runtime is **not** proven:

- Molag / Hircine: apply each tier, watch the **Health pool** move, confirm exact
  restoration on lapse.
- Nocturnal: confirm the price now lands on Restoration, not CarryWeight.
- **Malacath: a felt-check, not a readback.** Walk and fight at Champion. `-4/-7/-10` is a
  proposal and is the one number in the set that a record cannot settle.

Also stale: the release houseCARL proof, on the new ESP hash — refresh it from a real
readback before packaging. **JoJ currently holds the pre-conversion build** (`87B04CDF`).

---

## Follow-ups raised

The generator's design (writing 15 live `.psc` as a side effect, hardcoded absolute
`SOURCE_DIR`, two-bucket magnitudes, duplicated actor-value alias maps across five tools)
is filed as GitHub issues rather than fixed here. The full Prince boon/price rebalance is
recorded there too — this pass fixed the worst offender, not the model.
