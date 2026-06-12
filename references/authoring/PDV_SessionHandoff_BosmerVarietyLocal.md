# Session Handoff - Bosmer Variety Local Completion

**Created:** 2026-06-12
**From:** Remote (cloud) session (Claude) - no Windows tooling: no Mutagen bridge, no Papyrus compiler, no ESP, no game
**To:** Local Windows dev session (Anvil MO2 setup)
**Why:** The Bosmer "The Story Goes On" tranche is content-complete on `main` (records contract + fail-closed author tool + full Papyrus paste-in), but every remaining step needs the local machine: FormID extraction, the Mutagen author run, the canonical `.psc` edit + recompile, and the fresh-save smoke. This handoff is the exact pickup script.

## State on main (all merged; nothing in flight)

| Artifact | Path | State |
|---|---|---|
| Roadmap + 5 design locks | `references/authoring/PDV_RaceVarietyTranche_Roadmap.md`; tranche sections in the Bosmer/Orc/Altmer/Redguard/Khajiit race sheets | LOCKED (shapes/gates/caps); magnitudes tunable behind `PDV_RaceEffectReviewLedger.md` Variety Tranche Gate |
| Bosmer record contract | `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json` | DRAFTED; 2 of 6 Songs LCTN FormIDs verified; NOT dry-run |
| Bosmer author tool | `tools/pdv-bosmer-variety-author/` | Authored, NOT built/run; FAIL-CLOSED on the 4 unverified Songs slots and on any error before write |
| Bosmer Papyrus layer | `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md` | Paste-in spec (Steps 1-3 incl. 2d/2e/2f); NOT applied/compiled |
| Live manager snapshot used as authoring base | `generated/live-devotion-snapshot/2026-06-12-daedric-champion-parity/Scripts/Source/PDV__ManagerQuest.psc` | Reference only; canonical `.psc` lives in the Devotion MO2 mod |

PRs #7 and #8 are squash-merged (`e7b5f8e`, `2ff6491`). The dev branch `claude/race-thickness-solutions-hegbfq` is merged and disposable; remote deletion was blocked by the cloud git proxy, so delete it from the GitHub UI if it is still there.

## Decisions already locked - do not relitigate

1. **Keeper told-self = CarryWeight +15**, not barter (vanilla prices are Speech-governed, already Speaker's effect). Race sheet, manifest, and tool agree.
2. **Eldergleam fires on the cave interior cells**, not the exterior approach (user-confirmed 2026-06-12): arm-on-location + OnUpdate poll, mirroring `TryArgonianEldergleamInterior`, shared cells `0x3A9EC/0x3A9E0/0x3A9E3`, award keyed to LCTN `0x000192AC`.
3. **Eldergleam is intentionally in BOTH the Argonian Waters and Bosmer Songs sets** (shared-site rule: race-distinct vision text).
4. **Both Baan Dar signatures exist on purpose** (Bosmer escape-below-20% vs Khajiit survive-outnumbered); documented in the roadmap's Resolved Decisions, not in the equity-waiver CSV (wrong schema).

## Pickup sequence (in order; each step gates the next)

### 1. Resolve the 4 PENDING Songs LCTN FormIDs

`node .\tools\pdv_extract_vanilla_gameplay_refs.mjs` (or the SkyrimGamePlayReferences bridge) for:
`WhiterunWindDistrictLocation` (confirm which LCTN actually covers the Gildergreen courtyard - may be a temple sub-location), `EvergreenGroveLocation`, `ClearspringTarnLocation`, `AutumnshadeClearingLocation`.

Fill the resolved FormIDs in BOTH places (they are deliberately duplicated):
- manifest `formList.entries[2..5]`: set `formId`, flip `verified` to `true`;
- `tools/pdv-bosmer-variety-author/Program.cs` `greenSongs` table: set the `LocalId` values.

If a candidate has no real LCTN (possible for wilderness POIs - some are cells/markers only), swap in a substitute green site and record the swap in the manifest entry's `why` (Argonian precedent: Clearspring->Ancestor Glade swap note).

### 2. Build + dry-run the author tool

`dotnet build` in `tools/pdv-bosmer-variety-author/`, then run with `--dry-run` against the framework ESP (CK/Skyrim must not hold the file). Expected first-pass fixes are **C# enum member names only** (manifest `atRiskEnumNames`): `ActorValue.Archery` may be `Marksman`, `Speech` may be `Speechcraft`, plus `SpeedMult` - same drift family as the Argonian batch's `MagicResist -> ResistMagic`. Never change FormIDs or magnitudes to satisfy the compiler.

### 3. Write + verify

Run without `--dry-run` (tool backs up the ESP first, refuses to write while any error exists), then `--check` for the fail-closed FLST slot dump, then `node .\tools\pdv_verify.mjs` (expect FAIL=0; WARN baseline was 2 pre-existing).

### 4. Apply the Papyrus layer + recompile

Apply `PDV_BosmerVariety_PapyrusHandoff.md` exactly: Step 1 property decls + Step 3 functions into the canonical `PDV__ManagerQuest.psc`; Step 2a sleep dispatch; Step 2b dawn calls; Step 2c Exchange call; Step 2d location-change line + Step 2e OnHit hook into `PDV_PlayerEvents.psc`; Step 2f `TryBosmerEldergleamInterior()` beside the Argonian poll in OnUpdate. Known likely compile fixes (listed in the handoff): the `PDV_BosmerPathTrack.ForceState(...)` setter name in `DebugSeedBosmer` (mirror whatever `DebugSetBosmerPathState` uses), and the `GetActorValuePercentage("Health")` signature. Recompile via `node .\tools\pdv_compile.mjs` - 0 errors, 0 warnings.

### 5. Fresh-save smoke (NEW save or main-menu `coc qasmoke`; VMAD props bake at first init)

Seed with `cqf PDV__ManagerQuest DebugSeedBosmer <path 0-3>` (clears Naming/signature cooldowns, +3 discoveries). Per-lever checks:
- Hearth (path 1): sleep -> declaration prompt; decline re-prompts only after 3 days; declared-cell sleep after 3+ new locations -> `A Tale Carried` + log `Bosmer favor LivingStory.CommunityKept`.
- Naming (any path, at hearth or a Songs site): menu; "Not yet" does NOT spend the 7-day cooldown; chosen told-self in Active Effects; path-switch -> fades at dawn ("The told-self goes quiet"), returns at dawn on path recovery.
- Songs: first arrival per site -> vision MessageBox + path piety; Eldergleam ONLY once inside the cave cells; all 6 -> milestone MessageBox.
- Scales at Rest (path 2): complete a favor/bounty quest -> Speech pulse, once/day cap on the second.
- **Baan Dar Gap (path 3) - the one real cadence risk:** drop below 20% health in combat -> 5s speed burst, once/day. This is the only NEW event registration (player-alias OnHit); confirm it stays silent on every other hit and off-path.
- Dreams: occasional path-keyed line; elevated the night after a path change; never stacks with a shown menu.
- Wrong-origin + generic silence: non-Bosmer origin -> zero movement from all of the above.

### 6. Closeout

Write `PDV_BetaTestPacket_Bosmer.md` (model: `PDV_BetaTestPacket_Argonian.md`) from the smoke evidence; add BetaContract rows + run `pdv_completeness_audit.mjs`; doc-sync AGENTS.md (decisions-log entry + build status + this handoff's row); update the roadmap's Build status line (Bosmer -> runtime-proven) and the manifest `status` field.

## After Bosmer

Next per the locked roadmap order: the **Orc "Witnessed" batch** (`PDV_OrcVariety_RecordBatch.manifest.json` + `tools/pdv-orc-variety-author`, same pattern). Note for its manifest: carry the forward note that the cell-keyed Hearth-Held mechanic migrates into `PDV_SacredPlace` if that system is ever built (Resolved Decision 5).
