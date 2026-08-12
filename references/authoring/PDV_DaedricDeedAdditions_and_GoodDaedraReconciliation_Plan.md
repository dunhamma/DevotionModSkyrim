# Daedric deed additions + Good-Daedra vs generic reconciliation — PLAN

**Status:** LIVING plan (design-approved, not yet implemented) · **Opened:** 2026-08-12 ·
**Branch:** `feat/daedric-deed-additions-and-good-daedra-reconciliation`

> This is a work-tracking design plan, not a status claim about shipped code. Nothing in
> Parts A-D is wired yet. Precedence for any "is it done" question stays: live readback / a
> re-run gate > `AGENTS.md` > this doc.

## Context

A player requested deeds for **Mephala** (poison enemies; kill with sneak attacks; do not go
to jail), **Azura** (trap souls; do not use black soul gems), and **Boethiah** (steal from
enemies; kill innocents & leave no witnesses; do not go to jail). The 1.5.0 update was
suspected of overwriting them.

Investigation established:

1. **No regression.** The likes/dislikes rows for all three princes are byte-identical
   between tag `v1.0.4` and `v1.5.0`. Nothing was overwritten.
2. **Most requested deeds were never wired** — the deed engine emits no event for poisoning,
   soul-trapping, black-soul-gem use, going to jail, sneak-attack kills, or leaving no
   witnesses. The vocabulary is a fixed block (`PDV_EventTypes.psc:77-115`, IDs 300-368) and
   the "HARD-detection acts" were explicitly dropped (`:114-115`).
3. **Several authored rows are dead in game** — `EVT_CLEAR_BOUNTY (351)`,
   `EVT_VAMPIRE_FEED (366)`, and `EVT_HEAL_OR_CURE_NPC (350)` have scoring rows but **zero**
   router/emitter calls anywhere in source (grep-verified). Reviving them delivers requested
   behavior with no new event IDs — notably Boethiah's existing `351` dislike ("bowing to
   another's law") is the correct lore model for "do not go to jail."

**Intended outcome:** (a) add the feasible new deeds; (b) revive the dead rows; (c) make the
Dunmer Good-Daedra *patron* forms and the generic Daedric *path* forms diverge on principle,
with in-lore reasoning documented for every discrepancy.

### Decisions locked with the owner (2026-08-12)
- **Scope:** Tier 1 + Tier 2 (sneak-kill + revived dead rows + bounty-clear detector +
  poison-application). Tier 3 (soul-trap / black-soul-gem / no-witnesses) deferred.
- **Patron vs path:** **strict exclusion** — Dunmer patrons exclude generic crime/violence
  per their locked design boundaries; generic paths embrace it.
- **"Do not go to jail":** reframe as **submission** — emit existing `351` (clearing/serving
  a bounty = bowing to law); no new arrest event.
- **Existing drift:** audit and rule on every current patron/path row difference.

---

## Architecture (verified, with anchors)

Source under `live-source/Scripts/Source/` (git mirror; compile-authoritative tree is the MO2
folder `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` — see Sync note).

**Emission chain** (representative: `332 brew-potion`): detector (Story Manager receiver
`PDV__SM_*` → `PDV_ActionRouter.HandleStory*`, or a player alias event in
`PDV_PlayerEvents.psc`) → `RouteActionWithAttribution` (`PDV_ActionRouter.psc:459`) →
`PDV_EventBus.RouteActionWithAttribution` → per-deity `ScoreAction`/`ScoreFromTable`
(`PDV_DeityBase.psc:243-287`, the **V1 patron lane**) and `RouteActionToOpenPaths`
(`PDV__ManagerQuest.psc:12777`) → `ScorePrinceAction` (the **V2 path lane**, gated to
open/committed paths only).

**Two scoring tables / loaders** (both in `PDV__ManagerQuest.psc`):

| Lane | Loader | Writer | CSV source | Codegen tool | Version const | Roster | Namespace |
|---|---|---|---|---|---|---|---|
| Patron (V1) | `LoadRowsForDeity` (:12985) | `WriteLD` (:12534, has `originGate`) | `references/authoring/PDV_DeityLikesDislikes.csv` | `tools/pdv_likesdislikes_gen.mjs` | `LIKES_DISLIKES_VERSION`=21 (:626) | `PDV_FLST_AllDeities` | `PDV.LD.*` |
| Daedric path (V2) | `LoadPrinceRowsForPath` (:12804) | `WritePLD` (:12717, no gate) | `references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv` | `tools/pdv_princeld_gen.mjs` | `PRINCE_LD_VERSION`=4 (:627) | `PDV_FLST_DaedricPaths_All` | `PDV.PLD.*` |

**Dual-form princes** (both a patron row-block and a path row-block): **Azura, Boethiah,
Mephala** (Dunmer Good Daedra; Azura also Khajiit "Azurah") and **Malacath** (Orc). The other
12 princes are path-only. A single action credits **both lanes** for a dual-form prince
(patron lane scores ambient for every roster deity; path lane scores only if the path is
open) — but committed *pacts* are mutually exclusive (`MigrateDaedricPactsIfNeeded`, `:2667-2679`).

**Anti-farm:** every row carries `dailyCap` + `cooldownDays`, enforced by peek-then-commit
(`PeekRepeatableAction`/`CommitPendingRepeatableActions`, `PDV_DeityBase.psc:485-548`). New
rows get this for free by supplying the two columns.

**Adding any new event requires, end to end:** (1) `EVT_*` const in `PDV_EventTypes.psc`
300-block + an `EventLabel` arm (~:144); (2) re-declare the const in each emitter script that
fires it; (3) a detector; (4) rows in the CSV(s) + matching `WriteLD`/`WritePLD` calls;
(5) register the ID in `GetLikesDislikesEventTypes()` and/or `GetPrinceEventTypes()` (or a
removed row won't clear); (6) bump the matching version constant.

---

## Part A — Detector-coverage audit + revive dead rows (do first)

1. **Coverage sweep.** For every 300-block ID, grep emitter scripts (`PDV_PlayerEvents.psc`,
   `PDV_ActionRouter.psc`, `PDV__SM_*.psc`) for a `Route*` call. Table: emitted / dead.
   Already confirmed dead: `350`, `351`, `366`.
2. **Revive `351 EVT_CLEAR_BOUNTY`** — the "do not go to jail" answer. Detector: cache
   `GetCrimeGold` for the major hold crime factions; when it **drops** (paid/served, not from
   new crime), emit `EVT_CLEAR_BOUNTY`. **Piggyback an existing periodic hook** (dawn/tick),
   not a new `RegisterForUpdate` loop (Papyrus perf). Revives Mara/Stendarr/Zenithar (+) and
   Boethiah-path/Baan Dar/Sithis/Hermaeus (−).
3. **Revive `366 EVT_VAMPIRE_FEED`** — detect the feed (MagicEffect / animation / PO3 hook).
   Revives Mephala-patron (+0.35), Azura (−1.0), Molag-Bal-path (+0.5).
4. **Revive `350 EVT_HEAL_OR_CURE_NPC`** — detect restoration heal/cure on an injured NPC.
   Broad: Kynareth/Azura/Stendarr (+), many Daedra (−).

---

## Part B — New deed events (Tier 1 + 2)

**B1 — script-only, high confidence:**
- **`EVT_SNEAK_ATTACK_KILL`** (propose ID 305; confirm no collision). Reuse existing hooks:
  in `OnHitEx` (`PDV_PlayerEvents.psc:732`) when `abSneakAttack && akAggressor == player`,
  stamp the victim (mirror `:1071`); in `OnActorKilled` (`:1061`) read the stamp →
  `RouteGenericAction(EVT_SNEAK_ATTACK_KILL, …)` (`:782`). No engine event, no ESP record.

**B2 — needs a throwaway prototype before commit (poison detection is the soft spot):**
- **`EVT_APPLY_POISON`** (propose ID 306). Literal "poison enemies." No `ApplyPoison` event
  exists; prototype two paths, keep the reliable one: (a) PO3 Papyrus Extender hit/magic
  hooks already used (`PO3_Events_Alias`, `PDV_PlayerEvents.psc:1609`); (b) approximate via
  `OnHitEx` outgoing alchemy contact effect. Gate the event on the prototype landing; else
  fall back to the `332 brew-potion` proxy and mark poison-application deferred.

Anti-farm defaults for new rows: `dailyCap 2-3`, `cooldownDays 0-0.5`.

---

## Part C — Placement matrix (strict exclusion, with lore reasoning)

Principle: the Dunmer forms are **Good Daedra / Reclamations** — an always-on ancestor
substrate re-reads each deed as honor/shame or community, worship is culturally tolerated with
**no stigma**, and each patron has a **locked boundary excluding generic crime/violence**
(`references/PDV_RaceDesign_Dunmer.md`, the per-prince "favor boundary (LOCKED)" rows;
`PDV_RaceArchitecture_DesignReference.md` §3.1/§9.3.1). Generic **paths** are Daedric
deviations with the global stigma/price machinery, scoring one prince in isolation.

| Deed | Generic PATH placement | Dunmer PATRON placement | Lore reason for the split |
|---|---|---|---|
| **Sneak-attack kill** (305) | Mephala + (small), Nocturnal + (small); **Malacath −** | Mephala **excluded**; **Boethiah −** (small) | Mephala lock excludes random murder; Boethiah's ancestor honor-gate requires "no stealth opener" — a sneak kill is dishonorable, so the patron **dislikes** what the path tolerates. |
| **Apply poison** (306) | Mephala + (small) | Mephala **excluded** | Generic = indiscriminate poison; Dunmer Mephala favor requires *sanctioned/targeted* killing (Morag Tong). |
| **Clear/serve bounty** (351, revived) | Boethiah path − (−0.75); Baan Dar/Sithis − | Boethiah **−** (add, small); Mara/Stendarr/Zenithar + | Submitting to another's law betrays Boethiah's self-authorship — consistent for both her forms (anti-authority ≠ generic crime, survives the exclusion rule). |
| **Vampire feed** (366, revived) | Molag Bal path + | Mephala + (+0.35); Azura − (−1.0) | Already lore-authored; needs the detector. |
| **Heal/cure NPC** (350, revived) | most Daedra paths − | Azura + ; Mephala − | Already authored; detector only. |

Azura's "trap souls / black soul gems" is **not buildable now** (Tier 3 deferred) but
addressed indirectly: `331 enchant-item` ("soul-work / Azura's Star") is already patron-only,
and the anti-necromancy stance is already encoded (Part D). If built later, black-soul use
belongs on the **Dunmer Azura patron as a dislike** (corrupted Star = blasphemy; soul-
defilement is Molag Bal's — a Bad Daedra — domain) and neutral on the generic path.

---

## Part D — Reconcile existing patron/path drift (rule on each)

"Keep" = intentional + document. "Fix" = drift to correct.

**Azura**
- `365 raise-undead` −1.5 patron vs −0.75 path — **Keep** (blasphemy-of-the-Star anti-necromancy is stronger for the devotee).
- `364 assault-innocent` −1.0 vs −0.5; `368 artifact` +0.5/3 vs +1.0/1 — **Keep** (patron harsher on cruelty; path weights pact-deepening artifact heavier).
- `331`/`300`/`366` patron-only — **Keep** (Dunmer theology); `314 sleep-in-bed` path-only — low-value drift, **harmonize or drop**.

**Boethiah**
- Patron-only `1 kill-beast`, `343 learn-word`, `315 sleep-inn −`, `333 cook −`; path-only `364 assault-innocent +0.5` — **Keep the split.** Path's treacherous-assault like is correctly absent from the patron (generic-violence lock). Already lore-correct.
- Add `351` − to the patron (Part C).

**Mephala** — the one real violation:
- **`364 assault-innocent` +1.0 patron vs +0.5 path — FIX.** A +1.0 *like* for striking a trusting innocent contradicts Mephala's locked boundary ("random murder / casual… never trigger Mephala favor"). Reduce Dunmer-patron `364` to ≤ path weight or gate behind curated context; owner sets magnitude.
- `350 heal` −0.5 vs −0.25 — **Keep** (open mending unweaves her web harder for the devotee).
- `313 rest-open-sky` cap 2 vs 3 (same delta) — **Fix** (accidental cap drift; harmonize to 3).
- `366` patron-only, `332 brew-potion` path-only — **Keep**; new poison-application likewise generic-path-only. Consistent with strict exclusion.

---

## Files to modify (implementation phase)

- `live-source/Scripts/Source/PDV_EventTypes.psc` — new `EVT_*` consts (305/306) + `EventLabel` arms.
- `live-source/Scripts/Source/PDV_PlayerEvents.psc` — detectors: sneak-kill stamp in `OnHitEx`/read in `OnActorKilled`; crime-gold poller (piggybacked); poison hook (prototype); vampire-feed + heal/cure detectors. Re-declare new consts.
- `live-source/Scripts/Source/PDV_ActionRouter.psc` — re-declare/classify any new const it routes.
- `live-source/Scripts/Source/PDV__ManagerQuest.psc` — updated `WriteLD`/`WritePLD` bodies; register new IDs in `GetLikesDislikesEventTypes()` and `GetPrinceEventTypes()`; **bump `LIKES_DISLIKES_VERSION` (:626) and `PRINCE_LD_VERSION` (:627)**.
- `references/authoring/PDV_DeityLikesDislikes.csv` and `PDV_DeityLikesDislikes_Princes_V2.csv` — new/edited rows (edit CSV, never the `.psc` body by hand).
- Regenerate loader bodies via `tools/pdv_likesdislikes_gen.mjs` and `tools/pdv_princeld_gen.mjs`, paste over the loader functions.
- `references/authoring/PDV_GoodDaedra_vs_Generic_ReconciliationSpec.md` (optional split-out of Part C/D as the standalone living authority, if this plan doc is later archived).

**Sync note (repo drift):** the compile-authoritative source is the MO2 live tree, not the git
`live-source/` mirror. Edit the canonical source, regenerate, compile via `tools/pdv_compile.mjs`,
then mirror to `live-source/`. Do **not** hand-edit generated loader bodies.

---

## Verification

1. **Codegen parity:** both gen tools with `--check` (or diff regenerated vs pasted body); confirm both version constants bumped.
2. **Detector-coverage gate:** re-run the Part A sweep — `350`/`351`/`366` and the two new IDs must now show a live emitter.
3. **Compile/verify:** `tools/pdv_compile.mjs` clean; `tools/pdv_verify.mjs` for VMAD/property/SEQ regressions.
4. **In-game (MCM-driven; debug is MCM, not `cqf`):** fresh save; fire each new/revived event via the MCM debug harness and confirm per-lane deltas — sneak-kill credits Mephala **path** but not Dunmer Mephala patron, and **dislikes** Dunmer Boethiah patron; poison credits Mephala path only; a paid bounty fires `351`; vampire-feed/heal now register. Confirm anti-farm caps hold and reset at dawn.
5. **Regression negative check:** committed Dunmer patron and committed Prince path remain mutually exclusive; ambient dual scoring unchanged for non-dual deities.
6. No houseCARL/ESP readback needed unless a later Tier-3 detector requires a Story Manager node — this tranche is script + CSV only.

---

## Deferred (Tier 3, out of scope)
Soul-trap / black-soul-gem use (soul-gem fill not cleanly detectable in Papyrus) and
leave-no-witnesses (witness state not exposed; Skyrim already voids bounty when unwitnessed).
Revisit only if a reliable detector prototype exists; placement pre-decided in Part C.
