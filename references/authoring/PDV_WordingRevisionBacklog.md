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


---

## MCM Status page -- redundant restatement (owner-flagged 2026-08-19)

Observed live on a Nord fresh save (broad Nine Divines). The Status/summary page restates the
same worship fact several times:

| Row | Value (Nord example) |
|---|---|
| summary | `BROAD WORSHIP \| UNPROVEN` |
| path | `PILGRIM'S PATH` |
| mode | `BROAD NINE DIVINES` |
| Patron | `BROAD WORSHIP` |
| Standing | `UNPROVEN` |
| Favor | `NORD BROAD NINE DIVINES` |

- `summary` is literally `Patron` + `Standing` concatenated -- pure duplication of the two rows
  directly beneath it.
- `Patron` / `mode` / `path` / `Favor` all encode "broad Nine Divines" four different ways;
  "BROAD" appears 4x and "NINE DIVINES" 3x on one screen.

**Direction (defer to the MCM by-module rebuild / player-copy pass, NOT now):** collapse to a
single headline plus only the rows that add information. Candidate shape -- one `Devotion`
headline line ("Broad Nine Divines - Unproven"), then `Path`, `Favor`, `Curse`, `Neglect`;
drop the standalone `summary`, `Patron`, `mode`, `Standing` rows once their content is folded
in. Confirm no other surface reads those individual rows before removing them.
- **Status:** OPEN -- deferred to MCM rebuild.

## Deity name renders lowercase in Prisma surfacing (2026-08-20, owner-flagged) -- DEDICATED PASS

Second occurrence of a lowercase deity name (first was Talos, quest-reaction line). Auri-El
in the tier-reach card: "Favor deepened / Your devotion to auri-el has reached Champion."
NOT the Papyrus layer -- GetPublicDeityDisplayName / BuildTierReachJournalLine / SendPrismaEventToast
(PDV__ManagerQuest.psc:7689/1674/1415) all produce "Auri-El"; Auri-El ESP DeityName (QUST 03DE88) is
correct. The lowercase "auri-el" is Altmers Prisma SYMBOL/key -- so the render bug is in the PRISMA
BRIDGE JS/view (tier + journal toast templates compose from the symbol instead of the deity field).
Fix the templates, bump index.html cache key, re-check Talos + all multi-word/hyphenated names
(Tuwhacca, Zen, Baan Dar, Auri-El). See the ForCodex handoff (2026-08-20) section 3a.
- **Status:** OPEN -- dedicated dev pass (render bug, not copy).

## Formal commitment offer must NAME the deity + rewrite drafts (2026-08-20, owner-flagged)

Offer fired at Devoted (piety 50) but did not name Auri-El. Owner: ALL offers should name their
deity, and the current drafts read mediocre -- owner will supply rewrites. Records: per-adapter
GetXFormalCommitmentOfferMessage -> PDV_Msg_<Race>_<Deity>_Offer (Altmer AuriEl/Magnus/Xarxes/
Trinimac/Syrabane; same shape for Breton/Dunmer/Imperial/Nord/Redguard). Audit every offer Message
record for the deity name; drop owners rewritten drafts here. See ForCodex handoff section 3b.
- **Status:** OPEN -- owner to draft; Codex to apply to the Message records.
