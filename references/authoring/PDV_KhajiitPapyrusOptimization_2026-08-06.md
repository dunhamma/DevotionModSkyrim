# Khajiit Papyrus Optimization Review -- 2026-08-06

Scope: the manager's Khajiit focus, god-strength, observation, road-home,
reward, Portent, and rescue paths; `PDV_PlayerEvents`; `PDV_EventBus`;
`PDV_Substrate_KhajiitLunar`; `PDV_ObserveMoonsEffect`;
`PDV_KhajiitAzurahPortentEffect`; `PDV_KhajiitBaanDarRescueEffect`; and the
shared `PDV_T3DailyLowHealthSaveEffect` base.

## Broken -- fixed

- Focus emergence could be evaluated after focus weight but before the same
  event's piety crossed Seeker. The curated Khajiit route now applies weight,
  applies piety, then evaluates; the central piety sink also reevaluates a
  Khajiit focus deity after a real piety movement.
- Focus emergence called the generic transition surface and then appended its
  own Book entry, creating two chronicle writes. First emergence and later
  reorientation now each write exactly one entry with their correct tone and
  pin policy.
- JSON runtime validation checked only the first shared and deity rows. It now
  verifies non-empty `id`, `title`, and `body` for all sixteen eligible rows
  before using the external pool; malformed content falls back to the compiled
  four-line set.

## Suboptimal -- fixed

- Resonance rewrote its StorageUtil state on every reconciliation even when the
  state had not changed. It now writes and refreshes the reward only on an
  actual transition.
- Focus evaluation previously carried an unused candidate helper; it was
  removed. The five focus weights remain cached once per evaluation and the
  second-place calculation uses those locals.
- Moon completion read game time three times in one event. It now caches the
  value once. Repeated substrate-form resolution in the observation and debug
  reset paths is likewise cached per call.

## Clean

- Moon observation is event-driven: one two-second wait after player activation,
  with one completion check and no update loop.
- God-strength reconciliation uses one scheduled `OnUpdateGameTime` at the next
  boundary. There is no continuous polling.
- Outdoor sleep captures context in `OnSleepStart` and consumes it once at
  `OnSleepStop`; interrupted or missing-context sleeps fail closed.
- Portent casts one native, conditioned detection packet. No actor scans,
  reference enumeration, or polling were introduced.
- Baan Dar's rescue is driven by `OnHit`/`OnDying`, has no 0.1-second watcher,
  and performs the final runtime eligibility check immediately before healing.
- JSON and StorageUtil reads in the observation selector are bounded to one
  low-frequency player rite. Selection is uniform over sixteen entries and the
  no-repeat scan is capped at sixteen.
- Reward reconciliation is bounded to five deity families and three exclusive
  tiers per family. Repeated engine calls are cached where the event reuses the
  result.

All changed scripts compile with zero errors and zero warnings. Runtime latency,
stack behavior, and save/load behavior remain an in-game proof boundary.
