# Handoff -- Nexus Release Packaging + 1.0 Gate State (2026-07-16)

**Owner:** packaging / release-claim boundary
**Authority:** `PDV_1_0_EndStateContract.json` + a fresh `pdv_1_0_endstate_gate.mjs`
run. This doc is a snapshot of that run, not a competing authority.

## What was built

`dist/Devotion-1.0.0.zip` -- 7.6 MB, 216 entries, SHA256
`9140A08933BE8386A7989D24497120CDA6D2CC50B7AD08B7927938161793D8CF`.
(Supersedes `BD99DCC5...` -- the same package before the Bosmer path-label fix
below forced a recompile; both supersede the leaking `A72E63D3...`. Re-derive the
true hash at any time with
`node tools/pdv_package_release.mjs --verify dist/Devotion-1.0.0.zip`
rather than trusting this line.)

> **Renamed to `Devotion-1.0.0.zip` by the owner, 2026-07-17. This is the
> official distribute file.** Pure rename -- byte-identical to the
> `Devotion-1.0-rc1-20260717.zip` build, same SHA256, re-verified PASS after the
> rename. The `1.0-rc1` filename is retired; any doc still naming it is stale --
> including `PDV_CleanupSweep_SmokePacket_2026-07-16.md`, whose "Artifact under
> test" names a file no longer on disk.
>
> The owner is shipping this as **1.0** while the end-state gate reads 11 RED.
> That is an owner release-claim decision, not a gate pass. The criteria and
> their `post10: false` flags are unchanged and the open work is still tracked in
> `PDV_1_0_UntestedBacklog_2026-07-16.md` -- do not read the `1.0.0` filename
> back as evidence that the gate greened.
>
> Not the distribute file: `dist/Devotion.Beta1.0.zip` is the retired friend
> pack (top-level `Devotion\` wrapper, carries the 876 KB
> `PDV__ManagerQuest.psc.orig` leak, and a README telling readers not to
> redistribute). Never upload it.

Clean deployable of live `mods/Devotion` with a **Data-relative root** (installs
via mod manager with no "set data directory" step), plus `README.txt` and
`CHANGELOG.txt`. Contents: `Devotion.esp`, 96 `.pex`, 96 `.psc` (source, under
`Scripts/Source/`), `Seq/Devotion.seq`, SKSE bridge DLL + StorageUtil data,
PrismaUI views, meshes, textures, dialogue views, `Credits.txt`.

Excluded: `Backups/`, ~50 `.seq` backups, the `.esp.bak-*` snapshots, bridge
`.pdb`, `.bak` JSON, `.orig` source, `meta.ini`.

> **Correction (2026-07-16).** The original build of this zip was 217 entries /
> 7.7 MB / SHA256 `A72E63D3...` and this section claimed "Verified zero leakage
> by direct zip inspection." **That claim was false.** The archive shipped
> `Scripts/Source/PDV__ManagerQuest.psc.orig` -- 876 KB of stale, md5-mismatched
> manager source, ~11% of the download. The hand-run exclusion matched `.bak-*`
> and never covered `.orig`.
>
> Root cause: the exclusions existed only in a shell invocation, not in the repo.
> Fixed three ways -- the six stale `.bak`/`.orig` files were deleted from live
> `Scripts/Source` (~2.7 MB); packaging now runs through
> `tools/pdv_package_release.mjs`, which builds from a filtered staging tree so
> an excluded file cannot reach the archive, then re-scans the finished zip and
> fails on any leak; and `README.txt`/`CHANGELOG.txt` -- which previously existed
> **only inside the zip** and were unversioned -- now live in
> `dist/release-meta/`.
>
> Rebuild and re-verify with:
> ```
> node tools/pdv_package_release.mjs --version 1.0-rc1 --date 20260716
> node tools/pdv_package_release.mjs --verify dist/Devotion-1.0-rc1-20260716.zip
> ```
> The SHA256 above is the corrected build. It also carries the recompiled
> manager/MCM bytecode from the same-day Papyrus cleanup, so it supersedes
> `A72E63D3...` on content as well as on leakage.

**Versioned `1.0-rc1`, NOT 1.0** -- see gate state below. The bits are
release-quality; the *claim* is not yet earned. Renaming the file is a one-line
change once the gate greens.

## Gate state

Read-mode: **2 PASS / 1 STALE / 20 RED**. After `--run` re-green:
**12 PASS / 1 STALE / 10 RED**. Most REDs were drift-voided machine proofs
(the `.pex`/ESP moved after evidence was recorded), not breakage.

> **Re-run after the cleanup sweep (2026-07-16 21:40):**
> **11 PASS / 1 STALE / 11 RED.** The ten below are unchanged. The extra RED is
> `C-MAIN-QUEST-FULL-COVERAGE`, and it is **not** from the sweep and **not** a
> code defect -- it is a concurrent session's in-flight authoring:
>
> `PDV_MainQuestFullCoverageContract.json` expects `matrixCells: 1978` /
> `questKeys: 172`; the live compiler reports **1982 / 173**. Four new DB01
> "Innocence Lost" rows (stage 198, the report-Grelod non-murder resolution,
> stamped `ruled 2026-07-16` / `RUNTIME-VERIFY`) were written to
> `PDV_QuestReactionMatrix_Full.csv` at 21:18 and the runtime JSON regenerated at
> 21:20. 1978+4 = 1982 and 172+1 = 173 (DB01 is a new quest key) -- the arithmetic
> accounts for the delta exactly. The contract's expected counts have not been
> bumped yet.
>
> Left untouched deliberately: those rows are uncommitted and mid-edit, so
> recompiling the matrix or bumping the contract here would stomp live work. The
> owner of the DB01 tranche should bump `expected` and re-run the gate. Every
> other machine gate is green: `pdv_prisma_ui_audit` 123 checks,
> `pdv_prisma_to_oneoh_audit` PASS=76 FAIL=0, ASCII guard clean, all 96 `.pex`
> fresh, zero packaging leakage.

### Remaining 10 RED -- all need in-world proof

| Criterion | Open |
|---|---|
| C-FELT-FAMILY | 25/151 slots (Argonian boons, BaanDar/Boethiah price, Bosmer, ...) |
| C-PACING-SIGNOFF | 9/10 races (all but one) |
| C-COMPAT-BORDELLO | 6/6 (JOJ, TOT, HOH, MOM, DoD, VOV) |
| C-COMPAT-ARR | 1/1 (arrAcceptedPackage) |
| C-REQUIEM-TRACKB | 4/4 sweeps |
| C-MAIN-QUEST-FULL-COVERAGE-RUNTIME | 5/5 slots |
| C-PLACEMENT-FINAL | 10 hooks pending in-world proof (73 PASS) |
| C-DISLIKE-DEBUFF-TUNING | 1/1 (antiStackRequiemFelt) |
| C-AUDIT-BETA-STRICT | meta-gate; fails closed while the above are open |
| C-EXPMODE-BUILD | **stale contract, see below** |

None of these is a code defect. They are play-time evidence buckets, and per
[[felt-family-retrocredit-exhausted]] they cannot be retro-credited from specs.

## Two drift findings (not fixed here)

1. **C-EXPMODE-BUILD is a stale gate contract, not missing work.**
   `pdv_verify.mjs --strict-experience-mode` fails on `PDV_MCM.psc` missing
   `String Property PAGE_MODE = "Experience Mode"` and `Function BuildModePage()`.
   Per CHANGELOG 2026-07-16 the Experience Mode **tab was deliberately removed**
   and folded into Settings; `ToggleExperienceMode()` and the Path label both
   still PASS. The verifier is checking for a page that was intentionally
   deleted. Toolchain edits are out of scope without an explicit ask
   (Claude.md rule 5) -- **the gate expectation needs updating to match the
   shipped Settings-tab design.** Until then C-EXPMODE-BUILD reds the rollup for
   a wrong reason. Updates [[experience-mode-designed-not-built]].

2. **SEQ freshness WARN is a false alarm.** `pdv_verify.mjs` warns the SEQ is
   older than the ESP. Regenerated it via `housecarl_write_seq` and diffed:
   **byte-identical**, 42 start-game-enabled quests both sides. The ESP was
   touched later without adding an SGE quest. No action needed; the WARN is an
   mtime artifact, not a start-failure risk.

## Incidental fix

`PDV_ActionRouter.pex` was stale against its source in the live folder;
recompiled clean (0 errors / 0 warnings) so shipped bytecode matches shipped
source. This is also what drift-voided several machine gates -- expect a
re-green to be needed after any recompile.

## Pre-release cleanup sweep (2026-07-16, later same day)

A review pass landed the following. All machine gates re-green after; the ten
in-world REDs are untouched and still require a tester.

**Papyrus (`/papyrus-optimization`).** The 1s manager tick is a
`RegisterForSingleUpdate` chain -- correct idiom, no queue stacking, no freeze
risk -- but it never exits and three consumers kept paying after self-disabling.
Fixed: deleted `Phase0PrismaChoiceTick` (self-described throwaway Phase 0 debug
code polling StorageUtil every second in a release build; fully self-contained,
no MCM or gate caller); hoisted `EnsureUnifiedStartupChoice`'s completion flag
ahead of its `GetPlayerOriginRaceIndex()` call; folded `UpdateDisfavorStingRuntime`
into the existing 10s `_shoutRefreshTicks` throttle. Disfavor expiry is compared
against **game** time, so at timescale 20 a 10s cadence is ~3 game-minutes of
granularity on a game-hours debuff. `UpdateContextualFavorRuntime` deliberately
stays at 1s -- it re-checks eligibility and must react when the player leaves the
triggering context. Deleting Phase 0 leaves `ShowChoice`/`ConsumePendingChoice`/
`SupportsChoice` without a Papyrus caller; that is intentional (retained bridge
capability, see `PDV_PrismaChoicePanel_CapabilityPlan.md`) -- do not remove them.

**Prisma.** The layer was already clean: one view, repo/live md5-identical across
`app.js`/`styles.css`/`index.html`/DLL, no orphan views, no broken `CreateView`
paths, no JS/native interop mismatches, cold-view focus trap correctly deferred.
Two mirror/gate defects fixed, neither ever affecting the game:
- `native/DevotionPrismaBridge/mod/Scripts/Source/PDV_PrismaBridge.psc` was
  missing `IsPanelVisible`, which C++ registers and `PDV_MCM.psc` calls -- a
  repo-side **compile break** that no gate caught, because every audit read the
  live copy. Declaration restored, and `pdv_prisma_ui_audit.mjs` now checks
  repo/live bridge parity plus "every C++-registered native is declared."
  The parity check normalizes line endings: the repo mirror is CRLF and live is
  mixed CRLF/LF, so a raw byte hash would false-fail on identical text.
- `pdv_prisma_to_oneoh_audit.mjs` asserted retired Altmer copy ("The old line
  turns: ...") that ships nowhere. The real implementation is strictly better
  (authored headline/line/tone + paired Book of Days entry). Retargeted at what
  ships; the audit now reads PASS=76 FAIL=0 (was 74/1).

**Git.** 42 lines of shipped behavior (per-mod quest-reaction patch channels in
`PDV_PlayerEvents` + the manager's channel resolver) were compiled into the
shipped `.pex` but uncommitted. Committed as `a11fc0c`.

**Bosmer path label (found in smoke, fixed).** Book of Days rendered
`You've chosen your road: OldContract.` -- the raw PascalCase StateTrack token.
`GetBosmerPathLabel()` returned the ESP's internal `StateLabels` entry, and all
eleven of its callers are player surfaces, so the token leaked everywhere: also
`Your road through the Green is the OldContract.`, the Prisma shift toast, and
the Survey line. Mapped state -> authored guide copy in that one function
(Old Contract / Living Story / Bandit Road / Exchange -- the article stays in the
prose, so "The Exchange" would have rendered "is the The Exchange.").

Fixed in Papyrus, **not** in the ESP's `StateLabels`: VMAD properties bake at
first init so a data edit would not reach existing saves, and the internal token
is still wanted -- `pdv_phase20_runtime_check` greps it in Trace markers, and
`GetBosmerSummary()` uses it deliberately in the MCM's debug `key=value;` readout.
Safe to change in place: nothing string-compares the label, `app.js` does not
match the path token, and the chronicle gates assert only the prose prefix ahead
of the label. This recompile produced the current SHA256.

**Smoke results (2026-07-17).** Disfavor 10s-cadence clear, favor 1s
reactivity, startup choice, and the Prisma hotkeys all PASS -- see
`PDV_CleanupSweep_SmokePacket_2026-07-16.md`. Test 5 (Phase 0 removed) PASS,
proven from the bytecode: `DebugPrismaChoiceGo`, `Phase0PrismaChoiceTick`,
`phase0_test`, and `PDV Phase 0:` are all absent from the live
`PDV__ManagerQuest.pex` while control strings are present.

## Open proof debt

Packaging success is not gameplay proof. What is proven here:

- **Package shape** -- direct zip inspection.
- **`.pex` freshness** -- all 96 verified against source.
- **Machine/readback gates** -- 12 PASS on a fresh `--run`.

What is NOT proven and blocks the 1.0 claim: every row in the RED table above.
All require a tester at a keyboard. No amount of tool running closes them.

## Next

**Work breakdown for the 10 RED: `PDV_1_0_UntestedBacklog_2026-07-16.md`**
(owner decision 2026-07-16: track the untested work, do NOT waive it -- every
criterion stays `post10: false`, the gate stays RED and keeps meaning what it
says).

1. Decide the C-EXPMODE-BUILD contract fix (gate expectation vs shipped design).
2. Burn the in-world buckets -- `PDV_1_0_CoTest_Runbook_2026-07-10.md` is the
   operator sheet; record into the structured ledgers the burndown names.
3. Re-run `pdv_1_0_endstate_gate.mjs --run` **after** the last recompile, not
   before, or drift voids the machine PASSes again.
4. Only then rename `1.0-rc1` -> `1.0` and cut the Nexus upload.
