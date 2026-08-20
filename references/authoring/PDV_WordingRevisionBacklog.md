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

## Deity name rendered lowercase in Prisma smoke (2026-08-20, owner-flagged) -- RUNTIME RECHECK

Observed during the intake smoke: "Favor deepened / Your devotion to auri-el has reached
Champion." Current-source investigation disproved the provisional claim that the live Prisma
template composes this sentence from the lowercase symbol. The repository and `Devotion-V3Dev`
Prisma assets are byte-identical; the tier renderer calls `deityName(payload)`, the presenter
builds the journal line from `GetJournalDeityName(deityIndex)`, and that resolver calls
`GetPublicDeityDisplayName`. `pdv_prisma_ui_audit.mjs` now fails closed if tier display copy uses
the symbol field or if the presenter stops resolving the public display name; its regression
case covers Talos, Tu'whacca, Z'en, Baan Dar, and Auri-El.

This closes the current-source defect hypothesis, not the observation. Recheck on the next
fresh-game/runtime pass with the current PEX and Prisma cache. If it recurs, capture the exact
payload and loaded asset/version before changing copy or renderer code.
- **Status:** STATIC CLOSED; RUNTIME RECHECK OPEN.

## Formal commitment offer must NAME the deity + rewrite drafts (2026-08-20, owner-flagged)

Offer fired at Devoted (piety 50) but did not name Auri-El. Owner: ALL offers should name their
deity, and the current drafts read mediocre -- owner will supply rewrites. Records: per-adapter
GetXFormalCommitmentOfferMessage -> PDV_Msg_<Race>_<Deity>_Offer (Altmer AuriEl/Magnus/Xarxes/
Trinimac/Syrabane; same shape for Breton/Dunmer/Imperial/Nord/Redguard). Audit every offer Message
record for the deity name; drop owners rewritten drafts here. See ForCodex handoff section 3b.

Direct houseCARL readback on 2026-08-20 found 45 actual offer records. Every record names the
deity in `Name`, but 23 descriptions do not contain the deity's explicit public name:

- Nord (12): `PDV_Msg_Nord_Kyne_Offer`, `PDV_Msg_Nord_Tsun_Offer`,
  `PDV_Msg_Nord_Stuhn_Offer`, `PDV_Msg_Nord_Akatosh_Offer`,
  `PDV_Msg_Nord_Mara_Offer`, `PDV_Msg_Nord_Arkay_Offer`,
  `PDV_Msg_Nord_Stendarr_Offer`, `PDV_Msg_Nord_Zenithar_Offer`,
  `PDV_Msg_Nord_Julianos_Offer`, `PDV_Msg_Nord_Dibella_Offer`,
  `PDV_Msg_Nord_Kynareth_Offer`, `PDV_Msg_Nord_Orkey_Offer`.
- Dunmer (3): `PDV_Msg_Dunmer_Azura_Offer`, `PDV_Msg_Dunmer_Boethiah_Offer`,
  `PDV_Msg_Dunmer_Mephala_Offer`.
- Altmer (3): `PDV_Msg_Altmer_AuriEl_Offer`, `PDV_Msg_Altmer_Magnus_Offer`,
  `PDV_Msg_Altmer_Xarxes_Offer`.
- Imperial (4): `PDV_Msg_Imperial_Akatosh_Offer`, `PDV_Msg_Imperial_Talos_Offer`,
  `PDV_Msg_Imperial_Mara_Offer`, `PDV_Msg_Imperial_Zenithar_Offer`.
- Redguard (1): `PDV_Msg_Redguard_HoonDing_Offer`.
- Breton (0): all 11 descriptions already name their deity.

The remaining 22 descriptions already contain the deity's public name. No Message record was
changed in the module-closeout tranche: the owner rewrite is the authority for this copy pass.
- **Status:** INVENTORY COMPLETE; OPEN -- owner to draft 23 descriptions, Codex to apply and
  read back the Message records.
