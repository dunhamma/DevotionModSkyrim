# Divine Agency -- Feasibility Assessment

**Status:** Design dossier, 2026-06-11. Research only -- no Papyrus/CK/ESP changes.
**Honesty bar:** mirrors `03_feasibility.md` (LD-P1 feasibility): every seam is traced to a
real function name in the live PDV source. No in-game proof exists for any mechanism in this
dossier. CK and runtime proof remain required for each entry.

**Live source root:** D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/
**Note:** line numbers drift. Function names are the contract.

---

## Grounding: What Is Live in PDV Today

The divine-agency mechanisms all depend on LD-P1 infrastructure that is **not yet live** --
it is authored and compiled in the zen-allen-build worktree but has not been deployed or
in-game proven at the time of this dossier. The references below to mood namespace, band
constants, patron pool, and PDV_GLO_PatronMoodBand are LD-P1 seams confirmed in the
architecture dossier (`04_living_deities_architecture.md`) and feasibility dossier
(`03_feasibility.md`), not in the live shipped source.

What IS live in PDV__ManagerQuest.psc (confirmed by source inspection 2026-06-11):
- `SendPrismaEventToast(String, PDV_DeityBase, String, String, String)` (live :1245)
- `SurfaceTransition(String, String, String, Int, String)` (live :1307)
- `ApplyRivalryPenalties(PDV_DeityBase, Float)` (live :10094)
- `GetDeityFormOrNone(PDV_DeityBase)` (live :10128)
- `HasRecentCommitmentSignalDays(PDV_DeityBase, Int, Int)` (live :6814)
- `PDV_DiegeticDirectorService.Dispatch(String, String, String, Int, String)` (live :1320, via property :1282)
- `ScoreRepeatableAction(Int, Float, Int, Float)` on `PDV_DeityBase.psc` (live :283)
- `ProcessDawn()` (live :4065) with `RunDawnConsolidateScratch()` sub-phase (live ~:3896)

No PlaceActorAtMe, XMarker spawn, or SPID-related Papyrus exists in the PDV source -- those
are vanilla Papyrus (PlaceAtMe on ObjectReference) and SPID INI authoring respectively.

---

## Modality 1: Emissary Spawn (Bucket 1 -- Theophany)

**What it does:** on a mood band-cross or demand event, a transient themed NPC spawns
near the player, optionally delivers a toast/dialogue cue, and despawns after a lifetime.
Examples: a raven that circles and vanishes (Hermaeus Mora), a wandering beggar who offers
cryptic comment and leaves (Sanguine), a Vigilant who delivers Stendarr's displeasure.

**Live seam -- spawn:**
Vanilla Papyrus: `ObjectReference.PlaceAtMe(Form akFormToPlace, Int aiCount, Bool abForcePersist,
Bool abInitiallyDisabled)` returns `ObjectReference`. The calling form must be an
`ObjectReference` already present in the cell. PDV's manager quest is a QUST, not an
ObjectReference -- the spawn must originate from a pre-placed XMarker alias in the player's
cell or from the player actor reference itself.
- `Game.GetPlayer().PlaceAtMe(actorBaseForm, 1, false, false)` -- vanilla, no PDV seam needed.
- Spawn cleanup: `spawnedRef.Delete()` or `spawnedRef.Disable()` + `spawnedRef.Delete()` after
  a timed delay. SoT/Genesis pattern: spawn at XMarker, delete after lifetime via
  `RegisterForSingleUpdateGameTime(lifetimeDays)` + `OnUpdateGameTime`.
- No PDV precedent for PlaceAtMe or actor lifecycle management exists in the live source.
  This is **greenfield spawn plumbing**.

**Live seam -- trigger insertion:**
Cheapest insertion point: `OnMoodBandCross(deity, oldBand, newBand)` (LD-P1 seam, not yet
live -- see `04_living_deities_architecture.md` section 3.3). A new sub-call
`TrySpawnEmissary(deity, newBand)` fires after `SyncPatronBoonsToBand` on a down-cross to
Wroth or an up-cross to Exalted. Alternatively, the emissary can ride the demand
scheduler (`RunDawnProcessDemands`, LD-P1 seam) as a "demand delivery" -- the NPC
materializes to present the demand, not just a toast.

**Anti-spam:** a new StorageUtil key `PDV.Agency.Emissary.<deity>.LastFire` (float, gametime)
+ `PDV.Agency.Emissary.<deity>.Day` (int) mirrors the ScoreRepeatableAction pattern
(`PDV_DeityBase.psc:283`). Cap: once per devotion-week per deity per modality.

**Confidence:** MEDIUM. Vanilla PlaceAtMe is well-understood. The PDV insertion points
(OnMoodBandCross, RunDawnProcessDemands) are LD-P1 seams -- **no in-game proof of those
seams yet** (LD-P1 itself is unproven at time of this writing). Cell-load pitfalls are real:
if the player is in an interior cell with no exterior XMarker, PlaceAtMe from the player
actor will spawn the NPC inside the cell, which may be thematically wrong and may confuse
AI packages. A persistent alias pool (CK alias with Fill Type Unique Actor) is safer for
dialogue but requires authoring a custom aliased actor record per emissary type. Cost
comparison in section 4 below.

**Recomposition vs greenfield:** GREENFIELD on the spawn/lifecycle side. Recomposition on the
trigger and toast side (OnMoodBandCross + SendPrismaEventToast exist or are LD-P1 seams).

**In-CK/in-game proof still required:**
1. PlaceAtMe from player actor spawns emissary NPC in the correct cell at expected position.
2. Lifetime timer fires and Delete() executes cleanly (no orphan ref).
3. Spawn does not double-fire if the player enters/exits the cell (cell-load check).
4. OnMoodBandCross fires exactly once per band transition (LD-P1 proof dependency).
5. Anti-spam key persists across save/load.

---

## Modality 2: Congregation Aura (Bucket 6 -- Proselytizing)

**What it does:** SPID-distributes a keyword to NPC priests and faction members of the
player's patron deity. The keyword carries a MGEF (ability type) whose CK condition reads
PDV_GLO_PatronMoodBand. When the patron's band is Pleased+, the ability grants a disposition
bonus toward the player; when Wroth, a penalty. No per-NPC Papyrus scripts.

**Live seam -- SPID pattern:**
Canonically specced in `08_deity_politics_architecture.md` section 4. The pattern:
1. SPID INI file (e.g. `PlayerDevotion_Stendarr_CongregAura_DISTR.ini`), distributed keyword
   by ActorType/Faction/FormList.
2. Keyword carries an always-on Ability MGEF.
3. MGEF has a single CK condition: `GetGlobalValue(PDV_GLO_PatronMoodBand) >= 2` (Pleased).
   When true, applies a small FrenzyMagnitude / disposition modifier. When false (band < 2),
   the ability is inert (condition-gated effect, vanilla behavior).
4. No Papyrus. CK-only authoring after PDV_GLO_PatronMoodBand is live.

**Live seam -- global:**
`PDV_GLO_PatronMoodBand` is the LD-P1 global mirror (`04_living_deities_architecture.md`
section 2.3). It must be live and updated by `RunDawnUpdateMood` before any MGEF condition
can read it meaningfully. Before LD-P1 ships, a proxy global initialized to 2 (Pleased)
allows the CK/INI authoring to be validated in isolation.

**MGEF re-evaluation caveat (from B3 dossier):** `GetGlobalValue` in a CK MGEF condition
re-evaluates on NPC package change or cell reentry -- NOT frame-by-frame. The aura is
ambient texture, not real-time tracking. A patron's band may change at dawn but the NPC
disposition effect won't update until the player re-enters the cell or the NPC's package
transitions. This is acceptable and consistent with the B3 design decision.

**Confidence:** HIGH for CK authoring. The identical pattern is proven-in-design by the
B3 politics dossier (same author, same date, structurally identical). The remaining unknown
is runtime: does the SPID keyword distribute correctly to the intended faction NPCs, and does
the MGEF condition gate on the correct global value? Both are CK/in-game proof items.

**Recomposition vs greenfield:** RECOMPOSITION. Identical to the B3 SPID aura pattern.
New authoring only: one SPID INI, one keyword, one MGEF.

**In-CK/in-game proof still required:**
1. Keyword distributes to at least one target NPC after SPID loads (check NPC inventory
   keywords via console `sqv` or `GetAV`).
2. MGEF condition correctly reads PDV_GLO_PatronMoodBand and gates the disposition effect.
3. Disposition effect visible or measurable (check NPC relationship rank or reaction).
4. Effect updates after cell reentry when global changes value (confirm re-evaluation timing).
5. No conflict with NPC overhaul mods distributing the same NPC (SPID is last-in-order;
   verify no orphan keywords from prior-load overwrites).

---

## Modality 3: Champion / Rival Sponsorship (Bucket 7)

**What it does:** the deity sponsors a mortal NPC to embody its current mood. On a band-cross
event (Pleased: a Vigilant patrol materializes; Wroth: a cultist hit-squad is dispatched),
the NPC acts out the deity's posture toward the player for one scene. Distinct from A3e/A3f
(which are combat/piety interventions); this is the NPC-delivery body those interventions
can take when the deity acts through a mortal agent.

**Live seam -- trigger:**
Same as emissary: `OnMoodBandCross` (LD-P1 seam) + `TrySpawnChampion(deity, newBand)`.
For rival sponsorship: `ApplyRivalryPenalties` (live :10094) is the existing rivalry hook;
a new `TrySpawnRivalAgent(rivalDeity, appliedAmount)` could fire there on a threshold check,
mirroring the A3f sacrifice check pattern (`06_interventions_architecture.md` section 3.3).

**Live seam -- allegiance:**
A spawned NPC's team/allegiance is set via `Actor.SetRelationshipRank(akOtherActor, aiRank)`
(vanilla Papyrus) -- Friend (3) for patron-sponsored champions, Enemy (4) for rival-sent
cultists. Level scaling is not directly settable post-spawn; it must be authored into the
ActorBase record or use a leveled actor form. Tracking the deity's live mood band post-spawn
(so a champion "feels" the god's energy) cannot be done via per-frame MGEF global re-read
(engine limitation confirmed in `04_living_deities_architecture.md` section 3.4): boon
magnitude cannot live-read a global from an applied MGEF. Instead, the champion's ability
level is baked at spawn time -- read PDV_GLO_PatronMoodBand via a script-poll at the moment
`PlaceAtMe` fires, then select among authored ActorBase variants (e.g. a leveled actor form
with three tier slots: Cool/Pleased/Exalted). No per-frame polling required.

**Confidence:** MEDIUM-LOW. The spawn mechanics are identical to the emissary modality
(same PlaceAtMe greenfield). The added complexity is: (1) combat-capable NPCs require AI
package authoring (fight or follow behavior); (2) allegiance must be set correctly before
combat AI triggers; (3) the rival-agent path requires thematic NPC design per deity (a
Boethiah cultist squad is different from a Malacath war-party). Low confidence is driven by
authoring breadth and untested actor-lifecycle patterns, not Papyrus complexity. The
Papyrus surface is identical to emissary; the CK authoring surface is substantially larger.

**Recomposition vs greenfield:** GREENFIELD on spawn/allegiance/AI-package side. Recomposition
on trigger side (existing band-cross and rivalry hooks).

**In-CK/in-game proof still required:**
1. Spawned champion NPC has correct faction/allegiance post-PlaceAtMe.
2. Level scaling reflects band at spawn time (not a static low-level placeholder).
3. NPC AI package correctly targets or follows player based on role (escort vs attacker).
4. Rival cultist hits the player and does not flip to friendly mid-combat.
5. NPC cleans up (Delete) after scene end without leaving a ghost ref.
6. No double-spawn if player fast-travels mid-scene (cell-load guard, same as emissary).

---

## 4. Spawn Pattern Cost Comparison (Emissary / Champion)

Two spawn approaches:

**Option A: PlaceAtMe from player (recommended for P1 emissary).**
- Cost: ~15-20 lines of Papyrus in a new `TrySpawnEmissary` function in PDV__ManagerQuest;
  one authored ActorBase (or reuse a vanilla NPC); one lifetime timer.
- Pitfall: NPC spawns wherever the player is standing -- interior, dungeon, or crowded city.
  Thematic mismatch possible. No persistent alias; the ref may not survive a save/reload
  mid-lifetime if the NPC's cell unloads (exterior NPCs across the unload boundary).
- Mitigation: spawn only outdoors (check `Game.GetPlayer().IsInInterior()` and bail if true);
  restrict to 5-minute lifetime (short enough to outlast a typical outdoor scene).

**Option B: Persistent alias pool in a service quest.**
- Cost: a dedicated QUST with N Fill-Type alias slots (one per emissary type); alias tracking
  state in StorageUtil; more robust lifecycle (alias persists across cell loads).
- Pitfall: more CK wiring per deity; alias slots must be pre-allocated even when unused,
  which can burden save size if many deities have emissaries.
- Recommendation: defer to P2 once P1 option A is in-game proven. The B3 dossier's
  structure (start minimal, expand after proof) applies here.

**Verdict:** use PlaceAtMe for the P1 emissary pilot. Move to alias pool if persistence
across cell loads proves to be a real problem in smoke testing.

---

## Feasibility Summary Table

| Modality | Seam Type | Confidence | Greenfield? | Pilot Ready? |
|---|---|:-:|:-:|:-:|
| Congregation aura (Bucket 6) | SPID INI + CK MGEF condition | HIGH | no (reuses B3 pattern) | YES -- CK-only after LD-P1 global |
| Emissary spawn (Bucket 1) | PlaceAtMe + LD-P1 OnMoodBandCross | MEDIUM | YES (spawn lifecycle) | After LD-P1 in-game proof |
| Champion/rival spawn (Bucket 7) | PlaceAtMe + allegiance + AI | MEDIUM-LOW | YES (spawn + AI packages) | After emissary proven |
