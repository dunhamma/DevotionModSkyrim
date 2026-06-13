# Khajiit Race Packet -- Papyrus Optimization Review (2026-06-13)

Scope: the Khajiit beta packet -- the 5 concrete deity shells + `PDV_Substrate_KhajiitLunar`,
plus the shared-engine paths that actually run Khajiit logic (`PDV_PlayerEvents`, `PDV_EventBus`
`RouteKhajiit*`, `PDV__ManagerQuest` Khajiit dawn/posture paths, `PDV_ActionRouter`). Method:
`housecarl:papyrus-optimization` (cost = trigger frequency x per-run latency; classify 🔴/🟡/🟢).

**Verdict: the Khajiit packet is clean. No 🔴. One low-severity 🟡 in shared code (cross-race,
not Khajiit-only). Nothing blocks beta.**

## Khajiit-specific scripts -- all 🟢

| Script | Trigger | Verdict |
|---|---|---|
| `PDV_Deity_Alkosh/BaanDar/Rajhin/Azura/Khenarthi` | none (called by manager scoring) | 🟢 Stateless `ScoreAction`/`ScoreCuratedSignal` table lookups. No event handlers, loops, or native calls. As optimized as it gets. |
| `PDV_Substrate_KhajiitLunar` | event (observe / road-home) | 🟢 StorageUtil read/write on rare signals; no `OnUpdate`, no polling. |
| `PDV_EventBus` `RouteKhajiit*` (~13 fns) | event (signal routing) | 🟢 Single-call assignment chains; one `ScoreAction`/`AdjustPiety` each; no loops. |
| New posture code in `PDV__ManagerQuest` (this session) | dawn (1/day) + curse transition (rare) + Rajhin theft (event) + Survey (on-demand) | 🟢 `RefreshKhajiitLunarPosture` early-outs when posture is unchanged; `RecordKhajiitShadowEvidence` is a cheap hour calc + one StorageUtil write gated to night + `IsKhajiitOrigin`. All low-frequency, well-guarded. |

## Shared-engine paths that carry Khajiit logic

**`PDV_PlayerEvents` -- 🟢 architecture, credit where due.** This is textbook-correct:
- `OnUpdate` is a **single-update chain with an exit** (`RegisterForSingleUpdate`, not bare
  `RegisterForUpdate`): the combat poll re-registers at 4 s **only while a session is open**, the
  origin retry at 2 s **only while origin is unresolved**, and once both resolve it stops re-arming
  -- **zero idle polling.**
- `OnPlayerLoadGame` re-arms registrations (survives save/load).
- `OnItemAdded` (Rajhin theft) leads with cheap early-outs (dead/teammate/detected/no-base)
  **before** the `FormList.HasForm` + StorageUtil cooldown work.
- `OnActorKilled` (Alkosh) is a PO3 event with a keyword guard, not a poll.
- `RegisterForCivilWarSignals` unregisters before re-registering (no double-registration on load).

**The one 🟡 (cross-race, low severity):** `Game.GetPlayer()` is re-resolved at ~5 handler sites
(`PDV_PlayerEvents.psc` lines 403/451/491/553/1112 and `CombatPollTick`) instead of the alias's own
cached `GetActorRef()` accessor (used at line 163). Each call is one native lookup (~1000x a cached
read). Hottest trigger is the per-hit/4-s combat path, so the real cost is small.
- **Fix (deferred -- cross-race):** route those sites through the existing `GetActorRef()` (the alias
  already points at the player), or cache an `Actor PlayerREF` on `OnInit`/`OnPlayerLoadGame`.
- **Why not applied this session:** `PDV_PlayerEvents` runs for all ten races; editing it this close
  to the Khajiit beta is out of the Khajiit scope. Flagged for a separate cross-race pass.

**`PDV__ManagerQuest` Khajiit paths -- 🟢.** `SyncKhajiitPhaseBlessing` and
`ProcessKhajiitAlkoshWordDrip` (a `while` loop **capped at 3**) run once per dawn, not per tick;
the focus/lunar math is comparison arithmetic, no iteration. The 1 s manager `OnUpdate` does its
real work on a 10 s sub-interval and has no Khajiit-specific per-tick cost.

**`PDV_ActionRouter` -- 🟢.** No Khajiit-specific branching of concern; classifies and dispatches.

## Bottom line
Ship as-is. The packet follows the heavy-pattern avoidance the skill looks for (event-driven,
single-update chains with exits, early-out guards, capped loops, cached/aliased refs, symmetric
registration). The lone `Game.GetPlayer()` 🟡 is a shared-engine micro-tidy worth doing in a
dedicated cross-race cleanup, not a Khajiit beta blocker.
