# PDV UX/UI Next-Session Handoff - 2026-08-25

## Purpose

Resume PDV UX/UI work without reopening design decisions that are already locked in the
architecture, race design packets, or decision memos. The next assistant should recover the
intended design first, compare it with current implementation, and ask the user only about a
genuine contradiction, missing choice, or taste call.

This is an assistant-neutral handoff. It may be used with Codex, Claude, or another assistant.
It is a dated execution guide, not a new design authority.

For next-session UX work, use this file instead of the workflow and artifact instructions in
`handoff/PDV_UX_Claude_Handoff_2026-08-24.md`. Keep the older file as historical context; its
workbook path and discovery-first framing are superseded here.

The user owns artistic direction and exact prose. Preserve owner wording unless the user asks
for alternatives or a mechanical contradiction makes the wording impossible to implement.

## The operating pattern: recover, reconcile, implement

The unit of work is one bounded player moment:

`trigger -> presentation -> player understanding or choice -> consequence -> recovery/follow-up`

Do not begin by asking the user what the moment should do. Begin by retrieving the answer from
the narrowest current design authority.

### 1. Recover the intended decision

Read only the sources relevant to the selected moment. Produce a compact recovered-decision
summary containing:

- the locked player experience;
- the locked mechanic and branches;
- the intended surface and intrusion level;
- the intended emotional, cultural, and theological beat;
- any exact design language that remains explicitly provisional.

Completion criterion: every material part of the proposed UX is either sourced to an active
authority or labelled genuinely unresolved. A missing implementation is not an open design
question.

### 2. Reconcile against current implementation

Keep these truths separate:

- **Design truth:** what the experience is intended to be.
- **Runtime/source truth:** what Papyrus currently routes and assembles.
- **ESP truth:** which records and properties currently exist.
- **Player-surface proof:** what has actually been observed in game.
- **Prose truth:** exact owner wording in the workbook.

Verify Papyrus and direct ESP readback independently. Record absent runtime proof as absent;
do not infer it from a green static check.

Classify each apparent gap as exactly one of:

1. already implemented; verification only;
2. implementation missing;
3. implementation differs from locked design;
4. exact prose missing or pending owner review;
5. genuine design question;
6. stale or historical reference, requiring no implementation.

Completion criterion: the selected moment has one short delta statement saying what is missing
or mismatched. If there is no delta, close the audit row rather than redesigning the moment.

### 3. Ask only the unresolved frontier

Bring a question to the user only when:

- two current authorities conflict;
- a technical constraint forces a player-visible trade-off;
- several valid treatments remain and the choice is artistic;
- exact prose requires owner judgment;
- scope or a new dependency requires approval.

Do not ask the user to recall facts available in the repository. Do not re-ask whether an
already locked feature should exist. Present the recovered answer, the implementation delta,
and the smallest remaining choice.

### 4. Implement as a small vertical slice

After approval, implement the smallest complete player moment, including its real trigger,
presentation, alternate branch, recovery path, and fallback. Avoid implementing only the cheap
record or copy layer while leaving the event unable to fire.

One slice should normally include:

- stable Atlas node and copy IDs;
- trigger and route;
- surface and fallback;
- exact approved prose, when needed;
- branch, dismissal, repetition, and recovery behaviour;
- anti-spam or one-shot rule;
- static/readback checks;
- clearly separated runtime and player-surface proof still owed.

### 5. Close the loop

Update the narrowest authority that owns the changed state:

- Atlas for implementation/readback status and remaining discrepancies;
- workbook for exact owner prose;
- Penpot for a material flow or surface decision;
- source/ESP for implementation;
- proof ledger or handoff for runtime/manual evidence.

Penpot is not required for a decision already documented clearly enough to implement. Use it
when spatial comparison, adjacency, branching, or a new presentation treatment needs visual
work.

## Why PDV uses this pattern

- Most PDV design has already been paid for in architecture and race packets. Retrieval is
  faster and more reliable than rediscovery.
- It separates missing code from missing design, preventing audits from inflating the number of
  user decisions.
- It preserves the user's authorship by reserving questions for actual judgment calls.
- It prevents popup-first design: the mechanic, moment, cadence, and neighbouring surfaces are
  known before a channel is selected or changed.
- A complete vertical slice can be implemented and proven without reopening an entire race.
- Stable IDs allow the Atlas, workbook, Penpot, source, and ESP to agree without duplicating all
  their content into one document.

## Product principles to carry into every slice

- Devotion should remain atmospheric and consequential without becoming the focal point of an
  otherwise normal Skyrim playthrough.
- The default experience preserves religious mystery. Prisma and Book of Days quietly name
  meaningful likes, dislikes, and relationship changes; Survey Devotion provides optional
  mechanical transparency without exposing the raw piety number.
- The relationship becomes more explicit as attention deepens: recognition, commitment,
  focused devotion, and Champion status should feel progressively more significant.
- Routine acts should not generate routine popup spam. Major transitions, real choices, major
  affronts, rupture, and recovery may justify stronger presentation.
- Player-facing race framing comes from the race's current Skyrim-era culture and religious
  history. Daedric stigma and response remain culturally specific.
- Exact prose belongs to the user. Agent work is mapping, research, implementation analysis,
  conformance review, and minimal approved editing.

## Current authorities

### Design and mechanics

- Cross-race architecture: `references/PDV_RaceArchitecture_DesignReference.md`.
- Current technical architecture: `PDV_Architecture_v3.md` and `PDV_Architecture_v2.md` where
  still referenced by the current design packet.
- Per-race design: `race-sheets/PDV_RaceDesign_<Race>.md`.
- Imperial design: `race-sheets/PDV_RaceDesign_Imperial.md`.
- Imperial Concordat surfacing decision:
  `references/authoring/PDV_DecisionMemo_ImperialComplianceLane.md`.
- Diegetic surface architecture:
  `references/authoring/PDV_DiegeticUX_ArchitectureSpec.md`.
- Surface feasibility and constraints: `references/authoring/PDV_UXSurfaceCatalogue.json`.

Read superseding addenda before older prose in the same packet. A locked design document says
what should happen; it does not prove that the current game does it.

### Audit and traceability

- Editable audit authority: `references/authoring/PDV_RaceArchitectureAtlas.json`.
- Validate/render with `node tools/pdv_atlas_render.mjs --check` and
  `node tools/pdv_atlas_render.mjs`.
- Regenerable implementation projection:
  `node tools/pdv_implementation_audit_export.mjs --write`.
- Stable flow map: `references/authoring/PDV_CopyFlowMap.json`.

### Exact prose

- Current workbook:
  `outputs/PDV_Accessible_Prose_Workbook_2026-08-25/PDV_Accessible_Prose_Editing_Workbook_v3.xlsx`.
- The visible writing sheets own the user's review statuses, wording, and notes.
- Stable copy IDs preserve the round trip. Technical columns or sheets are traceability support,
  not a writing surface.
- Historical reference rows are evidence or prior intent, not live records and not automatic
  implementation requirements.

### Visual design

- Penpot project: **Devotion UX Workbench**.
- Penpot owns flow, adjacency, surface experiments, and explicit design annotations.
- Freeform arrows, moved objects, and sketches are evidence. Only named fields explicitly marked
  `Approved for implementation` become requirements.

## Current audit state

The compact queue has five items:

- three Imperial player-experience deltas;
- one shared source/PEX version-reconciliation blocker;
- one global Message census paging defect.

The three Imperial rows were phrased as questions, but the current design sources answer most of
them. Treat them as implementation-reconciliation cards:

| Moment | Recovered design | Actual remaining work |
|---|---|---|
| Imperial curse rupture and recovery | Vampirism halts Imperial Divine and civic devotion; the current addendum resets civic practice and seeds recovery at 20 after cure. Lycanthropy reduces rather than halts Nine Divines effectiveness and opens no native Imperial Hircine path. Curse onset and cure are major transitions, not routine notices. | Verify the current vampire and werewolf branches in active source and ESP; compare current Survey/Book/Prisma/MessageBox coverage; reconcile exact owner copy; implement only the missing transition and recovery surfaces. |
| Imperial Champion recognition | Champion entry is a personal, deity-specific recognition moment. The race packet contains nine Champion moments. The diegetic profile treats Champion entry as an apotheosis-level transition rather than only a generic tier change. | Verify what the generic Champion helper currently emits and which per-deity assets/records exist. Determine the smallest shared implementation that preserves deity-specific recognition without nine cloned flows. |
| Concordat posture changes | Concordat compliance is a standing modifier, not a separate worship lane or Champion path. High compliance closes Talos absent costly defiance and strains Arkay/Stendarr. The resolved presentation is state-legible rather than offer-time rejection: surface meaningful standing transitions and preserve the consequence in Survey/status. | Verify current threshold emitters and persistent status text. Implement missing threshold-transition and status coverage without adding five mandatory popups or a repeated Talos rejection. |

## Recommended implementation order

1. **Resolve or explicitly version-qualify the shared source/PEX drift.** Current audit evidence
   says the active tree and repo mirror differ across 26 shared scripts. Do not make unqualified
   route claims until the intended 2.0 source authority is confirmed.
2. **Concordat posture surfacing.** This is the smallest design-locked tracer slice: the track,
   consequence, and presentation rule are already settled.
3. **Champion recognition.** Use one shared transition architecture with deity-specific content,
   rather than nine independent flows.
4. **Curse onset and recovery.** Implement after the shared transition pattern is proven because
   this slice carries asymmetric vampire/werewolf mechanics, cure recovery, and save/load risk.
5. **Repair the global Message census paging defect** before claiming that the workbook is a
   complete global live-copy inventory. Race-scoped Message families currently reconcile.

This order optimizes for a small proven vertical slice first. The user may reorder it when a
different player-impact priority matters more.

## Exact opening script for the next assistant

1. State: "I will recover the existing decision before asking you to redesign anything."
2. Read the selected Atlas node, the narrow race packet section, any linked decision memo, the
   relevant current source functions, and direct ESP records.
3. Return one compact card:
   - **Recovered requirement**
   - **Current implementation**
   - **Delta**
   - **Only unresolved choice**, or `None`
   - **Smallest implementation slice**
   - **Proof required**
4. Ask for confirmation only if a genuine choice remains or before making player-visible/game
   changes.
5. Implement and verify the approved vertical slice in the same session where practical.
6. End with the next single slice, not the entire remaining race backlog.

## Next-session completion criterion

The next UX/UI session is successful when one Imperial moment has:

- its existing design recovered and cited;
- Papyrus and ESP state independently verified;
- the implementation delta reduced to one bounded statement;
- no settled design question returned to the user;
- any genuine taste call decided or explicitly parked;
- either one complete vertical slice implemented and statically/readback verified, or one precise
  implementation packet ready for approval;
- runtime, player-surface, save/load, and packaging evidence reported separately rather than
  inferred.

The session does not need to finish the Imperial race, rewrite all linked prose, or redesign the
full Penpot journey.

## Current scope and safety boundary

- Current branch at handoff creation: `fix/2.0-copy-uplift`.
- The working tree already contains unrelated or in-progress modifications. Inspect and preserve
  them; stage only an explicitly reviewed slice.
- No ESP, Papyrus, Prisma, workbook prose, or Penpot content was changed while creating this
  handoff.
- Direct ESP readback proves record data, not runtime routing or player-visible presentation.
- Workbook or Penpot edits alone do not authorize game changes.
