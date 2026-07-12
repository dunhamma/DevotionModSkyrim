# PDV Living Progress Widgets — Session Handoff (2026-06-24)

## Why this exists
The session that built these `show_widget` charts got visually janky (too many
rendered widgets in one long thread). This handoff is self-contained: paste it
into a FRESH session and it can regenerate every chart identically, then keep
them living. Companion to memory [[living-beta-progress-charts]] (data model) and
`PDV_SpineParityWidget_Handoff_2026-06-24.md` (the spine tracker spec).

## How to use (fresh session)
1. Read this file.
2. Refresh data via the commands in the table below (don't hand-key generated
   numbers — re-run the tool/git and re-read).
3. Call `mcp__visualize__read_me` once (modules `["chart"]`) before the first
   `show_widget`, then render each widget with the embedded code, swapping in the
   refreshed data arrays.
4. Render ONE widget per turn if jank returns; they're independent.

## Shared conventions (all widgets)
- `show_widget`, transparent bg, CSS-variable themed. Canvas can't read CSS vars,
  so chart colors are hardcoded hex chosen to read in BOTH light/dark; detect dark
  with `matchMedia('(prefers-color-scheme: dark)')` and pick tick/grid colors.
- Chart.js 4.4.1 UMD + (where noted) `chartjs-plugin-annotation` 3.0.1, both from
  cdnjs. Register annotation in a `try/catch`.
- Palette: amber `#E5A23C` (commits/effort), teal `#1D9E75` (progress/done),
  blue `#378ADD`, coral `#D85A30`, red `#A32D2D`, purple `#7F77DD`, pink `#D4537E`,
  amber-dark `#BA7517`, gray `#888780`. Round all displayed numbers.
- Every `<canvas>` needs `role="img"` + descriptive `aria-label`; HTML widgets
  start with a visually-hidden `<h2 class="sr-only">` summary.

## Data sources & refresh commands
| Widget | Source | Refresh |
|---|---|---|
| build-arc history | git | `git log --pretty=format:"%ad" --date=short \| sort \| uniq -c` ; total `git rev-list --count HEAD` |
| progress snapshot | integrity harness | `node tools/pdv_integrity_harness.mjs` → read `PDV_IntegrityHarnessLedger.md` |
| build-debt burndown | floor + spine + minus | harness roll-up: floor UNDER-FLOOR count + spine targets + specced_minus count |
| projection-to-1.0 | estimate + ledgers | re-derive remaining-phase session estimates from harness state (soft numbers) |
| spine-parity tracker | spine score tool | `node tools/pdv_spine_stack_score.mjs` → read `PDV_SpineStackScoreLedger.csv` |

## Current snapshot (2026-07-09, regenerated)
- Commits: **742** over a **61-day** span (05-10→07-09); busiest single day 62 (06-24), then 07-05 at 49; this week (07-05→07-09) = 122.
- Races proven (gate ledger): **10/10** — Imperial 07-04, Dunmer 07-05. Long pole down.
- **1.0 contract gate (`pdv_1_0_endstate_gate.mjs`): 9 PASS / 1 STALE / 8 RED after the 07-09 `--run` re-green with the Anvil bridge live.** ALL NINE machine gates green (Prince, beta-strict, verify, content, integrity, expmode-build, pacing-sim, felt-trace, dislike-build). C-AUDIT-INTEGRITY closed when the bridge confirmed 39/39 signal surfaces GREEN.
- The 8 remaining RED are evidence-gate slots only (no code): C-FELT-FAMILY (105/148 open), C-PACING-SIGNOFF (10), C-EXPMODE-SMOKE (2), C-REQUIEM-TRACKB (3), C-DISLIKE-DEBUFF-TUNING (1), C-COMPAT-ARR (1), C-COMPAT-BORDELLO (6), C-PLACEMENT-FINAL (folds into race sittings). C-RACE-RUBRIC STALE = race-sheet drift.
- E2E wiring gate 39 GREEN / 0 RED; spine 7/7; specced minuses 0/16; all DONE.
- Design guidance now bars dual-axis charts, so BOTH widgets were rebuilt single-axis on 07-09 (build-arc = commit bars + cards; projection = horizontal remaining-effort bars + cards). The old dual-axis burnup (cumulative % line) is retired.
- Caveat carried on the projection: gate flags live-vs-deployed manager drift; recompile/deploy to MO2 before in-game smoke.

---

## Widget 1 — build-arc history (SINGLE-AXIS as of 07-09)
Daily commit bars, one y-axis (blue `#378ADD`), + 4 metric cards + milestone
annotation lines. Races line RETIRED (10/10 done; dual-axis barred by guidance).
Refresh: append new days to `commits`, regen `labels`, move the last milestone.

```js
// data (61 days, 05-10→07-09):
var commits=[4,0,0,10,1,8,15,5,8,6,6,18,0,1,4,6,5,2,13,12,31,26,12,11,4,27,18,23,13,8,11,19,10,21,13,12,22,4,5,0,4,21,29,8,16,62,14,0,7,9,5,9,4,3,2,13,49,30,20,5,18];
var labels=[];var d=new Date(2026,4,10);for(var j=0;j<61;j++){labels.push((d.getMonth()+1)+'/'+d.getDate());d=new Date(d.getTime()+86400000);}
// milestone annotation lines (label → text): '6/24' integrity harness (idx45, 62-spike), '7/5' races 10/10 (idx56), '7/9' gates 9/9 (idx60)
```
Build: type bar, single y-axis, maxBarThickness 14, x autoSkip maxTicksLimit 12;
annotation vertical dashed lines keyed by DATE LABEL (not index). Cards: total
commits 742, day span 61, this week (7/5-7/9) 122, busiest day 62. Rendered as
`devotion_build_arc_through_2026_07_09`.

---

## Widget 2 — projection-to-1.0 (phased burnup) — RE-DERIVE, estimates

**MODEL CHANGE 2026-07-09 (contract era).** The projection is now derived from
the 1.0 End-State Contract (`pdv_1_0_endstate_gate.mjs` burndown), NOT the old
5-lane roadmap. Rendered as `devotion_projection_to_oneoh_contract_era`:

SINGLE-AXIS horizontal bars (dual-axis burnup retired 07-09). Bars = est. sessions
per REMAINING lane, colored by TYPE (blue `#378ADD` = in-game testing, gray
`#888780` = packaging); 2-item legend; 3 metric cards. All machine gates are green,
so no build/red bars remain — every lane is play-or-package. Rendered as
`devotion_projection_to_oneoh_2026_07_09`:

```js
// indexAxis:'y'; sorted descending; total ~6 sessions (2026-07-12):
var labels=['felt-family sweep (71 net families)','ARR compat packet','Bordello compat (2 build-targets, 6 lists)','requiem track B (Authoria)'];
var effort=[2.5,1.5,1,1];
var fill=['#378ADD','#888780','#888780','#378ADD']; // blue=in-game test, gray=packaging
// OWNER CORRECTION 2026-07-12: C-COMPAT-BORDELLO's 6 lists (JOJ/TOT/HOH/MOM/DoD/VOV)
// collapse to 2 real build-targets -- DoD-base and JOJ-base -- which SHARE the
// religion-removal set. Packaging WORK is 2 passes, ~1 session, not 6. The gate still
// carries 6 evidence slots (one sign-off per list), closed from the 2 base packages.
// Per-list -> base mapping (TOT/HOH/MOM/VOV) TBD at packaging time. Bar dropped 2.5 -> 1.
// Cards: felt-family 79/150 (53%) | sessions to 1.0 ~6 (was 10.5) | compat build-targets 2 not 6.
// Experience Mode smoke CLOSED (2/2), signal-floor smoke CLOSED (13/13) -> both bars removed.
// Nord + Imperial felt sittings DONE + verified (13/13 each, ticks backed by ledger).
// 07-11: 35 felt families recorded in ONE testing day (WITH bug-finding). Cross-cutting
// pre-cleared 10 of the remaining 8 sittings' 82 families -> 72 net; Breton walks in
// half-done (6/12). Caveat: Nord/Imperial were Divines-heavy so cleared an outsized
// share of shared pantheon families; bespoke races left (Khajiit/Argonian/Dunmer/Bosmer)
// hold closer to nominal. pacing (1/10), placement hooks (73/83), dislike-tuning fold in.
```

Old model (kept for history) — sequencing megapacket → Experience Mode smoke →
ARR compat → branding, remaining ≈5 sessions as of 2026-07-06 evening:

```js
var labels=['megapacket smoke','requiem felt sweep','experience mode','ARR compat','branding + packaging'];
var effort=[1,1,0.5,1.5,1];            // est sessions, SOFT — see 07-06 evening note
var cum=[20,40,50,80,100];             // cumulative % of remaining road
var fill=['#378ADD','#378ADD','#A32D2D','#7F77DD','#888780']; // blue=in-game test, red=build-smoke, purple/gray=compat+packaging
// 1F freeze annotation after 'requiem felt sweep' (x=1.5); 1.0 ready at end (x=4.5).
// 2026-07-06 evening: megapacket bar burned 2 -> 1. Universal Prisma U1-U9 ALL PASS
// in game; C2 beats 1/2/4 ran; all three U4 retests (curated driver-reason, watching
// badge, watching-onset BoD line) re-verified; Sitting-1 quest-reaction aggregation
// re-verify CLOSED. Remaining = Sitting-1 tail (C2 beats 3/5/6, Refuse/Accept
// control, Orkey/Dibella Active Effects smoke after the MCM freeze-guard restart)
// + Sitting 2 (Prince V2 F + C3-if-changed). Bug tally 16 caught in-game across the
// packet (07-06 cascade added: driver-reason, watching badge, watching BoD line,
// refuse surfaces, Hircine over-fire, Old Ways neglect lapses, MCM ShowMessage
// freeze, app.js CRLF drift). Open tasks: 387bfc95 slider cap, 7dab1ebb Hircine,
// e6904bb3 + 8c27e440 manual smoke owed.
// Cards: ~5 sessions / 16 bugs caught+fixed / ~82% burned.
// 2026-07-06 midday: Sitting-1 Prisma U1-U9 PASS, but the run stayed bug-heavy;
// megapacket bar held until the C2 residual beats close.
// Experience Mode BUILT 07-05 (b09acefb, all 5 steps) so its bar collapsed 2.5 -> 0.5
// (Session G smoke + Redguard earn-halt mirror still unbuilt). U/Prisma catches include
// panel movement filter, debug resync, Nord reused-spell strip (+lint), Orkey/Dibella,
// curated driver copy, watching badge/onset line, and surfacing aggregation.
// Cards: ~6 sessions / 8+ bugs caught+fixed / ~79% burned.
// 2026-07-05 evening: Sitting 1 (Section A 8 origins + E1 sweep + mechanics) PASSED;
// 4 wiring bugs (341/360/365/361+364) found AND fixed+proven same day.
```
Note (2026-07-05): signal-floor ×23, race testing (10/10 packets), and Daedric
in-game proof (PASS=16) are DONE and removed. Megapacket smoke = Anvil sittings
1-2 of `PDV_MegaPacket_OneOh_2026-07-02.md` (quest-expansion A-rows, day-to-day
E-sweep, Prisma C, Prince V2 F); requiem felt sweep = Authoria sitting 3.
Experience Mode is BUILT (b09acefb 2026-07-05); its bar is the Session G in-game
smoke + the Redguard earn-halt mirror (still unbuilt).
Rendered as `devotion_projection_to_oneoh_2026_07_05` with metric cards
(sessions remaining ~5 / 16 in-game bugs caught+fixed / ~82% of baseline burned).

---

## Widget 3 — progress snapshot (% per workstream)
Pure-HTML horizontal bars, green (done) / amber (in progress) / gray (not started·play-gated).
Refresh from the harness roll-up. Current rows:

```
e2e wiring gate        100%  39/0        green
Integrity Harness      100%  built       green
spine parity           100%  7/7         green
specced minuses        100%  16/16 wired green   <-- now DONE (6c)
ancestral LD mechanism 100%  origin-gate green   <-- 6d mechanism DONE; content play-gated
signal floor            55%  28/51       amber
Daedric in-game proof  ~25%  floors done amber
race testing+re-verify   0%  play-gated  gray
Requiem HP-bar sweep     0%  play-gated  gray
Experience Mode          0%  unbuilt     gray
```
(Code pattern: `devotion_audit_progress_snapshot_06_24` — bar fill % via inline width,
color by status; legend done/in-progress/not-started.)

---

## Widget 4 — build-debt burndown (the "when will we finish" chart)
Line of machine-buildable items remaining (floor + minuses + spine targets), with
real data points and a best/likely projection cone to zero. Build items only — the
play-gated test/tune tail is NOT on this axis (call it out in prose).

```js
var labels=['Jun24 08:00','Jun24 14:00','Jun24 18:00','Jun25 ~now','Jun25 22:00','Jun26'];
var actual=[71,45,40,23,null,null];   // last real point from harness: floor_under(23) + minuses(0) + spine_targets(0) = 23
var best=[null,null,null,23,0,null];
var likely=[null,null,null,23,12,0];
// y title 'machine-buildable items remaining'; annotation y=0 line 'build debt = 0'.
// NOTE: the remaining 23 are ALL signal-floor race-paths; minuses + spine + gate are 0.
```
Cards: build items left **23** (all signal-floor paths), minuses cleared (17→0) + spine
done this burn, build clear est. Jun26, then-to-1.0 play-gated. (Pattern: `devotion_build_debt_burndown_to_finish`.)

---

## Widget 5 — spine-parity tracker (LIVING, per its own handoff)
Horizontal bars worst-first, length=pct, segmented by the 6 weighted dims, dashed
70% threshold line, header `N/7 at parity`. Refresh: `node tools/pdv_spine_stack_score.mjs`
→ read `PDV_SpineStackScoreLedger.csv`. CURRENT = 7/7 COMPLETE, all 10 ≥70% (post-6e):

```js
// [race, pct, [boon×3, sink×2, minus×2, renew×1, dieg×1, text×1 weighted contributions], target]
var data=[
  ['Bosmer',73.3,[6,4,4,2,3,3],false],
  ['Breton',76.7,[9,6,2,2,2,2],false],
  ['Imperial',76.7,[9,6,2,2,2,2],false],
  ['Altmer',76.7,[9,6,2,2,2,2],false],
  ['Dunmer',80,[9,6,4,2,1,2],false],
  ['Orc',80,[9,6,2,2,3,2],false],
  ['Redguard',83.3,[9,6,4,2,2,2],false],
  ['Nord',83.3,[9,6,2,2,3,3],false],
  ['Khajiit',86.7,[9,6,4,2,2,3],false],
  ['Argonian',100,[9,6,6,3,3,3],false]];
var col=['#1D9E75','#378ADD','#D85A30','#E89A2B','#7F77DD','#D4537E'];
// segment width = contribution/30*100% ; threshold line at left:70% ; status green (at parity) since all target=false
```
(Pattern: `devotion_spine_parity_tracker_live` — weighted contribution = dim_value × weight; raw max 30 = 100%.)

---

## Update protocol (event-driven, LIVING — not scheduled)
When work lands, the user says so → refresh the relevant source → re-render only the
affected widget(s). Build items burn down on Codex commits; races-proven + the
play-gated rows move only on the user's in-game sessions. Keep the burndown's
build axis separate from the play-gated tail. A burndown of *whole-project* scope
was rejected earlier (only shows scope shrinking) — the build-arc + this targeted
build-debt burndown are the agreed framing. Full rationale + numbers live in
[[living-beta-progress-charts]].
