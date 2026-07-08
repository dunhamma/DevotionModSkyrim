# PDV Deity Signal Remap Testing Documentation Handoff

Date: 2026-07-09

## Scope

Update tester-facing documentation for the deity signal remap implementation tranche. The docs must describe exact in-game smoke steps and keep proof boundaries separate:

- Readback proof: compile, verifier, ESP/SEQ/property checks, quest JSON compile, source-fill checks.
- Runtime-route proof: Papyrus route markers and expected single-fire/no-fire behavior.
- Manual visual proof: Active Effects, Book of Days, Survey/status, Prisma/notification copy, and save/load stack behavior.

## Implementation Surfaces To Cover

- Shared shrine cap: one shrine prayer credit per resolved deity per game day through `AwardShrinePrayerToDeityName` / `ConsumeShrinePrayerCredit`.
- Quest matrix remap: `PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv` merged into `PDV_QuestReactionMatrix_Full.csv` and live StorageUtil JSON.
- Likes/dislikes remap: `PDV_DeityLikesDislikes.csv`, regenerated `LoadRowsForDeity`, `ClearRowsForDeity` version bump to `LIKES_DISLIKES_VERSION = 14`.
- Formal offers: Breton active-tradition offers, Altmer Syrabane, Altmer Trinimac, existing no-offer races unchanged for Bosmer/Khajiit/Argonian.
- Reward/neglect: Breton Hidden Art Magnus/Mara, Green Way Y'ffre, Breton Health/Magic Resistance neglect, Knight's Road Speech, Altmer Syrabane/Trinimac rewards, Nord Orkey-as-Arkay display posture.

## Required Smoke Steps

Document exact setup:

- Devotion Dev profile selected.
- Clear Papyrus log before each smoke pass.
- Confirm `Devotion.esp`, `Devotion.seq`, live source, and compiled PEX freshness.
- Use MCM/debug controls only where the test requires them, and call out when a route is artificial.

Representative smoke routes to document:

- Shrine repeat click: same shrine/deity twice on same game day; first click credits, repeat is denied; multi-deity alias credit still works once per resolved deity.
- Multi-deity quest stage: one main-quest or faction outcome that credits/penalizes multiple gods through the quest matrix.
- Breton tradition route: one Knight's Road, one Hidden Art, and one Green Way source enough to prove Survey/status lane reflection.
- Exact-stage P2 source: one approved exact-stage source with its route key, duplicate guard, and rejected context.
- Formal offer: Breton off-tradition denial, Breton in-tradition offer, Altmer Syrabane/Trinimac offer.
- Neglect/debuff transition: Breton tradition lapse shows Maximum Health -10 plus Magic Resistance -5 where applicable, then clears on renewed practice.
- Taboo/hostile reaction: a hostile or taboo quest outcome becomes stigma/penalty instead of positive credit.
- Rejected generic source: generic faction membership, generic spell learning, generic undead killing, generic hunting, generic city presence, generic theft, generic shrine proximity, and non-terminal quest progress must not fire remap proof.
- Save/load stack check: no duplicate reward, neglect, or disfavor effect remains after save/load.

## Expected Visible Evidence

For each smoke route, tester docs should ask for:

- Papyrus route/log marker or explicit absence for rejected routes.
- Active Effects spell/effect name and magnitude.
- Book of Days entry text or absence.
- Survey/status lane state.
- Prisma/notification text, where applicable.
- Screenshot or written note after save/load for stack cleanliness.

## Commands Used By Implementation Session

```powershell
node tools\pdv_quest_tranche_merge.mjs
node tools\pdv_quest_matrix_compile.mjs --check --json
node tools\pdv_quest_matrix_compile.mjs --papyrusutil-check --json
node tools\pdv_compile.mjs --script PDV__ManagerQuest.psc --skip-verify --json
node tools\pdv_compile.mjs --script PDV_MCM.psc --skip-verify --json
node tools\pdv_verify.mjs --json
node tools\pdv_formal_offer_check.mjs --json
node tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json
node tools\pdv_deity_signal_remap_adversary_check.mjs
node tools\pdv_eligibility_reward_coverage_audit.mjs --json
node tools\pdv_antifarm_sweep_audit.mjs --json
node tools\pdv_ledger_coverage_audit.mjs --json
node tools\pdv_signal_floor_audit.mjs --json
node tools\pdv_requiem_penalty_audit.mjs --json
node tools\pdv_prisma_ui_audit.mjs --json
```

## Open Proof Boundary

This tranche is smoke-ready, not player-guide-ready. Runtime-route, manual visual proof, manual feel, and player-facing guide claims remain open until in-game evidence is recorded.
