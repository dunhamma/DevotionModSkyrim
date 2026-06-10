# Relic Resonance -- Bucket 9 Design Charter

**Status:** DESIGN DOSSIER ONLY -- no Papyrus/CK/ESP changes.
**Date:** 2026-06-10
**Bucket source:** `references/research/living-deities/04_future_buckets_backlog.md` #9

---

## What it adds

A deity whose artifact the player carries or uses passively notices. Relic
resonance is a low-frequency mood nudge: once per dawn, the engine checks
whether the player holds a relic linked to a deity in the active patron pool,
and if so applies a small `ApplyMoodDelta` to that deity. This is the quietest
positive feedback loop in the system -- it rewards "you chose to keep it" with
a gentle ambient approval, without touching piety or tier.

Scope constraint: reuses the dawn tick already proven in
`RunDawnConsolidateScratch`, the `ApplyMoodDelta` path proven in the LD-P1
slice, and the `PDV_FLST_FaucetDaedricArtifacts` FormList already wired in
`PDV_PlayerEvents.OnObjectEquipped`. No new detection hooks, no new event
vocabulary IDs, no new Papyrus base classes.

---

## Shippable relics by deity (vanilla + DLC, concrete)

Criteria: the item must be a named unique given to the player by or for a
specific Prince, from the base game, Dawnguard, Hearthfire, or Dragonborn.
"Shippable" means the FormID is in vanilla/DLC (no mod dependency) and the
artifact is already referenced in lore as belonging to that deity.

| Deity | Artifact(s) | Quest / source | Notes |
|---|---|---|---|
| Hircine | Savior's Hide, Ring of Hircine | DA05 (Ill Met By Moonlight) | Two rewards; player keeps one or both |
| Nocturnal | Skeleton Key (Nightingale Bow/Armor also thematic) | TG09 (Hard Answers) | Skeleton Key is the canonical relic; Nightingale set is Nocturnal-touched |
| Meridia | Dawnbreaker | DA09 (The Break of Dawn) | Meridia's personal weapon |
| Boethiah | Ebony Mail | DA02 (Boethiah's Calling) | Classic Boethiah artifact |
| Mephala | Ebony Blade | DA08 (The Whispering Door) | Mephala's hunger-blade |
| Hermaeus Mora | Oghma Infinium, Seeker Robes (Dragonborn) | DA04 (Discerning the Transmundane), DB | Infinium is one-use; robes are keepable |
| Clavicus Vile | Rueful Axe, Masque of Clavicus Vile | DA03 (A Daedra's Best Friend) | Player chooses one |
| Mehrunes Dagon | Mehrunes' Razor | DA07 (Pieces of the Past) | Assembled from three fragments |
| Sheogorath | Wabbajack | DA15 (The Mind of Madness) | Unmistakable signature |
| Namira | Ring of Namira | DA11 (The Taste of Death) | |
| Sanguine | Sanguine Rose | DA14 (Night to Remember) | |
| Vaermina | Skull of Corruption | DA16 (Waking Nightmare) | |
| Molag Bal | Mace of Molag Bal | DA10 (The House of Horrors) | |
| Peryite | Spellbreaker | DA13 (The Only Cure) | |
| Azura | Azura's Star / Black Star | DA01 (The Black Star) | Black Star = deviation; lore maps both to Azura |
| Malacath | Volendrung | DA06 (The Cursed Tribe) | |
| Meridia | (see above) | | |
| Stendarr | None confirmed vanilla | -- | No canonical daedric-hunter relic in vanilla; OMIT from P1 |
| Aedra (general) | Amulets of the Divines | Temple/merchant | Not unique per deity; lower signal value; defer to P2 |

**P1 pilot scope:** Hircine + Nocturnal + Meridia. These are the three deities
with the clearest single unique relic, the strongest lore tie, and existing
PDV actor coverage. Hircine is the LD-P1 pilot deity (curse-gated deity face
per `04_living_deities_architecture.md` SS2.0); Nocturnal and Meridia are
existing `PDV_DaedricPath_*` actors that would need an accepted-deity face for
full mood participation (see feasibility).

---

## Passive vs. equip -- recommendation

**Recommendation: per-dawn inventory scan (passive).**

One-line reason: Skyrim's `Actor.GetItemCount(Form)` is a cheap synchronous
call at a single dawn-tick entry point, so scanning 1--3 FormLists over the
active patron pool costs ~3 calls per dawn and fits cleanly into the existing
`RunDawnConsolidateScratch` loop with zero new event registration.

**On-equip alternative cost:**
The equip hook already fires in `PDV_PlayerEvents.OnObjectEquipped` and
dispatches `EVT_ACCEPT_DAEDRIC_ARTIFACT` (event 368) via
`PDV_FLST_FaucetDaedricArtifacts`. That path goes to `ScoreAction` and feeds
piety, not mood. Routing equip events to `ApplyMoodDelta` would require either
(a) a second branch in `OnObjectEquipped` -- workable but couples two separate
signals in one handler -- or (b) a new event ID in the 300+ vocabulary that
`ScoreAction` maps to a mood-feed, which does not exist. The per-dawn scan
avoids both and makes unequip/drop naturally handled (the artifact is simply
absent at the next dawn scan, so the nudge stops without any
`OnObjectUnequipped` bookkeeping).

**Why not per-frame polling:** Skyrim has no affordable per-frame item check.
`OnUpdate`-based polling is explicitly expensive at short intervals and the
0.7^n decay pattern in `ConsumeDailyRepeatMultiplier` is already tied to the
dawn boundary. Per-dawn is consistent with every other piety and mood signal
in the system.

---

## P1 pilot scope

Three deities, one relic each:

- Hircine: Savior's Hide OR Ring of Hircine (whichever the player holds)
- Nocturnal: Skeleton Key (proof item: Skeleton Key is a quest item and may
  never leave inventory; this needs an in-game behavior verification -- see
  feasibility 01)
- Meridia: Dawnbreaker

New authoring surface: three `PDV_FLST_Relic_<Deity>` FormLists (one per
deity), one new branch in `RunDawnConsolidateScratch` (or a new
`RunDawnApplyRelicResonance` sub-function), and three rows in a new
`PDV_RelicResonance.csv` authoring table.

Full-roster expansion (all 15+ deities above) is content fill once the pilot
proves the FormList-per-deity scan pattern.
