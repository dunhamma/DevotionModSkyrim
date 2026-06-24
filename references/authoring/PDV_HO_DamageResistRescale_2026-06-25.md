# HO DamageResistRescale (Codex Handoff, 2026-06-25) [queue B / short-mechanical / decision D4]

## Status up front: ALREADY DONE -- verify-and-close, do not re-author

Verify-current-state first (grep before authoring -- multiple items were found
already-built this session). This is one of them. The grep below shows all five
"still-wrong" races already carry the corrected armor-points ladder AND the
2026-06-14 idempotency stamp. Treat this doc as a closeout/confirmation pass,
not a build. If the grep still matches what is recorded here, write nothing and
mark the item closed; the stale input was the MEMORY note, not the specs.

Closeout check (2026-06-24): verified again. Bosmer, Imperial, Nord, Khajiit, and
Dunmer remain on the 15/30/50 armor-points ladder where those specs actually use
DamageResist; Dunmer still correctly has only the T2/T3 secondary DamageResist
entries. No spec or ESP write was performed.

## Goal

DamageResist rewards are armor POINTS, not a percent. PDV's old flat ~12
magnitude ceiling wrongly capped them, making armor rewards trivial under
Requiem (+4 AR ~= 0.3% damage reduction). Orc was rescaled to the
T1 15 / T2 30 / T3 50 ladder (broad T1/T2 + capstone on the three life-mode T3s).
The stated goal was to apply that ladder to the still-wrong races:
Bosmer / Imperial / Nord / Khajiit / Dunmer.

Finding: all five are ALREADY on the 15/30/50 ladder and already carry the
`ceilingReviewApplied20260614` stamp ("DamageResist rescaled to the armor-points
ladder T1 15/T2 30/T3 50 ... mirrors the Orc spec"). The work landed in the
2026-06-14 Requiem ceiling review, not in a later pass. The MEMORY index line
("other races ... still on the wrong scale; T2/T3 await the pending Orc author
helper") is STALE and should be corrected to "rescaled 2026-06-14".

## Evidence / current-state grep (exact seams)

Spec files (one per race), reward effect records under `.records[].effects[]`
(or `.broadTiers[]` / focused-emphasis chains) with
`"actorValue": "DamageResist"`:

- references/authoring/PDV_OrcRewardRecords.spec.json   (REFERENCE -- already correct: 15/30/50; broad T1/T2 + 3 life-mode T3 capstones)
- references/authoring/PDV_BosmerRewardRecords.spec.json
- references/authoring/PDV_ImperialRewardRecords.spec.json
- references/authoring/PDV_NordRewardRecords.spec.json
- references/authoring/PDV_KhajiitRewardRecords.spec.json
- references/authoring/PDV_DunmerRewardRecords.spec.json

Re-run this grep to confirm (Git Bash):

    cd references/authoring
    for f in PDV_BosmerRewardRecords.spec.json PDV_ImperialRewardRecords.spec.json \
             PDV_NordRewardRecords.spec.json PDV_KhajiitRewardRecords.spec.json \
             PDV_DunmerRewardRecords.spec.json; do
      echo "=== $f ==="
      grep -A1 '"actorValue": "DamageResist"' "$f" | grep magnitude | sort | uniq -c
    done

Observed magnitudes (2026-06-25), all on-ladder, zero stragglers at ~12 or below:

| Race     | DamageResist magnitudes present | Shape | On-ladder? |
|----------|--------------------------------|-------|------------|
| Bosmer   | 15 x1, 30 x1, 50 x2            | Bandit Road focused 3-tier (15/30/50) + a 50 carry-weight-paired capstone | YES |
| Imperial | 15 x1, 30 x2, 50 x2            | Talos focused 3-tier (15/30/50) + Stuhn/Block-paired T2 30 + T3 50 | YES |
| Nord     | 15 x2, 30 x2, 50 x3            | Stuhn's Ward + Talos's Resolve chains (15/30/50 each) + a Stendarr/Block 50 | YES |
| Khajiit  | 15 x1, 30 x1, 50 x1            | Baan Dar focused 3-tier (15/30/50) | YES |
| Dunmer   | 30 x1, 50 x1                   | Boethiah focused-emphasis chain; DamageResist is a SECONDARY effect on T2/T3 only (no T1 DR by design, primary is One-Handed) | YES |

Dunmer caveat: the absence of a T1 (15) DamageResist entry is correct-by-design,
not a missing rescale -- Boethiah's spine primary is One-Handed and DamageResist
rides as the T2/T3 secondary. Do not "fill" a T1 DR to make the table symmetric.

## Design / steps (only if a future grep shows a regression)

If and only if a straggler reappears (a DamageResist magnitude <= ~12, or any
value off the 15/30/50 ladder on a broad/focused tier), the fix is spec-only:

1. Edit the offending `effects[].magnitude` in the race spec to the ladder value
   (T1 -> 15, T2 -> 30, T3/capstone -> 50). Pure JSON edit; no Papyrus.
2. UPDATE that spec's `ceilingReviewApplied20260614` note text only if the
   description no longer matches reality (do not add a second stamp).
3. Re-emit via the existing reward-author tool (the same tool that owns these
   specs -- do NOT write Devotion.esp by hand). Reuse the existing author entry
   point used for the Orc/Bosmer rescale; no new code path.

REUSED existing functions / contracts (do not reinvent):
- The reward-author tool re-emits SPEL/MGEF magnitudes from these spec files;
  the spec is the source of truth, the ESP is derived.
- The armor-points exemption rationale is already documented inline in every
  spec's `ceilingReviewApplied20260614` field -- cite it, do not re-derive.

## Idempotency guard (CRITICAL -- do not double-apply)

These are ABSOLUTE tier magnitudes, not deltas. Every one of these specs also
carries `"cumulativeRebalanceApplied": "2026-06-11 highest-tier-only guard
applied; magnitudes are current absolute tier values, do not re-run"`. Per the
rebalance-tool idempotency lesson, a cumulative/additive rebalance tool DOUBLES
every value on a second --write. So:

- Never run a cumulative/additive rebalance pass over these specs again.
- DamageResist values 15/30/50 are final absolute targets; if you see 30/60/100
  you double-applied -- revert, do not "re-tune down".
- A reward-author re-emit (absolute write from spec) is idempotent by
  construction; a rebalance tool (delta math) is NOT. Only the former is safe.

## Serialize note

Spec-only, no manager edits -> low serialize risk. But the reward-author re-emit
writes Devotion.esp in place, so if any re-emit is actually needed, serialize the
ESP write with concurrent writers (Codex / houseCARL / xEdit / a running
Skyrim) per the houseCARL-holds-ESP-lock and P2-source-fill-atomic lessons. If
no straggler is found (expected), there is no ESP write and no serialization
concern at all.

## Verify

Expected outcome: nothing to build, so the gates should already be green for
this item. If a re-emit was performed, run the full chain:

1. pdv_compile -> 0/0 (no .psc touched, so this is just a regression guard)
2. pdv_verify -> FAIL=0
3. pdv_signal_e2e_gate -> 0 RED
4. pdv_integrity_harness -> PASS

Plus the item-specific check: re-run the grep above and confirm only 15/30/50
appear for DamageResist across all five specs (Dunmer 30/50 only, by design).

## Open item to hand back

- Correct the stale MEMORY index line
  (damageresist-armor-points-ceiling-exemption.md): change "other races
  (Bosmer/Imperial/Nord/Khajiit/Dunmer) still on the wrong scale; T2/T3 await
  the pending Orc author helper" to record that the 2026-06-14 ceiling review
  already rescaled all five to 15/30/50 (stamped `ceilingReviewApplied20260614`
  in each spec). This is the only remaining action for D4.
