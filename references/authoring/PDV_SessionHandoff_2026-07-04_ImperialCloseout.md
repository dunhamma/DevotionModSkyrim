# PDV Session Handoff -- 2026-07-04 Imperial Closeout

## TL;DR

Imperial V1 is passed for the current race beta-feel packet. The remaining race
manual/runtime blocker is Dunmer.

Do not reopen Imperial unless a regression touches Concordat, Talos offer
gating, civic-service route attribution, formal offers, Active Effects, or
Book-of-Days/Ledger surfacing. Final-world placement remains separate from this
packet closeout.

## What Passed

Imperial `PDV_RunSheet_Imperial_V1.md` slots 1-7 are recorded as PASS:

- no new mesh, placed proof object, or visible shrine object required
- Survey/status wording accepted after civic/standing/Concordat copy polish
- Active Effects stack stayed civic/patron-owned; no standalone Concordat buff
- formal offer accept/refuse surfaces and terminal-refuse cadence passed
- broad civic worship capped at Tier 2/Faithful and did not grant Champion
- Talos book routed Talos piety pressure, not Concordat movement
- Concordat raw-value emitters moved by expected amounts; band lag is expected
- Concordat reorientation wrote the next-dawn Book of Days line
- Talos offer blocked at Concordat raw >50 and appeared at <=50
- civic-service quest-stage route produced Ledger and Book of Days surfaces
- wrong-origin rejection passed using a non-Imperial, non-Nord origin
- generic civic/Talos-proximity actions stayed silent
- final feel read as concrete civic practice under public law

## Implementation Notes From The Closeout

- Book of Days and Ledger were deepened so every reason-bearing `AwardPiety`
  path can expose driver attribution rather than only selected foreground
  routes.
- The Book of Days is locked back to Chronicle-only in Prisma; the full Ledger
  remains a separate focused Devotion panel surface.
- Follow-up in-game sanity on 2026-07-04: tester reported checks 1 and 2 pass
  for the Chronicle-only rollback prompt. This confirms the narrow Book/Panel
  UX split, not any unrelated race or final-world placement bucket.
- Dawn now writes one concise Book of Days digest for positive deity or Prince
  movement: `At dawn, your acts fed ...`.
- The digest is part of the dawn pass, not a separate end-of-day timer.
- Imperial civic-service surfaces use the Chronicle and Ledger rather than a
  forced full Prisma panel.
- Kynareth/Kyne/Khenarthi display is player-origin aware; Imperial-facing
  Kynareth should not show as Kyne in panel or Book of Days.
- The Talos offer remains gated by Concordat raw value: blocked above 50,
  allowed at 50 or below.

## Proof This Session

Commands run during the closeout included:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_ledger_coverage_audit.mjs
```

Expected current outcomes from the last run:

- `PDV__ManagerQuest` compile: PASS, `0 error(s), 0 warning(s)`.
- Prisma UI audit: PASS, including Book of Days dawn digest checks.
- Book of Days audit: PASS=113, WARN=0, FAIL=0 after the Chronicle-only
  rollback guard.
- In-game sanity: tester reported checks 1 and 2 pass for the Book-of-Days
  Chronicle-only / separate-panel Ledger UX split.
- Hotkey remediation: Papyrus log showed stale `PDV_MCM.pex` still calling
  `SendPrismaJournalPayload(True, 1)` after the Chronicle-only manager rollback.
  Recompiled `PDV_MCM` from the current one-argument source; compile PASS and
  Book/Prisma audits stayed clean. Requires one fresh in-game key retest.
- Follow-up guard: `pdv_prisma_ui_audit` and `pdv_book_of_days_audit` now fail
  if live `PDV_MCM.pex` is stale against the manager journal payload contract.
- Prisma-to-1.0 audit: PASS with manager repo/live parity.
- Ledger coverage audit: CLEAN, no untracked `AwardPiety` sites.

Proof boundary: these are compile/static/audit proof plus tester manual/runtime
proof for Imperial. They do not prove Dunmer and do not promote final-world
placement.

## Updated Evidence Sinks

- `references/authoring/PDV_RunSheet_Imperial_V1.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `references/authoring/PDV_InGameTestingNeeded_Runbook.md`
- `references/authoring/PDV_BetaFeelBurndown.md`

## Next Session Flow

Start with preflight:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_prisma_ui_audit.mjs
```

Then run Dunmer:

```text
references/authoring/PDV_RunSheet_Dunmer_V1.md
references/authoring/PDV_RunSheet_Dunmer_BetaFeel.md
```

Required Dunmer evidence slots remain:

- wrong-origin rejection
- generic Daedric/generic shrine/generic crime silence
- Survey/status clarity
- Active Effects or stack snapshot
- immersive hook proof (4a Reclamation focus PASS; 4b ash-prayer/home rite
  behavior PASS through home bonus; exact revised home-bonus toast display still
  needs one retest; 4c curse silence behavior PASS by tester report, but revised
  werewolf/restored Survey copy needs one display retest; 4d outdoor Good Daedra
  shrine route proof PASS from Papyrus.0.log and Prisma toast display PASS after
  restart; 4e deviation-price is no longer deferred: DA01 Black Star stage 110 is
  static/readback wired to `RouteDunmerDeviationPrice`, but still needs runtime
  and manual proof. After the post-fix pause build, 4e should also show the
  `Reclamation strained` toast and Chronicle line, while the focused Devotion
  panel stays Dunmer-roster scoped and does not expose off-race DA01 ledger rows.
  DA02/sacrifice is not part of 4e.)
- asset status
- manual feel note

After Dunmer evidence is recorded, update:

```text
references/authoring/PDV_Phase20_ManualEvidenceLedger.json
references/authoring/PDV_PreBetaRaceGateLedger.md
references/authoring/PDV_InGameTestingNeeded_Runbook.md
references/authoring/PDV_BetaFeelBurndown.md
```

Then rerun:

```powershell
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Do not claim beta-ready until the strict audit has no `FAIL` blockers.

## Watch Items

- Rerun `pdv_ledger_coverage_audit` after any new piety or substrate writer.
- Rerun Prisma audits after any Book of Days, toast, or panel payload change.
- Recompile both `PDV__ManagerQuest` and `PDV_MCM` whenever the Book-of-Days
  payload function signature or open/close contract changes.
- The 2026-07-04 pause build added DA01 deviation-price Book-of-Days/toast
  surfacing and focused-panel origin-roster filtering across all races. This is
  compile/static/audit clean only until the next Dunmer 4e in-game retest.
- Current 2026-07-04 live Papyrus route log could not be used for Dunmer 4c
  number confirmation: the active profile has logging enabled, but only stale
  January `Papyrus.0.log` files were found. Treat 4c as tester manual/runtime
  proof plus source/compile proof until a fresh log is captured.
- Keep Book of Days digest concise; do not convert every movement into a toast.
- Do not use `cqf` in tester instructions. Use real MCM buttons, normal play,
  or verified console commands.
- Keep Imperial Concordat band proof tied to raw value, not the lagging band
  label.
