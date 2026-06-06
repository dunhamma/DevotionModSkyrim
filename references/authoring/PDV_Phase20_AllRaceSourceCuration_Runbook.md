# PDV Phase 20 All-Race Source Curation Runbook

**Created:** 2026-06-03
**Status:** Unified curation handoff for all ten race immersive hook contracts
**Owner:** Companion to `PDV_Phase20_NoInGameProof_Gates.json`

## Purpose

Phase 20 no longer splits race readiness by whether a route is P0, P1, or P2.
All ten races use the same source standard before empirical proof:

- QASmoke ACTI/REFR records are route harnesses only.
- Scan-only candidate tables are prompts, not approvals.
- Final hook proof requires exact source records, rejected-source proof,
  wrong-origin silence, anti-farm behavior, Survey/status clarity, stack
  snapshot, and manual feel evidence.

Do not promote scan-only quest candidates into live FormLists or route sources.
`vanilla-quest-candidates.csv` explicitly marks rows as scan-only and says to
read specific quest records before implementing stage hooks. That warning
applies to every race, not only Breton, Dunmer, Imperial, and Nord.

## Shared Approval Rule

Before a source can be wired or treated as empirical proof, record:

- exact form key in `ModName.ext:localHex` form
- source kind: quest-stage, book, spell-learned, spell-effect, harvest,
  weather, location, service, crime-chain, sleep, shrine/rite, craft, kill, or
  script-event
- route family and race
- accepted context
- rejected context
- anti-farm rule
- proof route
- whether source readback is direct record readback, CK readback, xEdit
  readback, runtime log proof, or manual in-game proof

Quest-stage sources need additional proof:

- exact quest record
- exact stage or mutually exclusive outcome
- whether every observed stage change is acceptable for that source family
- duplicate guard
- rejected nearby stage or generic quest progress case

If the receiver cannot distinguish a quest's meaningful stage from unrelated
stage changes, do not use the whole quest as a PO3 quest-stage source. Use a
narrower receiver, fragment/script event, or keep it manual until a safe source
shape exists.

## Race Curation Targets

| Race | Contract families now in scope | Current source posture |
|---|---|---|
| Altmer | Dawn/study coherence, Lorkhan/crisis pressure, orthodox costly enforcement | QASmoke route harness exists; final dawn/study and crisis-pressure sources need exact record/context approval |
| Khajiit | Lunar observance, road-home circuit, Baan Dar/Rajhin/Alkosh focus | QASmoke route harness exists; final moon, road, caravan, theft, and dragon-order sources need exact source approval |
| Argonian | Hist water/rest, People/community support, Void threshold | QASmoke route harness exists; final water/rest/community/Void sources need exact source approval |
| Orc | Stronghold forge, city dignity/community, Legion/exile service | QASmoke route harness exists; final forge/service/community/faction sources need exact source approval |
| Redguard | Crown/Forebear sect, Ash'abah death duty, HoonDing/Far Shores cap | QASmoke route harness exists; final tomb/death-duty/sect/road sources need exact source approval |
| Bosmer | Old Contract proper hunt/forest kept, Living Story community/nature, Exchange debt/redress, Bandit Road road-life/reversal | QASmoke route harness exists for all four options; final Old Contract and non-hunter sources need exact source approval before item/tag expansion |
| Breton | Tradition choice, Knight's Road, Hidden Art, Green Way | Receiver/FormList tooling exists; source fill remains empty until exact approved records are chosen |
| Dunmer | Portable ash-prayer/home rite, Reclamation focus, deviation price | Existing devotional object routes exist; Reclamation/deviation source fill remains empty until exact approved records are chosen |
| Imperial | Civic service, public/private Talos pressure, patron civic favor | Receiver/FormList tooling exists; source fill remains empty until exact approved records are chosen |
| Nord | Old Ways state, Kyne/Talos context, Hircine/Arkay edge | Receiver/FormList tooling exists; source fill remains empty until exact approved records are chosen |

## Candidate Table Boundaries

Use local extracted tables only as discovery aids:

- `references/vanilla-gameplay/extracted/vanilla-quest-candidates.csv`
- `references/vanilla-gameplay/extracted/vanilla-book-signal-candidates.csv`
- `references/vanilla-gameplay/extracted/vanilla-spell-effect-candidates.csv`
- `references/vanilla-gameplay/pdv-crosswalk/quest-moral-signal-crosswalk.csv`
- `references/vanilla-gameplay/pdv-crosswalk/hook-recipe-cards.md`

Book and spell rows may be easier to approve than quest rows because their
source form is the event source. They still need semantic review and duplicate
owner selection. For example, a spell tome may fire both book-read and
spell-learned paths; one family must own the score.

Shrine blessing spells are not spell-learned sources. They belong to future
spell-effect, shrine, or rite receivers.

## Current Stop Condition

All races can proceed together to source curation and empirical proof. None
should be promoted to `Pass` or scoped `Conditional` only because a route
harness exists.

The next safe implementation step is to author exact approved source manifests
or receiver-specific source plans for all races, starting with sources where the
record semantics are unambiguous and the rejected generic case is testable.
