# Session handoff -- 2026-08-07 (hygiene pass, channel refactor capture, calian)

## TL;DR

Six commits on `codex/khajiit-lunar-champion-rebalance`, **ahead 6, not pushed**. All gates green by
exit code: `pdv_verify` 0 FAIL / 4075 PASS, `pdv_signal_e2e_gate`, `pdv_ascii_guard`,
`pdv_prisma_ui_audit`, `pdv_substrate_pacing_audit`, `pdv_housecarl_p2_readback --check-formlists`.

| Commit | What |
|---|---|
| `4928c634` | Calian rotating practice lines (20-entry pool) + Prisma toast parity |
| `9df803ea` | Hygiene pass: harvester, perf review, verdict doc, STANDING RULE |
| `e03062a7` | Moved the quest-matrix `../` guard onto the channel-folder seam (unblocked verify) |
| `b1a5d149` | Stopped the sweep proposing deletion of public compat seams |
| `eab79c1c` | **Captured the channel refactor into git** -- 243 lines existed only in the MO2 tree |

Earlier same day: `16a7c218` (Khajiit runbook fresh-save precondition), `762cc5b6`, `6f5723cb`,
`c1302197`, `eae92c52` (calian records, mesh, lore dive, test packet).

## Do these first

1. **Push.** Six commits are local only. The channel refactor was one folder deletion from gone
   until `eab79c1c`; it is now in git but not on the remote.
2. **Decide the uncommitted Khajiit-lane files** (list below). They are not mine and I have not
   touched them all session.
3. **`references/authoring/PDV_QuestReactionMatrix_Tranche12_KhajiitFiveWealth.csv` was untracked**
   earlier today. If that tranche is meant to be live it needs committing AND regenerating into
   source -- a quest-matrix CSV is inert until the codegen runs.

Uncommitted, not mine: `race-sheets/PDV_RaceDesign_Khajiit.md`, four `*RewardRecords.spec.json`
(Altmer/Breton/Imperial/Nord), `PDV_PreBetaRaceGateLedger.md`, `PDV_QuestReactionMatrix_Full.csv`,
`PDV_SubstratePacingContracts.json`, `tools/pdv_felt_registry_gen.mjs`,
`tools/pdv_quest_tranche_merge.mjs`, `tools/pdv_reward_runtime_order_lint.mjs`, plus two untracked
ARR25 content-sweep docs.

## The standing rule (new, `PDV_STANDARDS.md` 6.7b)

After any multi-commit coding cluster: perf review of the CHANGED functions
(`housecarl:papyrus-optimization`), dead-code and orphaned-property sweep
(`tools/pdv_hygiene_harvest.mjs`), retired-scaffolding verdicts. **Report-only** -- removals are
their own packet. Memory: `post-coding-hygiene-checklist`.

Two rules decide whether the pass is worth anything, both learned the hard way today:
**read the source the compiler reads**, and **a candidate is not a finding**.

## Open work, in the order I would take it

### 1. Wire-or-retire rulings (blocks the removal packet)

Five things are documented as working and have no live call path. **Do not "fix" these by updating
the doc** -- that converts a defect into a documented non-feature. Decide wire or retire, then the
doc follows the ruling.

| Item | Evidence |
|---|---|
| `..._ChampionEntry` MESGs | `AGENTS.md:1560` already records the offer as broken for **all 16 Princes** -- never bound to path-quest VMAD props, reads `None` at runtime |
| `PDV_Msg_Nord_CurseState_WerewolfCured` | its three siblings are wired via `ShowNordMessage`; the cure branch has no call |
| `AwardDunmerAncestorSpinePulse` | `PDV_PrismaParityRegistry.csv:65` and `PDV_RunSheet_Dunmer_V1.md:184` say it fires the Ledger driver; zero call sites. `pdv_verify` checks only that the signature exists |
| `RefreshOpenBookOfDays` | three gates validate it, one forbids `AppendBookOfDaysEntry` calling it, nothing invokes it |
| 21 `PDV_Msg_*_OfferResponse_*` | verified zero source references; live path uses `BuildCommitmentOffer*ToastLine` instead |

The OfferResponse set is the one with a genuine fork: either the built-line rework was intended (the
21 properties, their VMAD bindings and records are leftovers) or it was a regression (thin lines
replaced authored copy). **Two docs misdescribe the mod either way** --
`PDV_FinalPolishLook_Ledger.md:98` marks FP-020 done-on-live, and
`PDV_FormalOfferWriting_Copy.md` carries copy-reviewed text for every mirror.

### 2. Finish the adjudication

Covered: 44/44 properties, 29/29 scaffolding markers, 42/84 functions. **Not covered: 42 functions,
18 read-never-written StorageUtil keys, 5 unreferenced tools.** Re-run
`PDV_SOURCE_DIR=<live> node tools/pdv_hygiene_harvest.mjs` and feed the gap to a Sonnet subagent
with the guardrails from 6.7b.

Everything in the verdict doc's agent section is **hypothesis, not evidence** -- each
`LIKELY-REMOVABLE` still needs main-loop verification. Two agent runs disagreed on several rows and
the more thorough read won both times.

The 243 write-never-read StorageUtil keys were deliberately excluded: that set is mostly one-way
stamps and one-shot flags, so "is this read?" is the wrong question to ask of it.

### 3. The removal packet (small, ready)

One CONFIRMED-REMOVABLE item, and it is mine: `GetAltmerPracticeLine` and the `practice_focus` arm
of `GetAltmerHeritageSourceLine` are unreachable -- `AppendAltmerHeritageVoice` intercepts first.
Harmless today but a second draw site from the practice-line pool with its own `LastId` write, which
would reintroduce the toast/Book divergence the single-pick design prevents. Recipe is in the
verdict doc; re-run `pdv_prisma_ui_audit` after, its assertions touch that function.

### 4. Testing (needs a played save, blocks P17)

`references/authoring/PDV_TestPacket_P11_Ambient_And_P17_Pacing_2026-08-06.md` -- Part A (calian,
five minutes, any Altmer save) first, because it exercises the same VMAD binding path everything
else depends on. **Fresh save required**: 14 `Message` properties bake at first init; on an older
save they read `None` and degrade to a Prisma toast.

Khajiit has its own: `PDV_KhajiitLunarChampionRebalance_InGameRunbook_2026-08-06.md`, now with a
fresh-save precondition of its own (its focus-message path has NO fallback -- an unbound property
shows nothing at all, which reads as a broken feature).

P17 cadence sizing is the last Altmer packet and cannot be tuned without that save.

### 5. Optional perf follow-up

`references/authoring/PDV_AltmerCalianPapyrusOptimization_2026-08-07.md`. Nothing urgent. The one
worth doing eventually: `IsAltmerPracticeLineJsonValid` re-validates the whole 20-entry pool on
every pick (~65 JsonUtil calls), held at amber only because the trigger is once-per-devotional-day.
**The Khajiit moon picker has the identical shape** -- fix both or neither. Confirm
`JsonUtil.Load` caching semantics via `papyrus-reference` before sizing it; I did not assert them.

### 6. Release obligation, easy to forget

pixelartpeach's calian assets ship under a permission that **requires a credit with a direct link in
the mod description** -- the Nexus page, not just `mod-data/CREDITS.md`. Must be on the page before
any public build containing them.

## Traps this session paid for

1. **houseCARL's instance is global, sticky, and silent.** It was on ARR 2.5, serving a four-day-old
   `Devotion.esp`. That produced a 41-surface RED signal gate and a 39-of-41 readback -- both false.
   Switching to Anvil made both green. **It cost me twice**: I also called the channel seam "inert"
   after checking only Anvil, when ARR 2.5 carries 39 channel files. Confirm the instance before any
   read that becomes a claim. It is currently **Anvil / Devotion Dev**.
2. **`live-source/` is a mirror and goes stale.** It was up to seven weeks behind on 19 files while
   work happened in the MO2 tree. My first hygiene harvest described a codebase that did not exist.
   `pdv_hygiene_harvest.mjs` now takes `PDV_SOURCE_DIR` and prints which tree it read.
3. **Finished work outside git is a single point of failure.** The refactor sat only in the MO2 tree
   for two hours, and the regenerated core matrix was in no commit at all.
4. **Gates that pin an implementation die with it.** Twice today: the header check pinned a constant
   the refactor removed, and my own Prisma assertion pinned an exact player-facing sentence that a
   copy pass legitimately changed. Assert the invariant, not the spelling.
5. **A candidate is not a finding, and neither is a delegated verdict.** The guardrails caught
   deletions that would have broken machine-enforced Prisma scaffolding, four reserved-ledger
   handlers, and `TempleBlessingScript` properties whose own comment explains why they must stay.
6. **`--check-plugin` exists now.** `pdv_package_release.mjs` gates plugin headers: patches must be
   ESL-flagged, `Devotion.esp` must not be. All 7 patches pass. Extension never matters -- the flag
   does; renaming to `.esl` would hoist a patch above the mods it patches.
