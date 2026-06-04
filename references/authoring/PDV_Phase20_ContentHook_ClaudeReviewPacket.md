# PDV Phase 20 Content Hook Claude Review Packet

Status: review-only, not live-fill authority.

This packet holds plausible but unapproved hooks that need lore review, branch proof, or stronger local readback before any ESP FormList fill. The implementation authority remains `PDV_Phase20_P2ImmersiveReceivers.manifest.json`, `PDV_Phase20_SourceFillApprovalLedger.json`, live `PDV_PlayerEvents.psc`, and verifier/readback output.

## Approval Bar

- local quest-stage readback is authoritative for exact stage IDs and branch outcomes.
- UESP can support context sanity, but cannot approve live source fill by itself.
- A hook must name the race lane, route owner, exact source kind, accepted context, rejected context, duplicate guard, and review status.
- Broad category hooks, lore-controversial hooks, scan-only quest candidates, and branch-unproven hooks stay here.
- This packet is not live-fill authority; promotion requires manifest update, verifier support, and readback proof.

## Review Queue

| Candidate | Race/Lane | Why It Is Not Approved Yet | Required Proof |
|---|---|---|---|
| Dawnguard Bloodline branch outcomes | Altmer, Nord, Imperial, Breton, cross-race vampire rupture | Branch semantics are viable but side-stage exactness must be locked before scoring. | Local quest-stage readback for vampire/refusal branches, rejected-stage context, duplicate guard, and route-entry manifest row. |
| Destroy the Dark Brotherhood path | Argonian Sithis and Imperial civic rupture | It may be meaningful, but the current route block only promotes DB01/DB11 Sithis path. | Exact quest/stage outcome readback and race-specific accepted/rejected context. |
| Civil War oath and allegiance validators | Imperial civic, Nord old ways, Redguard sect pressure | Oath context is strong in concept but risky if whole faction membership or radiant war progress scores. | Exact joining quest/stage branch proof, side selection semantics, and one-shot duplicate guard. |
| Per-hold Hall of the Dead or Arkay service hooks | Nord Hircine/Arkay, Imperial civic, Breton vow | Too broad if implemented as shrine/location proximity or generic undead cleanup. | Specific quest/stage, book, or service source with anti-farm proof. |
| Dragonborn/Mora DLC2 knowledge hooks | Dunmer deviation, Breton hidden art, Altmer crisis, Khajiit focus | Lore weight is real, but DLC2 branches and Mora interaction need exact outcome separation. | DLC2 readback table, exact branch routing, and Daedric/reward precedence review. |
| Generic spell-learning filters | Breton hidden art, Altmer Magnus, Dunmer deviation | Current policy rejects generic spell learning; only curated occult/hidden-art spells may pass. | Spell whitelist with rationale, sourceKind `spell-learned`, and no broad school/category fill. |
| Generic harvest/weather/nature loops | Breton Green Way, Argonian Hist, Bosmer Y'ffre | Broad environmental events can farm or misread normal travel. | Small curated source list, cooldown/duplicate guard, and Survey/status wording. |
| Broad Daedric artifact possession | Dunmer, Khajiit, Orc, Redguard, all races | Artifact ownership alone often lacks branch intent and can conflict with race-specific theology. | Exact quest outcome or explicit manager-owned Daedric precedence contract. |
| Reward stack escalation | All races plus all Daedric lanes | First-tier reward records are contract-only until readback and smoke; grants are intentionally unwired. | SPEL/MGEF readback, manager property wiring, one-active/stack-cap verifier, and targeted compile. |

## Promotion Checklist

1. Add the hook to `routeEntries` or `sourceFillEntries` with accepted/rejected context and duplicate guard.
2. Prove local readback for the exact source.
3. Run `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries`.
4. Run `--check-exact-stage-gates` and `--check-source-fill` if the source becomes live fill.
5. Re-run strict Phase 20 verifier.
