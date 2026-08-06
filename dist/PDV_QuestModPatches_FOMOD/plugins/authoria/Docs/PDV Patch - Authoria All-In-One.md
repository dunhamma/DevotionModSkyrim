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
- `PDV_AuthoriaARR_Combined.esp` (ESPFE): the one combined Authoria plugin for
  KoK R11 deployment and this cumulative FOMOD. It replaces the former
  `PDV_Patch_Authoria_QuestMods.esp` and `PDV_AuthoriaARR_Compatibility.esp`
  donors, with 32 records total: 21 quest/dialogue overrides and 11 shrine-prayer
  ACTIs. Source quest SEQ files remain supplied by their respective masters.
- `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`: the 11 read-back prayer activators
  route as once-per-day prayer (`202`), not QASmoke commitment (`200`). Jyggalag
  is absent. Wyrmstooth placements use different base forms and are not claimed.
- The combined-plugin external-reference scan found five unrelated unreadable
  records; it did not establish a runtime or support result.
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
