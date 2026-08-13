# PDV Release-Proof Refresh Runbook

**Class:** LIVING authority and operator checklist
**Claim evaluated:** the committed release-proof snapshot matches the live Anvil
`Devotion.esp`, its current load-order winners, its VMAD audit, and the asset-provider
claims consumed by the release packager.

This workflow proves static release inputs. It does not prove gameplay routing, player UI
behaviour, balance, save/load behaviour, or compatibility support. A green package build
must not imply any of those claims.

## When a refresh is required

Refresh after any change that can move a gate input:

- any byte change or replacement of the live `Devotion.esp`;
- an Anvil load-order change that can move a contested or critical winner;
- a live Papyrus-source change that can change the VMAD audit verdict;
- adding, removing, or changing a critical-record target;
- adding, removing, or changing an asset-provider claim in the proof.

A refresh is not required for docs-only changes, PatchHub CSV/JSON/FOMOD-only changes, or
other files that neither alter `Devotion.esp` nor a proof surface above. Their own package
and generation gates still apply.

## One ordered workflow

1. Confirm houseCARL is on `D:\Wabbajack\modlists\Anvil`, profile `Devotion Dev`, and
   `Devotion.esp` is active. The refresh tool checks this again and fails closed.
2. Run the current-state gate:

   ```powershell
   node tools/pdv_release_proof_refresh.mjs --check
   ```

   If it passes, no proof refresh is needed. ESP mtime drift with an identical SHA-256 is
   informational; byte identity is the gate.
3. If it fails because live state intentionally changed, capture a regenerable review
   candidate:

   ```powershell
   node tools/pdv_release_proof_refresh.mjs --capture
   ```

   Review `generated/PDV_HousecarlReleaseProof.candidate.json` against the committed
   `references/authoring/PDV_HousecarlReleaseProof.json`. The candidate is gitignored and is
   never package authority.
4. Review all four manual decisions before promotion:

   - Is the exact contested-record membership and every changed winner intentional?
   - Does the critical-record target list still cover the current release claims?
   - Do the two contested CELL overrides still retain Devotion's intended nested references?
   - Does `proofBoundary.open` still list every runtime/manual surface not proven here?

5. Promote only after that review. Supply a specific note and all three confirmations:

   ```powershell
   node tools/pdv_release_proof_refresh.mjs --refresh `
     --note "Describe the ESP or load-order change that required this refresh." `
     --confirm-critical-scope `
     --confirm-cell-retention `
     --confirm-open-boundary
   ```

   If exact contested membership changed, add `--accept-contested-changes`. If a critical
   winner changed, add `--accept-critical-winner-changes`. Those flags acknowledge review;
   they do not make the change correct by themselves.
6. Re-run `--check`. Then run the release preflight. `pdv_package_release.mjs` invokes the
   same live check and fails when houseCARL is unavailable or the committed proof is stale.

## Required readback order

The tool performs these reads in order through houseCARL's sanctioned read-only MCP
stdio path:

1. active instance/profile/plugin status;
2. live ESP SHA-256, size, and mtime;
3. absolute plugin-file masters and raw-file record summary;
4. defined-in record summary;
5. FormLink, missing-master, and parse-error sweep;
6. exact contested records, type breakdown, winners, and set fingerprint;
7. every committed critical-record winner and the Manager VMAD shape;
8. all defined placed-object winners used by the CELL retention decision;
9. full `pdv_vmad_audit.mjs --json` verdict;
10. PSC/PEX name-pair inventory;
11. provider/winner checks for every asset path named in the committed proof.

No previous numeric result is used as the live answer. In particular, the old
`contestedRecordCount === 33` package constant is retired: the workflow fingerprints all
sorted `formid|type|editorid|winner` rows, so a different set of 33 fails.

## Field classification

| Surface | Classification | Package effect |
|---|---|---|
| profile, active plugin, ESP SHA-256 and size | machine gate input | mismatch fails |
| ESP mtime | informative diagnostic | mismatch alone does not fail when bytes match |
| masters and both record-count frames | machine gate input | mismatch fails |
| exact contested set, breakdown, and winners | machine gate input | mismatch fails |
| critical-record target list | hand-authored authority | scope confirmation required on refresh |
| critical-record winners and Manager VMAD shape | machine gate input | mismatch fails |
| CELL nested-reference intent | manual gate input backed by placed-object readback | explicit confirmation required |
| VMAD exit code and unwaived findings | machine gate input | nonzero fails |
| VMAD counts and waived hypotheses | informative context | counts recorded; waiver intent remains open |
| claimed asset paths and providers | authority plus machine gate | missing/non-Devotion winner fails |
| `refreshNote`, timestamps | informative provenance | specific note required; not gameplay proof |
| `proofBoundary.open` | hand-authored authority | explicit confirmation required; runtime/manual stays open |

## Open proof boundary

Even after a successful refresh and package build, this workflow does not prove:

- intentional-versus-defective status of waived VMAD hypotheses;
- manual Prisma, MCM, or Book-of-Days behaviour;
- navmesh or terrain spatial integrity;
- runtime routing, balance, save/load behaviour, or support promotion.

Those claims require their own runbooks, runtime evidence, or manual sign-off. The next
required step after a refresh is therefore the package preflight, not a claim that gameplay
testing has passed.
