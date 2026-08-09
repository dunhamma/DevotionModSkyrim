# Session handoff -- 2026-08-09

Class: ARCHIVE (a record of one session; not a status doc)
Session: tooling gates, the candidate-queue structural probe, deity stance parity, and the
1.5.0 tester build's player-facing copy.

## READ THIS FIRST -- one thing is mid-flight

**`Devotion.esp` was edited today and the houseCARL release proof was NOT refreshed, so the
release package cannot be rebuilt.**

```
[FAIL] houseCARL proof is stale for Devotion.esp
       (proof A09270329F50CB2D169F7AA41D463CF96C614EFC84D8CD84F5572761DAAFE08A,
        live  0DE7DB29A48C11722A80B7FE949E93393F3424572330C66D1D779FBE94A7DC9F)
```

That refusal is CORRECT and was deliberately left standing rather than worked around. It
blocks `tools/pdv_package_release.mjs`, and therefore `pdv_fomod_release_package.mjs`.

`references/authoring/PDV_HousecarlReleaseProof.json` pins `espSha256` plus a record summary,
contested-record count, critical winners and cell retention. **There is no refresh tool** --
`pdv_package_release.mjs` only names the file; it does not write it. The 2026-08-08 refresh
was done by hand. Whoever refreshes it should also know the gate hardcodes
`contestedRecordCount === 33`, which is pinning rather than verifying.

Until that is done, PR #64 cannot ship and the published tester asset keeps its wrong
installer text.

## What changed in the live ESP

Five VMAD stance properties, applied as ONE atomic `housecarl_bulk_apply` (one rewrite, so the
"a later in-place write reverts an earlier one" hazard cannot apply).

| Record | Property | Was | Now |
|---|---|---|---|
| `0710AF` Mara | `Stance_Altmer` | 0 NATIVE | 1 FOREIGN |
| `0710B1` Stendarr | `Stance_Altmer` | 0 NATIVE | 1 FOREIGN |
| `06CB52` Y'ffre | `Stance_Altmer` | 0 NATIVE | 1 FOREIGN |
| `071149` Boethiah | `Stance_Breton` | 1 FOREIGN | 2 TABOO |
| `071149` Boethiah | `Stance_Bosmer` | 1 FOREIGN | 2 TABOO |

No runtime behaviour change: these records are the LOSING copy (the matrix JSON wins), so this
removed a trap rather than altering play.

- Backup: `mods\Devotion\Backups\stance-parity-20260809\Devotion.esp.pre-stance-fix`
- Masters unchanged: `Skyrim.esm, Dawnguard.esm, HearthFires.esm, Dragonborn.esm`, vanilla
  first, correct order. 1994 records across 22 types, every count identical before and after.
  `housecarl_check_errors`: 0 dangling, 0 missing masters, 0 unscannable.
- Size unchanged at 649,917 bytes; hash moved, which is the expected shape for in-place Int
  edits. A size change would have been the revert tell; there wasn't one.
- **Yffre's `Stance_Altmer` is at property index 11, not 3.** Its layout differs from every
  other deity (2-4 are threshold/delta floats). Writing to index 3 there would have
  overwritten `DELTA_RECOMMITMENT` with an Int. Resolve indices per record; never assume.

## Merged today

| PR | |
|---|---|
| #47 | ignore the shipping FOMOD's build artifacts |
| #48 | candidate queue: judge every folder alias, not the shortest |
| #50 | Daedric contract generator is report-only; no side-effect script writes |
| #53 | a release edit is not done until the repo says the same thing (standing rule) |
| #54 | structural QUST probe + the `voiced` token |
| #55 | one changelog, generated and gated |
| #56 | shared CLI flag guard, 19 self-test tools |
| #57 | `patch-source/` tree so `dist/` is regenerable |
| #58 | Val Serano correction + six follower verdicts |
| #59 | the patch-source lock hashed raw bytes; autocrlf broke it |
| #60 | shared content-vs-bytes file compare helper |
| #62 | remaining 46 tools guarded |
| #63 | deity stance parity gate |

Closed: #41, #49, #52. Filed: #51, #61, and the changelog-divergence issue.

## Open, with the next action

**PR #64 -- FOMOD `info.xml`.** Blocked on the proof refresh above. The 1.5.0 installer still
shows `ARR 2.5 experimental candidate (2026-08-07)` and claims it requires Devotion
separately. Source is fixed; a rebuild and re-upload are owed.

**#51 -- off-roster gods.** The audit is done and the gate is green. Two decisions left:
1. Where the block lives. Today an off-roster god earns NOTHING, but the refusal happens at
   AWARD time -- the god is still offered, the player prays, nothing happens, and that is
   indistinguishable from a bug. Owner position is that it should not be offered at all.
2. The 4 remaining gate WARNINGS. `PDV_DeityBase` defines four stances; the matrix JSON uses
   six. `TOLERATED` and `CURSE` cannot be held by a record, so those pairs disagree
   permanently. Either extend the vocabulary or delete the ESP `Stance_*` copy and let the
   JSON be the only source. Given the records just needed hand-syncing to stay correct, the
   second looks right.

Also settled and worth not re-deriving: `stanceMult.FOREIGN` (0.4) is **unreachable** -- no
deity is both in a race's roster and FOREIGN for it. But `stanceMult.TOLERATED` (also 0.4)
**is** live, via Khajiit/Boethiah and Khajiit/Mephala. Do not delete the multiplier wholesale.

**#61 -- 14 tools document a flag their code never reads.** `pdv_cumulative_rebalance --dry`
is the one to look at first: it reads as a safety mode and works only because the tool
defaults to not writing.

**Untriaged, from the probe:** 40 rows discarded by name that define quests, and 164 queued
rows that define none. `node tools/pdv_candidate_queue.mjs` regenerates; output is gitignored.

**#37 / #35 (items 3-4) / #27** unchanged; all need rulings before code.

## Things that would have cost a day to rediscover

**A gate that pins is not a gate that verifies.** `pdv_verify` checks stances -- against
hardcoded constants for 3 of 33 deities, reading the JSON stance table zero times. It could
never detect ESP/JSON drift, and none of the 9 drifted pairs was one of its 3. It looked like
coverage. `tools/pdv_deity_stance_parity.mjs` derives rosters and canonical names from source
instead, and hardcodes nothing.

**Comparing files across a git checkout is a trap, three times over.** mtimes (git does not
preserve them), then raw-byte hashing (autocrlf), then two files pinned DIFFERENTLY in
`.gitattributes`. `tools/lib/pdv_file_compare.mjs` now makes you say TEXT or BYTES. Do not
add a fourth ad-hoc comparison.

**Read the canonical name, not the record's.** `PDV_Deity_Azura`'s `DeityName` is `Azurah`;
the JSON is keyed `Azura`; `RepairDeityRuntimeName` patches it at init. An audit keyed on the
record value silently misses real drift -- it missed `Breton/Azura` in this session.

**A bulk VMAD read truncates silently enough to look like a finding.** Reading
`PDV__ManagerQuest`'s properties returned 170 of 524 and every Khajiit property looked
missing. Reading indices 512-521 directly showed all ten present and bound. Nearly written up
as a defect in the release notes.

**Mechanical inserts are not safe on this tree.** Migrating 46 tools onto the flag guard,
"insert after the last import" landed inside a multi-line `import {` in one file, and inside a
TEMPLATE LITERAL holding a subprocess preload script in another -- corrupting the preload and
leaving that tool unguarded. Only caught because the sweep tested every tool rather than
sampling.

**The tester build was installed on JoJ and worked.** `meta.ini` records
`installationFile=Devotion-FOMOD-1.5.0-20260808.zip`; core installed with no tickbox and 22
patch channels landed, including four quest expansions the hand-written coverage list had
missed. The silent-underdelivery failure did not recur.

## Release state

`v1.5.0-test1` prerelease. Asset `Devotion-FOMOD-1.5.0-20260808.zip`, sha256
`23391D099723F084541564C1CFC03A72DFF43D01261370FADA6031A67E08CC04`. Notes were rewritten
today: the Khajiit rebalance section (it needs a NEW CHARACTER -- ten bindings bake at first
init and the focus popup degrades to silence, not an error), an Authoria upgrade section (the
old `Devotion - PatchHub` is a separate mod carrying ten colliding channel files and must be
disabled), and the blanket "No new game required" qualified.

The asset predates the `info.xml` fix and the ESP stance corrections. Neither affects play --
the stance records are the losing copy -- but the installer text is wrong until #64 ships.
