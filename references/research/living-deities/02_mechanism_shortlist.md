# M2 — Mechanism Shortlist & Scoring

**Status:** COMPLETE. Scores the M1 mechanisms and force-ranks them into engine
build phases. Pairs with `02_mood_model.md`.

> **LD-P1 / LD-P2 / Backlog are engine build phases, NOT the mod's release V1.**
> Per the owner, the Living Deities engine is not a V1-ship requirement; this is
> forward sequencing for when the engine is built.

## Scoring axes
- **Author** = authorability in the existing CSV/JSON pipeline (H/M/L)
- **Tech** = footprint (Vanilla / PO3 / soft-dep / native)
- **Daedra** = parity (Yes / Partial)
- **Notice** = player-noticeability (H/M/L)
- **Risk** = build/UX risk incl. spam (L/M/H)

| Mechanism (channel) | Author | Tech | Daedra | Notice | Risk | Phase |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| **Mood EWMA + bands (B1)** | H | Vanilla | Yes | (engine) | L | **LD-P1** |
| **Active patron pool filter (Hades)** | H | Vanilla | Yes | (engine) | L | **LD-P1** |
| **A2 omen on band-cross — dream + notification** | H | PO3 + soft-gated director | Yes | H | L | **LD-P1** |
| **A4 mood-scaled boon (PoE formula → MGEF)** | M | Vanilla | Yes | M | L | **LD-P1** |
| **A1 demand: single act-demand type (band-triggered)** | H | Vanilla | Yes | H | M | **LD-P1** |
| **A1 demand: tithe + pilgrimage + abstinence types** | H | Vanilla + KID | Yes | H | M | LD-P2 |
| **A1 expectation meter (Sims unmet-need)** | H | Vanilla | Yes | M | M | LD-P2 |
| **A3 clutch-save (Andromeda conditioned MGEF)** | M | Vanilla | Yes | H | M | LD-P2 |
| **A3 Sacrifice / rival-boon replace (Hades) = B3** | M | Vanilla | Yes | H | M | LD-P2 |
| **Daedric displeasure escalation (Sacrosanct/Growl staged)** | M | Vanilla | Yes | H | M | LD-P2 |
| **B2 world-context mood weights (location/lunar/weather)** | H | Vanilla | Yes | M | L | LD-P2 |
| **B3 narrated rivalry (surface existing ledger)** | M | soft-gated director | Yes | M | L | LD-P2 |
| **A2 animal-behavior omens (SoT XMarker spawn)** | M | Vanilla | Yes | H | M | LD-P2 |
| **B3 faith-aware NPC auras (SPID/KID/BOS)** | H | soft-dep (SPID/KID/BOS) | Yes | M | L | LD-P2 |
| **A2 ambient world-state shift (Black & White)** | M | PO3 weather + soft-gate | Yes | M | M | Backlog |
| **B4 stage-gated patron bond + reminiscence (Serana DAO)** | M | Vanilla | Yes | H | M | Backlog |
| **B4 BDI desire-profile personalization** | L | Vanilla | Yes | L | M | Backlog |
| **Dread/Dominance axis for coercive Princes (CK3)** | M | Vanilla | Yes | M | M | Backlog |
| **Public `PDV_ModMood` patch API (Gods & Worship)** | H | Vanilla | Yes | (ecosystem) | L | Backlog |
| Future buckets (theophany, festivals, alliances, schism, divine-debt, champions, prophecy, relic resonance, divine-climate, afterlife) | — | varies | Yes | varies | — | Backlog (`04_future_buckets_backlog.md`) |
| Voiced theophany | — | AI/voice | Yes | H | H | Post-engine (owner-planned separately) |

## Phase rationale
**LD-P1 — "the god notices and reacts" (smallest provable slice).**
Mood EWMA + bands (the foundation) → patron pool (the noise filter) → band-cross **omens** (the most visible "it noticed me," lowest risk: no gameplay mutation, reuses the director) → **mood-scaled boon** (proves mood *matters* mechanically) → **one A1 act-demand type** (proves *god-initiation* — the core agency inversion — detected via the existing 37 act-tags, fulfilled→single-act reset). All Vanilla/PO3, all authorable, all Daedra-parity, all low/med risk. Everything attaches to `ProcessDawn()`, the `DiegeticDirector`, `SyncPatronBoonsToTier`, and `ScoreRepeatableAction` — proven seams.

**LD-P2 — "the god asks and acts."** Full demand grammar (tithe/pilgrimage/abstinence + expectation meter), interventions (clutch-save + the marquee **Hades Sacrifice** rival-boon-replace), Daedric displeasure escalation, world-context weighting, narrated rivalry, animal omens, SPID faith-ambient. Higher noticeability, more moving parts; built on the LD-P1 foundation.

**Backlog.** Authored bilateral arcs, BDI personalization, the Dread axis, the public patch API, and the future-bucket inventions (`04_future_buckets_backlog.md`). Voiced theophany is post-engine (owner-planned separately; out of scope here).

## Pilot lock recommendation (for the M4 architecture doc)
**Kyne (Aedra) + Hircine (Daedra).**
- **Kyne** has PDV's most-proven content (commitment-signal tracking, neglect spell, shout hooks) — least new scaffolding to demonstrate the Aedra path.
- **Hircine** reuses the most existing Daedric proof (Phase 13 Hircine/werewolf pilot) and the curse-state hooks (`OnLycanthropyStateChanged`), and maps 1:1 onto the Sacrosanct/Growl staged-displeasure model (days-since-hunt). The strongest Daedric demonstrator with the least new code.

This pairing proves Aedra + Daedra parity while reusing the maximum amount of already-shipped, already-proven PDV machinery — exactly the project's evidence-gated, lowest-new-surface-area discipline.

## Exit-gate status — SATISFIED
Every LD-P1 mechanism is authorable in the existing toolchain on a Vanilla/PO3
footprint; the mood model has a single agreed definition (`02_mood_model.md`);
Daedra parity is confirmed for every LD-P1 item; the pilot lock names one Aedra +
one Daedra. The natural **owner decision checkpoint** is here (post-M2): ratify the
mood tunables + pilot lock + LD-P1 scope before the expensive M3 spikes / M4 doc.
