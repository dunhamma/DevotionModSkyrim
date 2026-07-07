# PDV Dislike Consequence V2 Handoff Back - 2026-07-07

## Scope Closed

Implemented the V2 shared deity dislike-consequence backend from
`PDV_CodexHandoff_DislikeConsequence_V2.md`.

The implementation is deliberately domain-keyed:

- 32 deity likes/dislikes actors map to 7 disfavor domains.
- Daedric prince dislike lanes stay out of scope because prince prices already
  carry felt penalties.
- `|baseDelta| <= 0.5` remains piety loss plus surfacing only.
- `0.5 < |baseDelta| <= 1.0` applies a light sting for 2 in-game hours.
- `|baseDelta| > 1.0` applies a sharp sting for 4 in-game hours.
- Standing gate is piety >=25 or current active patron.
- Same-domain stings refresh instead of stacking.
- At most 3 domains may be active at once.
- Dislike stings only run through likes/dislikes event context; neglect, decay,
  rivalry, scripted penalties, and Daedric prince prices do not double-sting.

## Files Added

- `references/authoring/PDV_DislikeConsequence_DesignReference.md`
- `references/authoring/PDV_DislikeConsequenceRecords.spec.json`
- `references/authoring/PDV_DislikeConsequence_TestLedger.json`
- `references/authoring/PDV_DislikeConsequence_HandoffBack_2026-07-07.md`
- `tools/pdv-dislike-consequence-author/`
- `tools/pdv_dislike_consequence_audit.mjs`

## Files Updated

- `live-source/Scripts/Source/PDV__ManagerQuest.psc`
- `live-source/Scripts/Source/PDV_ActionRouter.psc`
- `live-source/Scripts/Source/PDV_EventBus.psc`
- `tools/pdv_felt_registry_gen.mjs`
- `references/authoring/PDV_FeltEffectRegistry.json`
- `references/authoring/PDV_FeltFamilyEvidenceLedger.json`
- `AGENTS.md`
- `PDV_MOD_SETUP.md`

## Live Writes

`Devotion.esp` was written by:

```powershell
dotnet run --project .\tools\pdv-dislike-consequence-author\PdvDislikeConsequenceAuthor.csproj -- --write
```

Backup:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\dislike-consequence\Devotion.esp.20260707-182952.bak
```

SEQ refresh was run after the ESP write:

```powershell
node .\tools\pdv_refresh_seq.mjs --write --json
```

It reported `changed=false`, `questCount=40`, and wrote backup:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260707-083415.bak
```

## Verification

Passing gates from this closeout:

```powershell
dotnet build .\tools\pdv-dislike-consequence-author\PdvDislikeConsequenceAuthor.csproj
dotnet run --project .\tools\pdv-dislike-consequence-author\PdvDislikeConsequenceAuthor.csproj -- --dry-run
dotnet run --project .\tools\pdv-dislike-consequence-author\PdvDislikeConsequenceAuthor.csproj -- --write
dotnet run --project .\tools\pdv-dislike-consequence-author\PdvDislikeConsequenceAuthor.csproj -- --check
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_ActionRouter --script PDV_EventBus --json
node .\tools\pdv_dislike_consequence_audit.mjs --self-test
node .\tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json
node .\tools\pdv_felt_registry_gen.mjs --self-test
node .\tools\pdv_felt_registry_gen.mjs --sync-ledger --json
node .\tools\pdv_felt_registry_gen.mjs --check
node .\tools\pdv_felt_trace_audit.mjs --self-test
node .\tools\pdv_felt_trace_audit.mjs --json
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_ascii_guard.mjs --summary --ext .psc,.mjs,.cs,.csproj,.md,.json ...
git diff --check
```

Key results:

- Papyrus compile: 3 scripts, 0 errors, 0 warnings.
- Strict dislike audit: `PASS=32`.
- Felt registry: `471 effects`, `148 families`, `disfavor-sting=14`.
- Felt trace: `PASS=471`, `RED=0`, `SKIP=0`, bridge live.
- Default verifier: `PASS=3546`, `WARN=1`, `INFO=68`, `FAIL=0`.
- ASCII guard: 20 scoped files scanned, all ASCII-clean.
- `git diff --check`: no whitespace errors; only existing CRLF conversion warnings.

## Runtime Proof Still Pending

This closeout is backend/readback/compile proof only. It does not claim in-game
Requiem feel or Active Effects proof.

Record runtime/manual results in
`references/authoring/PDV_DislikeConsequence_TestLedger.json`.

Per domain, prove:

- A positive/eligible relationship can produce the expected sharp sting.
- A no-standing negative case produces piety loss and surfacing but no sting.
- A `|delta| <= 0.5` case remains piety-only.
- Repeating the same domain refreshes instead of stacking.
- The effect is visible/felt under Requiem.
- Domain cap behavior keeps simultaneous stings to at most 3.
