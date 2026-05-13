# Devotion Progress Plan

## Status Checklist

- [x] **Phase 0** — Cleanup
- [x] **Phase 1** — Data model swap
- [x] **Phase 2** — Deity-as-Quest (Kyne proof slice)
- [ ] **Phase 3** — ActionRouter + first Story Manager event
- [ ] **Phase 4** — Origin, stance, rivalry, tier boons
- [ ] **Phase 5** — MCM
- [ ] **Phase 6** — Second deity (Talos) — scalability proof
- [ ] **Phase 7+** — Full deity roster, ritual quests, tier-3 questlines

---

## Phase 0 — Cleanup ✅

**Goal:** Clear out the old architecture so the new one can be built on a clean slate.

Deleted the pre-rename `PDV_MasterQuest` quest record, script, and compiled binary. Verified the rename to `PDV__ManagerQuest` was clean with no orphan references. At the end of this phase, the ESP had no PDV-namespaced records at all — a true blank slate.

---

## Phase 1 — Data Model Swap ✅

**Goal:** Replace the single `DevotionLevel` global and three generic combat/social/lifestyle buckets with a per-deity StorageUtil store and a set of mirror globals that vanilla CK Conditions can read.

The old model couldn't track more than one deity at a time and had no way to express that Mara cares about social behavior but not combat. The new model stores piety per deity via StorageUtil (keyed by deity FormID), with three mirror globals (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) shadowing the active patron's values. The manager script was refactored to expose a clean API: `AwardPiety`, `GetPiety`, `RecomputeTier`, `RefreshPatronMirrors`. Verified in-game via console.

---

## Phase 2 — Deity-as-Quest ✅

**Goal:** Make "deity" a first-class object in the engine, not a hardcoded value. Prove the architecture with Kyne before building anything else.

Each deity is now a standalone persistent Quest form running a script that extends `PDV_DeityBase`. The base class defines the contract: `ScoreAction()` (returns a piety delta for a given event), `OnTierChange()` (grants/revokes tier boon spells), `OnPatronStart/End()`. `PDV_Deity_Kyne` implements the first rubric — beast kills cost piety (-3), humanoid combat and shouting earn small amounts (+0.5 / +0.25), sleeping outdoors earns piety (+0.5).

The manager's `ProcessDawn()` loop now iterates `PDV_FLST_AllDeities`, consolidates daily scratch into persistent piety, and fires tier transitions. Adding deity #2 in Phase 6 will require only a new script, a new quest form, and appending to the FormList — no changes to the manager.

Runtime-verified in-game: patron activation, mirror global tracking, dawn clamping (+/-5/day), tier crossing at piety 10.

---

## Phase 3 — ActionRouter + First Story Manager Event

**Goal:** Wire the game's actual events into the piety system. After this phase, killing a hostile wolf or a bandit will meaningfully move piety in real gameplay — no more console-only testing.

A persistent `PDV_ActionRouter` service quest sits between Story Manager and the deity roster. Story Manager fires a small non-persistent receiver quest (`PDV__SM_KillActor`) on Kill Actor events; the receiver calls the router and resets itself. The router classifies victims (hostile beast vs. hostile humanoid) using CK-wired keywords, guards against `None` casts, and fans the result to every deity via `ScoreAction()`. Only `PDV.PietyToday` (the daily scratch) is written during live events — persistent piety, tier transitions, and mirror updates remain owned by dawn.

First slice is player-direct kills only. Follower kills, traps, and summons are out of scope until the base path is proven stable.

---

## Phase 4 — Origin, Stance, Rivalry, Tier Boons

**Goal:** Make the player's race matter theologically, and make tier transitions feel mechanically meaningful.

`PDV_Origin` runs once at game start, reads the player's race, and writes a stable race index to `PDV_GLO_OriginRace` (0–9, one per playable race). Each deity quest carries a 10-element stance array — one value per race — encoding `NATIVE` (full piety gain), `FOREIGN` (half gain), `TABOO` (three-quarter gain, optional NPC reactions), or `HOSTILE` (full gain, but triggers the rivalry ledger). When a `HOSTILE` worship action fires, the router also drains piety from a defined rival deity — an Altmer worshipping Talos erodes their standing with Auri-El; an Orsimer pursuing Boethiah costs Malacath piety in both directions.

Tier boon spells (Seeker / Devoted / Champion) are authored in CK and wired as properties on each deity. `OnTierChange()` grants and revokes them automatically at dawn.

Design artifacts for this phase now exist under `references/phase4/` in the docs workspace and are mirrored under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\`. They define the first-pass race signal matrix, stance matrix, Daedric race-by-Prince matrix, and the validation rules that keep those three aligned.

---

## Phase 5 — MCM

**Goal:** Give the player a readable UI and give developers a debug interface without the console.

A single MCM quest iterates `PDV_FLST_AllDeities` and auto-generates panels. The *Status* page shows current piety and tier per deity. The *Patron* page lets the player pick or change their patron. The *Tuning* page exposes global gain multiplier and decay rate. The *Debug* page lets developers force-set piety, trigger tier transitions, reset a deity, and control trace verbosity — replacing most of the current `SetPQV` console workflow.

---

## Phase 6 — Second Deity (Talos)

**Goal:** Prove the architecture actually scales. Adding deity #2 should take hours, not days.

Duplicate `PDV_Deity_Kyne.psc` as `PDV_Deity_Talos.psc`, rewrite the rubric (e.g. reward open defiance of Thalmor, penalize compliance with the White-Gold Concordat), set Altmer stance to `HOSTILE` with Auri-El as the rival, wire to the existing Story Manager kill node where appropriate, and append the new quest to `PDV_FLST_AllDeities`. If this phase is fast, the architecture has paid for itself.

---

## Phase 7+ — Full Roster, Ritual Quests, Tier-3 Questlines

**Goal:** Expand to Wintersun-comparable deity breadth (25–35 deities), covering the Nine Divines with Nordic variants, Daedric Princes, and the obscure pantheons (Yokudan, Khajiit, Hist/Sithis, Orsimer). Tier-3 Champion status for each deity unlocks a short questline or ritual — this is where the "harder to earn" design intent becomes content.

Scope and sequencing to be defined once the Phase 6 scalability proof is complete.
