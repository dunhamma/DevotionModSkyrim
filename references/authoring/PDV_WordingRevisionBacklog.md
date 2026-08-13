# PDV Wording Revision Backlog

**Status:** LIVING. Opened 2026-08-13.
**Purpose.** Player-facing strings flagged for a copy/voice rewrite. Nothing here is a
bug or a wiring gap -- the copy is live and correct in behaviour, it just reads awkwardly
and wants a hand-edit. This is the queue for the deliberate post-beta copy pass, separate
from the self-marked `PLACEHOLDER copy` drafts (see the pointer at the bottom).

**How to use.** One row per string. Record the surface, the exact `file:line`, the current
copy verbatim, why it was flagged, and any candidate replacements. A change only lands
in-game after the manager recompiles, so leave the live string in place until the pass runs.

---

## 1. Long Devotion mark -- Book of Days entry

- **Surface:** Book of Days journal entry (also feeds the Prisma Ledger). Fires once per
  Long-Devotion mark as a patron accrues piety past Champion (marks at 100/115/130/145/...).
- **Site:** `MaybeSurfaceDevotionMark(...)`, [PDV__ManagerQuest.psc:12345](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:12345)
- **Current copy:** `{Deity} marks devotion held long past the day it was proven.`
- **Flagged by:** reviewer, 2026-08-13. Live shipped copy (NOT a `PLACEHOLDER` draft).
- **Why:** dense/clunky. The knot is *"devotion held long past the day it was proven"* --
  "it" points back to "devotion," and "the day it was proven" is doing compressed work to
  mean *the day you reached Champion*. It parses, but reads stiff for a diegetic journal line.
- **Candidate replacements (staying in register, closest to original intent first):**
  - `{Deity} marks devotion kept faithfully, long after it was first proven.`
  - `{Deity} marks how long your devotion has held since the day you proved it.`
  - `{Deity} marks a devotion that has long outlasted its proving.`
  - `{Deity} sees a devotion that endures far beyond the day it was won.`
- **Status:** OPEN -- awaiting owner pick.

---

## Related: self-marked `PLACEHOLDER copy` drafts

Distinct from the above (these are explicitly labelled drafts the owner already intends to
rewrite post-beta), but the same copy pass should sweep them. Live surfaces, `PLACEHOLDER`
in-source:

- `GetDaedricSurveyText` -- [PDV__ManagerQuest.psc:5383](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:5383)
- `SurfaceSwitchSeverance` (pact switch/severance) -- [PDV__ManagerQuest.psc:5389](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:5389)
- `SurfaceDaedricLapse` (pact lapse) -- [PDV__ManagerQuest.psc:5402](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:5402)
- Generic curse toast title/message -- [PDV__ManagerQuest.psc:21172](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:21172)
- Generic curse Book of Days entry -- [PDV__ManagerQuest.psc:21652](../../live-source/Scripts/Source/PDV__ManagerQuest.psc:21652)
