# Live Devotion Source Snapshot - 2026-06-20 Restore Recovery

This snapshot captures the live Devotion Papyrus source after the restore-boundary
recovery pass on 2026-06-20.

Files captured:

- `Scripts/Source/PDV__ManagerQuest.psc`
- `Scripts/Source/PDV_MCM.psc`
- `Scripts/Source/PDV_PlayerEvents.psc`
- `Scripts/Source/PDV_ActionRouter.psc`
- `Scripts/Source/PDV_EventBus.psc`

Recovered behavior captured here:

- P2 `po3_book` suffix-aware book notice gate.
- Startup per-path confirm selector.
- Orc life-mode organic source wiring.
- Breton per-book Hidden Art notice copy.
- Argonian bed-of-choice move-home / re-adapt helpers.
- Existing Phase 0 Prisma choice channel and Argonian debug seed helpers.
- Book of Days MCM hotkey toggle and Prisma journal race/path line.

Targeted compile command used after patching:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents --script PDV_ActionRouter --script PDV_EventBus --skip-verify
```

All listed scripts compiled with `0 error(s), 0 warning(s)` after their respective
restore passes.

This is source/machine recovery evidence only. Runtime/manual proof still needs a
fresh Skyrim session for the affected book notice, startup, Orc organic, Breton
notice, Argonian move-home paths, and Book of Days in-game overlay open/close.
