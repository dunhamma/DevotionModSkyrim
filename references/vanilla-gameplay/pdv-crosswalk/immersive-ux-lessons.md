# Immersive UX Lessons For PDV

**Status:** Living synthesis from mod pages and community discussions.  
**Validation:** Qualitative evidence only. Use for design direction, not as a vote count.

## Core Thesis

The best PDV experience is quiet, lore-reactive, and recoverable. The player should feel that their culture and gods are noticing Skyrim play they already care about. They should not feel that religion has become a chore meter.

## Repeated Player Signals

| Theme | Evidence | PDV rule | Risk if ignored |
|---|---|---|---|
| Quiet immersion wins | iHUD frames its value as HUD visibility only when needed. Notification Filter exists because players want to hide repeated top-left notifications. | Default to rare notifications and diegetic surfaces. | PDV feels like UI spam instead of religion. |
| Tedium is not immersion | Multiple survival-mod discussions complain about repeated food/water/sleep menu chores even when players like immersion in principle. | Avoid daily religious chores. Use meaningful rituals, dawn processing, and curated actions. | Players disable decay/neglect or the whole mod. |
| Configuration is expected but exhausting | SunHelm emphasizes customization; MCM Recorder exists because repeated MCM setup is painful. | Keep MCM small: status, debug, notification verbosity, broad tuning presets. | PDV becomes another setup screen tax. |
| Rewards need restraint | Religion overhauls such as Wintersun, Pilgrim, and Gods And Worship show demand for deity rewards, but community comparison often worries about long-play power creep. | Tier 1 useful, Tier 2 identity-defining, Tier 3 special but not build-breaking. | PDV becomes mandatory power optimization. |
| Punishment needs recovery | Religion/survival systems are disliked when decay or failure feels relentless. | Neglect should be legible, slow, and recoverable. Permanent lockouts need explicit in-world choice. | Players feel punished for exploration or taking breaks. |
| Compatibility is trust | Script-heavy/save-bloat discussions focus less on script count and more on bad event hygiene, orphaned scripts, waits, spam, and unsafe uninstall. | Stay event-driven, cap repeatable events, avoid high-frequency polling, document uninstall/update honestly. | Players distrust PDV in long modlists. |
| Vanilla-plus feel matters | Vanilla Plus framing favors Skyrim that still feels like Skyrim, just fresher. | Use shrines, blessings, factions, quests, conditions, and terse Skyrim-style text. | PDV feels like an imported reputation sim. |

## UX Rules To Carry Into Implementation

1. **One quiet daily resolution beats constant feedback.** If daily movement must surface, batch it at dawn or show it only in MCM/status.
2. **The player should know why a major change happened.** Patron commitment, tier changes, major neglect, and path lockouts need clear text.
3. **Debug is not UX.** Detailed scoring belongs behind debug, not in normal notifications.
4. **Roleplay friction should open a decision.** Pilgrimage, confession, offering, taboo breach, or renunciation are good friction. Repetitive menu actions are bad friction.
5. **Never make religion a second hunger meter.** Decay and neglect should be slow enough that players can adventure without servicing the system.
6. **Respect load-order anxiety.** Avoid runtime FormList mutation for stable indexes, avoid polling loops, and keep uninstall/update expectations honest.
7. **Make MCM optional after setup.** A player should be able to ignore MCM and still understand PDV through in-world outcomes.

## PDV Notification Policy Draft

| Surface | Default behavior |
|---|---|
| First-load origin | One notification only, especially if custom-race fallback occurs. |
| Routine piety gain/loss | Silent by default. Visible only in debug. |
| Dawn consolidation | Silent unless tier/neglect/patron state changes or user enables summaries. |
| Tier change | One concise notification or message. |
| Patron offer/commitment | Message box or dialogue-level clarity; this is a real choice. |
| Major neglect | Rare warning with recovery hint. |
| Debug harness | Explicitly opt-in and easy to turn off. |

Sources: `nexus_ihud`, `nexus_notification_filter`, `nexus_sunhelm`, `nexus_mcm_recorder`, `nexus_wintersun`, `nexus_pilgrim`, `nexus_gods_and_worship`, `reddit_tedium_not_immersion`, `reddit_survival_tedium`, `pcgamer_vanilla_plus`.
