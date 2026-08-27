# PDV UX handoff - 2026-08-26 - Book of Days uplift

**Status:** LIVING. Extends `PDV_UX_Handoff_2026-08-25.md` (still current for the
journey-board/atlas/Concordat thread). This file records the Book of Days session.
**Branch:** `fix/2.0-copy-uplift`, uncommitted. **Evidence bucket: static only** --
live V3Dev Papyrus + view source, compile exit codes, headless render of the view with
mocked payloads. **Nothing observed in game; runtime proof owed** (bars per race,
MCM-driven pass).

## Decisions locked this session (owner, 2026-08-26)

1. **Book of Days voice = Keeper** (chronicle-witness). Now a row in
   `race-sheets/PDV_ContentDestinationMatrix.md` section 5, with the no-restating-the-toast
   note. Player-first-person was considered and rejected: "I" is the gods' register
   project-wide (voice conformance 2026-06-14), and ~44/87 emit sites compose a deity name
   in subject position.
2. **Culture bar, every race, journal header**: bar + posture label, race-fixed points,
   independent of the deity instrument. Header-only for now.
3. **Crossing entries deferred** behind the substrate-tier-crossing ruling (open decision:
   beat, or is quiet the point). When it lands, the emits are Codex's (new triggers).
4. Orc/Redguard bars measure **dominant-commitment share** (largest life-mode/sect weight
   over total, 0-100). Concept shipped; band labels + pips wait on the owner (issue #109).

## What shipped (all in the LIVE V3Dev tree, mirrored to repo)

- `Scripts/Source/PDV_PrismaPresenter.psc`: `BuildJournalCultureJson(originRace)` +
  `ComputeDominantShare`; `BuildJournalPayloadJson` emits `"culture":{posture,value,max,
  pips[]}`. Compiled 0 err / 0 warn. `PDV_MCM` recompiled for the freshness gate.
- View (`PrismaUI/views/Devotion/`): `renderJournalCulture` in app.js; culture label +
  gauge markup in index.html under `.bod-standing`; small CSS block. Reuses `.bod-gauge`
  styling; hidden when culture is `{}`. Cache key now `pdv-d3470e06ea535ad5` in BOTH
  index.html query strings.
- Per-race scales: Nord/Imperial/Altmer/Dunmer/Khajiit/Argonian metric 0-75 pips 1/25/75
  (Dunmer journal previously showed tier urns, now the metric); Bosmer GreenPactCompliance
  0-100 pips 20/50/80; Breton practice count 0-85 pips 25/50 (kills the unbounded
  pins-at-100 display); Orc/Redguard share 0-100 no pips.
- Prose workbook: new sheet **Book of Days Inventory** -- 65 emit rows (87 call sites,
  base/adapter twins collapsed; 12 ECHO toast-restaters first) + 23 builder-internal
  strings + the tone->default-title map. Owner drafting column blank. Concordat sheet's
  five Book-of-Days CURRENT cells were verified already correct (an earlier this-session
  claim that column F was empty was a parser artifact -- retracted).
- Voice matrix row + `references/authoring/PDV_WordingRevisionBacklog.md` entries (the
  "You've chosen your road" contraction; the echo family). Issues: #109 opened, #107
  commented.

## Drift absorbed / caused / left

- **Mirror sync direction was deployed -> repo** for `PDV_PrismaPresenter.psc`,
  `PDV_MCM.psc`, `app.js`, `styles.css`, `index.html` (live was ahead; the compile gate
  demands parity). The repo mirror gained live-only work for those five files: presenter
  tier-milestone sender, MCM runbook page, app.js toast-trace.
- **One live-ward fix restored:** repo app.js had `showCancel !== false` guarding the
  choice cancel button; live lacked it; a blind live->repo copy briefly reverted it. Fixed
  in BOTH: live and repo now carry the guard. Drift is bidirectional -- always diff before
  mirroring.
- **Pre-existing audit reds, not regressions** (V3Dev env-override runs):
  `pdv_prisma_ui_audit` FAIL x2 (Breton Champion Survey pin; commitment tokens pinned to
  `PDV_DevotionLedger` that V3 moved) and `pdv_book_of_days_audit` FAIL x2 (manager
  `GetTierStandingLabel(TIER_CHAMPION)`; MCM `SendPrismaJournalPayload(True)`). All four
  predate this session's edits; the stale pins belong to whoever reconciles the audits
  with the V3 layout. My four gate items (view parity x2, cache key, MCM freshness) went
  red -> green.

## How to run the gates against V3Dev (defaults still point at 1.5)

- Compile: `PDV_COMPILE_SOURCE_ROOT`/`PDV_COMPILE_OUTPUT_ROOT` -> V3Dev Scripts paths.
- `pdv_prisma_ui_audit.mjs`: `PDV_DEVOTION_ROOT` -> V3Dev mod folder.
- `pdv_book_of_days_audit.mjs`: `PDV_AUDIT_LIVE_PRISMA` / `PDV_AUDIT_LIVE_SOURCE` /
  `PDV_AUDIT_COMPILED` -> V3Dev paths.

## Next session picks up

1. Owner: Orc/Redguard share verdict + band labels; keeper drafts in the inventory sheet.
2. The substrate-tier-crossing ruling; then Codex wires crossing entries.
3. The two stale-pin pairs in each audit (deliberate reconciliation, not silent edits).
4. Runtime pass: open the Book of Days per race, confirm the bar and posture label.

## Addendum (same day): gauge geometry sync

Owner feedback: the two header bars looked mismatched. View-only fix: both journal
gauges now share ONE normalized geometry (`journalGaugeFraction`/`journalGaugeNode` in
app.js) -- marker pips render evenly across the track regardless of scale, and the fill
interpolates within the current segment, so a 41/75 civic practice and a 47/85 piety
standing read as siblings. Payload contract unchanged; pip-less bars (Orc/Redguard)
stay proportional. Cache key now `pdv-1b6109a55f3adc33`; repo/live view parity re-synced;
both audits back to the same two pre-existing FAILs each.

## Addendum 2 (same day): runtime proof banked into V3 acceptance

Owner direction: bank the in-game journal testing with the V3 runtime acceptance
(currently up to Session B, Khajiit). Done:

- `PDV_2_0_RuntimeAcceptance.manifest.json` revision 1 -> 2, six new evidence slots:
  `nord_core.culture_bar`, `khajiit_origin.culture_bar`, `imperial_origin.culture_bar`,
  `altmer_regression.culture_bar`, `race_change.culture_bar_switch`,
  `presentation.gauge_sync`. Ledger shell re-synced via `--init` (144 -> 150 slots, all
  observations were empty, nothing invalidated).
- Runbook steps added per session, hooked to setup each session already performs:
  Session B uses the existing seed-lunar-25 step -- with segment geometry the fill must
  land exactly ON the second pip at 25/75; Session C proves Concordat moves alone do NOT
  move the civic bar; Session D proves the reward swap does not touch the heritage bar;
  Session E proves rebind re-labels/re-scales with no stale fill; cross-session
  `gauge_sync` checks shared pip geometry, no raw numerals, no "Spine", and that an empty
  culture payload hides the row.
- Session A already ran informally before the bar existed; its `culture_bar` slot is
  flagged in the runbook to be banked during the final regression instead.
- Record evidence with the usual intake, e.g.
  `node tools/pdv_v3_runtime_acceptance.mjs --record --case khajiit_origin --slot culture_bar --status pass --note '...'`.
