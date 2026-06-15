# PDV Prisma "Book of Days" -- Build Spec (2026-06-15)

**Status:** BUILT on live 2026-06-15 (machine-proven: compile 0/0, verify FAIL=0,
`pdv_prisma_ui_audit` PASS 13). In-game display test pending (see below). Built via 3 efficient
agents (sonnet Papyrus + JS, haiku audit). Post-build fixes: hotkey shows via overlay only (the
audit blanket-bans `OpenDevotionPanel` outside the bridge); journal JS deployed repo->live
`D:\...\Devotion\PrismaUI\views\Devotion\`; audit's mode-literal check looks in the builder.
KEY UNVERIFIED: whether `SendOverlayJson` alone renders+closes the modal (the medallion, the only
precedent, was never wired to an opener). Optional polish: entry `tone` is the raw toneKey
(tier.reach/...), not a good/warning/neutral color class, so entries may render uncolored.
**Why:** a first-party, dependency-free devotion journal that works in EVERY load order
(Anvil + Authoria/ARR), as the alternative to the Dynamic Book Framework (DBF) journal
channel -- DBF is absent from Authoria and adding it needs author coordination. Prisma is
Devotion's own bundled UI shell, so a Prisma journal needs no external framework. This is
"option 3" from the 2026-06-15 journal-channel discussion. Trade accepted by the user: the
journal becomes a player-OPENED Prisma surface (panel/overlay), not an in-world DBF book.
Boundary law still holds ([[PDV_PrismaIntegrationBoundary]]): "P2 proves state, Prisma
surfaces state" -- the manager stays authoritative; Prisma only renders.

## Locked decisions (this session)

- **Data depth:** RICH dated ring buffer, ~20-30 entries, each carrying line + in-game day +
  tone + deity-symbol (not the flat 8-entry text-only `PDV.RecentDevotionEvents`).
- **Open trigger:** configurable HOTKEY (open anywhere) -- needs key registration +
  input-safety handling.
- **Surface posture:** default-off, player-owned modal (mirrors the medallion roster);
  never auto-pushed by a gameplay event (boundary + audit requirement).

## Existing leverage (what is already there -- ~80% built)

UI app: `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/` (`app.js`, `index.html`, css)
- `handlePayload` (~app.js:1324-1350): additive key-presence dispatch -- already branches on
  `payload.startup` / `payload.medallion` and early-returns on `mode`. A `journal` branch
  slots in identically. Entry points: `window.ReceivePDVJson(str)` / `ReceivePDVOverlayJson(str)`.
- `renderList(node, items, emptyMessage)` (~1142-1179): already renders structured entries
  (title / text / tone / symbol). A journal log is one full-height `renderList()` call.
- `createSymbol("journal")` (~60-64): the open-book SVG already exists (header icon).
- Reusable CSS (no new CSS needed): `.startup-card` (scroll container), `.medallion-section`
  + `.medallion-section h4` (date dividers), `.list-item/.list-symbol/.list-content` (tone-aware).

Data hook: live `PDV_DiegeticDirector.psc`
- `EmitJournal(Int deityIndex, String toneKey)` (~144-160) fires on every transition and
  resolves a per-race line via `ResolveJournalLine()` (~317-335). TODAY it only stores the
  latest line -- keys `PDV.Diegetic.Journal.LastLine` (str), `PDV.Diegetic.Journal.PendingCount`
  (int), `PDV.Diegetic.Journal.JournalFallback="DBFPending"`. **No history buffer exists yet.**
- Flat fallback already persisted: `PDV.RecentDevotionEvents` (manager `RecordRecentDevotionEvent`
  / `GetRecentDevotionEventsText` / `AppendRecentDevotionEvents`, ~12497-12532; string list, max 8,
  text-only). We are NOT using this as the source (decision: richer buffer).

Send pattern: live `PDV__ManagerQuest.psc`
- Medallion modal is the template: `SendPrismaMedallionPayload()` builds JSON via manual concat
  with `MedallionSection()` / `MedallionEntry()` helpers + `JsonSafeString()` / `BoolToJson()`,
  guarded by `PDV_PrismaBridge.IsAvailable()` + `AllowPrismaBlockingSurfaces`, sent via
  `SendOverlayJson()`. Properties `AutoPushPrismaPanel` + `AllowPrismaBlockingSurfaces` default
  `False Auto`. `SendJson()` is the focused-panel path (PushDevotionPanel only, exactly one call).

## The build -- three layers + hotkey

### 1. Data (Papyrus, director) -- the one real new piece
Extend `EmitJournal` to APPEND to a ring buffer instead of only setting `LastLine`. Suggested keys
(StorageUtil lists, capped ~24, FIFO shift like the recent-events buffer):
- `PDV.Diegetic.Journal.Lines` (string list) -- the resolved line text
- `PDV.Diegetic.Journal.Days` (int list) -- `Utility.GetCurrentGameTime() as Int` (day stamp)
- `PDV.Diegetic.Journal.Tones` (string list) -- the tone key (reverent/dread/release/absence/...)
- `PDV.Diegetic.Journal.Symbols` (string list) -- deity symbol id (from the deity by index)
Keep `LastLine`/`PendingCount` as-is (harmless). EmitJournal already has line+tone+deityIndex in
hand, so this is ~15 lines. Optional: append a daily dawn-digest entry at ProcessDawn for cadence.

### 2. Send (Papyrus, manager)
- `String Function BuildJournalPayloadJson()` -- read the ring buffer, assemble
  `{"mode":"journal","journal":{"title":"Book of Days","summary":"...","entries":[ {date,day,
  symbol,tone,title,text}, ... ]}}` via the same `JsonSafeString` concat style as the medallion
  builder. Map `day` -> a fiction date string ("Heartfire 12") via a small day->date helper.
- `Function SendPrismaJournalPayload()` -- guard `if !PDV_PrismaBridge.IsAvailable() return`,
  guard `if !AllowPrismaBlockingSurfaces return` (player-owned modal), then
  `PDV_PrismaBridge.SendOverlayJson(BuildJournalPayloadJson())`. Mirror the medallion fn shape so
  the audit pattern matches (literal `\"mode\":\"journal\"` present, blocking-surface guard present).

### 3. Open trigger (Papyrus) -- HOTKEY
- Register a configurable key (MCM key-map option writing a StorageUtil key) and handle
  `OnKeyDown(keyCode)` on a player-alias or the MCM script. On press: input-safety gate
  (skip if `UI.IsMenuOpen("...")` / in a menu / mid-MessageBox), then
  `SendPrismaJournalPayload()` + `PDV_PrismaBridge.OpenDevotionPanel()` (or overlay-only if we
  want non-focusing). Default the key unbound or to a sensible default; let MCM rebind.
- INPUT-SAFETY is the main care item (boundary doc requires it for any opened surface): no input
  trap, no overlap with CK MessageBoxes/menus, works across startup/load/combat.

### 4. UI (app.js + index.html)
- `index.html`: add `<section id="pdv-journal-modal">` cloning the `.startup-modal` structure
  (reuse `.startup-card/.startup-header/.startup-body`).
- `app.js`: add `journal: document.getElementById("pdv-journal-modal")` to `nodes`; write
  `renderJournal(journal)` calling `renderList()` over `journal.entries`, optionally grouped by
  date with `.medallion-section` + `.medallion-section h4` headers; add to `handlePayload`:
  `if (payload.journal) { renderJournal(payload.journal); }` and add `|| payload.mode === "journal"`
  to the early-return guard. No new CSS.

## Payload contract

```json
{ "mode": "journal",
  "journal": {
    "title": "Book of Days",
    "summary": "A record of devotional acts since the path began.",
    "entries": [
      { "date": "Heartfire 12", "day": 47, "symbol": "kyne", "tone": "reverent",
        "title": "Clean hunt remembered", "text": "Kyne took notice." }
    ] } }
```

## Audit / compat constraints (`tools/pdv_prisma_ui_audit.mjs`)

- `AllowPrismaBlockingSurfaces` must stay `False Auto` (it is); the journal send fn must carry the
  `if !AllowPrismaBlockingSurfaces` guard + the literal `\"mode\":\"journal\"` string.
- **Caller nuance:** the audit asserts the medallion/startup payload fns have ZERO external callers
  (no gameplay auto-push). The journal is hotkey-opened = a PLAYER-OWNED caller, which honors the
  *spirit* (not a gameplay-event auto-push) but is still a caller. The audit doesn't yet name a
  journal fn, so it won't fail by default -- but extend the audit with a parallel journal check
  that ALLOWS exactly one player-input caller (the hotkey handler), so the rule stays meaningful.
- New symbols (if any beyond `journal`) must be added to the app.js symbol gallery + display-name map.

## Effort / risk

- Papyrus ~80 lines (buffer + builder + send + hotkey/MCM key), JS ~30 lines + one HTML section,
  no CSS, no ESP records, no new frameworks. Compile + `pdv_prisma_ui_audit` + `pdv_verify`.
- Risk: LOW-MED. Main care = hotkey input-safety proof; everything else mirrors the shipped
  medallion modal. Works in Anvil + Authoria (Prisma ships with Devotion).

## Open items / proof

1. Final buffer cap (24 proposed) and whether to add the dawn-digest daily entry.
2. Day->date fiction formatting helper (in-game day -> "Heartfire 12").
3. Extend `pdv_prisma_ui_audit.mjs` for the journal fn (allow one player-input caller).
4. Input-safety proof for the hotkey (menus/combat/load).
5. Deploy to ARR ("Devotion - PlayerDevotion Local Test") to play-test in Authoria.

## Turnkey reference

- App: `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/{app.js,index.html}`
- Director: live `PDV_DiegeticDirector.psc` `EmitJournal` ~144, `ResolveJournalLine` ~317
- Manager: live `PDV__ManagerQuest.psc` medallion send pattern (`SendPrismaMedallionPayload`,
  `MedallionSection`, `MedallionEntry`, `JsonSafeString`, `BoolToJson`), recent-events ~12497
- Bridge API: `PDV_PrismaBridge.{IsAvailable, OpenDevotionPanel, SendJson, SendOverlayJson}`
- Audit: `tools/pdv_prisma_ui_audit.mjs`
