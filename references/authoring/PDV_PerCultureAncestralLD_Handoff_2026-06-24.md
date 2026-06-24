# Per-Culture Ancestral LD Category (open-item 6d / gap #1) — Codex Handoff (2026-06-24)

## Problem
Ancestor day-to-day signals route through the shared per-deity LD table
(`PDV_DeityLikesDislikes.csv`, keyed by `actor`) with **generic verbs** — so a native Nord and
a foreign Shor-worshipper get the identical signal set. There is **no Saxhleel/Yokudan/Orsimer
distinction**, so cultural ancestor behavior is invisible. (The spine *pulse* `SIGNAL_ANCESTOR_SPINE`
is per-deity/culture, but the day-to-day LD layer is not.)

## Design — add an `originGate` column (mirrors the existing `stanceGate`/`conditionTag`)
1. **CSV:** add an `originGate` column to `PDV_DeityLikesDislikes.csv`. Blank = fires for any
   worshipper (today's behavior, unchanged). Set to an origin token (`Argonian`, `Redguard`,
   `Orc`, `Nord`, …) = the row fires **only** for a player of that native origin.
2. **Codegen:** `tools/pdv_likesdislikes_gen.mjs` currently emits `actor[0], eventId[1],
   baseDelta[5]` etc. into `LoadRowsForDeity`. Add the `originGate` column to the emitted row
   metadata (a new per-row field), and **bump `LIKES_DISLIKES_VERSION`** (currently 9) or the
   change is inert (see the likes/dislikes codegen rule). Regen + prove on a new save.
3. **Runtime:** in the row-scoring path, gate an `originGate`-bearing row on the player's origin
   via the existing origin native (`GetPlayerOriginRaceIndex` / `IsRaceNativeForPlayer`). A
   non-native player simply skips that row — they still get the generic (blank-gate) rows, so a
   foreign worshipper's experience is unchanged; the native gets the EXTRA cultural rows.
4. **Content (the cultural distinctiveness):** author per-culture ancestor rows gated to their
   origin — e.g. Saxhleel `tend-the-hist` on `PDV_Deity_Hist`, Yokudan `keep-the-death-duty`
   on `PDV_Deity_Tuwhacca`, Orsimer `uphold-the-code` on `PDV_Deity_Malacath`, Nord
   `honor-the-ancestor-cairn` on `PDV_Deity_Shor`. These are NEW rows, small `baseDelta`,
   daily-capped, distinct verbs — the felt cultural ancestor layer.

## Serialization
Touches `tools/pdv_likesdislikes_gen.mjs` + the manager's `LoadRowsForDeity` → **serializes with
the spine builds** (shared manager). Two clean options:
- **(a)** do the schema change (1-3) as one pass after the spine builds settle, then author the
  per-culture rows (4); OR
- **(b)** fold each race's cultural rows (4) into that race's spine build, with the schema change
  (1-3) landed first as a prerequisite.
Recommend (a): land the `originGate` mechanism once, then author rows incrementally.

## Verify
- `node tools/pdv_likesdislikes_gen.mjs` regen + VERSION bump; `pdv_compile`/`pdv_verify` clean.
- `pdv_signal_e2e_gate` 0 RED; prove on a NEW save that a native gets the cultural row and a
  foreign worshipper does not (origin-gate works).
- No Score dim directly measures this yet; it deepens `text_voice`/felt-culture — note for a
  future Score dim if desired.

## STATUS 2026-06-25 — mechanism DONE; content = deliberate authoring
- **Mechanism is fully built + committed (`ec36725`)** — the handoff was stale. `originGate` column
  + culture aliases (saxhleel/yokudan/orsimer) in `pdv_likesdislikes_gen.mjs`; `WriteLD` writes
  origin-prefixed `.O<n>` keys; `ClearRowsForDeity` clears them; `PDV_DeityBase.ScoreFromTable`
  overlays the origin row gated on `IsRaceNativeForPlayer()` with a DISTINCT anti-farm key
  (`GetOriginGatedEventType` = eventType+10000+origin); `LIKES_DISLIKES_VERSION` = 10, verifier
  `EXPECTED_LIKES_DISLIKES_VERSION` synced. Verified harness-PASS this session.
- **3 cultural rows live:** Hist `tend-the-hist` (334 harvest, Argonian), Malacath `uphold-the-code`
  (330 smith, Orc), Tu'whacca `keep-the-death-duty` (300 kill-undead + ActorTypeUndead, Redguard).
- **Remaining cultural rows = deliberate content (NOT shipped speculatively).** The clean pattern,
  from the 3 examples: pick an ALREADY-EMITTED generic `EVT_*` whose act expresses that culture's
  ancestor devotion, then add a CSV row keyed on it with `originGate` = the native culture +
  `dailyCap` (anti-farm) + an optional `conditionTag`. This is never inert (the event already
  fires) but IS a theme/balance judgment — choose acts that are on-theme and not farmy, and prove
  on a NEW save. Held back from blind authoring because: (a) several races have no clean single
  native-deity + generic-event mapping (multi-focus Dunmer/Bosmer; Green-Pact harvest ban; civic
  acts aren't generic EVT_), and (b) the native-gate proof is play-gated. Recommend a deliberate
  per-race design pass (theme + event + cap + conditionTag) before authoring.
