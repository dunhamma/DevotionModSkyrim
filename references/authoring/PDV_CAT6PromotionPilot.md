# PDV CAT-6 Content Promotion Pilot

Status: first pilot record/readback-proven. Do not use this as permission to
promote broad strings yet.

> **V1/V2 note (2026-05-31):** Per `PDV_Architecture_v3.md` Section 21.3, V1
> ships no voiced NPC dialogue. The **dialogue portion** of CAT-6 promotion (the
> 39 `PDV_Dlog_*_Recognition` strings) is **V2** and excluded from V1 promotion;
> see `references/authoring/PDV_V2_Backlog.md`. Non-voiced CAT-6 promotion
> (MessageBox, notification, Survey, blessing/price descriptions) proceeds for
> V1 as described below.

Owner scope: CAT-6 ratification and promotion handoff for one non-pilot
player-facing content surface.

Structured pilot manifest: `PDV_CAT6PromotionPilot.manifest.json`.

## 1. Purpose

CAT-6 is the point where drafted player-facing prose stops being planning text
and becomes shipped content. `PDV_Architecture_v3.md` Section 25.9 defines this
as a code-coupled handoff: draft prose can run ahead of implementation, but
final string promotion into ESP records and `Race_*.md` handbooks follows the
owning subsystem.

This packet exists to prove that handoff once, deliberately, before broad
promotion starts. It is not a content-grind checklist and it is not a new
runtime feature.

Current repo evidence:

- Section 25.9 marks CAT-6 as `NOT STARTED, code-coupled`.
- Section 17 defines Phase 19 as the code-side content authoring pipeline.
- Phase 19 has a live generated patcher and record-authoring proof lane, but
  broad content string promotion is not proven at scale.
- `race-sheets/PDV_RaceContent_Manifest.md` is the draft source for Aedric and
  native devotion strings.
- `race-sheets/PDV_DaedricContent_Manifest.md` is the draft source for Daedric
  path strings; all sixteen Skyrim-present Princes now have draft rows, but
  Daedric promotion now waits on proof-path gates against the locked D-15..D-18
  decisions: per-Prince CAT-6 target selection, record readback, runtime or
  display proof, and stack/Survey legibility.
- CK-safe dialogue readback exists for CK-authored dialogue, but generated
  dialogue creation is not a supported promotion path.

## 2. Pilot Objective

Prove the complete CAT-6 chain for one low-risk, non-pilot surface:

1. Select one drafted source row from a content manifest.
2. Ratify the row text and its target surface.
3. Promote the ratified string into the owning ESP record.
4. Add or update verifier/readback coverage for that target record.
5. Prove the string appears through runtime, menu, or readback display.
6. Sync the final player-facing wording into the appropriate handbook.
7. Record rollback/backup evidence and stop conditions.

Success means future CAT-6 packets have a repeatable shape. It does not mean
all rows can be promoted automatically.

## 3. Candidate Selection Rules

The first pilot should minimize authoring risk. Choose a candidate that meets
all required rules:

- The source row already exists in `PDV_RaceContent_Manifest.md` or
  `PDV_DaedricContent_Manifest.md`.
- The owning subsystem already exists or is being implemented in the same
  narrow packet.
- The target surface is not dialogue.
- The target surface does not require Story Manager edits, quest alias edits,
  package edits, scene graph edits, or generated dialogue creation.
- The target string can be verified through record readback and either an
  in-game menu, active-effect description, Survey/status display, or a simple
  runtime proof command.
- The change can be rolled back from a timestamped backup or a removable
  overlay.

Prefer these surfaces for the first pilot:

- `SPEL` description on a blessing or price spell.
- `MGEF` description where the magic effect is already part of a proven spell.
- `MESG` title/body shown through Survey/status or a controlled MessageBox.

Avoid these surfaces for the first pilot:

- Dialogue topics, INFO responses, scene content, and NPC recognition lines.
- Daedric stigma band rows until the stigma band/decay row contract is locked.
- Hircine/Molag Bal curse-access rows until their template variation is locked.
- Any row whose gameplay owner is still design-only.
- Any row that requires generated CK graph mutation.

## 4. Required Artifacts

Each CAT-6 pilot packet must produce or identify the following artifacts.

### Source Row

- Manifest path.
- Section heading.
- Slot ID.
- Surface.
- Existing draft prose.
- Length budget and current character count.
- Any token placeholders such as `%s`, `%s1`, or `%s2`.

### Ratification Note

- Ratified final text.
- Date and reviewer.
- Confirmation that the text is ASCII-safe.
- Confirmation that the surface still matches the voice-by-surface matrix.
- Confirmation that the row does not rely on unimplemented gameplay.

The note can live in this packet for the first pilot or in a future
`references/authoring/PDV_CAT6PromotionPilot_<SlotId>.md` if the packet grows.

### Target Record

- Target plugin.
- Record type: `SPEL`, `MGEF`, `MESG`, or other approved type.
- EditorID.
- Target field: description, message title, message body, effect description,
  or equivalent.
- Ownership boundary: direct framework edit, generated overlay, manual CK/xEdit,
  or helper-managed write.

### Authoring Boundary

Name the exact write path before editing:

- Existing narrow helper, if one owns the target record family.
- Manual CK/xEdit, if helper support is absent or unsafe.
- Generated overlay, if the string can be proven without touching the source
  plugin.
- No generated dialogue path for the first pilot.

If manual CK is required, split the workflow:

1. CK/xEdit write and save.
2. Close CK if MO2/MCP readback stalls.
3. Run verifier/readback from the docs workspace.

### Verifier Additions

The verifier must check at least:

- Target record exists.
- Target field equals the ratified ASCII text.
- No placeholder token mismatch.
- No accidental write to the wrong record.
- Any required spell/effect membership still holds.

If the target is a handbook-only string, it is not a CAT-6 ESP promotion pilot.
The first pilot must include ESP readback.

### Runtime or Menu Display Proof

Use the lowest-risk proof that actually shows the promoted text:

- Active Effects menu for `SPEL` / `MGEF` descriptions.
- Survey Devotion or MCM Player page for status `MESG` text.
- Controlled MessageBox route for one-shot `MESG` text.
- Readback-only proof is acceptable as a preflight step, but final pilot
  acceptance needs one player-visible display path unless the record type is
  impossible to display without unrelated gameplay.

### Rollback and Backup

- Timestamped backup path or overlay name.
- Exact record(s) touched.
- Reversal command or manual xEdit/CK reversal note.
- Verifier command expected to fail or pass after rollback.

### Handbook Destination

- Target `race-sheets/Race_*.md` file or other player-facing handbook.
- Section heading.
- Final wording policy: exact copy, shortened player-guide paraphrase, or
  "not handbook-facing".

## 5. Pilot Workflow

1. Pick one candidate and freeze the slot ID.
2. Confirm the owning subsystem exists enough to display the target surface.
3. Ratify text from the manifest row.
4. Run `node tools/pdv_content_verify.mjs`.
5. Create a backup or choose a removable overlay path.
6. Promote the string through the named authoring boundary.
7. Add narrow verifier/readback coverage.
8. Run the relevant strict verifier plus the targeted readback check.
9. Prove runtime or menu display.
10. Sync the handbook destination if the text belongs in a player-facing guide.
11. Write a short result note: pass, fail, rollback, or repeat with a safer
    candidate.

## 6. Acceptance Checklist

A CAT-6 pilot passes only when all of these are true:

- One source row is identified and ratified.
- The promoted string is ASCII-safe.
- The target record and field are named.
- The authoring boundary is explicit.
- The target record reads back with the ratified text.
- The verifier covers the target field.
- Runtime or menu proof shows the promoted text, or the packet explicitly
  accepts readback-only proof for a pre-runtime pilot and keeps runtime display
  proof out of scope.
- The handbook destination is updated or explicitly marked not applicable.
- Rollback is documented.
- No dialogue, scene, quest alias, or Story Manager authoring was introduced.
- No broad CAT-6 claim is made beyond the one proven surface.

## 7. Stop Conditions

Stop the pilot and do not promote more strings if any of these happen:

- The selected row depends on gameplay that does not exist yet.
- The target record does not exist and no safe helper/manual boundary is named.
- CK/xEdit authoring requires dialogue graph mutation.
- The verifier cannot read the promoted field.
- The runtime/menu surface shows stale text after readback passes.
- A placeholder token is lost, renamed, or displayed raw.
- A non-ASCII character enters the promoted string.
- The promotion requires touching unrelated records.
- MO2/MCP readback stalls after CK work and cannot be recovered by the split
  CK-first/readback-second flow.
- Rollback cannot be explained before the write.

## 8. Recommended First Pilot Candidates

### Candidate A: `PDV_Bless_Khajiit_Lunar_T1`

Source: `race-sheets/PDV_RaceContent_Manifest.md`, Khajiit blessing
description row.

Surface: passive `SPEL` description, visible through Active Effects.

Why it fits:

- Non-dialogue.
- Low-risk passive text.
- Belongs to the Khajiit contrast lane, which is already part of the pre-beta
  scaling spine.
- Proves a real player-visible description without waiting on Daedric stigma,
  curse-access, or recognition dialogue.

Risk:

- Confirm the target `SPEL` record exists or choose a helper/manual boundary to
  create/fill it before promotion.

2026-05-31 readback check:

- The source row exists in `race-sheets/PDV_RaceContent_Manifest.md`.
- `PDV_Bless_Khajiit_Lunar_T1` now reads back from
  `PlayerDevotion_Framework.esp` as a pilot-provisional `SPEL`.
- `PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen` and
  `PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist` now read back as
  pilot-provisional `MGEF` records.
- Both effect entries are gated by `GetCurrentTime >= 19 OR <= 7`. The source
  row says "At night" so text matches the implemented condition.
- The pilot remains grant-unwired. It proves record/readback/text promotion, not
  full Khajiit reward distribution or balance.

Implementation helper:

```powershell
dotnet run --project .\tools\pdv-phase20-cat6-author\PdvPhase20Cat6Author.csproj -- --dry-run --create-missing
dotnet run --project .\tools\pdv-phase20-cat6-author\PdvPhase20Cat6Author.csproj -- --create-missing
dotnet run --project .\tools\pdv-phase20-cat6-author\PdvPhase20Cat6Author.csproj -- --check
```

### Candidate B: `PDV_Msg_Khajiit_Survey_Broad`

Source: `race-sheets/PDV_RaceContent_Manifest.md`, Khajiit Survey Devotion row.

Surface: status `MESG` shown through Survey Devotion or MCM Player page.

Why it fits:

- Non-dialogue.
- Uses the already important Survey/status legibility lane.
- Proves player-facing status clarity, not just passive tooltip text.

Risk:

- More code-coupled than a spell description. It should wait if Khajiit Survey
  routing is not ready to display that exact message.

### Candidate C: `PDV_Bless_Bosmer_Exchange_T1`

Source: `race-sheets/PDV_RaceContent_Manifest.md`, Bosmer blessing
description row.

Surface: passive `SPEL` description.

Why it fits:

- Bosmer path records and runtime proof exist.
- The Exchange path is less likely to collide with the Old Contract proof lane.
- It stays far from dialogue and Daedric stigma.

Risk:

- Phase 9 helper scope may not own final string promotion for this specific
  spell description; confirm the write boundary before use.

2026-05-31 readback check:

- The source row exists in `race-sheets/PDV_RaceContent_Manifest.md`.
- `PDV_Bless_Bosmer_Exchange_T1` does not currently read back from
  `PlayerDevotion_Framework.esp` as an EditorID.
- This fallback also needs a target-record owner before CAT-6 promotion.

### Candidate D: `PDV_Bless_Altmer_Magnus_T3`

Source: `race-sheets/PDV_RaceContent_Manifest.md`, Altmer blessing
description row.

Surface: passive `SPEL` description.

Why it fits:

- Altmer is the active scaling spine.
- Magnus is a non-Auri-El focus, so it avoids simply re-proving the foundation
  deity.

Risk:

- Do not use first unless the Magnus focus reward record and display path exist.
  CAT-6 should follow the owning subsystem, not create pressure to overbuild it.

## 9. First Pilot Recommendation

Ratified first pilot: start with `PDV_Bless_Khajiit_Lunar_T1`.

It is the best first CAT-6 candidate because it is a passive, player-visible,
non-dialogue surface tied to the first contrast race. It does not depend on
Daedric CAT-4 decisions, does not require generated dialogue, and can be proven
through record readback plus Active Effects display if the target spell exists.
Lore cross-review keeps it as the first pilot because the Lunar Lattice,
road-home, moon, and caravan identity are the Khajiit contrast lane's strongest
source-backed surface. Do not broaden this pilot into moon-sugar, generic
theft, generic night-stealth, or generic dragon-kill copy.

Ratified fallback: if the Khajiit spell record does not exist or cannot be
safely filled in a narrow pass, fall back to `PDV_Bless_Bosmer_Exchange_T1`.
Do not fall forward into dialogue or Daedric stigma rows just to keep momentum.
The Bosmer fallback remains valid because Exchange/Z'en debt, proper return,
and Bandit Road/Baan Dar reversal are source-backed non-dialogue surfaces.

Current implementation status: the Khajiit first candidate now has a live
pilot-provisional `SPEL` plus two live pilot-provisional `MGEF` records in the
framework ESP, created by the narrow CAT-6 helper. The Bosmer fallback still has
a source row but no live target `SPEL`. This state is mirrored in
`PDV_Phase20_NoInGameProof_Gates.json`, described by
`PDV_CAT6PromotionPilot.manifest.json`, and checked by
`--strict-phase20-race-costing`.

## 10. Interaction With Pre-Beta Race Scaling

This pilot supports pre-beta race scaling but does not replace it.

Pre-beta race scaling answers whether a race has real hooks, rejected-hook
protection, Survey/status clarity, final placement, stack/ceiling visibility,
and normal-session feel. CAT-6 answers whether ratified text can safely move
from manifest to shipped records and handbooks.

Use the CAT-6 pilot to prove one text-promotion lane while Altmer, Khajiit, and
Argonian scaling packets define gameplay feel. Do not promote many race strings
just because the first passive tooltip works. Each broad promotion wave still
needs the owning race gate to exist.

## 11. Interaction With CAT-4 Daedric Work

CAT-4 Daedric expansion should not use this first pilot for broad Prince
promotion.

The first CAT-6 pilot intentionally avoids Daedric stigma and curse-access
rows. D-15..D-18 now lock the stigma model, Hircine/Molag Bal curse-access
templates, Prince authoring order, and per-Prince content-ready bar. A second
CAT-6 pilot can promote one Daedric non-dialogue row against those locks,
preferably a `SPEL` boon or price description before stigma band feedback. Only
after that should Daedric stigma/status rows move in bulk.
