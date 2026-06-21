# PDV Notoriety -> Hostile-On-Sight -- Design Dossier (RESEARCH ONLY)

**Status:** Design spike. POST-1.0 / V2 research. **No live-build change.** This
document does not edit `Devotion.esp`, any `.psc`/`.pex`, any manifest, or any
vanilla record. It is a design dossier produced under the V2 Backlog item 3
("Curse-access notoriety enhancement") and Open-Decision 7 (Breton light Vigilant
pressure encounter).

**Created:** 2026-06-20

**Question asked:** Can PDV add a "Notorious -> hostile on sight" hook for the top
band of its witness-based notoriety system, so that Vigilants of Stendarr and
other appropriate hostile factions identify the player as an enemy and attack on
sight, strictly as the TOP-band consequence, with lower bands keeping the
non-hostile rumor/Survey-text treatment?

**Short answer:** Yes, cheaply and save-safely, via a PDV-owned faction whose
own `Relations` array marks the hunter factions as `Enemy`, toggled on the player
by runtime `AddToFaction`/`RemoveFromFaction` at the top band. The engine's native
combat-reaction system does the rest -- no cloak, no per-frame scan. The real work
is not the hostility mechanism (it is small); it is (a) the world-state gate so a
Vigilant hunt cannot fire after the Vigilants are canonically wiped, (b) avoiding
*double*-hostility for the curse cases where vanilla already makes the player an
enemy of the Vigilants, and (c) the scoping discipline that keeps the game
playable (top band only, dedicated hunter factions only, never guards/townsfolk).

**Provenance:** `PDV_V2_Backlog.md` (sec.3), `references/authoring/PDV_OpenDecisions_RulingMemo.md`
(Decision 7), `references/authoring/PDV_DecisionMemo_CurseAccessReconciliation.md`,
`PDV_Architecture_v3.md` (sec.6 reputation tracks, sec.11.6 D-14..D-16, sec.13
curse-state seam, sec.16.7 transition surfacing, sec.17.6/17.7 distribution
posture), `race-sheets/PDV_RaceDesign_Breton.md`, `race-sheets/Race_Breton.md`,
`PDV_TargetEndStates_1.0.md` (Breton). Live record facts were read with houseCARL
on the "Devotion Dev" profile and are cited inline with FormIDs.

**Proof-boundary note (carried from `pdv-proof-boundary`):** every live-record
claim below is *static record inspection* on the non-Requiem dev list. Requiem is
NOT present in that list (verified: zero `REQ_`-prefixed MGEF records), so the
Requiem section is grounded in web research plus the architecture's stated posture
and is explicitly flagged "verify on the ARR/Authoria Requiem instance before any
build." Nothing here is runtime-proven; in-game smoke is a hard gate before this
ever ships.

---

## 0. Why this is mostly a *scoping* problem, not a *mechanism* problem

The instinctive read is "attack-on-sight is hard." It is not. Skyrim resolves
attack-on-sight from faction **combat-reaction relations** every time two actors
evaluate each other; this is engine-native and free. The hard parts are all
judgment calls about *who*, *when*, and *how to undo it*:

1. The hostility machinery for "abominations" already exists in vanilla and PDV
   must not duplicate it (double-hostility / desync -- the exact failure that got
   curse-access stigma moved to "Model B" in V1; see `PDV_V2_Backlog.md` sec.3).
2. The Vigilants are canonically massacred early in Dawnguard, so a Vigilant hunt
   that ignores world-state is a lore break and a "ghosts attacking me" bug.
3. Broad hostility (guards, townsfolk) makes the game unplayable and breaks
   merchants/quests/essential NPCs.

So this dossier spends most of its length on those three, and keeps the mechanism
section short and concrete.

---

## 1. Current state in the repo (what exists vs. what is unbuilt)

| Piece | State | Source |
|---|---|---|
| Witness-based curse notoriety (Suspected/Known/Notorious for werewolf=Hircine, vampire=Molag Bal) | **DESIGNED, UNBUILT.** V1 uses "Model B": social readability rides the Phase 15 curse-state overlay, NOT an independent counter. The witnessed-kill counter + Vigilant-hunt consequence is explicitly V2. | `PDV_V2_Backlog.md` sec.3 |
| Band copy (Suspected/Known/Notorious, Hircine + Molag Bal) | **DRAFTED**, ready, with a note to re-phrase from "devotion is suspected" toward "you have been seen" when it becomes witness-based. | `PDV_V2_Backlog.md` sec.3 table |
| Breton `WitchcraftExposure` track (0-100; Hidden/Suspected/Known/Notorious) | **SCAFFOLD LOCKED for 1.0** as a `PDV_ReputationTrack` instance (`PDV_RepTrack_WitchcraftExposure`, `PDV_GLO_WitchcraftExposure`). Bands + the Notorious x1.25 Daedric-gain modifier are locked. | `PDV_Architecture_v3.md:730`, `Race_Breton.md`, `PDV_RaceDesign_Breton.md:99-128` |
| Breton high-exposure consequence in 1.0 | **TEXT-ONLY** "Vigilant attention" Survey/status nod; the actual hunter *encounter* is deferred (this spike). | Open-Decisions Memo Decision 7; `PDV_TargetEndStates_1.0.md:574-576` |
| `PDV_CurseState` detection seam (None/Werewolf/Vampire) | **BUILT + runtime-proven** (Phase 15). Single curse-detection seam; transition hook `OnCurseStateChange`. | `PDV_Architecture_v3.md:1432-1465` |
| `PDV_ReputationTrack` subsystem (Adjust/bands/lock-in) | **BUILT + proven** (Imperial Concordat, Altmer ThalmorAlignment use it live). | `PDV_Architecture_v3.md:6.x`; memory `reputation-track-label-lags-raw` |
| Transition-surfacing contract (`tier`/`emergence`/`curse`/`reorientation`/`neglect`) | **BUILT.** One manager helper; band-cross notifications already route through it. | `PDV_Architecture_v3.md:16.7` |
| Distribution posture | PDV prefers its **own offline build-time patcher** over runtime frameworks. SPID = deferred. PO3 Papyrus Extender = accepted runtime dep. JContainers = out of 1.0 core. | `PDV_Architecture_v3.md:17.6-17.7` |

**Implication:** the *surfacing*, *track*, *band* and *curse-detection* layers
that a hostile-on-sight hook needs already exist and are proven. The two missing
pieces are (a) the witnessed-notoriety counter for the curse cases (V2 backlog
item 3) and (b) the hostile-on-sight consequence itself (this dossier). The
heretic case (Breton Hidden Art) already has its track built; only the consequence
is missing.

---

## 2. How vanilla ALREADY treats the three target populations (verified)

This is the single most important section, because it shows the three populations
are NOT symmetric -- two of them are partly covered by vanilla and one is bare.

### 2.1 The Vigilant faction's existing enemy list (live record)

`VigilantOfStendarrFaction` (`0B3292:Skyrim.esm`) -- read with houseCARL:
- Flags: `HiddenFromPC, CanBeOwner`. Ranks: none.
- **Override status: vanilla-only.** Only `Skyrim.esm` touches the record in the
  dev list (no Requiem, no USSEP override of *this* record). Its `Relations`
  array (10 entries) is the engine's hostility source.
- `Enemy` to: `VampirePCFaction` (`0C4DE0`), `VampireFaction` (`027242`),
  `WerewolfFaction` (`043594`), `DaedraFaction` (`02B0E5`),
  `NecromancerFaction` (`034B74`), `HagravenFaction` (`04359E`),
  `ghostFaction` (`0D33A2`), `SkeletonFaction` (`02D1DF`), `WispFaction`
  (`03E096`). `Ally` to itself.

### 2.2 What that means per population

| Population | In a vanilla faction the Vigilants already hate? | Net vanilla behavior |
|---|---|---|
| **Vampire (player)** | YES -- player vampires are in `VampirePCFaction` (`0C4DE0`), which is already `Enemy` to the Vigilants. | Hostility is **already authored**. A living Vigilant who detects a player vampire is already set to combat. (Players rarely feel it only because the Vigilants are mostly dead post-level-10, and because Dawnguard relaxed the stage-4 auto-aggro that the rest of the world used -- web-confirmed.) |
| **Werewolf (player, human form)** | NO -- the human-form player is in `PlayerWerewolfFaction` (`091822`), which is **not** in the Vigilant enemy list. The beast-form `WerewolfFaction` (`043594`) IS hated, but only while transformed. | A human-walking werewolf is **NOT** attacked by Vigilants in vanilla. This is the genuine gap (web-confirmed: "they will not recognize you ... unless you activate Beast Form"). |
| **Heretic (Breton Hidden Art, no curse)** | NO -- a Daedra-worshipping mortal is in no abomination faction. | **Zero** vanilla hostility. UESP notes an *unused* Daedric-artifact confrontation that is set never to fire. This is the bare/greenfield case. |

**Design consequence (load-bearing):**
- For **vampires**, PDV must NOT add a second Vigilant-hostility -- that would be
  the double-hostility/desync trap. PDV's value-add for vampires is *surfacing*
  ("you are hunted") plus, optionally, extending hostility to a hunter the player
  meets *after* the Vigilants are gone (the Dawnguard -- see 6.2).
- For **werewolves (human form)** and **heretics**, the faction-add *is* a real
  new mechanic, because vanilla provides nothing.

---

## 3. Implementation approaches and trade-offs

Four candidate mechanisms, scored on performance, save-safety, reversibility, and
compatibility.

### 3.1 Approach A -- PDV-owned faction with its own `Enemy` relations + runtime membership toggle (RECOMMENDED)

Define one (or a small set of) PDV faction(s) in `Devotion.esp`, e.g.
`PDV_Faction_Hunted_Vigilant`, whose **own** `Relations` array carries
`Enemy` toward the chosen hunter faction(s). At the top band, call
`Game.GetPlayer().AddToFaction(PDV_Faction_Hunted_Vigilant)`; below the band,
`RemoveFromFaction(...)`.

- **Performance:** essentially zero. Combat reaction is resolved by the engine on
  normal actor evaluation, not by a script tick. No cloak, no `OnUpdate`, no
  `FindAllReferences`. This is the cheapest possible mechanism and the one PDV's
  own `papyrus-optimization` guidance points toward (avoid cloak scans).
- **Save-safety:** `AddToFaction`/`RemoveFromFaction` write standard faction
  membership into the save; no script-instance accumulation, no save bloat. The
  faction record itself is baked in the ESP. No VMAD-property baking pitfall
  (the toggle is a function call at runtime, not a property read).
- **Reversibility:** strong. `RemoveFromFaction` clears the membership; the
  relation no longer applies. Caveat: NPCs already mid-combat will not instantly
  forgive -- on band-drop the handler should also run a combat-clear pass over
  engaged hunters (e.g. stop-combat on nearby members of the hunter faction;
  confirm the exact Papyrus API via `housecarl:papyrus-reference` at build time).
  Document the brief cool-down as expected.
- **Compatibility / Reqtificator:** best in class, because the relation lives on
  **PDV's own record** -- vanilla `VigilantOfStendarrFaction` is never edited.
  Nothing for another faction-overhaul mod or the Reqtificator to conflict with.
  (See 5.3 for the Reqtificator detail.)
- **One thing to prove:** Skyrim resolves combat reaction by checking *both*
  factions' relations and taking the most hostile, so authoring the `Enemy`
  relation on the PDV side *should* make the Vigilant hostile to the PDV-faction
  member without touching the Vigilant record. This direction-of-relation
  behavior is a classic gotcha and MUST be smoke-proven. **Fallback if the
  PDV-side relation proves insufficient:** add the relation to the vanilla
  Vigilant record via PDV's offline build-time patcher (sec.17.6) or, at runtime,
  SkyPatcher -- see 3.3.

### 3.2 Approach B -- add the player to an existing vanilla "hated" faction

E.g. `Player.AddToFaction(WerewolfFaction 043594)` or `VampireFaction`.

- **Rejected.** These factions are load-bearing for many other systems
  (detection, dialogue, other mods, Requiem). Borrowing them to trigger hostility
  produces broad, unintended side effects and is the opposite of scoped. The
  *mechanism* (AddToFaction) is right; the *target* must be a dedicated PDV
  faction, which is Approach A.

### 3.3 Approach C -- SPID / KID / SkyPatcher runtime, no-ESP distribution

- **SPID** distributes spells/perks/items/factions/keywords to **NPCs** at load.
  It does not control the **player's** dynamic, band-driven faction membership, so
  it cannot be the trigger. Its legitimate use here is *coverage*: ensure modded
  Vigilant-type NPCs also carry `VigilantOfStendarrFaction` (or a PDV keyword) so
  the relation catches them too. PDV posture defers SPID (sec.17.7), so treat this
  as optional polish, not core.
- **KID** distributes keywords to **items** -- not applicable.
- **SkyPatcher** can add the `Enemy` relation to the vanilla Vigilant record at
  game load with no ESP edit. This is the cleanest *fallback* if Approach A's
  PDV-side relation does not produce mutual hostility. Cost: it introduces a
  runtime-framework dependency PDV wants to avoid; PDV's own offline patcher
  (sec.17.6) is the in-house equivalent and is preferred for a shipped feature.
- **Net:** none of these is the primary mechanism; the player-side toggle is
  Papyrus (Approach A). SkyPatcher/offline-patcher is the relation-authoring
  fallback only.

### 3.4 Approach D -- scripted cloak / detection polling + forced `StartCombat`

A cloak magic effect (applied to nearby actors each tick) or an `OnUpdate` scan
that calls `StartCombat` on valid hunters.

- **Rejected as the primary mechanism.** Cloaks are a well-known Papyrus
  performance sink (the effect runs on every nearby actor every tick) and a save-
  bloat risk; PDV's `papyrus-optimization` guidance explicitly flags cloak scans.
  It buys fine-grained control PDV does not need, at a cost PDV refuses to pay.
- **Where a *light, event-driven* script IS appropriate:** not for hostility, but
  for the *trigger evaluation* -- the band-cross handler that decides whether to
  call `AddToFaction` (checking world-state, curse-state, Dawnguard membership,
  etc.). That is one event handler, not a per-frame scan.

### 3.5 Scorecard

| Approach | Perf | Save-safe | Reversible | Compat | Verdict |
|---|---|---|---|---|---|
| A: PDV faction + relations + toggle | Best | Best | Strong (+combat-clear) | Best (no vanilla edit) | **RECOMMENDED** |
| B: add player to vanilla abomination faction | Best | OK | OK | Poor (side effects) | Rejected |
| C: SPID/KID/SkyPatcher | n/a (NPC/record side) | n/a | n/a | Good | Coverage + relation fallback only |
| D: cloak / poll + StartCombat | Worst | Risky | OK | OK | Rejected as primary |

---

## 4. HARD lore constraint -- detecting "Vigilants still active"

The Hall of the Vigilant is destroyed and most Vigilants are killed early in
Dawnguard. A Vigilant hunt that fires after that is a lore break (and the player
will see "Vigilants" that should not exist, or none at all). Any Vigilant-keyed
hostility MUST gate on Vigilants-still-active.

### 4.1 The canonical trigger

The Hall of the Vigilant is destroyed by vampires once the player reaches **level
10** or the Dawnguard questline starts (quest **`DLC1VQ01`** "Dawnguard",
`00352A:Dawnguard.esm`). Survivors (Adalvald, Tolan) are taken to Dimhollow and
die there. (Web-confirmed against UESP/Fandom summaries; corroborated by multiple
Vigilant-rebuild mods that key their logic off "is the ruined state enabled.")

`DLC1VQ01` stage indices (read live): `0, 5, 10, 12, 15, 17, 18, 19, 20, 30, 40,
200 (ShutDownStage), 999`. The quest moves off stage 0 when the Dawnguard intro
begins; the world has shifted to "vampire menace loose, Vigilants attacked" from
that point.

### 4.2 Recommended detection (defence in depth)

A small `PDV_VigilantWorldState` helper behind the existing service-seam style:

1. **Primary gate:** `DLC1VQ01.GetStage() == 0` (and/or the quest not running)
   means pre-Dawnguard -- Vigilants intact. Any value past 0 means the intro has
   fired -> treat Vigilants as wiped, suppress the Vigilant hunt.
   - Resolve `DLC1VQ01` once via `Game.GetFormFromFile(0x00352A, "Dawnguard.esm")`
     and cache it (per the `GetFormFromFile` caching guidance).
   - DLC-absence safe: if the form is `None` (no Dawnguard), there is no Hall
     attack, so Vigilants are always "intact" -- but see 4.3.
2. **Redundant gate (belt-and-suspenders):** also check a key Vigilant leader is
   alive -- e.g. Keeper Carcette -- with `actor.IsDead()`/`IsDisabled()`. This
   catches the edge where a player wiped the Hall manually or a mod altered the
   trigger without advancing the quest. NPC-dead checks are otherwise fragile, so
   use it only as an OR-confirmation of the quest gate, never as the sole gate.
3. **Optional location context:** `HalloftheVigilantLocation` (`0C342D`) and
   `StendarrsBeaconLocation` (`108A5A`) are usable for flavor/spawn anchoring if
   an authored encounter ever wants a "home turf," but they are not needed for the
   alive/dead gate.

Re-evaluate the gate on `OnPlayerLoadGame` and on the relevant band-cross, not on
a timer.

### 4.3 Consequence of the gate for design

Because the Vigilants are gone for most of a normal playthrough, a Vigilant-only
hunt has a **short live window** (early game, pre-level-10/pre-Dawnguard). That is
fine for the *heretic* and *human-form werewolf* cases (the player can reach a high
band early via Daedric quests). For a complete post-Dawnguard experience, the
design should pair the Vigilant hunt with a **post-Vigilant hunter** so the
consequence does not silently evaporate at level 10:
- **Vampire Notorious -> the Dawnguard** (`DLC1HunterFaction 003375`), who appear
  *after* the Vigilants fall and already hate `DLC1VampireFaction` (verified: their
  only `Enemy` relation is `003376`). See 6.2.
- **Heretic / human-form werewolf Notorious post-Vigilant -> PDV-authored
  pressure** (the V2 backlog's "track you down and randomly attack" -- a rare,
  long-cooldown authored encounter rather than a standing faction relation), since
  vanilla has no roaming mortal-heretic or human-form-werewolf hunter after the
  Vigilants are gone.

---

## 5. Requiem-list interaction

PDV targets Requiem. **Requiem is not in the dev list this dossier was read
against** (verified: zero `REQ_`-prefixed MGEF records; per the
`arr-authoria-requiem-scan-gotchas` memory, the Requiem list is the separate
ARR/"Authoria" houseCARL instance). So the following is grounded in web research +
architecture posture and is flagged for a confirming read on the ARR instance
before any build.

### 5.1 Does Requiem already give vampires/werewolves their own hostility/detection?

- Requiem **rebalances** vampire/werewolf *stats* (e.g. werewolf health buff
  reduced; vampires gain knockdown immunity) but does not, from the available
  evidence, replace the social *hostility* model with a general "known
  Daedra-worshipper" or "known heretic" reputation hunt. (Web-confirmed for the
  stat rebalance; no evidence of a heretic-reputation system.)
- Vanilla-with-Dawnguard relaxed the old "stage-4 vampire = whole town aggro" so
  NPCs no longer auto-turn-hostile on stage 4 alone (only Vampire Lord form);
  Requiem inherits the vanilla faction-relation baseline. Requiem vampire
  *stage* (advances every ~4.8h unfed; feeding lowers it) governs detectability/
  penalties more than a bespoke faction hunt.
- **Werewolf:** vanilla/Requiem only flag the player as a werewolf to haters in
  beast form. The human-form gap (sec.2.2) holds under Requiem too.

### 5.2 Avoiding double-hostility under Requiem

- The vampire case is where double-hostility risk is highest, because the vanilla
  `VampirePCFaction -> Vigilant Enemy` relation (sec.2.1) is inherited by Requiem.
  PDV must therefore **not** re-assert Vigilant hostility for vampires; let vanilla
  own it and have PDV add only surfacing + the post-Vigilant Dawnguard extension.
- For werewolf (human form) and heretic, there is no vanilla/Requiem hostility to
  collide with, so the PDV faction-add is additive and clean.

### 5.3 Reqtificator implications

- The Reqtificator is a **patch-generation** step: it reads the ESP load order and
  bakes a `Requiem for the Indifferent.esp`-style merged patch (notably leveled
  lists, and it normalizes records that carry Requiem-relevant data). It runs
  at build time, not at game load.
- **Approach A touches no vanilla record and adds no leveled-list/stat data**, so
  there is nothing for the Reqtificator to rebalance or clobber: a PDV faction +
  its relations + a Papyrus toggle are invisible to the Reqtificator's concerns.
  This is a strong argument for Approach A over editing the vanilla Vigilant record.
- If the fallback (3.3) is ever used to edit the vanilla `VigilantOfStendarrFaction`
  record, do it via a **runtime** patcher (SkyPatcher) or PDV's offline patch that
  loads *after* Requiem, so the relation addition wins; a build-time ESP edit to a
  vanilla faction would need to be ordered against Requiem and re-checked after any
  Reqtificator run. Approach A avoids this entirely.
- **Action before build:** re-point houseCARL to the ARR/Authoria instance and
  confirm (a) Requiem does not override `VigilantOfStendarrFaction` / the curse
  factions' relations, and (b) no Requiem patch already adds a heretic-hunt the
  PDV feature would duplicate. Re-point back to Anvil afterward (instance choice
  persists to disk -- `compat-reference-instances` memory).

---

## 6. Which factions react at Notorious -- and how not to break the game

### 6.1 The whitelist (dedicated hunter factions only)

| Faction | FormID | Reacts to | Live window | Recommendation |
|---|---|---|---|---|
| Vigilants of Stendarr | `0B3292` | heretic, human-form werewolf, (vampire already covered) | pre-Dawnguard only (sec.4) | **Primary** hunter. Gate hard on Vigilants-alive. |
| Dawnguard | `DLC1HunterFaction 003375` | vampire | post-Vigilant (appears after the Hall falls) | **Vampire-only** extension, and ONLY if the player is not a Dawnguard member (do not make an order attack its own member). |
| Silver Hand | `SilverHandFaction 0AA0A4` | werewolf | n/a | **NOT recommended.** They are a static, dungeon-bound, Companions-questline-entangled camp faction (Enemy to the Companions, not roaming hunters). Attack-on-sight would only matter in their lairs and could snarl the Companions questline. |
| Guards / townsfolk / `CrimeFaction` | -- | -- | -- | **NEVER.** See 6.3. |

For werewolves and heretics *after* the Vigilants are gone, there is no clean
vanilla roaming hunter -> use rare PDV-authored pressure (sec.4.3), not a standing
faction relation.

### 6.2 The Dawnguard nuance (vampire)

`DLC1HunterFaction` is `Enemy` only to `DLC1VampireFaction` (`003376`) -- verified.
A Notorious player vampire is the natural quarry. But:
- Gate on **not a Dawnguard member** (`Player.IsInFaction(DLC1DawnguardFaction)`
  false) so a vampire who joined the Dawnguard side is not attacked by their own.
- This pairs cleanly with the timeline: Vigilants (early) -> Dawnguard (later) gives
  a vampire a continuous "you are hunted" arc across the playthrough.

### 6.3 Not breaking essential NPCs, merchants, quests

- **Faction-relation hostility only affects members of the hunter faction.** It
  does not touch guards, merchants, or quest-givers unless they are in that
  faction. Keeping the whitelist to Vigilant/Dawnguard avoids essential-NPC and
  merchant breakage by construction.
- **Quest-entangled Vigilants:** a few Vigilants are tied to quests -- the Moth
  Priest escort (`DLC1PriestCampVigilants 008876`, `DLC1PriestEscortVigilants
  008875`) and the Vigilant who attacks Barbas in *A Daedra's Best Friend*.
  Mitigation: scope the relation to `VigilantOfStendarrFaction` generic members
  and accept that by the time those quests run the Vigilants are usually gone; or,
  if precision is wanted later, exclude the escort sub-factions. Low priority --
  the hard world-state gate already shrinks this surface.
- **Never** touch `CrimeFaction`/guards or add the player to a crime faction.
  WitchcraftExposure is religious/social stigma, NOT hold-scoped crime bounty
  (the Breton doc is explicit: prefer authored road/letter/contract pressure over
  crime-gold mechanics). Conflating the two would make the player wanted by every
  hold and break the whole game.
- **Essential flag:** hunter-faction combatants are generally non-essential, so
  the player can kill them (killing a Vigilant is itself a +25 exposure signal in
  the Breton design -- a coherent loop, not a soft-lock).

---

## 7. Band-gated scope, tie-in to the notoriety bands, and surfacing

### 7.1 Strictly top-band lethal; lower bands stay non-hostile

| Band (heretic 0-100 / witnessed-curse) | Consequence | Hostile on sight? |
|---|---|---|
| Suspected (26-50) | Rumor / wary eyes / Survey-text; mild disposition only. | No |
| Known (51-75) | "Credible danger" -- watched, distance, authored/contextual pressure may fire; still no standing kill order. | No (non-lethal escalation only) |
| **Notorious (76-100)** | **Attack on sight** by the whitelisted hunter for that population (sec.6), gated on world-state/curse/membership. | **Yes -- top band only** |

This satisfies the spike's hard requirement: hostile-on-sight is strictly the
TOP-band consequence; Suspected/Known keep the existing rumor/Survey-text
treatment.

**Reconciliation flag:** `PDV_V2_Backlog.md` sec.3 says "Known or above" for the
Vigilant-attack consequence, while the 1.0 Breton sheet and this spike say
Notorious. **Recommend pulling lethal attack-on-sight up to Notorious-only**, with
Known limited to non-lethal escalation. This is a one-line design ruling to record
when the feature is promoted.

### 7.2 Thematic fit (why top-band hostility is *earned*, not punitive)

For the Breton Hidden Art, Notorious is a **chosen end-state** that *accelerates*
Daedric rewards (the locked x1.25 modifier; "total isolation as total commitment").
Attack-on-sight is the matched cost of that reward -- "you went all the way; the
world treats you as what you are." For the curse cases it is the visible price of
being an openly-known werewolf/vampire. In all three it is a consequence the player
walked toward, not a random tax.

### 7.3 Surfacing -- reuse the proven contract

- Drive the "you are now hunted" beat through the existing **transition-surfacing
  contract** (sec.16.7) as a one-shot **Loud (MessageBox)** on the cross *into*
  Notorious, and a quieter Notification when it cools back below. Reuse the
  `reorientation`/`curse` class plumbing -- do not scatter new notification calls.
- Keep the **Survey/status** line as the persistent, glanceable readout ("Hunted:
  Vigilants of Stendarr will attack on sight"), consistent with the V1 text-only
  "Vigilant attention" nod -- the V2 feature *upgrades* that text into a real
  consequence without changing the surface the player already learned to read.
- Coordinate with the curse-state onset/cure messages so the hostile-on-sight
  notice does **not** double-fire against `CurseState` transitions (the Model B
  desync lesson). The hostile-on-sight toast fires on the *notoriety band* cross,
  the curse toast fires on the *curse* transition; they are different events and
  must stay distinct.

---

## 8. Recommended architecture (synthesis)

```
PDV_RepTrack_WitchcraftExposure / witnessed-curse-notoriety counter (V2)
        |  band-cross event (existing ReputationTrack plumbing)
        v
PDV__ManagerQuest.OnNotorietyBandChange(population, oldBand, newBand)
        |
        |-- newBand == Notorious ?
        |       |-- population == HERETIC or WEREWOLF(human form):
        |       |       if PDV_VigilantWorldState.VigilantsAlive():   AddToFaction(PDV_Faction_Hunted_Vigilant)
        |       |       else (post-Vigilant):                         schedule rare PDV-authored pressure
        |       |-- population == VAMPIRE:
        |       |       (skip Vigilant -- vanilla already hostile)
        |       |       if Dawnguard active && player not Dawnguard:  AddToFaction(PDV_Faction_Hunted_Dawnguard)
        |       |-- SurfaceTransition(Loud, "you are hunted")  (sec.16.7)
        |
        |-- newBand < Notorious ?
                |-- RemoveFromFaction(PDV_Faction_Hunted_*)
                |-- combat-clear pass over engaged hunters
                |-- SurfaceTransition(Notification, "the hunt has cooled")
```

Records added to `Devotion.esp` (no vanilla record edited):
- `PDV_Faction_Hunted_Vigilant` -- own `Relations`: `Enemy` -> `VigilantOfStendarrFaction`.
- `PDV_Faction_Hunted_Dawnguard` (optional, vampire) -- own `Relations`: `Enemy` -> `DLC1HunterFaction`.
- (Optionally a shared `PDV_Faction_Hunted` if a single membership is cleaner; keep
  per-hunter if the populations diverge.)

Scripts (new, small):
- `PDV_VigilantWorldState` helper (sec.4.2), behind the service-seam style like
  `PDV_CurseState`.
- A band-cross handler on `PDV__ManagerQuest` reusing the existing surfacing helper.

No cloak. No timer/poll. No vanilla-record edit. No new hard runtime dependency
beyond what PDV already accepts (PO3). SPID/SkyPatcher only as optional coverage /
relation-direction fallback.

---

## 9. Scope, risk, and what would gate this into a release

### 9.1 Dependencies / sequencing

1. **Build the witnessed-notoriety counter first** for the curse cases (V2 backlog
   item 3) -- the hostile-on-sight consequence has nothing to hang on until the
   counter exists. The heretic case already has its track (`WitchcraftExposure`),
   so the heretic slice could pilot the consequence first.
2. Prove the **relation-direction** question (3.1): does a PDV-side `Enemy`
   relation make the Vigilant hostile without editing the Vigilant record? This is
   the single technical unknown; smoke it in a throwaway test ESP before committing
   the design.
3. Build the **world-state gate** (sec.4) and prove it: Vigilants attack pre-level-10,
   stop being a factor after `DLC1VQ01` advances.
4. Re-verify on the **ARR/Authoria Requiem instance** (sec.5.3).

### 9.2 Risks (and mitigations)

| Risk | Severity | Mitigation |
|---|---|---|
| Double-hostility for vampires (vanilla already hostile) | High (desync, the Model B failure) | Vampire path skips Vigilant entirely; uses Dawnguard + surfacing only (sec.2.2, 5.2). |
| Lore break -- Vigilant hunt after the Hall falls | High | Hard `DLC1VQ01` gate + redundant NPC-alive check (sec.4.2). |
| Game made unplayable by broad hostility | High | Whitelist = dedicated hunter factions only; never guards/townsfolk/`CrimeFaction` (sec.6.3). |
| Hostility won't clear on band-drop (NPC stays in combat) | Medium | `RemoveFromFaction` + explicit combat-clear pass; document brief cool-down (3.1). |
| Quest-entangled Vigilants (Moth Priest escort, Barbas) | Low | World-state gate shrinks the window; optionally exclude escort sub-factions later. |
| Save-safety of dynamic faction toggling | Low | `AddToFaction`/`RemoveFromFaction` are standard, save-clean; no VMAD-bake dependency. |
| Compat with faction-overhaul mods / Reqtificator | Low | Approach A edits no vanilla record (sec.3.1, 5.3). |
| Performance | Low | Engine-native combat reaction; no cloak/poll (sec.3.1). |

### 9.3 Release gate (what "ready" means)

- The witnessed-notoriety counter (curse) and/or `WitchcraftExposure` Notorious
  band drives the band-cross event reliably (no over-fire on routine play).
- In-game smoke proof, per population: (a) Notorious + Vigilants-alive -> Vigilant
  attacks; (b) band drops -> hostility clears within the documented cool-down;
  (c) post-Dawnguard -> no Vigilant hunt; (d) vampire -> no PDV double-hostility,
  Dawnguard extension fires only when not a Dawnguard member; (e) surfacing fires
  once per band-cross and never double-fires against curse transitions.
- ARR/Requiem-instance verification clean (sec.5.3).
- Decision-7 ruling recorded: lethal = Notorious-only (sec.7.1 reconciliation).
- Voice posture: any *dialogue* a hunter speaks is V2/voice-coupled
  (architecture sec.21.3); the 1.0/early-V2 surface stays non-voiced
  (MessageBox/Notification/Survey), so the feature can ship before voice work.

### 9.4 Effort estimate (rough)

- Records: 1-2 factions in `Devotion.esp` -- trivial.
- Scripts: `PDV_VigilantWorldState` helper + one band-cross handler -- small,
  reuses existing surfacing + track plumbing.
- The cost is in **proving** (the relation-direction smoke, the world-state gate,
  the cross-population matrix), not in **writing**. Call it a contained V2 slice,
  not a system.

---

## Appendix A -- Verified live FormIDs (houseCARL, Devotion Dev profile)

| EditorID | FormID | Note |
|---|---|---|
| VigilantOfStendarrFaction | `0B3292:Skyrim.esm` | vanilla-only; 10 relations; Enemy to the abomination factions below |
| VampirePCFaction | `0C4DE0:Skyrim.esm` | player vampire faction; already Vigilant-Enemy |
| VampireFaction | `027242:Skyrim.esm` | Vigilant-Enemy |
| WerewolfFaction | `043594:Skyrim.esm` | beast-form; Vigilant-Enemy |
| PlayerWerewolfFaction | `091822:Skyrim.esm` | human-form; NOT Vigilant-Enemy (the gap) |
| DaedraFaction | `02B0E5:Skyrim.esm` | Vigilant-Enemy |
| NecromancerFaction | `034B74:Skyrim.esm` | Vigilant-Enemy |
| HagravenFaction | `04359E:Skyrim.esm` | Vigilant-Enemy |
| ghostFaction / SkeletonFaction / WispFaction | `0D33A2` / `02D1DF` / `03E096` | undead/atronach; Vigilant-Enemy |
| DLC1HunterFaction (Dawnguard) | `003375:Dawnguard.esm` | Enemy only to DLC1VampireFaction |
| DLC1VampireFaction | `003376:Dawnguard.esm` | Dawnguard's quarry |
| DLC1PlayerVampireLordFaction | `0071D3:Dawnguard.esm` | 2 relations |
| SilverHandFaction | `0AA0A4:Skyrim.esm` | static/quest-bound; not a roaming hunter |
| DLC1PriestCampVigilants / DLC1PriestEscortVigilants | `008876` / `008875:Dawnguard.esm` | quest-entangled Vigilant sub-factions |
| DLC1VQ01 ("Dawnguard" intro quest) | `00352A:Dawnguard.esm` | world-state gate; stages 0..40,200,999 |
| HalloftheVigilantLocation | `0C342D:Skyrim.esm` | optional encounter anchor |
| StendarrsBeaconLocation | `108A5A:Skyrim.esm` | optional encounter anchor |

## Appendix B -- Open questions to resolve at promotion

1. Relation direction: PDV-side `Enemy` sufficient, or is a vanilla-record edit
   (offline patcher / SkyPatcher) required? (Smoke-prove.)
2. Lethal-band ruling: confirm Notorious-only (vs V2 backlog's "Known or above").
3. Werewolf/heretic post-Vigilant hunter: authored-pressure shape (road/letter/
   ambush), cadence, and cooldown.
4. Whether to exclude the Moth Priest escort Vigilant sub-factions.
5. ARR/Requiem-instance confirmation that nothing duplicates or overrides this.
