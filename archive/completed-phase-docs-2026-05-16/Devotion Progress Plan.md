# Devotion Progress Plan

## Status Checklist

- [x] **Phase 0** — Cleanup
- [x] **Phase 1** — Data model swap
- [x] **Phase 2** — Deity-as-Quest (Kyne proof slice)
- [x] **Phase 3** — ActionRouter + first Story Manager event
- [ ] **Phase 4** — Origin, stance, rivalry, tier boons
- [ ] **Phase 5** — MCM
- [ ] **Phase 6** — Talos + Auri-El (first hostile-path / rivalry-ledger proof; scalability template as secondary benefit)
- [ ] **Phase 7+** — Full deity roster, ritual quests, tier-3 questlines

---

## Roadmap Confidence Tiers

Not every future session deserves the same level of detail. The roadmap below is layered by confidence so future-me doesn't mistake a sketch for a commitment, or a directional theme for a CK walkthrough.

- **High-fidelity (next 1–2 sessions).** The level of detail in `PDV_Phase4_CK_Steps.md` and `PDV_Phase6_Talos_AuriEl_CK_Steps.md` — specific records, property tables, test scenarios, exact CK-side wiring, named test actors. If a session is about to start, this is what its doc should look like.
- **Mid-fidelity (sessions 3–5).** Sketch MCM pages by name, identify the reads and OID structure, commit to scope but not content. Enough to know what the session is for, not yet enough to walk straight into CK without thinking. `PDV_Phase5_CK_Steps.md` is the current example of mid-fidelity that's starting to firm up.
- **Directional themes (sessions 6+).** One paragraph each, no checkbox commitment. These exist to keep the long horizon visible without pretending it's been scoped. They graduate to mid-fidelity once the validation gate above (live rivalry + MCM fidelity) is cleared.

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

## Phase 6 — Talos + Auri-El (Coupled Hostile-Path Proof)

**Goal:** Prove the rivalry ledger works under live event volume against a real hostile target — not just deity duplication. The v2.2 revision (2026-05-14) coupled Talos with Auri-El because the §12.3 rivalry plumbing needs an actual rival deity on the receiving end of the drain, not a hypothetical one. The scaling-template aspect (Kyne → Talos as evidence that adding deity #2 takes hours, not days) is still real, but it's now the secondary benefit; the primary milestone is the first hostile-path validation.

Duplicate `PDV_Deity_Kyne.psc` as `PDV_Deity_Talos.psc`, rewrite the rubric (e.g. reward open defiance of Thalmor, penalize compliance with the White-Gold Concordat), and stand up `PDV_Deity_AuriEl.psc` as the minimum-viable Altmer foundation deity that can absorb the rivalry drain. Set Altmer stance to `HOSTILE` on Talos with Auri-El as the rival, wire to the existing Story Manager kill node where appropriate, and append both quests to `PDV_FLST_AllDeities`. If Talos worship visibly erodes Auri-El piety on an Altmer save, the architecture has paid for itself.

---

## Phase 7+ — Full Roster, Ritual Quests, Tier-3 Questlines

**Goal:** Expand to Wintersun-comparable deity breadth (25–35 deities), covering the Nine Divines with Nordic variants, Daedric Princes, and the obscure pantheons (Yokudan, Khajiit, Hist/Sithis, Orsimer). Tier-3 Champion status for each deity unlocks a short questline or ritual — this is where the "harder to earn" design intent becomes content.

Scope and sequencing to be defined once Phase 6 is complete.

### Validation gate — when Sessions 8+ get drafted

Drafting anything past Phase 6 in high-fidelity form is gated on **both** of the following:

- **(a) Live rivalry-ledger validation.** Talos worship visibly erodes Auri-El piety on a real Altmer save in-game, under realistic event volume — not just a `SetPQV`-driven scratch update. This is what proves §12.3 rivalry plumbing under load, not in theory.
- **(b) MCM Status + Debug page fidelity.** The MCM has to be readable and operable at Phase 5's target quality before the deity roster scales. `SetPQV` console polling works fine against a single patron; it does not work against a 25–35 deity roster. The MCM is the prerequisite operational surface, not a nice-to-have.

Without both, Sessions 8+ should stay directional (one paragraph each) rather than drop into the level of detail in `PDV_Phase4_CK_Steps.md` or `PDV_Phase6_Talos_AuriEl_CK_Steps.md`.

> Meta-note: `PDV_Architecture_v2.md` §9 currently has the "Phase 7+ — Out of scope for this migration document" line as its only out-of-scope framing. Once the in-flight `PDV_Architecture_v3.md` grilling session concludes, revisit whichever doc ends up owning the §9 phase plan and decide whether this gate framing belongs there too. Not editing v3 right now to avoid stepping on that grilling.

---

## Directional themes — sessions 6+

One paragraph each. These are placeholders that exist to keep the horizon honest, not commitments. They graduate to mid-fidelity once the validation gate is cleared.

### Lock contested lore items

A short list of theological calls that are currently fine as draft prose but will become bug surface the moment they're property data on a CK record. Locking now, before the data is authored, costs less than re-authoring later. The contested items are: Trinimac canon (pre- vs. post-Boethiah-eats-him, and how the cult survives in Orsimer worship); Talos/Altmer framing (does Auri-El register Talos at all, or is the rivalry one-way?); Hircine/Bosmer (is the Wild Hunt patronage or possession?); Malacath classification (Daedric Prince vs. ascended hero-god, and which framing the rivalry ledger uses); and Lorkhan/Shor/Sep/Lorkhaj equivalence (one entity with five faces, or five overlapping cults sharing a name?). Each of these should resolve before its corresponding race ESP is authored.

### Reconcile §12.4 vs `references/phase4/PDV_StanceMatrix.csv`

The v1.9 revision flagged §12 as "partially superseded" by the Phase 4 matrix work, but didn't actually do the reconciliation pass. The CSV is the working source of truth for stance authoring; §12.4 is older prose that may now disagree. Two outcomes are possible: §12.4 gets rewritten to point at the CSV (cheaper), or §12.4 gets demoted/removed entirely (cleaner but more disruptive). This should resolve before Phase 4 CK property wiring on additional deities.

### Decay model decision

Deferred since Phase 1, still unresolved. Phase 5's *Tuning* page needs a concrete answer before the MCM can expose a "decay rate" slider that means anything. The open question: is decay a flat per-day drift toward zero, a tier-gated drift (only Tier 1+ decays, Tier 0 stays at zero), or absent entirely (piety is monotonic until a player action moves it)? Each has different implications for "lapsed worshipper" UX and for the rivalry ledger's long-tail behavior.

### First race ESP — `PDV_Nord`

Currently invisible in the phase list, but the project's ESP structure lists nine race ESPs (`PDV_Nord.esp` through `PDV_Argonian.esp`) and the phase plan stops at Talos. The race-blessing / neglect spell layer plus race ESP authoring is an entire workstream that hasn't been scoped — it's not just "more deities," it's a new ESP topology with its own master dependency, its own property graph, and its own per-race signal authoring. `PDV_Nord` is the natural first cut because Kyne is already the proof slice. This deserves its own phase number once the gate clears.

### Phase 7 ritual quest pattern proof

Same logic Phase 6 used for deities: prove one ritual end-to-end, then fan out. Pick one Tier-3 Champion ritual (a Kyne-favoured outdoor vigil is the obvious candidate — leverages the existing outdoor-sleep signal), author it as a real quest with stages, triggers, completion conditions, and a tangible reward. If that one ritual works, the remaining ~25–35 follow the same template. If it doesn't, the "tier-3 unlocks a ritual" promise needs to be rethought before any other ritual is authored.
