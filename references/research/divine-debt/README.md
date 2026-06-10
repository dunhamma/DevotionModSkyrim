# Future Bucket 5 -- Sacrifice Economy / Divine Debt (Charter)

**Status:** Design dossier. NO Papyrus/CK/ESP work. No in-game proof exists; every
seam below is traced to live source only (`D:/Wabbajack/modlists/Anvil/mods/Devotion/
Scripts/Source/`). Names are the contract, not line numbers.

**Bucket source:** `references/research/living-deities/04_future_buckets_backlog.md`
row 5: "Nocturnal/Clavicus 'luck debt' that accrues and must be repaid -- a
Daedra-native ledger distinct from piety." Seed = Sims need-decay + Daedric
boon/price triples. Owner ruling: **Daedra are first-class.**

---

## What divine debt IS

Divine debt is a **third axis** of the Daedric relationship, parallel to (not a
relabel of) the two axes that already ship:

- **Piety** (`PDV.Piety` per deity form, 0--200, tiers 25/50/85): standing earned by
  faithful acts. It only rises with worship and decays slowly with neglect. It is a
  *credit* relationship -- "this god knows your name."
- **Stigma** (`PDV.Daedric.Stigma` on the path form, see `PDV_DaedricPathBase.AddStigma`):
  social/spiritual *taint* the world reads off you for walking a transgressive path.
  It accrues from doing the path's own acts (hunt rites add stigma) and is reduced by
  cure/renounce. It is a one-way reputational cost the player carries, not something
  the Prince is owed.
- **Debt (NEW):** a *liability the Prince holds against you*. When a Daedric Prince
  does you a favor -- a luck draw, a clutch intervention, a granted boon -- the favor
  is **borrowed**, not given. The ledger remembers. It must be **repaid** in the
  Prince's own coin (sacrifice, offering, a demanded deed), and if left unpaid it
  **comes due** as an escalating consequence. Nocturnal's luck is on loan; Clavicus's
  bargains always have a catch.

The one-line distinction the owner asked us to resolve:

| Axis | Sign | Who holds it | How it moves up | How it clears | Default behavior |
|---|---|---|---|---|---|
| Piety | credit | you (your standing) | faithful acts | spent/decays | slow neglect drift |
| Stigma | cost | the world (reads you) | doing path acts | cure / renounce | passive, you carry it |
| **Debt** | **liability** | **the Prince (owes-you-back)** | **accepting favor/luck** | **sacrifice / offering / demanded deed** | **escalating "comes due" event** |

Debt is genuinely orthogonal: you can have high piety AND high debt (a devout
Nocturnal thief who keeps drawing on luck), or low piety AND high debt (a desperate
mortal who took one Clavicus bargain and never paid). Negative piety cannot express
"the Prince is actively owed and will collect" -- it only expresses absence of
standing. Stigma cannot express it either -- stigma never demands repayment, it just
marks you.

---

## Which Princes use it

Debt is **opt-in per Prince**, authored as a flag/row, never a universal tax.

| Prince | Debt flavor | P1 pilot? |
|---|---|---|
| **Nocturnal** | "Luck debt." Passive draw: her shadow-luck favors accrue debt over time even when idle (the Sims need-decay seed). Repaid by offerings in shadow / Evergloam-coded acts. | **YES -- primary pilot** |
| **Clavicus Vile** | "Bargain debt." Spiky, not passive: each accepted boon/wish is a discrete loan with a stated price. Repaid by the demanded deed; default = the wish "sours." | **YES -- secondary pilot** |
| Hircine | "Blood debt" (the hunt is never finished). Candidate; rides the existing stigma/hunt-rite model closely, so it is a natural *third* but NOT in the P1 pilot. | Backlog |
| Molag Bal / Boethiah / Mephala | coercive "tribute owed" framings exist in lore; defer until the two-Prince pilot proves the axis. | Backlog |

Princes with **no** debt row behave exactly as today (piety + stigma only). The axis
must be invisible for un-flagged Princes.

---

## Why a separate axis (not negative piety, not stigma)

1. **Direction of obligation is reversed.** Piety/stigma are *yours*. Debt is what the
   *Prince* will collect. Modeling "the god is owed" as negative piety would corrupt
   the tier spine (negative piety already means "no standing," and the dawn loop clamps
   piety to `[0, PIETY_MAX]` -- there is no room below 0 for a collectible liability).
2. **Repayment is an active loop, not decay.** Piety neglect is passive drift; stigma
   clears on cure/renounce. Debt is the only axis that demands the player *do a thing*
   (sacrifice) to zero it, and *escalates* if they don't -- a true economy.
3. **It can rise while standing is good.** A favored worshipper accrues the most debt
   precisely because they draw the most favor. Coupling debt to piety sign would make
   that impossible.

---

## Scope: P1 pilot vs backlog

**P1 pilot (smallest honest slice):**
- Two flagged Princes: **Nocturnal** (passive-draw debt) + **Clavicus** (bargain-loan
  debt). One passive accrual model, one discrete-loan model -- proves both shapes.
- One repayment channel (offering/sacrifice act) + one default-consequence event.
- New `PDV.Debt.*` StorageUtil namespace on the path form (parallel to `PDV.Daedric.*`).
- New dawn sub-phase that ages debt (Nocturnal passive draw) and checks for "comes due."
- Reuses the live Prince path roster, `ScoreRepeatableAction` anti-farm, the Daedric
  toast channel, and the price-spell swap machinery.

**Backlog (explicitly out of P1):**
- Hircine blood-debt, coercive-Prince tribute, debt-driven omens/avatar collectors
  (ties to Bucket 1/7), debt forgiveness questlines (Bucket 8), debt as a gate on
  artifact boons (Bucket 9).
- Any new quest content (the System Contract forbids new quests for first release).

See `01_feasibility.md` for seam-by-seam costing and `02_architecture.md` for the
buildable spec.
