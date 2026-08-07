# Session handoff -- 2026-08-07 (wire-or-retire rulings, full adjudication, merged runbook)

Continues `PDV_SessionHandoff_2026-08-07_HygieneAndChannelRefactor.md`. Five commits on
`codex/khajiit-lunar-champion-rebalance`, **pushed**.

| Commit | What |
|---|---|
| `d6759eab` | Wired two orphaned Nord messages, retired `GetAltmerPracticeLine`, cached pooled-line validation |
| `c34a9e8c` | Merged in-game runbook (Altmer + Khajiit + the two new Nord surfaces) |
| `39c78cc8` | Retired `RefreshOpenBookOfDays`, moved its three gates onto the invariant |
| `6d34c92e` | Adjudicated all 133 uncalled functions by name, plus the 18 keys and 5 tools |
| `67e05b98` | Resolved the OfferResponse fork: supersession, not regression |

Gates green by exit code throughout: `pdv_verify`, `pdv_prisma_ui_audit`, `pdv_ascii_guard`,
`pdv_signal_e2e_gate`, `pdv_book_of_days_audit`, `pdv_substrate_pacing_audit`,
`pdv_housecarl_p2_readback --check-formlists`.

houseCARL instance for every readback this session: **Anvil / Devotion Dev**.

## The one thing blocking, and it needs the owner

**`AwardDunmerAncestorSpinePulse` is unresolved.** It is a real gap, not redundancy -- signal `705`
is declared on Azura, handled in the manager's curated-signal dispatch, and the Orc (`2209`) and
Redguard (`2406`) equivalents fire. Dunmer's has no producer.

The consequence: a Dunmer praying at the portable urn gets substrate progress
(`RecordPortableShrinePrayerScaled`) but a **Ledger driver only when a patron is ACTIVE and only on
the first prayer of the day**, because `AwardActiveDunmerReclamationMemorySignal` is the sole curated
signal on that path and carries both gates. A patronless Dunmer, or a second prayer that day, gets an
empty Ledger. `PDV_RunSheet_Dunmer_V1.md:184` calls exactly that state a FAIL and names
`AwardDunmerAncestorSpinePulse` as the fix. The fix was written and never called.

The complication: `HandleDunmerPortableShrinePrayer` at `PDV__ManagerQuest.psc:7876` says the prayer
"already supplied the one deity-piety pulse for this logical act". Curated signals carry piety, so
calling the spine pulse unconditionally adds a second piety gain to acts that already have one.

Three options were put to the owner; **the recommendation is the first**:

1. Call it only when neither the twilight signal nor the Reclamation-memory signal fired -- fills
   exactly the gap, never double-pulses, leaves working cases untouched. Use the existing
   `ConsumeDailyRepeatMultiplier` for decay.
2. Wire unconditionally, matching the Altmer shape. Simpler, but a real Dunmer pacing change.
3. Retire and correct the two docs -- but that strips a registered signal, which is its own gate
   failure class.

Nothing else is blocked on this.

## Rulings made, so they do not get re-litigated

- **`RefreshOpenBookOfDays`: RETIRED, not wired.** The prior handoff called it "an intended periodic
  refresh that was never wired into the tick loop". It is not. `PDV_MCM.psc` `OnKeyDown:1708-1719`
  already performs the identical reconciliation inline, at the only moment it is consumed. Wiring it
  to a tick would have added periodic cost to re-check state reconciled for free. Its three gates
  pinned the function NAME; they now assert the behaviour against `PDV_MCM.psc`.
- **OfferResponse mirrors: SUPERSEDED, retire recommended.** No authored copy was lost. Each authored
  sentence was split -- opening clause to the toast, state clause and cooldown consequence to the
  Book of Days line. Full per-race comparison in
  `references/authoring/PDV_OfferResponseMirrors_CopyVsBuiltLine_2026-08-07.md`. It is **18**
  properties across **six** races, not 21 across seven.
- **The Daedric-Prince `ChampionEntry` finding was a bad citation.** `AGENTS.md:1560` does not
  support "broken for all 16 Princes"; `AGENTS.md:1596` records the opposite (housecarl-verified
  correct, Boethiah `071270`; the real defect was the MCM `Message.Show()` gotcha, since fixed). The
  genuine orphan was `PDV_Msg_Nord_Kyne_ChampionEntry`, a different record collapsed into the same
  row. Corrected in the verdict doc.

## Open work, in the order I would take it

### 1. The in-game sitting (blocks P17, and now also today's wirings)

`references/authoring/PDV_MergedInGameRunbook_2026-08-07.md` sequences everything.

**It cannot be one save.** The two packets need different races and today's wirings need a third:
Nord (~10 min, do first -- it proves the VMAD binding path on the newest build), then Altmer
(P11 A-E + P17), then Khajiit. Fresh save is a hard precondition for all three; the three lanes
degrade differently on a stale save and the runbook tabulates which is which.

Two things in there will otherwise be reported as bugs: an MCM-forced curse transition surfaces as a
**Prisma toast, not the MessageBox** (`ShouldSuppressNordCurseModal` catches the `mcm_force_*`
reasons by design), and a tier seed only surfaces on an **up-crossing**, so Kyne must be reset below
Champion before seeding to 85+.

### 2. The removal packet (now sized, still not scheduled)

37 main-loop-verified `LIKELY-REMOVABLE` functions and 16 `SUPERSEDED` ones, listed by name in
`references/authoring/PDV_DeadCode_RetiredScaffolding_Verdicts_2026-08-07.md` under "Completion
pass". Two carry an explicit prior ruling that already says delete: `EvaluateQuestMetaFaucets` (and
its `tools/pdv_qr_direct_fanout.json:36-41` entry, which must go in the SAME commit) and
`GetStartupOptionDetailText`.

The dominant `SUPERSEDED` class is twelve unscaled `Record*` substrate wrappers stranded by their
`*Scaled` siblings -- a single coherent packet if you want an easy one.

### 3. Three defects this session surfaced but did not fix

- **`PDV.Khajiit.LunarSourceCount` is never incremented.** It is read at
  `PDV__ManagerQuest.psc:26241` to gate the line "A lunar source has been read and remembered", so
  that line can only ever see 0. Its sibling `LastLunarSourceTime`/`Reason` keys ARE written.
- **"Not yet" has no surface anywhere.** `NotYet` appears nowhere in the live tree outside its six
  property declarations -- no toast builder, no journal arm, no defer function. Accept and refuse
  each close with a beat; the middle option closes with silence.
- **No Khajiit focus button for Khenarthi or Azurah.** Only Baan Dar, Rajhin and Alkosh exist
  (`PDV_MCM.psc:2265-2267`). The Khajiit runbook needs both of the missing two, so they have to be
  reached by piety seeding.

### 4. Two docs that claim wiring the code contradicts

Both surfaced during adjudication and are doc bugs either way:
- `handoff/PrismaSubstrateInstruments_DesignDraft.md:75,125,175` claims
  `GetBretonWitchcraftExposureLabel` is "already wired into Survey". It has no caller;
  `GetBretonSurveyText` duplicates the thresholds inline.
- `references/authoring/PDV_VoiceConformance_RecordCopy.md:322` asserts the "live"
  `GetBretonCursePostureLabel` returns bare enum-ish phrases. It has no caller.

### 5. `AGENTS.md` was deliberately NOT updated

`Claude.md` rule 3 says not to touch it unless the owner asks, and Codex committed to the repo
concurrently this session (`e7832ec8`). What it needs when someone does update it:
the five commits above, the `RefreshOpenBookOfDays` and OfferResponse rulings, and a correction to
the `ChampionEntry` claim its own line 1560 is being cited for.

### 6. Still carried from the previous handoff

pixelartpeach's calian assets require **a credit with a direct link in the mod description** -- the
Nexus page itself, not just `mod-data/CREDITS.md`. Must be on the page before any public build
containing them. Owner action; an agent cannot post it.

## Traps this session paid for

1. **A delegated verdict is not a finding, and this session proved it three times.** Four Sonnet
   batches classified 133 functions; main-loop re-checking against `tools/*.mjs` flipped three rows
   from removable to LEDGER-PROTECTED (`GetNordAncestorSummary`, `GetImperialCivicLayerLabel`,
   `RegisterGenericEffectList`). All three would have deleted a signature a gate requires present.
2. **Word-boundary matching is mandatory when verifying call counts.** A substring grep makes
   `DebugSeedBosmer` look like it has five callers and `GetKhajiitLunarPostureLabel` three. Every hit
   is inside a longer name (`DebugSeedBosmerVariety`, `GetKhajiitLunarPostureLabelAt`) -- and in both
   cases the longer sibling is the live one. The same trap makes all twelve `Record*` wrappers look
   gate-protected when the hits are on their `*Scaled` siblings.
3. **A comment is not a call site.** `DebugSeedBretonDruidicFrayTest` carries a comment claiming MCM
   wiring; no such button exists. `RecordHeritageStanding` and friends self-forward to a Scaled
   sibling that took their callers.
4. **Recording counts instead of rows loses the work.** The prior pass's "42 of 84 functions" could
   not be acted on -- nothing said which 42, and its row-level verdicts existed only in agent output.
   That is why this pass wrote all 133 down by name.
5. **A prior finding's citation deserves the same scepticism as the finding.** The `ChampionEntry`
   row cited a line that says the opposite of what was claimed, inside the very document written to
   stop that failure mode.
6. **`pdv_matrix_runtime_preflight` FAILs on the ARR instance, not on code.** It checks that
   `Devotion - Authoria ARR Compatibility` is enabled in `D:\Wabbajack\modlists\ARR\profiles\R11 KoK`.
   That is an MO2 enablement condition only the MO2 UI can change, and it is unrelated to any script
   edit. It was not in the previous handoff's green list either.
7. **The compiler enforces the live-tree/mirror sync and will refuse.** `pdv_compile` fails with
   "Tracked/deployed source drift" until `live-source/` is synced from the MO2 tree. Copy first, then
   compile.
