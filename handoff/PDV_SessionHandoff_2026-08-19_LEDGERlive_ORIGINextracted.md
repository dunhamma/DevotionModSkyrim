# Session handoff -- 2026-08-19 (overnight): LEDGER live, ORIGIN extracted

Morning summary of the overnight run. All work is committed, NOTHING pushed. Detail lives in
the per-module specs; this is the resume pointer.

## What's done + verified

### LEDGER -- extracted, verified, WIRED LIVE on V3Dev
Branch feature/v3-ledger-extraction (off f01d1ada). 216 fns + 81 props into PDV_DevotionLedger;
reconstruction-parity proven (0 logic changes), compile 0/0. **ESP wired live**: host QUST
PDV_DevotionLedger 0x04071792, 34 properties filled, LedgerRuntime on the manager, check_errors
clean, SEQ regenerated (44 SGE quests). Devotion.esp backup at
Devotion-V3Dev/Devotion.esp.pre-ledger-backup. See PDV_2_0_LEDGER_ExtractionSpec.md.

### ORIGIN -- extracted (pure move complete), NOT wired
Branch feature/v3-origin-extraction (off the LEDGER branch). 664 of 667 fns moved into
PDV_OriginRuntimeBase across 6 parity-clean tranches (6414077b, 6e9b6151, 05b06011, f56b50b0,
b9036e9d, 760780de). 3 gain-multipliers deferred; 557 properties deferred (Manager.-qualified in
place). Capstone parity removed=0, full compile 101 PASS. Module INERT until wiring. See
PDV_2_0_ORIGIN_ExtractionSpec.md.

### Supporting work
- Durable resolver-aware verifier fix (extractions no longer break definition-needles).
- 20 pre-existing stale needles resolved; FAVOR registered in the release manifest.
- Provider-seam spec drafted (branch feature/v3-provider-seam-spec, 9e1c3a65).
- Runbooks: LEDGER smoke + FAVOR/LEDGER co-run checklist.

## Your move (in priority order)

1. **Run the FAVOR + LEDGER co-run smoke** on a NEW GAME (both host quests need a fresh save) --
   references/authoring/PDV_2_0_Gate05_CoRun_Checklist.md. This confirms LEDGER's GATE 0.5 runtime.
2. **Review the ORIGIN branch** (6 commits). It's a pure move; the specs cite the parity/compile
   evidence per tranche. Decide merge order (LEDGER first, then ORIGIN).
3. **Supervised: the provider seam** -- the one architectural step deferred across both LEDGER and
   ORIGIN. Build PDV_GainModifierProvider, make the ORIGIN runtime host a provider, move the 3
   deferred multipliers in, convert LEDGER's interim Manager.Get*GainMultiplier reach-backs to
   Providers[]. Spec: PDV_2_0_ProviderSeam_ExtractionSpec.md.
4. **Supervised: ORIGIN ESP wiring** -- create the PDV_OriginRuntimeBase host QUST + Manager backref
   + manager OriginRuntime forward-ref (LIGHTER than LEDGER -- no property fills until the property
   consolidation pass). Then ORIGIN goes live like LEDGER.
5. Property-consolidation pass (move ORIGIN's 557 property decls into ORB); manifest reconciliation;
   full env gate roll-up against V3Dev.

## Branch chain (all unpushed)
feature/v3-big-update -> feature/v3-ledger-extraction -> feature/v3-origin-extraction ;
feature/v3-provider-seam-spec (seam design, parallel).

## Boundaries kept overnight
No push, no live-ESP writes beyond the owner-approved LEDGER wiring, no game-env gates, everything
reversible + committed. V3Dev deployment currently reflects the LEDGER branch (piety core routed
through the wired ledger).

---

## UPDATE — 2026-08-19 session 2 (both GATE 0.5 tiers passed; MCM + ORIGIN-adapter queue)

### Gates: PASSED (in-game, owner-run)
- **LEDGER GATE 0.5 runtime = GREEN.** In-game on a fresh Altmer: liveness (Patron/Standing/Active
  piety render) → "Apply target piety" → committed to **Mara** as patron → "Apply curated signal"
  accrued to PietyToday (the Site-A pipeline round-trip through `Manager.LedgerRuntime.AwardPietyFromLikesDislikes`)
  → dawn consolidated it into committed piety + tier. No None-`LedgerRuntime` errors.
- **FAVOR GATE 0.5 = GREEN on the wiring proof.** A favor (Dawn Steadiness) activated cleanly through
  the wired ledger, zero None-ref errors. The visible-toast box is NOT ticked, but that is **blocked by
  an MCM bug, not FAVOR** (see below) — Dawn Steadiness is also a "Quiet"-by-design family (no toast
  intended); the Orthodox retry didn't fire because the MCM Debug page was crashing.

### MCM overflow — diagnosed (audit done); premise flipped
- The in-game `Array index 109-127 out of range` is **column imbalance**, NOT too-many-options.
  SkyUI 2-col layout: left=even buffer indices, right=odd; the Flash panel crashes when a column
  exceeds ~54 rows (index ~108). **Culprit: page "Debug: Daedric & Curse"** — 26 rows left / **56 right**
  → index 111. The 1.5.0e Sanguine-consent block tipped it.
- **Nothing is stale/dead.** All 278 options are LIVE and already call the decomposed 2.0 API
  (`LedgerRuntime.*`/`FavorRuntime.*`) — the extraction left no broken cross-module calls. Only real
  dead code: **5 unreachable `RunPatternAction` arms (IDs 38-42)**. "Experience Mode" control is
  live-but-renamed ("Current path" on Settings). **Latent 2nd crash:** the Status page deity roster
  will overflow on its own at ~54 deities.
- Owner chose **"by module"** reorg for the rebuild (Ledger / Origin / Daedric / Pacing / Status pages,
  each column-balanced).

### ORIGIN correction (committed this session, 40aea3a7)
- The 664-fn `PDV_OriginRuntimeBase` monolith is **STAGE 1 only**. Intended shape = base + **10 race
  adapters** (polymorphic by birth race, no switchboard). ORIGIN spec corrected + `PDV_2_0_ORIGIN_AdapterSplit_Plan.md`
  added — the adapter split is design-heavy (interface collapse), do it before wiring.

### SUPERVISED QUEUE for the new session (priority order)
1. **MCM quick unblock** (~15 min): rebalance the Daedric page columns (move ~11 rows left, zero
   deletions) + delete the 5 dead `RunPatternAction` arms (38-42) + page/cap the Status deity roster.
   Fixes the live crash + the latent one. Then redeploy to V3Dev so testing is reliable.
2. **MCM by-module rebuild** (the chosen project): reflow ~201 debug options into module pages,
   column-balanced. Own focused session.
3. **ORIGIN adapter split** (base + 10 race adapters) — `PDV_2_0_ORIGIN_AdapterSplit_Plan.md`. Design +
   refactor; precedes ORIGIN wiring.
4. **Provider seam** (gain-multipliers) — design the base virtual interface + provider verb together
   with the adapter split (`PDV_2_0_ProviderSeam_ExtractionSpec.md`).
5. **ORIGIN ESP wiring** — per-adapter host QUSTs + race-selection fill (lighter than LEDGER: no
   property fills until the property-consolidation pass).
6. **Cleanup debt:** strip the ~34 stale moved-property FILLS off the manager QUST (they cause 198
   `Property … cannot be initialized` warnings in the Papyrus log — harmless but noisy); ORIGIN
   property-consolidation pass; manifest reconciliation (RegionMap/ReleasePayload).
7. **Deferred design decision:** FAVOR activation model — should a new favor **replace** (recommended)
   or **queue** rather than be suppressed while one is active? Owner deferred; ~5-line change if "replace".

### Key state facts for resuming
- V3Dev deployment = the LEDGER branch (piety core runs through the wired ledger). ORIGIN is NOT
  deployed to V3Dev (branch only, module inert).
- Branch chain unchanged (all unpushed): v3-big-update -> v3-ledger-extraction -> v3-origin-extraction;
  v3-provider-seam-spec parallel.
- To exercise the FAVOR toast before the MCM fix: trigger a "Noted" family (e.g. Orthodox) after
  **Clear active favor**, and close the MCM — but the MCM Debug page currently crashes, so fix MCM first.

---

## UPDATE — 2026-08-19 session 3 (queue item 1 SHIPPED: MCM quick unblock live on V3Dev)

### What shipped
- **Daedric page rebalanced**: the Neglect & decay block (11 rows) moved right→left → **37 left /
  45 right** (was 26/56; the crash was right-column row 56 → buffer index 111). Zero options deleted.
- **5 dead `RunPatternAction` arms (IDs 38-42) deleted** — a fresh call-site sweep re-confirmed no
  caller passes them; the live neglect/decay buttons dispatch through their own `_oid` handlers.
- **Status page roster capped** at 48 rendered rows + a "... and N more | Book of Days has the full
  roster" tail row. Kills the latent ~54-deity overflow; nothing is hidden at the current roster size.
- Column-budget constraint comments (~54 rows/column, index ~108) left in `BuildDaedricPage` and
  `BuildStatusPage` so the next option-adder sees the ceiling.

### Where it landed (and why there)
- Committed on **feature/v3-ledger-extraction** `be572f0a` — the branch V3Dev reflects. ORIGIN's MCM
  is rewired to `Manager.OriginRuntime.*`, which is not wired live, so an ORIGIN-built MCM.pex would
  None-error on V3Dev; the deployable fix had to build from LEDGER state.
- **Merged forward into feature/v3-origin-extraction** (clean auto-merge; all 11 OriginRuntime rewire
  lines intact). Merged MCM compile-proven against the ORIGIN tree: 0/0.
- **Deployed to V3Dev**: source synced hash-verified, targeted compile 0/0, `PDV_MCM.pex e89e689e`
  (2026-08-19 10:17). Branch chain still fully unpushed.

### Unblocked / next
- MCM Debug page is usable again → the FAVOR visible-toast retry can run now: **Clear active favor** →
  trigger a "Noted" family (e.g. Orthodox) → close the MCM.
- Queue items 2-7 unchanged; next up is the MCM by-module rebuild (own focused session), then the
  ORIGIN adapter split before any ORIGIN wiring.

### Branch reconciliation — the chain is now current (merge `67f431d2`)

Audited every local and remote branch by ancestry against the chain tip. **Exactly one merge was
owed, and it is done:** `feature/v3-provider-seam-spec` -> `feature/v3-origin-extraction`, clean.
Because `9e1c3a65`'s parent IS the big-update tip `a51ac436`, that single merge carried all of
big-update's 4 commits too: the `pdv_substrate_pacing_audit.mjs` gate reconciliation `a653006a`,
3 docs, and **`PDV_2_0_ProviderSeam_ExtractionSpec.md`** — which queue item 4 depends on and which
until now existed on no branch the chain could see.

**Do NOT merge these two** (analysis done, don't redo it):
- `hotfix/1.5.0e-daedric-consent-kid` (2 commits) — the fix commits already came over fix-only at
  `252eb0ea`. What is left is the 1.5.0e **release stamp**: `da762400` sets
  `PDV_BUILD_VERSION = "1.5.0e"`, plus changelog and release proof. 1.5.x is the maintenance line;
  merging it corrupts the 2.0.0 version identity. Checked for stranded content — none: the 1.5.0d
  "Large toast" UI is already in the chain (`styles.css` byte-identical, `is-large` in `app.js`).
- `claude/clever-goldstine-e63b0a` (1 commit) — superseded AND regressive. Its LF/CRLF hashing fix
  is already solved in the chain via `hashText` from `tools/lib/pdv_file_compare.mjs`
  (`readTextNormalised`), and merging it would strip `assertKnownFlags`, regressing the CLI
  flag-contract gate. Recommend deleting the branch.

`main` and all five `codex/v3-*` QR branches are fully contained already. Correction to the note
above: `feature/v3-big-update` **is pushed** and identical to `origin/feature/v3-big-update`; only
ledger / origin-extraction / seam-spec are local-only.

### NEW WORK ITEM — the substrate-pacing gate is blind after the extraction

`tools/pdv_substrate_pacing_audit.mjs` on the chain: **exit 1, 28 FAILs**. On
`feature/v3-big-update`: **exit 0, 0 FAILs**. The merge above did **not** improve it — re-run after
merging is still 28 FAILs; only the wording of `source.argonian-maintenance-clock` changed. (I had
predicted 28->27; that was wrong, and the reason is the point below.)

Root cause, proven not inferred: the audit pins `MANAGER_PATH = PDV__ManagerQuest.psc` (line 28) and
has no resolver, but the extractions moved the needled functions out. `IsArgonianHistNeglected` and
`TryArgonianBedOfChoiceSleep` now live in `PDV_OriginRuntimeBase.psc`; `HasHistMaintenance` and
`GetLastHistMaintenanceDevotionalDay` return **0 hits in the manager, 2 in ORB**. So
`bodyFor(managerSource, ...)` yields an empty string and every positive needle in the AND collapses.

**This is tool blindness, not a code regression** — ORIGIN is still inert and nothing is broken at
runtime. Do not "fix" source to satisfy it. The fix is the resolver treatment `pdv_verify.mjs`
already got (`3c7d459f`, `e3a870fa`): resolve a function body across the manager *and* the extracted
modules. Checked for the nastier variant — vacuous PASSes, where a negated needle against an empty
body passes for the wrong reason — and found none: every affected check ANDs at least one positive
needle, so the blindness shows up honestly as red. Every future extraction re-breaks any gate that
still pins a fixed source path, so this is worth fixing once, properly.

### FAVOR toast — no wiring change was made, and none was indicated
`be572f0a` touched one file and three functions (`BuildStatusPage`, `BuildDaedricPage`,
`RunPatternAction`); filtering its diff for `toast|favor|notif|prisma|message` returns zero lines.
The toast was **unblocked, not fixed**. Source reading confirms session 2's read independently:
`GetFavorSurfacingLabel` hard-codes `FAVOR_FAMILY_ALTMER_DAWN_STEADINESS` as **"Quiet"**, and
`SendContextualFavorToast` returns before `SendPrismaEventToast` on Quiet — so Dawn Steadiness
emitting no toast is correct, and no MCM fix could have changed it. **Orthodox costly enforcement**
is not in the Quiet list, classifies "Noted", and does call `SendPrismaEventToast` — that is the
retry that proves the path. Also note `TryApplyContextualFavor` skips the toast entirely when
`Manager.IsP2BookNoticeReason(reason)`, so don't drive the retry through a book-notice reason.
Status: wiring reads correct **on source inspection**; runtime remains UNPROVEN.

---

## UPDATE -- 2026-08-19 session 4: WORKPLAN AGREED, LANE A COMPLETE

Full workplan (lanes, waves, decisions) is in the session plan; decisions D1-D10 are summarised
below because they change how the remaining modules get built.

### Decisions locked (owner-approved)
- **D1 `PDV_OriginRuntimeBase` owns the gain provider**, NOT `PDV_Origin`. `PDV_Origin.psc` is a
  519-line one-shot bootstrap quest (detect race, write the origin global, seed 3 ledgers) -- the
  seam spec's Section 3 targets it literally and is wrong. Two of the four multipliers
  (`GetOrcLifeModeGainMultiplier`, `GetImperialCurseGainMultiplier`) are hard race gates that
  already call into `OriginRuntime`, so adapters delete the gate entirely. Because
  `PDV_GainModifierProvider extends Quest`, the base stays IS-A Quest and can still host. Only one
  adapter is instantiated per playthrough, so `Providers[]` holds one ORIGIN entry either way.
  **Correct the seam spec before building from it**: wrong provider script, missing decay site, and
  line citations (:15601, :13256) that cannot resolve against a 12,135-line manager.
- **D2 Decay routes through `Providers[]` too.** THREE consumer sites exist, the spec covers two:
  award (`RunGainPipeline`, PDV_DevotionLedger.psc:3253), dawn (`ProcessDawn` :2027-2033) and
  **decay (:2287)**. Add a decay phase so one scalar has one source.
- **D3 Split the stigma hybrid**: Breton Hidden Art branch -> Breton adapter (carry
  `IsBretonHiddenArtDaedricOfferDeity` with it); Hircine branch stays in DAEDRIC.
  **Dunmer needs NO work** -- Good Daedra worship is exempted structurally, not by branch: Azura /
  Boethiah / Mephala exist as both `PDV_DaedricPath_*` (stigma-bearing) and `PDV_Deity_*`
  (Reclamation patron), and the cast in `ApplyQuestReactionStigma` (:1805) means a Reclamation never
  reaches the stigma path. Khajiit/Azurah is clean the same way. Breton is the ONLY leak.
- **D4** MCM: debug pages only (State/Daedric/Pacing), after the adapter split. **D5** gate resolver
  across all blind gates. **D6** DAEDRIC starts now (the seam needs it); PRISMA/RECOGNITION follow
  the ORIGIN interface. **D7** ORIGIN: wire light first, consolidate the 557 properties after.
  **D8** PRISMA gets a presentation hook designed BEFORE extraction -- it carries 27 race tests
  across 115 fns including 8 full ten-race switches (DAEDRIC has 1, RECOGNITION 4); PRISMA is the
  real race-leak cost centre. **D9** FAVOR: a new favor REPLACES the active one (~5 lines, open).
  **D10** supervision: mechanical work unattended, design/ESP work supervised.

### LANE A COMPLETE (commit afe23e9b)
`familySourceText()` added to `tools/lib/pdv_symbol_home.mjs`: raw manager text first and verbatim,
then each extracted module with qualifiers stripped. Strictly additive, and it skips modules not yet
extracted, so it stays correct through DAEDRIC/PRISMA/RECOGNITION with no per-move patching.
Adopted across 24 audit gates plus the shared `tools/lib/pdv_matrix_vocab.mjs`.

Verdicts by exit code, never grepped:
- `pdv_substrate_pacing_audit`: exit 1 / 28 FAILs -> **exit 0 / 0** (reference case)
- 41-tool pinned suite: **24 red / 100 FAILs -> 12 red / 18 FAILs**
- self-tests green throughout (substrate 13, broad-pantheon 20, felt-trace 10, pacing-sim 5, dislike 5)

**`pdv_signal_floor_audit.mjs` was blind AND generative** -- it had been regenerating
`PDV_SignalFloorLedger.csv` with 35 fabricated UNDER-FLOOR rows (HEAD has 0). With the resolver it
regenerates byte-identical to HEAD. Any conclusion drawn from that ledger while it was blind is void.

A0 (RegionMap reconciliation) turned out NOT to be a prerequisite: the family list needs only
`targetScript` names, which are all correct. RegionMap function-list staleness (stale line numbers,
2 entries for deleted fns, the `GetCurseGainMultiplier` mis-tag) remains Lane D debt.

### Real findings surfaced by the repaired gates -- NOT fixed, for a human
- `LIKES_DISLIKES_VERSION` pinned at 20 in two gates; `PDV_DevotionLedger.psc:59` ships **23**.
- `AwardPietyFromLikesDislikes` signature drifted from what the dislike gate pins.
- `PDV_Bless_Breton_Tradition_T1` and `PDV_Bless_Redguard_AncestorSpine_T1` appear in no selector.
- Khajiit focus-lane quiet-emergence cue (`SurfaceTransition("emergence", focusDeity...)`) is absent.
- azura (4) and Syrabane (5) rows in `PDV_DeityLikesDislikes.csv` carry no disfavor domain.
- `RegisterQuestReactionMatrixFile` no longer exists; a coverage gate still pins it.
- `PDV_FeltEffectRegistry.json` regenerates with a large diff vs HEAD -- worth its own look.

### Operational note
**This environment's bash heredocs silently eat one backslash level.** Regex literals written
through a heredoc arrive corrupted and the failure is silent. Build backslashes with
`String.fromCharCode(92)` or use a dedicated edit tool, and always read the line back.

Never commit the regenerated reports (felt registry, felt trace, pacing sim, signal floor, quest
cross-gen) -- running the gates rewrites them; revert before staging.

### Next
Wave 1 remainder: B1 base virtual interface design (supervised -- gates B2), DAEDRIC extraction,
D-2/D-3 debt. The 2.0 rebuild artifact was refreshed this session (same URL).

---

## UPDATE -- 2026-08-19 session 5: WAVE 1 COMPLETE

| Item | Commit | State |
|---|---|---|
| Lane A -- gate resolver across the audit suite | `afe23e9b` | done |
| B1 -- ORIGIN adapter interface ADR | `311796d2` | **done, AWAITING OWNER REVIEW** |
| Lane D -- release manifest reconciliation | `60f8633f` | done |
| Lane D -- FAVOR supersede (D9) | `c9a5e7df` | done |
| Lane C -- DAEDRIC extraction | `3d77709b` | done, module INERT |

### B1 -- the interface is designed but NOT yet owner-reviewed
`references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md`. Measured, not estimated:
**341 distinct `OriginRuntime` verbs / 707 call sites; 288 verbs / 478 calls are race-specific.**
That kills Option B (it would need ~288 virtual stubs). Option A lands as **18 virtuals**.

The collapse is justified by data: the neglect predicate exists on all ten races under ten
different names; so does the primary state label. `GetSurveyText` on 9, `ApplyCurseHandlers` on 10.
The 91 `Handle*` verbs deliberately do NOT align by name -> one keyed `HandleContextualSignal`,
which alone removes 94 named calls from `PDV_EventBus`.

**Key de-risking:** each adapter override DELEGATES to the existing named function, so all ~664
moved bodies still reconstruct against `origin_golden.json`. Parity survives the split; behavior
review narrows to the dispatch tables plus remapped call sites.

**Honest cost recorded in the ADR:** `GetPlayerOriginRaceIndex` stays at 101 calls and external
race-index branching is NOT removed by this pass. Do not read the ADR as "switchboards gone".

Proposes a durable gate: no `OriginRuntime.<RaceName>` call may survive outside the adapters.

### DAEDRIC (`3d77709b`)
47 fns moved; **manager 444 -> 397 EndFunction blocks, exactly 47 removed** -- the arithmetic
closes, so nothing was lost or duplicated. Parity 1643/1644 byte-for-byte. The single deviation is
necessary, not sloppy: `_dawnHadActivity = True` -> `Manager.SetDawnHadActivity(True)`, verified a
one-line pass-through (Papyrus cannot reach another script's private vars). Compile 0/0 across 4
scripts, substrate gate exit 0, ASCII clean. **Module INERT until supervised ESP wiring.**

Two consequences to carry:
- Per D3 `GetDaedricStigmaGainMultiplier` moved WHOLE; its Breton branch waits for the Breton adapter.
- LEDGER's `RunGainPipeline` now reaches `Manager.DaedricRuntime.GetDaedricStigmaGainMultiplier`.
  The interim reach-back debt MOVED rather than went away; fold it into the `Providers[]` work.

### PROCESS FAILURE -- read this before the next fan-out
Lanes C and D ran concurrently **in the same worktree**, against the plan's own instruction to use
worktree isolation. Lane C's cleanup reverted Lane D's FAVOR edit; `git status` showed the file
modified, then it was silently clean again with the original suppression intact. It was caught only
because the diff was checked rather than the agent's report believed.

**Rules going in:** one worktree per concurrent lane that mutates source; commit each lane's work
as soon as it verifies (a commit survives a stray `git checkout --`); and verify every agent claim
against the tree before reporting it.

### NEXT -- Wave 2
1. **Owner: review the B1 ADR** before B2 builds 10 adapters on it. This is the gate.
2. B2 adapter fan-out: 5 agents by tranche pair (t1 Altmer/Bosmer, t2 Khajiit/Argonian,
   t3 Breton/Redguard, t4 Nord/Dunmer, t5 Orc/Imperial), **each in its own worktree**.
3. Supervised: DAEDRIC ESP wiring + GATE 0.5 (needs a fresh save).
4. Artifact refresh checkpoint 1 (already done this session; refresh again after DAEDRIC wiring).

---

## UPDATE -- 2026-08-19 session 6: DAEDRIC ESP HOST WIRED; B2 adapters built

### DAEDRIC ESP wiring -- DONE and verified (owner-authorised in-place write)
- Host quest created: **`071793:Devotion.esp` = PDV_DaedricRuntime**, `Flags = StartGameEnabled`,
  VMAD script `PDV_DaedricRuntime` (Local), one property `Manager -> 00C325:Devotion.esp`.
  ANAM auto-set to 0 (CK parity for an alias-less quest).
- Manager forward-ref filled: `PDV__ManagerQuest` VMAD properties **510 -> 511**, new `[510] =
  DaedricRuntime -> 071793`.
- **SEQ regenerated: 44 -> 45 start-game-enabled quests** (176 -> 180 bytes). houseCARL wrote it
  into a fresh `houseCARL - houseCARL_SEQ_002` folder, which is NOT in modlist.txt and is inert;
  the live copy was deployed over `Devotion-V3Dev/SEQ/Devotion.seq` (old one backed up), matching
  how the working SEQ has always been carried in the mod's own folder.
- **Verification:** `check_errors` on Devotion.esp = 0 dangling / 0 missing masters / 0 unscannable.
  Masters `Skyrim.esm, Dawnguard.esm, HearthFires.esm, Dragonborn.esm` -- game master first, order
  correct. ESP size moved MONOTONICALLY UP across both writes (657928 -> 658072 -> 658098), and
  the FIRST record was re-read after the SECOND write and is intact -- so no silent revert.
- Backups: `Devotion.esp.pre-daedric-backup`, `SEQ/Devotion.seq.pre-daedric-backup`.

### GATE 0.5 for DAEDRIC is BLOCKED, and the reason is sequencing
The deployed V3Dev build is **LEDGER-era**: `Devotion-V3Dev/Scripts/PDV__ManagerQuest.pex`
(2026-08-18 19:19) contains **zero** `OriginRuntime` references, and `PDV_DaedricRuntime.pex` is
not deployed at all.

This branch's manager depends on `OriginRuntime`, so deploying DAEDRIC's scripts would drag the
ORIGIN extraction in with it -- and ORIGIN has no host quest, so every `Manager.OriginRuntime.*`
call would hit None. Wiring ORIGIN now is also wrong: `PDV_2_0_ORIGIN_AdapterSplit_Plan.md` s7 is
explicit that ORIGIN wiring must wait so **the monolith shape is never wired**.

So the correct order is: finish the adapter split -> wire ORIGIN -> deploy -> run GATE 0.5 for
ORIGIN and DAEDRIC together. The DAEDRIC ESP host is authored and waiting; nothing about it needs
redoing.

**Cosmetic consequence meanwhile:** a V3Dev run will log a bind failure for quest 071793 (script
not deployed) and one "property cannot be initialized" warning for the manager's new
DaedricRuntime property -- the same class as the ~198 stale-fill warnings already in the log.
Both vanish on deployment. If V3Dev needs to be pristine for testing before then, restore
`Devotion.esp.pre-daedric-backup` and `SEQ/Devotion.seq.pre-daedric-backup`.

### B2 -- all 10 adapters built (606 functions), NOT yet reconciled
Five isolated worktrees, five branches, each compiling 0/0:

| tranche | branch | races | fns | script vars moved |
|---|---|---|---|---|
| t1 | `claude/v3-adapters-t1` | Altmer 85 / Bosmer 79 | 164 | 3 |
| t2 | `claude/v3-adapters-t2` | Khajiit 88 / Argonian 46 | 134 | 9 |
| t3 | `claude/v3-adapters-t3` | Breton 68 / Redguard 59 | 127 | 0 |
| t4 | `claude/v3-adapters-t4` | Nord 47 / Dunmer 38 | 85 | 5 |
| t5 | `claude/v3-adapters-t5` | Orc 62 / Imperial 34 | 96 | 0 |

**Not one shared script variable across the whole fan-out** -- no base accessor pairs needed.
Adapters never touched the base, so the five branches merge without conflict.

### NEXT -- B3 central reconciliation (the remaining ORIGIN work)
1. Merge the five adapter branches.
2. Bring all 10 adapters onto the **corrected 21-virtual** signatures (they were built against the
   first, defective cut -- see the ADR's "Corrections after the pilot").
3. Re-route the ~25 base->lane calls through virtuals BEFORE deleting anything.
4. Delete the lane originals from `PDV_OriginRuntimeBase`, verifying with the same
   function-count arithmetic that proved DAEDRIC (manager 444 -> 397 = exactly 47).
5. Then B4 provider seam, B5 ORIGIN wiring, and GATE 0.5 for ORIGIN + DAEDRIC together.
