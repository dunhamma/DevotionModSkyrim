# PDV Redguard Variety Tranche -- Record Manifest (DRAFT)

**Status: DRAFT (no-deploy prep)**
**Created 2026-06-19**
**Provenance:** Drafted from `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` (Redguard "The Far Shores Keep Watch", DESIGN-LOCKED 2026-06-12); the Redguard race sheet `race-sheets/PDV_RaceDesign_Redguard.md` (Variety Tranche section + build-facing hook table + Tu'whacca devotional surface lock); the Redguard rows of `references/authoring/PDV_RaceEffectReviewLedger.md` (Variety Tranche Gate + Race Review Table + Completed Race Rows, Redguard `Pending`); `references/authoring/PDV_BetaTestPacket_Redguard.md` (2026-06-19 live-run findings, Far Shores token behavior, vampire earn-halt GAP); the Bosmer precedent `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json`, `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md`, and `references/authoring/PDV_SessionHandoff_BosmerVarietyLocal.md` (mirrored format); and live-spine reads of `generated/live-devotion-snapshot/2026-06-15-final-polish/Scripts/Source/PDV__ManagerQuest.psc` (the newest in-repo snapshot; the canonical .psc is the untracked live MO2 dir per the repo-source-drift note, so all line refs below are snapshot-relative and must be re-confirmed against live before authoring).

---

> ## PROVISIONAL MAGNITUDES -- DO NOT AUTHOR UNTIL ROW REVIEW
>
> No records are authored. Every magnitude, duration, and percentage in this
> document is **PROVISIONAL** and is blocked behind the Redguard row in
> `references/authoring/PDV_RaceEffectReviewLedger.md` (Race Review Table:
> Redguard = `Pending`). The Variety Tranche Gate locks only the **shapes,
> gates, caps, and fade rules**; it explicitly does not lock numbers
> ("All tranche magnitudes are provisional and must pass this ledger's race
> row review like any other effect change"). Do not build
> `tools/pdv-redguard-variety-author`, do not write any `PDV_SPEL_`/`PDV_MGEF_`/
> `PDV_MSG_`/`PDV_FLST_` record, and do not paste any Papyrus layer until the
> Redguard ledger row is reviewed and the manual-evidence ledger carries
> per-effect approval. This is a prep artifact only.

---

## 1. Scope And Lock Status

The Redguard "The Far Shores Keep Watch" tranche is DESIGN-LOCKED 2026-06-12
into `race-sheets/PDV_RaceDesign_Redguard.md` and the roadmap. Six beats:

1. **Far Shores dreams** (all sects) -- sleep-keyed ambient texture.
2. **Sword-Tending Rite** -- daily observance hung off the Far Shores token.
3. **Sect signatures** (once/day): Crown `Leki's Measure`, Forebear
   `Tava's Departure`, Ash'abah `The Unclean Hour`.
4. **The Halls of the Dead** -- six one-shot non-martial pilgrimage stations.
5. **The Remembering of Names** -- one-active ancestral observance rite.

Locked: shapes, triggers, gates, caps, fade rules. Tunable: every magnitude.
The tranche adds **no new always-on boon family** (per the Variety Tranche
Gate): pilgrimage pulses are one-shot, signatures are once/day pulses, the
rite is one-active with dawn fade/restore. The two-family hybrid budget and
the global one-active contextual-favor cap are untouched.

---

## 2. Exists-vs-Missing Reconciliation

The Redguard sect spine already shipped and is runtime-touched (beta packet
PASS 2026-06-19). This tranche **reuses existing primitives** and must not
re-invent them. The Bosmer variety layer is already merged into the
`2026-06-15-final-polish` snapshot, so its functions are the working pattern
to clone.

### 2a. Already exists -- REUSE, do not re-author

| Primitive | Where (snapshot line) | Reuse for |
|---|---|---|
| `Int Property ORIGIN_REDGUARD = 9 AutoReadOnly` | line 459 | origin guard on every beat |
| `PDV_StateTrack Property PDV_RedguardSectTrack Auto` | line 95 | sect read + evidence/lockout gating |
| `REDGUARD_SECT_CROWN=0` / `_FOREBEAR=1` / `_ASHABAH=2` | lines 483-485 | sect-keyed signatures, dreams, rite coherence |
| `Bool Function IsRedguardOrigin()` | line 4715 | origin guard (preferred over raw `GetPlayerOriginRaceIndex()==9`) |
| `String Function GetRedguardSectLabel()` -> `PDV_RedguardSectTrack.GetStateLabel()` | line 4729 | dream/vision/Survey copy selection |
| `Function EnsureRedguardSectInitialized()` | line 4701 | call before any sect read in a new beat |
| `Float Function ConsumeDailyRepeatMultiplier(String key)` | (used throughout, e.g. line 4587) | day+1 anti-farm soft 0.7x decay on any pulse credit |
| `Function HandleRedguardFarShoresToken(String reason)` | line 4582 | the Sword-Tending Rite and the Remembering rite both ride the Far Shores token surface; reuse this entry, do not add a parallel token route |
| `PDV_RedguardSectTrack.RecordEvidenceDay / HasRecentEvidenceDays / SetTransitionLockout / IsTransitionLockedOut` | lines 4590, 4650, 4655 | sect-coherence gate for the Remembering fade/restore (StateTrack evidence-gate pattern) |
| `Spell Property PDV_Bless_Redguard_FarShoresToken Auto` + `SyncRedguardRewards(playerRef)` | lines 340, 7834-7847 | dawn-synced reward apply pattern (the rite/signature pulses are cast directly, but the dawn-sync precedent is the Far Shores token) |
| `Function HandlePlayerSleepStop(Actor playerRef, Bool wasInterrupted, String reason)` | line 2383 | sleep dispatcher to host the dreams + the Remembering rite menu |
| `Function RunDawnRefreshTrackStates()` | line 6520 | dawn fade/restore + dream-arming hook site |
| `Function TryArgonianEldergleamInterior()` | line 2657 (called line 685) | interior-poll precedent only (the Halls likely do NOT need it; see beat L4) |
| Argonian/Bosmer variety function family (`HandleBosmerSleepEvents`, `TryBosmerNaming`, `SyncBosmerNaming`, `AwardBosmerSong`, `HandleBosmerLocationChange`) | snapshot 2900-3200 region | exact clone templates for the Redguard equivalents |
| Location-change hook precedent: `HandleArgonianSacredWaterDiscovery(playerRef.GetCurrentLocation())` (line 8078) + Bosmer `HandleBosmerLocationChange` routed from `PDV_ActionRouter.HandleStoryChangeLocation` | line 8078 | the Halls pilgrimage router rides this same location-change entry; do NOT add a new event registration |

### 2b. New -- must be authored (blocked on row review)

- **No prior Redguard variety manifest or author tool exists.** `Glob`/`Grep`
  for "Redguard" + "variety"/"tranche" returns only the roadmap, the race
  sheet, the ledger gate, and this draft. This document is the intended
  replacement draft (it overwrote an earlier placeholder line).
- **No Redguard block exists in `RunDawnRefreshTrackStates()`** (lines
  6520-6550): Khajiit, Argonian, Orc, Breton, and Bosmer each have one;
  Redguard does **not**. The Remembering fade/restore and the dream-arming
  helper need a **new** `if IsRedguardOrigin() && PDV_RedguardSectTrack ...`
  block added there.
- **No Redguard branch exists in `HandlePlayerSleepStop`** -- a new dispatch
  line is required (mirrors the Bosmer `HandleBosmerSleepEvents` insertion).
- **All six beats' records are new** (table below): 5+ SPEL/MGEF, 4 ability
  SPEL/MGEF for the rite told-selves, 1 MESG (rite), 1 FLST (Halls), plus the
  manager VMAD properties and the Papyrus runtime layer.
- **A `tools/pdv-redguard-variety-author`** (cloned from
  `tools/pdv-bosmer-variety-author`, fail-closed `--dry-run`/`--check`) is new.

---

## 3. Per-Beat Record Manifest

Naming follows PDV convention (`PDV_SPEL_`/`PDV_MGEF_`/`PDV_MSG_`/`PDV_FLST_`).
All player text is ASCII-only. All magnitudes are **PROVISIONAL** (see banner).
EditorIDs below are **proposed**; the author tool owns the final FormIDs.

### L1 -- Far Shores Dreams (all sects)

| Field | Value |
|---|---|
| Records | None (pure `Debug.Notification` text; no SPEL/MGEF). Author as Papyrus string functions only, like `GetBosmerDreamText`. |
| Locked shape | Sleep-keyed dream line, ~8-12% per sleep, 2-day floor, elevated (~60%) the night after a sect/posture change. Keyed to sect: Crown = inheritance / line of swords; Forebear = road and wind; Ash'abah = the dead at rest (or restless if work waits). |
| Trigger | `HandlePlayerSleepStop` -> new `HandleRedguardSleepEvents` dispatcher. |
| Gate | `IsRedguardOrigin()`; text branches on `PDV_RedguardSectTrack.GetCurrentState()`. |
| Cap / fade | 2-day floor key; a shown rite menu that night suppresses the dream (mirror the Bosmer "menu shown -> dream yields" order). No piety, no state writes beyond dream bookkeeping. |
| Surfacing / copy hook | top-left only. Copy-hook function `GetRedguardDreamText(Int sect)`. Ash'abah variant quietly carries the stigma 1.0 cannot socially simulate (race sheet, Signature Friction). |
| Anti-farm | day-floor StorageUtil key (day+1 encoded). |
| Author-tool / Papyrus hook | Papyrus only (`TryRedguardSectDream`, `GetRedguardDreamText`, `ArmRedguardDreamOnSectChange` in dawn block). No author-tool record. |

### L2 -- Sword-Tending Rite (place/observance anchor)

| Field | Value |
|---|---|
| Proposed EditorID | (reuse) routes through `HandleRedguardFarShoresToken`; the Leki pulse may reuse an existing Leki support spell or a new `PDV_SPEL_RedguardSwordTending` (TBD at row review -- prefer reuse). |
| Record type | SPEL+MGEF only if a new Leki pulse is approved; otherwise no new record. |
| Locked shape | Tending the blade at the portable Far Shores token in a **private/player-owned** context grants a small Leki pulse and counts as the daily Yokudan observance. 24h cooldown. "No new state; it hangs off the token." |
| Trigger | Far Shores token activation in a qualifying private context -> existing `HandleRedguardFarShoresToken(reason)`. |
| Gate | `IsRedguardOrigin()`; private/player-owned cell check (V1 token currently ships with **no** private/home bonus condition per the locked Tu'whacca surface -- this rite is the first place that gates on private context, confirm scope at review). |
| Cap / fade | 24h cooldown (StorageUtil day-key, day+1 encoded); `ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardSwordTending")` soft-decays repeat credit. |
| Surfacing / copy hook | Quiet top-left ("The blade is tended; Leki's measure holds."). |
| Anti-farm | 24h cooldown + `ConsumeDailyRepeatMultiplier` (existing soft 0.7x). |
| Author-tool / Papyrus hook | Papyrus extension of `HandleRedguardFarShoresToken`; new record only if Leki pulse is not reusable. |

### L3 -- Sect Signatures (once/day, small, Quiet)

These never touch the make-way frame; HoonDing stays rare per the locked Crown
make-way rule. Each is a self-cast timed buff (Rooted-Rest scale).

| Proposed EditorID | Record | Sect / trigger (locked) | PROVISIONAL magnitude | Surfacing / copy | Anti-farm | Hook |
|---|---|---|---|---|---|---|
| `PDV_SPEL_RedguardLekisMeasure` (+ `PDV_MGEF_*`) | SPEL+MGEF, self-cast timed buff | Crown: kill a hostile with a one-handed weapon while at **full health** (discipline texture: never touched), once/day | one-handed damage **+8%**, ~120s **[PROVISIONAL]** | Quiet top-left ("Leki's measure: you were never touched.") | once/day day-key (day+1); `PDV.RedSig.MeasureLastDay` | combat-session route via `PDV_PlayerEvents` / `PDV_EventBus` (clone the shared Khajiit/Bosmer combat-session poll; do NOT use a naked `OnHitEx`) |
| `PDV_SPEL_RedguardTavasDeparture` (+ `PDV_MGEF_*`) | SPEL+MGEF, self-cast timed buff | Forebear: leave a walled city **on foot at dawn**, once/day | StaminaRateMult **+15** (regen) ~120s **[PROVISIONAL]** -- see AV note S4 | Quiet top-left ("Tava's wind is at your back on the road.") | once/day day-key; `PDV.RedSig.DepartureLastDay` | location-change entry (`HandleStoryChangeLocation` -> `HandleRedguardLocationChange`) + dawn-window + on-foot/fast-travel-reject check (race sheet: reject `OnPlayerFastTravelEnd`) |
| `PDV_SPEL_RedguardUncleanHour` (+ `PDV_MGEF_*`) | SPEL+MGEF, self-cast timed buff | Ash'abah: the **first undead destroyed inside a tomb**, once/day | undead damage resist **+10%** ~120s **[PROVISIONAL]** | Quiet top-left ("The unclean hour is yours; the dead give way.") | once/day day-key; `PDV.RedSig.UncleanLastDay`; first-in-tomb gate | undead-kill route (existing Kill Actor + `ActorTypeUndead`) + `LocTypeDraugrCrypt` tomb context |

### L4 -- The Halls of the Dead (pilgrimage)

| Field | Value |
|---|---|
| Proposed EditorID | `PDV_FLST_RedguardHallsOfDead` (FLST) |
| Record type | FLST (6 LCTN entries) + Papyrus award/milestone logic |
| Locked shape | Six **one-shot** death-duty stations: Halls of the Dead in Whiterun, Windhelm, Solitude, Markarth, Riften, plus Falkreath's graveyard. First **respectful visit** each = ancestor-layer pulse + sect-flavored vision line; all six = milestone MessageBox. Non-martial: visiting/paying respect, not clearing. One-shot forever. |
| Trigger | Location-change entry -> `HandleRedguardLocationChange(loc)` -> `AwardRedguardHall(formId)` (clone `HandleBosmerLocationChange` / `AwardBosmerSong`). |
| Gate | `IsRedguardOrigin()`; `PDV_FLST_RedguardHallsOfDead.HasForm(loc)`. Strongest for Ash'abah; meaningful for all sects via the always-active ancestor layer. |
| Cap / fade | one-shot-forever per site (`PDV.RedHalls.Seen.<FormID>`); milestone once (`PDV.RedHalls.Milestone`). |
| Surfacing / copy | vision line per site (sect-flavored via `GetRedguardSectLabel`); milestone `Debug.MessageBox`. |
| Anti-farm | one-shot keys (no day-cap needed; arrival is permanent). |
| Author-tool / Papyrus hook | author tool writes the 6-entry FLST **fail-closed** on unverified slots (FormList index/order-drift lesson: build in manifest order, `--check` slot dump). LCTN FormIDs must be resolved via houseCARL / `pdv_extract_vanilla_gameplay_refs.mjs` and marked `verified` before any real write. **Interior-poll note:** unlike the Argonian/Bosmer Eldergleam case, the Halls of the Dead resolve to their own interior LCTNs, so a `TryArgonianEldergleamInterior`-style poll is likely **unnecessary** -- confirm each Hall LCTN actually fires on the door at slot-resolution time; Falkreath's graveyard is an exterior and may need an LCTN-vs-marker check (Bosmer Wind-District swap precedent). |

**Halls FLST slot plan (FormIDs PENDING -- author-tool fail-closes until resolved):**

| Slot | Proposed EditorID | Status |
|---|---|---|
| 0 | `WhiterunHalloftheDeadLocation` (or equivalent LCTN) | PENDING FormID resolution |
| 1 | `WindhelmHalloftheDeadLocation` | PENDING |
| 2 | `SolitudeHalloftheDeadLocation` | PENDING |
| 3 | `MarkarthHalloftheDeadLocation` | PENDING |
| 4 | `RiftenHalloftheDeadLocation` | PENDING |
| 5 | Falkreath graveyard LCTN (exterior -- verify LCTN exists; swap-and-record if marker-only) | PENDING |

### L5 -- The Remembering of Names (rite)

One-active ancestral observance. Follows the Hist Adaptations contract exactly
(Variety Tranche Gate): one active at a time, swap is clear-before-add,
"Not yet" does not spend the cooldown, fade at dawn on coherence break, restore
at dawn on recovery. Clone `PDV_MESG_BosmerNaming` + the four
`PDV_SPEL_BosmerNaming_*` abilities + `SyncBosmerNaming`/`ApplyBosmerNaming`/
`RemoveBosmerNamingSpells`/`GetBosmerNamingSpell`.

| Field | Value |
|---|---|
| Proposed menu EditorID | `PDV_MSG_RedguardRemembering` (MESG) |
| Locked shape | Rite at the Far Shores token in private context, 7-day cooldown; choosing again swaps (clear-before-add); "Not yet" does not spend the cooldown. Fades at dawn if sect coherence breaks (mid-switch window); returns automatically at dawn once the sect is settled. |
| Trigger | Far Shores token activation in private context (or sleep-dispatch at the token), 7+ days since last rite. |
| Gate | `IsRedguardOrigin()`; private/player-owned context; 7-day cooldown (game-time float key, like `PDV.BosNaming.LastRiteTime`). |
| Cap / fade | one-active; dawn fade/restore via new Redguard dawn block, gated on `PDV_RedguardSectTrack` coherence (the told-self records the sect it was named on; off-sect during the mid-switch window -> quiet at dawn, returns when sect settles). Use the existing `HasRecentEvidenceDays`/`IsTransitionLockedOut` primitives to detect the mid-switch window. |
| Surfacing / copy | MESG body lists the four observances (effects in the BODY, not the buttons -- Skyrim lays buttons in one row); button index == observance value (startup-choice index==value lesson). |
| Anti-farm | 7-day cooldown (not day-cap); cooldown not spent on "Not yet". |

**Remembering told-self abilities (one-active SPEL+MGEF abilities):**

| Proposed EditorID | Observance (locked) | Deity | PROVISIONAL effect | AV note |
|---|---|---|---|---|
| `PDV_SPEL_RedguardRemember_Blade` | Blade | Leki | one-handed **+5** | -- |
| `PDV_SPEL_RedguardRemember_Road` | Road | Tava | stamina regen **+8%** | StaminaRateMult, see S4 |
| `PDV_SPEL_RedguardRemember_Rest` | Rest | Tu'whacca | health regen **+5%** | **HealRate -- PeakValueModifier, see S4** |
| `PDV_SPEL_RedguardRemember_Harvest` | Harvest | Zeht | barter **+5%** | **barter AV reconciliation needed, see S5** |

Menu buttons: `["Blade", "Road", "Rest", "Harvest", "Not yet"]` -- indices 0-3
map to the four abilities, index 4 = no change (cooldown not spent).

---

## 4. ActorValue / PeakValueModifier And AV-Reconciliation Notes

- **S1 -- regen effects use PeakValueModifier, not ValueModifier.** Any regen
  AV (`HealRate`, `MagickaRate`, `StaminaRate`, and the `*RateMult` family)
  must be authored as **PeakValueModifier** (durable convention, MEMORY:
  strict-phase20 race-costing). This applies to `Tava's Departure`
  (StaminaRateMult), `Remember_Road` (stamina regen), and `Remember_Rest`
  (health regen).
- **S2 -- enum member drift.** Confirm Mutagen `ActorValue` member names at
  `--dry-run` exactly as the Argonian/Bosmer batches did
  (`MagicResist`->`ResistMagic`; `Archery` may be `Marksman`). At-risk for this
  batch: `OneHanded` (likely correct), `StaminaRateMult`, `HealRate`,
  `DamageResist`/undead-resist mechanism. Never change FormIDs or magnitudes to
  satisfy the compiler -- fix the C# member name.
- **S3 -- undead-resist magnitude class.** `The Unclean Hour` and the
  `Remember_Rest`/Tu'whacca family touch undead damage resist. Note the
  `DamageResist` armor-points-ceiling lesson does **not** apply here (these are
  percent magic/undead resists, not armor points), but confirm the resist
  mechanism (keyword-gated MGEF vs flat AV) at row review.
- **S4 -- `Tava's Departure` / `Remember_Road` stamina regen.** Use
  `StaminaRateMult` as PeakValueModifier. The provisional `+15` on the once/day
  signature vs `+8%` on the one-active rite is intentional (signature is a
  short pulse, rite is a steady one-active) -- both PROVISIONAL.
- **S5 -- Harvest/barter AV reconciliation (BLOCKING for the rite).** The
  locked sheet lists Harvest as "+5% barter". **Vanilla has no separate barter
  ActorValue** -- prices are governed by `Speech`. The Bosmer batch hit this
  exact problem (Keeper "+5% barter" was reconciled to `CarryWeight +15`). The
  Redguard Harvest observance needs the same reconciliation at row review:
  either implement as `Speech` (collides thematically with no other Redguard
  told-self, so it may be acceptable here) or pick a distinct Zeht-appropriate
  AV. Record the resolution in both the race sheet and this manifest so they
  stay in sync.

---

## 5. Reserved StorageUtil Keys

Script state only; **no records back these.** Day-keyed anti-spam keys encode
**day+1**, because StorageUtil int day-keys default to `0` and a `0`-default
guard self-suppresses on day 0 of a fresh game (durable lesson:
storageutil-day-key-zero-default; it bit the LD-P1 mood toast). Float
game-time cooldown keys (the 7-day rite) do not need the +1 trick.

| Beat | Reserved key | Note |
|---|---|---|
| Dreams | `PDV.RedDream.LastDay` | 2-day floor; **day+1 encoded** |
| Dreams | `PDV.RedDream.LastSect` | detect sect change for elevated chance |
| Dreams | `PDV.RedDream.Armed` | 0/1, armed at dawn after sect change |
| Sword-Tending | `PDV.Signal.RedguardSwordTending` | existing `ConsumeDailyRepeatMultiplier` key shape; 24h, **day+1** |
| Leki's Measure | `PDV.RedSig.MeasureLastDay` | once/day; **day+1 encoded** |
| Tava's Departure | `PDV.RedSig.DepartureLastDay` | once/day; **day+1 encoded** |
| The Unclean Hour | `PDV.RedSig.UncleanLastDay` | once/day; **day+1 encoded** |
| Halls | `PDV.RedHalls.Seen.<FormID>` | one-shot per site (permanent, no day-key) |
| Halls | `PDV.RedHalls.Count` | milestone counter |
| Halls | `PDV.RedHalls.Milestone` | 0/1, fired once |
| Remembering | `PDV.RedRemember.Active` | 0=none, 1-4=Blade/Road/Rest/Harvest |
| Remembering | `PDV.RedRemember.SectAtRite` | sect named-on; coherence fade/restore key |
| Remembering | `PDV.RedRemember.LastRiteTime` | game-time float; 7-day cooldown (no +1) |

---

## 6. VMAD / Wiring Plan

- **New manager VMAD properties** on `PDV__ManagerQuest` (forward-wired by the
  author tool, inert until the Papyrus layer is applied): the L3 signature
  SPELs, the four L5 Remembering ability SPELs, `PDV_MSG_RedguardRemembering`,
  `PDV_FLST_RedguardHallsOfDead`, and (if approved) `PDV_SPEL_RedguardSwordTending`.
- **New dawn block** in `RunDawnRefreshTrackStates()` (insert after the Bosmer
  block, lines 6544-6549):
  `if IsRedguardOrigin() && PDV_RedguardSectTrack` -> `SyncRedguardRemembering(...)`
  + `ArmRedguardDreamOnSectChange()`. **This block does not exist yet** and is
  required.
- **New sleep dispatch** in `HandlePlayerSleepStop` (line 2383) ->
  `HandleRedguardSleepEvents(playerRef, reason)`.
- **Location-change hook** rides the existing entry. Per the
  variety-tranche-hook-architecture lesson, the location hook lives in
  `PDV_ActionRouter.HandleStoryChangeLocation` (the Bosmer snapshot routes
  `HandleBosmerLocationChange` from there, not from `PDV_PlayerEvents`); the
  Argonian water discovery is called via `playerRef.GetCurrentLocation()` at
  line 8078. Add a sibling `HandleRedguardLocationChange(akNewLoc)` call;
  **do not register a new event.** Note: `coc` skips
  `OnStoryChangeLocation`, so the Halls/Tava's-Departure beats must be reached
  via a load door or fast-travel-in during smoke (coc-skips-story-triggers
  lesson).
- **Combat signature** (`Leki's Measure`) routes through the shared combat-
  session poll in `PDV_PlayerEvents` / `PDV_EventBus` (the StateTrack setter is
  `SetState`, not `ForceState`; the player-alias hook routes via
  `PDV_EventBus`). Do **not** add a naked `OnHitEx` low-health/full-health hook.
- **Existing-save note:** VMAD props bake at first init; features stay inert on
  existing saves until a lazy `GetFormFromFile` fallback pass adds the FormIDs.
  Beta proof path is a NEW save / `coc qasmoke`.

---

## 7. Dependencies / Blocked-On

1. **Effect-review row (HARD GATE).** Redguard row in
   `PDV_RaceEffectReviewLedger.md` is `Pending`. All magnitudes are PROVISIONAL
   until that row is reviewed and the manual-evidence ledger carries per-effect
   approval. No authoring before this.
2. **Roadmap build order.** The locked order is
   **Bosmer -> Orc -> Altmer -> Redguard -> Khajiit addendum.** Redguard is P2,
   fourth. Bosmer's in-game fresh-save smoke is still the open gate ahead of it
   (roadmap Build status; records+runtime landed, smoke PENDING). Orc and Altmer
   batches are not yet built. Redguard should not jump the queue without an
   explicit re-order decision.
3. **Harvest/barter AV reconciliation (S5).** The "+5% barter" observance has no
   vanilla AV; must be reconciled (Speech, or a distinct Zeht AV) and synced
   into the race sheet before the rite records are authored.
4. **Halls LCTN FormID resolution.** All six `PDV_FLST_RedguardHallsOfDead`
   slots are PENDING; resolve via houseCARL / `pdv_extract_vanilla_gameplay_refs.mjs`,
   verify each Hall fires on its own LCTN (no interior poll if so), and confirm
   Falkreath graveyard has a real LCTN (swap-and-record if marker-only).
5. **Author tool.** `tools/pdv-redguard-variety-author` is not built (clone
   `tools/pdv-bosmer-variety-author`, fail-closed `--dry-run`/`--check`,
   FLST `--check` slot dump). Watch for the houseCARL ESP-lock workaround if a
   write fails ("used by another process").
6. **Papyrus runtime layer + canonical source.** A `PDV__ManagerQuest.psc`
   handoff (modeled on `PDV_BosmerVariety_PapyrusHandoff.md`) must be authored
   and applied to the **live untracked .psc** (not the snapshot) -- verify
   against live, not the dated snapshot (repo-source-drift lesson). New dawn
   block + sleep dispatch + location/combat hooks per Section 6. Recompile via
   `tools/pdv_compile.mjs` (0/0).
7. **Private-context scope decision.** The V1 Far Shores token ships with **no**
   private/home bonus condition (locked Tu'whacca surface). The Sword-Tending
   Rite and the Remembering rite both want a private/player-owned context check.
   Confirm at row review whether introducing that condition is in V1 scope or
   stays post-1.0.
8. **Vampire earn-halt interaction (carry-forward).** A specced-not-built
   Redguard vampire earn-halt GAP exists (`GetCurseGainMultiplier` returns 1.0
   for all Yokudan deities; beta packet 2026-06-19 + memory:
   redguard-vampire-earn-halt-specced-not-built). The tranche pulses (signatures,
   sword-tending Leki credit) accrue full-rate during the vampire window today.
   When the earn-halt is built, gate the tranche pulses on
   `VampireReentryNeeded == 1` consistently with the curse layer (Variety Tranche
   Gate: "Curse and Daedric modifiers must be reviewed with the race effect set").
9. **Beta packet addendum.** Extend `PDV_BetaTestPacket_Redguard.md` with the
   tranche checklist + a `DebugSeedRedguard` SetPQV/MCM harness (debug is
   MCM-driven, not `cqf`, per the debug-testing lesson). Until per-lever
   fresh-save smoke returns PASS, the tranche is **NOT runtime-proven**.
