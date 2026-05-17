# Radiant Quest Patterns

Skyrim's radiant system dynamically assembles content from components such as locations, targets, enemy types, and rewards. That is useful for replayability, but it makes radiant quests weaker evidence than curated quest stages.

## PDV Rules

1. Treat radiant completion as **context**, not a major theological event.
2. Prefer the quest giver, faction, location type, target type, and outcome over "a radiant quest happened."
3. Do not use radiant targets for irreversible state changes.
4. Add per-quest and per-day caps before any repeatable radiant signal can award piety.
5. For major faction progress, prefer curated quest stages over radiant filler counts.

## Known Cautions

- Radiant quests can choose target locations dynamically.
- Some radiant locations may be determined earlier than the player sees the quest.
- Radiant quests can collide with other quests by selecting locations that another quest needs.
- Civil War progression can replace Jarls and alter quest availability or state.

## PDV Use Cases

| Use case | Safe pattern |
|---|---|
| Companions radiant work | Small martial/community signal, capped, no major deity shift. |
| Thieves Guild jobs | Nocturnal or crime-path context, capped by city/day, stronger only when tied to guild milestone. |
| Bounty work | Protection/civic signal if target is hostile and quest giver is civic authority. |
| Animal extermination | Hunting/protection signal only when target and context fit the deity/race. |

Sources: `uesp_skyrim_radiant`, `uesp_skyrim_quest_timing`.
