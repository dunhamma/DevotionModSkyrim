# Decisions Awaiting Owner — Living Deities research

The program ran M0→M4 autonomously (you were asleep; instruction: defer questions,
automate). Every fork below was resolved with a **sensible default so work could
proceed** — none is locked, all are cheap to change since nothing is implemented.
Skim and override anything you dislike; I'll fold changes into the M2/M4 docs.

## A. Mood model tunables (`02_mood_model.md`) — ✅ RATIFIED (owner, 2026-06-09)
All four accepted as recommended for LD-P1. **LOCKED.**
1. **EWMA `alpha`** — default **0.15** (~4-day half-life); Daedra higher (0.20–0.25), patient Aedra lower (0.10). ✅
2. **Band thresholds** (asymmetric): Wroth [−100,−40) · Cool [−40,+10) · Pleased [+10,+55) · Exalted [+55,100]. ✅
3. **Stance caps the mood ceiling** (FOREIGN→max Pleased; TABOO/HOSTILE→max Cool unless curse/commitment active). ✅
4. **Materialized decaying modifiers** deferred to LD-P2; LD-P1 ships the scalar EWMA only. ✅

## B. Scope & pilot (`02_mechanism_shortlist.md`, `04_living_deities_architecture.md`)
5. **LD-P1 scope** = mood EWMA + bands · active patron pool · band-cross omens · mood-scaled boon · **one** demand type. *Agree this is the right MVP slice?*
6. **Pilot lock = Kyne (Aedra) + Hircine (Daedra)** — chosen to reuse the most already-proven content. *Agree, or prefer a different pairing (e.g. Mara + Sanguine)?*
7. **Public `PDV_ModMood` patch API** (lets the community wire any quest to a deity's mood) — currently **Backlog**. *Pull it earlier, or leave in Backlog?*

## C. Diegetic-UI dependency (settled, recorded for confirmation)
8. Engines (Prisma, OAR) = **hard-installed, never bundled**; your content (views, bridge DLL, animations) = **bundled**; the summonable panel = **soft-with-fallback**. You endorsed "go with your recommendation." *Confirm — and note this only matters whenever the engine ships, since it's not a V1 requirement.*

## Reality check
- This is **research only** — no Papyrus/CK/ESP changes were made. The architecture
  (`04_living_deities_architecture.md`) is a draft spec, not built.
- M3 feasibility is **source-grounded**, not in-CK/in-game proof (no Creation Kit or
  Skyrim runtime in the cloud session). Each mechanism lists the runtime proof still
  required for a future in-CK session.
- Headline good news: the LD-P1 MVP is **recomposition of mostly-live PDV code**
  (dawn consolidation, commitment engine, `SendPrismaEventToast`,
  `SyncPatronBoonsToTier`, `PDV_T3DailyLowHealthSaveEffect`, `ScoreRepeatableAction`).

## Suggested next step when you're back
Ratify A+B (≈5 min), then either: (i) I open an **in-CK/in-game proof** task for the
Kyne+Hircine LD-P1 slice, or (ii) we keep this purely as a design dossier and you
schedule the build later. Your call — I won't start implementation without it.
