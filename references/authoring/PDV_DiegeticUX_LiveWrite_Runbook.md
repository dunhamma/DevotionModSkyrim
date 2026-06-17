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

1. Back up `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp`.
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

## Status — 2026-06-17 (D1 enabled + proven, ships on)

D1 is **enabled and shipped on**. `D1Enabled = true` is baked in the ESP via
`tools/pdv-diegetic-author`, so new games get the diegetic layer by default;
existing saves use the MCM runtime toggle. The counted transition proof passed
in-game (tier, curse onset, curse cure, and neglect all fire their real surfaces;
the five tones were previewed, tuned, and accepted). Sound is fixed:
`PDV_DiegeticDirector.RebindSounds()` self-heals stale `Sound`-property bindings
(an earlier build authored the cues as `SoundDescriptor`/SNDR, which a `Sound`
property cannot hold, so they baked as `None`; they are now `SoundMarker`/SOUN
markers and the director re-resolves them by FormID on load / first dispatch).

## D1 in-game test tools (MCM Debug page)

Dev-page controls added this pass for tuning/proof without questlines:

- **Diegetic surfaces (D1)** — runtime on/off (per-save; ships on for new games).
- **Preview tone: Reverent / Revelation / Dread / Release / Absence** — fire a tone's
  screen + sound on demand, repeatably. Bypasses the `D1Enabled` gate and the
  one-shot `SurfaceTransition` guard, and clears stacked shaders. Use for tone feel (FP-043).
- **Preview curse music bed** — on/off (music is keyed to event-class, not tone).
- **Clear tone preview** — remove the shader aura.
- **Force neglect (active patron)** — drops the patron's piety into the neglect band,
  clears the once-per-drop toast guard, and runs the neglect layer so the REAL
  `neglect -> drop -> absence` surface fires. Patron-only.

### Real-transition triggers (FP-044; D1 must be On; each fires once per game)

- **Tier (reverent):** dev page -> Apply target piety -> cross a tier. The debug piety
  setters now pass `surfaceTierUp = true`, so a debug jump surfaces the full tier-up
  (previously `false` suppressed toast + D1).
- **Curse onset (dread):** become a real werewolf or vampire.
- **Curse cure (release):** Falion's *Rising at Dawn*, or console removal of the signals
  PDV reads (`PDV_CurseState`): vampire `player.removefromfaction 000C4DE0` +
  `player.removespell 000ED0A8`; werewolf `player.removefromfaction 000917E2` +
  `player.removespell 000F5AE0`. The curse poll then fires the cure surface.
- **Neglect (absence):** the **Force neglect** button above.

Note: previews bypass the gate/one-shot (repeatable); real transitions honor both
(fresh game to re-test). A full Skyrim restart loads new `.pex`/ESP/UI.
