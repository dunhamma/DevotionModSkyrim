# Daedric Minus Triage — Wire 3, Remove 2 (Codex Handoff, 2026-06-24)

Decision logged in `PDV_MinusTriage_Decision_2026-06-24.md` (Class B). The 5 unemitted Daedric
minuses split: 3 have a real in-game trigger (wire the emit), 2 don't (remove; the deity keeps
its working LD dislikes — Boethiah 3, Mephala 3, Malacath 4, so none goes penalty-free).
These signals already DEFINE + HANDLE (`ScoreCuratedSignal` branch) — wiring = add the EMIT site.

## WIRE (add an `AwardCuratedSignalScaled` emit at the trigger)
| Signal | Trigger to hook | Notes |
|---|---|---|
| `PDV_Deity_Malacath` `SIGNAL_CURSE_CODE_RUPTURE` (−2) | **werewolf onset / lycanthropy** | Use the existing PDV werewolf/curse-onset detection. Lore-perfect: an Orc taking the beast-blood is a Code violation. Strongest of the three — do first. |
| `PDV_Deity_Mephala` `SIGNAL_SECRET_BETRAYED` (−3) | **clumsy crime — bounty gain / caught-in-the-act** | Hook a crime-gold/bounty-increase or getting-detected event; the opposite of Mephala's subtlety. |
| `PDV_Deity_Malacath` `SIGNAL_BROKEN_FAITH_KIN` (−2) | **desert sworn service / betray the kin-faction** | Only if a clean hook exists (follower-abandon / faction-leave). If not clean, HOLD this one and flag — do not force it. |

Each: `AwardCuratedSignalScaled(PDV_<Deity>, PDV_<Deity>.SIGNAL_X, None, multiplier)` with a
`ConsumeDailyRepeatMultiplier` anti-farm, mirroring the spine-pulse emits. The curated-parity
gate already confirms define+handle; this just adds the missing emit.

## REMOVE (no clean trigger; same safe-delete as the pantheon-creed handoff)
- `PDV_Deity_Boethiah` `SIGNAL_TREACHERY` (cowardice/fleeing the test — no clean event).
- `PDV_Deity_Malacath` `SIGNAL_SELF_ERASURE` (swallowing an insult — no clean event).
- Delete the `SIGNAL_*` + `DELTA_*` + `ScoreCuratedSignal` branch. **Safe-delete precondition:**
  `grep -rn "SIGNAL_X" live-source/Scripts/Source/` must show it ONLY in its own deity script.
- Note Malacath keeps `CURSE_CODE_RUPTURE` + `BROKEN_FAITH_KIN` (wired above) — remove ONLY `SELF_ERASURE`.

## ⚠️ Serialize (Malacath/Mephala/Boethiah scripts + manager hooks). Verify
- `pdv_compile` (each edited script) 0/0 → `pdv_verify` FAIL=0.
- `node tools/pdv_specced_minus_audit.mjs` → the 3 wired move to "emitted", the 2 removed drop
  out; combined with the pantheon removal, unemitted **18 → 4** (the 4 remaining = Hist×3 +
  Tuwhacca, which wire on their race spine pulses).
- `node tools/pdv_signal_e2e_gate.mjs` → 0 RED + curated-signal parity PASS.
