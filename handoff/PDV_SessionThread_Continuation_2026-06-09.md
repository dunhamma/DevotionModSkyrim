# PDV Session Thread Continuation - Slice A Review (2026-06-09)

Captures the live state of the working session so it can be resumed locally
(or in a fresh Claude Code session). Source session: `session_01TotBATGCawkjEckdKM9ABA`.
Branch: `claude/available-work-review-n7iafz`. PR: #3 (-> `main`).

## What this thread did
Picked up "meaningful work that is NOT blocked on in-game smoke or the Windows
toolchain" and delivered four review-ready slices (see
`handoff/PDV_UnblockedSlices_Handoff_2026-06-09.md` for the full index):

- **B - Matrix gaps** (`874070d`): Tranche4 cells for Y'ffre/Z'en/Khenarthi. DONE.
- **D - Matrix tooling** (`f5dfe3b`): `pdv_quest_matrix_selftest.mjs` + `--stdout`. DONE.
- **C - Description clarity #16** (`b0d746d`): `pdv_reward_desc_audit.mjs` + review
  doc (107 ADD / 151 clear). DONE, awaiting wording approval.
- **A - Startup copy #18** (`5c9a38d`): rewrite of 10 blurbs + advisory.
  **IN REVIEW - see below. Not finalized.**

PR #3 is open and this session is subscribed to its activity. No CI exists in the
repo (zero Actions workflows), so nothing to fix there; waiting on review/merge.

## Slice A - live review state (resume here)

### Correction made mid-review (important)
The repo's only un-scratch `PDV__ManagerQuest.psc` is a Phase-18 snapshot that
predates `GetStartupCanonicalSummary`. The CURRENT strings DO exist in the repo,
in the scratch live-source copies:
- `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc`
- `scratch/phase2-live-source/PDV__ManagerQuest.psc`
`GetStartupCanonicalSummary` is at ~:6821 (p2-toast-panel-fix); current strings
quoted below. Live edit target on the box:
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`.

### How/when the text fires (confirmed from live source)
`Debug.MessageBox` at character startup, two modes (`STARTUP_MODE_*`):
- **INFO_ONLY** (birth-fixed: Nord, Imperial, Dunmer, Altmer, Khajiit, Argonian) ->
  `GetStartupInfoOnlyText` = `summary + "\n\n" + advisory`.
- **EXPLICIT_CHOICE** (Breton, Bosmer, Redguard, Orc) -> summary is FUNCTIONAL: it
  reads "You begin by choosing your X: A, B, C" and leads into the choice buttons.
- Migration variant for existing saves: prefixes "PlayerDevotion keeps your
  existing startup state on this save."
Constraint: MessageBox has no scrollbar; info-only shows summary+advisory together,
so total length must stay compact or it clips in-game.

### The pending decision (drives all 10 - ASK USER FIRST)
**A) Lightly improve the existing terse strings** (keep MessageBox-sized; preserve
the "begin by choosing: A/B/C" structure for the 4 choice races) - RECOMMENDED.
vs
**B) Use the expanded literary rewrite** in
`race-sheets/PDV_StartupCanonicalSummary_Rewrite_2026-06-09.md` and accept a longer
box (verify no clipping during smoke).
User was leaning unstated; Claude recommended (A). #18's real complaint was the
Dunmer line + inconsistency, not that the strings were too short.

### CURRENT strings (the real baseline to edit)
- Nord: "You begin among the broad worship of the Nords. No single god claims you
  yet; a patron will reveal itself through how you live, hunt, and weather the storms."
- Imperial: "You begin in the broad embrace of the Nine Divines, even as the
  White-Gold Concordat presses down on the open worship of Talos."
- Dunmer: "You begin already grounded in ancestor and Reclamation. There is no path
  to choose here; the Dunmer carry their devotion in the blood."
- Altmer: "You begin beneath Auri-El, the founding light of the Altmer, and the
  lifelong pressure to keep your devotion pure and coherent."
- Khajiit: "You begin within the Lunar Lattice, the two moons your road and your
  guide. Your focus will emerge quietly, in how you walk and where you rest."
- Argonian: "You begin in the layered devotion of your people: the Hist that shaped
  you, the world's gods you may yet borrow, and the Void that waits beneath."
- Breton (CHOICE): "You begin by choosing your tradition: the Knight's Road of vow
  and mercy, the Hidden Art of forbidden power, or the Green Way of the old druids."
- Bosmer (CHOICE, 4 paths): "You begin by choosing your path: the Old Contract's
  hard covenant, the Living Story of your people, the Exchange of debt and redress,
  or the Bandit Road's trickster survival."
- Redguard (CHOICE): "You begin by choosing your sect: the orthodox Crown, the
  adaptive Forebear, or the burdened Ash'abah who tend the unquiet dead."
- Orc (CHOICE): "You begin by choosing your life-mode: the full Stronghold code of
  Malacath, dignity kept in the City, or honor carried into Legion and exile."
- STARTUP_ADVISORY_TEXT (current): "This is only where your road begins. What you
  revere, neglect, or defy from here will shape the devotion that grows."

### Open per-race / cross-cutting calls still to settle
1. Curse-state parity: draft mentions curse line only for Altmer + Dunmer. Drop for
   parity, or add a one-clause curse note to all ten?
2. Imperial Talos/Concordat clause: keep / soften / cut?
3. Length & voice: terse (current) vs ~3-sentence literary (draft).
4. Nord: name Talos outright vs "the Eight and the hidden Ninth"?
We were going RACE BY RACE, starting at Nord, when the resume point was reached.

## To resume locally
1. `git fetch origin && git switch claude/available-work-review-n7iafz`
2. Open this file + `race-sheets/PDV_StartupCanonicalSummary_Rewrite_2026-06-09.md`.
3. Settle the A-vs-B fork, then walk the 10 races; edit the rewrite doc; keep it
   ASCII-safe; re-commit.
4. Box-side: paste approved strings into `GetStartupCanonicalSummary` (~:6821) and
   `STARTUP_ADVISORY_TEXT` (~:353) in the MO2 `PDV__ManagerQuest.psc`, compile.
