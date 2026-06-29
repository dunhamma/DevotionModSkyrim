# PDV Session Handoff -- 2026-06-29 Pre-Beta Race Closeout

## TL;DR

Breton Hidden Art, Orc organic life-mode, and Nord current beta-feel packets are
closed for the current race manual/runtime scope. The strict beta audit is still
`NOT_BETA_READY`, but the remaining race blockers are now Imperial and Dunmer
only.

Do not reopen Breton/Orc/Nord current-packet evidence unless a new runtime
regression appears. Their optional/deferred design arms remain separate from the
current beta-feel closeout.

## What Changed

- Prisma and Book of Days are player-owned surfaces only. Gameplay/runtime
  events can update stored data and send allowed toasts, but they must not open
  the focused Devotion panel or Book of Days.
- Book of Days close behavior is hardened through the native bridge, UI, and
  MCM hotkey path. Escape, X, and configured key close paths are expected to
  work without opening the full Skyrim pause menu.
- Dashboard/Ledger driver capture is no longer active-patron gated; every
  nonzero `AwardPiety` movement records a driver reason.
- Broad Nord Old Ways T1 syncs immediately from accepted sources rather than
  waiting for the next dawn pass.
- Overlapping old Aedric `Boon_*` grants are opted out/cleared for manager-owned
  race reward families, avoiding duplicate Talos/Kyne/Auri-El stacks.
- Public deity labels are normalized through shared display helpers so lowercase
  `kyne`, `akatosh`, `nord`, etc. do not leak into Prisma or Book of Days.
- Vanilla shrine blessing activation is now `no-vanilla-effect`: no vanilla
  stat blessing, cure disease, or blessing removal. Supported shrines fire a
  hidden once-per-day PDV shrine-prayer signal instead.

## Shrine Rule Locked

Backend shrine prayer can award multiple cultural alias ledgers from one shrine,
but Book of Days writes exactly one player-origin-appropriate deity name.

- Kynareth shrine awards Kynareth, Kyne, and Khenarthi; Nord journal line says
  Kyne, Khajiit says Khenarthi, everyone else says Kynareth.
- Akatosh shrine awards Akatosh, Auri-El, and Alkosh; Khajiit journal line says
  Alkosh, Altmer/Bosmer says Auri-El, everyone else says Akatosh.
- Arkay shrine awards Arkay and Tu'whacca; Redguard journal line says
  Tu'whacca, everyone else says Arkay.
- Zenithar shrine awards Zenithar and Z'en; Bosmer journal line says Z'en,
  everyone else says Zenithar.
- Auriel shrine awards Auri-El and Akatosh.
- Direct-only shrines: Dibella, Julianos, Mara, Stendarr, Talos.
- Nocturnal and Dragonborn Good Daedra shrines are intentionally outside this
  generic +2 bridge for now to avoid Daedric/Dunmer double-award drift.

## Proof This Session

Commands that passed during closeout:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_compile.mjs --script PDV_ShrinePrayerEffect --script PDV_EventBus --script PDV__ManagerQuest
node .\tools\pdv_compile.mjs --script PDV_MCM
dotnet run --project .\tools\pdv-shrine-blessing-author -- --check
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_legacy_boon_overlap_audit.mjs
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Expected current outcomes:

- `pdv_compile`: PASS for touched scripts.
- Shrine author check: PASS.
- Prisma UI audit: PASS.
- Legacy boon overlap audit: PASS.
- Full verifier: FAIL=0, with one existing WARN for medallion glyph fallback.
- Strict beta readiness audit: `NOT_BETA_READY`, FAIL=2, blockers are Imperial
  and Dunmer race manual/runtime evidence plus the release-claim boundary.

## Current Race State

Closed for current beta packet:

- Altmer, Argonian, Bosmer, Breton, Khajiit, Nord, Orc, Redguard.

Still required before race beta-feel claim:

- Imperial: all seven required manual/runtime slots.
- Dunmer: all seven required manual/runtime slots.

Final-world placement remains separate from these current race packets.

## Next Session Flow

Start with preflight:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_prisma_ui_audit.mjs
```

Then run the remaining race sheets:

1. Imperial: `references/authoring/PDV_RunSheet_Imperial_BetaFeel.md`
2. Dunmer: `references/authoring/PDV_RunSheet_Dunmer_BetaFeel.md`

For each race, keep proof buckets separate:

- accepted route/runtime proof
- wrong-origin rejection
- generic-source silence
- anti-farm/duplicate behavior
- Survey/status clarity
- Active Effects or stack snapshot
- Book of Days/Prisma surface check
- manual feel note
- save/load sanity where the sheet asks for it

After each race passes, update `PDV_Phase20_ManualEvidenceLedger.json`, then
rerun:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Do not claim beta-ready until the strict audit has no `FAIL` blockers.

