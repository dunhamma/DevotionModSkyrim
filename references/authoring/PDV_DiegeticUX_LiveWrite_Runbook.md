# PDV Diegetic UX Live-Write Runbook

**Status:** repo-only handoff. No live step is implied by this runbook.

Use this after the UX worktree is approved for a deliberate live test lane or after the branch is merged. Do not merge this worktree into `main` just to test CK writes; a live test lane can be run separately with backups and explicit restore/keep decisions.

## Preflight

Run these from the UX worktree before touching the live mod:

```powershell
node .\tools\pdv_diegetic_ux_check.mjs
node .\tools\pdv_diegetic_ux_author.mjs plan --json
```

Both must pass. The planner is dry-run-only; it does not write the framework ESP, live source, live PEX, or SEQ.

## D0 Inert Live Scaffold

D0 exists to prove the scripts and CK wiring can live in the framework without changing player-visible behavior.

1. Back up `D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp`.
2. Promote these source files from `scratch/p2-toast-panel-fix\` to `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\`:
   - `PDV_DiegeticDeps.psc`
   - `PDV_DiegeticDirector.psc`
   - `PDV__ManagerQuest.psc`
3. Compile live:

```powershell
node .\tools\pdv_compile.mjs --script PDV_DiegeticDeps --script PDV_DiegeticDirector --script PDV__ManagerQuest
```

4. In CK or an approved authoring helper, create or verify Start Game Enabled quest `PDV_DiegeticDeps`.
   - Attach script `PDV_DiegeticDeps`.
   - Set `ForceAllDepsAbsent = false`.
5. Create or verify Start Game Enabled quest `PDV_DiegeticDirector`.
   - Attach script `PDV_DiegeticDirector`.
   - Set `PDV_DiegeticDepsService -> PDV_DiegeticDeps`.
   - Set `D1Enabled = false`.
   - Set `TraceDispatch = true`.
   - Wire current-state read properties:
     - `PDV_GLO_ActivePiety`
     - `PDV_GLO_ActiveTier`
     - `PDV_GLO_ActiveDeityIndex`
     - `PDV_GLO_OriginRace`
     - `PDV_FLST_AllDeities`
6. Wire `PDV__ManagerQuest.PDV_DiegeticDirectorService -> PDV_DiegeticDirector`.
7. Refresh SEQ because new Start Game Enabled quests were added.
8. Run:

```powershell
node .\tools\pdv_verify.mjs --json
```

9. Run fresh-start or QASmoke no-behavior-change smoke:
   - Existing startup still works.
   - Survey/status still works.
   - Prisma panel still stays opt-in.
   - Tier/neglect/curse hooks do not produce visible diegetic output because `D1Enabled = false`.
   - Papyrus log has no missing-script, missing-property, or `None` call warnings from `PDV_Diegetic*`.

## D1 Visible Pilot

Only start D1 after D0 passes.

1. Create or duplicate placeholder channel records listed in `PDV_DiegeticUX.manifest.json`:
   - IMAD: `PDV_IMAD_Reverent`, `PDV_IMAD_Revelation`, `PDV_IMAD_Dread`, `PDV_IMAD_Release`, `PDV_IMAD_Absence`
   - SPEL: `PDV_Abil_Shader_Reverent`, `PDV_Abil_Shader_Revelation`, `PDV_Abil_Shader_Dread`, `PDV_Abil_Shader_Release`
   - SNDR: `PDV_SND_Chime`, `PDV_SND_Swell`, `PDV_SND_Hollow`, `PDV_SND_RisingChime`, `PDV_SND_Distant`
   - MUSC: `PDV_MUS_CurseBed`
   - MISC: `PDV_DevotionMedallion`
   - BOOK: `PDV_BookOfDays`
2. Wire each matching property on `PDV_DiegeticDirector`.
3. Keep soft-dependency behavior conservative:
   - DF absent -> medallion falls back to Survey/status cache.
   - DBF absent -> journal lines cache only.
   - NiOverride/bodymark and OAR custom art remain V2/deferred.
4. Set `D1Enabled = true`.
5. Run verifier.
6. Run counted QASmoke proof:
   - Tier-up transition fires once.
   - Neglect drop transition fires once.
   - Curse onset and cure transitions fire once per direction.
   - Khajiit/Dunmer routine substrate acts refresh medallion/journal-digest state but do not route through one-shot `SurfaceTransition`.
   - Save/load preserves one-shot guards and reapplies persistent music/mark state without duplicate output.
   - Forced deps-absent run degrades cleanly.

## Boundaries

- Do not claim D0 complete from compile proof alone; D0 requires CK/ESP wiring and no-behavior-change smoke.
- Do not claim D1 complete from record creation alone; D1 requires counted transition proof.
- Do not enable bodymark or OAR art channels in V1. Those are V2 assets.
- Do not make Prisma panel auto-open as part of this lane; the existing opt-in guard stays.
