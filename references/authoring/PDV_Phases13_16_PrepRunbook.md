# PDV Phases 13-16 Prep Runbook

This runbook captures the current creation boundary for Phases 13-16.

What is already live:

- Phase 13 has a real `PDV_DaedricPath_Hircine` pilot script, manager routing, EventBus routing, MCM actions, stigma global, the Hircine proof activator, the three Hircine price records wired through `PDV_DaedricPathBase`, and runtime proof on 2026-05-28 for the live gate/exit loop: no piety before day-three commitment signals, Seeker and Devoted price activation on the multi-day hunt-rite cadence, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path.
- Phase 14 has a generic formal-offer engine on `PDV__ManagerQuest`, `PDV_GLO_PatronState`, MCM debug actions, and a strict verifier gate under `--strict-commitment`, with Kyne runtime-proven on 2026-05-28 for seed/evaluate, decline, refuse, accept, and accepted-patron persistence.
- Phase 15 has a real `PDV_CurseState` service quest/global seam with manager and MCM wiring, plus runtime-proven werewolf/vampire/none transitions on the shared seam as of 2026-05-28.
- Phase 16 has a generic dawn-owned neglect selection pass, live manager-owned cap logic (`NEGLECT_ACTIVE_CAP = 3`), and broad-worship suppression, with Kyne runtime-proven on 2026-05-28 as the first authored neglect spell packet.

What remains deferred:

- Phase 13: future authored recovery accelerants or a separate Champion-tier smoke if content later needs them, but the current Hircine/Nord pilot proof bar is runtime-closed.
- Phase 14: non-debug in-world offer surfaces and more deity-authored offer content beyond Kyne.
- Phase 15: extra compat adapters such as Sacrosanct cross-routing and broader deity-authored transition content.
- Phase 16: per-deity neglect records beyond Kyne and a clean verifier split from decay.

Verifier entrypoints created in this batch:

```text
node .\tools\pdv_verify.mjs --strict-phase13
node .\tools\pdv_verify.mjs --strict-phase14
node .\tools\pdv_verify.mjs --strict-phase15
node .\tools\pdv_verify.mjs --strict-phase16
```

Important interpretation:

- `--strict-phase14` currently rides the live `--strict-commitment` gate plus the new Phase 14 manifest.
- `--strict-phase16` currently rides the live `--strict-neglect-decay` gate plus the new Phase 16 manifest, because neglect and decay still share one dawn-owned source pass.
- These gates prove the Phase 13-16 source and framework contracts. As of 2026-05-28, the manual runtime matrix is closed for Phases 13-16.
- Durable Phase 13 proof lesson: same-day `Hircine hunt rite` spam is anti-repeat-scaled before stigma or piety is applied. Counted Seeker proof must use one rite on each of three in-game days.

Recommended next authoring order from here:

1. Phase 14: add the first non-debug in-world offer surface when the presentation contract is ready.
2. Phase 15: add compat adapters only where a real mod path needs them; keep `PDV_CurseState` the sole curse owner.
3. Phase 16: author more per-deity neglect packets only when content needs them, then split the verifier gate from decay.
4. Phase 13 follow-up only if content needs it: authored recovery accelerants, Champion-tier explicit smoke, or a second Prince pilot.
