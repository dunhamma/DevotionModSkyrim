# Requiem regen-vs-pool flips proposal (2026-06-22)

Research output: how Requiem food "re-adds health rate," the Requiem-proof calibration,
and which Devotion health rewards should flip from a max-HP **pool** boost to a **regen**
(Fortify HealRateMult) buff. **Needs user approval before it becomes a build spec.**

## The mechanism (verified via houseCARL on the ARR list)

Requiem zeroes natural regen with a **constant drain**: `REQ_Trait_NoHealthRegeneration`
(SPEL `609AF0:Requiem.esp`) → `REQ_AbHide_DrainHealthRegeneration` (MGEF
`000A87:Requiem.esp`) = a **ValueModifier of 100 on HealRateMult**, Detrimental, Constant.
HealRateMult's baseline is 100, so −100 zeroes regen entirely. **Undead/vampires get it
twice.** Food/potions/enchants `Fortify HealRateMult` (PeakValueModifier) to add it back.

## Requiem-proof calibration — THE CRITICAL NUMBER

**Net-positive threshold = magnitude must EXCEED 100.** A Fortify of exactly 100 only
cancels the drain (≈vanilla feel); <100 leaves regen suppressed; **only >100 is felt at all.**

| Feel target | Requiem source mirrored | Fortify HealRateMult (base) | Duration |
|---|---|---|---|
| Weak / food-tier | `REQ_Alcohol_FortifyHealthRegeneration` (Juniper Mead 15%) | **~115** | 300s |
| Mid potion-tier | `REQ_Alch_FortifyHealthRegeneration` (Fair/Good 120–160%) | **220–260** | 300s |
| Strong potion-tier | same ladder (Remarkable 200%) | **300** | 300s |
| Constant enchant-tier | `REQ_Ench_FortifyHealthRegeneration` (200–400%) | **300–500** constant | 0 (equipped) |

Effect shape to copy: **Fortify HealRateMult, PeakValueModifier on HealRateMult,
FireAndForget, magnitude >100, duration 300s.**

### ⚠ Ceiling conflict (must resolve)
The project's `ceilingReviewApplied20260614` caps HealRateMult at **T2 15 / T3 30** —
**both below the drain of 100, so Requiem-swallowed by construction.** No reward in any
of the 10 specs currently exceeds 100 on a RateMult. **Any flip MUST use the >100 band,
which requires a documented exception to the 2026-06-14 ceiling note for HealRateMult.**
(That ceiling predates the drain measurement.)

## FLIP list (pool → regen) — mend-over-time fantasies

| Reward | Proposed effect (keep the non-Health halves) |
|---|---|
| Argonian / Hist broad emphasis / T1 (Health +10, "steadying hand") | Fortify HealRateMult **115** / 300s (food-band; weakest, broad/soft lane) |
| Khajiit / Baan Dar / T2 (Health +20, "mends quickly") | Fortify HealRateMult **180** / 300s |
| Khajiit / Baan Dar / T3 (Health +30) | Fortify HealRateMult **220** / 300s (out-recovers T2) |
| Bosmer / Living Story / T2 (Health +20, "keep you whole") | Fortify HealRateMult **180** / 300s |
| Bosmer / Living Story / T3 (Health +30) | Fortify HealRateMult **220** / 300s |
| Breton / Green Way / T3 (Health +20 + StaminaRateMult +20 + Restoration +18) | Fortify HealRateMult **220** / 300s (coheres with the existing recovery theme) |

## KEEP list (leave as pool / instant)

- **Pool (hardiness, not mending):** Argonian Hist substrate Mid/High/T3 + People; Bosmer
  Bandit Road; Breton Tradition broad T1/T2; Orc Malacath broad T2; Imperial Civic broad
  T1/T2; Imperial Arkay Vigil/Ward T2/T3; **Nord Shor T1/T2/T3 (pool-only BY DESIGN — do
  not add regen)**.
- **Instant (already Requiem-proof flat restore):** Imperial Mara mercy-on-rest (25/40);
  Redguard Tu'whacca death-rite; Dunmer ancestor-home pulse; Nord Shor cheat-death save.
- **Restoration-SKILL bonuses** (Breton focused +8/+18): inherently felt under Requiem
  (they scale the player's own cast heals) — leave as-is.

## Caveat
Regen = **out-of-combat recovery** (Requiem suppresses in-combat regen harder), so
emergency / "save me mid-fight" payoffs stay **flat Restore** (instant). Regen flips are
for the "the god sustains you between fights" fantasy only.

## Next step
User approves the flip list + the >100 ceiling exception → this becomes a reward-author
build spec (rewrite the Health-pool effect-items on those 6 rewards to Fortify HealRateMult
at the listed magnitudes), then ESP author + Reqtificator + in-game HP-bar proof.
