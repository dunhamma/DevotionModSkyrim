# PDV Custom Extras Ledger (1.0)

Tracks "extras" the final mod requires that go **beyond plain Papyrus scripting and
Creation Kit record edits** — i.e. things that must be authored or sourced separately
(custom items, authored text/scenes, tagging systems, third-party dependencies, and any
art/animation/audio). Use this as the tick-off checklist.

Status legend: 🔒 Locked (1.0 required) · ⚠️ Needed (1.0, lighter) · ⏸️ Deferred (post-1.0) · ❌ Not required (vanilla reuse)

---

## 1. Custom items / objects (portable devotional tokens)

The three "exile" races share one pattern: a permanent, usable-anywhere inventory item
that supplies a valid maintenance/prayer signal, with a bonus in a player-owned home /
authored private context. **Build once, reskin three times.**

| # | Item | Race | Status | Source |
|---|------|------|--------|--------|
| 1 | **Ash-shrine token** — portable ancestor prayer, home-use bonus | Dunmer | 🔒 | `race-sheets/PDV_RaceDesign_Dunmer.md:179` |
| 2 | **Far Shores token** — portable Yokudan devotion, home-use bonus; vanilla Arkay shrine as fallback | Redguard | 🔒 | `race-sheets/PDV_RaceDesign_Redguard.md:53,254` |
| 3 | **Hist sap** — portable meditation tool; supplies a valid Hist-maintenance signal anywhere to offset dawn decay | Argonian | 🔒 | `race-sheets/PDV_RaceDesign_Argonian.md:47,67-72` |

Notes: all three reuse vanilla activators/icons — **no custom mesh or texture required** for the items themselves.

## 2. Tagging / data systems

| # | System | Race | Status | Source |
|---|--------|------|--------|--------|
| 4 | **Green Pact plant-tagging** — keyword list or manual curation of all plant-based consumables. Called "the most significant custom work on the Bosmer sheet." | Bosmer | 🔒 | `race-sheets/PDV_RaceDesign_Bosmer.md:229` |

## 3. Authored content (non-voiced text / scenes)

| # | Content | Race | Status | Source |
|---|---------|------|--------|--------|
| 5 | **Y'ffre forced-reckoning scene** — one-time event after 3 days in Apostate state; day-counter + localized non-voiced dialogue | Bosmer | ⚠️ | `race-sheets/PDV_RaceDesign_Bosmer.md:230` |
| 6 | **Azura threshold flavor text** — curated localized notification strings on major moments | Dunmer | ⚠️ | `race-sheets/PDV_RaceDesign_Dunmer.md:248` |
| 7 | **Ash'abah social-stigma lines** — light reaction/status text | Redguard | ⏸️ | `race-sheets/PDV_RaceDesign_Redguard.md:69` |
| 8 | **Tribunal memory flavor text** — cosmetic notifications on events | Dunmer | ⏸️ | `race-sheets/PDV_RaceDesign_Dunmer.md:249` |
| 9 | **Argonian location rituals** — meditation at specific places (Tier B enrichment) | Argonian | ⏸️ | `race-sheets/PDV_RaceDesign_Argonian.md:72,192` |

## 4. Third-party dependencies (ship-blocking)

| Dependency | Status | Source |
|------------|--------|--------|
| SKSE64 (version-matched) | 🔒 | `PDV_MOD_SETUP.md:64-68` |
| SkyUI 5.2SE (MCM) | 🔒 | `PDV_MOD_SETUP.md:64-68` |
| Address Library for SKSE | 🔒 | `PDV_MOD_SETUP.md:64-68` |
| powerofthree's Tweaks + Papyrus Extender (v3 event hooks) | 🔒 | `PDV_MOD_SETUP.md:64-68` |
| FNIS / Nemesis | ❌ unless animations added — see §5 | `PDV_MOD_SETUP.md:87` |

## 5. Animations / movements

❌ **Not required for 1.0 under the current design.** No `.hkx`, idle, furniture-marker, or
`PlayIdle` requirement appears in any race sheet. "Posture" is a **state enum**
(`PDV_State_..Posture` = Normal/Distant/Strained/...), not a body pose. FNIS/Nemesis is
listed only as conditional (`PDV_MOD_SETUP.md:87`).

> **Open decision:** custom prayer/kneel animations (e.g. a Dunmer personal-prayer idle) are
> a *scope addition*, not a tick-off of existing spec. Adding them pulls in FNIS/Nemesis as a
> hard dependency plus a behavior-file build step and per-race pose authoring.

## 6. Other art / audio

| Category | Status | Source |
|----------|--------|--------|
| Custom meshes (.nif) | ❌ vanilla reuse | — |
| Custom textures (.dds) | ❌ vanilla reuse | — |
| Voice acting / lip / chants | ⏸️ deferred to V2 (voiced-content non-goal) | `PDV_Architecture_v3.md` §21.3 |
| Particle / shader FX | ❌ vanilla magic-effect archetypes only | — |
| MCM / Prisma UI | ❌ internal to mod (scaffold exists) | `native/DevotionPrismaBridge/` |
