# PDV UX handoff - 2026-08-25

**Status:** LIVING. Supersedes `PDV_UX_ConsolidationPlan_2026-08-25.md` for day-to-day work
(its Phases 0 and 1 are done). The operating pattern in
`PDV_UX_NextSession_Handoff_2026-08-25.md` still stands and is not restated here.
**Branch:** `fix/2.0-copy-uplift`. **Evidence bucket:** static only - houseCARL ESP readback
plus `live-source` Papyrus. **No runtime observation anywhere in this work.**

---

## 1. Read these three, in this order

1. **The journey board** - `references/authoring/journeys/PDV_Journey_Imperial.json`,
   rendered with `node tools/pdv_journey_render.mjs --race Imperial`. The player's
   experience in order, with the verbatim text at each beat. **Start here** - it is the
   only document that shows what the game actually says.
2. **The atlas** - `references/authoring/PDV_RaceArchitectureAtlas.json`, rendered with
   `node tools/pdv_atlas_render.mjs`. Architecture across all 10 races, plus the
   `implementationAudit.queue` (17 rows) which holds the evidence.
3. **The workbook** - `references/authoring/prose-workbook/PDV_ProseWorkbook.xlsx`. Exact
   owner wording. Sheets `Concordat Writing` and `Offer Writing Worksheet` are live
   drafting surfaces.

GitHub Issues is the work tracker (`dunhamma/DevotionModSkyrim`). The queue holds evidence;
issues hold work. Issues point at their `auditId` rather than restating it.

## 2. Where things live, and why

| Thing | Authority | Generated |
|---|---|---|
| Player journey per race | `references/authoring/journeys/PDV_Journey_<Race>.json` | `generated/PDV_Journey_<Race>.html` (gitignored) |
| Architecture + audit queue | `references/authoring/PDV_RaceArchitectureAtlas.json` | `generated/PDV_RaceArchitectureAtlas.html` (gitignored) |
| Exact player copy | `references/authoring/prose-workbook/PDV_ProseWorkbook.xlsx` | - |
| Outstanding work | GitHub Issues | - |

**Never hand-edit a generated HTML.** Both renderers have a real `--check` gate whose
verdict is its exit code; both were negative-tested (break the data, it exits 1).

The journey gate additionally **rejects any quoted line without a source**. That is
deliberate: the board's whole value is that the words are real, and the failure mode is
paraphrase creeping in.

## 3. Standing rules

- **The owner writes all player-facing copy** (2026-08-24). Model text appears only as
  explicitly marked placeholders carrying the project's `PLACEHOLDER copy` marker. Do not
  offer bulk drafting; supply the writing SUPPORTS instead - target lists, same-deity
  exemplars, voice patterns, character budgets.
- **Claude may write to the ESP** via houseCARL (owner decision 2026-08-25), with readback
  proof in the same session. Codex owns Papyrus wiring where a new trigger is needed.
- **Every route claim is version-qualified** until the source/PEX drift across 26 shared
  scripts is resolved. Say "repo-mirror-derived" in the artifact, not just in chat.
- **A gap must say what KIND it is** - wiring, writing, design, or wiring + writing. This is
  enforced by the journey gate. "Gap" alone hides who fixes it.

## 4. The single most important framing

**PDV is not silent about state changes.** It communicates a great deal through **PULL**
surfaces - Active Effects and the Survey - and that writing is good. Neglect reads "You have
let civic faith lapse. The Divines' ward against sickness thins..." Tier crossings push a
Book of Days line. Blessings name and describe themselves.

What is thin is **PUSH at the moment of transition**. That is a narrower and more answerable
question than "why is it silent", and two earlier claims in this project's docs were wrong
on exactly this point before being corrected.

## 5. Imperial: where the walkthrough stopped

15 beats - 4 built, 8 partial, 3 real gaps. Findings not previously in any queue:

- **Talos climbs in silence.** Talos tier crossings are suppressed entirely while Concordat
  standing is above 50 (`PDV_DevotionLedger.psc:1155-1157` with
  `PDV_OriginRuntime_Imperial.psc:238-248`). A compliant Imperial reaches Champion with
  Talos and is told nothing. Reads as a hole OR as thematically exact - owner ruling needed.
  Issue #104.
- **Five civic families, one line.** A mercy act reports as "public service" (`:367` passes
  one hardcoded string). Issue #103.
- **Two tier vocabularies disagree** on what "Devoted" means. Issue #105.
- **Broad-worship Imperials get no neglect push** - the dawn toast is Nord-gated. #100.
- **No Imperial branch** in `GetCurseContextForRace`. #101.
- **16 Imperial Daedric responses are written and unreachable** - wiring only. #102.

**Concordat is the live thread.** Locked 2026-08-25: Talos offers fail gracefully, no
offer-time rejection, so **state copy is the only channel carrying the cost** - and it
currently carries none. Every Concordat line restates the label ("Under the Concordat, you
are Publicly Compliant.") while the real cost - Talos closed, Stendarr and Arkay blunted,
Talos gain slowed and decay sped via `GainModifyingTrack`/`DecayModifyingTrack` - is stated
nowhere. Owner drafting on the workbook's `Concordat Writing` sheet. Five states, five entry
beats (every transition is an entry into some state, so five covers all ten directions).

**Implementation trap for the Concordat beat:** the track carries a committed state AND a
pending state, and the label deliberately lags the raw value
(`PDV_ReputationTrack.psc:40-67`). Fire on **label commit**, not raw crossing, or it fires
on a standing the player does not have and re-fires as the value oscillates.

## 6. Next race

The journey board is built to repeat: author `PDV_Journey_<Race>.json`, run the same
renderer. The expensive part is **gathering**, not rendering - Imperial took two parallel
agents, one reading the ESP via houseCARL for record text, one reading Papyrus for emitted
strings. That shape is known and repeatable.

Suggested order: Nord (most content, the established pilot), then a substrate race
(Argonian or Khajiit) to stress the format on the harder shape.

## 7. Open owner decisions

1. Talos silence - intended or a hole? (#104) - blocks the Concordat slice's shape.
2. Tier vocabulary - one set or a deliberate split? (#105) - blocks any copy naming a tier.
3. Substrate tier crossings - beat, or is quiet the point?
4. Champion recognition - one shared parameterised transition, or bespoke per race?
5. Redguard offers cover 3 of 7 deities - deliberate or unfinished?
6. Dunmer substrate has no decay function - deliberate or missing?

## 8. What is NOT proven

Nothing here has been observed in game. Every claim is static: Papyrus source, or direct ESP
record readback where stated. "MESG exists" means a declared property with a live show path
or a confirmed record, never that it was seen firing. Runtime, player-surface, save/load and
packaging evidence are all still owed and must be reported separately rather than inferred
from a green static check.
