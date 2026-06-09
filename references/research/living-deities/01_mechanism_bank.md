# M1 — Mechanism Bank (deduplicated reusable patterns)

The cross-cutting, deduplicated library distilled from `01_teardown_dossier.md`.
Each pattern names its source(s), the technique, PDV's use, and the channel/driver it
serves. This is the direct hand-off to **M2** (shortlist + mood model).

## A. State & storage patterns

1. **Storage singleton** *(Pilgrim `MAG_BlessingStorageScript`)* — one persistent quest holds a few pointers; zero globals, no save bloat. → PDV per-deity mood/demand state lives on `PDV_DeityBase` + StorageUtil, not globals. Already PDV's pattern; M0 confirmed.
2. **Scalar-on-unused-AV** *(Wintersun `VoicePoints`)* — store a tracked float on an unused actor value for native polling. → minor; PDV uses StorageUtil instead (no conflict surface). Note the *conflict* lesson: never co-opt a shared AV.
3. **Rotating "recent events" buffer** *(Pantheon circular buffer; CK3 stamped modifiers; Sims moodlet pool)* — keep the last N `{eventType, ts, deity, tag}` entries with expiry. → **the concrete data structure behind the B1 mood EWMA** — recent acts contribute, then drop out of the window.
4. **Config-as-spell-presence** *(Pantheon)* — encode toggles as dummy-spell presence to avoid an MCM hard-dep. → fallback if we keep MCM optional.

## B. Mood model patterns (B1 — the core new state)

5. **Banded threshold events, not continuous punishment** *(CK3 stress; Sacrosanct stages)* — the meter is silent between bands; **crossing a band fires** a demand/omen/intervention. → validates the EWMA-bucket design (Wroth/Cool/Pleased/Exalted); events fire only on crossings.
6. **Event-stamped, decaying opinion modifiers** *(CK3)* — every act logs a named, inspectable, self-decaying modifier. → **the recommended implementation of B1**: the EWMA is *materialized* as a short list of decaying modifiers per deity → gives a free, narrative, debuggable audit trail and the diegetic "why" for omens.
7. **Multi-dimensional per-deity value profile → net scalar** *(Pillars dispositions/Holy Radiance; CK3 trait valence)* — track behavior *dimensions*; each deity weights them; net scalar drives boon power. → **the recommended A4 formula** and the per-deity authoring table (2-3 favored / 1-2 disfavored tags); maps onto PDV's existing approve/disapprove profiles + stance matrix.
8. **Interpret pattern, never tally acts** *(Black & White — north star)* — react to who/why/recently via behavior-tagging on events. → the philosophical guardrail; PDV's stance-adjusted deltas + act-tags already encode this; mood EWMA adds recency.
9. **Ranks/sustain, not raw points** *(Pillars)* — a single act doesn't move a dimension; sustained pattern advances a rank. → smoothing on the EWMA so one murder doesn't flip a Prince.
10. **Decay-as-absence** *(Wintersun decay; Sims need decay)* — mood/need drifts toward neutral/negative when the player is absent. → PDV already has decay/neglect; mood decays toward neutral via the same dawn pass.

## C. Demand patterns (A1)

11. **Unmet-need → autonomous demand** *(Sims)* — a separate decaying "need" meter; when it reds out the agent acts on its own. → **A1's trigger**: a per-deity *expectation* meter (separate from mood) decays; on threshold the god issues a demand. Authored per-deity decay rates.
12. **Single act resets to zero** *(Sacrosanct feeding)* — one satisfying act undoes accumulated displeasure/need. → fulfilling a demand/tithe resets the expectation meter and lifts displeasure stage.
13. **Public distribution API for community content** *(Gods & Worship patch hub)* — expose `PDV_ModMood(deityKeyword, delta, context)`; tiny shim ESPs wire any quest. → scalable A1/B1 authoring surface; PDV's existing quest-reaction matrix is the first-party version of this.
14. **Material tithe via item injection** *(Pilgrim `OnInit`; Gods & Worship offerings)* — inject deity items into vendor/loot lists; offer at shrine. → A1 material-tithe pathway.
15. **Stage-gated demand specificity** *(Serana DAO)* — low-stage = generic ask; high-stage = personal, history-referencing demand. → couples A1 to the B4 bond.

## D. Omen patterns (A2)

16. **XMarker + `PlaceActorAtMe` + self-cleanup** *(Sands of Time/Genesis)* — spawn a themed creature at a filtered marker, delete after a tuned lifetime; keyword-flag for cleanup. → animal-behavior omens (stag/crow/wolf), ~3 scripts.
17. **Sleep-probability dream check** *(Sands of Time sleeping encounters)* — `OnSleepStart` probability scaled by state. → the A2 **dream channel** (PDV already hooks `OnSleepStart`).
18. **World-state as mood readout** *(Black & White)* — ambient weather/light/wildlife shift with the god's disposition. → ambient A2 (Meridia-pleased brighter; Molag-Bal-wroth shadowed interiors) via the `DiegeticDirector`.
19. **Object swap for ambient signal** *(Base Object Swapper)* — swap props in deity-tagged cells, scriptless. → A2 ambient props.
20. **Diegetic-but-quiet cue** *(SoT pairing; PDV surfacing ladder)* — pair each omen with a *subtle* notification, not an explainer popup.

## E. Intervention patterns (A3)

21. **Conditioned-MGEF clutch** *(Andromeda)* — `IsInCombat && Health%<0.15` native conditions, zero script. → A3 clutch-save/divine-luck, wrapped in a `mood >= Favorable` gate.
22. **Sacrifice / replace-a-rival-boon** *(Hades)* — a god overwrites a rival's standing boon (more potent), souring the spurned god. → A3 that *is* a B3 act; the marquee "living rivalry" moment.
23. **Domain-flavored effect** *(Hades kits; CK3 trait)* — each deity's intervention keyed to its domain, never generic.
24. **Active patron pool (4-of-N)** *(Hades godpool)* — only recently-relevant deities can fire; others dormant. → **the master noise filter** across A1/A2/A3, essential for a 42-deity roster.

## F. Escalation & anti-spam (cross-channel — the highest-value synthesis)

25. **Staged state machine with ability-bundle swap** *(Sacrosanct/Growl)* — named stages; each swaps one boon/penalty bundle at the transition (not per-frame). → Daedric displeasure ladder; A4 mood bands.
26. **Interval-shortening escalation** *(Growl)* — the timer loop shortens at higher stages → urgency without low-stage spam. → "the master grows impatient."
27. **The anti-spam triad** *(SoT + Growl + Hircine's Ring)* — (a) global **min-cooldown + combat-check before firing**, (b) **interval-shortening** by severity, (c) **keyword-gate** suppressing terminal events (= a "completed arc" flag). → apply to ALL of A1/A2/A3. PDV already ships `ScoreRepeatableAction()` (day-cap + cooldown) and the `Quiet/Noted/Marked` ladder — this triad slots onto them.
28. **MCM density master-slider** *(SoT/Genesis)* — one "omen/intervention density" slider scales every cooldown; 0 = off. → respects players who dislike interruptions.

## G. Distribution & compatibility (B3 + ambient)

29. **Data-driven scriptless distribution** *(SPID/KID/BOS)* — INI-configured, lazy at load, last-in-load-order, no save interaction, no orphans. → **the canonical "authorable not opaque" surface** for faith-aware NPCs (B3), keyword minting (KID), and ambient props (BOS); conflict-light vs NPC overhauls. **Pair with a runtime Papyrus MGEF condition** reading a `PDV_*` global so distributed auras respond to live mood.

## H. Bilateral bond (B4)

30. **Stage-gated content pools + dual (time-OR-ritual) gate** *(Serana DAO)* — relationship stages gate which events fire; advance by sustained time OR a completed ritual. → the patron bond ladder; gates A1-A4 availability.
31. **Authored reminiscence flag** *(Serana DAO; CK3 stamped events)* — set a flag at a significant act; later dream/omen text references it by name. → "a god who has been watching *you*," text-only, in-scope.
32. **BDI desire-profile personalization** *(Black & White)* — the god prefers the demand/boon type this player keeps fulfilling. → cheap personalization of authored arcs without branch explosion.
33. **Dread / Dominance as an orthogonal axis** *(CK3 Dread)* — submission-type Princes (Molag Bal) use a separate "you submit, not worship" axis with behavioral-flip bands. → a B4 expansion for coercive Daedra.

---

## PDV's white space (the differentiation thesis, evidence-backed)
Across **every** Skyrim faith mod studied (Wintersun, Pilgrim, Gods & Worship, Pantheon), the god is a **passive ledger**: favor moves only because the player acted, and the god **never initiates**. **A3 interventions, B2 world-context, B3 inter-deity politics, and B4 authored arcs have *zero* working precedent in the faith-mod space.** Every mechanism PDV needs to *invert the agency* exists — but only in **adjacent** mods (EnaiSiaion curses, EnaiSiaion stones, SoT, SPID) and **other games** (Hades, CK3, Pillars, Sims, Black & White). PDV's novel, defensible position is to be the first to assemble them **into a faith system, for the whole pantheon including Daedra, authored in data**.

## Hand-off to M2 — recommended implementation models
- **B1 mood:** EWMA over `clampedToday` (PDV's existing daily stance-adjusted delta), **materialized as CK3-style decaying modifiers**, bucketed into 4 bands (CK3 banding); per-deity weighting via the **PoE disposition formula** over PDV's existing approve/disapprove tags; **ranks/sustain** smoothing; recency = EWMA.
- **A1 demand:** a **separate Sims-style expectation meter** (per-deity decay), trigger on band-cross, **mirror the commitment-offer engine** (`EvaluateFormalCommitmentOffer`), new `PDV.Demand.<deity>.*` namespace, **single-act reset**, stage-gated specificity, optional public `PDV_ModMood` API.
- **A2 omen:** extend `DiegeticDirector.Dispatch()` with an `omen` eventClass; dreams on `OnSleepStart`; animals via XMarker+`PlaceActorAtMe`; ambient via BOS; world-state shift à la Black & White; anti-spam triad + density slider.
- **A3 intervention:** Andromeda conditioned-MGEF gated by `mood>=Favorable` + `RegisterForSingleUpdateGameTime` cooldown + `Marked`-tier dispatch; **Hades Sacrifice** as the flagship B3 intervention; domain-flavored per deity.
- **A4 mood-boon:** PoE net-scalar formula → MGEF magnitude read from `PDV.Mood.<deity>`; Sacrosanct stage-bundle swap for band changes; respect the one-active-boost cap.
- **B2:** mood-weight table over `location-theology-map.csv` + lunar substrate + `OnWeatherChange`; SoT location-keyword filter for omen appropriateness.
- **B3:** surface the existing rivalry ledger as a narrated event + Hades Sacrifice; SPID faction auras for ambient; persistent authored inter-deity opinion table.
- **B4:** Serana-style stage-gated bond + dual gate + authored reminiscence flags; Growl keyword-gate for arc capstones; Dread axis for coercive Princes.

**Active patron pool (Hades) is the master filter that makes a 42-deity living pantheon tractable — likely the first thing M2 should lock.**
