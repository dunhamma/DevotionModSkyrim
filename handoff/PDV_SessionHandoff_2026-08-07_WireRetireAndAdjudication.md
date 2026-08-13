# Session handoff -- 2026-08-07 (wire-or-retire rulings, full adjudication, merged runbook)

Continues `PDV_SessionHandoff_2026-08-07_HygieneAndChannelRefactor.md`. Seven commits on
`codex/khajiit-lunar-champion-rebalance`, **pushed**.

| Commit | What |
|---|---|
| `d6759eab` | Wired two orphaned Nord messages, retired `GetAltmerPracticeLine`, cached pooled-line validation |
| `c34a9e8c` | Merged in-game runbook (Altmer + Khajiit + the two new Nord surfaces) |
| `39c78cc8` | Retired `RefreshOpenBookOfDays`, moved its three gates onto the invariant |
| `6d34c92e` | Adjudicated all 133 uncalled functions by name, plus the 18 keys and 5 tools |
| `67e05b98` | Resolved the OfferResponse fork: supersession, not regression |
| `29f5243d` | Wired the Dunmer ancestral-layer Ledger driver, patron-independent |

Gates green by exit code throughout: `pdv_verify`, `pdv_prisma_ui_audit`, `pdv_ascii_guard`,
`pdv_signal_e2e_gate`, `pdv_book_of_days_audit`, `pdv_substrate_pacing_audit`,
`pdv_housecarl_p2_readback --check-formlists`.

houseCARL instance for every readback this session: **Anvil / Devotion Dev**.

## Dunmer ancestral spine -- RULED AND WIRED (`29f5243d`)

`AwardDunmerAncestorSpinePulse` was a real gap, not redundancy. Signal `705` is declared on Azura,
handled in the manager's curated-signal dispatch, and the Orc (`2209`) and Redguard (`2406`)
equivalents fire -- Dunmer's had no producer.

The defect: a Dunmer praying at the portable urn got substrate progress
(`RecordPortableShrinePrayerScaled`) but a **Ledger driver only when a patron was ACTIVE and only on
the first prayer of the day**, because `AwardActiveDunmerReclamationMemorySignal` was the sole
curated signal on that path and carries both gates. A patronless Dunmer, or any repeat prayer,
recorded nothing -- the state `PDV_RunSheet_Dunmer_V1.md:184` calls "the key regression" and a FAIL.

**Owner ruling: the pulse feeds the ANCESTRAL layer, so it fires on the first prayer of the
devotional day regardless of patron.**

That also dissolves the apparent conflict with `PDV__ManagerQuest.psc:7876` ("the portable prayer
already supplied the one deity-piety pulse for this logical act"). That comment governs the **home
bonus** not stacking on top of the prayer. The two layers were always designed to answer separately:
layer 1 (ancestral) is curse-silenced, layer 2 (Reclamation) "still answers, so it routes
regardless". They are different lanes, not two pulses on one lane.

Implementation notes worth keeping:

- The anti-farm cap lives **on the pulse**, not the call site, so a future second call site cannot
  reintroduce farming. It reuses the `GetDevotionalDay() + 2` day-int encoding the Reclamation-memory
  pulse already uses, which handles the day-key zero-default trap the same way in both.
- The call sits **inside the `layerWeight > 0.0` guard** on purpose: vampirism silences the ancestral
  layer, so a silenced prayer must not record a driver either.
- Only `HandleDunmerPortableShrinePrayer` calls it. The other three
  `RecordPortableShrinePrayerScaled` sites (`reclamation_source`, `honorable_victory`,
  `good_daedra_altar`) are different acts, not prayers, and were deliberately left alone.

**PROVEN IN GAME 2026-08-08.** Papyrus log, patronless Dunmer:

- first prayer, `day=0` -> `AwardCuratedSignal: Azura signal 705 delta 1.000000` (705 is
  `SIGNAL_ANCESTOR_SPINE`), alongside the pre-existing twilight rite 704
- second prayer same day -> `Daily credit rejected: duplicate_event`, no 705, no 704
- after the 06:00 boundary, `day=1` -> 705 fires again

Steps 1, 3 and 4 of the packet pass: the driver fires, self-caps within the devotional day, and
returns after the boundary. Still unrun: the vampirism guard (expect complete silence -- no standing,
no driver) and the off-window case that would isolate the original gap (705 with no 704).

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

---

# Addendum -- 2026-08-08 session close

## Proven in game since this handoff was written

| Surface | Result |
|---|---|
| Nord werewolf cure | PASS |
| Nord/Kyne champion recognition | PASS (after the deferred-queue fix below) |
| Dunmer ancestral-layer Ledger driver | PASS -- signal 705, self-caps, returns after 06:00 |
| Khajiit long test | PASS (owner) |

## Defects live testing found, all introduced by this branch

1. **`Message.Show()` cannot display over an open MCM.** The Kyne recognition fired into an open
   menu, displayed nothing, **and set its one-shot key** -- burning the beat permanently while the
   record and its VMAD binding were both correct. Fixed by queueing and presenting from `OnUpdate`,
   stamping the key on PRESENT rather than on queue. `AGENTS.md` (2026-06-13) already documented this
   trap and it was re-broken the same day it was read. Memory:
   `message-show-cannot-fire-over-an-open-mcm`.
2. **A one-shot guard with no reset path** recreated the P10 "total silence on a re-climb" bug one
   surface lower. The Kyne key now clears on demotion alongside the tier notice.
3. **FOMOD entries spliced into the wrong install step** -- the anchor string occurs in both steps and
   a plain string replace takes the first. Caught only by simulating the install, not by XML
   validation.
4. **All-In-One left behind** -- would have shipped Authoria users none of the 29 new channels.

## Still open, unresolved

**The MCM `Evaluate commitment` button did not fire.** No `Commitment evaluate debug` trace appeared
though a level-1 trace from `Seed commitment signals` on the same page did, and the wiring
(`OnOptionSelect` -> `RunPatternAction(..., 12)` -> `DebugEvaluateCommitmentOffer`) reads correct.
The offer eventually arrived through the dawn path. Worth a look if it recurs.

**`ShowFormalCommitmentOffer` has the un-deferred `Message.Show()` problem too** --
`Int choice = offerMessage.Show()` with no menu-mode hold, so run from the MCM it returns 0 and
silently auto-accepts. The Daedric champion path got the deferred fix; this one never did.

## New scope docs opened

- `references/authoring/PDV_PatronOfferDeityNaming_Scope_2026-08-08.md` -- patron-commitment boxes
  must name their deity; plus a player-copy lint for that rule and for `--` in player-facing text
- Three owner-authored scope docs captured into git unmodified: JoJ compatibility, KID distribution,
  SPID recognition

## Packaging

The quest-mod patch hub is now a **pure per-mod patcher** -- one page, 46 tickable options, each
gated on its own mod's plugin, no Authoria lane and no combined plugin. This is **breaking for
existing hub users**: anyone who installed via All-In-One must re-run the installer. Save-safe (all
ESL-flagged, no FormID shifts), but it belongs in the release notes.

Deleting that lane also removed an active regression: its core payload had gone stale and would have
**downgraded** users (`ManagerQuest.pex` 909,685 vs 961,450 live; core matrix 614,651 vs 714,030).

## PR #34 relationship -- resolved, and it is not what it looks like

`claude/awesome-proskuriakova-8991c7` (PR #34) is titled "land the unpushed 1.0.4 work". **That work
is already on this branch.** Verified rather than assumed:

| Symbol #34 adds to the manager | live MO2 | this branch | main |
|---|---|---|---|
| `AppendQuestReactionSnapshotToken` | 46 | 46 | 0 |
| `MaybeEmitManagerOptimizationProfile` | 3 | 3 | 0 |
| `_optimizationTimerFires` | 5 | 5 | 0 |

This branch's `live-source` mirror is byte-identical to the live MO2 tree (28,219 lines, identical
once CRLF/LF is normalised), and the live tree is what shipped 1.0.4 -- so the mirror already carries
the optimization source. A `git merge-tree` of the two branches resolves the manager to exactly the
live file with **no duplicated function definitions**, and `PDV_PlayerEvents.psc` likewise.

So the feared failure -- #34 dragging an older manager over this session's work -- **does not
happen**. Git resolves it correctly. Recorded because the branch names and PR titles suggest
otherwise, and the next person will have the same worry.

**Taken from #34 (owner ruling: Claude and skill changes only), in `946bae95`:** the four dead skill
copies deleted, `.claude/settings.json` tracked, `Claude.md` renamed to `CLAUDE.md` and cut 101 lines
to 28, and the AGENTS.md file-map rows for the deleted skills dropped.

**NOT taken, still an open decision:** #34's AGENTS.md archive roll (367 deletions, the 425KB ->
165KB shrink). That is the **only** file where the two branches genuinely conflict -- all 25 other
shared files auto-merge cleanly. Whoever resolves it should know this branch added ~94 lines to the
Decisions Log head today, and #34 keeps that head while deleting older entries below it.

`CLAUDE.md` is now 28 lines and is strictly an entrypoint -- it carries no build status. Every Claude
session in this repo loads it, so that change takes effect immediately for the next session.
