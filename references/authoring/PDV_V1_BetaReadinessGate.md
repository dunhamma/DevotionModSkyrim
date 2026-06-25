# PDV V1 Beta-Readiness Gate

Created 2026-06-25. The single aggregator that says **"ready for testers" or not**. Supersedes the dated
per-race ledgers for the V1 beta decision. A race is GREEN only when its runsheet's every row is filled +
recorded; the beta opens when all rows below are GREEN and the small-build items are done.

## The gate (what "ready for testers" means)
1. **Machine proof** (all currently GREEN -- re-run before the run):
   `pdv_compile` 0/0 · `pdv_verify` FAIL=0 · `pdv_integrity_harness` PASS · `pdv_formal_offer_check` PASS ·
   `pdv_prisma_parity_unitd_check` 39/39.
2. **Per-race runsheet** (gameplay 7-slot + `## Prisma surfaces` table) recorded in-game on a NEW save.
3. **Universal Prisma checklist** recorded once.
4. **Small-build items** done (below).
5. Deferrals explicitly NOT blocking (below).

## Per-race verdicts (fill from the runsheets)
| Race | Runsheet | Gameplay slots | Prisma surfaces | Verdict | Notes |
|---|---|---|---|---|---|
| Nord | `PDV_RunSheet_Nord_V1.md` | PENDING | PENDING | **PENDING** | headline: offer accept/refuse + cadence |
| Imperial | `PDV_RunSheet_Imperial_V1.md` | PENDING | PENDING | **PENDING** | offers + Concordat band |
| Dunmer | `PDV_RunSheet_Dunmer_V1.md` | PENDING | PENDING | **PENDING** | offers + ancestor substrate driver |
| Altmer | `PDV_RunSheet_Altmer_V1.md` | PENDING | PENDING | **PENDING** | NEW alignment band + crisis toast |
| Bosmer | `PDV_RunSheet_Bosmer_V1.md` | PENDING | PENDING | **PENDING** | NEW path-confirm chronicle |
| Khajiit | `PDV_RunSheet_Khajiit_V1.md` | PENDING | PENDING | **PENDING** | NEW emergence + posture chronicle + pin fix |
| Argonian | `PDV_RunSheet_Argonian_V1.md` | PENDING | PENDING | **PENDING** | NEW Hist potion + adaptation beat |
| Orc | `PDV_RunSheet_Orc_V1.md` | PENDING | PENDING | **PENDING** | life-mode lapse toast fix; rite (no overlay by R1) |
| Redguard | `PDV_RunSheet_Redguard_V1.md` | PENDING | PENDING | **PENDING** | offers + sect champion chronicle; Requiem heal feel |
| Breton | `PDV_RunSheet_Breton_V1.md` | PENDING | PENDING | **PENDING** | NEW tradition + druidic-fork beats |
| Daedric (16) | `PDV_RunSheet_Daedric_V1.md` | PENDING | PENDING | **PENDING** | milestones, titles, Hircine, pre-pact watching |
| Universal Prisma | `PDV_RunSheet_Universal_Prisma_V1.md` | -- | PENDING | **PENDING** | panel/ESC, tier, digest, Ledger, prune, neglect |

Allowed verdicts: GREEN / RED / PENDING. Do not mark GREEN until every row of that sheet is filled.

## Small-build items (Codex; gate-blocking)
| Item | Owner | Status |
|---|---|---|
| Hist sap -> self-replenishing ALCH potion (consume -> Hist piety, returns to inventory) | Codex | PENDING (`PDV_PrismaParity_HistPotion_TitleRun_Handoff.md`) |
| Daedric 16 epithet title author-run against `Devotion.esp` | Codex | PENDING (same handoff) |

## Authoria pass
Each runsheet carries a "Running in Authoria (Requiem)" block: same steps, swap the preflight. Run the
**HP-bar reward-feel** checks (Redguard Tu'whacca heal, Namira feed-heal) in **Authoria** specifically.

## Deferred to 1.0 / V2 (NOT beta blockers)
- **Experience Mode** (Pilgrim/Wayfarer) -- design-locked, unbuilt -> 1.0.
- **ACTI "surface" final homes** -- the per-race recognition activators; the runsheets prove the organic
  hooks fire in normal play, which is the substantive part.
- **Redguard Far Shores token** -> V2 (owner not convinced it's needed).
- **Full 16-Prince Daedric runtime proof** -- may finish *during* the beta via the Daedric runsheet.
- Voiced dialogue -> V2.

## Verdict
**NOT YET READY** -- the runsheets exist; the in-game passes + the 2 small-build items are outstanding.
Flip to **READY FOR TESTERS** when every race + Daedric + universal row is GREEN and both small-build items are done.
