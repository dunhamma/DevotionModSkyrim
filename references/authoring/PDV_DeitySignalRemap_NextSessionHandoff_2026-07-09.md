# PDV Deity Signal Remap - Next Session Handoff - 2026-07-09

## Purpose

Continue the deity signal remap after the Syrabane broad quest-row tranche. The
next session should do a deliberate, deity-by-deity pass over both major signal
surfaces:

- quest-reaction matrix rows for questline, branch, faction, mercy, betrayal,
  occult, oath, death-duty, nature, work, and anti-Daedric outcomes
- day-to-day likes/dislikes rows for repeatable or semi-repeatable behavior

The goal is not numeric equality. The goal is that every live deity has enough
clear positive and negative evidence to feel present in normal play, without
promoting weak scan-only quest candidates or generic activity spam.

## Current Implemented State

Recent completed tranche:

- `Syrabane` is now visible/reachable in Altmer origin roster and Prisma display
  from the prior display fix.
- `Syrabane` now has 8 quest matrix rows:
  - `MG01 200` positive ward/apprentice lesson
  - `MG03 55` positive Orthorn apprentice rescue
  - `MG05 200` positive Winterhold magical containment
  - `MG08 200` positive Eye crisis protection echo
  - `DA01 110` negative corrupt soul-binding
  - `DA04 100` negative reckless Daedric blood/forbidden knowledge
  - `DA13 102` positive Peryite altar-destroy plague warding
  - `DA16 200` positive Skull of Corruption destruction / hostile dream warding
- `FreeformWinterholdCollegeB` / The Missing Apprentices remains explicitly
  unwired. It is thematically ideal but unfinished, with empty stages and no
  reliable playable hook.

Proof completed:

- `node tools/pdv_quest_tranche_merge.mjs`
  - `884` quest cells, `45` deities, `90` quests
- `node tools/pdv_quest_matrix_compile.mjs --check --json`
  - PASS, `884` cells, `118` quest keys, `90` watched quests, `24` faucet acts
- live StorageUtil JSON regenerated at:
  - `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionMatrix.json`
- Syrabane static check:
  - `8` Syrabane rows
  - `0` Missing Apprentices Syrabane rows
  - `DA13 102` present
- `node tools/pdv_deity_signal_remap_adversary_check.mjs`
  - PASS, with expected thin-Hist design warning only
- `node tools/pdv_verify.mjs --json`
  - PASS: `3546 PASS`, `1 WARN`, `68 INFO`
- `node tools/pdv_formal_offer_check.mjs --json`
  - PASS: `260 PASS`, `0 WARN`, `0 FAIL`

Proof boundary:

- Proven: authority/source rows, generated matrix, live JSON generation,
  verifier/static-readback, and formal-offer coverage.
- Not proven: in-game runtime route, Book of Days/Survey/Prisma surfacing, Active
  Effects behavior, save/load stack behavior, and manual feel.

## Current Coverage Snapshot

Quest matrix source: `references/authoring/PDV_QuestReactionMatrix_Full.csv`.
Current low-row or structurally suspicious deities:

| Deity | Quest rows | Notes |
| --- | ---: | --- |
| `The Hist` | 2 | Vanilla quest availability is thin. Prefer Argonian P2/community/non-quest sources; add quest rows only when root, sap, memory, people, communal survival, or Void posture is exact. |
| `Namira` | 2 | May be acceptable if Prince quest and faucet paths carry her, but needs check for reject/embrace counterweights. |
| `Sanguine` | 2 | May be acceptable if Prince quest and faucet paths carry him, but check revel/excess rows and non-generic alcohol boundaries. |
| `Vaermina` | 4 | Core Waking Nightmare exists; check dream/memory/Skull branch counterweights. |
| `Peryite` | 6 | Thin but The Only Cure plus disease/pestilence can carry him if exact. |
| `Y'ffre` | 7 | Needs targeted Green Way/Bosmer/Breton nature-law pass; no generic wilderness spam. |
| `Sheogorath` | 8 | Low but Prince-specific; add only exact madness/restoration/chaos outcomes. |
| `Syrabane` | 8 | Newly fixed. Next work is in-game smoke and possible future defensive-text/ward route, not immediate broadening. |
| `Zenithar` | 10 | Needs civic/work/trade fanout review, especially Imperial/Breton/Divine rows. |

Quest matrix zero-negative deities to review, not automatically fix:

`Hermaeus Mora`, `Talos`, `Boethiah`, `Tsun`, `HoonDing`, `Nocturnal`,
`Mephala`, `Rajhin`, `Clavicus Vile`, `Sanguine`, `Sithis`.

Some of these can remain positive-only if the theology is served by stigma,
stance, or rival rows elsewhere, but the next session should explicitly justify
each one.

Likes/dislikes source: `references/authoring/PDV_DeityLikesDislikes.csv`.
Current state:

- `340` rows across `32` actors.
- No actor currently has zero dislikes.
- No actor currently has fewer than 8 likes/dislikes rows.
- Important: CSV edits alone are inert until codegen output is folded into
  `PDV__ManagerQuest.psc`, old rows are cleared in `ClearRowsForDeity`, and
  `LIKES_DISLIKES_VERSION` is bumped.

Lowest likes/dislikes counts:

| Actor | Rows |
| --- | ---: |
| `Leki` | 8 |
| `Arkay` | 9 |
| `Baan Dar` | 9 |
| `Stuhn` | 9 |
| `Talos` | 9 |
| `Tu'whacca` | 9 |
| `alkosh` | 10 |
| `auri-el` | 10 |
| `Dibella` | 10 |
| `HoonDing` | 10 |
| `khenarthi` | 10 |
| `kyne` | 10 |
| `Mephala` | 10 |
| `rajhin` | 10 |

## Next Session Work Order

### 1. Establish Authority And Diff Scope

Start with a clean truth pass:

```powershell
git status --short
node tools/pdv_quest_matrix_compile.mjs --check --json
node tools/pdv_deity_signal_remap_adversary_check.mjs
```

Read these before deciding rows:

- `references/authoring/PDV_DeitySignalRemap_DivergenceLedger_2026-07-08.md`
- `references/authoring/PDV_DeitySignalRemap_WiringGapDeepDive_2026-07-09.md`
- `references/authoring/PDV_QuestReactionMatrix.md`
- `references/authoring/PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv`
- `references/authoring/PDV_DeityLikesDislikes.csv`
- `references/authoring/PDV_Phase20_QuestStageExclusionAudit.md`
- `references/authoring/PDV_Phase20_SourceCurationDossier.md`

Preserve the current pattern:

- edit source tranches, not just generated `Full.csv`
- re-run `tools/pdv_quest_tranche_merge.mjs`
- compile/check before writing runtime JSON
- keep exact-stage candidates out unless readback supports the stage and outcome

### 2. Quest Matrix Big Pass

Do this deity-by-deity, not race-by-race first. Race stance and origin filtering
already decide whether a row matters to the player. The pass should ask:

- Does this deity have at least one strong positive quest family?
- Does this deity have at least one meaningful dislike/failure/hostile branch,
  or a documented reason to remain positive-only?
- Are rows tied to exact quest outcomes rather than generic membership,
  ordinary progress, city presence, shrine proximity, or generic combat?
- Are duplicate and mutually exclusive branches handled cleanly?
- Does the row use existing act-tags unless a new tag is truly needed?

Priority quest-row audits:

1. `The Hist`
   - Add only exact Argonian-relevant rows for communal survival, root/sap/memory,
     Hist-people duty, or Sithis/Void posture.
   - Avoid generic nature restoration or swamp-adjacent rows.
2. `Y'ffre`
   - Review `T03`, `DA05`, Eldergleam/Nettlebane, hunt-law, Green Way, Bosmer
     story/covenant, and Breton Green Way proxy routes.
   - Route Kynareth-proxy Green Way items to Y'ffre where locked.
3. `Zenithar` / `Z'en`
   - Review work, honest labor, trade, repayment, mine/farm/craft/community
     restoration, and exploitation/dispossession dislikes.
4. Thin Princes: `Namira`, `Sanguine`, `Vaermina`, `Peryite`, `Sheogorath`,
   `Clavicus Vile`
   - Add exact Prince-owned quest branches and clearly hostile counterbranches.
   - Do not balance counts by adding generic indulgence/madness/deal rows.
5. Zero-negative quest deities:
   - `Hermaeus Mora`, `Talos`, `Boethiah`, `Tsun`, `HoonDing`, `Nocturnal`,
     `Mephala`, `Rajhin`, `Clavicus Vile`, `Sanguine`, `Sithis`
   - Either add real negative branches or document why the deity is intentionally
     positive-only in quest matrix and relies on stigma/likes-dislikes/stance.
6. Shared Divines:
   - Recheck Akatosh oath/order/covenant, Arkay death duty, Stendarr mercy/law,
     Mara hearth/family, Dibella beauty/social repair, Kynareth/Kyne split,
     Julianos/Magnus/Xarxes/Syrabane boundaries.

Recommended source file for new rows:

- Continue using `PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv` for
  remap-closeout rows unless a new tranche is clearer.

Generated file:

- `PDV_QuestReactionMatrix_Full.csv` is generated. Do not hand-edit it as the
  only source of truth.

### 3. Likes/Dislikes Big Pass

Do a second pass over `PDV_DeityLikesDislikes.csv` after the quest-matrix audit.
This is where repeatable behavior belongs:

- daily practice
- murder/mercy patterns
- theft style and betrayal
- worship/shrine/prayer boundaries
- crafting/work/commerce
- hunting/nature
- death-duty and necromancy
- charity/family/hearth
- Daedric taboo and faction-posture behaviors

Rules:

- Keep CSV row names and event IDs tied to existing dispatch surfaces.
- Do not invent an event ID unless the event router can actually dispatch it.
- Prefer capped small/medium repeatables over uncapped generic gains.
- For new actors or removed rows, update `ClearRowsForDeity` and bump
  `LIKES_DISLIKES_VERSION`.
- Run `node tools/pdv_likesdislikes_gen.mjs` and fold the generated
  `LoadRowsForDeity` body into `PDV__ManagerQuest.psc`.
- Compile touched Papyrus after codegen insertion.

Priority likes/dislikes actors:

- `Leki`, `Stuhn`, `Talos`, `Tu'whacca`, `Baan Dar`, `Rajhin`, `khenarthi`,
  `alkosh`, `auri-el`, `Dibella`, `HoonDing`, `kyne`, `Mephala`
- Check whether live/deferred actors from the remap need likes/dislikes support
  or should stay quest/reward-only for now:
  - `Syrabane`
  - `Trinimac`
  - future/proof-gated `Phynaster`

Important implementation note:

`PDV_DeityLikesDislikes.csv` currently has 32 actors. The quest matrix has 45
deity names because Daedric Princes and some matrix-only names are represented
there. Do not blindly force one-to-one parity. Decide whether each missing actor
needs day-to-day likes/dislikes or is intentionally quest/Daedric-system-only.

### 4. Verification Gates

After quest rows:

```powershell
node tools/pdv_quest_tranche_merge.mjs
node tools/pdv_quest_matrix_compile.mjs --check --json
node tools/pdv_quest_matrix_compile.mjs --json
node tools/pdv_deity_signal_remap_adversary_check.mjs
node tools/pdv_verify.mjs --json
node tools/pdv_formal_offer_check.mjs --json
```

After likes/dislikes codegen:

```powershell
node tools/pdv_likesdislikes_gen.mjs
node tools/pdv_compile.mjs --script PDV__ManagerQuest
node tools/pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json
node tools/pdv_deity_signal_remap_adversary_check.mjs
node tools/pdv_verify.mjs --json
```

If Papyrus source changes are broader than generated likes/dislikes insertion,
run the full compile wrapper:

```powershell
node tools/pdv_compile.mjs
```

No Papyrus warnings should be accepted for this tranche.

### 5. In-Game Smoke Still Required

The next implementation pass should not claim player-ready or beta-feel complete
until runtime/manual smoke proves visible behavior. Minimum smoke:

- Altmer Syrabane:
  - `setstage MG01 200` positive quest reaction
  - `setstage DA01 110` negative quest reaction
  - one broad optional row such as `DA13 102` if that QE route is accessible in
    the current runtime/debug surface
- One low-row deity added in the next pass, preferably `Y'ffre`, `The Hist`, or
  a thin Prince.
- Confirm:
  - Book of Days records the event
  - Survey/status reflects the correct lane/deity
  - Prisma/notification text is coherent
  - Active Effects/reward behavior updates when applicable
  - no duplicate or stale effect stack remains after save/load
  - wrong-origin or unreachable deity routes stay silent where expected

## Open Risks / Watch Points

- Generated-file drift: always edit tranches and regenerate `Full.csv`.
- Likes/dislikes drift: CSV-only edits do nothing until codegen is pasted into
  manager source, clear rows are updated, and version is bumped.
- Missing Apprentices: do not wire unless a real hook is added; current vanilla
  content has empty stages and no reliable playable completion.
- `DA04` Syrabane negative must stay framed as reckless Daedric/blood
  exploitation, not a blanket dislike of study.
- `DA13 102` is a custom QE route. It is matrix-supported now, but runtime smoke
  should prove the route if it becomes part of a representative test path.
- Count parity is not the goal. The goal is coherent, hookable, source-backed
  signal presence.

## Suggested Next Prompt

Use this prompt to continue:

> Continue from `references/authoring/PDV_DeitySignalRemap_NextSessionHandoff_2026-07-09.md`. First audit quest matrix and likes/dislikes coverage deity-by-deity from live CSVs. Propose a row plan for low-row and zero-negative deities, with exact quest/stage evidence and rejected generic contexts. After approval, implement by editing source tranches and `PDV_DeityLikesDislikes.csv`, regenerate `Full.csv` and StorageUtil JSON, fold likes/dislikes codegen into `PDV__ManagerQuest.psc`, compile, and run the listed gates. Keep proof boundaries explicit and do not claim in-game proof without smoke.
