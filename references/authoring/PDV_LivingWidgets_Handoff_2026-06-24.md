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

## Current snapshot (2026-06-25, regenerated)
- Commits: **528** over **46** days (05-10→06-24); busiest day 36 (06-24); 6e + 6c landed.
- Races proven (gate ledger): **8/10** (Dunmer/Imperial pending in-game).
- E2E wiring gate: **39 GREEN / 0 RED** (DONE). Integrity Harness: **built** (DONE).
- Signal floor: **28/51 PASS**, **23 race-paths under floor** (all 16 Princes done).
- Spine parity: **7/7 at parity (DONE)** — after the 6e retrofit all 10 races clear the 70% floor; lowest Bosmer 73.3%, highest Argonian 100% (Nord/Orc/Redguard lifted).
- Specced minuses: **0 unemitted (16/16 wired) — DONE** (6c: removed 9 pantheon + 2 Daedric, wired 3 Daedric + 3 Hist + Tu'whacca).
- Per-culture ancestral LD (6d): **mechanism DONE** (committed ec36725; originGate column + native-gated overlay read); content rows + new-save proof play-gated.
- **Machine-buildable build items left = 23 floor + 0 minuses = 23** (spine 0, gate 0, minuses 0).
- Play-gated (NOT in the 23): ancestral-LD content rows, run-sheets
  (Dunmer/Imperial + re-verify the 8 proven races on new spine/signal dims),
  Requiem HP-bar sweep, Daedric in-game proof, Experience Mode (build+test).

---

## Widget 1 — build-arc history
Daily commits (amber bars) + cumulative races-proven (teal stepped line, right axis).
Refresh: extend `commits`/`labels` with new days; bump races line only when a NEW
race packet PASSES the gate ledger.

```js
// data (46 days, 05-10→06-24):
var commits=[4,0,0,10,1,8,15,5,6,8,6,18,0,1,4,6,5,2,13,12,31,26,12,11,4,27,18,23,13,8,11,19,10,21,13,12,22,4,5,0,4,21,29,8,16,24];
var races=[];for(var i=0;i<46;i++){races.push(i<31?0:i<35?1:i<37?2:i<39?3:i<40?6:8);}
var labels=[];var d=new Date(2026,4,10);for(var j=0;j<46;j++){labels.push((d.getMonth()+1)+'/'+d.getDate());d=new Date(d.getTime()+86400000);}
// milestone annotation lines (index → label): 21 phase 20 gate, 34 9-race audit, 41 requiem conv., 44 signal-equity audit + harness
```
Build: type bar (commits, left axis `c` max ~33) + type line stepped (races, right
axis `r` 0-10); pointRadius 4 only where races changes; annotation vertical dashed
lines at the indices above (xAdjust -50 when index>38). Cards: commits 516, days 46,
races 8/10, today 24. (Full code pattern: see widget `devotion_build_arc_refreshed_through_06_24`.)

---

## Widget 2 — projection-to-1.0 (phased burnup) — RE-DERIVE, estimates
Bars = est. sessions per REMAINING workstream; teal line = cumulative % of the
remaining road; dashed 1F-freeze + 1.0 gates. DONE phases drop off. Current
remaining (≈15.5 sessions, down from the ~28 baseline before today's build burn):

```js
var labels=['signal-floor ×23','race testing','requiem sweep','daedric + surfacing','experience mode'];
var effort=[4,4,2,2.5,2];              // est sessions, SOFT — refresh from velocity
var cum=[28,55,69,86,100];             // cumulative % of remaining road
var fill=['#A32D2D','#378ADD','#1D9E75','#7F77DD','#888780']; // warm=build, cool=test, gray=build-dependent
// 1F freeze annotation after 'requiem sweep' (x=2.5); 1.0 ready at end.
```
Note: integrity harness / wiring tail / spine parity / **specced minuses (6c)** are DONE
and removed. Signal-floor ×23 is now the only pure-build bar left; it shrinks first.

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
