# PDV Drift-Gate Pattern

**Status:** Living authoring standard for gates that compare competing sources.

This note defines how a drift gate names its authorities and reports what it
actually proved. It does not replace the artifact classes in
`PDV_STANDARDS.md` section 5.3 or the current package facts in
`PDV_ModPackaging_StateAuthority.md`.

## Required declaration

Before implementing a new drift gate, write this table in the tool header,
nearby contract, or design review:

| Field | Required answer |
|---|---|
| `authorityA` | First source being compared, including its exact file or live readback surface. |
| `authorityB` | Second source being compared. |
| `runtimeWinner` | The source runtime actually consumes when the two disagree. |
| `allowedFallback` | The losing source runtime may use, including the exact condition; write `none` when no fallback is legal. |
| `proofClass` | `verification`, `pinning`, `advisory`, or a named mixture with each check classified. |
| `driftClass` | One of the reusable classes below. |
| `skipRule` | What happens when the proving backend is unavailable. |

A gate without these answers is not ready to encode. If the answer is copied
from the data being validated, the validator is self-harvested and cannot
detect the defect it claims to guard.

## Drift classes

| Class | Meaning |
|---|---|
| `pin-only` | A value equals a stored expectation, but the gate did not independently re-derive it. |
| `stale-generated` | A generated or staged artifact no longer matches its authoring source. |
| `self-harvested-validator` | The validator learns legal values from the same payload it validates. |
| `fallback-disagrees-with-winner` | Runtime is currently correct because the winning source masks a stale fallback. |
| `winner-disagrees-with-authority` | The runtime winner contradicts the declared design or authoring authority. |
| `backend-unavailable` | The source needed to prove the claim could not be read. This is a skip or failure, never a pass. |

## Output semantics

- `PASS`: the gate independently compared or re-derived the claimed state.
- `FAIL`: the winning state is wrong, a required parity check disagrees, or a
  required backend cannot run.
- `WARN`: a non-winning fallback or advisory surface drifted, but the declared
  runtime winner remains available and correct.
- `SKIP`: the command explicitly allows an unavailable proving backend. State
  exactly what was not checked; never roll a skip into a green proof count.
- `PIN`: a stored value matches its contract. A matching pin may allow the
  command to continue, but it must not be described as verification.

Release-critical commands fail when their proving backend is unavailable.
Advisory audits may emit `SKIP` and exit successfully only when their
declaration says so. No command may silently downgrade a required proof to a
fallback.

## Authoring checklist

1. State the question the gate answers in one sentence.
2. Fill every required declaration field before writing comparisons.
3. Name the runtime winner from the consuming code or staged artifact, not from
   whichever source is easiest to parse.
4. Keep legal-value registries independent of the payload under validation.
5. Classify every literal expected count or value as a pin unless it is
   independently re-derived in the same run.
6. Make backend absence produce the declared `FAIL` or `SKIP`; never an implicit
   `PASS`.
7. Print the proof class and drift class in actionable failure output.
8. Add a negative fixture or deliberate mismatch that proves the gate can see
   each drift class it claims to detect.
9. Update this declaration when the runtime seam or allowed fallback changes.

## Current repo applications

| Family | `authorityA` | `authorityB` | `runtimeWinner` | `allowedFallback` | `proofClass` and drift |
|---|---|---|---|---|---|
| Stance/readback parity | Live `PDV_QuestReactionMatrix.json` `stance.<Race>.<Deity>` | ESP `Stance_<Race>` VMAD property | JSON when the key exists | ESP only when the JSON key is absent | Verification by `pdv_deity_stance_parity`; `fallback-disagrees-with-winner` when ESP differs. `IsDashboardDeityInOriginRoster` is a reachability gate, not another stance authority. |
| Generated package metadata | `PDV_QuestPatchHub.manifest.json` and the release builder inputs | Generated/staged `fomod/ModuleConfig.xml` and `fomod/info.xml` | The exact files in the installed archive | None; regenerate or rebuild | `stale-generated`; the staged tree and archive membership must be compared to their authoring inputs. |
| Release-proof snapshot | Live `Devotion.esp` plus direct houseCARL readback | `PDV_HousecarlReleaseProof.json` | The live plugin and current load-order winner | None | `pdv_release_proof_refresh --check` independently re-derives byte identity, both record frames, the exact contested membership fingerprint, critical winners, VMAD, and claimed asset providers. Critical-target scope, CELL retention, and open runtime/manual boundaries are explicit refresh confirmations. Backend absence fails a release build. |
| Prince slug legality | Part B-2 `Canonical Prince slugs` in `PDV_QuestReactionMatrix.md` | Tagged/canonical CSV rows and compiled runtime data | Compiled data after canonical validation | None; shipped rows cannot legalise themselves | `self-harvested-validator` if legality is learned from the CSVs. `pdv_matrix_vocab.mjs` reads only the canonical table. |

## Closeout wording

Report the narrow result: which authorities were compared, which one wins, and
which proof classes ran. A green command with a `PIN` or `SKIP` line may support
the checks that genuinely passed; it does not prove the pinned or skipped
surface.
