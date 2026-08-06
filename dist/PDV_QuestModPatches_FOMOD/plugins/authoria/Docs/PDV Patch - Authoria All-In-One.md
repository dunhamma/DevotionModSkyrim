# Devotion Patch - Authoria All-In-One

Experimental cumulative compatibility candidate for ARR 2.5 KoK R11. It is
machine-verified, not supported, until the bundled runtime ledgers are returned
with equivalent evidence for every included case.

## Install boundary

- Requires Devotion with per-mod channel support.
- Select only the combined Authoria option for the full ARR list. Do not also
  select individual mod options.
- Install below Devotion so these scripts/data win, but do not place source files
  inside Reqtificator, ParallaxGen, DynDOLOD, Synthesis, TexGen, xLODGen, or NPC
  Plugin Chooser output. Regenerate tool outputs after source-mod changes.

## Contents

- 34 per-mod quest-reaction channel JSON files, covering the original package
  and ARR 2.5 tranches T13-T17.
- Current core and legacy ARR matrix JSON files.
- `PDV_PlayerEvents`, `PDV_EventBus`, and `PDV__ManagerQuest` source/PEX. These
  include channel loading, T16 ending resolution, the optional AFDI once-ever
  observer, the existing bard observer, and the Breton Hidden Art renewable.
- `PDV_Patch_Authoria_QuestMods.esp`, the pre-existing dialogue/result hook ESP
  for outcomes that cannot be observed through a safe data-only stage.
- `PDV_AuthoriaARR_Compatibility.esp` plus
  `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`: 11 read-back prayer activators routed
  as once-per-day prayer (`202`), not QASmoke commitment (`200`). Jyggalag is
  absent. Wyrmstooth placements use different base forms and are not claimed.
- `PDV_GreenPact_KID.ini`: exact-name classifications for 14 ARR animal foods
  and three Kabu gourd records, while retaining the existing Green Pact rules.
- Shared tester runbook and structured T13-T17/non-quest evidence ledgers.

## Proof boundary

The CSV/JSON gates, Papyrus compiler, source/PEX parity checks, record readback,
FOMOD simulations, file manifest, and archive checksum establish machine state
only. Controlled `setstage` may establish route delivery but cannot clear an
objective-derived row's semantic debt. Support requires the expected piety
result, exactly one toast, exactly one Book of Days beat, save/load behavior,
and organic correctness for every applicable case.
