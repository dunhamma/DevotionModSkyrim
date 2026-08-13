# PDV Dead-Wiring Burndown

Living tracker for the declaration-side dead-wiring class found 2026-07-06/07:
registries (signals, events, routes, keys) declared but never consumed/emitted.
Guarded by the default-FAIL declaration gates in `tools/pdv_signal_e2e_gate.mjs`
(+ `pdv_matrix_runtime_preflight.mjs --name-resolution-only`), enforced on every
`pdv_verify` run. Reserved ledgers: `tools/pdv_reserved_signals.json`,
`tools/pdv_reserved_events.json`, `tools/pdv_reserved_routes.json`.

**Progress metric: reserved counts only shrink.** Each wired/retired item deletes
its ledger entry (a stale entry hard-FAILs, so this doc cannot drift silently).

Owner decisions: 2026-07-07 grill session (see plan `precious-seeking-corbato`).
Sequencing: bugs + tooling landed now; WIRE items build AFTER the mega packet.

> **RESTORED 2026-08-06.** This file was missing from the working tree: it was added by `b5086d89`,
> which is **not an ancestor of HEAD** (orphan branch), so the spec below never reached this line of
> history even though `tools/pdv_reserved_events.json` cites it by name as the authority for the 350
> and 366 emitters. Recovered verbatim via `git show b5086d89:<path>`. Nothing in it was edited; the
> status note below is the only addition. **If a reserved-ledger entry cites a doc, check the doc
> actually exists on the current branch** — a dangling authority pointer reads exactly like a
> completed hand-off.
>
> **The "post-mega-packet" gate on 350 and 366 has now lapsed.** The mega packet was the Altmer lane
> audit: 17 of its 18 packets are landed, with only P17 (cadence sizing, needs a played save) left.
> `350 heal-or-cure-npc` is therefore buildable now — 19 deity rows plus a two-sided
> Boethiah/Sithis/Mephala axis are currently promising piety that can never fire, and the emitter
> spec below is complete. Syrabane gained his own 350 row on 2026-08-06 (`0.75`, medium, cap 2,
> cooldown 0.5, likes/dislikes VERSION 19 -> 20); he had been the one protection-themed deity with
> no heal-or-cure row at all. That row is inert until this emitter is built.

## Ledger state

| Ledger | Seeded | Current | Burned down |
|---|---|---|---|
| Signals | 33 | 33 (Wave 1 -4, vestigial -7 pending Phase 3) | 0 |
| Events | 12 | 5 (310/311/312/363 constants removed; 3/4/335 rows retracted, ver 13) | 7 |
| Routes | 4 | 4 (Phase 4 verdicts pending) | 0 |

## Event verdicts (Phase 2, DONE except post-packet wires)

| Event | Verdict | State |
|---|---|---|
| 350 heal-or-cure-npc | WIRE | **BUILT 2026-08-13** (caster-side; reserved entry deleted). See spec note below. |
| 366 vampire-feed | WIRE post-packet | reserved; spec below |
| 354 persuade-success (undeclared) | verdict pending | reserved; fold into spec review |
| 367 cannibalize (undeclared) | verdict pending | reserved; fold into spec review |
| 351 clear-bounty | RESERVE indefinitely | detector ambiguous; rows kept |
| 335 mine-or-chop | RETRACTED | row deleted, regen v13, constant removed |
| 3 / 4 kill-event placeholders | RETRACTED | rows deleted, regen v13 (ids kept in clear-superset for old-save cleanup) |
| 310/311/312 pray/blessing/sky-shout | REMOVED | superseded dead constants deleted |
| 363 pickpocket | REMOVED | dead constant deleted; ActionRouter comment updated (type-3 stays deliberately unrouted) |

## Emitter spec: EVT_HEAL_OR_CURE_NPC (id 350) — BUILT 2026-08-13

> **AS-BUILT (2026-08-13), deviates from the original trigger below — read this first.**
> The original trigger (`OnMagicEffectApplyEx`, "player heals a friendly NPC") is
> **unbuildable with the current hook**: that PO3 event is registered on the player alias
> and is **target-side** — it only hears effects applied *to the player*, so a heal that
> lands on an NPC never reaches it (the same limitation that forced raise-undead caster-side,
> documented at `PDV_PlayerEvents.OnMagicEffectApplyEx`). No caster-on-other magic-effect
> hook exists (PO3 exposes `GetEffectArchetypeAsInt` but no delivery getter, and vanilla heal
> MGEFs carry no shared keyword), so a spec-faithful build is not available.
>
> **Built instead, mirroring the shipped raise-undead detector:** caster-side
> `PDV_PlayerEvents.OnSpellCast` → `SpellHasHealOrCureOtherEffect(castSpell)` matches the cast
> spell's effects against a new curated FormList `PDV_FLST_HealCureOtherEffects`
> (`071790:Devotion.esp`, resolved by FormID per the KID save-safety pattern) → emits
> `RouteGenericAction(EVT_HEAL_OR_CURE_NPC, player, spell)`. The FormList holds only
> **other-delivery** heal effects — `01CEA7` (Healing Hands, target-actor) and `0B62ED`
> (Grand Healing, self-area ally heal) — so Self-cast combat heals never score. Because
> Mysticism overrides those vanilla effect FormIDs in place, Mysticism's heals are covered
> for free; Triumvirate's Cleric Aid (a new FormID) is added via a runtime foreign-form pass.
>
> **Fidelity trade vs the original spec:** cannot confirm the actual target was a friendly
> NPC (an other-directed heal cast is the proxy), and anti-farm is the per-deity CSV
> `dailyCap` (2–3) rather than a per-target day-key — the same governance raise-undead uses.
> Owner-approved 2026-08-13.
>
> **Runtime proof still owed:** cast Healing Hands on a follower in game → the per-origin
> deities gain in the Ledger; second cast same day is bounded by the per-deity dailyCap.

### Original spec (superseded by the as-built note above)

- **Trigger**: `PDV_PlayerEvents.OnMagicEffectApplyEx` (hook already registered).
  Accept when: caster == player, target is an NPC (ActorTypeNPC keyword), target
  NOT hostile to player, effect archetype is Restore Health / Cure Disease /
  Cure Poison (PO3 `GetEffectArchetypeAsInt` or MGEF keyword `MagicRestoreHealth`),
  magnitude > 0, target != player.
- **Route**: new `PDV_EventBusService.RouteHealOrCureNpc(target)` ->
  `PDV_EventBus.RouteAction(eventTypes.EVT_HEAL_OR_CURE_NPC, playerRef, target)`
  (declared constant already exists; the data rows are live).
- **Anti-farm**: rows already carry dailyCap 2-3 per deity (data-side). Add the
  standard once-per-target-per-day guard (StorageUtil day-key on the target,
  day+1 encoding per the day-key-zero-default gotcha) to stop cast-spam on one
  follower; the per-deity caps then govern cross-target totals.
- **Race gates**: none at the emitter — the data table's per-deity rows +
  origin gates already scope it. Two-sided: Boethiah/Sithis/Mephala dislike rows
  fire from the same emission.
- **Prove**: cast Healing Hands on a follower -> Kyne/Mara (per origin) gain in
  the Ledger; second cast same day on the same target = no double bank.

## Emitter spec: EVT_VAMPIRE_FEED (id 366) — build post-packet

- **Trigger options (research pick, in preference order)**:
  1. PO3 `OnMagicEffectApplyEx` filter on the vanilla feed effect
     (`VampireFeedingHealthRestore` / feed spell family) — cleanest if the
     effect fires reliably in Requiem's vampirism.
  2. Animation-event hook on the feed paired-idle (`IdleVampireStandingFeedA`)
     via `RegisterForAnimationEvent`.
  3. `PlayerVampireQuest` stage watch (vanilla advances feed bookkeeping).
  Requiem note: verify against Requiem's vampirism overhaul before picking —
  the smoke gate is a Requiem profile.
- **Route**: `RouteAction(eventTypes.EVT_VAMPIRE_FEED, playerRef, victim)`
  (constant exists; Molag Bal row is live, dailyCap 3).
- **Anti-farm**: once per feed event; per-victim day-key as with 350.
- **Synergy**: shares curse-state surface with Tuwhacca VAMPIRE_REENTRY (Wave 1)
  and the Imperial/Redguard vampire earn-halts — wire in the same pass.
- **354/367 fold-in**: when this spec is built, also decide persuade-success 354
  (speechcraft `OnPersuasionSuccess` — needs a menu/dialogue hook; Clavicus row)
  and cannibalize 367 (Ring of Namira vanilla quest effect `NamiraRingScript` or
  PO3 cannibal event; Namira signature row +2.0). Either wire (declare constants
  properly, replacing the comment-only ids) or retract rows with owner sign-off.

## Route/Handle orphan verdicts (Phase 4, pending)

- `PDV_EventBus.RouteBosmerBaanDarGap` -> `HandlePlayerBelowHealthGate`
- `PDV_EventBus.RouteOrcStrongholdPresence` -> `HandleOrcStrongholdPresence`
- `PDV__ManagerQuest.HandleNordAncestorSpine` (gate find)
- `PDV__ManagerQuest.HandleDunmerClumsyCrime` (gate find)

## Signal waves (Phase 3)

- Wave 1 (wire now): Malacath BLOOD_KIN, Tuwhacca VAMPIRE_REENTRY,
  Magnus + Xarxes SHARED_PACT_MEMORY.
- Vestigial (remove now): 7x SIGNAL_CIVIC_SERVICE (Arkay, Dibella, Julianos,
  Kynareth, Mara, Stendarr, Zenithar).
- Wave 2 (classify now, build post-packet): quest-shaped -> matrix cell,
  state-shaped -> curated; see classification table (Phase 3).
- Wave 3 (spec now, build post-packet): 13 conduct beats.
