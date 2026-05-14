# claude.md — PlayerDevotion (PDV) Mod Project

> Legacy compatibility copy. `AGENTS.md` is the canonical living context doc for current project state, build status, and decisions.

## What This Project Is

A Skyrim Special Edition (SSE) mod called **PlayerDevotion** that tracks the player's religious devotion based on their race's authentic theological traditions. The system reads the player's daily behavior (combat, social, lifestyle) and adjusts a floating `DevotionLevel` variable, which then gates tiered blessings and neglect effects per race.

The mod is designed for roleplayers who want mechanically meaningful, lore-accurate religious practice — not generic shrine-visiting bonuses.

---

## Project File Map

| File | Role | Use When |
|------|------|----------|
| `Claude.md` | This file — project context, build status, decisions log | Context for Claude across sessions |
| `PDV_STANDARDS.md` | Operating rules: doc hygiene, description discipline, investigation/safety rules | **Read at session start.** Re-read § 1 + § 4 when in doubt |
| `PDV_MOD_SETUP.md` | Dev environment, architecture, build order, variable reference | Setting up tooling, debugging, tracking decisions |
| `PDV_Architecture_v2.md` | Full v2 architecture spec — data model, quest topology, phase plan, stance matrix | Phase planning, writing new scripts, understanding the deity/origin system |
| `PDV_Phase1_ManualSteps.md` | CK step-by-step for Phase 1 globals and script wiring | Returning to CK work after a break |
| `PDV_Phase2_CK_Steps.md` | **NEW** — Detailed CK walkthrough for Phase 2 deity quest creation and FormList wiring | Completing Phase 2 CK work |
| `PDV_Phase2_Summary.md` | **NEW** — Phase 2 architecture summary, design decisions, testing checklist | Understanding Phase 2 completeness and next steps |
| `PDV_SkyrimConsoleReference.md` | UESP-sourced console command reference (source of truth) | Any in-game testing or debugging |
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity equivalency table (all 9 races × all pantheons) | Writing race-specific dialogue, checking deity names, avoiding lore errors |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice, threshold rituals, class variation, era pressures | Designing trigger conditions, writing flavour text, balancing per-race logic |
| `archive/HOUSECARL_*.md` | Inherited source material (frozen) | When PDV_STANDARDS doesn't cover a question and you want the fuller treatment |

### Mod implementation folder

Source and compiled output live at `D:\Wabbajack\modlists\Anvil\mods\Devotion\` (MO2-managed; `meta.ini` present). Source `.psc` files at the root; compiled `.pex` in `Scripts\`. The MCP server is connected to the Anvil MO2 instance with the **Devotion Dev** profile.

Script folder layout (CK toolchain):
```
Devotion\
  Scripts\
    PDV__ManagerQuest.pex     ← compiled output
    Source\
      PDV__ManagerQuest.psc   ← source (edit here, compile via CK)
  PDV__MainQuest.psc          ← root (compiled separately; move to Scripts\Source\ when next touched)
```

Quest scripts (current):
- `PDV__MainQuest.psc` — RunOnce bootstrap stub (currently at mod root; migrate to `Scripts\Source\` when next compiled)
- `PDV__ManagerQuest.psc` — Phase 1 refactor complete: mirror globals API, `AwardPiety`/`GetPiety`/`RecomputeTier`/`RefreshPatronMirrors`. Buckets removed. Phase 2 addition: FormList property and ProcessDawn loop (ready to compile).
- `PDV_DeityBase.psc` — **NEW (Phase 2)** Base class contract for all deity scripts. Properties for identity, tier thresholds, origin multipliers, boon spells. Virtual functions: `ScoreAction()`, `OnTierChange()`, `OnPatronStart()`, `OnPatronEnd()`.
- `PDV_Deity_Kyne.psc` — **NEW (Phase 2)** First concrete deity implementation. Kyne-specific rubric: -3 for slaughtering beasts, +0.5 for humanoid combat, +0.25 for shouting, +0.5 for sleeping outdoors.

(`PDV_MasterQuest.psc` and its `.pex` have been deleted. ESP record removed via xEdit. Done.)

---

## Architecture Summary

### ESP Structure

```
PlayerDevotion_Framework.esp    ← master: quest, bucket system, globals
PDV_Nord.esp                    ← race module (depends on framework)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

### v2 Architecture (current target — see `PDV_Architecture_v2.md` for full spec)

Per-deity piety lives in **StorageUtil** (PapyrusUtil SE), keyed by deity FormID. A set of **mirror GlobalVariables** shadows the active patron's current values so vanilla CK Conditions can read them without scripting glue. The manager quest is a dispatcher and helper API, not a calculator.

**StorageUtil keys per deity:**

| Key | Range | Purpose |
|-----|-------|---------|
| `PDV.Piety` | 0–200 | Current piety. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Reset at dawn. |
| `PDV.Tier` | 0–3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Decay grace period + MCM display |

**Mirror GlobalVariables (active patron only):**

| Global | Purpose |
|--------|---------|
| `PDV_GLO_ActivePiety` | Active patron's current piety |
| `PDV_GLO_ActiveTier` | Active patron's current tier (0–3) |
| `PDV_GLO_ActiveDeityIndex` | Stable int identifying the active deity. -1 = none |

Mirrors are refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()` on every piety/tier mutation to the active patron and on patron switch. They are never the source of truth — StorageUtil is.

**Tier thresholds (current defaults, tunable per-deity in Phase 2+):**

| Tier | Label | Piety threshold |
|------|-------|----------------|
| 0 | None | < 10 |
| 1 | Seeker | ≥ 10 |
| 2 | Devoted | ≥ 50 |
| 3 | Champion | ≥ 150 |

**The bucket system has been removed.** `CombatBucket`, `SocialBucket`, `LifestyleBucket`, and `PDV_GLO_DevotionLevel` are gone. Do not reference them.

---

## Naming Conventions

All records use prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals add a second underscore (`PDV_GLO__X`). Mirrored from Gods And Worship — full reference in `PDV_MOD_SETUP.md` § EditorID Prefix Convention.

```
PDV__MainQuest                  ← internal: RunOnce bootstrap
PDV__ManagerQuest               ← internal: runtime (registry + helper API)
PDV_GLO_ActivePiety             ← Global, mirror: active patron's piety (float)
PDV_GLO_ActiveTier              ← Global, mirror: active patron's tier 0–3 (float)
PDV_GLO_ActiveDeityIndex        ← Global, mirror: active deity stable int, -1=none (float)
PDV_GLO_OriginRace              ← Global, set once: race index 0–9 (Phase 4)
PDV_GLO_PatronDeity             ← Global, FormID of active patron, 0=none (Phase 2+)
PDV_GLO_DebugLevel              ← Global, 0–3 trace verbosity (MCM-toggleable)
PDV_Race[Name]Quest             ← per-race tracking (in race ESP)
PDV_ActionRouter                ← Story Manager event fan-out (Phase 3)
PDV_DeityBase                   ← base class all PDV_Deity_<X> scripts extend (Phase 2)
PDV_Deity_[Name]                ← concrete deity quest (Phase 2+)
PDV_FLST_AllDeities             ← FormList, iteration source for ProcessDawn and MCM
PDV_Blessing_[Race]_Low/Mid/High
PDV_Neglect_[Race]
PDV_SMF_[EventName]             ← Story Manager flag globals
PDV_DebugSpell
```

`PDV_GLO_DevotionLevel`, `CombatBucket`, `SocialBucket`, and `LifestyleBucket` have been removed.

---

## Race Design Philosophy

Each race module is designed around the **primary religious tension** that culture faces in 4E 201. These tensions should drive what the buckets reward and punish — not generic "worship a shrine" logic.

| Race | Core Tension | What the Buckets Should Reflect |
|------|-------------|----------------------------------|
| Nord | Talos ban vs. identity | Openly defiant worship vs. pragmatic silence |
| Imperial | Concordat enforcement vs. private faith | Civic observance vs. personal conscience |
| Dunmer | Tribunal gone, far from ancestral tombs | Ash-prayer maintenance, ancestor memory |
| Altmer | Thalmor enforcement as religious vocation | Theological purity, bloodline, magical study |
| Khajiit | Excluded from cities, no temple access | Moon-watching, caravan community cohesion |
| Bosmer | Green Pact observance without Valenwood enforcement | Dietary compliance, hunting ritual |
| Redguard | Post-victory confidence, Crown/Forebear split | Martial-devotional practice, sword rites |
| Orc | Labor as worship, Malacath's active judgment | Craft excellence, honor, code adherence |
| Argonian | Hist absence, identity under discrimination | Community cohesion, Sithis acknowledgment |

---

## Key Lore Constraints

Pull from `skyrim-gods-reference.jsx` and `tamriel-daily-worship-4e201.html` before writing any race content. Key things to remember:

- **Khajiit** worship the lunar lattice (Riddle'Thar), not generic Nine Divines. Moon phase determines identity.
- **Dunmer** religious life centres on named ancestors, not named gods. The household ash-shrine outranks any temple.
- **Orcs** treat craft as prayer. Malacath is not petitioned — he judges by observing strength and labor.
- **Argonians** lose their core religious infrastructure (the Hist) when outside Black Marsh. Design their triggers around adaptation and absence, not normal worship.
- **Bosmer** Green Pact dietary observance (no plant matter) creates daily friction in Skyrim that is itself a mechanic opportunity.
- **Redguard** theology is a survival narrative. Their recent military victory over the Dominion is a live theological fact in 4E 201.
- **Daedric Prince** names are largely consistent across all cultures — use `skyrim-gods-reference.jsx` for the few exceptions (e.g. Azurah, Boethra, Sheggorath for Khajiit).

---

## Current Build Status

*Update this section as the project progresses.*

```
[x] Environment setup verified
[x] PDV_Framework.esp created
[x] Master quest and script skeleton running
[x] Phase 0 complete — PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 complete — StorageUtil data model, mirror globals declared and verified,
      PDV__ManagerQuest refactored (AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors)
[x] Phase 2 complete — Kyne proof slice verified in-game; deity-as-quest model validated
      - PDV_DeityBase.psc ✓
      - PDV_Deity_Kyne.psc ✓
      - PDV__ManagerQuest.psc with ProcessDawn and FormList ✓
      - CK wiring, FormList, dawn consolidation, tier crossing ✓
[x] Phase 3 complete (2026-05-14) — ActionRouter kill event slice; all tests passed
      - PDV_ActionRouter.psc ✓
      - PDV__SM_KillActor.psc ✓
      - Story Manager Kill Actor wiring ✓
      - Test 1: Hostile bandit routing (+0.5) ✓
      - Test 2: Hostile animal routing (-3.0) ✓
      - Test 3: Neutral kill rejection ✓
      - Test 4: Rapid dual kills + consolidation ✓
[ ] Phase 4 — PDV_Origin, stance taxonomy, rivalry ledger, tier boon grants
[ ] Phase 5 — MCM
[ ] Phase 6 — Talos (second deity; proof of scalability)
[ ] Debug spell working
[ ] Nord module complete
```

---

## Decisions Log

*Append here when architectural choices are made. Mirror significant entries in PDV_MOD_SETUP.md.*

- **Framework vs. monolithic:** One core ESP owns the quest spine and globals. Nine race ESPs patch in as modules.
- **Variable storage (2026-05-09, revised 2026-05-10):** StorageUtil (PapyrusUtil SE) is the source of truth for all per-deity piety/tier values, keyed by deity FormID. Three mirror GlobalVariables (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) shadow the active patron's values for vanilla CK Condition reads. Mirrors are write-only caches — always write through `AwardPiety`/`RecomputeTier`, never directly to the globals. `PDV_GLO_DevotionLevel` and the three buckets are gone.
- **Dawn detection:** `RegisterForUpdateGameTime(1.0)` with hour-window check — chosen over Story Manager dawn event for reliability.
- **Bootstrap / Manager quest split (2026-05-09):** `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (Start-Game-Enabled runtime). Runtime owns the mirror globals API and will own the dawn consolidation loop in Phase 2+.
- **Naming taxonomy (2026-05-09):** Internal/machinery records prefixed `PDV__X`; runtime Globals prefixed `PDV_GLO_X`; internal/system Globals (config, debug, dev) prefixed `PDV_GLO__X`. Full taxonomy in `PDV_MOD_SETUP.md` § EditorID Prefix Convention.
- **PapyrusUtil SE (2026-05-10):** SKSE DLL plugin — no ESP master, no xEdit step. Call `StorageUtil.*` directly in script; DLL resolves at runtime. Never add as a plugin master.
- **CK compiler toolchain (2026-05-10):** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output goes to `Scripts\`. CK compiler (Ctrl+F7) is the build path. After compiling, move `.pex` from game's `Data\Scripts\` into the MO2 mod folder's `Scripts\`. `compile.ps1` / `skyrimse.ppj` in the mod folder are legacy — defer to CK compiler for now.
- **Phase 1 complete (2026-05-10):** Mirror globals declared in CK, verified in-game with `GetGlobalValue`. `PDV__ManagerQuest` refactored with `AwardPiety`/`GetPiety`/`RecomputeTier`/`RefreshPatronMirrors` API. Console command source of truth: `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed commands: `GetGlobalValue <var>` (read), `set <var> to <value>` (write).
- **Deity-as-Quest model (2026-05-10):** Each deity is a standalone persistent quest form extending PDV_DeityBase, not hardcoded rules in the manager. Allows N deities to be added via FormList membership alone; no manager changes required. Scaling proof arrives in Phase 6 when Talos is duplicated. Scripts: PDV_DeityBase (contract), PDV_Deity_Kyne (first implementation), PDV__ManagerQuest (ProcessDawn loop), all complete and ready for CK wiring.
- **Phase 2 script delivery (2026-05-10):** PDV_DeityBase.psc, PDV_Deity_Kyne.psc, and updated PDV__ManagerQuest.psc created and ready to compile. Detailed walkthrough: PDV_Phase2_CK_Steps.md. Summary: PDV_Phase2_Summary.md. All three scripts follow project conventions (PDV_ prefix, internal __ convention, full documentation headers, lore alignment via deity properties).
- **Phase 3 complete (2026-05-14):** ActionRouter kill event slice verified end-to-end. Story Manager Kill Actor event → `PDV__SM_KillActor` receiver → `PDV_ActionRouter` dispatcher → deity `ScoreAction()` → `AwardPiety()` → daily scratch. All four test scenarios passed: hostile humanoid (+0.5), hostile animal (-3.0), neutral rejection, and rapid dual kills with correct accumulation and clamping at dawn consolidation. Ready to scale to Phase 4 (origin system, boon grants).
