# B4 Authored Arcs -- Charter

**Status:** DESIGN COMPLETE, 2026-06-10. Bucket 8 subsumed.
Build deferred behind LD-P2 smoke; P1 pilot = Kyne bond ladder + reminiscence only.

---

## 1. What B4 is and why it matters

Every Skyrim faith mod studied is a **passive ledger**: the god has no relationship with
the player, only an accumulated score. B4 closes that gap: a **curated, bilateral bond**
where a specific deity has been watching THIS player and can prove it. Relationship depth
is tracked independently of piety standing, surfaces through text/diegetic channels only
(no AI voice -- explicitly out of scope for V1), and gates increasingly personal contact.

This has zero working precedent in the Skyrim faith-mod space. It is the mechanism that
most converts PDV from a "score tracker with reactions" to a living patron.

---

## 2. Bond model overview (four interlocking pieces)

### 2.1 Bond-stage ladder (Serana DAO)
A per-deity stage scalar, **orthogonal to tier**:

| Stage | Int | What it means | What becomes available |
|---|:-:|---|---|
| Unnoticed | 0 | default; no patron relationship | nothing |
| Noticed | 1 | the deity has registered your existence | generic omens; mood-band demands |
| Tested | 2 | the deity has made and watched one demand cycle | personal demand variants; milestone callbacks |
| Bound | 3 | sustained investment; a real patron bond | reminiscence-tagged dreams; named arc text |
| Beloved/Feared | 4 | deep bond; Aedra=Beloved, coercive Prince=Feared | capstone arc texts; prophecy-chain eligibility (Bucket 8) |

Advance gate is **dual (time-OR-ritual)** per the Serana DAO pattern: a stage advances if
the player has been at the current tier AND band >= Pleased for `N` dawn cycles (authored
per deity) OR has completed a designated ritual/demand at the current stage (an authored
tag in `PDV_DemandTable.csv` column `bond_advance_tag`). One advance per stage; no
speed-run shortcut at stage 4 -- the capstone requires both sustained time AND a
terminal arc demand.

Tiers measure earned standing (piety). Stages measure relationship depth (history).
A high-tier patron may still be Noticed if the player never lingered at a band.

### 2.2 Reminiscence flags (Serana DAO + CK3 stamped events)
At significant matrix beats (curated quest completions that carry `milestone` magnitude
in `PDV_QuestReactionMatrix_Full.csv`, plus terminal demand fulfillments), the system
sets a **flag in a `PDV.Bond.<deity>.Remi.*` StorageUtil namespace**. Later dream, omen,
and journal text for that deity can reference those flags by key.

The god does not generically react to "you did quests." The god says: "In the ruins of
Saarthal, you chose mercy." The player earns that text only if the flag was set.

No new runtime system: just a StorageUtil write at existing `ApplyQuestReaction` and
`FulfillDemand` call sites, and a conditional text-key lookup at dream/omen dispatch.

### 2.3 BDI demand personalization (Black & White)
Per deity, a small counter of fulfilled demand types is kept at
`PDV.Bond.<deity>.Prefer.<demandType>` (int, incremented on each `FulfillDemand`).
`SelectDemandKey` (LD-P2, `05_ld_p2_architecture.md` 3.2) reads this as a **bias
weight** when choosing between the pipe-list of demand keys: demand types the player has
fulfilled more often are weighted higher. This is an INPUT to the existing LD-P2
`SelectDemandKey`, not a fork. The prefer counts are bounded (e.g. max 5) to prevent
runaway bias; ties broken by trigger type.

Effect: a player who habitually fulfills hunt demands gets offered hunt demands more
often; a player who always chooses the mercy demand gets offered that variant more. The
god feels like it has learned you, without any new authored branches.

### 2.4 Dread axis -- coercive Princes only (CK3 Dread)
For Molag Bal (and design-ready for Boethiah, Vaermina -- see 9_authored_arcs_architecture.md),
a **second orthogonal scalar** `PDV.Bond.<deity>.Dread` [0, 100] runs in parallel to mood.
It is explicitly NOT a sub-case of mood; it is a different dimension of the god-player
relationship.

Dread accrues via:
- **Submission acts**: fulfilling a Molag demand during a Wroth band (yielding under threat)
- **Threat events**: Molag's displeasure escalation fires without the player countering it
- **Voluntary abasement**: a curated ritual demand whose `demand_type` = `submission`

Dread decays very slowly (authored `dread_decay_rate_per_dawn`; much slower than mood).
It does not decay to zero unless a hard defiance act fires (a curated matrix beat tagged
`defy_molag` and the player is at stage >= Bound).

Behavioral bands:

| Dread band | Range | Behavior flip |
|---|---|---|
| Defiant | 0--24 | Molag issues threats, mood swings volatile |
| Compliant | 25--59 | Demands shift to exploitation type; submission omens |
| Subjugated | 60--84 | Bond stage 3/4 text shifts to dominance register |
| Enslaved | 85--100 | Terminal arc; stage 4 capstone locked behind escape demand |

The Dread axis is NOT coupled to piety or mood. A high-Dread player may be high-piety
(they satisfied every demand) or low-piety (coerced but absent). The axis purely tracks
the submission/defiance behavioral record.

**Note:** Molag does NOT have a `PDV_Deity_*` face in live source today -- only
`PDV_DaedricPath_Molag extends PDV_DaedricPathBase`. The Dread pilot requires the same
greenfield actor pattern as `PDV_Deity_Hircine` (owner ruling precedent). This is
design-complete but **build-deferred** pending LD-P1/LD-P2 smoke.

---

## 3. Bucket 8 -- Prophecy / quest-chain mood-gating: SUBSUMED

Bucket 8 (`04_future_buckets_backlog.md`: "long demand chains that branch on sustained
mood -- the seed of authored arcs") is fully subsumed by this charter. The arc-capstone
layer is: stage 4 (Beloved/Feared) + a sustained Exalted (or Subjugated for coercive
Princes) band for the authored `bond_advance_days` window + a terminal arc demand whose
fulfillment unlocks a unique journal entry and a capstone omen dispatch. The "branching
on sustained mood" mechanism is the bond stage advance gate (mood as a precondition).
Long demand chains are authored as sequential `bond_advance_tag` demands across stages.
No separate Bucket 8 build item remains.

---

## 4. Novelty claim (evidence-based)

The teardown matrix (`01_teardown_dossier.md`) confirmed B4 has zero strong precedent in
the Skyrim faith-mod space (Wintersun, Pilgrim, Gods & Worship, Pantheon: all passive
ledgers). The pattern sources are explicitly from OTHER domains: Serana DAO (stage
gates), CK3 (Dread + stamped events), Black & White (BDI bias). PDV is the first to
assemble all four sub-mechanisms (stages, reminiscence, personalization, Dread) into a
faith system for the full pantheon including Daedra.

---

## 5. P1 pilot scope

**In scope for B4 P1:**
- Kyne bond-stage ladder (stages 0-3; stage 4 deferred to content beta)
- Kyne reminiscence flags: `the_hunt` matrix milestone + `kyne_mercy` demand fulfill
- Bond-advance text keys for stages 1-3 (toasts + one dream per stage)
- BDI prefer counters wired into `SelectDemandKey` for Kyne (feed the LD-P2 selector)

**Design-complete, build-deferred:**
- Dread axis for Molag Bal (requires `PDV_Deity_Molag` greenfield actor, same cost as
  Hircine)
- Stage 4 / capstone arc for all deities
- Personalization bias for Hircine (deferred until LD-P2 smoke confirms demand variety)
- Reminiscence for Daedric path deities (awaits LD-P2 demand loop for them)

**Deferred to content beta / 1.0:**
- Per-race dream text variants (the architecture supports it via existing race-response
  pattern in `PDV_DaedricPath_Molag.ShowRaceResponseForPlayer`)
- More than 2 reminiscence flags per deity
