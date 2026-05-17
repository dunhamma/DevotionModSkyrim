# Implementation Risk Notes

## High-Risk Patterns

| Pattern | Why risky | Safer PDV pattern |
|---|---|---|
| Raw skill XP scoring | Muffle, crafting, training, and other loops are farmable. | Score curated skill milestones or quest-validated learning. |
| Raw crafting counts | Iron dagger, potion, and enchant loops can explode. | Require value/quality/context and daily caps. |
| Frequent polling | Increases script latency anxiety and wastes work. | Use Story Manager, player alias events, and dawn consolidation. |
| Runtime FormList mutation for stable indexes | CK Wiki notes runtime-added forms have ordering caveats. | Keep deity rosters CK-authored when order matters. |
| Notification for every score event | Players actively install tools to hide notification spam. | Silent by default; debug-only detailed traces. |
| Hard decay with no recovery | Feels like a chore meter and punishes roleplay pacing. | Slow decay, clear neglect warnings, recovery rituals. |
| Generic radiant quest scoring | Radiant targets can be random/repeatable/colliding. | Use curated faction/quest milestones; treat radiant as context. |
| Broad GMST edits | High compatibility blast radius. | Use PDV records, magic effects, conditions, and scripts. |
| Current-race-only theology | Vampirism, beast forms, and custom races distort current race. | Use stored `PDV_GLO_OriginRace` and curse-state overlays. |

## Verification Before Build

Before implementing a new signal family:

1. Identify the vanilla event or CK surface.
2. Verify payload and timing with a test receiver or Papyrus trace.
3. Define anti-farm rules.
4. Decide whether the signal writes piety scratch, reputation track, state track, or only debug.
5. Add a row to `pdv-signal-hook-index.csv`.
6. Add verifier coverage if record wiring is required.

Sources: `ck_story_manager`, `ck_sm_event_node`, `ck_formlist_addform`, `nexus_notification_filter`, `reddit_tedium_not_immersion`.
