# Session Handoff — Prisma Surfacing Pass
**Date:** 2026-06-04  
**Branch:** `main` (all work merged directly)  
**Script snapshot:** `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc`  
**Live source:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`

---

## What this session accomplished

This session completed the Prisma UI surfacing architecture for PlayerDevotion. The goal was UX continuity: every way a player earns or loses devotion should surface through the same typed-event funnel rather than silent StorageUtil writes or one-off literal toasts.

### Commits (all on `main`)
| Hash | What |
|---|---|
| `a85fe95` | Wired Prisma main panel (`PushDevotionPanel`), added `SendPrismaEventToast`, converted 5 templated toast sites to events, warmed startup copy for all 10 races |
| `c1b4bf7` | Wired `shift` and `daedric` events for substrate/state-track transitions and Hircine hunt rites; authored Tier-0 glyph SVG data (`yffre`, `zen`, `baan-dar`) |
| `dd7871c` | Panel quasi-patron for all 10 races — non-deity races now have a named title, symbol, mode label, and acts/rites entries derived from their substrate |

The `curse` event was on branch `claude/prisma-curse-event` (also pushed to remote); the branch was not merged but the same code made it into `main` via the commit above — they are equivalent.

---

## Architecture added this session

### Prisma event vocabulary (Papyrus → UI)

All events go through `PDV_PrismaBridge.SendOverlayJson(j)` (toasts) or `PDV_PrismaBridge.SendJson(j)` (panel). The UI owns the voice; Papyrus provides typed data.

| event | sender function | payload fields | fires at |
|---|---|---|---|
| `favor` | `SendPrismaEventToast("favor", deity, context, "", "")` | event, deity, symbol, context | `AwardPietyInternal` (patron gain), `SendContextualFavorToast` (contextual favor) |
| `dawn` | `SendPrismaEventToast("dawn", None, "", "", "")` | event | `RunDawnNotify` |
| `tier` | `SendPrismaEventToast("tier", deity, "", tierLabel, "")` | event, deity, symbol, tierLabel | `RecomputeTier` on increase |
| `neglect` | `SendPrismaEventToast("neglect", deity, "", "", "")` | event, deity, symbol | `RunDawnApplySpellAndNeglectLayers` on patron transition into neglect |
| `rivalry` | `SendPrismaEventToast("rivalry", sourceDeity, "", "", rivalName)` | event, deity, symbol, rival | `ApplyRivalryPenalties` once per pass |
| `curse` | `SendPrismaCurseToast(oldState, newState)` | event, phase, curse, symbol, context, deity | `HandleCurseStateTransition` |
| `shift` | `SendPrismaShiftToast(mode, context, symbol)` | event, shiftMode, symbol, context, deity | Khajiit focus, Argonian Hist, Orc life-mode, Redguard sect, Bosmer path settle |
| `daedric` | `SendPrismaDaedricToast(prince, phase, context, symbol)` | event, prince, phase, symbol, context | `HandleHircineHuntRite` (boon only, for now) |

### Panel refresh architecture
- `RequestPanelRefresh()` sets `_panelDirty = True`
- `OnUpdate()` flushes via `PushDevotionPanel()` when bridge available
- Panel open is native/SKSE — no Papyrus hook; keeping the last `SendJson` payload current is the approach
- `PushDevotionPanel()` calls `GetPanelQuasiPatronName/Symbol/TierLabel(originRace)` for the 7 races without a scoring `_activeDeity`

### Quasi-patron panel identity (all 10 races)
When `_activeDeity` is null, the panel derives its identity from the race substrate:

| Race | title | symbol | tierLabel source |
|---|---|---|---|
| Nord | "Nord Worship" | `kyne` | `GetNordDevotionModeLabel()` |
| Imperial | "Nine Divines" | `akatosh` | `GetImperialConcordatLabel()` |
| Breton | "Breton Tradition" | `journal` | `GetBretonTraditionLabel()` |
| Dunmer | "House Ancestors" | `ancestor` | "Ancestor layer" |
| Altmer | "Auri-El Foundation" | `auri-el` | `GetAltmerCrisisStateLabel()` |
| Khajiit (no focus) | "Lunar Lattice" | `lunar` | "Lunar Lattice" |
| Khajiit (focused) | focus deity name | focus symbol | "Focused: &lt;deity&gt;" |
| Bosmer (no patron) | "Path Unsettled" | `yffre` | `GetBosmerPathLabel()` |
| Argonian | "The Hist" | `hist` | "Hist: &lt;posture&gt;" |
| Orc | "Malacath" | `malacath` | `GetOrcLifeModeLabel()` |
| Redguard | "Yokudan Path" | `journal` | `GetRedguardSectLabel()` |

Symbols marked with no glyph yet fall back to `journal` non-breakingly.

---

## What's next (ordered)

### 1. UI design pass — apply handoff docs to `app.js` (frozen file, needs design agent)

Four ready-to-apply handoff documents live in `handoff/`:

| Doc | What it adds to `app.js` |
|---|---|
| `PrismaGlyph_Tier0_SVGData.md` | `symbolSpecs` entries for `yffre`, `zen`, `baan-dar` (live gap — Bosmer patrons render journal today) |
| `PrismaCurseEvent_UIHandoff.md` | `eventLanguage.curse` block, `normalizeToastPayload` additions, demo entries |
| `PrismaShiftEvent_UIHandoff.md` | `eventLanguage.shift` block, demo entries |
| `PrismaDaedricEvent_UIHandoff.md` | `eventLanguage.daedric` block, demo entries |
| `PrismaGlyph_DesignHandoff.md` | Full glyph priority list (Tier 0/1/2/3) for the wider symbol set |

**The `app.js` in the live mod (`D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js`) is the target.** The repo copy under `native/DevotionPrismaBridge/mod/PrismaUI/...` should be kept in sync.

Each handoff doc is self-contained with exact code snippets — a design-focused agent can apply them without needing the broader session context.

### 2. Daedric emit completions (Papyrus, `PDV__ManagerQuest.psc` only)

Hircine `boon` fires at `HandleHircineHuntRite`. Missing phases:
- **`price`** — emit when stigma crosses a meaningful threshold (add comparison inside `RecordHuntRiteScaled` or a dawn check)
- **`lapse`** — emit at `DebugRenounceHircinePath` → `PDV_HircinePath.RenouncePath("mcm")` (and any future runtime renounce site)
- **`residue`** — emit at `BeginNordResidueRecovery` (already identified, line ~91 of `PDV_DaedricPath_Hircine.psc`)

These are Papyrus-only. The `daedric` UI template is already in the handoff doc; no `app.js` changes needed.

### 3. Remaining 15 Daedric Princes (Papyrus scoring + emit)

Currently only Hircine is path-wired. The other 15 Skyrim-present Princes are content-ready in prose (matrix slice 20C in `PDV_DeityCoverageMatrix.json`) but have no runtime scoring, emit, or glyph. Priority order from the audit:

1. **Azura / Boethiah / Mephala** — Dunmer Reclamation overlap; highest racial salience
2. **Malacath** — Orc `malacath` symbol already in quasi-patron; scoring would promote it from label to live meter
3. **Meridia** — undead-cleanse hook exists; bounded scope
4. **Molag Bal** — curse-access template from Hircine applies directly
5. Remaining 10 in any order

Each Prince needs: a `PDV_DaedricPath_X` script (or reuse `PDV_DaedricPathBase`), wiring onto `PDV__ManagerQuest`, a `GetPrismaSymbolForDeity` branch, and a `SendPrismaDaedricToast` call at the scoring site.

### 4. Glyph Tier 1 — Prince symbols (16 glyphs)

Blocked on design pass. See `PrismaGlyph_DesignHandoff.md` Tier 1 table for the full list and motif notes. Priority: `hircine` and `malacath` first (reused in Tier 3 concept marks too).

### 5. Dunmer panel depth

Dunmer's quasi-patron label is "Ancestor layer" (static). Unlike Argonian which has a posture track, Dunmer ancestor depth is a cumulative substrate, not a named state. Options for next session:
- Surface the raw substrate piety-equivalent as a progress note in acts (if `PDV_DunmerAncestorSubstrate` exposes a readable value)
- Add Reclamation deity toasts (`azura` / `boethiah` / `mephala`) once Prince scoring lands — these would be the richer surface for Dunmer

---

## Key constraints to carry forward

- **`app.js`, `index.html`, `styles.css` are frozen** — edit only via explicit handoff docs, never directly in a session covering Papyrus work
- **Do not touch `PDV_PrismaBridge` or the `ReceivePDVJson` / `ReceivePDVOverlayJson` entry points**
- **JSON payload shape is fixed** — add fields freely, never remove or rename existing ones
- **`AGENTS.md` is Codex's canonical context** — don't overwrite it; it's been updated by Codex separately this session
- **Script edits go to the live mod path** (`D:\Wabbajack\...`); the `scratch/p2-toast-panel-fix/` snapshot is the repo copy
- **Branch discipline:** create a feature branch before any Papyrus edits; the session accidentally committed to `main` — the user is aware and OK with it this time

---

## File map for this work

| File | Role |
|---|---|
| `D:\Wabbajack\...\Scripts\Source\PDV__ManagerQuest.psc` | Live source — all changes this session |
| `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc` | Repo snapshot (byte-identical to live) |
| `handoff/PrismaGlyph_DesignHandoff.md` | Full glyph design spec |
| `handoff/PrismaGlyph_Tier0_SVGData.md` | SVG paths for `yffre`, `zen`, `baan-dar` |
| `handoff/PrismaCurseEvent_UIHandoff.md` | `app.js` drop-in for `curse` event |
| `handoff/PrismaShiftEvent_UIHandoff.md` | `app.js` drop-in for `shift` event |
| `handoff/PrismaDaedricEvent_UIHandoff.md` | `app.js` drop-in for `daedric` event |
| `references/authoring/PDV_PietySurfacingAudit.md` | Full audit + phasing plan |
| `references/authoring/PDV_DeityCoverageMatrix.json` | Roster authority for Princes |
